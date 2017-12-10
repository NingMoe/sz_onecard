CREATE OR REPLACE PROCEDURE SP_PB_Refund_Dept
(
	p_ID              char,
	p_CARDNO          char,
	p_TRADETYPECODE   char,
	p_BACKMONEY       int,		--退款金额
	p_DBalunitNo	  char,
    p_TRADEID         out char, -- Return Trade Id
    p_currOper        char,
    p_currDept        char,
    
    p_retCode         out char, -- Return Code
    p_retMsg          out varchar2  -- Return Message

)
AS
    v_TradeID 			char(16);
    v_CURRENTTIME 		date := sysdate;
    v_ex          		exception;
	v_int				int;
	v_cardno			char(16);--实际要处理的卡号
	v_cardstate			char(2);
	v_RSRV1				varchar2(20);--旧卡对应的新卡卡号
	v_reasoncode		char(2);
BEGIN
    -- 1) Get trade id
    SP_GetSeq(seq => v_TradeID);
    p_TRADEID := v_TradeID;
    --判断ID是否存在，解决数据重复提交的问题wdx 20130111
	SELECT COUNT(*) INTO V_INT
	FROM TF_B_REFUND 
	WHERE ID=P_ID;
	if(v_int>0) THEN
		p_retCode := 'ASPPBRD001';
        p_retMsg  := '数据重复提交，请查验';
	end if;
    -- 2) Log operation
    BEGIN
        INSERT INTO TF_B_TRADE
              (TRADEID,ID,TRADETYPECODE,CARDNO,ASN,CARDTYPECODE,CURRENTMONEY,OPERATESTAFFNO,
              OPERATEDEPARTID,OPERATETIME)
          SELECT
                v_TradeID,p_ID,p_TRADETYPECODE,CARDNO,ASN,CARDTYPECODE,p_BACKMONEY,p_currOper,
                p_currDept,v_CURRENTTIME
          FROM TF_F_CARDREC
          WHERE CARDNO = p_CARDNO;
          
    EXCEPTION
          WHEN OTHERS THEN
              p_retCode := 'S001014101';
              p_retMsg  := 'Fail to log the operation' || SQLERRM;
              ROLLBACK; RETURN;
    END;
    
	-- 3) Log the refund  
    BEGIN
        INSERT INTO TF_B_REFUND
              (TRADEID		,ID				,TRADETYPECODE	,BACKMONEY		,DBALUNITNO		,
              OPERATESTAFFNO,OPERATETIME	,CARDNO			,FACTMONEY)
         VALUES
               (v_TradeID	,p_ID			,p_TRADETYPECODE,p_BACKMONEY	,p_DBalunitNo	,
               p_currOper	,v_CURRENTTIME	,p_CARDNO		,p_BACKMONEY);
    EXCEPTION
          WHEN OTHERS THEN
              p_retCode := 'S001014102';
              p_retMsg  := 'Fail to log the refund' || SQLERRM;
              ROLLBACK; RETURN;
    END;
	
	BEGIN
		INSERT INTO TF_B_DEPTACCTRADE(
			TRADEID     , TRADETYPECODE    , DBALUNITNO      , CURRENTMONEY    ,
			PREMONEY    , NEXTMONEY        , OPERATESTAFFNO  , OPERATEDEPARTID ,
			OPERATETIME 
		 )SELECT
			v_TradeID	, '22'             , p_DBalunitNo    , p_BACKMONEY		,
			a.PREPAY   , p_BACKMONEY+a.PREPAY , p_currOper	 , p_currDept		, 
			v_CURRENTTIME
		  FROM TF_F_DEPTBAL_PREPAY a
		  WHERE a.DBALUNITNO = p_DBalunitNo
		  AND   a.ACCSTATECODE = '01';
		EXCEPTION WHEN OTHERS THEN
		  P_RETCODE := 'S008905001';
		  P_RETMSG  := '记录网点结算单元资金管理台账表失败'||SQLERRM;
		  ROLLBACK;RETURN;
    END;
	
	BEGIN
        UPDATE TF_F_CARDEWALLETACC
        SET CARDACCMONEY = CARDACCMONEY - p_BACKMONEY,
            TOTALSUPPLYTIMES = TOTALSUPPLYTIMES - 1,
            TOTALSUPPLYMONEY = TOTALSUPPLYMONEY - p_BACKMONEY
        WHERE CARDNO = p_CARDNO
		AND USETAG='1';

        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;    
    EXCEPTION
          WHEN OTHERS THEN
              p_retCode := 'S001014100';
              p_retMsg  := 'Fail to update acc' || SQLERRM;
              ROLLBACK; RETURN;
    END;
	
	BEGIN
		UPDATE TF_F_DEPTBAL_PREPAY T
		SET T.PREPAY = T.PREPAY + p_BACKMONEY,
			T.UPDATESTAFFNO	= p_currOper,
			T.UPDATETIME	= v_CURRENTTIME
		WHERE T.ACCSTATECODE = '01'
		AND   T.DBALUNITNO = p_DBalunitNo;
		
		IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
	EXCEPTION
		WHEN OTHERS THEN
			p_retCode := 'S001124100';
			p_retMsg  := '更新预付款账户表失败' || SQLERRM;
			ROLLBACK; RETURN;
	END;
    
  p_retCode := '0000000000';
  p_retMsg  := '';
  COMMIT; RETURN;
END;
/
show errors

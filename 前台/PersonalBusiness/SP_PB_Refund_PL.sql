CREATE OR REPLACE PROCEDURE SP_PB_Refund
(
		p_ID              char,
		p_CARDNO          char,
		p_TRADETYPECODE   char,
		p_BACKMONEY       int,
		p_BANKCODE        char,
		p_BANKACCNO       varchar2,
    p_CUSTNAME        varchar2,
    p_BACKSLOPE       Decimal,
    p_FACTMONEY       int,
    p_TRADEID         out char, -- Return Trade Id
    p_currOper        char,
    p_currDept        char,
    
    p_PURPOSETYPE     char,     --add by jiangbb 
    
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
     
    
    --通过旧卡找到未转值的新卡
	v_cardno:=p_CARDNO;
	while(true)
	loop
		--可读换卡已转值的，则允许退款。且退款到新卡上。
		select cardstate,RSRV1 into v_cardstate,v_RSRV1 from tf_f_cardrec where cardno=v_cardno;
		if(v_cardstate ='02') then
			begin
			--判断是否可读卡换卡
			select reasoncode into v_reasoncode from tf_b_trade where cardno=trim(v_RSRV1) and oldcardno=v_cardno and tradetypecode in ('03','73','74','75','7C');
			exception when no_data_found then
				exit when 1=1;
			end;
			if(v_reasoncode in ('12','13')) then
				v_cardno:=trim(v_RSRV1);
			else
				v_cardno:=p_CARDNO;
				exit when 1=1;
			end if;
		else
			exit when 1=1;
		end if;
	end loop;
	
	
	
	-- 3) Log the refund  RSRV1存放实际退款的卡账户
    BEGIN
        INSERT INTO TF_B_REFUND
              (TRADEID,ID,TRADETYPECODE,CARDNO,BANKCODE,BANKACCNO,BACKMONEY,CUSTNAME,
              BACKSLOPE,FACTMONEY,OPERATESTAFFNO,OPERATETIME,PURPOSETYPE,RSRV1)
         VALUES
               (v_TradeID,p_ID,p_TRADETYPECODE,p_CARDNO,p_BANKCODE,p_BANKACCNO,p_BACKMONEY,
               p_CUSTNAME,p_BACKSLOPE,p_FACTMONEY,p_currOper,v_CURRENTTIME,p_PURPOSETYPE,v_cardno);

    EXCEPTION
          WHEN OTHERS THEN
              p_retCode := 'S001014102';
              p_retMsg  := 'Fail to log the refund' || SQLERRM;
              ROLLBACK; RETURN;
    END;
	
    -- 4) update acc
    BEGIN
        UPDATE TF_F_CARDEWALLETACC
        SET CARDACCMONEY = CARDACCMONEY - p_BACKMONEY,
            TOTALSUPPLYTIMES = TOTALSUPPLYTIMES - 1,
            TOTALSUPPLYMONEY = TOTALSUPPLYMONEY - p_BACKMONEY
        WHERE CARDNO = v_cardno
		AND USETAG='1';

        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;    
    EXCEPTION
          WHEN OTHERS THEN
              p_retCode := 'S001014100';
              p_retMsg  := 'cardno:' || v_cardno || ';Fail to update acc' || SQLERRM;
              ROLLBACK; RETURN;
    END;
    
  p_retCode := '0000000000';
  p_retMsg  := '';
  COMMIT; RETURN;
END;
/
show errors

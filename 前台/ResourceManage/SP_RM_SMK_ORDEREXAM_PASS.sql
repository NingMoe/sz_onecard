--------------------------------------------------
--  市民卡下单审核通过存储过程
--  初次编写
--  蒋兵兵
--  2012-11-26
--------------------------------------------------
CREATE OR REPLACE PROCEDURE SP_RM_SMK_ORDEREXAM_PASS
(
    P_SESSIONID       CHAR,
    P_CURROPER        CHAR,
    P_CURRDEPT        CHAR,
    p_retCode     out char, -- Return Code
    p_retMsg      out varchar2  -- Return Message
)
AS
    V_CARDORDERID     CHAR(18);     --订购单号
    V_CARDORDERTYPE   CHAR(2);      --订购类型
	V_CARDORDERSTATE  CHAR(1);		--订购单状态
	V_FILENAME		  VARCHAR2(255);--制卡文件名
    V_CARDNUM         INT;          --订购数量
    V_BEGINCARDNO     VARCHAR2(16); --起始卡号
    V_ENDCARDNO       VARCHAR2(16); --结束卡号
	V_BATCHNO		  VARCHAR2(30); --批次号
	V_BATCHDATE		  VARCHAR2(20);	--批次日期
    V_MANUTYPECODE    CHAR(2);      --卡片厂商
	V_REMARK		  VARCHAR2(255);--备注
        
    V_FROMCARD        NUMERIC(16);  --开始卡号
    V_TOCARD          NUMERIC(16);  --结束卡号
    V_CARDNO          VARCHAR2(16); --卡号
    V_ASN             CHAR(16);     --ASN号
    v_seqNo           CHAR(16);     --流水号
    V_EXIST           INT     ;     --存在数量
    V_TODAY           DATE:=SYSDATE;
    V_EX              EXCEPTION;
    
BEGIN
	SELECT f0 INTO V_CARDORDERID FROM TMP_COMMON WHERE f1 = p_SESSIONID;
	
	  --获取流水号
	  SP_GetSeq(seq => v_seqNo);
	  BEGIN
	  	--参数赋值
			SELECT
			    CARDNUM        , BEGINCARDNO   , ENDCARDNO       , CARDORDERTYPE,
			    FILENAME       , MANUTYPECODE  , BATCHNO         , BATCHDATE 	,
				CARDORDERSTATE , REMARK
			INTO
			    V_CARDNUM      , V_BEGINCARDNO , V_ENDCARDNO    , V_CARDORDERTYPE,
			  	V_FILENAME     , V_MANUTYPECODE, V_BATCHNO      , V_BATCHDATE    ,
				V_CARDORDERSTATE, V_REMARK
			FROM TF_F_SMK_CARDORDER
			WHERE CARDORDERID = V_CARDORDERID;
	  EXCEPTION
			WHEN NO_DATA_FOUND THEN
		          p_retCode := 'S094570156'; 
		          p_retMsg  := '未找到订购单';
		          ROLLBACK; RETURN;
	  END;
		
		--更新订购单
		BEGIN
			UPDATE TF_F_SMK_CARDORDER 
			SET    CARDORDERSTATE = '1'     ,
			       EXAMTIME = V_TODAY       ,
			       EXAMSTAFFNO = P_CURROPER
			WHERE  CARDORDERID = V_CARDORDERID ;		
		
      IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
    EXCEPTION
      WHEN OTHERS THEN
        P_RETCODE := 'S094570107';
        P_RETMSG  := '更新订购单失败'||SQLERRM;      
        ROLLBACK; RETURN; 			
	  END;				
		
	    -- 判断时候已有卡片在库
	    SELECT count(*) INTO v_exist FROM  TL_R_ICUSER WHERE CARDNO BETWEEN V_BEGINCARDNO AND V_ENDCARDNO;
	
	    IF v_exist > 0 THEN
	        p_retCode := 'A002P01B01'; p_retMsg  := '已有卡片存在于库中';
	        ROLLBACK;RETURN;
	    END IF;
	
	    --用户卡入库
	    V_FROMCARD := TO_NUMBER(V_BEGINCARDNO);
	    V_TOCARD   := TO_NUMBER(V_ENDCARDNO);
	
	    BEGIN
	        LOOP
	            V_CARDNO := SUBSTR('0000000000000000' || TO_CHAR(V_FROMCARD), -16);
	            V_ASN    := '00215000' || SUBSTR(V_CARDNO, -8);
	            --记录IC卡库存表
	            INSERT INTO TL_R_ICUSER( 
	                CARDNO          , ASN              , CARDPRICE    , 
	                UPDATESTAFFNO   , UPDATETIME       , 
	                MANUTYPECODE    , RESSTATECODE
	           )VALUES(
	                V_CARDNO        , V_ASN            , 0            , 
	                P_CURROPER      , V_TODAY          , 
	                V_MANUTYPECODE  , '15'         );
	
	            EXIT WHEN  V_FROMCARD  >=  V_TOCARD;
	
	            V_FROMCARD := V_FROMCARD + 1;
	        END LOOP;
	    EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S002P01B02'; p_retMsg  := '记录电子钱包IC卡库存表失败,' || SQLERRM;
	            ROLLBACK; RETURN;
	    END;
	
	    
	
	    --记录用户卡库存操作台账
	    BEGIN
	        INSERT INTO TF_R_ICUSERTRADE(
	            TRADEID          , BEGINCARDNO     , ENDCARDNO       , CARDNUM         ,
	            CARDTYPECODE     , MANUTYPECODE    , OPETYPECODE      , OPERATESTAFFNO ,
				OPERATEDEPARTID  , OPERATETIME
	       )VALUES(
	            v_seqNo          , V_BEGINCARDNO   , V_ENDCARDNO     , V_CARDNUM       , 
	            '18'      		 , V_MANUTYPECODE  ,'20'             , P_CURROPER      ,
				P_CURRDEPT       , V_TODAY
	            );
	    EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S002P01B03'; p_retMsg  := '记录用户卡库存操作台账失败' || SQLERRM;
	            ROLLBACK; RETURN;
	    END;
		
			--删除卡片下单卡号排重表记录
			BEGIN
				DELETE FROM TD_M_SMKCARDNO_EXCLUDE WHERE CARDORDERID = V_CARDORDERID;
				
				IF  SQL%ROWCOUNT = 0 THEN RAISE V_EX; END IF;
		  EXCEPTION
		     WHEN OTHERS THEN
		          p_retCode := 'S094570157'; p_retMsg  := '删除卡片下单卡号排重表记录失败' || SQLERRM;
		          ROLLBACK; RETURN;				
			END;

		--记录单据管理台账表
		BEGIN	
			INSERT INTO TF_B_SMK_ORDERMANAGE(
					TRADEID				,ORDERID			,OPERATETYPECODE	,CARDNUM			,
					MANUTYPECODE		,BATCHNO			,FILENAME			,BATCHDATE			,
					OPERATETIME			,OPERATESTAFF		,REMARK
					)VALUES
					(v_seqNo			,V_CARDORDERID    	,'03'				,V_CARDNUM			,
					V_MANUTYPECODE		,V_BATCHNO			,V_FILENAME			,V_BATCHDATE		,
					V_TODAY				,p_currOper			,V_REMARK);
					IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
				  EXCEPTION
					WHEN OTHERS THEN
					  P_RETCODE := 'S094780021';
					  P_RETMSG  := '添加市民卡单据管理台帐表失败'||SQLERRM;      
					  ROLLBACK; RETURN;				  
		END;
		
		--同步卡管系统导入市民卡库存表
		BEGIN
			SP_CM_ORDERIN(V_BEGINCARDNO,V_ENDCARDNO,
						p_currOper,p_currDept,p_retCode,p_retMsg);
		IF p_retCode != '0000000000' THEN RAISE v_ex; END IF;
				EXCEPTION
				WHEN OTHERS THEN
					ROLLBACK; RETURN;
		END;

    p_retCode := '0000000000';
	p_retMsg  := '';
	COMMIT; RETURN;    	  
END;

/
show errors
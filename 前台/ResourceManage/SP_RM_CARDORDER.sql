CREATE OR REPLACE PROCEDURE SP_RM_CARDORDER
(
	P_CARDORDERTYPE        CHAR     ,  --订购单类型
	P_APPLYORDERID         CHAR     ,  --需求单号
	P_CARDTYPECODE         CHAR     ,  --卡类型编码
	P_CARDSURFACECODE	     CHAR     ,  --卡面类型编码
	P_CARDSAMPLECODE	     CHAR     ,  --卡样编码
	P_CARDNAME             VARCHAR2 ,  --卡片名称
	P_CARDFACEAFFIRMWAY    CHAR     ,  --卡面确认方式
	P_VALUECODE            CHAR     ,  --面值
	P_CARDNUM              INT      ,  --卡片数量
	P_REQUIREDATE          CHAR     ,  --要求到货日期
	P_BEGINCARDNO          VARCHAR2 ,  --起始卡号
	P_ENDCARDNO            VARCHAR2 ,  --结束卡号
	P_CARDCHIPTYPECODE     CHAR     ,	 --芯片类型
	P_COSTYPECODE          CHAR     ,  --COS类型
	P_MANUTYPECODE         CHAR     ,  --卡片厂商
	P_APPVERNO             CHAR     ,  --应用版本
	P_VALIDBEGINDATE       CHAR     ,  --起始有效期
	P_VALIDENDDATE         CHAR     ,  --结束有效期
	P_ORDERID              out CHAR ,  --订购单号
	P_REMARK               VARCHAR2 ,  --备注
	p_currOper	           char     ,
	p_currDept	           char     ,
	p_retCode          out char     ,  -- Return Code
	p_retMsg           out varchar2    -- Return Message  
)
AS
    v_seqNo     CHAR(16);
    V_ORDERID   CHAR(18);
    v_exist     INT     ;
    V_EX        EXCEPTION      ;
    V_TODAY     DATE := SYSDATE;
    V_FROMCARD  CHAR(16)       ;
    V_TOCARD    CHAR(16)       ;
    V_CARDNO    CHAR(16)       ;
    V_FROMCARD2  INT       ;
    V_TOCARD2    INT      ;
    V_CARDNO2    CHAR(14)       ;
    V_ALREADYORDERNUM INT;          --已订购数量
    V_APPLYORDERSTATE CHAR(1);      --需求单状态
    V_APPLYCARDNUM    INT;          --需求单要求数量
BEGIN
	--判断需求单是否完成订购    
	SELECT CARDNUM,ALREADYORDERNUM 
	INTO   V_APPLYCARDNUM,V_ALREADYORDERNUM 
	FROM   TF_F_APPLYORDER 
	WHERE  APPLYORDERID = P_APPLYORDERID;
	
	IF P_CARDNUM + V_ALREADYORDERNUM >= V_APPLYCARDNUM THEN
	   V_APPLYORDERSTATE := '2';  --完成订购
	ELSE
	   V_APPLYORDERSTATE := '1';  --部分下单
	END IF;   
	    
	--更新卡片需求单
	BEGIN
		UPDATE TF_F_APPLYORDER
		SET    APPLYORDERSTATE = V_APPLYORDERSTATE ,
		       ALREADYORDERNUM = P_CARDNUM + V_ALREADYORDERNUM 
		WHERE  APPLYORDERID    = P_APPLYORDERID
		AND    APPLYORDERSTATE IN ('0','1')
		AND    USETAG = '1';
	
    IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
  EXCEPTION
    WHEN OTHERS THEN
      P_RETCODE := 'S094570103';
      P_RETMSG  := '更新卡片需求单失败'||SQLERRM;      
      ROLLBACK; RETURN; 		
  END;	
	
  --获取流水号
	SP_GetSeq(seq => v_seqNo);
  --生成订单号
  V_ORDERID := 'DG'||v_seqNo;
	
  IF P_CARDORDERTYPE = '01' OR P_CARDORDERTYPE = '02' THEN --如果是用户卡下单
      --查询是否已有卡片在库中
      SELECT count(*) INTO v_exist FROM  TL_R_ICUSER WHERE CARDNO BETWEEN P_BEGINCARDNO AND P_ENDCARDNO;

	    IF v_exist > 0 THEN
	        p_retCode := 'A002P01B01'; p_retMsg  := '已有卡片存在于库中';
	        ROLLBACK;RETURN;
	    END IF;
      --查询是否已有卡号下订购单
      SELECT COUNT(*) INTO v_exist FROM TD_M_CARDNO_EXCLUDE WHERE CARDNO BETWEEN P_BEGINCARDNO AND P_ENDCARDNO;
      
	    IF v_exist > 0 THEN
	        p_retCode := 'S094570150'; p_retMsg  := '已有卡片下订购单';
	        ROLLBACK;RETURN;
	    END IF;    

      --记录卡片下单卡号排重表
	    V_FROMCARD := TO_NUMBER(P_BEGINCARDNO);
	    V_TOCARD   := TO_NUMBER(P_ENDCARDNO);
	
	    BEGIN
	        LOOP
	            V_CARDNO := SUBSTR('0000000000000000' || TO_CHAR(V_FROMCARD), -16);
	
	            INSERT INTO TD_M_CARDNO_EXCLUDE( 
	                CARDNO    , CARDORDERID  , CARDTYPECODE    , CARDSURFACECODE
	           )VALUES(
	                V_CARDNO  , V_ORDERID    , P_CARDTYPECODE  , P_CARDSURFACECODE
	                );
	
	            EXIT WHEN  V_FROMCARD  >=  V_TOCARD;
	
	            V_FROMCARD := V_FROMCARD + 1;
	        END LOOP;
	    EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S094570151'; p_retMsg  := '记录卡片下单卡号排重表失败' || SQLERRM;
	            ROLLBACK; RETURN;
	    END;	
  END IF;    
  
  IF P_CARDORDERTYPE = '03' THEN --如果是充值卡下单
      --记录卡片下单卡号排重表
	    V_FROMCARD2 := TO_NUMBER(SUBSTR(P_BEGINCARDNO,7,8));
	    V_TOCARD2   := TO_NUMBER(SUBSTR(P_ENDCARDNO,7,8));
	
	    BEGIN
	        LOOP
	            V_CARDNO2 := SUBSTR(P_BEGINCARDNO,0,6)||SUBSTR('00000000' || TO_CHAR(V_FROMCARD2), -8);
	
	            INSERT INTO TD_M_CHARGECARDNO_EXCLUDE( 
	                CARDNO    , CARDORDERID  
             )VALUES(
                  V_CARDNO2  , V_ORDERID    
                  );
  
              EXIT WHEN  V_FROMCARD2  >=  V_TOCARD2;
  
              V_FROMCARD2 := V_FROMCARD2 + 1;
          END LOOP;
      EXCEPTION
          WHEN OTHERS THEN
              p_retCode := 'S094570152'; p_retMsg  := '记录充值卡卡片下单卡号排重表失败' || SQLERRM;
              ROLLBACK; RETURN;
      END;  
      
      --记录充值卡操作日志表
      BEGIN
        INSERT INTO TL_XFC_MANAGELOG(  
            ID            , STAFFNO     , OPERTIME , OPERTYPECODE ,  
            STARTCARDNO   , ENDCARDNO  
        )VALUES(  
            v_seqNo       , P_CURROPER  , V_TODAY  , '05'         ,  
            P_BEGINCARDNO , P_ENDCARDNO  
            );   
        
        IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
      EXCEPTION
        WHEN OTHERS THEN
          P_RETCODE := 'S094570154';
          P_RETMSG  := '记录充值卡操作日志表失败'||SQLERRM;      
          ROLLBACK; RETURN;            
      END;
  END IF;
  
  BEGIN
    --记录卡片订购单
    INSERT INTO TF_F_CARDORDER(
        CARDORDERID    , CARDORDERTYPE       , APPLYORDERID      , CARDORDERSTATE     ,
        USETAG         , CARDTYPECODE        , CARDSURFACECODE   , CARDSAMPLECODE     ,
        CARDNAME       , CARDFACEAFFIRMWAY   , VALUECODE         , CARDNUM            ,
        REQUIREDATE    , BEGINCARDNO         , ENDCARDNO         , CARDCHIPTYPECODE   ,
        COSTYPECODE    , MANUTYPECODE        , APPVERNO          , VALIDBEGINDATE     ,
        VALIDENDDATE   , ORDERTIME           , ORDERSTAFFNO      , REMARK
    )VALUES(
        V_ORDERID      , P_CARDORDERTYPE     , P_APPLYORDERID    , '0'                ,
        '1'            , P_CARDTYPECODE      , P_CARDSURFACECODE , P_CARDSAMPLECODE   ,
        P_CARDNAME     , P_CARDFACEAFFIRMWAY , P_VALUECODE       , P_CARDNUM          ,
        P_REQUIREDATE  , P_BEGINCARDNO       , P_ENDCARDNO       , P_CARDCHIPTYPECODE ,
        P_COSTYPECODE  , P_MANUTYPECODE      , P_APPVERNO        , P_VALIDBEGINDATE   ,
        P_VALIDENDDATE , V_TODAY             , P_CURROPER        , P_REMARK
        );
        
     IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
     EXCEPTION
       WHEN OTHERS THEN
         P_RETCODE := 'S094570102';
         P_RETMSG  := '记录卡片订购单表失败'||SQLERRM;      
         ROLLBACK; RETURN;              
  END;
  
  BEGIN
    --记录单据管理台账表
    INSERT INTO TF_B_ORDERMANAGE(
        TRADEID        , ORDERTYPECODE       , ORDERID           , OPERATETYPECODE  ,
        CARDTYPECODE   , CARDSURFACECODE     , CARDSAMPLECODE    ,
        CARDNAME       , CARDFACEAFFIRMWAY   , VALUECODE         , CARDNUM          ,
        REQUIREDATE    , BEGINCARDNO         , ENDCARDNO         , CARDCHIPTYPECODE ,
        COSTYPECODE    , MANUTYPECODE        , APPVERNO          , VALIDBEGINDATE   ,
        VALIDENDDATE   , OPERATETIME         , OPERATESTAFF      , REMARK
    )VALUES(
        v_seqNo        , '02'                , V_ORDERID         , '01'             ,
        P_CARDTYPECODE , P_CARDSURFACECODE   , P_CARDSAMPLECODE  ,
        P_CARDNAME     , P_CARDFACEAFFIRMWAY , P_VALUECODE       , P_CARDNUM          ,
        P_REQUIREDATE  , P_BEGINCARDNO       , P_ENDCARDNO       , P_CARDCHIPTYPECODE ,
        P_COSTYPECODE  , P_MANUTYPECODE      , P_APPVERNO        , P_VALIDBEGINDATE   ,
        P_VALIDENDDATE , V_TODAY             , P_CURROPER        , P_REMARK
        );
     IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
     EXCEPTION
       WHEN OTHERS THEN
         P_RETCODE := 'S094570104';
         P_RETMSG  := '记录单据管理台账表失败'||SQLERRM;      
         ROLLBACK; RETURN;    
  END;  
    P_ORDERID := V_ORDERID;
    p_retCode := '0000000000';
    p_retMsg  := '成功';
    COMMIT; RETURN;      
END;
/
show errors
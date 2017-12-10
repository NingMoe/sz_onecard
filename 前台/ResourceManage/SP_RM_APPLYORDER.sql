--------------------------------------------------
--  下单申请存储过程
--  初次编写
--  石磊
--  2012-07-18
--------------------------------------------------
CREATE OR REPLACE PROCEDURE SP_RM_APPLYORDER
(
	P_APPLYORDERTYPE       CHAR     ,  --需求单类型
	P_ORDERDEMAND          VARCHAR2 ,  --订单要求
	P_CARDTYPECODE         CHAR     ,  --卡类型编码
	P_CARDSURFACECODE	     CHAR     ,  --卡面类型编码
	P_CARDSAMPLECODE	     CHAR     ,  --卡样编码
	P_CARDNAME             VARCHAR2 ,  --卡片名称
	P_CARDFACEAFFIRMWAY    CHAR     ,  --卡面确认方式
	P_VALUECODE            CHAR     ,  --面值
	P_CARDNUM              INT      ,  --卡片数量
	P_REQUIREDATE          CHAR     ,  --要求到货日期
	P_REMARK               VARCHAR2 ,  --备注
	P_ORDERID              out char ,  --需求单号
	p_currOper	           char     ,
	p_currDept	           char     ,
	p_retCode          out char     ,  -- Return Code
	p_retMsg           out varchar2    -- Return Message  
)
AS
    v_seqNo     CHAR(16);
    V_ORDERID   CHAR(18);
    V_EX        EXCEPTION      ;
    V_TODAY     DATE := SYSDATE;
BEGIN
	--获取流水号
	SP_GetSeq(seq => v_seqNo);
  --生成订单号
  V_ORDERID := 'XQ'||v_seqNo;
	
	BEGIN
		--记录卡片需求单表
		INSERT INTO TF_F_APPLYORDER(
		    APPLYORDERID        , APPLYORDERTYPE    , APPLYORDERSTATE   , ORDERDEMAND    ,
		    CARDTYPECODE        , CARDSURFACECODE   , CARDSAMPLECODE    , CARDNAME       ,
		    CARDFACEAFFIRMWAY   , VALUECODE         , CARDNUM           , REQUIREDATE    ,
		    ORDERTIME           , ORDERSTAFFNO      , REMARK            , USETAG
		)VALUES(
		    V_ORDERID           , P_APPLYORDERTYPE  , '0'               , P_ORDERDEMAND  ,
		    P_CARDTYPECODE      , P_CARDSURFACECODE , P_CARDSAMPLECODE  , P_CARDNAME     ,
		    P_CARDFACEAFFIRMWAY , P_VALUECODE       , P_CARDNUM         , P_REQUIREDATE  ,
		    V_TODAY             , P_CURROPER        , P_REMARK          , '1'
		    );
		    
     IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
     EXCEPTION
       WHEN OTHERS THEN
         P_RETCODE := 'S094570100';
         P_RETMSG  := '记录卡片需求单表失败'||SQLERRM;      
         ROLLBACK; RETURN;      		    
	END;
	
	BEGIN
		--记录单据管理台账表
		INSERT INTO TF_B_ORDERMANAGE(
		    TRADEID       , ORDERTYPECODE       , ORDERID           , OPERATETYPECODE  ,
		    ORDERDEMAND   , CARDTYPECODE        , CARDSURFACECODE   , CARDSAMPLECODE   ,
		    CARDNAME      , CARDFACEAFFIRMWAY   , VALUECODE         , CARDNUM          ,
		    REQUIREDATE   , OPERATETIME         , OPERATESTAFF      , REMARK
		)VALUES(
		    v_seqNo       , '01'                , V_ORDERID         , '00'             ,
		    P_ORDERDEMAND , P_CARDTYPECODE      , P_CARDSURFACECODE , P_CARDSAMPLECODE ,
		    P_CARDNAME    , P_CARDFACEAFFIRMWAY , P_VALUECODE       , P_CARDNUM        ,
		    P_REQUIREDATE , V_TODAY             , P_CURROPER        , P_REMARK
		    );
     IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
     EXCEPTION
       WHEN OTHERS THEN
         P_RETCODE := 'S094570101';
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

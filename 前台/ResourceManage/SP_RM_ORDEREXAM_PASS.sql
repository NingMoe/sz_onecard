CREATE OR REPLACE PROCEDURE SP_RM_ORDEREXAM_PASS
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
    V_CARDNUM         INT;          --卡片数量
    V_BEGINCARDNO     VARCHAR2(16); --起始卡号
    V_ENDCARDNO       VARCHAR2(16); --结束卡号
    V_COSTYPE         CHAR(2);      --COS类型
    V_CARDTYPE        CHAR(2);      --卡类型
    V_FACETYPE        CHAR(4);      --卡面类型
    V_CARDSAMPLECODE  CHAR(6);      --卡样编码
    V_CHIPTYPE        CHAR(2);      --芯片类型
    V_PRODUCER        CHAR(2);      --卡片厂商
    V_APPVERSION      CHAR(2);      --应用版本
    V_EFFDATE         CHAR(8);      --有效起始日期
    V_EXPDATE         CHAR(8);      --有效结束日期
    V_VALUECODE       CHAR(1);      --金额代码
    V_FROMCARD        NUMERIC(16);  --开始卡号
    V_TOCARD          NUMERIC(16);  --结束卡号
    V_CARDNO          VARCHAR2(16); --卡号
    V_ASN             CHAR(16);     --ASN号
    v_seqNo           CHAR(16);     --流水号
    V_EXIST           INT     ;     --存在数量
    V_TODAY           DATE:=SYSDATE;
    V_EX              EXCEPTION;
    
BEGIN
	FOR cur IN (SELECT f0 FROM TMP_COMMON WHERE f1 = p_SESSIONID) 
	LOOP
	  V_CARDORDERID := cur.f0;
	  --获取流水号
	  SP_GetSeq(seq => v_seqNo);
	  BEGIN
	  	--参数赋值
			SELECT
			    CARDNUM        , BEGINCARDNO   , ENDCARDNO       ,VALUECODE     ,
			    COSTYPECODE    , CARDTYPECODE  , CARDSURFACECODE , COSTYPECODE  ,
			    MANUTYPECODE   , APPVERNO      , VALIDBEGINDATE  , VALIDENDDATE ,
			    CARDORDERTYPE  , CARDSAMPLECODE
			INTO
			    V_CARDNUM      , V_BEGINCARDNO , V_ENDCARDNO    ,V_VALUECODE   ,
			  	V_COSTYPE      , V_CARDTYPE    , V_FACETYPE     , V_CHIPTYPE   ,
			  	V_PRODUCER     , V_APPVERSION  , V_EFFDATE      , V_EXPDATE    ,
			  	V_CARDORDERTYPE, V_CARDSAMPLECODE
			FROM TF_F_CARDORDER
			WHERE CARDORDERID = V_CARDORDERID;
	  EXCEPTION
			WHEN NO_DATA_FOUND THEN
		          p_retCode := 'S094570156'; 
		          p_retMsg  := '未找到订购单';
		          ROLLBACK; RETURN;
	  END;
		
		--更新订购单
		BEGIN
			UPDATE TF_F_CARDORDER 
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
		
		--判断是否是用户卡
		IF V_CARDORDERTYPE ='01' OR V_CARDORDERTYPE ='02' THEN --如果是用户卡存货补货或用户卡新制卡片
	    -- 判断时候已有卡片在库
	    SELECT count(*) INTO v_exist FROM  TL_R_ICUSER WHERE CARDNO BETWEEN V_BEGINCARDNO AND V_ENDCARDNO;
	
	    IF v_exist > 0 THEN
	        p_retCode := 'A002P01B01'; p_retMsg  := '已有卡片存在于库中';
	        ROLLBACK;RETURN;
	    END IF;
	
	    --用户卡入库
	    V_FROMCARD := TO_NUMBER(V_BEGINCARDNO);
	    V_TOCARD   := TO_NUMBER(V_ENDCARDNO);
	    
	    IF V_CARDORDERTYPE ='02' THEN --如果是用户卡新制卡片
	    BEGIN
	    	--更新IC卡卡面编码表
	    	UPDATE TD_M_CARDSURFACE
	    	SET    CARDSAMPLECODE = V_CARDSAMPLECODE
	    	WHERE  CARDSURFACECODE = V_FACETYPE
	    	AND    CARDSAMPLECODE IS NULL;
	    	
	      IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
	    EXCEPTION
	      WHEN OTHERS THEN
	          p_retCode := 'S094570170'; p_retMsg  := '更新IC卡卡面编码表失败' || SQLERRM;
	          ROLLBACK; RETURN;
	    END;
	    END IF;
	
	    BEGIN
	        LOOP
	            V_CARDNO := SUBSTR('0000000000000000' || TO_CHAR(V_FROMCARD), -16);
	            V_ASN    := '00215000' || SUBSTR(V_CARDNO, -8);
	            --记录IC卡库存表
	            INSERT INTO TL_R_ICUSER( 
	                CARDNO          , ASN              , CARDPRICE    , 
	                UPDATESTAFFNO   , UPDATETIME       , COSTYPECODE  , CARDTYPECODE  , 
	                CARDSURFACECODE , CARDCHIPTYPECODE , MANUTYPECODE , APPTYPECODE   , 
	                APPVERNO        , VALIDBEGINDATE   , VALIDENDDATE , RESSTATECODE
	           )VALUES(
	                V_CARDNO        , V_ASN            , 0            , 
	                P_CURROPER      , V_TODAY          , V_COSTYPE    , V_CARDTYPE    , 
	                V_FACETYPE      , V_CHIPTYPE       , V_PRODUCER   , '01'          , 
	                V_APPVERSION    , V_EFFDATE        , V_EXPDATE    , '15');
	
	            EXIT WHEN  V_FROMCARD  >=  V_TOCARD;
	
	            V_FROMCARD := V_FROMCARD + 1;
	        END LOOP;
	    EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S002P01B02'; p_retMsg  := '记录IC卡库存表失败,' || SQLERRM;
	            ROLLBACK; RETURN;
	    END;
	
	    
	
	    --记录用户卡库存操作台账
	    BEGIN
	        INSERT INTO TF_R_ICUSERTRADE(
	            TRADEID          , BEGINCARDNO     , ENDCARDNO       , CARDNUM         ,
	            COSTYPECODE      , CARDTYPECODE    , MANUTYPECODE    , CARDSURFACECODE , 
	            CARDCHIPTYPECODE , OPETYPECODE     , OPERATESTAFFNO  , OPERATEDEPARTID , 
	            OPERATETIME
	       )VALUES(
	            v_seqNo          , V_BEGINCARDNO   , V_ENDCARDNO     , V_CARDNUM       , 
	            V_COSTYPE        , V_CARDTYPE      , V_PRODUCER      , V_FACETYPE      , 
	            V_CHIPTYPE       , '20'            , P_CURROPER      , P_CURRDEPT      , 
	            V_TODAY
	            );
	    EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S002P01B03'; p_retMsg  := '记录用户卡库存操作台账失败' || SQLERRM;
	            ROLLBACK; RETURN;
	    END;
		
			--删除卡片下单卡号排重表记录
			BEGIN
				DELETE FROM TD_M_CARDNO_EXCLUDE WHERE CARDORDERID = V_CARDORDERID;
				
				IF  SQL%ROWCOUNT = 0 THEN RAISE V_EX; END IF;
		  EXCEPTION
		     WHEN OTHERS THEN
		          p_retCode := 'S094570157'; p_retMsg  := '删除卡片下单卡号排重表记录失败' || SQLERRM;
		          ROLLBACK; RETURN;				
			END;    
     
      
    END IF;

    --记录单据管理台账表
    BEGIN
      INSERT INTO TF_B_ORDERMANAGE(
          TRADEID          , ORDERTYPECODE     , ORDERID           , OPERATETYPECODE  ,
          CARDTYPECODE     , CARDSURFACECODE   , CARDSAMPLECODE    , VALUECODE        , 
          CARDNUM          , REQUIREDATE       , BEGINCARDNO       , ENDCARDNO        , 
          CARDCHIPTYPECODE , COSTYPECODE       , MANUTYPECODE      , APPVERNO         , 
          VALIDBEGINDATE   , VALIDENDDATE      , OPERATETIME       , OPERATESTAFF      
      )SELECT
          v_seqNo            , '02'              , t.CARDORDERID     , '03'             ,
          t.CARDTYPECODE     , t.CARDSURFACECODE , t.CARDSAMPLECODE  , t.VALUECODE      , 
          t.CARDNUM          , t.REQUIREDATE     , t.BEGINCARDNO     , t.ENDCARDNO      , 
          t.CARDCHIPTYPECODE , t.COSTYPECODE     , t.MANUTYPECODE    , t.APPVERNO       , 
          t.VALIDBEGINDATE   , t.VALIDENDDATE    , V_TODAY           , P_CURROPER        
       FROM  TF_F_CARDORDER t
       WHERE CARDORDERID = V_CARDORDERID; 
       
       IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
    EXCEPTION
       WHEN OTHERS THEN
            p_retCode := 'S094570108'; p_retMsg  := '记录单据管理台账表失败' || SQLERRM;
            ROLLBACK; RETURN;                   
    END;

  END LOOP;
    p_retCode := '0000000000';
    p_retMsg  := '成功';
    COMMIT; RETURN;        
END;
/
show errors
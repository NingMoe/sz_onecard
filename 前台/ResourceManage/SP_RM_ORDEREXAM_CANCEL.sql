CREATE OR REPLACE PROCEDURE SP_RM_ORDEREXAM_CANCEL
(
    P_SESSIONID       CHAR,
    P_CURROPER        CHAR,
    P_CURRDEPT        CHAR,
    p_retCode     out char, -- Return Code
    p_retMsg      out varchar2  -- Return Message
)
AS
    V_CARDORDERID     CHAR(18);     --订购单号
    V_APPLYORDERID    CHAR(18);     --需求单号
    V_CARDORDERTYPE   CHAR(2);      --订购类型
    V_CARDORDERSTATE  CHAR(1);      --订购状态
    V_CARDNUM         INT;          --卡片数量
    V_BEGINCARDNO     VARCHAR2(16); --起始卡号
    V_ENDCARDNO       VARCHAR2(16); --结束卡号
    V_BEGINCARDNO2    VARCHAR2(14); --充值卡起始卡号
    V_ENDCARDNO2      VARCHAR2(14); --充值卡结束卡号
    V_COSTYPE         CHAR(2);      --COS类型
    V_CARDTYPE        CHAR(2);      --卡类型
    V_FACETYPE        CHAR(4);      --卡面类型
    V_CHIPTYPE        CHAR(2);      --芯片类型
    V_PRODUCER        CHAR(2);      --卡片厂商
    V_TASKSTATE       CHAR(1);      --任务状态
    V_ALREADYORDERNUM INT;          --已订购数量
    V_APPLYORDERSTATE CHAR(1);      --需求单状态
    v_seqNo           CHAR(16);     --流水号
    V_EXIST           INT     ;     --存在数量
    V_COUNT           INT;
    V_TODAY           DATE:=SYSDATE;
    V_EX              EXCEPTION;
BEGIN
	FOR cur IN (SELECT f0 FROM TMP_COMMON WHERE f1 = p_SESSIONID) 
	LOOP
		V_CARDORDERID := cur.f0;
		BEGIN
		--参数赋值
			SELECT
				CARDORDERSTATE  , CARDNUM         , BEGINCARDNO     , ENDCARDNO    ,
				COSTYPECODE     , CARDTYPECODE    , CARDSURFACECODE , COSTYPECODE  ,
				MANUTYPECODE    , CARDORDERTYPE   , APPLYORDERID
			INTO
				V_CARDORDERSTATE, V_CARDNUM       , V_BEGINCARDNO  , V_ENDCARDNO  ,
				V_COSTYPE       , V_CARDTYPE      , V_FACETYPE     , V_CHIPTYPE   ,
				V_PRODUCER      , V_CARDORDERTYPE , V_APPLYORDERID
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
			SET    CARDORDERSTATE = '2'     ,
			       EXAMTIME = V_TODAY       ,
			       EXAMSTAFFNO = P_CURROPER
			WHERE  CARDORDERID = V_CARDORDERID 
			AND    CARDORDERSTATE IN ('0','1');   --0、待审核，1、审核通过
	
			IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
		EXCEPTION
		WHEN OTHERS THEN
			P_RETCODE := 'S094570109';
			P_RETMSG  := '更新订购单失败'||SQLERRM;      
			ROLLBACK; RETURN; 			
		END;	
	  
		--获取流水号
		SP_GetSeq(seq => v_seqNo);

		--记录单据管理台账表
		BEGIN
			INSERT INTO TF_B_ORDERMANAGE(
			    TRADEID          , ORDERTYPECODE     , ORDERID           , OPERATETYPECODE  ,
			    CARDTYPECODE     , CARDSURFACECODE   , CARDSAMPLECODE    , VALUECODE        , 
			    CARDNUM          , REQUIREDATE       , BEGINCARDNO       , ENDCARDNO        , 
			    CARDCHIPTYPECODE , COSTYPECODE       , MANUTYPECODE      , APPVERNO         , 
			    VALIDBEGINDATE   , VALIDENDDATE      , OPERATETIME       , OPERATESTAFF      
			)SELECT
			    v_seqNo            , '02'              , t.CARDORDERID     , '04'             ,
			    t.CARDTYPECODE     , t.CARDSURFACECODE , t.CARDSAMPLECODE  , '1'              , 
			    t.CARDNUM          , t.REQUIREDATE     , t.BEGINCARDNO     , t.ENDCARDNO      , 
			    t.CARDCHIPTYPECODE , t.COSTYPECODE     , t.MANUTYPECODE    , t.APPVERNO       , 
			    t.VALIDBEGINDATE   , t.VALIDENDDATE    , V_TODAY           , P_CURROPER        
			 FROM  TF_F_CARDORDER t
			 WHERE CARDORDERID = V_CARDORDERID; 
			 
			IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
	    EXCEPTION
			WHEN OTHERS THEN
			  p_retCode := 'S094570110'; p_retMsg  := '记录单据管理台账表失败' || SQLERRM;
			  ROLLBACK; RETURN;				       		
		END;		 
		
		IF (V_CARDORDERTYPE ='01' OR V_CARDORDERTYPE ='02') AND V_CARDORDERSTATE = '0' THEN --如果是用户卡存货补货或用户卡新制卡片 
			--删除卡片下单卡号排重表记录
			BEGIN
				DELETE FROM TD_M_CARDNO_EXCLUDE WHERE CARDORDERID = V_CARDORDERID;
				
				IF  SQL%ROWCOUNT = 0 THEN RAISE V_EX; END IF;
		    EXCEPTION
		        WHEN OTHERS THEN
		          p_retCode := 'S094570158'; p_retMsg  := '删除卡片下单卡号排重表记录失败' || SQLERRM;
		          ROLLBACK; RETURN;				
			END;	
		ELSIF  V_CARDORDERTYPE = '03' AND V_CARDORDERSTATE = '0' THEN  --如果是充值卡
		    BEGIN
				--删除卡片下单卡号排重表记录
				  DELETE FROM TD_M_CHARGECARDNO_EXCLUDE WHERE CARDORDERID = V_CARDORDERID;
				
				  IF  SQL%ROWCOUNT = 0 THEN RAISE V_EX; END IF;
		      EXCEPTION
			    WHEN OTHERS THEN
			       p_retCode := 'S094570159'; p_retMsg  := '删除充值卡卡片下单卡号排重表记录失败' || SQLERRM;
			       ROLLBACK; RETURN;				
			END; 

	    END IF;
		
		IF V_CARDORDERSTATE = '1' THEN --如果是审核通过再作废
			--判断需求单是否完成订购    
			SELECT ALREADYORDERNUM
			INTO   V_ALREADYORDERNUM
			FROM   TF_F_APPLYORDER 
			WHERE  APPLYORDERID = V_APPLYORDERID;
			
			IF V_ALREADYORDERNUM - V_CARDNUM <= 0 THEN
			   V_APPLYORDERSTATE := '0';  --未下订购单
			ELSE
			   V_APPLYORDERSTATE := '1';  --部分下单
			END IF;   
			    
			--更新卡片需求单
      BEGIN
        UPDATE TF_F_APPLYORDER
        SET    APPLYORDERSTATE = V_APPLYORDERSTATE ,
               ALREADYORDERNUM = V_ALREADYORDERNUM - V_CARDNUM 
        WHERE  APPLYORDERID    = V_APPLYORDERID
        AND    APPLYORDERSTATE IN ('1','2')
        AND    USETAG = '1';
      
              IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
      EXCEPTION
        WHEN OTHERS THEN
          P_RETCODE := 'S094570103';
          P_RETMSG  := '更新卡片需求单失败'||SQLERRM;      
        ROLLBACK; RETURN;     
        END;    
    
      IF V_CARDORDERTYPE ='01' OR V_CARDORDERTYPE ='02' THEN --如果是用户卡存货补货或用户卡新制卡片 
      
        SELECT count(*) INTO v_exist FROM  TL_R_ICUSER WHERE (CARDNO BETWEEN V_BEGINCARDNO AND V_ENDCARDNO) AND RESSTATECODE = '15';
    
        IF v_exist <> V_CARDNUM THEN
          p_retCode := 'S094570163'; p_retMsg  := V_CARDORDERID||'订购单号段中的卡号不全为订购状态';
          ROLLBACK;RETURN;
        END IF;
        
        BEGIN
          --删除用户卡库存表记录
          DELETE FROM TL_R_ICUSER WHERE (CARDNO BETWEEN V_BEGINCARDNO AND V_ENDCARDNO) AND RESSTATECODE = '15';
          IF  SQL%ROWCOUNT != V_CARDNUM THEN RAISE V_EX; END IF;
      EXCEPTION
        WHEN OTHERS THEN
          p_retCode := 'S094570159'; p_retMsg  := '删除用户卡库存表记录失败' || SQLERRM;
          ROLLBACK; RETURN;        
        END;
        
        BEGIN
          --记录用户卡库存操作台账
        INSERT INTO TF_R_ICUSERTRADE(
          TRADEID          , BEGINCARDNO     , ENDCARDNO       , CARDNUM         ,
          COSTYPECODE      , CARDTYPECODE    , MANUTYPECODE    , CARDSURFACECODE , 
          CARDCHIPTYPECODE , OPETYPECODE     , OPERATESTAFFNO  , OPERATEDEPARTID , 
          OPERATETIME
         )VALUES(
          v_seqNo          , V_BEGINCARDNO   , V_ENDCARDNO     , V_CARDNUM       , 
          V_COSTYPE        , V_CARDTYPE      , V_PRODUCER      , V_FACETYPE      , 
          V_CHIPTYPE       , '23'            , P_CURROPER      , P_CURRDEPT      , 
          V_TODAY
          );
          EXCEPTION
        WHEN OTHERS THEN
          p_retCode := 'S094570160'; p_retMsg  := '记录用户卡库存操作台账失败' || SQLERRM;
          ROLLBACK; RETURN;          
        END;
      
      ELSIF V_CARDORDERTYPE ='03' THEN  --如果是充值卡
       V_BEGINCARDNO2 := SUBSTR(V_BEGINCARDNO,14);
       V_ENDCARDNO2 :=SUBSTR(V_ENDCARDNO,14);
         SELECT COUNT(*) INTO V_COUNT FROM  TF_F_MAKECARDTASK  WHERE  CARDORDERID = V_CARDORDERID; 
         IF V_COUNT>0 THEN 
          
          BEGIN
        -- 查询制卡任务表
        SELECT TASKSTATE INTO V_TASKSTATE FROM   TF_F_MAKECARDTASK  WHERE  CARDORDERID = V_CARDORDERID;
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
              p_retCode := 'S094570161'; 
              p_retMsg  := '未找到此订购单对应的制卡任务';
              ROLLBACK; RETURN;
         END;
              
        IF V_TASKSTATE IS NOT NULL AND V_TASKSTATE='1' THEN  --任务处理中
          p_retCode := 'S094570162';
          p_retMsg  := V_CARDORDERID||'订单不可作废';
          ROLLBACK; RETURN;
        END IF;
        IF V_TASKSTATE='0' THEN
        BEGIN
        --删除制卡任务表
           DELETE FROM TF_F_MAKECARDTASK WHERE CARDORDERID = V_CARDORDERID;
           IF  SQL%ROWCOUNT = 0 THEN RAISE V_EX; END IF;
           EXCEPTION
           WHEN OTHERS THEN
            p_retCode := 'S094570163'; p_retMsg  := '删除制卡任务表失败' || SQLERRM;
            ROLLBACK; RETURN;  
          END;
        END IF;
        IF V_TASKSTATE='0' OR V_TASKSTATE ='3' THEN --任务待处理或处理失败时
         BEGIN  
        --删除卡片下单卡号排重表记录
          DELETE FROM TD_M_CHARGECARDNO_EXCLUDE WHERE CARDORDERID = V_CARDORDERID;
          IF  SQL%ROWCOUNT = 0 THEN RAISE V_EX; END IF;
          EXCEPTION
          WHEN OTHERS THEN
             p_retCode := 'S094570164'; p_retMsg  := '删除卡片下单卡号排重表记录失败' || SQLERRM;
             ROLLBACK; RETURN;        
         END; 
         END IF;
        IF V_TASKSTATE='2' THEN --任务处理成功时
         BEGIN
         --作废充值卡账户表
          UPDATE TD_XFC_INITCARD SET CARDSTATECODE = 'Z' 
          WHERE XFCARDNO BETWEEN V_BEGINCARDNO2 AND V_ENDCARDNO2;
          IF  SQL%ROWCOUNT = 0 THEN RAISE V_EX; END IF;
          EXCEPTION
          WHEN OTHERS THEN
             p_retCode := 'S094570165'; p_retMsg  := '作废充值卡账户表失败' || SQLERRM;
             ROLLBACK; RETURN; 
         END;
          BEGIN
        --记录充值卡操作日志表
        INSERT INTO TL_XFC_MANAGELOG(
          ID            , STAFFNO    , OPERTIME , OPERTYPECODE ,
          STARTCARDNO   , ENDCARDNO
        )VALUES(
          v_seqNo       , P_CURROPER , V_TODAY  , '09'         ,
          V_BEGINCARDNO2 , V_ENDCARDNO2
          );
            
            IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
        EXCEPTION
        WHEN OTHERS THEN
          p_retCode := 'S094570165'; p_retMsg  := '记录充值卡操作日志表失败' || SQLERRM;
          ROLLBACK; RETURN;              
      END; 
        END IF;
         
         END IF;
        
        
        
       
          
      END IF;
      END IF;
    END LOOP;  
    p_retCode := '0000000000';
    p_retMsg  := '成功';
    COMMIT; RETURN;        
END;
/
show errors
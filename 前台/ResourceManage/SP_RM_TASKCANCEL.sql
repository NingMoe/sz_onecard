CREATE OR REPLACE PROCEDURE SP_RM_TASKCANCEL 
(
    P_TASKID          CHAR,      --任务ID
    P_CARDORDERID     CHAR,      --订购单号
    P_CURROPER        CHAR,
    P_CURRDEPT        CHAR,
    p_retCode     out char, -- Return Code
    p_retMsg      out varchar2  -- Return Message
)
AS
    
    V_STARTCARDNO     CHAR(14); --起始卡号
    V_ENDCARDNO       CHAR(14); --结束卡号
    V_TASKSTATE       CHAR(1);      --任务状态
    v_seqNo           CHAR(16);     --流水号
    V_EXIST           INT     ;     --存在数量
    V_TODAY           DATE:=SYSDATE;
    V_EX              EXCEPTION;
    
BEGIN
  
   
    --获取流水号
    SP_GetSeq(seq => v_seqNo);
    BEGIN
      --参数赋值
      SELECT
          V_STARTCARDNO   , V_ENDCARDNO   , TASKSTATE      
          
      INTO
          V_STARTCARDNO   , V_ENDCARDNO   , V_TASKSTATE    
      FROM TF_F_MAKECARDTASK  --制卡任务表
      WHERE TASKID = P_TASKID;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
              p_retCode := 'S094570156'; 
              p_retMsg  := '未找到制卡任务表';
              ROLLBACK; RETURN;
    END;
    
    --判断任务的状态是否是待处理状态
    IF V_TASKSTATE<>'0'  THEN 
     p_retCode := 'S094570157'; p_retMsg  := '此订单的任务状态不为待处理状态，不可作废任务';
          ROLLBACK;RETURN;
    END IF;
    
    --更新制卡任务表
    BEGIN
      UPDATE TF_F_MAKECARDTASK 
      SET    TASKSTATE = '4'             ,
             OPERATOR = P_CURROPER       ,
             OPERDEPT = P_CURRDEPT       ,
             DATETIME = V_TODAY
      WHERE  TASKID = P_TASKID ;    
    
      IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
    EXCEPTION
      WHEN OTHERS THEN
        P_RETCODE := 'S094570108';
        P_RETMSG  := '更新制卡任务表失败'||SQLERRM;      
        ROLLBACK; RETURN;       
    END;  
          
     --删除充值卡下单卡号排重表记录            
   
     SELECT COUNT(*) INTO V_EXIST FROM  TD_M_CARDNO_EXCLUDE WHERE CARDORDERID = P_CARDORDERID;
     IF V_EXIST>0 THEN
      BEGIN
          DELETE FROM TD_M_CHARGECARDNO_EXCLUDE WHERE CARDORDERID = P_CARDORDERID;                                                
          IF  SQL%ROWCOUNT = 0 THEN RAISE V_EX; END IF;                                                
          EXCEPTION                                                
          WHEN OTHERS THEN                                                
             p_retCode := 'S094570164'; p_retMsg  := '删除充值卡下单卡号排重表记录失败' || SQLERRM;                                                
             ROLLBACK; RETURN; 
        END;
      END IF;                                                 
   
     

    --记录制卡任务操作台帐表
    BEGIN
      INSERT INTO TF_B_MAKECARDLOG(
          TASKID            ,CARDORDERID        ,TASKTYPECODE         ,CORPCODE          ,YEAR          ,                                              
          BATCHNO           ,VALUECODE          ,STARTCARDNO          ,ENDCARDNO         ,CARDNUM       ,                                              
          OPERATOR          ,OPERDEPT           ,DATETIME             ,TASKSTARTTIME      ,TASKENDTIME  , MAKEFILEPATH                                            
   
      )SELECT
          v_seqNo            , T.CARDORDERID     ,'1'                , T.CORPCODE        ,T.YEAR          ,
          T.BATCHNO          , T.VALUECODE       ,T.STARTCARDNO      ,T.ENDCARDNO        ,T.CARDNUM       ,                                              
          P_CURROPER         , P_CURRDEPT         ,V_TODAY            ,T.TASKSTARTTIME    ,T.TASKENDTIME   , T.FILEPATH       
       FROM  TF_F_MAKECARDTASK T
       WHERE TASKID = P_TASKID; 
       
       IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
    EXCEPTION
       WHEN OTHERS THEN
            p_retCode := 'S094570108'; p_retMsg  := '记录制卡任务操作台帐表失败' || SQLERRM;
            ROLLBACK; RETURN;                   
    END;

    p_retCode := '0000000000';
    p_retMsg  := '成功';
    COMMIT; RETURN;        
END;
/
show errors
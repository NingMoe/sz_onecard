CREATE OR REPLACE PROCEDURE SP_RM_TASKDELETE
(
    P_TASKID          CHAR,      --����ID
    P_CURROPER        CHAR,
    P_CURRDEPT        CHAR,
    p_retCode     out char, -- Return Code
    p_retMsg      out varchar2  -- Return Message
)
AS
    
    V_STARTCARDNO     CHAR(14); --��ʼ����
    V_ENDCARDNO       CHAR(14); --��������
    V_TASKSTATE       CHAR(1);      --����״̬
    v_seqNo           CHAR(16);     --��ˮ��
    V_TODAY           DATE:=SYSDATE;
    V_EX              EXCEPTION;
    
BEGIN
  
   
    --��ȡ��ˮ��
    SP_GetSeq(seq => v_seqNo);
    BEGIN
      --������ֵ
      SELECT
          V_STARTCARDNO   , V_ENDCARDNO   , TASKSTATE      
          
      INTO
          V_STARTCARDNO   , V_ENDCARDNO   , V_TASKSTATE    
      FROM TF_F_MAKECARDTASK  --�ƿ������
      WHERE TASKID = P_TASKID;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
              p_retCode := 'S094570156'; 
              p_retMsg  := 'δ�ҵ��ƿ������';
              ROLLBACK; RETURN;
    END;
    
    --�ж������״̬�Ƿ��Ǵ���ɹ�״̬
    IF V_TASKSTATE<>'2'  THEN 
     p_retCode := 'S094570157'; p_retMsg  := '�˶���������״̬��Ϊ����ɹ�״̬������ɾ������';
          ROLLBACK;RETURN;
    END IF;
    
    --�����ƿ������
    BEGIN
      UPDATE TF_F_MAKECARDTASK 
      SET    TASKSTATE = '5'             ,--ɾ��
             OPERATOR = P_CURROPER       ,
             OPERDEPT = P_CURRDEPT       ,
             DATETIME = V_TODAY
      WHERE  TASKID = P_TASKID ;    
    
      IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
    EXCEPTION
      WHEN OTHERS THEN
        P_RETCODE := 'S094570108';
        P_RETMSG  := '�����ƿ������ʧ��'||SQLERRM;      
        ROLLBACK; RETURN;       
    END;  
          
                                                 
   
     

    --��¼�ƿ��������̨�ʱ�
    BEGIN
      INSERT INTO TF_B_MAKECARDLOG(
          TASKID            ,CARDORDERID        ,TASKTYPECODE         ,CORPCODE          ,YEAR          ,                                              
          BATCHNO           ,VALUECODE          ,STARTCARDNO          ,ENDCARDNO         ,CARDNUM       ,                                              
          OPERATOR          ,OPERDEPT           ,DATETIME             ,TASKSTARTTIME      ,TASKENDTIME  , MAKEFILEPATH                                            
   
      )SELECT
          v_seqNo            , T.CARDORDERID     ,'2'                , T.CORPCODE        ,T.YEAR          ,
          T.BATCHNO          , T.VALUECODE       ,T.STARTCARDNO      ,T.ENDCARDNO        ,T.CARDNUM       ,                                              
          P_CURROPER         , P_CURRDEPT         ,V_TODAY            ,T.TASKSTARTTIME    ,T.TASKENDTIME   , T.FILEPATH       
       FROM  TF_F_MAKECARDTASK T
       WHERE TASKID = P_TASKID; 
       
       IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
    EXCEPTION
       WHEN OTHERS THEN
            p_retCode := 'S094570109'; p_retMsg  := '��¼�ƿ��������̨�ʱ�ʧ��' || SQLERRM;
            ROLLBACK; RETURN;                   
    END;

    --��¼�ƿ�������ʷ��                                    
    BEGIN                              
        INSERT INTO TF_BH_MAKECARDTASK(                                  
          TASKID      ,CARDORDERID      ,STARTCARDNO    ,ENDCARDNO   ,                                
          CARDNUM     ,OPERATOR         ,OPERDEPT       ,DATETIME                                    
        )                                  
        SELECT 
          T.TASKID    ,T.CARDORDERID    ,T.STARTCARDNO  ,T.ENDCARDNO   ,                                  
          T.CARDNUM   ,P_CURROPER       ,P_CURRDEPT     ,V_TODAY                                   
        FROM TF_F_MAKECARDTASK T                                  
        WHERE  t. TASKID = P_TASKID;    
         IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
    EXCEPTION
       WHEN OTHERS THEN
            p_retCode := 'S094570110'; p_retMsg  := '��¼�ƿ�������ʷ��ʧ��' || SQLERRM;
            ROLLBACK; RETURN;                   
    END;
                                  
    --ɾ����ֵ���ʺű�����                              
    BEGIN                        
        DELETE TD_XFC_INITCARD T WHERE T.XFCARDNO BETWEEN V_STARTCARDNO AND V_ENDCARDNO  ;
         IF  SQL%ROWCOUNT = 0 THEN RAISE V_EX; END IF;                                                
          EXCEPTION                                                
          WHEN OTHERS THEN                                                
             p_retCode := 'S094570164'; p_retMsg  := 'ɾ����ֵ���ʺű�����ʧ��' || SQLERRM;                                                
             ROLLBACK; RETURN; 
     END;                          


    p_retCode := '0000000000';
    p_retMsg  := '�ɹ�';
    COMMIT; RETURN;        
END;
/
show errors
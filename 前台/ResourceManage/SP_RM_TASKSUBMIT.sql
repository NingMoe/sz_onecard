CREATE OR REPLACE PROCEDURE SP_RM_TASKSUBMIT
(
    P_CARDORDERID            CHAR ,
    P_SIGN                   VARCHAR,
    P_CURROPER              CHAR     ,
    P_CURRDEPT              CHAR     ,
    P_RETCODE           OUT CHAR     ,
    P_RETMSG            OUT VARCHAR2 
)
AS
    V_BEGINCARDNO     VARCHAR2(16); --��ʼ����
    V_ENDCARDNO       VARCHAR2(16); --��������
    V_CARDNUM         INT;          --����
    V_PRODUCER        CHAR(2);      --��Ƭ����
    V_APPVERSION      CHAR(2);      --���κ�
    V_EXPDATE         CHAR(8);      --��Ч����
    V_VALUECODE       CHAR(1);      --������
    v_seqNo           CHAR(16);     --��ˮ��
    V_TODAY           DATE         := SYSDATE    ;
    V_EX              EXCEPTION                  ;

BEGIN
        
      
    BEGIN
      --������ֵ
      SELECT
          CARDNUM        , BEGINCARDNO   , ENDCARDNO       ,VALUECODE     ,
          MANUTYPECODE   , APPVERNO      , VALIDENDDATE 
      INTO
          V_CARDNUM      , V_BEGINCARDNO , V_ENDCARDNO    ,V_VALUECODE   ,
          V_PRODUCER     , V_APPVERSION  , V_EXPDATE    
      FROM TF_F_CARDORDER
      WHERE CARDORDERID = P_CARDORDERID;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
              p_retCode := 'S094570156'; 
              p_retMsg  := 'δ�ҵ�������';
              ROLLBACK; RETURN;
    END;
     
      BEGIN
       --��ȡ��ˮ��
    SP_GetSeq(seq => v_seqNo);
        --��¼�ƿ������
        INSERT INTO TF_F_MAKECARDTASK(
            TASKID            , CARDORDERID    , TASKSTATE , STARTCARDNO    ,ENDCARDNO      ,
            CORPCODE          , YEAR           , BATCHNO   ,VALUECODE       ,VALIDTIME     ,
            CARDNUM           , OPERATOR       ,OPERDEPT   , DATETIME       ,SIGN
       )VALUES(
            v_seqNo           , P_CARDORDERID  , '0'          , SUBSTR(V_BEGINCARDNO,0,14)  ,SUBSTR(V_ENDCARDNO,0,14)   ,
            SUBSTR(V_PRODUCER,0,1) , SUBSTR(V_BEGINCARDNO,0,2)  ,V_APPVERSION               ,V_VALUECODE  ,V_EXPDATE,
            V_CARDNUM         , P_CURROPER     ,p_CURRDEPT    , V_TODAY     ,P_SIGN
            );
          
        IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
      EXCEPTION
        WHEN OTHERS THEN
              p_retCode := 'S094570157'; p_retMsg  := '��¼�ƿ������ʧ��' || SQLERRM;
              ROLLBACK; RETURN;              
       END;        
      --��¼�ƿ��������̨�ʱ�
    BEGIN
     SP_GetSeq(seq => v_seqNo);
      INSERT INTO TF_B_MAKECARDLOG(
          TASKID            ,CARDORDERID        ,TASKTYPECODE         ,CORPCODE          ,YEAR          ,                                              
          BATCHNO           ,VALUECODE          ,STARTCARDNO          ,ENDCARDNO         ,CARDNUM       ,                                              
          OPERATOR          ,OPERDEPT           ,DATETIME                                                        
   
      )VALUES(
          v_seqNo            , P_CARDORDERID    ,'0'                      ,SUBSTR(V_PRODUCER,0,1)     ,SUBSTR(V_BEGINCARDNO,0,2)  ,
          V_APPVERSION        , V_VALUECODE     ,SUBSTR(V_BEGINCARDNO,0,14) ,SUBSTR(V_ENDCARDNO,0,14)   , V_CARDNUM    ,                                              
          P_CURROPER         , P_CURRDEPT         ,V_TODAY               
      );
       
       IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
    EXCEPTION
       WHEN OTHERS THEN
            p_retCode := 'S094570109'; p_retMsg  := '��¼�ƿ��������̨�ʱ�ʧ��' || SQLERRM;
            ROLLBACK; RETURN;                   
    END;
       
 
     
     p_retCode := '0000000000'; p_retMsg  := '�ɹ�';
     COMMIT; RETURN;   
END;
/
show errors

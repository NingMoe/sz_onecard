create or replace procedure SP_RM_DOWNLOADFILELOG
(
    P_TASKID      char , --�ƿ�����ID
    p_currOper     char,           -- Current Operator
    p_currDept     char,           -- Curretn Operator's Department
    p_retCode      out char,       -- Return Code
    p_retMsg       out varchar2    -- Return Message
)
AS

    v_seqNo          CHAR(16);
    v_today         date:=sysdate;
    v_ex            EXCEPTION;

BEGIN

 SP_GetSeq(seq => v_seqNo); --������ˮ��  
       
        BEGIN
       --��¼�ƿ��ļ����ز���̨�ʱ�
        SP_GetSeq(seq => v_seqNo);
         INSERT INTO TF_B_DOWNLOADFILE(
         TRADEID      ,TASKID    ,OPERATOR   ,OPERATETIME      
         )VALUES(
            v_seqNo    ,P_TASKID ,P_CURROPER ,V_TODAY      
                      );
        IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
          EXCEPTION
          WHEN OTHERS THEN
            P_RETCODE := 'S001002901';
            P_RETMSG  := '��¼�ƿ��ļ����ز���̨�ʱ�ʧ��'||SQLERRM;
            ROLLBACK; RETURN;
       END;


   

    p_retCode := '0000000000'; p_retMsg  := '';
    COMMIT; RETURN;
END;
/
show errors
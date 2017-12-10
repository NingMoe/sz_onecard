CREATE OR REPLACE PROCEDURE SP_PS_PreDeExam_Pass
(
    P_ID              CHAR     , --�����ˮ��
    P_TRADETYPECODE   CHAR     , --ҵ�����ͱ���
    P_DBALUNITNO      CHAR     , --������㵥Ԫ����
    P_MONEY           INT      , --�������
    P_CURROPER        CHAR     ,
    P_CURRDEPT        CHAR     ,
    P_RETCODE     OUT CHAR     ,
    P_RETMSG      OUT VARCHAR2
)
AS
    V_TRADETYPECODE   VARCHAR2(2)  := P_TRADETYPECODE ;
    V_SEQ             VARCHAR2(16)               ;
    V_TODAY           DATE         := SYSDATE    ;
    V_EX              EXCEPTION                  ;
    V_PREPAY          INT                        ;
    V_USABLEVALUE     INT                        ;
    V_DEPOSIT       int;
    v_cardnum       int;
    V_CARDPRICE     int;
BEGIN
    IF V_TRADETYPECODE= '01' THEN --����汣֤��
    BEGIN
      SP_GETSEQ(SEQ => V_SEQ); --��ȡҵ����ˮ��
      --��¼������㵥Ԫ�ʽ����̨�˱�
      INSERT INTO TF_B_DEPTACCTRADE(
          TRADEID     , TRADETYPECODE    , DBALUNITNO      , CURRENTMONEY    ,
          PREMONEY    , NEXTMONEY        , OPERATESTAFFNO  , OPERATEDEPARTID ,
          OPERATETIME , REMARK
     )SELECT
          V_SEQ       , '01'             , b.DBALUNITNO    , b.CURRENTMONEY  ,
          a.DEPOSIT   , b.CURRENTMONEY+a.DEPOSIT , b.OPERATESTAFFNO  , b.OPERATEDEPARTID  , 
          V_TODAY   , b.REMARK
      FROM TF_F_DEPTBAL_DEPOSIT a, TF_B_DEPTACC_EXAM b
      WHERE a.DBALUNITNO = b.DBALUNITNO
      AND   a.ACCSTATECODE = '01'
      AND   b.ID = P_ID
      AND   b.STATECODE = '1';
    EXCEPTION WHEN OTHERS THEN
      P_RETCODE := 'S008905001';
      P_RETMSG  := '��¼������㵥Ԫ�ʽ����̨�˱�ʧ��'||SQLERRM;
      ROLLBACK;RETURN;
    END;
    BEGIN
      --����������㵥Ԫ��֤���˻���
      UPDATE TF_F_DEPTBAL_DEPOSIT
      SET    DEPOSIT       = DEPOSIT+P_MONEY     ,
             USABLEVALUE   = USABLEVALUE+P_MONEY ,
             UPDATESTAFFNO = P_CURROPER          ,
             UPDATETIME    = V_TODAY
      WHERE  DBALUNITNO    = P_DBALUNITNO
      AND    ACCSTATECODE  = '01';  
    
      IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
    EXCEPTION WHEN OTHERS THEN
      P_RETCODE := 'S008905005';
      P_RETMSG  := '����������㵥ԪԤ�����˻���ʧ��'||SQLERRM;
      ROLLBACK;RETURN;    
    END;
    BEGIN
      --����Ԥ���֤��ҵ��̨����˱�
      UPDATE TF_B_DEPTACC_EXAM
      SET    TRADEID       = V_SEQ      ,
             EXAMSTAFFNO   = P_CURROPER ,
             EXAMDEPARTNO  = P_CURRDEPT ,
             EXAMKTIME     = V_TODAY    ,
             STATECODE     = '2'
      WHERE  ID            = P_ID
      AND    STATECODE     = '1';  
    
      IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
    EXCEPTION WHEN OTHERS THEN
      P_RETCODE := 'S008905012';
      P_RETMSG  := '����Ԥ���֤��ҵ��̨����˱�ʧ��'||SQLERRM;
      ROLLBACK;RETURN;    
    END;
    END IF;
    IF V_TRADETYPECODE= '02' THEN --����֧����֤��
      --�����Ƿ��֧�����
      --��ȡ���п�
      select count(*) into v_cardnum from TL_R_ICUSER a
      where exists (select * from  TD_DEPTBAL_RELATION b where a.assigneddepartid=b.departno and b.dbalunitno = P_DBALUNITNO)
      and a.RESSTATECODE IN('01','05');
      --��ȡ�û�����ֵ
      SELECT TAGVALUE INTO V_CARDPRICE FROM TD_M_TAG WHERE TAGCODE='USERCARD_MONEY'; 
      --��ȡ��֤�����
      SELECT DEPOSIT INTO V_DEPOSIT FROM TF_F_DEPTBAL_DEPOSIT WHERE ACCSTATECODE='01' AND DBALUNITNO = P_DBALUNITNO; 
      --������쿨��ֵ���
      V_USABLEVALUE := V_DEPOSIT - v_cardnum*V_CARDPRICE;
      --���֧��������Ԥ�����������ʾ����
      IF P_MONEY > V_USABLEVALUE THEN
          P_RETCODE := 'S008905004';
          P_RETMSG  := '֧�����ܴ��ڿ��쿨��ֵ���';
          ROLLBACK;RETURN; 
      ELSE--���֧��������Ԥ���������ִ��		    	
      BEGIN
        SP_GETSEQ(SEQ => V_SEQ); --��ȡҵ����ˮ��
        --��¼������㵥Ԫ�ʽ����̨�˱�
        INSERT INTO TF_B_DEPTACCTRADE(
            TRADEID     , TRADETYPECODE    , DBALUNITNO      , CURRENTMONEY    ,
            PREMONEY    , NEXTMONEY        , OPERATESTAFFNO  , OPERATEDEPARTID ,
            OPERATETIME , REMARK
       )SELECT
            V_SEQ       , '02'             , b.DBALUNITNO    , -b.CURRENTMONEY  ,
            a.DEPOSIT   , a.DEPOSIT-b.CURRENTMONEY , b.OPERATESTAFFNO  , b.OPERATEDEPARTID  , 
            V_TODAY   , b.REMARK
        FROM TF_F_DEPTBAL_DEPOSIT a, TF_B_DEPTACC_EXAM b
        WHERE a.DBALUNITNO = b.DBALUNITNO
        AND   a.ACCSTATECODE = '01'
        AND   b.ID = P_ID
        AND   b.STATECODE = '1';
      EXCEPTION WHEN OTHERS THEN
        P_RETCODE := 'S008905001';
        P_RETMSG  := '��¼������㵥Ԫ�ʽ����̨�˱�ʧ��'||SQLERRM;
        ROLLBACK;RETURN;
      END;
      BEGIN
        --����������㵥Ԫ��֤���˻���
        UPDATE TF_F_DEPTBAL_DEPOSIT
        SET    DEPOSIT       = DEPOSIT-P_MONEY     ,
               USABLEVALUE   = USABLEVALUE-P_MONEY ,
               UPDATESTAFFNO = P_CURROPER          ,
               UPDATETIME    = V_TODAY
        WHERE  DBALUNITNO    = P_DBALUNITNO
        AND    ACCSTATECODE  = '01';  
    
        IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
      EXCEPTION WHEN OTHERS THEN
        P_RETCODE := 'S008905005';
        P_RETMSG  := '����������㵥ԪԤ�����˻���ʧ��'||SQLERRM;
        ROLLBACK;RETURN;    
      END;
      BEGIN
        --����Ԥ���֤��ҵ��̨����˱�
        UPDATE TF_B_DEPTACC_EXAM
        SET    TRADEID       = V_SEQ      ,
               EXAMSTAFFNO   = P_CURROPER ,
               EXAMDEPARTNO  = P_CURRDEPT ,
               EXAMKTIME     = V_TODAY    ,
               STATECODE     = '2'
        WHERE  ID            = P_ID
        AND    STATECODE     = '1';  
    
        IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
      EXCEPTION WHEN OTHERS THEN
        P_RETCODE := 'S008905012';
        P_RETMSG  := '����Ԥ���֤��ҵ��̨����˱�ʧ��'||SQLERRM;
        ROLLBACK;RETURN;    
      END;
      END IF;
    END IF;    
    IF V_TRADETYPECODE= '11' THEN --�����Ԥ����
    	BEGIN
      SP_GETSEQ(SEQ => V_SEQ); --��ȡҵ����ˮ��
      --��¼������㵥Ԫ�ʽ����̨�˱�
      INSERT INTO TF_B_DEPTACCTRADE(
          TRADEID     , TRADETYPECODE    , DBALUNITNO      , CURRENTMONEY    ,
          PREMONEY    , NEXTMONEY        , OPERATESTAFFNO  , OPERATEDEPARTID ,
          OPERATETIME , REMARK , FINDATE, FINTRADENO,FINBANK,USEWAY
     )SELECT
          V_SEQ       , '11'             , b.DBALUNITNO    , b.CURRENTMONEY  ,
          a.PREPAY   , b.CURRENTMONEY+a.PREPAY , b.OPERATESTAFFNO  , b.OPERATEDEPARTID  , 
          V_TODAY , b.REMARK , b.FINDATE, b.FINTRADENO,b.FINBANK,b.USEWAY
      FROM TF_F_DEPTBAL_PREPAY a, TF_B_DEPTACC_EXAM b
      WHERE a.DBALUNITNO = b.DBALUNITNO
      AND   a.ACCSTATECODE = '01'
      AND   b.ID = P_ID
      AND   b.STATECODE = '1';
    EXCEPTION WHEN OTHERS THEN
      P_RETCODE := 'S008905001';
      P_RETMSG  := '��¼������㵥Ԫ�ʽ����̨�˱�ʧ��'||SQLERRM;
      ROLLBACK;RETURN;
    END;
    BEGIN
      --����������㵥ԪԤ�����˻���
      UPDATE TF_F_DEPTBAL_PREPAY
      SET    PREPAY       = PREPAY+P_MONEY     ,             
             UPDATESTAFFNO = P_CURROPER          ,
             UPDATETIME    = V_TODAY
      WHERE  DBALUNITNO    = P_DBALUNITNO
      AND    ACCSTATECODE  = '01';  
    
      IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
    EXCEPTION WHEN OTHERS THEN
      P_RETCODE := 'S008905005';
      P_RETMSG  := '����������㵥ԪԤ�����˻���ʧ��'||SQLERRM;
      ROLLBACK;RETURN;    
    END;
    BEGIN
      --����Ԥ���֤��ҵ��̨����˱�
      UPDATE TF_B_DEPTACC_EXAM
      SET    TRADEID       = V_SEQ      ,
             EXAMSTAFFNO   = P_CURROPER ,
             EXAMDEPARTNO  = P_CURRDEPT ,
             EXAMKTIME     = V_TODAY    ,
             STATECODE     = '2'
      WHERE  ID            = P_ID
      AND    STATECODE     = '1';  
    
      IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
    EXCEPTION WHEN OTHERS THEN
      P_RETCODE := 'S008905012';
      P_RETMSG  := '����Ԥ���֤��ҵ��̨����˱�ʧ��'||SQLERRM;
      ROLLBACK;RETURN;    
    END;
    END IF;
    IF V_TRADETYPECODE= '12' THEN --����֧��Ԥ����
    	SELECT PREPAY INTO V_PREPAY FROM TF_F_DEPTBAL_PREPAY WHERE DBALUNITNO = P_DBALUNITNO;
      --���֧��������Ԥ�����������ʾ����
      IF P_MONEY > V_PREPAY THEN
          P_RETCODE := 'S008905002';
          P_RETMSG  := '֧�����ܴ���Ԥ�������';
          ROLLBACK;RETURN; 
      ELSE--���֧��������Ԥ���������ִ��		
    	BEGIN
        SP_GETSEQ(SEQ => V_SEQ); --��ȡҵ����ˮ��
        --��¼������㵥Ԫ�ʽ����̨�˱�
        INSERT INTO TF_B_DEPTACCTRADE(
            TRADEID     , TRADETYPECODE    , DBALUNITNO      , CURRENTMONEY    ,
            PREMONEY    , NEXTMONEY        , OPERATESTAFFNO  , OPERATEDEPARTID ,
            OPERATETIME , REMARK, FINDATE, FINTRADENO,FINBANK,USEWAY
       )SELECT
            V_SEQ       , '12'             , b.DBALUNITNO    , -b.CURRENTMONEY  ,
            a.PREPAY   , a.PREPAY-b.CURRENTMONEY , b.OPERATESTAFFNO  , b.OPERATEDEPARTID  , 
            V_TODAY   , b.REMARK, b.FINDATE, b.FINTRADENO,b.FINBANK,b.USEWAY
        FROM TF_F_DEPTBAL_PREPAY a, TF_B_DEPTACC_EXAM b
        WHERE a.DBALUNITNO = b.DBALUNITNO
        AND   a.ACCSTATECODE = '01'
        AND   b.ID = P_ID
        AND   b.STATECODE = '1';
      EXCEPTION WHEN OTHERS THEN
        P_RETCODE := 'S008905001';
        P_RETMSG  := '��¼������㵥Ԫ�ʽ����̨�˱�ʧ��'||SQLERRM;
        ROLLBACK;RETURN;
      END;
      BEGIN
        --����������㵥ԪԤ�����˻���
        UPDATE TF_F_DEPTBAL_PREPAY
        SET    PREPAY        = PREPAY-P_MONEY     ,
               UPDATESTAFFNO = P_CURROPER          ,
               UPDATETIME    = V_TODAY
        WHERE  DBALUNITNO    = P_DBALUNITNO
        AND    ACCSTATECODE  = '01';  
    
        IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
      EXCEPTION WHEN OTHERS THEN
        P_RETCODE := 'S008905005';
        P_RETMSG  := '����������㵥ԪԤ�����˻���ʧ��'||SQLERRM;
        ROLLBACK;RETURN;    
      END;
      BEGIN
        --����Ԥ���֤��ҵ��̨����˱�
        UPDATE TF_B_DEPTACC_EXAM
        SET    TRADEID       = V_SEQ      ,
               EXAMSTAFFNO   = P_CURROPER ,
               EXAMDEPARTNO  = P_CURRDEPT ,
               EXAMKTIME     = V_TODAY    ,
               STATECODE     = '2'
        WHERE  ID            = P_ID
        AND    STATECODE     = '1';  
    
        IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
      EXCEPTION WHEN OTHERS THEN
        P_RETCODE := 'S008905012';
        P_RETMSG  := '����Ԥ���֤��ҵ��̨����˱�ʧ��'||SQLERRM;
        ROLLBACK;RETURN;    
      END;
      END IF;
    END IF;
    p_retCode := '0000000000'; p_retMsg  := '�ɹ�';
    commit; return;	
END;    

/
show errors
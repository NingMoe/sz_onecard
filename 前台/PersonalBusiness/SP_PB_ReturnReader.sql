CREATE OR REPLACE PROCEDURE SP_PB_RETURNREADER
(
    P_SERIALNUMBER         VARCHAR2,  --���������к�
    P_READERNUMBER         INT     ,  --����������
    p_MONEY                INT     ,  --�˻����
    p_TRADEID          out char , --Return trade id
    p_currOper             char    ,
    p_currDept             char    ,
    p_retCode          out char    ,  -- Return Code
    p_retMsg           out varchar2   -- Return Message  
)
AS
    v_seqNo             CHAR(16)       ;
    V_EX                EXCEPTION      ;
    V_TODAY             DATE := SYSDATE;
    V_ID                CHAR(18);
/*
--  �������˻�
--  ���α�д
--  ʯ��
--  2013-04-05
*/
BEGIN 
    --��¼��������ʷ��
    BEGIN
        INSERT INTO TH_R_READER(
            SERIALNUMBER    , READERSTATE      , MANUCODE , MONEY       , 
            INSTIME         , INSTAFFNO        , OUTTIME  , OUTSTAFFNO  ,
            ASSIGNEDSTAFFNO , ASSIGNEDDEPARTID , SALETIME , SALESTAFFNO ,
            CHANGETIME      , CHANGESTAFFNO    , RSRV1
       )SELECT
            SERIALNUMBER    , READERSTATE      , MANUCODE , MONEY       , 
            INSTIME         , INSTAFFNO        , OUTTIME  , OUTSTAFFNO  ,
            ASSIGNEDSTAFFNO , ASSIGNEDDEPARTID , SALETIME , SALESTAFFNO ,
            CHANGETIME      , CHANGESTAFFNO    , RSRV1
        FROM TL_R_READER
        WHERE SERIALNUMBER = P_SERIALNUMBER;
        
        IF SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S094570281'; p_retMsg  := '��¼��������ʷ��ʧ��,' || SQLERRM;
            ROLLBACK; RETURN;            
    END;
    
    --���¶���������
    BEGIN
        UPDATE TL_R_READER
        SET    READERSTATE      = '4'        , --�˻�����
               ASSIGNEDSTAFFNO  = p_currOper ,
               ASSIGNEDDEPARTID = p_currDept ,
               SALETIME      = '',
               SALESTAFFNO   = '',
               CHANGETIME    = '',
               CHANGESTAFFNO = '',
               RSRV1 = ''
        WHERE  SERIALNUMBER = P_SERIALNUMBER
        AND    READERSTATE = '2' ;
        
        IF SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S094570282'; p_retMsg  := '���¶���������ʧ��,' || SQLERRM;
            ROLLBACK; RETURN;
    END;
    
    --��¼�������ͻ�������ʷ��
    BEGIN
        INSERT INTO TH_F_READERCUSTREC(
            SERIALNUMBER  , CUSTNAME  , CUSTSEX       , CUSTBIRTH   ,
            PAPERTYPECODE , PAPERNO   , CUSTADDR      , CUSTPOST    ,
            CUSTPHONE     , CUSTEMAIL , UPDATESTAFFNO , UPDATETIME  ,
            REMARK
       )SELECT 
            SERIALNUMBER  , CUSTNAME  , CUSTSEX       , CUSTBIRTH   ,
            PAPERTYPECODE , PAPERNO   , CUSTADDR      , CUSTPOST    ,
            CUSTPHONE     , CUSTEMAIL , UPDATESTAFFNO , UPDATETIME  ,
            REMARK
        FROM TF_F_READERCUSTREC
        WHERE SERIALNUMBER = P_SERIALNUMBER;
        
        IF SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S094570283'; p_retMsg  := '��¼�������ͻ�������ʷ��ʧ��,' || SQLERRM;
            ROLLBACK; RETURN;        
    END;
    --ɾ���������ͻ����ϱ�
    BEGIN
        DELETE TF_F_READERCUSTREC WHERE  SERIALNUMBER = P_SERIALNUMBER; 

        IF SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S094570284'; p_retMsg  := 'ɾ���������ͻ����ϱ�ʧ��' || SQLERRM;
            ROLLBACK; RETURN;        
    END;

    --��ȡ��ˮ��
    SP_GetSeq(seq => v_seqNo); 
    p_TRADEID := v_seqNo;
	
    --��¼����������̨�˱�,06�˻�
    BEGIN
        INSERT INTO TF_B_READER(
            TRADEID     , OPERATETYPECODE , BEGINSERIALNUMBER , ENDSERIALNUMBER,
            MONEY       , READERNUMBER    , OPERATETIME       , OPERATESTAFFNO     
       )VALUES(
            v_seqNo     , '1C'            , P_SERIALNUMBER    , P_SERIALNUMBER ,
            -p_MONEY    , P_READERNUMBER  , V_TODAY           , p_currOper     
            );
    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S094570285'; p_retMsg  := '��¼����������̨�˱�ʧ��' || SQLERRM;
            ROLLBACK; RETURN;            
    END;

    --��¼����������ͬ����
    BEGIN
        INSERT INTO TF_B_READER_SYNC(
            TRADEID , OPERATETYPECODE , SERIALNUMBER   , SYNCFLAG , OPERATETIME
       )VALUES(
            v_seqNo , '06'            , P_SERIALNUMBER , '0'      , V_TODAY);
    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S094570286'; p_retMsg  := '��¼����������̨�˱�ʧ��' || SQLERRM;
            ROLLBACK; RETURN;    
    END;
    
    v_ID := TO_CHAR(SYSDATE, 'MMDDHHMMSS') || SUBSTR(P_SERIALNUMBER, -8);
    --��¼�ֽ�̨��
    BEGIN
        INSERT INTO TF_B_TRADEFEE(
            ID         , TRADEID        , TRADETYPECODE   , CARDNO          ,
            OTHERFEE   , OPERATESTAFFNO , OPERATEDEPARTID , OPERATETIME 
       )VALUES(
            v_ID        , v_seqNo        , '1C'            , P_SERIALNUMBER ,
            -p_MONEY    , p_currOper     , p_currDept      , V_TODAY        
            );

    EXCEPTION
        WHEN OTHERS THEN    
            p_retCode := 'S094570287';
            p_retMsg  := '��¼�ֽ�̨�˱�ʧ��' || SQLERRM;
            ROLLBACK; RETURN;
    END;     
                         

    
    --����Ӫҵ���ֿ�Ԥ����
    BEGIN
      SP_PB_DEPTBALFEE(v_seqNo, '3' ,--1Ԥ����,2��֤��,3Ԥ����ͱ�֤��
                       -p_MONEY,V_TODAY,p_currOper,p_currDept,p_retCode,p_retMsg);
    
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
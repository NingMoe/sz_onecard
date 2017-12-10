CREATE OR REPLACE PROCEDURE SP_PB_SALEREADER_COMMIT
(
    p_FUNCCODE             VARCHAR2,  --���ܱ���
    P_SERIALNUMBER         VARCHAR2,  --���������к�
    P_ENDSERIALNUMBER      VARCHAR2,  --�������������к�
    P_READERNUMBER         INT     ,  --����������
    p_CUSTNAME               VARCHAR2,  --�ͻ�����
    p_CUSTSEX               VARCHAR2,  --�ͻ��Ա�
    p_CUSTBIRTH               VARCHAR2,  --��������
    p_PAPERTYPECODE           VARCHAR2,  --֤������
    p_PAPERNO              VARCHAR2,  --֤������
    p_CUSTADDR               VARCHAR2,  --��ϵ��ַ
    p_CUSTPOST               VARCHAR2,  --��������
    p_CUSTPHONE               VARCHAR2,  --��ϵ�绰
    p_CUSTEMAIL            VARCHAR2,  --�����ʼ�
    p_REMARK               VARCHAR2,  --��ע
    p_MONEY                INT     ,  --���۽��
    p_TRADEID          out char , --Return trade id
    p_currOper               char    ,
    p_currDept               char    ,
    p_retCode          out char    ,  -- Return Code
    p_retMsg           out varchar2   -- Return Message  
)
AS
    V_EX              EXCEPTION;
/*
--  �����������ύ�洢����
--  ���α�д
--  ʯ��
--  2013-05-26
*/    
BEGIN
    BEGIN
        SP_PB_SALEREADER(
            P_FUNCCODE         => P_FUNCCODE         ,
            P_SERIALNUMBER     => P_SERIALNUMBER     ,
            P_ENDSERIALNUMBER  => P_ENDSERIALNUMBER  ,
            P_READERNUMBER     => P_READERNUMBER     ,
            p_CUSTNAME         => p_CUSTNAME         ,
            p_CUSTSEX          => p_CUSTSEX          ,
            p_CUSTBIRTH        => p_CUSTBIRTH        ,
            p_PAPERTYPECODE    => p_PAPERTYPECODE    ,
            p_PAPERNO          => p_PAPERNO          ,
            p_CUSTADDR         => p_CUSTADDR         ,
            p_CUSTPOST         => p_CUSTPOST         ,
            p_CUSTPHONE        => p_CUSTPHONE        ,
            p_CUSTEMAIL        => p_CUSTEMAIL        ,
            p_REMARK           => p_REMARK           ,
            p_MONEY            => p_MONEY            ,
            p_TRADEID          => p_TRADEID          ,
            P_CURROPER         => P_CURROPER         ,
            P_CURRDEPT         => P_CURRDEPT         ,
            P_RETCODE          => P_RETCODE          ,
            P_RETMSG           => P_RETMSG
        );
        IF p_retCode != '0000000000' THEN RAISE v_ex; END IF;
    EXCEPTION WHEN OTHERS THEN
        ROLLBACK; RETURN;
    END;

    p_retCode := '0000000000';
    p_retMsg  := '';
    COMMIT; RETURN;    
END;

/
show errors
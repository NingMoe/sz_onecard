create or replace procedure SP_GC_SETORDERSTATE
(
    P_FUNCCODE     VARCHAR2,  --���ܱ���
    p_ORDERNO      char,      --������
    p_currOper     char,           -- Current Operator
    p_currDept     char,           -- Curretn Operator's Department
    p_retCode      out char,       -- Return Code
    p_retMsg       out varchar2    -- Return Message
)
AS
    V_COUNT         INT;
    V_TRANSACTOR    CHAR(6);
    V_ORDERSTATE    CHAR(2);
    V_ORDERTYPE     CHAR(1);
    v_seqNo         CHAR(16);
    v_today         date := sysdate;
    v_ex            EXCEPTION;
    V_ID            CHAR(16);
BEGIN
    IF P_FUNCCODE = 'SETMODIFY' THEN
        SELECT TRANSACTOR,ORDERSTATE INTO V_TRANSACTOR,V_ORDERSTATE FROM TF_F_ORDERFORM WHERE ORDERNO = p_ORDERNO;
        
        IF V_ORDERSTATE <> '01' THEN
            p_retCode := 'S094570302';
            p_retMsg := 'ֻ��¼������״̬�Ķ����ſ����ڸ�ҳ����Ϊ�޸�״̬' ;
            RETURN;
        END IF;
        
        IF V_TRANSACTOR <> p_currOper THEN
            p_retCode := 'S094570303';
            p_retMsg := '�Ǿ����˱��˲������޸Ķ���' ;
            RETURN;
        END IF;                
        
        --���¶�����
        BEGIN
            UPDATE TF_F_ORDERFORM
            SET ORDERSTATE = '00' --�޸���
            WHERE ORDERNO = p_ORDERNO
            AND   ORDERSTATE = '01' --¼������
            AND   TRANSACTOR = p_currOper;
            
            IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
        EXCEPTION
            WHEN OTHERS THEN
            P_RETCODE := 'S094570304';
            P_RETMSG  := '���¶�����ʧ��'||SQLERRM;      
            ROLLBACK; RETURN;             
        END;
        
        SP_GetSeq(seq => v_seqNo); --������ˮ��
        --��¼����̨��  
        BEGIN
            INSERT INTO TF_F_ORDERTRADE (
                TRADEID         , ORDERNO           , TRADECODE       , MONEY             , GROUPNAME      , NAME   ,
                CASHGIFTMONEY   , CHARGECARDMONEY   , SZTCARDMONEY    , CUSTOMERACCMONEY  , GETDEPARTMENT  ,
                GETDATE         , REMARK            , OPERATEDEPARTNO , OPERATESTAFFNO    , OPERATETIME    ,
                READERMONEY     , GARDENCARDMONEY   , RELAXCARDMONEY
           )SELECT
                v_seqNo         , A.ORDERNO         , '02'            , A.TOTALMONEY       , A.GROUPNAME    , A.NAME ,
                A.CASHGIFTMONEY , A.CHARGECARDMONEY , A.SZTCARDMONEY  , A.CUSTOMERACCMONEY , A.GETDEPARTMENT,
                A.GETDATE       , A.REMARK          , p_currDept      , p_currOper         , v_today        ,
                A.READERMONEY   , A.GARDENCARDMONEY , A.RELAXCARDMONEY
            FROM TF_F_ORDERFORM A
            WHERE ORDERNO = p_ORDERNO;
        exception when others then
            p_retCode := 'S094570301';
            p_retMsg :=  '���붩��̨�˱�ʧ��'|| SQLERRM ;
            rollback; return;
        END;
    END IF;
    
    IF P_FUNCCODE = 'SETCANCEL' THEN
        SELECT TRANSACTOR,ORDERSTATE,ORDERTYPE INTO V_TRANSACTOR,V_ORDERSTATE,V_ORDERTYPE FROM TF_F_ORDERFORM WHERE ORDERNO = p_ORDERNO;
        
        IF V_ORDERSTATE <> '00'  THEN
            p_retCode := 'S094570305';
            p_retMsg := 'ֻ���޸���״̬�Ķ����ſ�������' ;
            RETURN;
        END IF;
        
        IF V_TRANSACTOR <> p_currOper THEN
            p_retCode := 'S094570306';
            p_retMsg := '�Ǿ����˱��˲��������϶���' ;
            RETURN;
        END IF;
        
        IF V_ORDERTYPE = '1' THEN --��λ����
            SELECT ID INTO V_ID FROM TF_F_COMBUYCARDREG WHERE REMARK =  p_ORDERNO;
            BEGIN
                SP_PB_ComBuyCardReg(
                    P_FUNCCODE         => 'DELETE'           ,
                    P_ID               => V_ID               ,
                    P_COMPANYNAME      => ''                 ,
                    P_COMPANYPAPERTYPE => ''                 ,
                    P_COMPANYPAPERNO   => ''                 ,
                    P_COMPANYMANAGERNO => ''                 ,
                    P_COMPANYENDTIME   => ''                 ,
                    P_NAME             => ''                 ,
                    P_PAPERTYPE        => ''                 ,
                    P_PAPERNO          => ''                 ,
                    P_PHONENO          => ''                 ,
                    P_ADDRESS          => ''                 ,
                    P_EMAIL            => ''                 ,
                    P_OUTBANK          => ''                 ,
                    P_OUTACCT          => ''                 ,
                    P_STARTCARDNO      => ''                 ,
                    P_ENDCARDNO        => ''                 ,
                    P_BUYCARDDATE      => ''                 ,
                    P_BUYCARDNUM       => ''                 ,
                    P_BUYCARDMONEY     => ''                 ,
                    P_CHARGEMONEY      => ''                 ,
                    P_REMARK           => ''                 ,
                    P_CURROPER         => P_CURROPER         ,
                    P_CURRDEPT         => P_CURRDEPT         ,
                    P_RETCODE          => P_RETCODE          ,
                    P_RETMSG           => P_RETMSG
                );
                IF p_retCode != '0000000000' THEN RAISE v_ex; END IF;
            EXCEPTION WHEN OTHERS THEN
                ROLLBACK; RETURN;
            END;
        ELSIF V_ORDERTYPE = '2' THEN --���˶���
            SELECT ID INTO V_ID FROM TF_F_PERBUYCARDREG WHERE REMARK =  p_ORDERNO;
            BEGIN
                SP_PB_PerBuyCardReg(
                    P_FUNCCODE              => 'DELETE'       ,
                    P_ID                    => V_ID           ,
                    P_NAME                  => ''             ,
                    P_BIRTHDAY              => ''             ,
                    P_PAPERTYPE             => ''             ,
                    P_PAPERNO               => ''             ,
                    P_SEX                   => ''             ,
                    P_PHONENO               => ''             ,
                    P_ADDRESS               => ''             ,
                    P_EMAIL                 => ''             ,
                    P_STARTCARDNO           => ''             ,
                    P_ENDCARDNO             => ''             ,
                    P_BUYCARDDATE           => ''             ,
                    P_BUYCARDNUM            => ''             ,
                    P_BUYCARDMONEY          => ''             ,
                    P_CHARGEMONEY           => ''             ,
                    P_REMARK                => ''             ,
                    P_CURROPER              => P_CURROPER     ,
                    P_CURRDEPT              => P_CURRDEPT     ,
                    P_RETCODE               => P_RETCODE      ,
                    P_RETMSG                => P_RETMSG
                    );
                IF p_retCode != '0000000000' THEN RAISE v_ex; END IF;
            EXCEPTION WHEN OTHERS THEN
                ROLLBACK; RETURN;
            END;        
        END IF;
        
        --���¶�����
        BEGIN
            UPDATE TF_F_ORDERFORM
            SET   ORDERSTATE = '09' ,--����
                  USETAG     = '0' --��Ч
            WHERE ORDERNO = p_ORDERNO
            AND   ORDERSTATE = '00' --�޸���
            AND   TRANSACTOR = p_currOper;
            
            IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
        EXCEPTION
            WHEN OTHERS THEN
            P_RETCODE := 'S094570307';
            P_RETMSG  := '���¶�����ʧ��'||SQLERRM;      
            ROLLBACK; RETURN;             
        END;
        
        SP_GetSeq(seq => v_seqNo); --������ˮ��
        --��¼����̨��  
        BEGIN
            INSERT INTO TF_F_ORDERTRADE (
                TRADEID         , ORDERNO           , TRADECODE       , MONEY             , GROUPNAME      , NAME   ,
                CASHGIFTMONEY   , CHARGECARDMONEY   , SZTCARDMONEY    , CUSTOMERACCMONEY  , GETDEPARTMENT  ,
                GETDATE         , REMARK            , OPERATEDEPARTNO , OPERATESTAFFNO    , OPERATETIME    ,
                READERMONEY     , GARDENCARDMONEY   , RELAXCARDMONEY
           )SELECT
                v_seqNo         , A.ORDERNO         , '03'            , A.TOTALMONEY       , A.GROUPNAME    , A.NAME ,
                A.CASHGIFTMONEY , A.CHARGECARDMONEY , A.SZTCARDMONEY  , A.CUSTOMERACCMONEY , A.GETDEPARTMENT,
                A.GETDATE       , A.REMARK          , p_currDept      , p_currOper         , v_today        ,
                A.READERMONEY   , A.GARDENCARDMONEY , A.RELAXCARDMONEY
            FROM TF_F_ORDERFORM A
            WHERE ORDERNO = p_ORDERNO;
        exception when others then
            p_retCode := 'S094570301';
            p_retMsg :=  '���붩��̨�˱�ʧ��'|| SQLERRM ;
            rollback; return;
        END;
    END IF;
    
    IF P_FUNCCODE = 'SETCOMPLETEMAKE' THEN
        BEGIN
            UPDATE TF_F_ORDERFORM
            SET    ORDERSTATE = '05' ,
                   UPDATEDEPARTNO = p_currDept,
                   UPDATESTAFFNO = p_currOper ,
                   UPDATETIME = v_today
            WHERE  ORDERNO = p_ORDERNO
            AND    ORDERSTATE IN ('03','04');
            IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
        EXCEPTION
            WHEN OTHERS THEN
            P_RETCODE := 'S094570338';
            P_RETMSG  := '���¶�����ʧ��,'||SQLERRM;      
            ROLLBACK; RETURN;          
        END;
    END IF;
    ---��������쿨������
    IF P_FUNCCODE = 'SETCOMPLETERELATION' THEN
        BEGIN
            UPDATE TF_F_ORDERFORM
            SET    ORDERSTATE = '10' ,--��������쿨������
                   UPDATEDEPARTNO = p_currDept,
                   UPDATESTAFFNO = p_currOper ,
                   UPDATETIME = v_today
            WHERE  ORDERNO = p_ORDERNO
            AND    ORDERSTATE IN ('07');
            IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
        EXCEPTION
            WHEN OTHERS THEN
            P_RETCODE := 'S094570338';
            P_RETMSG  := '���¶�����ʧ��,'||SQLERRM;      
            ROLLBACK; RETURN;          
        END;
    END IF;
    p_retCode := '0000000000'; p_retMsg  := '';
    COMMIT; RETURN;    
END;
/
show errors;
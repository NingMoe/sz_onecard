create or replace procedure SP_GC_ORDERINPUTSUBMIT
(
    P_FUNCCODE     VARCHAR2 , --���ܱ���
    p_ORDERNO      char     , --������
    P_ORDERTYPE    CHAR     , --��������
    P_INITIATOR    CHAR     , --�������� 1 CRM ,2 ҵ��ϵͳ
    P_SESSIONID    varchar2 ,
    P_GROUPNAME    varchar2 , --��ҵ����
    P_COMPANYPAPERTYPE CHAR     , --��λ֤������
    P_COMPANYPAPERNO   VARCHAR2 , --��λ֤������
    P_COMPANYMANAGERNO VARCHAR2 , --����֤������
    P_COMPANYENDTIME   VARCHAR2 , --֤����Ч��
    P_NAME         varchar2 , --��ϵ������
    P_PHONE        varchar2 , --��ϵ�˵绰
    P_IDCARDNO     varchar2 , --��ϵ��֤������
    P_BIRTHDAY     VARCHAR2 , --��������
    P_PAPERTYPE    CHAR     , --֤������
    P_SEX          CHAR     , --�Ա�
    P_ADDRESS      VARCHAR2 , --��ϵ��ַ
    P_EMAIL        VARCHAR2 , --EMAIL
    P_OUTBANK      VARCHAR2 , --ת������
    P_OUTACCT      VARCHAR2 , --ת���˻�
    P_TOTALMONEY   integer,   --�ܽ��
    P_TRANSACTOR   char,      --������
    P_REMARK       varchar2,  --��ע

    P_CASHGIFTMONEY     integer, --����ܽ��
    P_CHARGECARDMONEY   integer, --��ֵ���ܽ��
    P_SZTCARDMONEY      integer, --����B���ܽ��
    P_LVYOUMONEY        integer, --���ο��ܽ��
    P_CUSTOMERACCMONEY  integer, --ר���˻��ܳ�ֵ���
    P_INVOICETOTALMONEY integer, --��Ʊ�ܽ��
    P_GETDEPARTMENT     char,    --�쿨����
    P_GETDATE           char,    --�쿨ʱ��
    
    P_READERMONEY       integer, --�������ܽ��
    P_GARDENCARDMONEY   integer, --԰���꿨�ܽ��
    P_RELAXCARDMONEY    integer, --�����꿨�ܽ��
    P_READERNUM         integer, --����������
    P_READERPRICE       integer, --����������
    P_GARDENCARDNUM     integer, --԰���꿨����
    P_GARDENCARDPRICE   integer, --԰���꿨����
    P_RELAXCARDNUM      integer, --�����꿨����
    P_RELAXCARDPRICE    integer, --�����꿨����
    P_MANAGERDEPT       CHAR, --�ͻ�������
    P_MANAGER           CHAR, --�ͻ�����
    P_ORDERDATE    char,
    P_ORDERSEQ     char,
    P_OUTORDERNO   out char,
    p_currOper     char,           -- Current Operator
    p_currDept     char,           -- Curretn Operator's Department
    p_retCode      out char,       -- Return Code
    p_retMsg       out varchar2    -- Return Message
)
AS
    V_COUNT         INT;
    v_orderseqNo    CHAR(16);
    v_tradeID       CHAR(16);
    V_COMNO_SEQ     VARCHAR2(6);
    v_today         date:=sysdate;
    v_ex            EXCEPTION;
    V_ID            CHAR(16);
    V_ORDERTYPE     CHAR(1);
BEGIN
    /*
    SELECT NVL((SELECT COMPANYNO
    FROM   TD_M_BUYCARDCOMINFO
    WHERE  COMPANYNAME = P_GROUPNAME),'')
    INTO   V_COMNO_SEQ
    FROM   DUAL;

    --��Ϣ������ʱ�����µ�λ��Ϣ
    IF V_COMNO_SEQ IS NULL THEN
    BEGIN
        SELECT TD_M_BUYCARDCOM_SEQ.NEXTVAL INTO V_COMNO_SEQ FROM DUAL;
        INSERT INTO TD_M_BUYCARDCOMINFO(
        COMPANYNO        , COMPANYNAME
        )VALUES(
        V_COMNO_SEQ      , P_GROUPNAME
        );
    EXCEPTION WHEN OTHERS THEN
       P_RETCODE := 'S004102001' ;
       P_RETMSG  := '���빺����λ��Ϣ��ʧ��'||SQLERRM ;
       ROLLBACK;RETURN;
    END;
    END IF;  */

    IF P_FUNCCODE = 'ADD' THEN
        IF P_INITIATOR = '1' THEN
            v_orderseqNo := p_ORDERNO ; --��ȡ������
        ELSE
            SP_GetSeq(seq => v_orderseqNo); --���ɶ�����
        END IF;
        
        P_OUTORDERNO := v_orderseqNo;

        SELECT COUNT(*) INTO V_COUNT FROM TF_F_ORDERFORM WHERE ORDERNO = v_orderseqNo;

        IF V_COUNT > 0 THEN
            p_retCode := 'S094570297';
            p_retMsg := '�����Ѵ���';
            ROLLBACK;RETURN;
        END IF;

        IF P_ORDERTYPE = '1' THEN --��λ����
            BEGIN
                SP_PB_ComBuyCardReg(
                    P_FUNCCODE         => 'ADD'              ,
                    P_ID               => ''                 ,
                    P_COMPANYNAME      => P_GROUPNAME        ,
                    P_COMPANYPAPERTYPE => P_COMPANYPAPERTYPE ,
                    P_COMPANYPAPERNO   => P_COMPANYPAPERNO   ,
                    P_COMPANYMANAGERNO => P_COMPANYMANAGERNO ,
                    P_COMPANYENDTIME   => P_COMPANYENDTIME   ,
                    P_NAME             => P_NAME             ,
                    P_PAPERTYPE        => P_PAPERTYPE        ,
                    P_PAPERNO          => P_IDCARDNO         ,
                    P_PHONENO          => P_PHONE            ,
                    P_ADDRESS          => P_ADDRESS          ,
                    P_EMAIL            => P_EMAIL            ,
                    P_OUTBANK          => P_OUTBANK          ,
                    P_OUTACCT          => P_OUTACCT          ,
                    P_STARTCARDNO      => ''                 ,
                    P_ENDCARDNO        => ''                 ,
                    P_BUYCARDDATE      => ''                 ,
                    P_BUYCARDNUM       => ''                 ,
                    P_BUYCARDMONEY     => ''                 ,
                    P_CHARGEMONEY      => ''                 ,
                    P_REMARK           => v_orderseqNo       ,
                    P_CURROPER         => P_CURROPER         ,
                    P_CURRDEPT         => P_CURRDEPT         ,
                    P_RETCODE          => P_RETCODE          ,
                    P_RETMSG           => P_RETMSG
                );
                IF p_retCode != '0000000000' THEN RAISE v_ex; END IF;
            EXCEPTION WHEN OTHERS THEN
                ROLLBACK; RETURN;
            END;
        ELSE
            BEGIN
                SP_PB_PerBuyCardReg(
                    P_FUNCCODE              => 'ADD'          ,
                    P_ID                    => ''             ,
                    P_NAME                  => P_NAME         ,
                    P_BIRTHDAY              => P_BIRTHDAY     ,
                    P_PAPERTYPE             => P_PAPERTYPE    ,
                    P_PAPERNO               => P_IDCARDNO     ,
                    P_SEX                   => P_SEX          ,
                    P_PHONENO               => P_PHONE        ,
                    P_ADDRESS               => P_ADDRESS      ,
                    P_EMAIL                 => P_EMAIL        ,
                    P_STARTCARDNO           => ''             ,
                    P_ENDCARDNO             => ''             ,
                    P_BUYCARDDATE           => ''             ,
                    P_BUYCARDNUM            => ''             ,
                    P_BUYCARDMONEY          => ''             ,
                    P_CHARGEMONEY           => ''             ,
                    P_REMARK                => v_orderseqNo   ,
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
        --SP_GC_GETORDERNO(p_orderDate => P_ORDERDATE,p_orderSeq => v_orderseqNo);

        BEGIN
            INSERT INTO TF_F_ORDERFORM(
                ORDERNO            , ORDERSTATE          , ORDERTYPE         , GROUPNAME         , NAME               ,
                PHONE              , IDCARDNO            , TOTALMONEY        , TRANSACTOR        , INPUTTIME          ,
                REMARK             , CASHGIFTMONEY       , CHARGECARDMONEY   , SZTCARDMONEY      , LVYOUMONEY         , CUSTOMERACCMONEY   ,
                CUSTOMERACCHASMONEY, INVOICETOTALMONEY   , GETDEPARTMENT     , GETDATE           , USETAG             ,
                ORDERDATE          , ORDERSEQ            , UPDATEDEPARTNO    , UPDATESTAFFNO     , UPDATETIME         ,
                INITIATOR          , PAPERTYPE           , READERMONEY       , GARDENCARDMONEY   , RELAXCARDMONEY     ,
                MANAGERDEPT        ,MANAGER
           )VALUES(
                v_orderseqNo       , '01'                , P_ORDERTYPE       , P_GROUPNAME       , P_NAME             ,
                P_PHONE            , P_IDCARDNO          , P_TOTALMONEY      , P_TRANSACTOR      , v_today            ,
                P_REMARK           , P_CASHGIFTMONEY     , P_CHARGECARDMONEY , P_SZTCARDMONEY    , P_LVYOUMONEY       , P_CUSTOMERACCMONEY ,
                0                  , P_INVOICETOTALMONEY , P_GETDEPARTMENT   , P_GETDATE         , '1'                ,
                P_ORDERDATE        , P_ORDERSEQ          , p_currDept        , p_currOper        , v_today            ,
                P_INITIATOR        , P_PAPERTYPE         , P_READERMONEY     , P_GARDENCARDMONEY , P_RELAXCARDMONEY   ,
                P_MANAGERDEPT      ,P_MANAGER
                );
        EXCEPTION WHEN OTHERS THEN
            p_retCode := 'S094570300';
            p_retMsg := '���붩����ʧ��'|| SQLERRM ;
            ROLLBACK;RETURN;
        END;

        --�������𿨶�����ϸ��
        BEGIN
            FOR cur_data IN
            (
                SELECT * FROM tmp_order TMP
                WHERE TMP.F0 = P_SESSIONID AND TMP.F1 = '0'  --�������
            )
            LOOP
                BEGIN
                    INSERT INTO TF_F_CASHGIFTORDER (ORDERNO,VALUE,COUNT,SUM,LEFTQTY)
                    VALUES
                    (v_orderseqNo,to_number(cur_data.f2),to_number(cur_data.f3),to_number(cur_data.f4),to_number(cur_data.f3));
                    exception when others then
                    p_retCode := 'S001002203';
                    p_retMsg := '�������𿨶�����ϸ��ʧ��'|| SQLERRM ;
                    rollback; return;
                END;
            END LOOP;
        END;
        --�����ֵ��������ϸ��
        BEGIN
           FOR cur_data IN
           (
                  SELECT * FROM tmp_order TMP
                  WHERE TMP.F0 = P_SESSIONID AND TMP.F1 = '1'  --�����ֵ��
           )
           LOOP
              BEGIN
                  INSERT INTO TF_F_CHARGECARDORDER
                  (ORDERNO,VALUECODE,COUNT,SUM,LEFTQTY)
                  VALUES
                  (v_orderseqNo,cur_data.f2,to_number(cur_data.f3),
                  to_number(cur_data.f4),to_number(cur_data.f3));
                  exception when others then
                  p_retCode := 'S001002204';
                  p_retMsg := '�����ֵ��������ϸ��ʧ��'|| SQLERRM ;
                  rollback; return;
              END;
           END LOOP;
        END;
        --��������ͨ��������ϸ��
        BEGIN
          FOR cur_data IN
           (
                  SELECT * FROM tmp_order TMP
                  WHERE TMP.F0 = P_SESSIONID AND TMP.F1 = '2'  --��������ͨ��
           )
           LOOP
              
              IF  to_number(cur_data.f3)<>0  THEN
               BEGIN
                  INSERT INTO TF_F_SZTCARDORDER (ORDERNO,CARDTYPECODE,COUNT,UNITPRICE,TOTALCHARGEMONEY,TOTALMONEY,LEFTQTY)
                  VALUES
                  (v_orderseqNo,cur_data.f2, to_number(cur_data.f3),to_number(cur_data.f4),
                   to_number(cur_data.f5),to_number(cur_data.f6),to_number(cur_data.f3));
                  exception when others then
                  p_retCode := 'S001002205';
                  p_retMsg := '��������ͨ��������ϸ��ʧ��'|| SQLERRM ;
                  rollback; return;
                 END;
               ELSE  --����B��Ϊ�ɿ�ʱ,��COUNT=0ʱ
                BEGIN  
                  INSERT INTO TF_F_SZTCARDORDER (ORDERNO,CARDTYPECODE,COUNT,UNITPRICE,TOTALCHARGEMONEY,TOTALMONEY,LEFTQTY,ISCHARGE)
                  VALUES
                  (v_orderseqNo,cur_data.f2, to_number(cur_data.f3),to_number(cur_data.f4),
                   to_number(cur_data.f5),to_number(cur_data.f6),to_number(cur_data.f3),1);
                  exception when others then
                  p_retCode := 'S001002206';
                  p_retMsg := '��������ͨ��������ϸ��ʧ��'|| SQLERRM ;
                  rollback; return;
                 END;
               END IF;
              
           END LOOP;
        END;
        
        
         --�������ο�������ϸ��
        BEGIN
          FOR cur_data IN
           (
                  SELECT * FROM tmp_order TMP
                  WHERE TMP.F0 = P_SESSIONID AND TMP.F1 = '5'  --�������ο�
           )
           LOOP
              
                BEGIN
                  INSERT INTO TF_F_SZTCARDORDER (ORDERNO,CARDTYPECODE,COUNT,UNITPRICE,TOTALCHARGEMONEY,TOTALMONEY,LEFTQTY)
                  VALUES
                  (v_orderseqNo,cur_data.f2, to_number(cur_data.f3),to_number(cur_data.f4),
                   to_number(cur_data.f5),to_number(cur_data.f6),to_number(cur_data.f3));
                  exception when others then
                  p_retCode := 'S001002205';
                  p_retMsg := '��������ͨ��������ϸ��ʧ��'|| SQLERRM ;
                  rollback; return;
                 END;
               
              
           END LOOP;
        END;

        --���붩����Ʊ��ϸ��
        BEGIN
           FOR cur_data IN
           (
                  SELECT * FROM tmp_order TMP
                  WHERE TMP.F0 = P_SESSIONID AND TMP.F1 = '3'  --����Ʊ��Ϣ
           )
           LOOP
              BEGIN
                  INSERT INTO TF_F_ORDERINVOICE (ORDERNO,INVOICETYPECODE,INVOICEMONEY)
                  VALUES
                  (v_orderseqNo,cur_data.f2, cur_data.f3);
                  exception when others then
                  p_retCode := 'S001002207';
                  p_retMsg :=  '���붩����Ʊ��ϸ��ʧ��'|| SQLERRM ;
                  rollback; return;
              END;
           END LOOP;
        END;

        --���붩�����ʽ��
        BEGIN
           FOR cur_data IN
           (
                  SELECT * FROM tmp_order TMP
                  WHERE TMP.F0 = P_SESSIONID AND TMP.F1 = '4'  --�����ʽ
           )
           LOOP
              BEGIN
                  INSERT INTO TF_F_PAYTYPE (ORDERNO,PAYTYPECODE,PAYTYPENAME)
                  VALUES
                  (v_orderseqNo,cur_data.f2, cur_data.f3);
                  exception when others then
                  p_retCode := 'S001002208';
                  p_retMsg :=  '���붩�����ʽ��ʧ��'|| SQLERRM ;
                  rollback; return;
              END;
           END LOOP;
        END;
        
        IF P_READERMONEY > 0 THEN
            --��¼��������ϸ��
            BEGIN
                INSERT INTO TF_F_READERORDER(ORDERNO,VALUE,COUNT,SUM,LEFTQTY) VALUES
                (v_orderseqNo,P_READERPRICE,P_READERNUM,P_READERMONEY,P_READERNUM);
            EXCEPTION when others then
                p_retCode := 'S094570339';
                p_retMsg := '��¼��������ϸ��ʧ��'|| SQLERRM ;
                rollback; return;
            END;
        END IF;
        
        IF P_GARDENCARDMONEY > 0 THEN
            --��¼԰���꿨��ϸ��
            BEGIN
                INSERT INTO TF_F_GARDENCARDORDER(ORDERNO,VALUE,COUNT,SUM) VALUES
                (v_orderseqNo,P_GARDENCARDPRICE,P_GARDENCARDNUM,P_GARDENCARDMONEY);
            EXCEPTION when others then
                p_retCode := 'S094570340';
                p_retMsg := '��¼԰���꿨��ϸ��ʧ��'|| SQLERRM ;
                rollback; return;        
            END;
        END IF;
        
        IF P_RELAXCARDMONEY > 0 THEN
            --��¼�����꿨��ϸ��
            BEGIN
                INSERT INTO TF_F_RELAXCARDORDER(ORDERNO,VALUE,COUNT,SUM) VALUES
                (v_orderseqNo,P_RELAXCARDPRICE,P_RELAXCARDNUM,P_RELAXCARDMONEY);
            EXCEPTION when others then
                p_retCode := 'S094570341';
                p_retMsg := '��¼�����꿨��ϸ��ʧ��'|| SQLERRM ;
                    rollback; return;        
            END;
        END IF;
        
        SP_GetSeq(seq => v_tradeID); --������ˮ��
        --��¼����̨��
        BEGIN
            INSERT INTO TF_F_ORDERTRADE (
                TRADEID         , ORDERNO           , TRADECODE       , MONEY             , GROUPNAME      , NAME   ,
                CASHGIFTMONEY   , CHARGECARDMONEY   , SZTCARDMONEY    , LVYOUMONEY        , CUSTOMERACCMONEY  , GETDEPARTMENT  ,
                GETDATE         , REMARK            , OPERATEDEPARTNO , OPERATESTAFFNO    , OPERATETIME    ,READERMONEY ,
                GARDENCARDMONEY   , RELAXCARDMONEY
           )VALUES(
                v_tradeID       , v_orderseqNo      , '00'            , P_TOTALMONEY       , P_GROUPNAME    , P_NAME ,
                P_CASHGIFTMONEY , P_CHARGECARDMONEY , P_SZTCARDMONEY  , P_LVYOUMONEY       , P_CUSTOMERACCMONEY , P_GETDEPARTMENT,
                P_GETDATE       , P_REMARK          , p_currDept      , p_currOper         , v_today        ,P_READERMONEY ,
                P_GARDENCARDMONEY , P_RELAXCARDMONEY
                );
            exception when others then
            p_retCode := 'S094570301';
            p_retMsg :=  '���붩��̨�˱�ʧ��'|| SQLERRM ;
            rollback; return;
        END;
    END IF;

    IF P_FUNCCODE = 'MODIFY' THEN
        --���ض����Ÿ�ֵ
        P_OUTORDERNO := p_ORDERNO;
        
        SELECT ORDERTYPE INTO V_ORDERTYPE FROM TF_F_ORDERFORM WHERE ORDERNO = p_ORDERNO;
        IF V_ORDERTYPE = '1' AND P_ORDERTYPE = '1' THEN --��λ����
            BEGIN
                SELECT ID INTO V_ID FROM TF_F_COMBUYCARDREG WHERE REMARK =  p_ORDERNO;
            EXCEPTION WHEN NO_DATA_FOUND THEN
                p_retCode := 'S094570299';
                p_retMsg :=  'δ�ҵ���λ������¼,'|| SQLERRM ;
                rollback; return;
            END;
            BEGIN
                SP_PB_ComBuyCardReg(
                    P_FUNCCODE         => 'MODIFY'           ,
                    P_ID               => V_ID               ,
                    P_COMPANYNAME      => P_GROUPNAME        ,
                    P_COMPANYPAPERTYPE => P_COMPANYPAPERTYPE ,
                    P_COMPANYPAPERNO   => P_COMPANYPAPERNO   ,
                    P_COMPANYMANAGERNO => P_COMPANYMANAGERNO ,
                    P_COMPANYENDTIME   => P_COMPANYENDTIME   ,
                    P_NAME             => P_NAME             ,
                    P_PAPERTYPE        => P_PAPERTYPE        ,
                    P_PAPERNO          => P_IDCARDNO         ,
                    P_PHONENO          => P_PHONE            ,
                    P_ADDRESS          => P_ADDRESS          ,
                    P_EMAIL            => P_EMAIL            ,
                    P_OUTBANK          => P_OUTBANK          ,
                    P_OUTACCT          => P_OUTACCT          ,
                    P_STARTCARDNO      => ''                 ,
                    P_ENDCARDNO        => ''                 ,
                    P_BUYCARDDATE      => ''                 ,
                    P_BUYCARDNUM       => ''                 ,
                    P_BUYCARDMONEY     => ''                 ,
                    P_CHARGEMONEY      => ''                 ,
                    P_REMARK           => p_ORDERNO          ,
                    P_CURROPER         => P_CURROPER         ,
                    P_CURRDEPT         => P_CURRDEPT         ,
                    P_RETCODE          => P_RETCODE          ,
                    P_RETMSG           => P_RETMSG
                );
                IF p_retCode != '0000000000' THEN RAISE v_ex; END IF;
            EXCEPTION WHEN OTHERS THEN
                ROLLBACK; RETURN;
            END;
        ELSIF V_ORDERTYPE = '2' AND P_ORDERTYPE = '2' THEN --���˶���
            BEGIN
                SELECT ID INTO V_ID FROM TF_F_PERBUYCARDREG WHERE REMARK =  p_ORDERNO;
            EXCEPTION WHEN NO_DATA_FOUND THEN
                p_retCode := 'S094570298';
                p_retMsg :=  'δ�ҵ����˹�����¼,'|| SQLERRM ;
                rollback; return;
            END;
            BEGIN
                SP_PB_PerBuyCardReg(
                    P_FUNCCODE              => 'MODIFY'       ,
                    P_ID                    => V_ID           ,
                    P_NAME                  => P_NAME         ,
                    P_BIRTHDAY              => P_BIRTHDAY     ,
                    P_PAPERTYPE             => P_PAPERTYPE    ,
                    P_PAPERNO               => P_IDCARDNO     ,
                    P_SEX                   => P_SEX          ,
                    P_PHONENO               => P_PHONE        ,
                    P_ADDRESS               => P_ADDRESS      ,
                    P_EMAIL                 => P_EMAIL        ,
                    P_STARTCARDNO           => ''             ,
                    P_ENDCARDNO             => ''             ,
                    P_BUYCARDDATE           => ''             ,
                    P_BUYCARDNUM            => ''             ,
                    P_BUYCARDMONEY          => ''             ,
                    P_CHARGEMONEY           => ''             ,
                    P_REMARK                => p_ORDERNO      ,
                    P_CURROPER              => P_CURROPER     ,
                    P_CURRDEPT              => P_CURRDEPT     ,
                    P_RETCODE               => P_RETCODE      ,
                    P_RETMSG                => P_RETMSG
                    );
                IF p_retCode != '0000000000' THEN RAISE v_ex; END IF;
            EXCEPTION WHEN OTHERS THEN
                ROLLBACK; RETURN;
            END;
        ELSIF V_ORDERTYPE = '2' AND P_ORDERTYPE = '1' THEN --���˶����ĵ�λ����
            BEGIN
                SELECT ID INTO V_ID FROM TF_F_PERBUYCARDREG WHERE REMARK =  p_ORDERNO;
            EXCEPTION WHEN NO_DATA_FOUND THEN
                p_retCode := 'S094570298';
                p_retMsg :=  'δ�ҵ����˹�����¼,'|| SQLERRM ;
                rollback; return;
            END;
            --���ϸ��˹�����¼
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
            --������λ������¼
            BEGIN
                SP_PB_ComBuyCardReg(
                    P_FUNCCODE         => 'ADD'              ,
                    P_ID               => ''                 ,
                    P_COMPANYNAME      => P_GROUPNAME        ,
                    P_COMPANYPAPERTYPE => P_COMPANYPAPERTYPE ,
                    P_COMPANYPAPERNO   => P_COMPANYPAPERNO   ,
                    P_COMPANYMANAGERNO => P_COMPANYMANAGERNO ,
                    P_COMPANYENDTIME   => P_COMPANYENDTIME   ,
                    P_NAME             => P_NAME             ,
                    P_PAPERTYPE        => P_PAPERTYPE        ,
                    P_PAPERNO          => P_IDCARDNO         ,
                    P_PHONENO          => P_PHONE            ,
                    P_ADDRESS          => P_ADDRESS          ,
                    P_EMAIL            => P_EMAIL            ,
                    P_OUTBANK          => P_OUTBANK          ,
                    P_OUTACCT          => P_OUTACCT          ,
                    P_STARTCARDNO      => ''                 ,
                    P_ENDCARDNO        => ''                 ,
                    P_BUYCARDDATE      => ''                 ,
                    P_BUYCARDNUM       => ''                 ,
                    P_BUYCARDMONEY     => ''                 ,
                    P_CHARGEMONEY      => ''                 ,
                    P_REMARK           => p_ORDERNO          ,
                    P_CURROPER         => P_CURROPER         ,
                    P_CURRDEPT         => P_CURRDEPT         ,
                    P_RETCODE          => P_RETCODE          ,
                    P_RETMSG           => P_RETMSG
                );
                IF p_retCode != '0000000000' THEN RAISE v_ex; END IF;
            EXCEPTION WHEN OTHERS THEN
                ROLLBACK; RETURN;
            END;
        ELSIF V_ORDERTYPE = '1' AND P_ORDERTYPE = '2' THEN --��λ�����ĸ��˶���
            BEGIN
                SELECT ID INTO V_ID FROM TF_F_COMBUYCARDREG WHERE REMARK =  p_ORDERNO;
            EXCEPTION WHEN NO_DATA_FOUND THEN
                p_retCode := 'S094570299';
                p_retMsg :=  'δ�ҵ���λ������¼,'|| SQLERRM ;
                rollback; return;
            END;
            --���ϵ�λ������¼
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
            --�������˹�����¼
            BEGIN
                SP_PB_PerBuyCardReg(
                    P_FUNCCODE              => 'ADD'          ,
                    P_ID                    => ''             ,
                    P_NAME                  => P_NAME         ,
                    P_BIRTHDAY              => P_BIRTHDAY     ,
                    P_PAPERTYPE             => P_PAPERTYPE    ,
                    P_PAPERNO               => P_IDCARDNO     ,
                    P_SEX                   => P_SEX          ,
                    P_PHONENO               => P_PHONE        ,
                    P_ADDRESS               => P_ADDRESS      ,
                    P_EMAIL                 => P_EMAIL        ,
                    P_STARTCARDNO           => ''             ,
                    P_ENDCARDNO             => ''             ,
                    P_BUYCARDDATE           => ''             ,
                    P_BUYCARDNUM            => ''             ,
                    P_BUYCARDMONEY          => ''             ,
                    P_CHARGEMONEY           => ''             ,
                    P_REMARK                => p_ORDERNO      ,
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
            SET   ORDERSTATE        = '01' ,
                  ORDERTYPE         = P_ORDERTYPE,
                  GROUPNAME         = P_GROUPNAME,
                  NAME              = P_NAME,
                  PHONE             = P_PHONE,
                  PAPERTYPE         = P_PAPERTYPE,
                  IDCARDNO          = P_IDCARDNO,
                  TOTALMONEY        = P_TOTALMONEY,
                  REMARK            = P_REMARK,
                  CASHGIFTMONEY     = P_CASHGIFTMONEY,
                  CHARGECARDMONEY   = P_CHARGECARDMONEY,
                  SZTCARDMONEY      = P_SZTCARDMONEY,
                  LVYOUMONEY        = P_LVYOUMONEY,
                  READERMONEY       = P_READERMONEY,
                  GARDENCARDMONEY   = P_GARDENCARDMONEY,
                  RELAXCARDMONEY    = P_RELAXCARDMONEY,
                  CUSTOMERACCMONEY  = P_CUSTOMERACCMONEY,
                  INVOICETOTALMONEY = P_INVOICETOTALMONEY,
                  GETDEPARTMENT     = P_GETDEPARTMENT,
                  GETDATE           = P_GETDATE,
                  UPDATEDEPARTNO    = p_currDept,
                  UPDATESTAFFNO     = p_currOper,
                  UPDATETIME        = v_today ,
                  MANAGERDEPT       = P_MANAGERDEPT,
                  MANAGER           = P_MANAGER
            WHERE ORDERNO = p_ORDERNO
            AND   TRANSACTOR = p_currOper
            AND   ORDERSTATE = '00' --�޸���
            AND   USETAG = '1'; --��Ч

            IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;

        EXCEPTION WHEN OTHERS THEN
            p_retCode := 'S094570308';
            p_retMsg := '�޸Ķ�����ʧ��,'|| SQLERRM ;
            ROLLBACK;RETURN;
        END;

        --ɾ����ϸ��
        BEGIN
            DELETE FROM TF_F_CASHGIFTORDER WHERE ORDERNO = p_ORDERNO;
            DELETE FROM TF_F_CHARGECARDORDER WHERE ORDERNO = p_ORDERNO;
            DELETE FROM TF_F_SZTCARDORDER WHERE ORDERNO = p_ORDERNO;
            DELETE FROM TF_F_READERORDER WHERE ORDERNO = p_ORDERNO;
            DELETE FROM TF_F_GARDENCARDORDER WHERE ORDERNO = p_ORDERNO;
            DELETE FROM TF_F_RELAXCARDORDER WHERE ORDERNO = p_ORDERNO;
            DELETE FROM TF_F_ORDERINVOICE WHERE ORDERNO = p_ORDERNO;
            DELETE FROM TF_F_PAYTYPE WHERE ORDERNO = p_ORDERNO;
        EXCEPTION WHEN OTHERS THEN
            p_retCode := 'S094570309';
            p_retMsg := 'ɾ��������ϸ��ʧ��,'|| SQLERRM ;
            ROLLBACK;RETURN;
        END;

        --�������𿨶�����ϸ��
        BEGIN
            FOR cur_data IN
            (
                SELECT * FROM tmp_order TMP
                WHERE TMP.F0 = P_SESSIONID AND TMP.F1 = '0'  --�������
            )
            LOOP
                BEGIN
                    INSERT INTO TF_F_CASHGIFTORDER (ORDERNO,VALUE,COUNT,SUM,LEFTQTY)
                    VALUES
                    (p_ORDERNO,to_number(cur_data.f2),to_number(cur_data.f3),to_number(cur_data.f4),to_number(cur_data.f3));
                    exception when others then
                    p_retCode := 'S001002203';
                    p_retMsg := '�������𿨶�����ϸ��ʧ��'|| SQLERRM ;
                    rollback; return;
                END;
            END LOOP;
        END;
        --�����ֵ��������ϸ��
        BEGIN
           FOR cur_data IN
           (
                  SELECT * FROM tmp_order TMP
                  WHERE TMP.F0 = P_SESSIONID AND TMP.F1 = '1'  --�����ֵ��
           )
           LOOP
              BEGIN
                  INSERT INTO TF_F_CHARGECARDORDER
                  (ORDERNO,VALUECODE,COUNT,SUM,LEFTQTY)
                  VALUES
                  (p_ORDERNO,cur_data.f2,to_number(cur_data.f3),
                  to_number(cur_data.f4),to_number(cur_data.f3));
                  exception when others then
                  p_retCode := 'S001002204';
                  p_retMsg := '�����ֵ��������ϸ��ʧ��'|| SQLERRM ;
                  rollback; return;
              END;
           END LOOP;
        END;
        --��������ͨ��������ϸ��
        BEGIN
          FOR cur_data IN
           (
                  SELECT * FROM tmp_order TMP
                  WHERE TMP.F0 = P_SESSIONID AND TMP.F1 = '2'  --��������ͨ��
           )
           LOOP
              BEGIN
                  INSERT INTO TF_F_SZTCARDORDER (ORDERNO,CARDTYPECODE,COUNT,UNITPRICE,TOTALCHARGEMONEY,TOTALMONEY,LEFTQTY)
                  VALUES
                  (p_ORDERNO,cur_data.f2, to_number(cur_data.f3),to_number(cur_data.f4),
                   to_number(cur_data.f5),to_number(cur_data.f6),to_number(cur_data.f3));
                  exception when others then
                  p_retCode := 'S001002205';
                  p_retMsg := '��������ͨ��������ϸ��ʧ��'|| SQLERRM ;
                  rollback; return;
              END;
           END LOOP;
        END;
        

        --�������ο�������ϸ��
        BEGIN
          FOR cur_data IN
           (
                  SELECT * FROM tmp_order TMP
                  WHERE TMP.F0 = P_SESSIONID AND TMP.F1 = '5'  --�������ο�
           )
           LOOP
              
                BEGIN
                  INSERT INTO TF_F_SZTCARDORDER (ORDERNO,CARDTYPECODE,COUNT,UNITPRICE,TOTALCHARGEMONEY,TOTALMONEY,LEFTQTY)
                  VALUES
                  (p_ORDERNO,cur_data.f2, to_number(cur_data.f3),to_number(cur_data.f4),
                   to_number(cur_data.f5),to_number(cur_data.f6),to_number(cur_data.f3));
                  exception when others then
                  p_retCode := 'S001002205';
                  p_retMsg := '��������ͨ��������ϸ��ʧ��'|| SQLERRM ;
                  rollback; return;
                 END;
               
              
           END LOOP;
        END;

        IF P_READERMONEY > 0 THEN
            --��¼��������ϸ��
            BEGIN
                INSERT INTO TF_F_READERORDER(ORDERNO,VALUE,COUNT,SUM,LEFTQTY) VALUES
                (p_ORDERNO,P_READERPRICE,P_READERNUM,P_READERMONEY,P_READERNUM);
            EXCEPTION when others then
                p_retCode := 'S094570339';
                p_retMsg := '��¼��������ϸ��ʧ��'|| SQLERRM ;
                rollback; return;
            END;
        END IF;
        
        IF P_GARDENCARDMONEY > 0 THEN
            --��¼԰���꿨��ϸ��
            BEGIN
                INSERT INTO TF_F_GARDENCARDORDER(ORDERNO,VALUE,COUNT,SUM) VALUES
                (p_ORDERNO,P_GARDENCARDPRICE,P_GARDENCARDNUM,P_GARDENCARDMONEY);
            EXCEPTION when others then
                p_retCode := 'S094570340';
                p_retMsg := '��¼԰���꿨��ϸ��ʧ��'|| SQLERRM ;
                rollback; return;        
            END;
        END IF;
        
        IF P_RELAXCARDMONEY > 0 THEN
            --��¼�����꿨��ϸ��
            BEGIN
                INSERT INTO TF_F_RELAXCARDORDER(ORDERNO,VALUE,COUNT,SUM) VALUES
                (p_ORDERNO,P_RELAXCARDPRICE,P_RELAXCARDNUM,P_RELAXCARDMONEY);
            EXCEPTION when others then
                p_retCode := 'S094570341';
                p_retMsg := '��¼�����꿨��ϸ��ʧ��'|| SQLERRM ;
                    rollback; return;        
            END;
        END IF;
        
        --���¿�Ʊ��Ϣ
        BEGIN
           FOR cur_data IN
           (
                  SELECT * FROM tmp_order TMP
                  WHERE TMP.F0 = P_SESSIONID AND TMP.F1 = '3'  --����Ʊ��Ϣ
           )
           LOOP
              BEGIN
                  INSERT INTO TF_F_ORDERINVOICE (ORDERNO,INVOICETYPECODE,INVOICEMONEY)
                  VALUES
                  (p_ORDERNO,cur_data.f2, cur_data.f3);
                  exception when others then
                  p_retCode := 'S001002207';
                  p_retMsg :=  '���붩����Ʊ��ϸ��ʧ��'|| SQLERRM ;
                  rollback; return;
              END;
           END LOOP;
        END;

        --���¸��ʽ��
        BEGIN
           FOR cur_data IN
           (
                  SELECT * FROM tmp_order TMP
                  WHERE TMP.F0 = P_SESSIONID AND TMP.F1 = '4'  --�����ʽ
           )
           LOOP
              BEGIN
                  INSERT INTO TF_F_PAYTYPE (ORDERNO,PAYTYPECODE,PAYTYPENAME)
                  VALUES
                  (p_ORDERNO,cur_data.f2, cur_data.f3);
                  exception when others then
                  p_retCode := 'S001002208';
                  p_retMsg :=  '���붩�����ʽ��ʧ��'|| SQLERRM ;
                  rollback; return;
              END;
           END LOOP;
        END;

        SP_GetSeq(seq => v_tradeID); --������ˮ��
        --��¼����̨��
        BEGIN
            INSERT INTO TF_F_ORDERTRADE (
                TRADEID         , ORDERNO           , TRADECODE       , MONEY             , GROUPNAME      , NAME      ,
                CASHGIFTMONEY   , CHARGECARDMONEY   , SZTCARDMONEY    , LVYOUMONEY        , CUSTOMERACCMONEY  , GETDEPARTMENT  , ORDERSTATE,
                GETDATE         , REMARK            , OPERATEDEPARTNO , OPERATESTAFFNO    , OPERATETIME    , READERMONEY ,
                GARDENCARDMONEY   , RELAXCARDMONEY
           )VALUES(
                v_tradeID       , p_ORDERNO         , '01'            , P_TOTALMONEY       , P_GROUPNAME    , P_NAME    ,
                P_CASHGIFTMONEY , P_CHARGECARDMONEY , P_SZTCARDMONEY  , P_LVYOUMONEY       , P_CUSTOMERACCMONEY , P_GETDEPARTMENT, '00'      ,
                P_GETDATE       , P_REMARK          , p_currDept      , p_currOper         , v_today        , P_READERMONEY ,
                P_GARDENCARDMONEY ,P_RELAXCARDMONEY
                );
            exception when others then
            p_retCode := 'S094570301';
            p_retMsg :=  '���붩��̨�˱�ʧ��'|| SQLERRM ;
            rollback; return;
        END;
    END IF;

    p_retCode := '0000000000'; p_retMsg  := '';
    COMMIT; RETURN;
END;
/
show errors

create or replace procedure SP_GC_ORDERCARDCHANGE
(
    P_SESSIONID    varchar2 ,
    p_ORDERNO      char     , --������
    P_TOTALMONEY   integer,   --�ܽ��
    P_CASHGIFTMONEY     integer, --����ܽ��
    P_CHARGECARDMONEY   integer, --��ֵ���ܽ��
    P_SZTCARDMONEY      integer, --����B���ܽ��
    P_LVYOUMONEY        integer, --���ο��ܽ��
    P_CUSTOMERACCMONEY  integer, --ר���˻��ܳ�ֵ���
    P_READERMONEY       integer, --�������ܽ��
    P_GARDENCARDMONEY   integer, --԰���꿨�ܽ��
    P_RELAXCARDMONEY    integer, --�����꿨�ܽ��
    
    P_READERNUM         integer, --����������
    P_READERPRICE       integer, --����������
    P_GARDENCARDNUM     integer, --԰���꿨����
    P_GARDENCARDPRICE   integer, --԰���꿨����
    P_RELAXCARDNUM      integer, --�����꿨����
    P_RELAXCARDPRICE    integer, --�����꿨����
    
    P_ISRELATED    char, --�Ƿ����

    p_currOper     char,           -- Current Operator
    p_currDept     char,           -- Curretn Operator's Department
    p_retCode      out char,       -- Return Code
    p_retMsg       out varchar2    -- Return Message
)
AS
    V_COUNT         INT;
    v_orderseqNo    CHAR(16);
    v_tradeID       CHAR(16);
    v_today         date:=sysdate;
    v_ex            EXCEPTION;
    V_ID            CHAR(16);
/*
    ����������
    ʯ��
    2013-05-26
*/
BEGIN    
    --���¶�����
    BEGIN
        UPDATE TF_F_ORDERFORM
        SET   ORDERSTATE        = '03' , --��ɷ��䣬���������ƿ�
              ISRELATED         = P_ISRELATED  , 
              CASHGIFTMONEY     = P_CASHGIFTMONEY,
              CHARGECARDMONEY   = P_CHARGECARDMONEY,
              SZTCARDMONEY      = P_SZTCARDMONEY,
              LVYOUMONEY        = P_LVYOUMONEY,
              READERMONEY       = P_READERMONEY,
              GARDENCARDMONEY   = P_GARDENCARDMONEY,
              RELAXCARDMONEY    = P_RELAXCARDMONEY,
              CUSTOMERACCMONEY  = P_CUSTOMERACCMONEY,
              UPDATEDEPARTNO    = p_currDept,
              UPDATESTAFFNO     = p_currOper,
              UPDATETIME        = v_today
        WHERE ORDERNO = p_ORDERNO
        AND   GETDEPARTMENT = p_currDept
        AND   ORDERSTATE = '07' --�����������
        AND   TOTALMONEY = P_TOTALMONEY --�ܽ��һ��
        AND   USETAG = '1'; --��Ч

        IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;

    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S094570308';
        p_retMsg := '�޸Ķ�����ʧ��,'|| SQLERRM ;
        ROLLBACK;RETURN;
    END;
	SP_GetSeq(seq => v_tradeID); --������ˮ��
    --�����ƿ�̨��
    BEGIN
        UPDATE TF_F_ORDERTRADE
        SET    CANCELTAG = '1' ,
               CANCELTRADEID = v_tradeID
        WHERE  ORDERNO = p_ORDERNO
        AND    TRADECODE = '07'
        AND    CANCELTAG = '0';
        
    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S943901B03';
            p_retMsg  := '�����ƿ�̨��ʧ��' || SQLERRM;
            ROLLBACK; RETURN;            
    END;
    
    --ȡ�����𿨶�����ϵ
    BEGIN
        DELETE FROM TF_F_CASHGIFTRELATION WHERE ORDERNO = p_ORDERNO;
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S094570324';
        p_retMsg  := 'ȡ�����𿨶�����ϵʧ��,'|| SQLERRM;
        ROLLBACK; RETURN;            
    END;    
    
    --ȡ����ֵ��������ϵ
    BEGIN
        DELETE FROM TF_F_CHARGECARDRELATION WHERE ORDERNO = p_ORDERNO;
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S094570325';
        p_retMsg  := 'ȡ����ֵ��������ϵʧ��,'|| SQLERRM;
        ROLLBACK; RETURN;            
    END;
    
    --ȡ������B��������ϵ���������ο���
    BEGIN
        DELETE FROM TF_F_SZTCARDRELATION WHERE ORDERNO = p_ORDERNO;
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S094570326';
        p_retMsg  := 'ȡ������B��������ϵʧ��,'|| SQLERRM;
        ROLLBACK; RETURN;            
    END;
    
 
    --ȡ��ר���˻�������ϵ
    BEGIN
        DELETE FROM TF_F_CUSTOMERACCRELATION WHERE ORDERNO = p_ORDERNO;
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S094570327';
        p_retMsg  := 'ȡ��ר���˻�������ϵʧ��,'|| SQLERRM;
        ROLLBACK; RETURN;            
    END;
    
    --ȡ��������������ϵ
    BEGIN
        DELETE FROM TF_F_READERRELATION WHERE ORDERNO = p_ORDERNO;
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S094570348';
        p_retMsg  := 'ȡ��������������ϵʧ��,'|| SQLERRM;
        ROLLBACK; RETURN;            
    END;    
    
    --ɾ����ϸ��
    BEGIN
        DELETE FROM TF_F_CASHGIFTORDER WHERE ORDERNO = p_ORDERNO;
        DELETE FROM TF_F_CHARGECARDORDER WHERE ORDERNO = p_ORDERNO;
        DELETE FROM TF_F_SZTCARDORDER WHERE ORDERNO = p_ORDERNO;
        DELETE FROM TF_F_READERORDER WHERE ORDERNO = p_ORDERNO;
        DELETE FROM TF_F_GARDENCARDORDER WHERE ORDERNO = p_ORDERNO;
        DELETE FROM TF_F_RELAXCARDORDER WHERE ORDERNO = p_ORDERNO;
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

    
    --��¼����̨��
    BEGIN
        INSERT INTO TF_F_ORDERTRADE (
            TRADEID           , ORDERNO           , TRADECODE       , MONEY             , GROUPNAME      , NAME        ,
            CASHGIFTMONEY     , CHARGECARDMONEY   , SZTCARDMONEY    , LVYOUMONEY        , CUSTOMERACCMONEY  , GETDEPARTMENT  , ORDERSTATE  ,
            GETDATE           , REMARK            , OPERATEDEPARTNO , OPERATESTAFFNO    , OPERATETIME    , READERMONEY ,
            GARDENCARDMONEY   , RELAXCARDMONEY
       )SELECT 
            v_tradeID         , p_ORDERNO         , '13'            , P_TOTALMONEY       , t.GROUPNAME    , t.NAME    ,
            P_CASHGIFTMONEY   , P_CHARGECARDMONEY , P_SZTCARDMONEY  , P_LVYOUMONEY       , P_CUSTOMERACCMONEY , t.GETDEPARTMENT, '00'      ,
            t.GETDATE         , t.REMARK          , p_currDept      , p_currOper         , v_today        , P_READERMONEY ,
            P_GARDENCARDMONEY , P_RELAXCARDMONEY
        FROM TF_F_ORDERFORM t
        WHERE  ORDERNO = p_ORDERNO;
        exception when others then
        p_retCode := 'S094570301';
        p_retMsg :=  '���붩��̨�˱�ʧ��'|| SQLERRM ;
        rollback; return;
    END;
    
    p_retCode := '0000000000'; p_retMsg  := '';
    COMMIT; RETURN;
END;
/
show errors
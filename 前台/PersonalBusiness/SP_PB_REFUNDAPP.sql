CREATE OR REPLACE PROCEDURE SP_PB_REFUNDAPP
(
    p_SESSIONID  varchar2, -- Session ID
    p_currOper  char,
    p_currDept  char,
    p_retCode   out char, -- Return Code
    p_retMsg    out varchar2  -- Return Message
)
AS
    v_today         date := sysdate;
    v_quantity      INT;
    v_ex            EXCEPTION;
    v_TRADEID       VARCHAR2(32);
    v_TRADEID2       CHAR(16);
    v_ID            CHAR(18);
    v_statecode     char(1);
    v_CARDNO         CHAR(16);
    v_CHANNELNO     char(2);
    v_PAYMENTTYPE   char(2);
    v_TRADEMONEY   INT;
    v_currOper     CHAR(6);
    v_currDept     CHAR(4);

BEGIN
    --�ж��Ƿ���������Ҫ����
    SELECT COUNT(*) INTO v_quantity FROM TMP_ORDER WHERE f1 = p_SESSIONID;
    IF v_quantity is null or v_quantity <= 0 THEN
        p_retCode := 'A004P01001'; p_retMsg  := 'û���κ�������Ҫ����';
        RETURN;
    END IF;



  BEGIN
    FOR V_CUR IN (SELECT f0 FROM TMP_ORDER WHERE f1 = p_sessionId)
    LOOP
    v_TRADEID:=V_CUR.f0;
    --��ѯ�˿�״̬,����,���׽��,����,���ʽ,
    SELECT ISREFUND ,CARDNO,TRADEMONEY,CHANNELNO,PAYMENTTYPE  INTO v_statecode,v_CARDNO,v_TRADEMONEY,v_CHANNELNO,v_PAYMENTTYPE FROM TF_OUT_ADDTRADE WHERE TRADEID  = v_TRADEID ;

      --����������˿�ļ�¼
        IF v_statecode = '1' THEN
            p_retCode := 'S094570231';
            p_retMsg :=V_CUR.f0||'��ֵ������ˮ�Ѿ������˿�,�������ٴβ���' ;
        RETURN;
        END IF;
     --�����ר���˻����˿����Ϊ0 
     IF v_PAYMENTTYPE='04' THEN 
     
        v_TRADEMONEY:=0;
     
     END IF;
        
     BEGIN
        --�ڳ�ֵ����֧����ʽ��Ӧ����Ա�������Ҷ�Ӧ����Ա�Ͳ���Ա����
          SELECT STAFFNO,DEPARTNO INTO v_currOper,v_currDept FROM TD_M_PAYMENTSTAFF WHERE PAYMENTTYPE=V_PAYMENTTYPE;
          EXCEPTION WHEN NO_DATA_FOUND THEN
          p_retCode := 'S094570232'; p_retMsg  := 'ȱ�ٲ���-��ֵ����֧����ʽ��Ӧ����Ա����';
          RETURN;
     END;


     --���³�ֵ�˿��
    BEGIN
        UPDATE TF_OUT_ADDTRADE
        SET    ISREFUND     = '1',
               REFUNDTIME   =v_today,
               REFUNDSTAFF=p_currOper
        WHERE  TRADEID =v_TRADEID;

        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S004P03B02'; p_retMsg  := '���²��Ƕ�����ʧ��,' || SQLERRM;
            ROLLBACK; RETURN;
    END;


    v_ID :=to_char(sysdate,'MMddHH24miss')||substr(v_CARDNO,9,8);
    SP_GetSeq(seq => v_TradeID2);
    --д��ҵ��̨�� RSRV1:����  RSRV2:���׷�ʽ
    BEGIN
        INSERT INTO TF_B_TRADE
            (TRADEID,ID,TRADETYPECODE,CARDNO,CURRENTMONEY,
            OPERATESTAFFNO,OPERATEDEPARTID,OPERATETIME,RSRV1,RSRV2)
         VAlUES
            (v_TradeID2,v_ID,'S2',v_CARDNO,-v_TRADEMONEY,
            v_currOper, v_currDept,v_today,v_CHANNELNO,v_PAYMENTTYPE);
    EXCEPTION
          WHEN OTHERS THEN
              p_retCode:= 'S004P03B03';
               p_retMsg  := '��¼ҵ��̨��ʧ��' || SQLERRM;
              ROLLBACK; RETURN;
    END;

    --д���ֽ�̨��
    BEGIN
        INSERT INTO TF_B_TRADEFEE
            (ID,TRADEID,TRADETYPECODE,CARDNO,SUPPLYMONEY,
            OPERATESTAFFNO,OPERATEDEPARTID,OPERATETIME)
        VAlUES
            (v_ID,v_TradeID2,'S2',v_CARDNO,-v_TRADEMONEY,
            v_currOper,v_currDept,v_today);

    EXCEPTION
          WHEN OTHERS THEN
              p_retCode := 'S004P03B04';
              p_retMsg  := '��¼�ֽ�̨�˱�ʧ��' || SQLERRM;
              ROLLBACK; RETURN;
    END;

    END LOOP;



  END;


    p_retCode := '0000000000'; p_retMsg  := '';
    COMMIT; RETURN;
END;


/
show errors

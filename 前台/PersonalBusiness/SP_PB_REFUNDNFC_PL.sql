CREATE OR REPLACE PROCEDURE SP_PB_REFUNDNFC
(
    p_SESSIONID  varchar2, -- Session ID
    p_STATE char, -- '1'  Approved, '2' Rejected
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
    v_statecode     char(1);
    v_CARDNO         CHAR(16);
    v_TRADECODE     char(1);
    v_seqNo        char(16);

BEGIN
    --�ж��Ƿ���������Ҫ����
    SELECT COUNT(*) INTO v_quantity FROM TMP_COMMON WHERE f1 = p_SESSIONID;
    IF v_quantity is null or v_quantity <= 0 THEN
        p_retCode := 'A004P01001'; p_retMsg  := 'û���κ�������Ҫ����';
        RETURN;
    END IF;
    


  BEGIN
    FOR V_CUR IN (SELECT f0 FROM TMP_COMMON WHERE f1 = p_sessionId)
    LOOP
    v_TRADEID:=V_CUR.f0;
    --��ѯ�˿�״̬
    SELECT REFUNDSTATUS,CARDNO INTO v_statecode,v_CARDNO FROM TF_SUPPLY_REFUND WHERE TRADEID  = v_TRADEID ;

    IF  p_STATE='1' THEN

      v_TRADECODE:='1';
      --����������˿�ļ�¼
        IF v_statecode = '1' THEN
            p_retCode := 'S094570231';
            p_retMsg :=V_CUR.f0||'��ֵ������ˮ�Ѿ������˿�,�������ٴβ���' ;
        RETURN;
        END IF;

    END IF;

    IF p_STATE='2'  THEN

       v_TRADECODE:='2';
        --����в������˿�ļ�¼
        IF v_statecode = '2' THEN
            p_retCode := 'S094570232';
           p_retMsg :=V_CUR.f0||'��ֵ������ˮ�Ѿ��������˿�,�������ٴβ���' ;
       RETURN;
        END IF;
    END IF;

		 --���³�ֵ�˿��        
    BEGIN
        UPDATE TF_SUPPLY_REFUND
        SET    REFUNDSTATUS     = p_STATE,
               CHECKSTAFF       = p_currOper,
               CHECKTIME        = v_today
        WHERE  REFUNDSTATUS     = v_statecode
        AND    TRADEID =v_TRADEID;

        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S004P03B02'; p_retMsg  := '���³�ֵ�˿��ʧ��,' || SQLERRM;
            ROLLBACK; RETURN;
    END;
   --������ˮ��
    SP_GetSeq(seq => v_seqNo); 
		  --��¼�˿���˲���̨�ʱ�
    BEGIN
        INSERT INTO TF_F_REFUNDTRADE(ID,TRADEID, CARDNO, TRADECODE, PRESTATE, UPDATESTAFFNO,UPDATEDEPARTID, UPDATETIME)
        VALUES(v_seqNo,v_TRADEID,v_CARDNO,v_TRADECODE,v_statecode, p_currOper    ,p_currDept, V_TODAY);
        
        IF  SQL%ROWCOUNT !=1 THEN RAISE v_ex; END IF;
    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S004P03B03'; p_retMsg  := '��¼�˿���˲���̨�ʱ�ʧ��,' || SQLERRM;
            ROLLBACK; RETURN;
    END;

		
		
		
		END LOOP;
		
   		
		
	END;
    
 
    p_retCode := '0000000000'; p_retMsg  := '';
    COMMIT; RETURN;
END;
/

show errors

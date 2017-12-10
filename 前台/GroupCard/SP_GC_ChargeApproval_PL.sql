CREATE OR REPLACE PROCEDURE SP_GC_ChargeApproval
(
    p_batchNo   char, -- Batch Number
    p_stateCode char, -- '1' Approved, '3' Rejected
    p_currOper  char, -- Current Operator
    p_currDept  char, -- Current Operator's Department
    p_retCode       out char, -- Return Code
    p_retMsg        out varchar2  -- Return Message
)
AS
    v_today         date := sysdate;
    v_amount        int;
    v_ex            EXCEPTION;
	v_quantity		INT;

BEGIN

    -- 1) Check the state code 
    IF NOT (p_stateCode = '1' OR p_stateCode = '3') THEN
        p_retCode := 'A004P05B01'; p_retMsg  := '״̬�������''1'' (ͨ��)����''3'' (����)';
        RETURN;
    END IF;

    BEGIN    
        SELECT  AMOUNT INTO v_amount FROM TF_GROUP_SUPPLYSUM WHERE ID = p_batchNo;  
    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S004P05BX1'; p_retMsg  := '��ֵ����̨�ʱ��в�������ָ�����κŵļ�¼,' || SQLERRM;
            ROLLBACK; RETURN;
    END;
	
	
    --��ֵ���˻����С��0�������ύ
	if(p_stateCode='1')then
	FOR v_curser IN(
		SELECT CARDNO,SUPPLYMONEY FROM TF_GROUP_SUPPLY
            WHERE ID = p_batchNo
	)
	LOOP
		BEGIN
			select t.OFFERMONEY+v_curser.SUPPLYMONEY 
			into v_quantity   
			from TF_F_CARDOFFERACC t  
			where t.cardno=v_curser.CardNo
			and usetag in ('1','2');
			if v_quantity<0 THEN
			p_retCode := 'SWDXP04B03'; p_retMsg  :=v_curser.cardno|| '��ֵ��������˻����С��0';
				ROLLBACK; RETURN;
			end if;
		EXCEPTION
			WHEN OTHERS THEN
            p_retCode := 'SWDXP05BX1'; p_retMsg  := v_curser.CardNo||'������˻�������' || SQLERRM;
            ROLLBACK; RETURN;
		END;
		
	END LOOP;
	end if;
	
	
    -- 2) Update the charge master record's state
    BEGIN
        UPDATE TF_GROUP_SUPPLYSUM
        SET    CHECKSTAFFNO  = p_currOper ,
               CHECKDEPARTNO = p_currDept ,
               CHECKTIME     = v_today ,
               STATECODE     = p_stateCode
        WHERE  ID            = p_batchNo
        AND    STATECODE     = '0';
        
        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S004P05B02'; p_retMsg  := '�����������ֵ����̨��ʧ��,' || SQLERRM;
            ROLLBACK; RETURN;
    END;

    -- 3) Update the charge detail records' state
    BEGIN
        UPDATE TF_GROUP_SUPPLY
        SET    STATECODE      = p_stateCode,
               OPERATESTAFFNO = p_currOper ,
               OPERATEDEPARTID= p_currDept ,
               OPERATETIME    = v_today
        WHERE  ID             = p_batchNo
        AND    STATECODE     = '0';
        
        IF  SQL%ROWCOUNT != v_amount THEN RAISE v_ex; END IF;
    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S004P05B03'; p_retMsg  := '�����������ֵ��ϸ̨��ʧ��,' || SQLERRM;
            ROLLBACK; RETURN;
    END;
        

    -- 4) Copy the approved detail records to finance table
    IF  p_stateCode = '1' THEN
        BEGIN
            INSERT INTO TF_GROUP_SUPPLYCHECK(ID    , CARDNO, CORPNO    , SUPPLYMONEY , STATECODE,
            OPERATESTAFFNO, OPERATEDEPARTID,OPERATETIME)
            SELECT ID    , CARDNO, CORPNO    , SUPPLYMONEY , STATECODE,
            OPERATESTAFFNO, OPERATEDEPARTID,OPERATETIME FROM TF_GROUP_SUPPLY
            WHERE ID = p_batchNo;
        
            IF  SQL%ROWCOUNT != v_amount THEN RAISE v_ex; END IF;
        EXCEPTION
            WHEN OTHERS THEN
                p_retCode := 'S004P05B04'; p_retMsg  := '���������������ϸ̨��ʧ��,' || SQLERRM;
                ROLLBACK; RETURN;
        END;
    END IF;

    p_retCode := '0000000000'; p_retMsg  := '';
    COMMIT; RETURN;
END;
/

show errors

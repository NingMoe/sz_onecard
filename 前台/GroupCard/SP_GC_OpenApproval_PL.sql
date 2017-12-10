CREATE OR REPLACE PROCEDURE SP_GC_OpenApproval
(
    p_batchNo   char, -- Batch Number
    p_stateCode char, -- '1' Approved, '3' Rejected
    p_currOper  char, -- Current Operator
    p_currDept  char, -- Current Operator's Department
    p_retCode   out char, -- Return Code
    p_retMsg    out varchar2  -- Return Message
)
AS
    v_today         date := sysdate;
    v_ex            EXCEPTION;
    v_statecode     char(1);
BEGIN

    -- 1) Check the state code 
    IF NOT (p_stateCode = '1' OR p_stateCode = '3') THEN
        p_retCode := 'A004P02B01'; p_retMsg  := '״̬�������''1'' (ͨ��) ��''3'' (����)';
        RETURN;
    END IF;
	
	BEGIN
		--��ѯ����״̬
		SELECT STATECODE INTO v_statecode FROM TF_GROUP_SELLSUM WHERE ID = p_batchNo ;
		
	EXCEPTION
        WHEN NO_DATA_FOUND THEN
            p_retCode := 'S094570228'; p_retMsg  := 'δ�ҵ���Ч���������������,' || SQLERRM;
            ROLLBACK; RETURN;	
	END;
	--�������ͨ��
	IF v_statecode = '1' THEN
		p_retCode := 'S094570225'; p_retMsg  := p_batchNo||'���ο���������Ѿ�����ͨ��' ;
		RETURN;
	END IF;
	--����������ͨ��
	IF v_statecode = '2' THEN
		p_retCode := 'S094570226'; p_retMsg  := p_batchNo||'���ο���������Ѿ��������ͨ��' ;
		RETURN;
	END IF;
	--�������
	IF v_statecode = '3' THEN
		p_retCode := 'S094570227'; p_retMsg  := p_batchNo||'���ο���������Ѿ�����' ;
		RETURN;
	END IF;

    -- 2) Update the master record's state
    BEGIN
        UPDATE TF_GROUP_SELLSUM
        SET    CHECKSTAFFNO  = p_currOper ,
               CHECKDEPARTNO = p_currDept ,
               CHECKTIME     = v_today    ,
               STATECODE     = p_stateCode
        WHERE  ID            = p_batchNo
        AND    STATECODE     = '0';
        
        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S004P02B02'; p_retMsg  := '�����������������̨��ʧ��,' || SQLERRM;
            ROLLBACK; RETURN;
    END;

    p_retCode := '0000000000';
    p_retMsg  := '';
    COMMIT; RETURN;
END;
/

show errors


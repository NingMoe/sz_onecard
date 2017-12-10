CREATE OR REPLACE PROCEDURE SP_PB_GIFTASSIGNEDCHANGE
(
    P_SESSIONID         VARCHAR2,  --sessionid
    P_ASSIGNEDSTAFFNO   CHAR    ,
    P_ASSIGNEDDEPARTID  CHAR    ,
    p_currOper          char    ,
    p_currDept          char    ,
    p_retCode       out char    ,  -- Return Code
    p_retMsg        out varchar2   -- Return Message  
)
AS 
    v_seqNo              CHAR(16)       ;
    v_CARDNO             CHAR(16)       ;
	v_OLDASSIGNEDSTAFFNO CHAR(6)        ;
    V_EX                 EXCEPTION      ;
    V_TODAY              DATE := SYSDATE;
/*
--  ��������
--  ���α�д
--  ʯ��
--  2013-01-29
*/
BEGIN
    FOR cur IN (SELECT CARDNO,OLDASSIGNEDSTAFFNO FROM TMP_ASSIGNEDCHANGE) LOOP
        v_CARDNO := cur.CARDNO;
		v_OLDASSIGNEDSTAFFNO := cur.OLDASSIGNEDSTAFFNO;
		
        --����IC������
        BEGIN
            UPDATE TL_R_ICUSER
            SET    ASSIGNEDSTAFFNO  = P_ASSIGNEDSTAFFNO ,
                   ASSIGNEDDEPARTID = P_ASSIGNEDDEPARTID 
            WHERE  CARDNO = v_CARDNO;
        IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
        EXCEPTION WHEN OTHERS THEN
            p_retCode := 'S094570279';
            p_retMsg  := '����IC������ʧ��,'|| SQLERRM;
            ROLLBACK; RETURN;            
        END;
        
        --��ȡ��ˮ��
        SP_GetSeq(seq => v_seqNo);
        
        --��¼���ҵ��̨�ʱ�
        BEGIN
            INSERT INTO TF_B_TRADE_CASHGIFT 
                (TRADEID, CARDNO, TRADETYPECODE, OPERATESTAFFNO, OPERATEDEPARTID, OPERATETIME,OLDASSIGNEDSTAFFNO,ASSIGNEDSTAFFNO)
            VALUES(v_seqNo, v_CARDNO, '57', p_currOper, p_currDept, v_today,v_OLDASSIGNEDSTAFFNO,P_ASSIGNEDSTAFFNO);
            IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
            EXCEPTION WHEN OTHERS THEN
                p_retCode := 'S094570280';
                p_retMsg  := '��¼���ҵ��̨�ʱ�ʧ��,'|| SQLERRM;
                ROLLBACK; RETURN;            
        END;   
    END LOOP;
    p_retCode := '0000000000';
    p_retMsg  := '';
    COMMIT; RETURN;	
END;

/
show errors
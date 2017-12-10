CREATE OR REPLACE PROCEDURE SP_GC_RETURNORDER
(
    p_ORDERNO           CHAR,  --������
    p_HASAPPROVAL       CHAR,  --�Ƿ������
    p_currOper          char    ,
    p_currDept          char    ,
    p_retCode       out char    ,  -- Return Code
    p_retMsg        out varchar2   -- Return Message  
)
AS
    v_seqNo              CHAR(16); --ҵ����ˮ��
    V_FROMCARDNO         CHAR(14);
    V_TOCARDNO           CHAR(14);
    V_VALUECODE          CHAR(1);
    V_NUMBER             INT;
    V_ORDERSTATE         CHAR(2);
    V_EX                 EXCEPTION;
    V_TODAY              DATE := SYSDATE;
    V_TRADEID            CHAR(16);
BEGIN
    --��ѯ����״̬
    SELECT ORDERSTATE INTO V_ORDERSTATE FROM TF_F_ORDERFORM WHERE ORDERNO = p_ORDERNO;
    
    --���¶�����
    BEGIN
        UPDATE TF_F_ORDERFORM
        SET    ORDERSTATE = '00' , --�޸���
               CUSTOMERACCHASMONEY = 0,
               FINANCEAPPROVERNO = '',
               FINANCEAPPROVERTIME = '',
               FINANCEREMARK = '',
               ASSIGNSTAFFNO = '',
               ASSIGNTIME = '',
               ISRELATED = '',
               UPDATEDEPARTNO = p_currDept,
               UPDATESTAFFNO = p_currOper,
               UPDATETIME = V_TODAY
        WHERE  ORDERNO = p_ORDERNO;
        IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S094570320';
        p_retMsg  := '���¶�����ʧ��,'|| SQLERRM;
        ROLLBACK; RETURN;            
    END;
    
    --�������𿨶�����ϸ��
    BEGIN
        UPDATE TF_F_CASHGIFTORDER 
        SET    LEFTQTY = COUNT
        WHERE  ORDERNO = p_ORDERNO;
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S094570321';
        p_retMsg  := '�������𿨶�����ϸ��ʧ��,'|| SQLERRM;
        ROLLBACK; RETURN;            
    END;
    
    --���³�ֵ��������ϸ��
    BEGIN
        UPDATE TF_F_CHARGECARDORDER 
        SET    LEFTQTY = COUNT
        WHERE  ORDERNO = p_ORDERNO;
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S094570322';
        p_retMsg  := '���³�ֵ��������ϸ��ʧ��,'|| SQLERRM;
        ROLLBACK; RETURN;            
    END;
    
    --��������B��������ϸ��
    BEGIN
        UPDATE TF_F_SZTCARDORDER
        SET    LEFTQTY = COUNT
        WHERE  ORDERNO = p_ORDERNO;
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S094570323';
        p_retMsg  := '��������B��������ϸ��ʧ��,'|| SQLERRM;
        ROLLBACK; RETURN;            
    END;
	
    --���¶�����������ϸ��
    BEGIN
        UPDATE TF_F_READERORDER
        SET    LEFTQTY = COUNT
        WHERE  ORDERNO = p_ORDERNO;
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S094570349';
        p_retMsg  := '���¶�����������ϸ��ʧ��,'|| SQLERRM;
        ROLLBACK; RETURN;            
    END;	
    
    --������ˮ��
    SP_GetSeq(seq => v_seqNo);    
    
    IF p_HASAPPROVAL = '1' THEN --����Ѿ����ͨ����ȡ����Ƭ������ϵ���˵�������ϵ
        --�����ƿ�̨��
        BEGIN
            UPDATE TF_F_ORDERTRADE
            SET    CANCELTAG = '1' ,
                   CANCELTRADEID = v_seqNo
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
        
        --ȡ������B��������ϵ
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
        
        V_TRADEID := v_seqNo;
        for v_c in(SELECT A.CHECKID,A.MONEY FROM TF_F_ORDERCHECKRELATION A WHERE A.ORDERNO = p_ORDERNO)
        LOOP
            --��¼�˵�̨�˱�
            BEGIN
                INSERT INTO TF_B_CHECK(
                    TRADEID   , CHECKID     , TRADECODE , MONEY     , USEDMONEY   , LEFTMONEY   , OPERATESTAFFNO , OPERATETIME
                )SELECT 
                    V_TRADEID , v_c.CHECKID , '5'       , v_c.MONEY , B.USEDMONEY , B.LEFTMONEY , p_currOper     , V_TODAY
                FROM TF_F_CHECK B
                WHERE v_c.CHECKID = B.CHECKID;
            EXCEPTION WHEN OTHERS THEN
                p_retCode := 'S094570328';
                p_retMsg  := '��¼�˵�̨�˱�ʧ��,'|| SQLERRM;
                ROLLBACK; RETURN;            
            END;
            
            --������ˮ��
            SP_GetSeq(seq => V_TRADEID);    
        END LOOP;
        
        --�����˵���
        BEGIN
            MERGE INTO TF_F_CHECK T
            USING(SELECT CHECKID,MONEY FROM TF_F_ORDERCHECKRELATION WHERE ORDERNO = p_ORDERNO) A
            ON (T.CHECKID = A.CHECKID)
            WHEN MATCHED THEN UPDATE SET 
                 USEDMONEY = USEDMONEY - A.MONEY ,
                 LEFTMONEY = LEFTMONEY + A.MONEY ,
                 CHECKSTATE = '2';
        EXCEPTION WHEN OTHERS THEN
            p_retCode := 'S094570329';
            p_retMsg  := '�����˵���ʧ��,'|| SQLERRM;
            ROLLBACK; RETURN;            
        END;    
        
        --�����˵���
        BEGIN
            MERGE INTO TF_F_CHECK T
            USING(SELECT CHECKID FROM TF_F_ORDERCHECKRELATION WHERE ORDERNO = p_ORDERNO) A
            ON (T.CHECKID = A.CHECKID AND T.MONEY = 0)
            WHEN MATCHED THEN UPDATE SET 
                 CHECKSTATE = '1';
        EXCEPTION WHEN OTHERS THEN
            p_retCode := 'S094570329';
            p_retMsg  := '�����˵���ʧ��,'|| SQLERRM;
            ROLLBACK; RETURN;            
        END; 
        
        --�������˵���ϵ����ʷ��
        BEGIN
            INSERT INTO TH_F_ORDERCHECKRELATION 
                (ORDERNO,CHECKID,TRADEID,MONEY,UPDATESTAFFNO,UPDATETIME)
            SELECT 
                ORDERNO,CHECKID,TRADEID,MONEY,UPDATESTAFFNO,UPDATETIME
            FROM TF_F_ORDERCHECKRELATION 
            WHERE ORDERNO = p_ORDERNO;
        EXCEPTION WHEN OTHERS THEN
            p_retCode := 'S094570330';
            p_retMsg  := '�������˵���ϵ����ʷ��ʧ��,'|| SQLERRM;
            ROLLBACK; RETURN;            
        END;        
        
        --ȡ���������˵���ϵ
        BEGIN
            DELETE FROM TF_F_ORDERCHECKRELATION WHERE ORDERNO = p_ORDERNO;
        EXCEPTION WHEN OTHERS THEN
            p_retCode := 'S094570331';
            p_retMsg  := 'ȡ���������˵���ϵʧ��,'|| SQLERRM;
            ROLLBACK; RETURN;            
        END;  
    END IF;    
    
    --��¼����̨�˱�
    BEGIN
        INSERT INTO TF_F_ORDERTRADE(
            TRADEID    , ORDERNO         , ORDERSTATE     , TRADECODE    , 
            MONEY      , OPERATEDEPARTNO , OPERATESTAFFNO , OPERATETIME
        )SELECT 
            v_seqNo    , p_ORDERNO       , V_ORDERSTATE   , '04'         , 
            TOTALMONEY , p_currDept      , p_currOper     , V_TODAY
        FROM TF_F_ORDERFORM 
        WHERE ORDERNO = p_ORDERNO
        ;    
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S094570332';
        p_retMsg  := '��¼����̨�˱�ʧ��,'|| SQLERRM;
        ROLLBACK; RETURN;            
    END;
    
    p_retCode := '0000000000'; 
    p_retMsg  := '�ɹ�';
    COMMIT; RETURN;      
END;

/
show errors
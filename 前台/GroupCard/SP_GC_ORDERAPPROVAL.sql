CREATE OR REPLACE PROCEDURE SP_GC_ORDERAPPROVAL
(
    P_SESSIONID         VARCHAR2,  --sessionid
    P_FINANCEREMARK     VARCHAR2,  --����������
    p_ISAPPROVE         CHAR    ,  --�Ƿ������
    p_currOper          char    ,
    p_currDept          char    ,
    p_retCode       out char    ,  -- Return Code
    p_retMsg        out varchar2   -- Return Message  
)
AS 
    v_seqNo              CHAR(16); --ҵ����ˮ��
    V_ORDERNO            CHAR(16); --������
    V_CHECKID            CHAR(16); --�˵���
    V_ORDERMONEY         INT;      --�����ܽ��
    V_ORDERLEFTMONEY     INT;      --����ʣ��δƥ����
    V_CHECKMONEY         INT;      --�˵��ܽ��
    V_CHECKUSEDMONEY     INT;      --�˵���ʹ�ý��
    V_CHECKLEFTMONEY     INT;      --�˵�ʣ����
    V_TRADEMONEY         INT;      --���׽��
    V_CHECKSTATE         CHAR(1);  --�˵�״̬
    V_ACCOUNTNAME        VARCHAR2(100);--�Է�����
    V_ACCOUNTNUMBER      VARCHAR2(30);--�Է��˺�
    V_COUNT              INT;
    V_ORDERSTATE         CHAR(2);   --����״̬
    V_EX                 EXCEPTION;
    V_TODAY              DATE := SYSDATE;
/*
--  �����������
--  ���α�д
--  ʯ��
--  2013-03-26
*/
BEGIN
    --��������
    FOR cur IN (SELECT F2 FROM TMP_ORDER WHERE F0 = P_SESSIONID AND F1 = '0') LOOP
        V_ORDERNO := cur.F2;
        --��ѯ����״̬�ж��Ƿ���δ���״̬
        SELECT ORDERSTATE INTO V_ORDERSTATE FROM TF_F_ORDERFORM WHERE ORDERNO = V_ORDERNO;
        IF V_ORDERSTATE<>'01' THEN
         p_retCode := 'S094570300';
                    p_retMsg := '������Ϊ'||V_ORDERNO||'�Ķ�����Ϊδ���״̬';
                   ROLLBACK;  RETURN; 
        END IF;
        
        --����ʣ��δƥ���ֵ
        SELECT TOTALMONEY INTO V_ORDERLEFTMONEY FROM TF_F_ORDERFORM WHERE ORDERNO = V_ORDERNO;
        
        --���¶�����
        BEGIN
            UPDATE TF_F_ORDERFORM
            SET    ORDERSTATE = '02',
                   FINANCEAPPROVERNO = p_currOper,
                   FINANCEAPPROVERTIME = V_TODAY,
                   FINANCEREMARK = P_FINANCEREMARK,
                   UPDATEDEPARTNO = p_currDept,
                   UPDATESTAFFNO = p_currOper,
                   UPDATETIME = V_TODAY
            WHERE  ORDERNO = V_ORDERNO;    
        IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
        EXCEPTION WHEN OTHERS THEN
            p_retCode := 'S094570308';
            p_retMsg  := '���¶�����ʧ��,'|| SQLERRM;
            ROLLBACK; RETURN;            
        END;
        IF p_ISAPPROVE <> '1' THEN --������ǳ���������������˵�
            --�����˵�
            FOR cur IN (SELECT F2 FROM TMP_ORDER WHERE F0 = P_SESSIONID AND F1 = '1') LOOP
                V_CHECKID := cur.F2;
                --��ѯ�˵�����ʹ�ý����Է��ʺš��Է�����
                SELECT MONEY,USEDMONEY,LEFTMONEY,ACCOUNTNAME,ACCOUNTNUMBER INTO V_CHECKMONEY,V_CHECKUSEDMONEY,V_CHECKLEFTMONEY,V_ACCOUNTNAME,V_ACCOUNTNUMBER FROM TF_F_CHECK WHERE CHECKID = V_CHECKID;
                --����˵���� != ��ʹ�ý�� + ����ʾ����
                IF V_CHECKLEFTMONEY + V_CHECKUSEDMONEY <> V_CHECKMONEY THEN
                    p_retCode := 'S094570309';
                    p_retMsg := '���˵���ʹ�ý����������ܽ���ȷ��' ;
                    RETURN;            
                END IF;
                
                --�������Ҫ����С�ڵ����˵����
                IF V_ORDERLEFTMONEY <= V_CHECKLEFTMONEY THEN
                    IF V_ORDERLEFTMONEY = V_CHECKLEFTMONEY THEN
                        V_CHECKSTATE := '3'; --���ʹ��
                    ELSE
                        V_CHECKSTATE := '2'; --����ʹ��
                    END IF;
                    --�����˵���
                    BEGIN
                        UPDATE TF_F_CHECK 
                        SET    CHECKSTATE = V_CHECKSTATE,
                               USEDMONEY = V_CHECKUSEDMONEY + V_ORDERLEFTMONEY,
                               LEFTMONEY = V_CHECKLEFTMONEY - V_ORDERLEFTMONEY,
                               UPDATEDEPARTNO = p_currDept,
                               UPDATESTAFFNO = p_currOper,
                               UPDATETIME = V_TODAY
                        WHERE  CHECKID = V_CHECKID;
                    IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
                    EXCEPTION WHEN OTHERS THEN
                        p_retCode := 'S094570310';
                        p_retMsg  := '�����˵���ʧ��,'|| SQLERRM;
                        ROLLBACK; RETURN;            
                    END;                
                    
                    V_TRADEMONEY := V_ORDERLEFTMONEY;
                    --����ʣ����Ϊ0
                    V_ORDERLEFTMONEY := 0;
                ELSE --�������Ҫ��������˵����
                    --�����˵���
                    BEGIN
                        UPDATE TF_F_CHECK 
                        SET    CHECKSTATE = '3', --���ʹ��
                               USEDMONEY = V_CHECKMONEY, --���ý������˵����
                               LEFTMONEY = 0, --ʣ����Ϊ0
                               UPDATEDEPARTNO = p_currDept,
                               UPDATESTAFFNO = p_currOper,
                               UPDATETIME = V_TODAY
                        WHERE  CHECKID = V_CHECKID;
                    IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
                    EXCEPTION WHEN OTHERS THEN
                        p_retCode := 'S094570311';
                        p_retMsg  := '�����˵���ʧ��,'|| SQLERRM;
                        ROLLBACK; RETURN;            
                    END;
                    --���׽�ֵ
                    V_TRADEMONEY := V_CHECKLEFTMONEY;
                    --���㶩��ʣ��δ��ɽ��
                    V_ORDERLEFTMONEY := V_ORDERLEFTMONEY - V_CHECKLEFTMONEY;
                END IF;
                
                --������ˮ��
                SP_GetSeq(seq => v_seqNo); 
                --��¼�������˵�������ϵ��
                BEGIN
                    INSERT INTO TF_F_ORDERCHECKRELATION(
                        ORDERNO   , CHECKID   , TRADEID , MONEY            , UPDATESTAFFNO , UPDATETIME
                    )VALUES(
                        V_ORDERNO , V_CHECKID , v_seqNo , V_TRADEMONEY , p_currOper    , V_TODAY
                    );
                IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
                EXCEPTION WHEN OTHERS THEN
                    p_retCode := 'S094570312';
                    p_retMsg  := '��¼�������˵�������ϵ��ʧ��,'|| SQLERRM;
                    ROLLBACK; RETURN;            
                END;
                BEGIN
                	SELECT COUNT(*) INTO V_COUNT FROM TF_F_COMBUYCARDREG T WHERE T.REMARK = V_ORDERNO;
                  
                	IF V_COUNT>0 THEN 
                	--���µ�λ������¼��
                	BEGIN
                		UPDATE TF_F_COMBUYCARDREG 
                		SET OUTBANK = v_ACCOUNTNUMBER,--ת�������ʺ�
                		    OUTACCT = V_ACCOUNTNAME--ת���˻�����
                		WHERE REMARK = V_ORDERNO;
                		 IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
                    EXCEPTION WHEN OTHERS THEN
                        p_retCode := 'S094570311';
                        p_retMsg  := '���µ�λ������¼��ʧ��,'|| SQLERRM;
                        ROLLBACK; RETURN; 
                	END;
                  END IF;
                	
                END;
                --��¼����̨��
                BEGIN
                    INSERT INTO TF_F_ORDERTRADE(
                        TRADEID , ORDERNO   ,TRADECODE , MONEY        , OPERATEDEPARTNO , OPERATESTAFFNO , OPERATETIME
                    )VALUES(
                        v_seqNo , V_ORDERNO ,'05'      , V_TRADEMONEY , p_currDept      , p_currOper     , V_TODAY
                    );
                IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
                EXCEPTION WHEN OTHERS THEN
                    p_retCode := 'S094570313';
                    p_retMsg  := '��¼����̨��ʧ��,'|| SQLERRM;
                    ROLLBACK; RETURN;            
                END;
                --��¼�˵�̨��
                BEGIN
                    INSERT INTO TF_B_CHECK(
                        TRADEID , CHECKID   , TRADECODE , MONEY        , USEDMONEY        , LEFTMONEY        , OPERATESTAFFNO , OPERATETIME
                    )VALUES(
                        v_seqNo , V_CHECKID , '4'       , V_TRADEMONEY , V_CHECKUSEDMONEY , V_CHECKLEFTMONEY , p_currOper     , V_TODAY
                    );
                IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
                EXCEPTION WHEN OTHERS THEN
                    p_retCode := 'S094570314';
                    p_retMsg  := '��¼�˵�̨��ʧ��,'|| SQLERRM;
                    ROLLBACK; RETURN;            
                END;
                IF V_ORDERLEFTMONEY <= 0 THEN
                    EXIT;
                END IF;
            END LOOP; --�����˵�����
        ELSE --����ǳ�������������¼����̨��
            --������ˮ��
            SP_GetSeq(seq => v_seqNo); 
                
            --��¼����̨��
            BEGIN
                INSERT INTO TF_F_ORDERTRADE(
                    TRADEID , ORDERNO   ,TRADECODE , MONEY            , OPERATEDEPARTNO , OPERATESTAFFNO , OPERATETIME
                )VALUES(
                    v_seqNo , V_ORDERNO ,'05'      , V_ORDERLEFTMONEY , p_currDept      , p_currOper     , V_TODAY
                );
            IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
            EXCEPTION WHEN OTHERS THEN
                p_retCode := 'S094570313';
                p_retMsg  := '��¼����̨��ʧ��,'|| SQLERRM;
                ROLLBACK; RETURN;            
            END;        
        END IF;
        
        IF V_ORDERLEFTMONEY > 0 AND p_ISAPPROVE <> '1' THEN
                p_retCode := 'S094570315';
                p_retMsg := '�˵�����' ;
                ROLLBACK;RETURN;            
        END IF;
        
    END LOOP;--������������
    p_retCode := '0000000000';
    p_retMsg  := '�ɹ�';
    COMMIT; RETURN;    
END;

/
show errors    
    
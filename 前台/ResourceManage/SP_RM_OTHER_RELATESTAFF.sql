CREATE OR REPLACE PROCEDURE SP_RM_OTHER_RELATESTAFF
(
    P_SESSIONID         VARCHAR2,  --sessionid
    P_SIGNINMAINTAINID  CHAR,      --������
    p_currOper          char    ,
    p_currDept          char    ,
    p_retCode       out char    ,  -- Return Code
    p_retMsg        out varchar2   -- Return Message  
)
AS 
    v_seqNo              CHAR(16); --ҵ����ˮ��
    V_SIGNINSHEETID      CHAR(18); --ǩ������
    V_COUNT              INT;
    V_STAFFNAME          VARCHAR2(50);
    V_SIGNINTIME         DATE;
    V_EX                 EXCEPTION;
    V_TODAY              DATE := SYSDATE;

BEGIN
    --����
    FOR cur IN (SELECT F0 FROM TMP_COMMON WHERE F1 = P_SESSIONID ) LOOP
        V_SIGNINSHEETID := cur.F0;
        --�ж�ά�������Ƿ��Ѿ�������ǩ����
        SELECT COUNT(*) INTO V_COUNT FROM TF_F_STAFFMAINTAINRELATION WHERE SIGNINMAINTAINID=P_SIGNINMAINTAINID AND SIGNINSHEETID=V_SIGNINSHEETID;                                                      

        IF V_COUNT>0 THEN
         p_retCode := 'S094570300';
                    p_retMsg := 'ǩ������Ϊ'||V_SIGNINSHEETID||'�Ѿ�������ά������'||P_SIGNINMAINTAINID||',�����ظ�����';
                   ROLLBACK;  RETURN; 
        END IF;
        
        select t.staffname,t.signintime into V_STAFFNAME,V_SIGNINTIME from TF_F_STAFFSIGNINSHEET t where t.signinsheetid=V_SIGNINSHEETID;
        --���빤��ǩ��������
        BEGIN
          INSERT INTO TF_F_STAFFMAINTAINRELATION(SIGNINMAINTAINID ,SIGNINSHEETID)                                              
          VALUES(P_SIGNINMAINTAINID  ,V_SIGNINSHEETID);  
          
          IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
        EXCEPTION WHEN OTHERS THEN
            p_retCode := 'S094570307';
            p_retMsg  := '���빤��ǩ��������ʧ��,'|| SQLERRM;
            ROLLBACK; RETURN;                                              

        END;
        
        --����Ա��ǩ����
        BEGIN
            UPDATE  TF_F_STAFFSIGNINSHEET T                    
            SET     T.STATE='1'                  
            WHERE   T.SIGNINSHEETID=V_SIGNINSHEETID;                    
    
        IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
        EXCEPTION WHEN OTHERS THEN
            p_retCode := 'S094570308';
            p_retMsg  := '����Ա��ǩ����ʧ��,'|| SQLERRM;
            ROLLBACK; RETURN;            
        END;
        
        --���¹�����
        BEGIN
            UPDATE  TF_F_STAFFMAINTAIN T                    
            SET     T.RELATEDSTATE='1',t.staffname=V_STAFFNAME,t.signintime=V_SIGNINTIME                 
            WHERE   T.SIGNINMAINTAINID=P_SIGNINMAINTAINID;                    
    
        IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
        EXCEPTION WHEN OTHERS THEN
            p_retCode := 'S094570309';
            p_retMsg  := '���¹�����ʧ��,'|| SQLERRM;
            ROLLBACK; RETURN;            
        END;
        
        

    END LOOP;
    p_retCode := '0000000000';
    p_retMsg  := '�ɹ�';
    COMMIT; RETURN;    
END;

 
    

/
show errors    
    
CREATE OR REPLACE PROCEDURE SP_RM_OTHER_RELATESTAFF
(
    P_SESSIONID         VARCHAR2,  --sessionid
    P_SIGNINMAINTAINID  CHAR,      --工单号
    p_currOper          char    ,
    p_currDept          char    ,
    p_retCode       out char    ,  -- Return Code
    p_retMsg        out varchar2   -- Return Message  
)
AS 
    v_seqNo              CHAR(16); --业务流水号
    V_SIGNINSHEETID      CHAR(18); --签到单号
    V_COUNT              INT;
    V_STAFFNAME          VARCHAR2(50);
    V_SIGNINTIME         DATE;
    V_EX                 EXCEPTION;
    V_TODAY              DATE := SYSDATE;

BEGIN
    --遍历
    FOR cur IN (SELECT F0 FROM TMP_COMMON WHERE F1 = P_SESSIONID ) LOOP
        V_SIGNINSHEETID := cur.F0;
        --判断维护单号是否已经关联此签到单
        SELECT COUNT(*) INTO V_COUNT FROM TF_F_STAFFMAINTAINRELATION WHERE SIGNINMAINTAINID=P_SIGNINMAINTAINID AND SIGNINSHEETID=V_SIGNINSHEETID;                                                      

        IF V_COUNT>0 THEN
         p_retCode := 'S094570300';
                    p_retMsg := '签到单号为'||V_SIGNINSHEETID||'已经关联到维护单号'||P_SIGNINMAINTAINID||',不可重复关联';
                   ROLLBACK;  RETURN; 
        END IF;
        
        select t.staffname,t.signintime into V_STAFFNAME,V_SIGNINTIME from TF_F_STAFFSIGNINSHEET t where t.signinsheetid=V_SIGNINSHEETID;
        --插入工单签到关联表
        BEGIN
          INSERT INTO TF_F_STAFFMAINTAINRELATION(SIGNINMAINTAINID ,SIGNINSHEETID)                                              
          VALUES(P_SIGNINMAINTAINID  ,V_SIGNINSHEETID);  
          
          IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
        EXCEPTION WHEN OTHERS THEN
            p_retCode := 'S094570307';
            p_retMsg  := '插入工单签到关联表失败,'|| SQLERRM;
            ROLLBACK; RETURN;                                              

        END;
        
        --更新员工签到表
        BEGIN
            UPDATE  TF_F_STAFFSIGNINSHEET T                    
            SET     T.STATE='1'                  
            WHERE   T.SIGNINSHEETID=V_SIGNINSHEETID;                    
    
        IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
        EXCEPTION WHEN OTHERS THEN
            p_retCode := 'S094570308';
            p_retMsg  := '更新员工签到表失败,'|| SQLERRM;
            ROLLBACK; RETURN;            
        END;
        
        --更新工单表
        BEGIN
            UPDATE  TF_F_STAFFMAINTAIN T                    
            SET     T.RELATEDSTATE='1',t.staffname=V_STAFFNAME,t.signintime=V_SIGNINTIME                 
            WHERE   T.SIGNINMAINTAINID=P_SIGNINMAINTAINID;                    
    
        IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
        EXCEPTION WHEN OTHERS THEN
            p_retCode := 'S094570309';
            p_retMsg  := '更新工单表失败,'|| SQLERRM;
            ROLLBACK; RETURN;            
        END;
        
        

    END LOOP;
    p_retCode := '0000000000';
    p_retMsg  := '成功';
    COMMIT; RETURN;    
END;

 
    

/
show errors    
    
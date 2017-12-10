/*
	专有账户批量开户财务审核
*/
CREATE OR REPLACE PROCEDURE SP_CA_OpenFiApproval
(
    p_sessionId  varchar2, -- Session ID
    p_stateCode  char, -- '2' Fi Approved, '3' Rejected
    P_PWD        varchar2,
    p_currOper   char,
    p_currDept   char,
    p_retCode    out char, -- Return Code
    p_retMsg     out varchar2  -- Return Message
)
AS
    v_today         date := sysdate;
    v_quantity      INT;
    v_batchQty      INT;
    v_ex            EXCEPTION;
    V_AMOUNT        INT;
    V_COUNT         INT;
    V_CORPNO        CHAR(4);
    V_ACCID         NUMBER;
	V_PASSWORD		varchar2(32);
BEGIN
    -- 1) Check the state code 
    IF NOT (p_stateCode = '2' OR p_stateCode = '3') THEN
        p_retCode := 'A004P03B01'; p_retMsg  := '状态码必须是''2'' (财务审核通过) or ''3'' (作废)';
        RETURN;
    END IF;

    -- 2) Update the tracing record
    SELECT COUNT(*) INTO v_batchQty FROM TMP_GC_BatchNoList WHERE SessionId = p_sessionId;
    IF v_batchQty is null or v_batchQty <= 0 THEN
        p_retCode := 'A004P01BX1'; p_retMsg  := '没有任何开户数据需要处理';
        RETURN;
    END IF;
    
    SELECT  SUM(AMOUNT) INTO v_quantity FROM TF_GROUP_SELLSUM
    WHERE ID IN 
        (SELECT BatchNo FROM TMP_GC_BatchNoList WHERE SessionId = p_sessionId);    
    IF v_quantity is null or v_quantity <= 0 THEN
        p_retCode := 'A004P01BX1'; p_retMsg  := '没有任何开户数据需要处理';
        RETURN;
    END IF;
    
    BEGIN
        UPDATE TF_GROUP_SELLSUM    
        SET EXAMSTAFFNO = p_currOper, 
            EXAMTIME    = v_today   , 
            STATECODE   = p_stateCode 
        WHERE STATECODE = '1'
        AND ID IN 
            (SELECT BatchNo FROM TMP_GC_BatchNoList WHERE SessionId = p_sessionId);
            
        IF  SQL%ROWCOUNT != v_batchQty THEN RAISE v_ex; END IF;
    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S004P03B02'; p_retMsg  := '更新企服卡开户总量台帐失败,' || SQLERRM;
            ROLLBACK; RETURN;
    END;
    
    -- 3) Update the finance detail records' state
  BEGIN
    UPDATE TF_F_OPENCHECK
       SET STATECODE       = P_STATECODE,
           OPERATESTAFFNO  = P_CURROPER,
           OPERATEDEPARTID = P_CURRDEPT,
           OPERATETIME     = V_TODAY
     WHERE ID IN (SELECT BATCHNO
                    FROM TMP_GC_BATCHNOLIST
                   WHERE SESSIONID = P_SESSIONID)
       AND STATECODE = '1';

    IF SQL%ROWCOUNT != V_AMOUNT THEN
      RAISE V_EX;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      P_RETCODE := 'S006014013';
      P_RETMSG := '更新专有账户开户财务明细失败,' || SQLERRM;
      ROLLBACK;
      RETURN;
  END;

    IF p_stateCode = '3'  THEN -- Rejected By Finance
    		-- Rejected By Finance
		    BEGIN
		      UPDATE TF_F_OPENACC
		         SET STATECODE       = P_STATECODE,
		             OPERATESTAFFNO  = P_CURROPER,
		             OPERATEDEPARTID = P_CURRDEPT,
		             OPERATETIME     = V_TODAY
		       WHERE ID IN (SELECT BATCHNO
		                      FROM TMP_GC_BatchNoList
		                     WHERE SESSIONID = P_SESSIONID)
		       AND STATECODE = '1';
		
		      IF SQL%ROWCOUNT != V_AMOUNT THEN
		        RAISE V_EX;
		      END IF;
		    EXCEPTION
		      WHEN OTHERS THEN
		        P_RETCODE := 'S006014014';
		        P_RETMSG := '更新专有帐户批量开户明细失败,' || SQLERRM;
		        ROLLBACK;
		        RETURN;
		    END;
    ELSE
    	-- Approved, update the accounts' balance
	    BEGIN
              FOR V_CURSOR IN (
                                SELECT 
                                FI.ID,
                                FI.CARDNO, 
                                FI.ACCTYPE, 
                                FI.CUSTNAME,
                                FI.CUSTBIRTH,
                                FI.PAPERTYPECODE,
                                FI.PAPERNO,
                                FI.CUSTSEX,
                                FI.CUSTPHONE,
                                FI.CUSTTELPHONE ,
                                FI.CUSTPOST,
                                FI.CUSTADDR ,
                                FI.CUSTEMAIL
                                FROM TF_F_OPENCHECK FI
                                WHERE FI.ID IN
                                      (SELECT BATCHNO
                                       FROM TMP_GC_BatchNoList
                                       WHERE SESSIONID = P_SESSIONID))
              LOOP
			  
				V_PASSWORD:='';
				--获取用户老账户密码
				BEGIN
				SELECT CUST_PASSWORD INTO V_PASSWORD FROM 
				(SELECT CUST_PASSWORD FROM TF_F_CUST_ACCT T WHERE ICCARD_NO = V_CURSOR.CARDNO ORDER BY CREATE_DATE)
				WHERE ROWNUM = 1;
				EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
				END;
					
				IF V_PASSWORD ='' or V_PASSWORD is null THEN
					V_PASSWORD := P_PWD;
				END IF;
				
                      --开户
                      SP_CA_OPENACC(V_CURSOR.CARDNO,
                                    V_CURSOR.ACCTYPE,
                                    V_CURSOR.CUSTNAME,
                                    V_CURSOR.CUSTBIRTH,	
                                    V_CURSOR.PAPERTYPECODE,
                                    V_CURSOR.PAPERNO,
                                    V_CURSOR.CUSTSEX,
                                    V_CURSOR.CUSTPHONE,
                                    V_CURSOR.CUSTTELPHONE,
                                    V_CURSOR.CUSTPOST,
                                    V_CURSOR.CUSTADDR,
                                    V_CURSOR.CUSTEMAIL,
                                    '0',
                                    V_PASSWORD,
                                    0,
                                    0,
                                    P_CURROPER,
                                    P_CURRDEPT,
                                    P_RETCODE,
                                    P_RETMSG);
                      IF p_retCode != '0000000000' THEN
                          ROLLBACK; RETURN;
                      END IF;
                      
      	              BEGIN
		                      --写账户和集团客户关系表
		                      SELECT CORPNO INTO V_CORPNO FROM TF_GROUP_SELLSUM WHERE ID = V_CURSOR.ID;
		                      SELECT ACCT_ID INTO V_ACCID FROM TF_F_CUST_ACCT TD 
		                      WHERE TD.ICCARD_NO = V_CURSOR.CARDNO AND TD.ACCT_TYPE_NO = V_CURSOR.ACCTYPE;
		                      BEGIN
		                             INSERT INTO TD_GROUP_ACCT(ACCT_ID, CORPNO, USETAG)
		                             VALUES (V_ACCID, V_CORPNO, '1');
		                             EXCEPTION
		                             WHEN OTHERS THEN
		                                  p_retCode := 'S004P03B03'; p_retMsg  := '新增卡片与集团客户关联关系失败,' || SQLERRM;
		                                  ROLLBACK; RETURN;
		                      END;
		                      EXCEPTION
		                         WHEN NO_DATA_FOUND THEN
		                               p_retCode := 'S004P03B07'; p_retMsg  := '未找到集团客户代码或者客户账户信息,' || SQLERRM;
		                               ROLLBACK; RETURN;
		                         WHEN OTHERS THEN
		                         			 p_retCode := 'S004P03B08'; p_retMsg  :=  SQLERRM;
		                               ROLLBACK; RETURN;
                      END;
                      
              END LOOP;
      	      
            EXCEPTION
              WHEN OTHERS THEN
                P_RETCODE := p_retCode;
                P_RETMSG := p_retCode || '专有帐户批量开户失败,' || SQLERRM;
                ROLLBACK;
                RETURN;
	    END;
    END IF;
    
    p_retCode := '0000000000'; p_retMsg  := '';
    COMMIT; RETURN;
    
END;
/

show errors

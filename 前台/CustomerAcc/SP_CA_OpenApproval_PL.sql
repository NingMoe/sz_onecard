CREATE OR REPLACE PROCEDURE SP_CA_OpenApproval
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
    V_AMOUNT 				INT;

BEGIN

    -- 1) Check the state code 
    IF NOT (p_stateCode = '1' OR p_stateCode = '3') THEN
        p_retCode := 'A004P02B01'; p_retMsg  := '状态码必须是''1'' (通过) 或''3'' (作废)';
        RETURN;
    END IF;
    
    BEGIN
		    SELECT AMOUNT INTO V_AMOUNT FROM TF_GROUP_SELLSUM WHERE ID = P_BATCHNO;
			  EXCEPTION
			    WHEN OTHERS THEN
			      P_RETCODE := 'S006012013';
			      P_RETMSG := '充值总量台帐表中不存在所指定批次号的记录,' || SQLERRM;
			      ROLLBACK;
			      RETURN;
  	END;
    
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
            p_retCode := 'S004P02B02'; p_retMsg  := '更新企服卡开户总量台帐失败,' || SQLERRM;
            ROLLBACK; RETURN;
    END;
    
    -- 3) Update the charge detail records' state
	  BEGIN
	    UPDATE TF_F_OPENACC
	       SET STATECODE       = P_STATECODE,
	           OPERATESTAFFNO  = P_CURROPER,
	           OPERATEDEPARTID = P_CURRDEPT,
	           OPERATETIME     = V_TODAY
	     WHERE ID = P_BATCHNO
	       AND STATECODE = '0';
	  
	    IF SQL%ROWCOUNT != V_AMOUNT THEN
	      RAISE V_EX;
	    END IF;
	  EXCEPTION
	    WHEN OTHERS THEN
	      P_RETCODE := 'S006012015';
	      P_RETMSG := '更新专有帐户批量充值明细台帐失败,' || SQLERRM;
	      ROLLBACK;
	      RETURN;
	  END;

  -- 4) Copy the approved detail records to finance table
  IF P_STATECODE = '1' THEN
    BEGIN
      INSERT INTO TF_F_OPENCHECK
        (ID,
	       CARDNO,
	       ACCTYPE,
	       STATECODE,
	       CUSTNAME,
	       CUSTBIRTH,
	       PAPERTYPECODE,
	       PAPERNO,
	       CUSTSEX,
	       CUSTPHONE,
	       CUSTTELPHONE,
	       CUSTPOST,
	       CUSTADDR,
	       CUSTEMAIL,
	       OPERATESTAFFNO,
	       OPERATEDEPARTID,
	       OPERATETIME
	       )
        SELECT ID,
	       CARDNO,
	       ACCTYPE,
	       STATECODE,
	       CUSTNAME,
	       CUSTBIRTH,
	       PAPERTYPECODE,
	       PAPERNO,
	       CUSTSEX,
	       CUSTPHONE,
	       CUSTTELPHONE,
	       CUSTPOST,
	       CUSTADDR,
	       CUSTEMAIL,
	       OPERATESTAFFNO,
	       OPERATEDEPARTID,
	       OPERATETIME
          FROM TF_F_OPENACC
         WHERE ID = P_BATCHNO;
    
	      IF SQL%ROWCOUNT != V_AMOUNT THEN
	        RAISE V_EX;
	      END IF;
		    EXCEPTION
		      WHEN OTHERS THEN
		        P_RETCODE := 'S006012016';
		        P_RETMSG := '新增专有帐户批量财务明细台帐失败,' || SQLERRM;
		        ROLLBACK;
		        RETURN;
    END;
  END IF;

    p_retCode := '0000000000';
    p_retMsg  := '';
    COMMIT; RETURN;
END;
/

show errors


--------------------------------------------------
--  其他资源-修改合同
--  初次编写
--  董翔
--  2012-12-7
--------------------------------------------------
CREATE OR REPLACE PROCEDURE SP_RM_EDITCONTRACT
(
	P_CONTRACTCODE				 CHAR      ,
	P_CONTRACTNAME      	 VARCHAR2  ,   
	P_CONTRACTID				   VARCHAR2  ,
	P_SIGNINGCOMPANY			 VARCHAR2  ,   
	P_SIGNINGDATE          VARCHAR2 ,
	P_CONTRACTDESC         VARCHAR2 ,
  P_DOCUMENTTYPE         VARCHAR2 ,
	p_currOper	           char     ,
	p_currDept	           char     ,
	p_retCode              out char     ,  -- Return Code
	p_retMsg               out varchar2    -- Return Message  
)
AS
    v_seqNo             CHAR(16)       ;
    V_EX                EXCEPTION      ;
    V_TODAY             DATE := SYSDATE;
BEGIN
	

	--记录合同表
	BEGIN
			UPDATE TL_R_CONTRACT SET																
			    CONTRACTNAME  =  P_CONTRACTNAME  , CONTRACTID =  P_CONTRACTID , SIGNINGCOMPANY = P_SIGNINGCOMPANY    ,																			
			    SIGNINGDATE = TO_DATE(P_SIGNINGDATE,'YYYYMMDD')  , CONTRACTDESC = P_CONTRACTDESC, 
			     UPDATESTAFFNO = p_currOper , UPDATETIME 	 = 	V_TODAY, DOCUMENTTYPE = P_DOCUMENTTYPE
			WHERE CONTRACTCODE = 	P_CONTRACTCODE;																													
			EXCEPTION
	    WHEN OTHERS THEN
	        p_retCode := 'SR00150002';
	        p_retMsg  := '修改合同失败'|| SQLERRM;
	        ROLLBACK; RETURN;   
	END;
	
	p_retCode := '0000000000';
	p_retMsg  := '成功';
	COMMIT; RETURN;    
END;

/
show errors

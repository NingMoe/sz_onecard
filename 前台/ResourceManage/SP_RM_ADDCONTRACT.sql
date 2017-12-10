--------------------------------------------------
--  其他资源-新增合同
--  初次编写
--  董翔
--  2012-12-7
--  2013-7-2 修改 增加文档类型
--------------------------------------------------
CREATE OR REPLACE PROCEDURE SP_RM_ADDCONTRACT
(
	P_CONTRACTNAME      	 VARCHAR2  ,   
	P_CONTRACTID				   VARCHAR2  ,
	P_SIGNINGCOMPANY			 VARCHAR2  ,   
	P_SIGNINGDATE          VARCHAR2 ,
	P_CONTRACTDESC         VARCHAR2 ,
	P_DOCUMENTTYPE         VARCHAR2 ,
	P_CONTRACTCODE				 OUT CHAR ,    
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
	
	
	--获取流水号
	SP_GetSeq(seq => P_CONTRACTCODE); 
	
	--记录合同表
	BEGIN
			INSERT INTO TL_R_CONTRACT(																			
			    CONTRACTCODE       , CONTRACTNAME    , CONTRACTID   , SIGNINGCOMPANY    ,																			
			    SIGNINGDATE           , CONTRACTDESC,  UPDATESTAFFNO , UPDATETIME    , DOCUMENTTYPE    																			
			)VALUES(																			
			    P_CONTRACTCODE            ,P_CONTRACTNAME    , P_CONTRACTID  ,P_SIGNINGCOMPANY  ,																			
			    TO_DATE(P_SIGNINGDATE,'YYYYMMDD')     , P_CONTRACTDESC  ,  p_currOper    ,   V_TODAY		, P_DOCUMENTTYPE																
			    );																			
			EXCEPTION
	    WHEN OTHERS THEN
	        p_retCode := 'SR00150001';
	        p_retMsg  := '新增合同失败'|| SQLERRM;
	        ROLLBACK; RETURN;   
	END;
	
	p_retCode := '0000000000';
	p_retMsg  := '成功';
	COMMIT; RETURN;    
END;

/
show errors

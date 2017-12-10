--------------------------------------------------
--  其他资源-删除合同
--  初次编写
--  董翔
--  2012-12-7
--------------------------------------------------
CREATE OR REPLACE PROCEDURE SP_RM_DELETECONTRACT
(
	P_CONTRACTCODE				 CHAR      ,
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
	
	
	 
	--删除合同表
	BEGIN
			DELETE TL_R_CONTRACT WHERE 	CONTRACTCODE = 		P_CONTRACTCODE;											
			EXCEPTION
	    WHEN OTHERS THEN
	        p_retCode := 'SR00150003';
	        p_retMsg  := '删除合同失败'|| SQLERRM;
	        ROLLBACK; RETURN;   
	END;
	
	p_retCode := '0000000000';
	p_retMsg  := '成功';
	COMMIT; RETURN;    
END;

/
show errors

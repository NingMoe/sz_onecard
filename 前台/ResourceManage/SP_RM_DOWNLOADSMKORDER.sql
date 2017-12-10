--下载市民卡订购单个人化文件
CREATE OR REPLACE PROCEDURE SP_RM_DOWNLOADSMKORDER
(
	P_CARDORDERID          CHAR     ,  --订购单号
	p_currOper	           char     ,
	p_currDept	           char     ,
	p_retCode          out char     ,  -- Return Code
	p_retMsg           out varchar2    -- Return Message  
)
AS
  
    V_EX        EXCEPTION      ;
 
BEGIN
	 
	BEGIN
	  --更新下载次数
		UPDATE TF_F_SMK_CARDORDER SET DOWNLOADNUM = NVL(DOWNLOADNUM,0) + 1
		WHERE CARDORDERID = P_CARDORDERID;
     EXCEPTION
       WHEN OTHERS THEN
         P_RETCODE := 'S094570100';
         P_RETMSG  := '更新市民卡订购单失败'||SQLERRM;      
         ROLLBACK; RETURN;      		       
	END;

  p_retCode := '0000000000';
  p_retMsg  := '成功';
  COMMIT; RETURN;    	
END;

/
show errors

create or replace procedure SP_RM_UPDATECONTRACTFILE
(
    p_retCode                 OUT VARCHAR2  ,
    p_retMsg                  OUT VARCHAR2  ,
   
    P_ID                 VARCHAR2      ,                    --消息ID
    P_FILENAME					 VARCHAR2      ,                    --附件名
    P_FILE               			BLOB                          --附件
)
as
    
begin
     --更新市民卡资料表图片
      BEGIN
      	UPDATE TL_R_CONTRACT SET CONTRACTFILE = P_FILE,CONTRACTFILENAME = P_FILENAME WHERE CONTRACTCODE = P_ID;
 				
				EXCEPTION WHEN OTHERS THEN
					p_retCode := 'SR00150004';
					p_retMsg :='保存扫描件失败'||SQLERRM;
					ROLLBACK;	RETURN;
      END;
  

    p_retCode := '0000000000'; p_retMsg  := '';
    COMMIT; RETURN;

end;
/
show error;

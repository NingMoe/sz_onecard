CREATE OR REPLACE PROCEDURE SP_PS_DeptBalApp_Cancel
(
    P_TRADEID         CHAR     ,
    P_CURROPER        CHAR     ,
    P_CURRDEPT        CHAR     ,
    P_RETCODE     OUT CHAR     ,
    P_RETMSG      OUT VARCHAR2
)
AS
    V_TODAY           DATE         := SYSDATE    ;
    V_EX              EXCEPTION                  ;
BEGIN
    BEGIN
        --更新网点结算单元业务台帐主表
	      UPDATE TF_B_DEPTBALTRADE													
		    SET		 STATECODE      =  '3'  ,    										
		    		   CHECKSTAFFNO   =  P_CURROPER ,										
		    		   CHECKDEPARTNO  =  P_CURRDEPT , 										
			   		   CHECKTIME      =  V_TODAY            										
	    	WHERE	 TRADEID        =  P_TRADEID  ;
		
        IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
    EXCEPTION WHEN OTHERS THEN
        P_RETCODE := 'S008108003';
        P_RETMSG  := '更新网点结算单元业务台帐主表失败'||SQLERRM;
    ROLLBACK;RETURN; 		
		END;
    p_retCode := '0000000000'; p_retMsg  := '成功';
    commit; return;	 
END;

/
show errors
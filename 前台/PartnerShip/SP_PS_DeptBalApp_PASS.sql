CREATE OR REPLACE PROCEDURE SP_PS_DeptBalApp_Pass
(
    P_TRADEID         CHAR     ,
    P_TRADETYPECODE   CHAR     ,
    P_DBALUNITNO      CHAR     ,
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
        --����������㵥Ԫҵ��̨������
	      UPDATE TF_B_DEPTBALTRADE													
		    SET		 STATECODE      =  '2'  ,    										
		    		   CHECKSTAFFNO   =  P_CURROPER ,										
		    		   CHECKDEPARTNO  =  P_CURRDEPT , 										
			   		   CHECKTIME      =  V_TODAY            										
	    	WHERE	 TRADEID        =  P_TRADEID  ;
		
        IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
    EXCEPTION WHEN OTHERS THEN
        P_RETCODE := 'S008108001';
        P_RETMSG  := '����������㵥Ԫҵ��̨������ʧ��'||SQLERRM;
    ROLLBACK;RETURN; 		
		END;
		BEGIN
		    --��¼������㵥Ԫҵ��̨����˱�
	      INSERT  INTO  TF_B_DEPTBALTRADE_EXAM(
		    		TRADEID         , DTRADETYPECODE  , ASSOCIATECODE  , OPERATESTAFFNO  ,
			    	OPERATEDEPARTID , OPERATETIME     , STATECODE											
	     )VALUES(
	          P_TRADEID       , P_TRADETYPECODE , P_DBALUNITNO   , P_CURROPER      ,
	          P_CURRDEPT      , V_TODAY         , '1'     );
	          
    EXCEPTION WHEN OTHERS THEN
        P_RETCODE := 'S008108002';
        P_RETMSG  := '��¼������㵥Ԫҵ��̨����˱�ʧ��'||SQLERRM;
        ROLLBACK;RETURN;	      
	  END;
	  
    p_retCode := '0000000000'; p_retMsg  := '�ɹ�';
    commit; return;	  
END;	      						
						
/
show errors												


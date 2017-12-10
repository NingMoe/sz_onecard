CREATE OR REPLACE PROCEDURE SP_PS_DeptBalFiApp_Pass
(
    P_TRADEID           CHAR     , --ҵ����ˮ��
    P_TRADETYPECODE     CHAR     , --�������ͱ���
    P_DBALUNITNO        CHAR     , --������㵥Ԫ����
    P_DBALUNIT          VARCHAR2 , --������㵥Ԫ����
    P_BANKCODE          CHAR     , --�������б���
    P_BANKACCNO         VARCHAR2 , --���������˺�
    P_BALCYCLETYPECODE  CHAR     , --�����������ͱ���
    P_BALINTERVAL       INT      , --�������ڿ��
    P_FINCYCLETYPECODE  CHAR     , --�����������ͱ���
    P_FININTERVAL       INT      , --�������ڿ��
    P_FINTYPECODE       CHAR     , --ת�����ͱ���
    P_FINBANKCODE       CHAR     , --ת�����б���
    P_LINKMAN           VARCHAR2 , --��ϵ��
    P_UNITPHONE         VARCHAR2 , --��ϵ�˵绰
    P_UNITADD           VARCHAR2 , --��ϵ�˵�ַ
    P_UNITEMAIL         VARCHAR2 , --EMAIL��ַ
    --P_USETAG          CHAR     , --��Ч��־
    P_DEPTTYPE          CHAR     , --�������ͱ���
    P_PREPAYWARNLINE    INT      , --Ԥ����Ԥ��ֵ
    P_PREPAYLIMITLINE   INT      , --Ԥ�������ֵ
    P_REMARK            VARCHAR2 , --��ע
    P_CURROPER          CHAR     ,
    P_CURRDEPT          CHAR     ,
    P_RETCODE       OUT CHAR     ,
    P_RETMSG        OUT VARCHAR2
)
AS
    V_TRADETYPECODE   VARCHAR2(2) := P_TRADETYPECODE ;
    V_ID              VARCHAR2(8)                    ;
    V_BEGINTIME       DATE                           ;
    V_ENDTIME         DATE                           ;
    V_TODAY           DATE        := SYSDATE         ;
    V_EX              EXCEPTION                      ;
    V_QUANTITY        INT                            ;
	V_DBALUNITKEY     CHAR(16)                       ;
BEGIN
    IF V_TRADETYPECODE='01' THEN --������㵥Ԫ��Ϣ����
		    BEGIN
				 IF P_DEPTTYPE = '2' THEN 
					SELECT SUBSTR(SYS_GUID(),-16) INTO V_DBALUNITKEY FROM DUAL;
				 END IF;
			  --����㵥Ԫ�����������һ�����㵥Ԫ��Ϣ
				INSERT INTO TF_DEPT_BALUNIT(
						  DBALUNITNO         , DBALUNIT          , BANKCODE           , BANKACCNO         , CREATETIME    , 									
						  BALCYCLETYPECODE   , BALINTERVAL       , FINCYCLETYPECODE   , FININTERVAL       , FINTYPECODE   , 									
						  FINBANKCODE        , LINKMAN           , UNITPHONE          , UNITADD           , UNITEMAIL     , 
						  USETAG             , DEPTTYPE          , PREPAYWARNLINE     , PREPAYLIMITLINE   , UPDATESTAFFNO , 
						  UPDATETIME         , REMARK			 , DBALUNITKEY						
			)VALUES(											
						  P_DBALUNITNO       , P_DBALUNIT        , P_BANKCODE         , P_BANKACCNO       , V_TODAY       ,
						  P_BALCYCLETYPECODE , P_BALINTERVAL     , P_FINCYCLETYPECODE , P_FININTERVAL     , P_FINTYPECODE , 									
						  P_FINBANKCODE      , P_LINKMAN         , P_UNITPHONE        , P_UNITADD         , P_UNITEMAIL   , 
						  '1'                , P_DEPTTYPE        , P_PREPAYWARNLINE   , P_PREPAYLIMITLINE , P_CURROPER    , 
						  V_TODAY            , P_REMARK			 , V_DBALUNITKEY);
		    EXCEPTION WHEN OTHERS THEN
		        P_RETCODE := 'S008109001';
		        P_RETMSG  := '��¼���㵥Ԫ�����ʧ��'||SQLERRM;
		        ROLLBACK;RETURN;	      
			  END;								
				BEGIN				
			  --��������㵥ԪԤ�����˻�������һ����¼																									
				INSERT INTO TF_F_DEPTBAL_PREPAY(
				      DBALUNITNO    , PREPAY     , ACCSTATECODE,
						  UPDATESTAFFNO , UPDATETIME )
				VALUES											
					   (P_DBALUNITNO , 0          , '01'  , 									
					    P_CURROPER   , V_TODAY    );									
		    EXCEPTION WHEN OTHERS THEN
		        P_RETCODE := 'S008109011';
		        P_RETMSG  := '��¼������㵥ԪԤ�����˻���ʧ��'||SQLERRM;
		        ROLLBACK;RETURN;	      
			  END;																																				
				BEGIN
			  --��������㵥Ԫ��֤�������һ����¼																									
				INSERT INTO TF_F_DEPTBAL_DEPOSIT											
						 (DBALUNITNO    , DEPOSIT    , USABLEVALUE  , STOCKVALUE , 
						  UPDATESTAFFNO , UPDATETIME , ACCSTATECODE )
				VALUES
						  (P_DBALUNITNO , 0          , 0            , 0          , 
						   P_CURROPER   , V_TODAY    , '01'   );									
		    EXCEPTION WHEN OTHERS THEN
		        P_RETCODE := 'S008109012';
		        P_RETMSG  := '��¼������㵥Ԫ��֤���ʧ��'||SQLERRM;
		        ROLLBACK;RETURN;	      
			  END;
        BEGIN
	      --��¼���ѽ�����Ϣ����¼���Ϣ																																									
				INSERT INTO TD_DEPT_BALEVENT(																			
					    ID             , DEVENTTYPECODE        , DBALUNITNO   ,
					    DEALSTATECODE1 , DEALSTATECODE2        , OCCURTIME 			   																		
			 )VALUES(																			
				      P_TRADEID      , '00'||V_TRADETYPECODE , P_DBALUNITNO , 
				      '0'            , '0'                   , V_TODAY
				      );										
		    EXCEPTION WHEN OTHERS THEN
		        P_RETCODE := 'S008109018';
		        P_RETMSG  := '��¼���ѽ�����Ϣ����¼���ʧ��'||SQLERRM;
		    ROLLBACK;RETURN;
		    END;				  
    END IF;
    
    IF V_TRADETYPECODE='02' THEN --������㵥Ԫ��Ϣ�����޸�
		    BEGIN
			  --���½��㵥Ԫ�����																							
				UPDATE TF_DEPT_BALUNIT								
				SET 	 DBALUNITNO       = P_DBALUNITNO,								
					     DBALUNIT         = P_DBALUNIT,								
						   BANKCODE         = P_BANKCODE,								
						   BANKACCNO        = P_BANKACCNO,								
						   BALCYCLETYPECODE = P_BALCYCLETYPECODE,								
						   BALINTERVAL      = P_BALINTERVAL,								
						   FINCYCLETYPECODE = P_FINCYCLETYPECODE,								
						   FININTERVAL      = P_FININTERVAL,								
						   FINTYPECODE      = P_FINTYPECODE,								
						   FINBANKCODE      = P_FINBANKCODE,								
						   LINKMAN          = P_LINKMAN,								
						   UNITPHONE        = P_UNITPHONE,								
						   UNITADD          = P_UNITADD,								
						   UNITEMAIL        = P_UNITEMAIL,								
						   DEPTTYPE         = P_DEPTTYPE,								
						   PREPAYWARNLINE   = P_PREPAYWARNLINE,								
						   PREPAYLIMITLINE  = P_PREPAYLIMITLINE,								
						   UPDATESTAFFNO    = P_CURROPER,								
						   UPDATETIME       = V_TODAY,								
						   REMARK           = P_REMARK								
				WHERE  DBALUNITNO       = P_DBALUNITNO;								
		    IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
		    EXCEPTION WHEN OTHERS THEN
		        P_RETCODE := 'S008109003';
		        P_RETMSG  := '����������㵥Ԫ�����ʧ��'||SQLERRM;
		    ROLLBACK;RETURN;
		    END;
        BEGIN
	      --��¼���ѽ�����Ϣ����¼���Ϣ																																									
				INSERT INTO TD_DEPT_BALEVENT(																			
					    ID             , DEVENTTYPECODE        , DBALUNITNO   ,
					    DEALSTATECODE1 , DEALSTATECODE2        , OCCURTIME 			   																		
			 )VALUES(																			
				      P_TRADEID      , '00'||V_TRADETYPECODE , P_DBALUNITNO , 
				      '0'            , '0'                   , V_TODAY
				      );
		    EXCEPTION WHEN OTHERS THEN
		        P_RETCODE := 'S008109018';
		        P_RETMSG  := '��¼���ѽ�����Ϣ����¼���ʧ��'||SQLERRM;
		    ROLLBACK;RETURN;
		    END;			    
    END IF;
    
    IF V_TRADETYPECODE='03' THEN --������㵥Ԫ��Ϣɾ��
		    BEGIN
			  --����������㵥Ԫ�����																						
				UPDATE TF_DEPT_BALUNIT								
				SET		 USETAG        = '0'        ,								
				   		 UPDATESTAFFNO = P_CURROPER ,								
					     UPDATETIME    = V_TODAY								
				WHERE	 DBALUNITNO    = P_DBALUNITNO;
		    IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
		    EXCEPTION WHEN OTHERS THEN
		        P_RETCODE := 'S008109003';
		        P_RETMSG  := '����������㵥Ԫ�����ʧ��'||SQLERRM;
		    ROLLBACK;RETURN;
		    END;									
		    BEGIN
			  --����������㵥Ԫ-Ӷ�𷽰���Ӧ��ϵ��																							
				UPDATE  TD_DEPTBAL_COMSCHEME										
				SET		  USETAG        = '0'        ,								
					   	  UPDATESTAFFNO = P_CURROPER ,								
						    UPDATETIME    = V_TODAY								
				WHERE	  DBALUNITNO    = P_DBALUNITNO;
		    EXCEPTION WHEN OTHERS THEN
		        P_RETCODE := 'S008109004';
		        P_RETMSG  := '����������㵥Ԫ-Ӷ�𷽰���Ӧ��ϵ��ʧ��'||SQLERRM;
		    ROLLBACK;RETURN;
		    END;																																	
		    BEGIN												
			  --���½��㵥Ԫ-�����Ӧ��ϵ��					
				UPDATE  TD_DEPTBAL_RELATION	
				SET		 USETAG        = '0'        ,								
					     UPDATESTAFFNO = P_CURROPER ,								
					     UPDATETIME    = V_TODAY								
				WHERE	 DBALUNITNO    = P_DBALUNITNO;
		    EXCEPTION WHEN OTHERS THEN
		        P_RETCODE := 'S008109005';
		        P_RETMSG  := '���½��㵥Ԫ-�����Ӧ��ϵ��ʧ��'||SQLERRM;
		    ROLLBACK;RETURN;
		    END;																								
				BEGIN										
			  --����Ԥ�����˻���				
				UPDATE TF_F_DEPTBAL_PREPAY										
				SET		 ACCSTATECODE  = '02'       ,								
					   	 UPDATESTAFFNO = P_CURROPER ,																				
					  	 UPDATETIME    = V_TODAY								
				WHERE	 DBALUNITNO    = P_DBALUNITNO;
		    IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
		    EXCEPTION WHEN OTHERS THEN
		        P_RETCODE := 'S008109006';
		        P_RETMSG  := '���¸���Ԥ�����˻���ʧ��'||SQLERRM;
		    ROLLBACK;RETURN;
		    END;																								
				BEGIN										
			  --���±�֤���˻���																							
				UPDATE  TF_F_DEPTBAL_DEPOSIT										
				SET	  	ACCSTATECODE   =  '02'      ,								
					     	UPDATESTAFFNO  = P_CURROPER ,								
					     	UPDATETIME     = V_TODAY								
				WHERE	  DBALUNITNO     = P_DBALUNITNO;
		    IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
		    EXCEPTION WHEN OTHERS THEN
		        P_RETCODE := 'S008109017';
		        P_RETMSG  := '���±�֤���˻���ʧ��'||SQLERRM;
		    ROLLBACK;RETURN;
		    END;	
        BEGIN
	      --��¼���ѽ�����Ϣ����¼���Ϣ																																									
				INSERT INTO TD_DEPT_BALEVENT(																			
					    ID             , DEVENTTYPECODE        , DBALUNITNO   ,
					    DEALSTATECODE1 , DEALSTATECODE2        , OCCURTIME 			   																		
			 )VALUES(																			
				      P_TRADEID      , '00'||V_TRADETYPECODE , P_DBALUNITNO , 
				      '0'            , '0'                   , V_TODAY
				      );
		    EXCEPTION WHEN OTHERS THEN
		        P_RETCODE := 'S008109018';
		        P_RETMSG  := '��¼���ѽ�����Ϣ����¼���ʧ��'||SQLERRM;
		    ROLLBACK;RETURN;
		    END;			    																							
    END IF;
    
    IF V_TRADETYPECODE='21' THEN --���㵥ԪӶ�𷽰�����
		    BEGIN    										
			  --�������ѽ��㵥Ԫ-Ӷ�𷽰������ϵ��Ϣ														  											
				INSERT INTO TD_DEPTBAL_COMSCHEME(										
					    ID          , DCOMSCHEMENO  , DBALUNITNO , TRADETYPECODE , 
					    CANCELTRADE , BEGINTIME     , ENDTIME    , REMARK				 ,
					    USETAG      , UPDATESTAFFNO , UPDATETIME		
			 )SELECT
			        ID          , DCOMSCHEMENO  , DBALUNITNO , TRADETYPECODE , 
			        CANCELTRADE , BEGINTIME     , ENDTIME    , REMARK			   ,  
			        '1'   			, P_CURROPER    , V_TODAY 
				FROM 	TH_DEPTBAL_COMSCHEME								
				WHERE TRADEID = P_TRADEID;
		    EXCEPTION WHEN OTHERS THEN
		        P_RETCODE := 'S008109013';
		        P_RETMSG  := '�������ѽ��㵥Ԫ-Ӷ�𷽰������ϵ��ʧ��'||SQLERRM;
		    ROLLBACK;RETURN;																    	
		    END;
    END IF;
    
    IF V_TRADETYPECODE='22' THEN --���㵥ԪӶ�𷽰��޸�		     
		    BEGIN
		    SELECT ID , BEGINTIME , ENDTIME INTO V_ID , V_BEGINTIME , V_ENDTIME
		    FROM   TH_DEPTBAL_COMSCHEME WHERE TRADEID = P_TRADEID ;
			  --����������㵥Ԫ-Ӷ�𷽰���Ӧ��ϵ����Ϣ																									
				UPDATE TD_DEPTBAL_COMSCHEME											
				SET		 BEGINTIME			=	V_BEGINTIME ,				
						   ENDTIME 				=	V_ENDTIME   ,		
						   UPDATESTAFFNO	=	P_CURROPER	,			
						   UPDATETIME			=	V_TODAY				
				WHERE  ID             = V_ID	      ;						
		    IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
		    EXCEPTION WHEN OTHERS THEN
		        P_RETCODE := 'S008109014';
		        P_RETMSG  := '����������㵥Ԫ-Ӷ�𷽰���Ӧ��ϵ��ʧ��'||SQLERRM;
		    ROLLBACK;RETURN;																			    	
		    END;
    END IF;
    IF V_TRADETYPECODE='23' THEN --���㵥ԪӶ�𷽰�ɾ��        
		    BEGIN
		    SELECT ID INTO V_ID FROM TH_DEPTBAL_COMSCHEME WHERE TRADEID = P_TRADEID ;
			  --����������㵥Ԫ-Ӷ�𷽰���Ӧ��ϵ����Ϣ
				UPDATE TD_DEPTBAL_COMSCHEME
				SET		 USETAG        = '0'        ,												
						   UPDATESTAFFNO = P_CURROPER	,	
						   UPDATETIME		 = V_TODAY	 						
				 WHERE ID            = V_ID;
		    IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
		    EXCEPTION WHEN OTHERS THEN
		        P_RETCODE := 'S008109015';
		        P_RETMSG  := '����������㵥Ԫ-Ӷ�𷽰���Ӧ��ϵ��ʧ��'||SQLERRM;
		    ROLLBACK;RETURN;																													    	
		    END;
    END IF;
    IF V_TRADETYPECODE='11' THEN --���㵥Ԫ�����ϵ����
		    BEGIN
		    --��¼���㵥Ԫ�����ϵ����Ϣ												
				INSERT INTO TD_DEPTBAL_RELATION(
							DEPARTNO , DBALUNITNO    ,								
							USETAG   , UPDATESTAFFNO , UPDATETIME  								
			 )SELECT
			        DEPARTNO , DBALUNITNO    ,								
						  USETAG   , UPDATESTAFFNO , UPDATETIME 
						  
				FROM  TH_DEPTBAL_RELATION								
				WHERE TRADEID = P_TRADEID;								
		    EXCEPTION WHEN OTHERS THEN
		        P_RETCODE := 'S008109016';
		        P_RETMSG  := '��¼���㵥Ԫ�����ϵ����Ϣʧ��'||SQLERRM;
		    ROLLBACK;RETURN;																						    	
		    END;
    END IF;

    IF V_TRADETYPECODE='13' THEN --���㵥Ԫ�����ϵɾ��
    	  --�жϽ��㵥Ԫ�Ƿ��ѽ���
    	  SELECT COUNT(*) INTO V_QUANTITY FROM TF_DEPTBALTRADE_BAL WHERE DBALUNITNO = P_DBALUNITNO;
        IF V_QUANTITY != 0 THEN --�ѽ���
		        P_RETCODE := 'S008109020';
		        P_RETMSG  := '������㵥Ԫ�ѽ��㣬����ɾ��';   
		    ROLLBACK;RETURN;          
		    ELSE --δ����
		    BEGIN
		    	--ɾ�����㵥Ԫ�����ϵ����Ϣ
		    	DELETE FROM TD_DEPTBAL_RELATION 
		    	WHERE  DBALUNITNO = P_DBALUNITNO
		    	AND    DEPARTNO   = (SELECT DEPARTNO FROM TH_DEPTBAL_RELATION WHERE TRADEID = P_TRADEID);
		    IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
		    EXCEPTION WHEN OTHERS THEN
		        P_RETCODE := 'S008109017';
		        P_RETMSG  := 'ɾ�����㵥Ԫ�����ϵ����Ϣʧ��'||SQLERRM;
		    ROLLBACK;RETURN;
		    END;
		    END IF;

    END IF;
		
	BEGIN
		--�������̨����Ϣ
		UPDATE TF_B_DEPTBALTRADE_EXAM								
		SET    STATECODE    = '2'        ,								
				   EXAMSTAFFNO  = P_CURROPER ,								
				   EXAMDEPARTNO = P_CURRDEPT ,								
				   EXAMKTIME    = V_TODAY    								
		WHERE	 TRADEID      = P_TRADEID  ;								
		IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
		EXCEPTION WHEN OTHERS THEN
			P_RETCODE := 'S008109019';
			P_RETMSG  := '�������̨�ʱ���Ϣʧ��'||SQLERRM;
		ROLLBACK;RETURN;									
	END;	

	
	IF V_TRADETYPECODE='21' OR  V_TRADETYPECODE='22' OR  V_TRADETYPECODE='23' THEN
	--��ɾ�Ľ��㵥��Ӷ�𷽰�ʱ�����½��㵥Ԫ�����ĸ���ʱ�䣬�Ա������߳丶ƽ̨���ݸ���ʱ��ͬ�����㵥Ԫ�����Ϣ
	BEGIN
		UPDATE  TF_DEPT_BALUNIT								
		SET 	UPDATESTAFFNO    = P_CURROPER,								
				UPDATETIME       = V_TODAY							
		WHERE  DBALUNITNO       = P_DBALUNITNO;								
	IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
	EXCEPTION WHEN OTHERS THEN
		P_RETCODE := 'S008109003';
		P_RETMSG  := '����������㵥Ԫ�����ʧ��'||SQLERRM;
	ROLLBACK;RETURN;
	END;   	
	
	END IF;
	
    p_retCode := '0000000000'; p_retMsg  := '�ɹ�';
    commit; return;	  
END;

/
show errors
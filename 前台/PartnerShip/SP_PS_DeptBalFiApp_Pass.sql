CREATE OR REPLACE PROCEDURE SP_PS_DeptBalFiApp_Pass
(
    P_TRADEID           CHAR     , --业务流水号
    P_TRADETYPECODE     CHAR     , --交易类型编码
    P_DBALUNITNO        CHAR     , --网点结算单元编码
    P_DBALUNIT          VARCHAR2 , --网点结算单元名称
    P_BANKCODE          CHAR     , --开户银行编码
    P_BANKACCNO         VARCHAR2 , --开户银行账号
    P_BALCYCLETYPECODE  CHAR     , --结算周期类型编码
    P_BALINTERVAL       INT      , --结算周期跨度
    P_FINCYCLETYPECODE  CHAR     , --划账周期类型编码
    P_FININTERVAL       INT      , --划账周期跨度
    P_FINTYPECODE       CHAR     , --转账类型编码
    P_FINBANKCODE       CHAR     , --转出银行编码
    P_LINKMAN           VARCHAR2 , --联系人
    P_UNITPHONE         VARCHAR2 , --联系人电话
    P_UNITADD           VARCHAR2 , --联系人地址
    P_UNITEMAIL         VARCHAR2 , --EMAIL地址
    --P_USETAG          CHAR     , --有效标志
    P_DEPTTYPE          CHAR     , --网点类型编码
    P_PREPAYWARNLINE    INT      , --预付款预警值
    P_PREPAYLIMITLINE   INT      , --预付款最低值
    P_REMARK            VARCHAR2 , --备注
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
    IF V_TRADETYPECODE='01' THEN --网点结算单元信息增加
		    BEGIN
				 IF P_DEPTTYPE = '2' THEN 
					SELECT SUBSTR(SYS_GUID(),-16) INTO V_DBALUNITKEY FROM DUAL;
				 END IF;
			  --向结算单元编码表中增加一条结算单元信息
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
		        P_RETMSG  := '记录结算单元编码表失败'||SQLERRM;
		        ROLLBACK;RETURN;	      
			  END;								
				BEGIN				
			  --向网点结算单元预付款账户表增加一条记录																									
				INSERT INTO TF_F_DEPTBAL_PREPAY(
				      DBALUNITNO    , PREPAY     , ACCSTATECODE,
						  UPDATESTAFFNO , UPDATETIME )
				VALUES											
					   (P_DBALUNITNO , 0          , '01'  , 									
					    P_CURROPER   , V_TODAY    );									
		    EXCEPTION WHEN OTHERS THEN
		        P_RETCODE := 'S008109011';
		        P_RETMSG  := '记录网点结算单元预付款账户表失败'||SQLERRM;
		        ROLLBACK;RETURN;	      
			  END;																																				
				BEGIN
			  --向网点结算单元保证金表增加一条记录																									
				INSERT INTO TF_F_DEPTBAL_DEPOSIT											
						 (DBALUNITNO    , DEPOSIT    , USABLEVALUE  , STOCKVALUE , 
						  UPDATESTAFFNO , UPDATETIME , ACCSTATECODE )
				VALUES
						  (P_DBALUNITNO , 0          , 0            , 0          , 
						   P_CURROPER   , V_TODAY    , '01'   );									
		    EXCEPTION WHEN OTHERS THEN
		        P_RETCODE := 'S008109012';
		        P_RETMSG  := '记录网点结算单元保证金表失败'||SQLERRM;
		        ROLLBACK;RETURN;	      
			  END;
        BEGIN
	      --记录消费结算信息变更事件信息																																									
				INSERT INTO TD_DEPT_BALEVENT(																			
					    ID             , DEVENTTYPECODE        , DBALUNITNO   ,
					    DEALSTATECODE1 , DEALSTATECODE2        , OCCURTIME 			   																		
			 )VALUES(																			
				      P_TRADEID      , '00'||V_TRADETYPECODE , P_DBALUNITNO , 
				      '0'            , '0'                   , V_TODAY
				      );										
		    EXCEPTION WHEN OTHERS THEN
		        P_RETCODE := 'S008109018';
		        P_RETMSG  := '记录消费结算信息变更事件表失败'||SQLERRM;
		    ROLLBACK;RETURN;
		    END;				  
    END IF;
    
    IF V_TRADETYPECODE='02' THEN --网点结算单元信息资料修改
		    BEGIN
			  --更新结算单元编码表																							
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
		        P_RETMSG  := '更新网点结算单元编码表失败'||SQLERRM;
		    ROLLBACK;RETURN;
		    END;
        BEGIN
	      --记录消费结算信息变更事件信息																																									
				INSERT INTO TD_DEPT_BALEVENT(																			
					    ID             , DEVENTTYPECODE        , DBALUNITNO   ,
					    DEALSTATECODE1 , DEALSTATECODE2        , OCCURTIME 			   																		
			 )VALUES(																			
				      P_TRADEID      , '00'||V_TRADETYPECODE , P_DBALUNITNO , 
				      '0'            , '0'                   , V_TODAY
				      );
		    EXCEPTION WHEN OTHERS THEN
		        P_RETCODE := 'S008109018';
		        P_RETMSG  := '记录消费结算信息变更事件表失败'||SQLERRM;
		    ROLLBACK;RETURN;
		    END;			    
    END IF;
    
    IF V_TRADETYPECODE='03' THEN --网点结算单元信息删除
		    BEGIN
			  --更新网点结算单元编码表																						
				UPDATE TF_DEPT_BALUNIT								
				SET		 USETAG        = '0'        ,								
				   		 UPDATESTAFFNO = P_CURROPER ,								
					     UPDATETIME    = V_TODAY								
				WHERE	 DBALUNITNO    = P_DBALUNITNO;
		    IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
		    EXCEPTION WHEN OTHERS THEN
		        P_RETCODE := 'S008109003';
		        P_RETMSG  := '更新网点结算单元编码表失败'||SQLERRM;
		    ROLLBACK;RETURN;
		    END;									
		    BEGIN
			  --更新网点结算单元-佣金方案对应关系表																							
				UPDATE  TD_DEPTBAL_COMSCHEME										
				SET		  USETAG        = '0'        ,								
					   	  UPDATESTAFFNO = P_CURROPER ,								
						    UPDATETIME    = V_TODAY								
				WHERE	  DBALUNITNO    = P_DBALUNITNO;
		    EXCEPTION WHEN OTHERS THEN
		        P_RETCODE := 'S008109004';
		        P_RETMSG  := '更新网点结算单元-佣金方案对应关系表失败'||SQLERRM;
		    ROLLBACK;RETURN;
		    END;																																	
		    BEGIN												
			  --更新结算单元-网点对应关系表					
				UPDATE  TD_DEPTBAL_RELATION	
				SET		 USETAG        = '0'        ,								
					     UPDATESTAFFNO = P_CURROPER ,								
					     UPDATETIME    = V_TODAY								
				WHERE	 DBALUNITNO    = P_DBALUNITNO;
		    EXCEPTION WHEN OTHERS THEN
		        P_RETCODE := 'S008109005';
		        P_RETMSG  := '更新结算单元-网点对应关系表失败'||SQLERRM;
		    ROLLBACK;RETURN;
		    END;																								
				BEGIN										
			  --更新预付款账户表				
				UPDATE TF_F_DEPTBAL_PREPAY										
				SET		 ACCSTATECODE  = '02'       ,								
					   	 UPDATESTAFFNO = P_CURROPER ,																				
					  	 UPDATETIME    = V_TODAY								
				WHERE	 DBALUNITNO    = P_DBALUNITNO;
		    IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
		    EXCEPTION WHEN OTHERS THEN
		        P_RETCODE := 'S008109006';
		        P_RETMSG  := '更新更新预付款账户表失败'||SQLERRM;
		    ROLLBACK;RETURN;
		    END;																								
				BEGIN										
			  --更新保证金账户表																							
				UPDATE  TF_F_DEPTBAL_DEPOSIT										
				SET	  	ACCSTATECODE   =  '02'      ,								
					     	UPDATESTAFFNO  = P_CURROPER ,								
					     	UPDATETIME     = V_TODAY								
				WHERE	  DBALUNITNO     = P_DBALUNITNO;
		    IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
		    EXCEPTION WHEN OTHERS THEN
		        P_RETCODE := 'S008109017';
		        P_RETMSG  := '更新保证金账户表失败'||SQLERRM;
		    ROLLBACK;RETURN;
		    END;	
        BEGIN
	      --记录消费结算信息变更事件信息																																									
				INSERT INTO TD_DEPT_BALEVENT(																			
					    ID             , DEVENTTYPECODE        , DBALUNITNO   ,
					    DEALSTATECODE1 , DEALSTATECODE2        , OCCURTIME 			   																		
			 )VALUES(																			
				      P_TRADEID      , '00'||V_TRADETYPECODE , P_DBALUNITNO , 
				      '0'            , '0'                   , V_TODAY
				      );
		    EXCEPTION WHEN OTHERS THEN
		        P_RETCODE := 'S008109018';
		        P_RETMSG  := '记录消费结算信息变更事件表失败'||SQLERRM;
		    ROLLBACK;RETURN;
		    END;			    																							
    END IF;
    
    IF V_TRADETYPECODE='21' THEN --结算单元佣金方案增加
		    BEGIN    										
			  --增加消费结算单元-佣金方案对象关系信息														  											
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
		        P_RETMSG  := '增加消费结算单元-佣金方案对象关系表失败'||SQLERRM;
		    ROLLBACK;RETURN;																    	
		    END;
    END IF;
    
    IF V_TRADETYPECODE='22' THEN --结算单元佣金方案修改		     
		    BEGIN
		    SELECT ID , BEGINTIME , ENDTIME INTO V_ID , V_BEGINTIME , V_ENDTIME
		    FROM   TH_DEPTBAL_COMSCHEME WHERE TRADEID = P_TRADEID ;
			  --更新网点结算单元-佣金方案对应关系表信息																									
				UPDATE TD_DEPTBAL_COMSCHEME											
				SET		 BEGINTIME			=	V_BEGINTIME ,				
						   ENDTIME 				=	V_ENDTIME   ,		
						   UPDATESTAFFNO	=	P_CURROPER	,			
						   UPDATETIME			=	V_TODAY				
				WHERE  ID             = V_ID	      ;						
		    IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
		    EXCEPTION WHEN OTHERS THEN
		        P_RETCODE := 'S008109014';
		        P_RETMSG  := '更新网点结算单元-佣金方案对应关系表失败'||SQLERRM;
		    ROLLBACK;RETURN;																			    	
		    END;
    END IF;
    IF V_TRADETYPECODE='23' THEN --结算单元佣金方案删除        
		    BEGIN
		    SELECT ID INTO V_ID FROM TH_DEPTBAL_COMSCHEME WHERE TRADEID = P_TRADEID ;
			  --更新网点结算单元-佣金方案对应关系表信息
				UPDATE TD_DEPTBAL_COMSCHEME
				SET		 USETAG        = '0'        ,												
						   UPDATESTAFFNO = P_CURROPER	,	
						   UPDATETIME		 = V_TODAY	 						
				 WHERE ID            = V_ID;
		    IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
		    EXCEPTION WHEN OTHERS THEN
		        P_RETCODE := 'S008109015';
		        P_RETMSG  := '更新网点结算单元-佣金方案对应关系表失败'||SQLERRM;
		    ROLLBACK;RETURN;																													    	
		    END;
    END IF;
    IF V_TRADETYPECODE='11' THEN --结算单元网点关系增加
		    BEGIN
		    --记录结算单元网点关系表信息												
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
		        P_RETMSG  := '记录结算单元网点关系表信息失败'||SQLERRM;
		    ROLLBACK;RETURN;																						    	
		    END;
    END IF;

    IF V_TRADETYPECODE='13' THEN --结算单元网点关系删除
    	  --判断结算单元是否已结算
    	  SELECT COUNT(*) INTO V_QUANTITY FROM TF_DEPTBALTRADE_BAL WHERE DBALUNITNO = P_DBALUNITNO;
        IF V_QUANTITY != 0 THEN --已结算
		        P_RETCODE := 'S008109020';
		        P_RETMSG  := '网点结算单元已结算，不可删除';   
		    ROLLBACK;RETURN;          
		    ELSE --未结算
		    BEGIN
		    	--删除结算单元网点关系表信息
		    	DELETE FROM TD_DEPTBAL_RELATION 
		    	WHERE  DBALUNITNO = P_DBALUNITNO
		    	AND    DEPARTNO   = (SELECT DEPARTNO FROM TH_DEPTBAL_RELATION WHERE TRADEID = P_TRADEID);
		    IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
		    EXCEPTION WHEN OTHERS THEN
		        P_RETCODE := 'S008109017';
		        P_RETMSG  := '删除结算单元网点关系表信息失败'||SQLERRM;
		    ROLLBACK;RETURN;
		    END;
		    END IF;

    END IF;
		
	BEGIN
		--更新审核台帐信息
		UPDATE TF_B_DEPTBALTRADE_EXAM								
		SET    STATECODE    = '2'        ,								
				   EXAMSTAFFNO  = P_CURROPER ,								
				   EXAMDEPARTNO = P_CURRDEPT ,								
				   EXAMKTIME    = V_TODAY    								
		WHERE	 TRADEID      = P_TRADEID  ;								
		IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
		EXCEPTION WHEN OTHERS THEN
			P_RETCODE := 'S008109019';
			P_RETMSG  := '更新审核台帐表信息失败'||SQLERRM;
		ROLLBACK;RETURN;									
	END;	

	
	IF V_TRADETYPECODE='21' OR  V_TRADETYPECODE='22' OR  V_TRADETYPECODE='23' THEN
	--增删改结算单用佣金方案时，更新结算单元编码表的更新时间，以便于在线充付平台根据更新时间同步结算单元相关信息
	BEGIN
		UPDATE  TF_DEPT_BALUNIT								
		SET 	UPDATESTAFFNO    = P_CURROPER,								
				UPDATETIME       = V_TODAY							
		WHERE  DBALUNITNO       = P_DBALUNITNO;								
	IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
	EXCEPTION WHEN OTHERS THEN
		P_RETCODE := 'S008109003';
		P_RETMSG  := '更新网点结算单元编码表失败'||SQLERRM;
	ROLLBACK;RETURN;
	END;   	
	
	END IF;
	
    p_retCode := '0000000000'; p_retMsg  := '成功';
    commit; return;	  
END;

/
show errors
--------------------------------------------------
--  其他资源-签收退库存储过程
--  初次编写
--  董翔
--  2012-12-14
--------------------------------------------------
CREATE OR REPLACE PROCEDURE SP_RM_ResourceStockReutrn
(
	P_GETORDERID           CHAR      ,  --领用单号
	P_SESSION							 VARCHAR2  ,
	P_SUM									 INT      ,   --签收数量
	P_ATTRIBUTE1           VARCHAR2  ,
	P_ATTRIBUTE2           VARCHAR2  ,
	P_ATTRIBUTE3           VARCHAR2  ,
	P_ATTRIBUTE4           VARCHAR2  ,
	P_ATTRIBUTE5           VARCHAR2  ,
	P_ATTRIBUTE6           VARCHAR2  ,
	P_REASON							 VARCHAR2  ,
	p_currOper	           char     ,
	p_currDept	           char     ,
	p_retCode              out char     ,  -- Return Code
	p_retMsg               out varchar2    -- Return Message  
)
AS
    v_seqNo             CHAR(16)       ;
    V_EX                EXCEPTION      ;
    V_RESOURCECODE      CHAR(6)        ;
    V_TODAY             DATE := SYSDATE;
    V_ALREADYGETNUM     INT    ;   --已领用数量
    V_INDEX							INT  := 0;
    V_COUNT             INT;
    V_ATTRIBUTE1				VARCHAR2(50);
    V_ATTRIBUTE2				VARCHAR2(50);
    V_ATTRIBUTE3				VARCHAR2(50);
    V_ATTRIBUTE4				VARCHAR2(50);
    V_ATTRIBUTE5				VARCHAR2(50);
    V_ATTRIBUTE6				VARCHAR2(50);
    V_ORDERATTRIBUTE1           VARCHAR2(50);
		V_ORDERATTRIBUTE2           VARCHAR2(50);
		V_ORDERATTRIBUTE3           VARCHAR2(50);
		V_ORDERATTRIBUTE4           VARCHAR2(50);
		V_ORDERATTRIBUTE5           VARCHAR2(50);
		V_ORDERATTRIBUTE6           VARCHAR2(50);
BEGIN
	
	
	--获取流水号
	SP_GetSeq(seq => v_seqNo); 
	
	BEGIN
			SELECT RESOURCECODE,ALREADYGETNUM,ATTRIBUTE1,ATTRIBUTE2,ATTRIBUTE3,ATTRIBUTE4,ATTRIBUTE5,ATTRIBUTE6 
			INTO V_RESOURCECODE,V_ALREADYGETNUM,V_ORDERATTRIBUTE1,V_ORDERATTRIBUTE2,V_ORDERATTRIBUTE3,V_ORDERATTRIBUTE4,V_ORDERATTRIBUTE5,V_ORDERATTRIBUTE6
		  FROM TF_F_GETRESOURCEORDER
			WHERE GETORDERID = P_GETORDERID;
			EXCEPTION
	    WHEN OTHERS THEN
	        p_retCode := 'SR00110001';
	        p_retMsg  := '查询退库资源失败'|| SQLERRM;
	        ROLLBACK; RETURN;   
	END;
	

	
	WHILE V_INDEX < P_SUM
	LOOP
	 BEGIN
			V_INDEX:=V_INDEX+1;
			
			
		 SELECT F1,F2,F3,F4,F5,F6  INTO V_ATTRIBUTE1,V_ATTRIBUTE2,V_ATTRIBUTE3,V_ATTRIBUTE4,V_ATTRIBUTE5,V_ATTRIBUTE6
	   FROM TMP_COMMON
	   WHERE f7 = P_SESSION and F0 =  V_INDEX ; 
	   
			SELECT COUNT(*) INTO V_COUNT
			FROM   TL_R_RESOURCE																			
			WHERE  RESOURCECODE = V_RESOURCECODE																			
			AND     (V_ATTRIBUTE1 IS NULL OR NVL(V_ATTRIBUTE1,V_ORDERATTRIBUTE1) = ATTRIBUTE1 )																			
			AND     (V_ATTRIBUTE2 IS NULL OR NVL(V_ATTRIBUTE2,V_ORDERATTRIBUTE2) = ATTRIBUTE2 )		
			AND     (V_ATTRIBUTE3 IS NULL OR NVL(V_ATTRIBUTE3,V_ORDERATTRIBUTE3) = ATTRIBUTE3 )																			
			AND     (V_ATTRIBUTE4 IS NULL OR NVL(V_ATTRIBUTE4,V_ORDERATTRIBUTE4) = ATTRIBUTE4 )	
			AND     (V_ATTRIBUTE5 IS NULL OR NVL(V_ATTRIBUTE5,V_ORDERATTRIBUTE5) = ATTRIBUTE5 )																			
			AND     (V_ATTRIBUTE6 IS NULL OR NVL(V_ATTRIBUTE6,V_ORDERATTRIBUTE6) = ATTRIBUTE6 )
			AND   STOCKSATECODE = '01';
			IF V_COUNT = 1 THEN
				BEGIN
				
			  	UPDATE TL_R_RESOURCE
			  	SET      STOCKSATECODE = '00' ,   											
					         INSTIME = V_TODAY ,											
					         UPDATESTAFFNO = P_CURROPER ,											
					         UPDATETIME = V_TODAY											
			  	WHERE   RESOURCECODE = V_RESOURCECODE																			
					AND     (V_ATTRIBUTE1 IS NULL OR NVL(V_ATTRIBUTE1,V_ORDERATTRIBUTE1) = ATTRIBUTE1 )																			
				  AND     (V_ATTRIBUTE2 IS NULL OR NVL(V_ATTRIBUTE2,V_ORDERATTRIBUTE2) = ATTRIBUTE2 )		
				  AND     (V_ATTRIBUTE3 IS NULL OR NVL(V_ATTRIBUTE3,V_ORDERATTRIBUTE3) = ATTRIBUTE3 )																			
				  AND     (V_ATTRIBUTE4 IS NULL OR NVL(V_ATTRIBUTE4,V_ORDERATTRIBUTE4) = ATTRIBUTE4 )	
				  AND     (V_ATTRIBUTE5 IS NULL OR NVL(V_ATTRIBUTE5,V_ORDERATTRIBUTE5) = ATTRIBUTE5 )																			
				  AND     (V_ATTRIBUTE6 IS NULL OR NVL(V_ATTRIBUTE6,V_ORDERATTRIBUTE6) = ATTRIBUTE6 )
				  AND   STOCKSATECODE = '01';
					EXCEPTION
			    WHEN OTHERS THEN
			        p_retCode := 'SR00110002';
			        p_retMsg  := '记录库存汇总表失败'|| SQLERRM;
			        ROLLBACK; RETURN;   
		    END;
		  ELSE
		  	BEGIN
		    --记录库存表
			  INSERT INTO TL_R_RESOURCE
			  (RESOURCECODE,ATTRIBUTE1,ATTRIBUTE2,ATTRIBUTE3,ATTRIBUTE4,ATTRIBUTE5,ATTRIBUTE6,
			  STOCKSATECODE,INSTIME,UPDATESTAFFNO,UPDATETIME)
			  SELECT V_RESOURCECODE,F1,F2,F3,F4,F5,F6,'00',V_TODAY,p_currOper,V_TODAY
			  FROM TMP_COMMON
			  WHERE f7 = P_SESSION AND F0 = TO_CHAR(V_INDEX);
			  EXCEPTION
		    WHEN OTHERS THEN
		        p_retCode := 'SR00110003';
		        p_retMsg  := '记录库存汇总表失败'|| SQLERRM;
		        ROLLBACK; RETURN;   
		  	END;
		  END IF;
		END;
	END LOOP;  
	  
	--更新库存汇总表
	BEGIN
		UPDATE TL_R_RESOURCESUM
		SET USENUM = USENUM - P_SUM
		WHERE RESOURCECODE = V_RESOURCECODE;
		EXCEPTION
	    WHEN OTHERS THEN
      p_retCode := 'SR00110004';
      p_retMsg  := '更新资源订购单表失败'|| SQLERRM;
      ROLLBACK; RETURN;   
	END;  
	  
	--更新资源领用单
	BEGIN
		 IF P_SUM  >  V_ALREADYGETNUM THEN
		 	BEGIN
		 		 p_retCode := 'SR00110005';
	       p_retMsg  := '输入的退库数量错误'|| SQLERRM;
	       ROLLBACK; RETURN;   
	    END;
	   ELSIF P_SUM < V_ALREADYGETNUM THEN 
	   UPDATE  TF_F_GETRESOURCEORDER         											
		 SET     ALREADYGETNUM = ALREADYGETNUM - P_SUM,											
			       ORDERSTATE = '3' 													
		 WHERE   GETORDERID = P_GETORDERID ;			
		 ELSE
		 UPDATE  TF_F_GETRESOURCEORDER         											
		 SET     ALREADYGETNUM = 0,										
			       ORDERSTATE = '1' 													
		 WHERE   GETORDERID = P_GETORDERID ;									
		 END IF;
		 EXCEPTION
	    WHEN OTHERS THEN
	        p_retCode := 'SR00110006';
	        p_retMsg  := '更新资源领用单表失败'|| SQLERRM;
	        ROLLBACK; RETURN;  
	END;
	
	BEGIN
  --记录资源退库单
  INSERT INTO  TF_F_RETURNSOURCEORDER(
    RETURNORDERID     ,USETAG          , RESOURCECODE     , ATTRIBUTE1      , ATTRIBUTE2     ,
    ATTRIBUTE3       , ATTRIBUTE4      , ATTRIBUTE5       , ATTRIBUTE6      , REASON         ,
    ORDERTIME        , ORDERSTAFFNO   )
  VALUES(
      'TK'||v_seqNo   , '1'           , V_RESOURCECODE    , P_ATTRIBUTE1    , P_ATTRIBUTE2    ,
      P_ATTRIBUTE3   , P_ATTRIBUTE4   , P_ATTRIBUTE5      ,P_ATTRIBUTE6     , P_REASON       ,
      V_TODAY        , P_CURROPER     );
  EXCEPTION
    WHEN OTHERS THEN
        p_retCode := 'SR00110008';
        p_retMsg  := '记录资源退库单失败'|| SQLERRM;
        ROLLBACK; RETURN;
  END;
	
	--记录资源单据管理台账表
	BEGIN
		INSERT INTO TF_B_RESOURCEORDERMANAGE(																							
		    TRADEID           , ORDERTYPECODE           , ORDERID           , OPERATETYPECODE     ,																							
		    ORDERDEMAND       , MAINTAINREASON          , RESOURCECODE      , ATTRIBUTE1          ,																							
		    ATTRIBUTE2        , ATTRIBUTE3              , ATTRIBUTE4        , ATTRIBUTE5          ,																							
		    ATTRIBUTE6        , RESOURCENUM             , REQUIREDATE       , LATELYDATE          ,																							
			  ALREADYORDERNUM   , ALREADYARRIVENUM        , APPLYGETNUM       , AGREEGETNUM         ,																						
			  ALREADYGETNUM     , LATELYGETDATE           , GETSTAFFNO        , OPERATETIME         ,																						
			  OPERATESTAFFNO																						
		)  VALUES	(																						
		    v_seqNo           ,  '03'                  , P_GETORDERID      , '10'                ,																							
		    NULL              , NULL                   , V_RESOURCECODE    , P_ATTRIBUTE1        ,																							
		    P_ATTRIBUTE2      ,P_ATTRIBUTE3            , P_ATTRIBUTE4      , P_ATTRIBUTE5        ,																							
		    P_ATTRIBUTE6      ,NULL                    , NULL              , NULL              ,																							
		    0                 ,0                       , P_SUM             , NULL                ,																							
			  V_ALREADYGETNUM -    P_SUM  , NULL                      , NULL             , V_TODAY             ,   																						
			  P_CURROPER ) 	;																					
	  EXCEPTION
	    WHEN OTHERS THEN
	        p_retCode := 'SR00110007';
	        p_retMsg  := '记录资源单据管理台账表'|| SQLERRM;
	        ROLLBACK; RETURN;  
	END;
	  
	--清除临时表
	DELETE TMP_COMMON WHERE f7 = P_SESSION;
	
	p_retCode := '0000000000';
	p_retMsg  := '成功';
	COMMIT; RETURN;    
END;

/
show errors

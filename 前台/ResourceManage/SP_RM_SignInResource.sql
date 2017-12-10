--------------------------------------------------
--  其他资源-签收入库存储过程
--  初次编写
--  董翔
--  2012-12-4
--------------------------------------------------
CREATE OR REPLACE PROCEDURE SP_RM_SignInResource
(
	P_RESOURCEORDERID      CHAR     ,  --订购单号
	P_SESSION							 VARCHAR2  ,
	P_SUM									 INT      ,   --签收数量
	P_ATTRIBUTE1           VARCHAR2  ,
	P_ATTRIBUTE2           VARCHAR2  ,
	P_ATTRIBUTE3           VARCHAR2  ,
	P_ATTRIBUTE4           VARCHAR2  ,
	P_ATTRIBUTE5           VARCHAR2  ,
	P_ATTRIBUTE6           VARCHAR2  ,
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
    V_ORDERCARDNUM      INT    ;   --订购单要求数量
    V_ALREADYARRIVENUM  INT    ;   --已到货数量
    V_INDEX							INT  := 0;
    V_ATTRIBUTE1           VARCHAR2(50);
		V_ATTRIBUTE2           VARCHAR2(50);
		V_ATTRIBUTE3           VARCHAR2(50);
		V_ATTRIBUTE4           VARCHAR2(50);
		V_ATTRIBUTE5           VARCHAR2(50);
		V_ATTRIBUTE6           VARCHAR2(50);
BEGIN
	
	
	--获取流水号
	SP_GetSeq(seq => v_seqNo); 
	
	BEGIN
			SELECT RESOURCECODE,RESOURCENUM,ALREADYARRIVENUM,ATTRIBUTE1,ATTRIBUTE2,ATTRIBUTE3,ATTRIBUTE4,ATTRIBUTE5,ATTRIBUTE6
			 INTO V_RESOURCECODE,V_ORDERCARDNUM,V_ALREADYARRIVENUM,V_ATTRIBUTE1,V_ATTRIBUTE2,V_ATTRIBUTE3,V_ATTRIBUTE4,V_ATTRIBUTE5,V_ATTRIBUTE6
		  FROM TF_F_RESOURCEORDER
			WHERE RESOURCEORDERID = P_RESOURCEORDERID;
			EXCEPTION
	    WHEN OTHERS THEN
	        p_retCode := 'SR00060001';
	        p_retMsg  := '查询签收资源失败'|| SQLERRM;
	        ROLLBACK; RETURN;   
	END;
	

	
	WHILE V_INDEX < P_SUM
	LOOP
	 BEGIN
			V_INDEX:=V_INDEX+1;
		  --记录库存表
		  INSERT INTO TL_R_RESOURCE
		  (RESOURCECODE,ATTRIBUTE1,ATTRIBUTE2,ATTRIBUTE3,ATTRIBUTE4,ATTRIBUTE5,ATTRIBUTE6,
		  STOCKSATECODE,INSTIME,UPDATESTAFFNO,UPDATETIME)
		  SELECT V_RESOURCECODE,NVL(F1,V_ATTRIBUTE1),NVL(F2,V_ATTRIBUTE2),NVL(F3,V_ATTRIBUTE3),
		  NVL(F4,V_ATTRIBUTE4),NVL(F5,V_ATTRIBUTE5),NVL(F6,V_ATTRIBUTE6),'00',V_TODAY,p_currOper,V_TODAY
		  FROM TMP_COMMON
		  WHERE f7 = P_SESSION AND F0 = V_INDEX;
		  EXCEPTION
	    WHEN OTHERS THEN
	        p_retCode := 'SR00060002';
	        p_retMsg  := '记录库存汇总表失败'|| SQLERRM;
	        ROLLBACK; RETURN;   
		END;
	END LOOP;  
	  
	--更新资源订购单表
	BEGIN
		 IF V_ALREADYARRIVENUM + P_SUM > V_ORDERCARDNUM THEN
		 	BEGIN
		 		 p_retCode := 'SR00060003';
	       p_retMsg  := '输入的签收数量错误'|| SQLERRM;
	       ROLLBACK; RETURN;   
	    END;
	   ELSIF V_ALREADYARRIVENUM + P_SUM < V_ORDERCARDNUM THEN 
	   UPDATE  TF_F_RESOURCEORDER         											
		 SET     LATELYDATE = TO_CHAR(V_TODAY,'YYYYMMDD') ,													
			       ALREADYARRIVENUM = V_ALREADYARRIVENUM + P_SUM,											
			       ORDERSTATE = '3' 													
		 WHERE   RESOURCEORDERID = P_RESOURCEORDERID ;			
		 ELSE
		 UPDATE  TF_F_RESOURCEORDER         											
		 SET     LATELYDATE = TO_CHAR(V_TODAY,'YYYYMMDD')  ,													
			       ALREADYARRIVENUM = V_ALREADYARRIVENUM + P_SUM,										
			       ORDERSTATE = '4' 													
		 WHERE   RESOURCEORDERID = P_RESOURCEORDERID ;									
		 END IF;
		 EXCEPTION
	    WHEN OTHERS THEN
	        p_retCode := 'SR00060004';
	        p_retMsg  := '更新资源订购单表失败'|| SQLERRM;
	        ROLLBACK; RETURN;  
	END;
	
	--更新库存汇总表
	BEGIN
		UPDATE TL_R_RESOURCESUM
		SET INSNUM = INSNUM + P_SUM
		WHERE RESOURCECODE = V_RESOURCECODE;
		EXCEPTION
	    WHEN OTHERS THEN
      p_retCode := 'SR00060005';
      p_retMsg  := '更新资源订购单表失败'|| SQLERRM;
      ROLLBACK; RETURN;   
	END;
	
	
	
	--记录资源单据管理台账表
	BEGIN
		INSERT INTO TF_B_RESOURCEORDERMANAGE(																							
		    TRADEID           , ORDERTYPECODE           , ORDERID           , OPERATETYPECODE     ,																							
		    ORDERDEMAND       , MAINTAINREASON          , RESOURCECODE      , ATTRIBUTE1          ,																							
		    ATTRIBUTE2        , ATTRIBUTE3              , ATTRIBUTE4        , ATTRIBUTE5          ,																							
		    ATTRIBUTE6        , RESOURCENUM             , REQUIREDATE       , LATELYDATE          ,																							
			  ALREADYORDERNUM   ,ALREADYARRIVENUM         , APPLYGETNUM       , AGREEGETNUM         ,																						
			  ALREADYGETNUM     , LATELYGETDATE           , GETSTAFFNO        , OPERATETIME         ,																						
			  OPERATESTAFFNO																						
		)  VALUES	(																						
		    v_seqNo           ,  '02'                  , P_RESOURCEORDERID , '07'                ,																							
		    NULL              , NULL                   , V_RESOURCECODE    , P_ATTRIBUTE1        ,																							
		    P_ATTRIBUTE2      ,P_ATTRIBUTE3            , P_ATTRIBUTE4      , P_ATTRIBUTE5        ,																							
		    P_ATTRIBUTE6      ,NULL                    , NULL              , TO_CHAR(V_TODAY,'YYYYMMDD')              ,																							
		    NULL              ,P_SUM                   , NULL              , NULL                ,																							
			  NULL              , NULL                   , NULL              , V_TODAY             ,   																						
			  P_CURROPER ) 	;																					
	  EXCEPTION
	    WHEN OTHERS THEN
	        p_retCode := 'SR00060006';
	        p_retMsg  := '记录资源单据管理台账表'|| SQLERRM;
	        ROLLBACK; RETURN;  
	END;
	
	--获取流水号
	SP_GetSeq(seq => v_seqNo); 
	  
  --记录资源单据管理台账表
	BEGIN
		INSERT INTO TF_B_RESOURCEORDERMANAGE(																							
		    TRADEID           , ORDERTYPECODE           , ORDERID           , OPERATETYPECODE     ,																							
		    ORDERDEMAND       , MAINTAINREASON          , RESOURCECODE      , ATTRIBUTE1          ,																							
		    ATTRIBUTE2        , ATTRIBUTE3              , ATTRIBUTE4        , ATTRIBUTE5          ,																							
		    ATTRIBUTE6        , RESOURCENUM             , REQUIREDATE       , LATELYDATE          ,																							
			ALREADYORDERNUM   ,ALREADYARRIVENUM         , APPLYGETNUM       , AGREEGETNUM         ,																						
			ALREADYGETNUM     , LATELYGETDATE           , GETSTAFFNO        , OPERATETIME         ,																						
			OPERATESTAFFNO																						
		)VALUES	(																						
		    v_seqNo           ,  '01'                  , P_RESOURCEORDERID , '07'                ,																							
		    NULL              , NULL                   , V_RESOURCECODE    , P_ATTRIBUTE1        ,																							
		    P_ATTRIBUTE2      ,P_ATTRIBUTE3            , P_ATTRIBUTE4      , P_ATTRIBUTE5        ,																							
		    P_ATTRIBUTE6      ,NULL                    , NULL              , TO_CHAR(V_TODAY,'YYYYMMDD')              ,																							
		    NULL              ,P_SUM                   , NULL              , NULL                ,																							
			  NULL              , NULL                    , NULL              , V_TODAY             ,   																						
			P_CURROPER ) 		;																				
	  EXCEPTION
	    WHEN OTHERS THEN
	        p_retCode := 'SR00060007';
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

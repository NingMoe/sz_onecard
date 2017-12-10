create or replace procedure SP_RM_RETURNCARD
(
		P_BEGINCARDNO		VARCHAR2,
		P_ENDCARDNO			VARCHAR2,
		p_returnmsg			char,  --退货原因
		P_SIGNTYPE      CHAR,  --签收类型，0用户卡，1充值卡
		p_seqNo         out char,
		p_currOper      char,
		p_currDept	    char,
		p_retCode	     	out char, -- Return Code
		p_retMsg     	 	out varchar2  -- Return Message
)
as
    v_seqNo             CHAR(16)       ;
    V_EX                EXCEPTION      ;
    V_TODAY             DATE := SYSDATE;
    V_QUANTITY          INT        ;   --数量
    V_CARDTYPE          CHAR(2):='';   --卡片类型
    V_FACETYPE          CHAR(4):='';   --卡面类型
    V_VALUECODE         CHAR(1):='';   --面值
    V_CARDORDERID       CHAR(18);  --订购单号
    V_APPLYORDERID      CHAR(18);  --需求单号
    V_CARDORDERSTATE    CHAR(1);   --订购单状态
    V_CARDNUM           INT    ;   --库存表中待订购数量
    V_ORDERCARDNUM      INT    ;   --订购单要求数量
    V_ALREADYARRIVENUM  INT    ;   --已到货数量
    V_RETURNCARDNUM     INT    ;   --退货数量
	  V_FROMCARDNO        VARCHAR2(16);  --起始卡号
    V_TOCARDNO          VARCHAR2(16);  --结束卡号
    V_FCARDNO           VARCHAR2(16);  --起始卡号
    V_ECARDNO           VARCHAR2(16);  --结束卡号
    V_COUNT             INT     ;  --卡片数量
BEGIN

  --查看卡片是否是同一个厂商
  select count(distinct t.MANUTYPECODE) into V_COUNT  from TL_R_ICUSER t where  t.cardno between P_BEGINCARDNO and P_ENDCARDNO;
  if V_COUNT > 1 then
     p_retCode := 'S094390132';
		 p_retMsg  := '卡号段内存在不同厂商的卡号';
     return;
  end if;

	--卡片数量
	V_QUANTITY := substr(P_ENDCARDNO,-8) - substr(P_BEGINCARDNO,-8) + 1;
	
	IF P_SIGNTYPE = '0' THEN --如果是用户卡
	--获取卡片类型和卡面类型
	  V_CARDTYPE  := SUBSTR(P_BEGINCARDNO,5,2);
	  V_FACETYPE  := SUBSTR(P_BEGINCARDNO,5,4);
	
	BEGIN
		SELECT COUNT(*) INTO V_CARDNUM
	    FROM   TL_R_ICUSER
	    WHERE  CARDNO BETWEEN P_BEGINCARDNO AND P_ENDCARDNO
	    AND    RESSTATECODE  = '00';

	    IF V_CARDNUM < V_QUANTITY THEN
		    p_retCode := 'S094570132';
		    p_retMsg  := '退货的用户卡中存在卡片不为入库状态的卡';
		    ROLLBACK; RETURN;
	    END IF;
		
		--更新用户卡库存表
			UPDATE TL_R_ICUSER
			SET    RESSTATECODE  = '15'       ,  --订购状态
			       INSTIME       = V_TODAY    ,
			       UPDATESTAFFNO = P_CURROPER ,
			       UPDATETIME    = V_TODAY
			WHERE  RESSTATECODE  = '00'          --入库状态
			AND    (CARDNO BETWEEN P_BEGINCARDNO AND P_ENDCARDNO);

	  EXCEPTION
	    WHEN OTHERS THEN
	        p_retCode := 'S094570134'; p_retMsg  := '更新用户卡库存表失败'|| SQLERRM;
	        ROLLBACK; RETURN;
	END;
	
	ELSIF P_SIGNTYPE = '1'  THEN
		
		BEGIN
		  SELECT COUNT(*) INTO V_CARDNUM
		  FROM TD_XFC_INITCARD
		  WHERE (XFCARDNO BETWEEN P_BEGINCARDNO AND P_ENDCARDNO)
		  AND CARDSTATECODE = '2';

	    IF V_CARDNUM < V_QUANTITY THEN
		    p_retCode := 'S094570142';
		    p_retMsg  := '退货的充值卡中存在卡片不为入库状态的卡';
		    ROLLBACK; RETURN;
	    END IF;

	    --更新充值卡账户表
      UPDATE TD_XFC_INITCARD
      SET    CARDSTATECODE = 'C'        ,  --订购状态
             INTIME        = V_TODAY    ,
             INSTAFFNO     = P_CURROPER
      WHERE  CARDSTATECODE = '2'          	--入库状态
      AND   (XFCARDNO BETWEEN P_BEGINCARDNO AND P_ENDCARDNO) ;

	  EXCEPTION
	    WHEN OTHERS THEN
	        p_retCode := 'S094570124'; p_retMsg  := '更新充值卡账户表失败'|| SQLERRM;
	        ROLLBACK; RETURN;
	  END;

	END IF;
	
	BEGIN
	  --查询所属订购单起始卡号
	  SELECT BEGINCARDNO INTO V_FROMCARDNO 
	  FROM TF_F_CARDORDER 
	  WHERE BEGINCARDNO <= P_BEGINCARDNO 
	  AND ENDCARDNO >= P_BEGINCARDNO 
	  AND CARDORDERSTATE IN ('1','3','4') --1、审核通过，3、部分到货，4、全部到货	
	  AND USETAG = '1'; 
	  EXCEPTION
		  WHEN NO_DATA_FOUND THEN
			  p_retCode := 'S094570111'; p_retMsg  := '未找到起始卡号所属订购单';
			  ROLLBACK;RETURN;  
	END;
	  
	BEGIN
	  SELECT BEGINCARDNO INTO V_TOCARDNO 
	  FROM TF_F_CARDORDER 
	  WHERE BEGINCARDNO <= P_ENDCARDNO 
	  AND ENDCARDNO >= P_ENDCARDNO 
	  AND CARDORDERSTATE IN ('1','3','4') --1、审核通过，3、部分到货，4、全部到货	
	  AND USETAG = '1'; 
	EXCEPTION
	  WHEN NO_DATA_FOUND THEN
	      p_retCode := 'S094570120'; p_retMsg  := '未找到结束卡号所属订购单';
	      ROLLBACK;RETURN;
	END;
	
	BEGIN
	FOR V_C IN (SELECT CARDORDERID, APPLYORDERID , VALUECODE , BEGINCARDNO , ENDCARDNO
  	            FROM TF_F_CARDORDER 
  	            WHERE (BEGINCARDNO BETWEEN V_FROMCARDNO AND V_TOCARDNO )
  	            AND    CARDORDERSTATE IN ('1','3','4') --1、审核通过，3、部分到货，4、全部到货
  	            AND    USETAG = '1'
  	            )
    LOOP
	  V_CARDORDERID  := V_C.CARDORDERID;
      V_APPLYORDERID := V_C.APPLYORDERID;
      V_VALUECODE    := V_C.VALUECODE;
	  
		IF V_C.BEGINCARDNO > P_BEGINCARDNO AND V_C.ENDCARDNO >= P_ENDCARDNO THEN
			 BEGIN 
			     V_COUNT   := SUBSTR(P_ENDCARDNO , -8) - SUBSTR(V_C.BEGINCARDNO , -8) + 1;  --计算订购单中退货数量
			     V_FCARDNO := V_C.BEGINCARDNO;
			     V_ECARDNO := P_ENDCARDNO;
			  END;   
			ELSIF V_C.BEGINCARDNO > P_BEGINCARDNO AND V_C.ENDCARDNO < P_ENDCARDNO THEN  
			  BEGIN
			      V_COUNT := SUBSTR(V_C.ENDCARDNO, -8) - SUBSTR(V_C.BEGINCARDNO, -8) + 1;  --计算订购单中退货数量
			      V_FCARDNO := V_C.BEGINCARDNO;
			      V_ECARDNO := V_C.ENDCARDNO;
			   END;   
			ELSIF V_C.BEGINCARDNO <= P_BEGINCARDNO AND V_C.ENDCARDNO >= P_ENDCARDNO THEN
			   BEGIN  
			      V_COUNT := SUBSTR(P_ENDCARDNO, -8) - SUBSTR(P_BEGINCARDNO, -8) + 1;  --计算订购单中退货数量
			      V_FCARDNO := P_BEGINCARDNO;
			      V_ECARDNO := P_ENDCARDNO;
			   END;   
			ELSIF V_C.BEGINCARDNO <= P_BEGINCARDNO AND V_C.ENDCARDNO < P_ENDCARDNO THEN
			   BEGIN   
			      V_COUNT := SUBSTR(V_C.ENDCARDNO, -8) - SUBSTR(P_BEGINCARDNO, -8) + 1;  --计算订购单中退货数量
			      V_FCARDNO := P_BEGINCARDNO;
			      V_ECARDNO := V_C.ENDCARDNO;
			   END;
		 END IF;
		 
		 --判断订购单是否全部到货
	SELECT CARDNUM          ,
	       ALREADYARRIVENUM ,
	       RETURNCARDNUM
	INTO   V_ORDERCARDNUM      , --订购数量
	       V_ALREADYARRIVENUM  , --已到货数量
	       V_RETURNCARDNUM       --已退货数量
	FROM   TF_F_CARDORDER
	WHERE  CARDORDERID = V_CARDORDERID;

	IF V_ALREADYARRIVENUM - V_RETURNCARDNUM - V_COUNT <= 0 THEN
	   V_CARDORDERSTATE := '1';  --审核通过
	ELSE
	   V_CARDORDERSTATE := '3';  --部分到货
	END IF;
	
	BEGIN
		--更新订购单
		UPDATE TF_F_CARDORDER		
		SET    CARDORDERSTATE = V_CARDORDERSTATE ,  --订购单状态			
			     RETURNCARDNUM  = V_RETURNCARDNUM + V_COUNT       --已退货数量		
		WHERE  CARDORDERID = V_CARDORDERID		
		AND    USETAG = '1';		

	EXCEPTION
	  WHEN OTHERS THEN
		    p_retCode := 'S094570117'; p_retMsg  := '更新订购单失败'|| SQLERRM;
		    ROLLBACK; RETURN;
	END;
	
	BEGIN
		--更新需求单
		UPDATE TF_F_APPLYORDER	
			SET ALREADYARRIVENUM = ALREADYARRIVENUM - V_COUNT ,  --已到货数量			
				RETURNCARDNUM  = V_RETURNCARDNUM + V_COUNT       --已退货数量			
			WHERE  APPLYORDERID = V_APPLYORDERID			
		AND    USETAG = '1';			
	EXCEPTION
		WHEN OTHERS THEN
		    p_retCode := 'S094570118'; p_retMsg  := '更新需求单失败'|| SQLERRM;
		    ROLLBACK; RETURN;
	END;
	
	--获取流水号
	SP_GetSeq(seq => v_seqNo); 
	
	IF P_SIGNTYPE = '0' THEN --如果是用户卡
		  --记录用户卡操作台账表
		  BEGIN
		      INSERT INTO TF_R_ICUSERTRADE(
		          TRADEID          , BEGINCARDNO     , ENDCARDNO       , CARDNUM         ,
		          CARDTYPECODE     , CARDSURFACECODE , OPETYPECODE     , OPERATESTAFFNO  , 
		          OPERATEDEPARTID  , OPERATETIME
		     )VALUES(
		          v_seqNo          , V_FCARDNO       , V_ECARDNO       , V_COUNT         , 
				  V_CARDTYPE       , V_FACETYPE      , '22'            , P_CURROPER      , 
		          P_CURRDEPT       , V_TODAY
		          );
		  EXCEPTION
		      WHEN OTHERS THEN
		          p_retCode := 'S094570116'; p_retMsg  := '记录用户卡操作台账表失败' || SQLERRM;
		          ROLLBACK; RETURN;
		  END;  
    ELSIF P_SIGNTYPE = '1' THEN --如果是充值卡
		--记录充值卡操作日志表
		  BEGIN
				INSERT INTO TL_XFC_MANAGELOG(
					ID           , STAFFNO    , OPERTIME , OPERTYPECODE ,
					STARTCARDNO  , ENDCARDNO  , RETURNREASON , VALUECODE
				)VALUES(
					v_seqNo      , P_CURROPER , V_TODAY  , '07'         ,
					V_FCARDNO    , V_ECARDNO  , p_returnmsg , V_VALUECODE
					);
		  EXCEPTION
			  WHEN OTHERS THEN
				  p_retCode := 'S094570125'; p_retMsg  := '记录充值卡操作日志表失败' || SQLERRM;
				  ROLLBACK; RETURN;
	  END;
	END IF;
	
	BEGIN
		--记录单据管理台账表
		INSERT INTO TF_B_ORDERMANAGE(
		    TRADEID          , ORDERTYPECODE     , ORDERID           , OPERATETYPECODE   ,
		    CARDTYPECODE     , CARDSURFACECODE   , CARDNUM           , LATELYDATE        ,
		    ALREADYARRIVENUM ,RETURNCARDNUM      , BEGINCARDNO       , ENDCARDNO         ,
		    OPERATETIME      , OPERATESTAFF      , VALUECODE
		)VALUES(
		    v_seqNo          , '02'              , V_CARDORDERID     , '08'              ,
		    V_CARDTYPE       , V_FACETYPE        , V_COUNT        , TO_CHAR(V_TODAY,'YYYYMMDD') ,
		    V_ALREADYARRIVENUM , V_RETURNCARDNUM + V_COUNT , V_FCARDNO , V_ECARDNO , 
		    V_TODAY          , P_CURROPER        , V_VALUECODE
		    );
	EXCEPTION
		WHEN OTHERS THEN
		    p_retCode := 'S094570119'; p_retMsg  := '记录单据管理台账表失败'|| SQLERRM;
		    ROLLBACK; RETURN;
	END;
	
	END LOOP;
	END;
	p_seqNo := v_seqNo;
	p_retCode := '0000000000';
	p_retMsg  := '';
	COMMIT; RETURN;
END;

/
show errors

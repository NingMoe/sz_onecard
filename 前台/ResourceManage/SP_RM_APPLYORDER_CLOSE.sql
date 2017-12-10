CREATE OR REPLACE PROCEDURE SP_RM_APPLYORDER_CLOSE
(
    P_SESSIONID       CHAR,
    P_CURROPER        CHAR,
    P_CURRDEPT        CHAR,
    p_retCode     out char, -- Return Code
    p_retMsg      out varchar2  -- Return Message
)
AS
    V_APPLYORDERID    CHAR(18);     --需求单号
	v_seqNo           CHAR(16);     --流水号
	V_TODAY           DATE:=SYSDATE;
    V_EX              EXCEPTION;
/*
	关闭需求单存储过程
	初次编写
	石磊
	2012-09-20
*/
BEGIN
	FOR cur IN (SELECT f0 FROM TMP_COMMON WHERE f1 = p_SESSIONID) 
	LOOP
		V_APPLYORDERID := cur.f0;
		
		--更新卡片需求单
		BEGIN
			UPDATE TF_F_APPLYORDER
			SET    USETAG = '0' 
			WHERE  APPLYORDERID    = V_APPLYORDERID
			AND    ALREADYORDERNUM = 0
			AND    APPLYORDERSTATE = '0'
			AND    USETAG = '1';
		
			IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
		EXCEPTION
			WHEN OTHERS THEN
				P_RETCODE := 'S094570103';
				P_RETMSG  := '更新卡片需求单失败'||SQLERRM;      
			ROLLBACK; RETURN; 		
		END;
		
		--获取流水号
		SP_GetSeq(seq => v_seqNo);
		
		BEGIN
			--记录单据管理台账表
			INSERT INTO TF_B_ORDERMANAGE(
				TRADEID       , ORDERTYPECODE       , ORDERID           , OPERATETYPECODE  ,
				ORDERDEMAND   , CARDTYPECODE        , CARDSURFACECODE   , CARDSAMPLECODE   ,
				CARDNAME      , CARDFACEAFFIRMWAY   , VALUECODE         , CARDNUM          ,
				REQUIREDATE   , OPERATETIME         , OPERATESTAFF      , REMARK
			)SELECT
				v_seqNo       , '01'                , V_APPLYORDERID    , '12'             ,
				t.ORDERDEMAND , t.CARDTYPECODE      , t.CARDSURFACECODE , t.CARDSAMPLECODE ,
				t.CARDNAME    , t.CARDFACEAFFIRMWAY , t.VALUECODE       , t.CARDNUM        ,
				t.REQUIREDATE , V_TODAY             , P_CURROPER        , t.REMARK
			FROM TF_F_APPLYORDER t
			WHERE APPLYORDERID    = V_APPLYORDERID;
		 IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
		 EXCEPTION
		   WHEN OTHERS THEN
			 P_RETCODE := 'S094570101';
			 P_RETMSG  := '记录单据管理台账表失败'||SQLERRM;      
			 ROLLBACK; RETURN;  	
		END;	
	END LOOP;
		p_retCode := '0000000000';
		p_retMsg  := '成功';
		COMMIT; RETURN;    	
END;

/
show errors
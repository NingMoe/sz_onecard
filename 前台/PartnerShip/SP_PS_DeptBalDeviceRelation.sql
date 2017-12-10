  -- =============================================
  -- AUTHOR:    liuhe
  -- CREATE DATE: 2013-11-14
  -- DESCRIPTION:  代理商户结算设备关系添加
  -- MODIFY: 
  -- =============================================
CREATE OR REPLACE PROCEDURE SP_PS_DeptBalDeviceRelation
(
	p_sessionID	 char,
	P_OPTYPE     CHAR,--'ADD' OR 'DEL'
    p_currOper   char,
    p_currDept   char,
    p_retCode    out char, -- Return Code
    p_retMsg     out varchar2  -- Return Message

)
AS
  V_CURRDATE  DATE := SYSDATE;
  V_EX      		EXCEPTION;
  v_count	int;
BEGIN
	
	IF P_OPTYPE = 'ADD' THEN --增加结算设备关系
	
	BEGIN			
		INSERT INTO TD_BALREADER_RELATION
		  (READERNO, DBALUNITNO, TAKETIME, UPDATESTAFFNO, UPDATETIME)
		SELECT DEVICENO, BALUNITNO, V_CURRDATE, p_currOper, V_CURRDATE
		FROM TMP_BalDeviceRelation_IMP WHERE SESSIONID= p_sessionID AND OPTYPECODE = 'ADD';

		IF  SQL%ROWCOUNT < 1 THEN RAISE V_EX; END IF; 
		EXCEPTION 
		WHEN OTHERS THEN
		  P_RETCODE := 'S008108091';
		  P_RETMSG  := '写入网点结算单元读卡器关系表失败'|| SQLERRM;
		  ROLLBACK;RETURN;
	END;
	
	ELSIF P_OPTYPE = 'DEL' THEN --删除结算设备关系，删除的记录先写入历史表
	
		BEGIN
			INSERT INTO TH_BALREADER_RELATION
			  (READERNO, DBALUNITNO, TAKETIME, UPDATESTAFFNO, UPDATETIME, BACKTIME)
			SELECT READERNO, DBALUNITNO, TAKETIME, UPDATESTAFFNO, UPDATETIME, V_CURRDATE
			FROM TD_BALREADER_RELATION WHERE READERNO IN
			(SELECT DEVICENO FROM TMP_BalDeviceRelation_IMP WHERE SESSIONID= p_sessionID AND OPTYPECODE = 'DEL');

			EXCEPTION 
			WHEN OTHERS THEN
			  P_RETCODE := 'S008108092';
			  P_RETMSG  := '写入网点结算单元读卡器关系历史表失败'|| SQLERRM;
			ROLLBACK;RETURN;
		END;
		
		BEGIN
			DELETE FROM TD_BALREADER_RELATION WHERE READERNO IN
			(SELECT DEVICENO FROM TMP_BalDeviceRelation_IMP WHERE SESSIONID= p_sessionID AND OPTYPECODE = 'DEL') ;
			
			IF  SQL%ROWCOUNT < 1 THEN RAISE V_EX; END IF;  
			EXCEPTION 
			WHEN OTHERS THEN
			  P_RETCODE := 'S008108093';
			  P_RETMSG  := '删除网点结算单元读卡器关系表失败'|| SQLERRM;
			ROLLBACK;RETURN;
		END;
			
	END IF; 

	--更新结算单元编码表的更新时间，以便于在线充付平台根据更新时间同步结算单元相关信息	
	BEGIN
		UPDATE  TF_DEPT_BALUNIT								
		SET 	UPDATESTAFFNO    = P_CURROPER,								
				UPDATETIME       = V_CURRDATE							
		WHERE  DBALUNITNO  IN
		(SELECT BALUNITNO FROM TMP_BalDeviceRelation_IMP WHERE SESSIONID= p_sessionID) ;

	IF  SQL%ROWCOUNT < 1 THEN RAISE V_EX; END IF;
	EXCEPTION WHEN OTHERS THEN
		P_RETCODE := 'S008109003';
		P_RETMSG  := '更新网点结算单元编码表失败'||SQLERRM;
	ROLLBACK;RETURN;
	END;       
			
    p_retCode := '0000000000';
    p_retMsg  := '';
    COMMIT; RETURN;
END;

/

show errors

 
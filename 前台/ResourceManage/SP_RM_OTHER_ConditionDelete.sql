--------------------------------------------------
--  资源定义删除存储过程
--  初次编写
--  蒋兵兵
--  2012-12-06
--------------------------------------------------
CREATE OR REPLACE PROCEDURE SP_RM_OTHER_ConditionDelete
(
    P_RESOURCECODE      CHAR, 			--资源编码
	
	P_CURROPER        CHAR,
    P_CURRDEPT        CHAR,
    p_retCode     out char, -- Return Code
    p_retMsg      out varchar2  -- Return Message
)
AS
    
    V_EXIST           INT     ;     --存在数量
    V_TODAY           DATE:=SYSDATE;
    V_EX              EXCEPTION;
	
BEGIN
	--验证此资源是否已经下单
	
	SELECT  COUNT(*) INTO v_exist FROM  TF_F_RESOURCEAPPLYORDER WHERE RESOURCECODE = P_RESOURCECODE;
		IF v_exist > 0 THEN
			P_RETCODE := 'A001002108';
			P_RETMSG  := '此资源已下单，无法执行删除操作';
			ROLLBACK; RETURN;
		END IF;
	
	--删除资源表
	BEGIN
		
		DELETE  TD_M_RESOURCE   WHERE  RESOURCECODE=P_RESOURCECODE;

		IF  SQL%ROWCOUNT = 0 THEN RAISE V_EX; END IF;
		  EXCEPTION
			 WHEN OTHERS THEN
				  p_retCode := 'S001002108'; p_retMsg  := '删除资源表失败' || SQLERRM;
				  ROLLBACK; RETURN;		
	END;
	
	--删除库存汇总表
	BEGIN
		
		DELETE  TL_R_RESOURCESUM  WHERE RESOURCECODE = P_RESOURCECODE;

		IF  SQL%ROWCOUNT = 0 THEN RAISE V_EX; END IF;
		  EXCEPTION
			 WHEN OTHERS THEN
				  p_retCode := 'S001002109'; p_retMsg  := '删除库存汇总表失败' || SQLERRM;
				  ROLLBACK; RETURN;		
	END;
	
	p_retCode := '0000000000';
	p_retMsg  := '';
	COMMIT; RETURN;   
END;

/
show errors



-- =============================================
-- AUTHOR:		LIUHE
-- CREATE DATE: 2011-12-26
-- DESCRIPTION:	代理营业厅使用卡片和抵扣付余款时调用存储过程
-- MODIFY: 2012-2-16 LIUHE 去掉本存储过程对保证金表的更新，
--						领卡数改为在出库时控制，办理业务时不再更新
-- =============================================
CREATE OR REPLACE PROCEDURE SP_PB_DEPTBALFEE
(
    P_TRADEID    	    CHAR, -- TRADE ID
	P_FEETYPE 			CHAR, --1预付款,2保证金,3预付款和保证金
	P_TRADEFEE          INT,  --操作金额
	P_CURRENTTIME       DATE DEFAULT SYSDATE,
    P_CURROPER          CHAR,
    P_CURRDEPT          CHAR,
    P_RETCODE           OUT CHAR, -- RETURN CODE
    P_RETMSG            OUT VARCHAR2  -- RETURN MESSAGE
)
AS
	V_DBALUNITNO 	CHAR(8);
	V_CARDPRICE     INT := 1000;
	V_COUNT   		INT;
	V_EX          	EXCEPTION;

BEGIN

	
	---判断是否是代理营业厅
	SELECT  COUNT(*) INTO V_COUNT 																
	FROM 	TF_DEPT_BALUNIT B , TD_DEPTBAL_RELATION R																
	WHERE 	B.DBALUNITNO = R.DBALUNITNO														
			AND B.DEPTTYPE = '1'														
			AND R.USETAG = '1'														
			AND B.USETAG = '1'														
			AND R.DEPARTNO = P_CURRDEPT;
	
    IF V_COUNT = 1 THEN--如果是代理营业厅则执行下面代码
		
		----获取网点结算单元编码
		BEGIN
			SELECT 		R.DBALUNITNO INTO V_DBALUNITNO													
			FROM 		TD_DEPTBAL_RELATION R													
			WHERE 		R.DEPARTNO = P_CURRDEPT 													
						AND  R.USETAG = '1';	
		EXCEPTION
			WHEN NO_DATA_FOUND THEN
				P_RETCODE := 'S001001990';
				P_RETMSG  := '获取结算单元编码失败' || SQLERRM;
				ROLLBACK; RETURN;
		END;
			
		IF P_FEETYPE = '1' OR P_FEETYPE = '3' THEN
			
			-----记录网点资金管理台账
			BEGIN
			
				INSERT INTO TF_B_DEPTACCTRADE                              
							(TRADEID, TRADETYPECODE, DBALUNITNO,                         
							CURRENTMONEY, PREMONEY, NEXTMONEY,                         
							OPERATESTAFFNO, OPERATEDEPARTID, OPERATETIME, CANCELTAG)                        
				SELECT   	P_TRADEID, '21', P.DBALUNITNO,                         
							- P_TRADEFEE, P.PREPAY, P.PREPAY - P_TRADEFEE,                         
							P_CURROPER, P_CURRDEPT, P_CURRENTTIME, '0'                      
				FROM        TF_F_DEPTBAL_PREPAY P                        
				WHERE       P.DBALUNITNO = V_DBALUNITNO                         
							AND P.ACCSTATECODE = '01';    
			  
			EXCEPTION
				  WHEN OTHERS THEN
					  P_RETCODE := 'S001001991';
					  P_RETMSG  := '抵扣预付款记录台账失败' || SQLERRM;
					  ROLLBACK; RETURN;
			END;
		
			----更新预付款余额
			BEGIN
			
				UPDATE  TF_F_DEPTBAL_PREPAY P                          
				SET     P.PREPAY = P.PREPAY - P_TRADEFEE,                          
						P.UPDATESTAFFNO = P_CURROPER,                          
						P.UPDATETIME = P_CURRENTTIME                          
				WHERE   P.DBALUNITNO = V_DBALUNITNO                           
						AND P.ACCSTATECODE = '01';    
				  
				IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;    
			EXCEPTION
				  WHEN OTHERS THEN
					  P_RETCODE := 'S001001992';
					  P_RETMSG  := '更新预付款余额失败' || SQLERRM;
					  ROLLBACK; RETURN;
			END;
			
		END IF;
		
		/*
		IF P_FEETYPE = '2' OR P_FEETYPE = '3' THEN
			---获取普通卡价值额度配置值
			BEGIN
				SELECT   TAGVALUE INTO V_CARDPRICE   
				FROM     TD_M_TAG   
				WHERE    TAGCODE='USERCARD_MONEY';    
			
			EXCEPTION
				  WHEN NO_DATA_FOUND THEN
					  P_RETCODE := 'S001001995';
					  P_RETMSG  := '获取普通卡价值额度配置失败' || SQLERRM;
					  ROLLBACK; RETURN;
			END;
		
			---更新保证金账户表，增加可领卡额度
			BEGIN
			
				UPDATE  TF_F_DEPTBAL_DEPOSIT      
				SET   	USABLEVALUE = USABLEVALUE + V_CARDPRICE,  
						STOCKVALUE = STOCKVALUE - V_CARDPRICE,  
						UPDATESTAFFNO = P_CURROPER,
						UPDATETIME = P_CURRENTTIME  
				WHERE  	DBALUNITNO = V_DBALUNITNO;  
				  
			  IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;    
			EXCEPTION
				  WHEN OTHERS THEN
					  P_RETCODE := 'S001001994';
					  P_RETMSG  := '更新保证金账户表失败' || SQLERRM;
					  ROLLBACK; RETURN;
			END;
		END IF;
		*/
		
  END IF;

    P_RETCODE := '0000000000';
	P_RETMSG  := '';
	RETURN;
  
END;



/

SHOW ERRORS

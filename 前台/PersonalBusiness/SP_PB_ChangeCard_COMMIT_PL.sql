CREATE OR REPLACE PROCEDURE SP_PB_ChangeCard_COMMIT
(
		p_ID	              char,
		p_CUSTRECTYPECODE	  char,
		p_CARDCOST	        int,
		p_NEWCARDNO	        char,
		p_OLDCARDNO	        char,
		p_ONLINECARDTRADENO	char,
		p_CHECKSTAFFNO	    char,
		p_CHECKDEPARTNO	    char,
		p_CHANGECODE	      char,
		p_ASN	              char,
		p_CARDTYPECODE	    char,
		p_SELLCHANNELCODE	  char,
		p_TRADETYPECODE	    char,
		p_DEPOSIT	          int,
		p_SERSTARTTIME	    date,
		p_SERVICEMONE	      int,
		p_CARDACCMONEY	    int,
		p_NEWSERSTAKETAG	  char,
		p_SUPPLYREALMONEY	  int,
		p_TOTALSUPPLYMONEY	int,
		p_OLDDEPOSIT	      int,
		p_SERSTAKETAG	      char,
		p_PREMONEY	        int,
		p_NEXTMONEY	        int,
		p_CURRENTMONEY	    int,
		p_TERMNO						char,
		p_OPERCARDNO				char,
		p_CURRENTTIME	      out date, -- Return Operate Time
		p_TRADEID    	      out char, -- Return Trade Id
		p_TRADEID2				  out char, 
    --p_TRADEID3          out char,    --专有账户换账户返回的tradeID
    --P_PWD               VARCHAR2,     --专有账户初始密码
		p_currOper	        char,
		p_currDept	        char,
		p_retCode	          out char, -- Return Code
		p_retMsg     	      out varchar2  -- Return Message

)
AS
    v_ex                  exception;
	  V_FEETYPE			  CHAR(1);
    v_NSALETYPE           varchar2(2); --新卡售卡方式
    v_OSALETYPE           varchar2(2); --旧卡售卡方式
    v_ODEPOSIT            int;         --旧卡押金
    v_OCARDCOST           int;         --旧卡卡费
    v_PAYMONEY            int;         --支付金额	
    v_ISMONTH             int;         --判断开通的爱心卡
    v_TRADEID3            char(16);
BEGIN
	BEGIN
		SP_PB_ChangeCard(p_ID,p_CUSTRECTYPECODE,p_CARDCOST,p_NEWCARDNO,p_OLDCARDNO,p_ONLINECARDTRADENO,
		                 p_CHECKSTAFFNO,p_CHECKDEPARTNO,p_CHANGECODE,p_ASN,p_CARDTYPECODE,
		                 p_SELLCHANNELCODE,p_TRADETYPECODE,p_DEPOSIT,p_SERSTARTTIME,p_SERVICEMONE,
		                 p_CARDACCMONEY,p_NEWSERSTAKETAG,p_SUPPLYREALMONEY,p_TOTALSUPPLYMONEY,
		                 p_OLDDEPOSIT,p_SERSTAKETAG,p_PREMONEY,p_NEXTMONEY,p_CURRENTMONEY,
		                 p_TERMNO,p_OPERCARDNO,p_CURRENTTIME,p_TRADEID,p_TRADEID2,p_currOper,p_currDept,
		                 p_retCode,p_retMsg);
		                 
     IF p_retCode != '0000000000' THEN RAISE v_ex; END IF;
        EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK; RETURN;
   END;
   
   --增加 殷华荣 换卡之后同时将卡片中开通的专有账户迁移到新卡中
   BEGIN
     SP_CA_CHANGECARDTRANSITBALANCE(p_OLDCARDNO,p_NEWCARDNO,'',p_currOper,p_currDept,p_retCode,p_retMsg,v_TRADEID3,'0.0-000*0/0.');
     IF (p_retCode != '0000000000' and p_retCode != 'A004P08B04') THEN RAISE v_ex; END IF;
        EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK; RETURN;
   END;
   
   -- 代理营业厅根据保证金修改可领卡额度，add by liuhe 20111230
   BEGIN
		--吴江B卡自然损换卡时交易金额为0  吴江B卡自然损换卡时交易金额为服务费 add by jiangbb 2013-11-21
		IF p_TRADETYPECODE = '03' AND (p_CHANGECODE = '13' OR p_CHANGECODE = '15') AND SUBSTR(p_OLDCARDNO,1,6) = '215031' THEN
			v_PAYMONEY := 0;
		ELSIF p_TRADETYPECODE = '03' AND (p_CHANGECODE = '12' OR p_CHANGECODE = '14') AND SUBSTR(p_OLDCARDNO,1,6) = '215031' THEN
			v_PAYMONEY := p_CARDCOST;
		ELSE
		  	 --押金改卡费,普通换卡业务自然损换卡金额计算, add by shil，20120605
				IF p_TRADETYPECODE = '03' THEN --普通换卡业务
				  --如果是自然损换卡
				
						BEGIN
							--获取旧卡售卡方式
						  SELECT SALETYPE INTO  v_OSALETYPE
						  FROM   TL_R_ICUSER
						  WHERE  CARDNO = p_OLDCARDNO;
						EXCEPTION 
						  WHEN NO_DATA_FOUND THEN
						    p_retCode := 'S094570035';
						    p_retMsg  := '没有查询出旧卡售卡方式';
						    ROLLBACK; RETURN;
					  END;
						
						BEGIN
							--获取新卡售卡方式
						  SELECT SALETYPE INTO  v_NSALETYPE
						  FROM   TL_R_ICUSER
						  WHERE  CARDNO = p_NEWCARDNO;
						EXCEPTION 
						  WHEN NO_DATA_FOUND THEN
						    p_retCode := 'S094570036';
						    p_retMsg  := '没有查询出新卡售卡方式';
						    ROLLBACK; RETURN;				  
						END;
						--如果旧卡或新卡的售卡方式既不是卡费也不是押金则提示错误
						IF (v_OSALETYPE <> '01' AND v_OSALETYPE <> '02') OR (v_NSALETYPE <> '01' AND v_NSALETYPE <> '02') THEN
						    p_retCode := 'S094570037';
						    p_retMsg  := '售卡方式不为押金也不为售卡';
						    ROLLBACK; RETURN;				  
				  	END IF;
				  	--旧卡售卡方式为卡费，新卡售卡方式为押金
				  	IF v_OSALETYPE = '01' AND v_NSALETYPE = '02' THEN
				  		  p_retCode := 'S094570038';
						    p_retMsg  := '旧卡售卡方式为卡费，不能换卡成押金方式';
						    ROLLBACK; RETURN;	
			  	  END IF;
SELECT COUNT(*) INTO v_ISMONTH FROM TF_F_CARDCOUNTACC where CARDNO = p_OLDCARDNO and USETAG ='1' and APPTYPE = '04';
            IF v_ISMONTH > 0 THEN --如果开通了月票爱心卡
                IF p_CHANGECODE = '13' OR p_CHANGECODE = '15' THEN --自然损换卡
                    --旧卡售卡方式为押金，新卡售卡方式为卡费
                    IF v_OSALETYPE = '02' AND v_NSALETYPE = '01' THEN
                        v_PAYMONEY := -3000;
                    END IF;
                    --旧卡售卡方式为卡费，新卡售卡方式为卡费
                    IF v_OSALETYPE = '01' AND v_NSALETYPE = '01' THEN
                        v_PAYMONEY := 0;
                    END IF;
                ELSE --人为损换卡
                    --旧卡售卡方式为押金，新卡售卡方式为卡费
                    IF v_OSALETYPE = '02' AND v_NSALETYPE = '01' THEN
                        v_PAYMONEY := 0;
                    END IF;
                    --旧卡售卡方式为卡费，新卡售卡方式为卡费
                    IF v_OSALETYPE = '01' AND v_NSALETYPE = '01' THEN
                        v_PAYMONEY := 1800;
                    END IF;
                END IF;
            ELSE --没有开通月票爱心卡
                IF p_CHANGECODE = '13' OR p_CHANGECODE = '15' THEN --如果是自然损换卡
                    
                    --旧卡售卡方式为押金，新卡售卡方式为卡费
                    IF v_OSALETYPE = '02' AND v_NSALETYPE = '01' THEN
                        IF p_OLDDEPOSIT - p_CARDCOST > 0 THEN
                         v_PAYMONEY := p_CARDCOST - p_OLDDEPOSIT;
                        ELSE 
                         v_PAYMONEY := 0;
                        END IF;
                    END IF;
                    --旧卡售卡方式为押金，新卡售卡方式为押金
                    IF v_OSALETYPE = '02' AND v_NSALETYPE = '02' THEN
                        SELECT DEPOSIT INTO v_ODEPOSIT
                        FROM TF_F_CARDREC
                        WHERE CARDNO = p_OLDCARDNO;                 
                      
                        IF p_DEPOSIT - v_ODEPOSIT > 0 THEN
                            v_PAYMONEY := p_DEPOSIT - v_ODEPOSIT ; 
                        ELSE 
                            v_PAYMONEY := 0;
                        END IF;
                    END IF;
                    --旧卡售卡方式为卡费，新卡售卡方式为卡费
                    IF v_OSALETYPE = '01' AND v_NSALETYPE = '01' THEN
                        SELECT CARDCOST INTO v_OCARDCOST
                        FROM TF_F_CARDREC
                        WHERE CARDNO = p_OLDCARDNO;                 

                        IF p_CARDCOST - v_OCARDCOST > 0 THEN
                          v_PAYMONEY := p_CARDCOST - v_OCARDCOST ; 
                        ELSE 
                             v_PAYMONEY := 0;
                        END IF;
                    END IF;
                ELSE --如果是人为损换卡
                    v_PAYMONEY := p_CARDCOST + p_DEPOSIT ;
                END IF;
            END IF;
        END IF;
		END IF;
    
        --如果交易金额大于0,则扣预付款并记录台账
        IF v_PAYMONEY > 0 THEN 
            V_FEETYPE := 3;
        ELSE 
            V_FEETYPE := 2;
        END IF;

        SP_PB_DEPTBALFEE(p_TRADEID, V_FEETYPE ,--1预付款,2保证金,3预付款和保证金
                     v_PAYMONEY,
		     
                    
		     p_CURRENTTIME,p_currOper,p_currDept,p_retCode,p_retMsg);

			 IF p_retCode != '0000000000' THEN RAISE v_ex; END IF;
				EXCEPTION
				WHEN OTHERS THEN
					ROLLBACK; RETURN;
	END;
    
  p_retCode := '0000000000';
	p_retMsg  := '';
	COMMIT; RETURN;
END;

/

show errors

 

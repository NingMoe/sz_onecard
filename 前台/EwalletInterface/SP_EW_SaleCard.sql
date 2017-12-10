CREATE OR REPLACE PROCEDURE SP_EW_SaleCard
(
	P_SALETYPECODE    VARCHAR2, --售卡类型编码
	p_CARDNO          char,     --卡号
	p_OLDCARDNO	      char,     --旧卡卡号
	p_CARDCOST	      int,      --卡费
	p_CUSTNAME	      varchar2, --用户姓名
	p_CUSTSEX         varchar2, --用户性别
	p_CUSTBIRTH	      varchar2, --出生日期
	p_PAPERTYPECODE	  varchar2, --证件类型
	p_PAPERNO         varchar2, --证件号码
	p_CUSTADDR        varchar2, --联系地址
	p_CUSTPOST 	      varchar2, --邮政编码
	p_CUSTPHONE	      varchar2, --联系电话
	p_CUSTEMAIL       varchar2, --电子邮件
	p_REMARK          varchar2, --备注
	p_CHANGECODE      char,     --换卡类型
	p_TRADEORIGIN     varchar2, --业务来源
	p_currOper        char,     --员工编码
	p_TRADEID         out char, -- 返回流水号
	p_retCode         out char, 
	p_retMsg          out varchar2  
)
AS
	v_ID               char(18); --记录流水号
	v_CARDTRADENO      char(4) ; --最近联机交易序号
	v_CARDACCMONEY     int     ; --账户余额
	v_TOTALSUPPLYMONEY int     ; --总充值金额
	v_SELLCHANNELCODE  char(2) ; --售卡渠道编码
	v_currDept         char(4) ; --部门编码
	v_PAPERTYPECODE    char(2) ; --证件类型
	v_ex               exception;
	v_RowCount         int     ;
BEGIN
    --获取记录流水号
    v_ID := TO_CHAR(SYSDATE, 'MMDDHHMMSS') || SUBSTR(p_CARDNO, -8);
    
    --转换证件类型
    IF p_PAPERTYPECODE = '01' THEN v_PAPERTYPECODE := '00'; END IF; --身份证号
    IF p_PAPERTYPECODE = '02' THEN v_PAPERTYPECODE := '05'; END IF; --护照
    IF p_PAPERTYPECODE = '03' THEN v_PAPERTYPECODE := '06'; END IF; --港澳台通行证
    IF p_PAPERTYPECODE = '99' THEN v_PAPERTYPECODE := '99'; END IF; --其他
    
    --设定联机交易序号和售卡渠道编码
    v_CARDTRADENO := '0000';
    v_SELLCHANNELCODE := '01' ;
    
    --获取部门编码
    BEGIN
      SELECT DEPARTNO 
      INTO   v_currDept
      FROM   TD_M_INSIDESTAFF
      WHERE  STAFFNO = p_currOper;
    EXCEPTION WHEN NO_DATA_FOUND THEN 
      v_currDept := '9002';
    END;

		--新卡制卡领卡
		IF P_SALETYPECODE = 'SALENEWCARD' THEN
			BEGIN
			  SP_EW_SaleNewCard(v_ID,p_CARDNO,p_CARDCOST,v_CARDTRADENO,0,v_SELLCHANNELCODE,p_CUSTNAME,
			                    p_CUSTSEX,p_CUSTBIRTH,v_PAPERTYPECODE,p_PAPERNO,p_CUSTADDR,p_CUSTPOST,p_CUSTPHONE,
			                    p_CUSTEMAIL,p_REMARK,p_TRADEORIGIN,p_currOper,v_currDept,p_TRADEID,p_retCode,p_retMsg);
				
		    IF p_retCode != '0000000000' THEN RAISE v_ex; END IF;
		    EXCEPTION
		    WHEN OTHERS THEN
		       RETURN;
			END;	
	  END IF;
	  
	  --换卡制卡领卡
	  IF P_SALETYPECODE = 'SALECHANGECARD' THEN
	  	--参数设置
      v_CARDACCMONEY := 0;
      v_TOTALSUPPLYMONEY := 0;
      
			BEGIN
			  SP_EW_SaleChangeCard(v_ID,'03',p_CARDCOST,p_CARDNO,p_OLDCARDNO,v_CARDTRADENO,p_CHANGECODE,
								   v_SELLCHANNELCODE,v_CARDACCMONEY,v_TOTALSUPPLYMONEY,p_CUSTNAME,
								   p_CUSTSEX,p_CUSTBIRTH,v_PAPERTYPECODE,p_PAPERNO,p_CUSTADDR,p_CUSTPOST,
								   p_CUSTPHONE,p_CUSTEMAIL,p_REMARK,p_TRADEORIGIN,
								   p_currOper,v_currDept,p_TRADEID,p_retCode,p_retMsg);
				
			IF p_retCode != '0000000000' THEN RAISE v_ex; END IF;
			EXCEPTION
			WHEN OTHERS THEN
			   RETURN;
			END;	
			
			     
		  BEGIN
				SP_EW_ChangeGroupCard(p_OLDCARDNO,p_CARDNO,p_TRADEORIGIN,p_currOper,v_currDept,p_TRADEID,p_retCode,p_retMsg);
					
				IF p_retCode != '0000000000' THEN RAISE v_ex; END IF;
		  EXCEPTION
				WHEN OTHERS THEN
					  RETURN;
				END;	
			
	  END IF;
    
    --补卡制卡领卡
    IF P_SALETYPECODE = 'SALEREISSUECARD' THEN
       
       BEGIN
          SP_EW_SaleNewCard(v_ID,p_CARDNO,p_CARDCOST,v_CARDTRADENO,0,v_SELLCHANNELCODE,p_CUSTNAME,
                            p_CUSTSEX,p_CUSTBIRTH,v_PAPERTYPECODE,p_PAPERNO,p_CUSTADDR,p_CUSTPOST,p_CUSTPHONE,
                            p_CUSTEMAIL,p_REMARK,p_TRADEORIGIN,p_currOper,v_currDept,p_TRADEID,p_retCode,p_retMsg);
  				
          IF p_retCode != '0000000000' THEN RAISE v_ex; END IF;
          EXCEPTION
          WHEN OTHERS THEN
             RETURN;
			END;
      
      BEGIN
          SP_EW_ChangeGroupCard(p_OLDCARDNO,p_CARDNO,p_TRADEORIGIN,p_currOper,v_currDept,p_TRADEID,p_retCode,p_retMsg);
            IF p_retCode != '0000000000' THEN RAISE v_ex; END IF;
          EXCEPTION
            WHEN OTHERS THEN
                RETURN;
      END;	
      
    END IF;
    
END;  

/
show errors   

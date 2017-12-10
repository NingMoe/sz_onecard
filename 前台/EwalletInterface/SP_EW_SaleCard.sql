CREATE OR REPLACE PROCEDURE SP_EW_SaleCard
(
	P_SALETYPECODE    VARCHAR2, --�ۿ����ͱ���
	p_CARDNO          char,     --����
	p_OLDCARDNO	      char,     --�ɿ�����
	p_CARDCOST	      int,      --����
	p_CUSTNAME	      varchar2, --�û�����
	p_CUSTSEX         varchar2, --�û��Ա�
	p_CUSTBIRTH	      varchar2, --��������
	p_PAPERTYPECODE	  varchar2, --֤������
	p_PAPERNO         varchar2, --֤������
	p_CUSTADDR        varchar2, --��ϵ��ַ
	p_CUSTPOST 	      varchar2, --��������
	p_CUSTPHONE	      varchar2, --��ϵ�绰
	p_CUSTEMAIL       varchar2, --�����ʼ�
	p_REMARK          varchar2, --��ע
	p_CHANGECODE      char,     --��������
	p_TRADEORIGIN     varchar2, --ҵ����Դ
	p_currOper        char,     --Ա������
	p_TRADEID         out char, -- ������ˮ��
	p_retCode         out char, 
	p_retMsg          out varchar2  
)
AS
	v_ID               char(18); --��¼��ˮ��
	v_CARDTRADENO      char(4) ; --��������������
	v_CARDACCMONEY     int     ; --�˻����
	v_TOTALSUPPLYMONEY int     ; --�ܳ�ֵ���
	v_SELLCHANNELCODE  char(2) ; --�ۿ���������
	v_currDept         char(4) ; --���ű���
	v_PAPERTYPECODE    char(2) ; --֤������
	v_ex               exception;
	v_RowCount         int     ;
BEGIN
    --��ȡ��¼��ˮ��
    v_ID := TO_CHAR(SYSDATE, 'MMDDHHMMSS') || SUBSTR(p_CARDNO, -8);
    
    --ת��֤������
    IF p_PAPERTYPECODE = '01' THEN v_PAPERTYPECODE := '00'; END IF; --���֤��
    IF p_PAPERTYPECODE = '02' THEN v_PAPERTYPECODE := '05'; END IF; --����
    IF p_PAPERTYPECODE = '03' THEN v_PAPERTYPECODE := '06'; END IF; --�۰�̨ͨ��֤
    IF p_PAPERTYPECODE = '99' THEN v_PAPERTYPECODE := '99'; END IF; --����
    
    --�趨����������ź��ۿ���������
    v_CARDTRADENO := '0000';
    v_SELLCHANNELCODE := '01' ;
    
    --��ȡ���ű���
    BEGIN
      SELECT DEPARTNO 
      INTO   v_currDept
      FROM   TD_M_INSIDESTAFF
      WHERE  STAFFNO = p_currOper;
    EXCEPTION WHEN NO_DATA_FOUND THEN 
      v_currDept := '9002';
    END;

		--�¿��ƿ��쿨
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
	  
	  --�����ƿ��쿨
	  IF P_SALETYPECODE = 'SALECHANGECARD' THEN
	  	--��������
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
    
    --�����ƿ��쿨
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

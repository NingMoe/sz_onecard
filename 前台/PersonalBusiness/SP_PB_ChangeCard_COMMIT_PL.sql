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
    --p_TRADEID3          out char,    --ר���˻����˻����ص�tradeID
    --P_PWD               VARCHAR2,     --ר���˻���ʼ����
		p_currOper	        char,
		p_currDept	        char,
		p_retCode	          out char, -- Return Code
		p_retMsg     	      out varchar2  -- Return Message

)
AS
    v_ex                  exception;
	  V_FEETYPE			  CHAR(1);
    v_NSALETYPE           varchar2(2); --�¿��ۿ���ʽ
    v_OSALETYPE           varchar2(2); --�ɿ��ۿ���ʽ
    v_ODEPOSIT            int;         --�ɿ�Ѻ��
    v_OCARDCOST           int;         --�ɿ�����
    v_PAYMONEY            int;         --֧�����	
    v_ISMONTH             int;         --�жϿ�ͨ�İ��Ŀ�
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
   
   --���� ���� ����֮��ͬʱ����Ƭ�п�ͨ��ר���˻�Ǩ�Ƶ��¿���
   BEGIN
     SP_CA_CHANGECARDTRANSITBALANCE(p_OLDCARDNO,p_NEWCARDNO,'',p_currOper,p_currDept,p_retCode,p_retMsg,v_TRADEID3,'0.0-000*0/0.');
     IF (p_retCode != '0000000000' and p_retCode != 'A004P08B04') THEN RAISE v_ex; END IF;
        EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK; RETURN;
   END;
   
   -- ����Ӫҵ�����ݱ�֤���޸Ŀ��쿨��ȣ�add by liuhe 20111230
   BEGIN
		--�⽭B����Ȼ�𻻿�ʱ���׽��Ϊ0  �⽭B����Ȼ�𻻿�ʱ���׽��Ϊ����� add by jiangbb 2013-11-21
		IF p_TRADETYPECODE = '03' AND (p_CHANGECODE = '13' OR p_CHANGECODE = '15') AND SUBSTR(p_OLDCARDNO,1,6) = '215031' THEN
			v_PAYMONEY := 0;
		ELSIF p_TRADETYPECODE = '03' AND (p_CHANGECODE = '12' OR p_CHANGECODE = '14') AND SUBSTR(p_OLDCARDNO,1,6) = '215031' THEN
			v_PAYMONEY := p_CARDCOST;
		ELSE
		  	 --Ѻ��Ŀ���,��ͨ����ҵ����Ȼ�𻻿�������, add by shil��20120605
				IF p_TRADETYPECODE = '03' THEN --��ͨ����ҵ��
				  --�������Ȼ�𻻿�
				
						BEGIN
							--��ȡ�ɿ��ۿ���ʽ
						  SELECT SALETYPE INTO  v_OSALETYPE
						  FROM   TL_R_ICUSER
						  WHERE  CARDNO = p_OLDCARDNO;
						EXCEPTION 
						  WHEN NO_DATA_FOUND THEN
						    p_retCode := 'S094570035';
						    p_retMsg  := 'û�в�ѯ���ɿ��ۿ���ʽ';
						    ROLLBACK; RETURN;
					  END;
						
						BEGIN
							--��ȡ�¿��ۿ���ʽ
						  SELECT SALETYPE INTO  v_NSALETYPE
						  FROM   TL_R_ICUSER
						  WHERE  CARDNO = p_NEWCARDNO;
						EXCEPTION 
						  WHEN NO_DATA_FOUND THEN
						    p_retCode := 'S094570036';
						    p_retMsg  := 'û�в�ѯ���¿��ۿ���ʽ';
						    ROLLBACK; RETURN;				  
						END;
						--����ɿ����¿����ۿ���ʽ�Ȳ��ǿ���Ҳ����Ѻ������ʾ����
						IF (v_OSALETYPE <> '01' AND v_OSALETYPE <> '02') OR (v_NSALETYPE <> '01' AND v_NSALETYPE <> '02') THEN
						    p_retCode := 'S094570037';
						    p_retMsg  := '�ۿ���ʽ��ΪѺ��Ҳ��Ϊ�ۿ�';
						    ROLLBACK; RETURN;				  
				  	END IF;
				  	--�ɿ��ۿ���ʽΪ���ѣ��¿��ۿ���ʽΪѺ��
				  	IF v_OSALETYPE = '01' AND v_NSALETYPE = '02' THEN
				  		  p_retCode := 'S094570038';
						    p_retMsg  := '�ɿ��ۿ���ʽΪ���ѣ����ܻ�����Ѻ��ʽ';
						    ROLLBACK; RETURN;	
			  	  END IF;
SELECT COUNT(*) INTO v_ISMONTH FROM TF_F_CARDCOUNTACC where CARDNO = p_OLDCARDNO and USETAG ='1' and APPTYPE = '04';
            IF v_ISMONTH > 0 THEN --�����ͨ����Ʊ���Ŀ�
                IF p_CHANGECODE = '13' OR p_CHANGECODE = '15' THEN --��Ȼ�𻻿�
                    --�ɿ��ۿ���ʽΪѺ���¿��ۿ���ʽΪ����
                    IF v_OSALETYPE = '02' AND v_NSALETYPE = '01' THEN
                        v_PAYMONEY := -3000;
                    END IF;
                    --�ɿ��ۿ���ʽΪ���ѣ��¿��ۿ���ʽΪ����
                    IF v_OSALETYPE = '01' AND v_NSALETYPE = '01' THEN
                        v_PAYMONEY := 0;
                    END IF;
                ELSE --��Ϊ�𻻿�
                    --�ɿ��ۿ���ʽΪѺ���¿��ۿ���ʽΪ����
                    IF v_OSALETYPE = '02' AND v_NSALETYPE = '01' THEN
                        v_PAYMONEY := 0;
                    END IF;
                    --�ɿ��ۿ���ʽΪ���ѣ��¿��ۿ���ʽΪ����
                    IF v_OSALETYPE = '01' AND v_NSALETYPE = '01' THEN
                        v_PAYMONEY := 1800;
                    END IF;
                END IF;
            ELSE --û�п�ͨ��Ʊ���Ŀ�
                IF p_CHANGECODE = '13' OR p_CHANGECODE = '15' THEN --�������Ȼ�𻻿�
                    
                    --�ɿ��ۿ���ʽΪѺ���¿��ۿ���ʽΪ����
                    IF v_OSALETYPE = '02' AND v_NSALETYPE = '01' THEN
                        IF p_OLDDEPOSIT - p_CARDCOST > 0 THEN
                         v_PAYMONEY := p_CARDCOST - p_OLDDEPOSIT;
                        ELSE 
                         v_PAYMONEY := 0;
                        END IF;
                    END IF;
                    --�ɿ��ۿ���ʽΪѺ���¿��ۿ���ʽΪѺ��
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
                    --�ɿ��ۿ���ʽΪ���ѣ��¿��ۿ���ʽΪ����
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
                ELSE --�������Ϊ�𻻿�
                    v_PAYMONEY := p_CARDCOST + p_DEPOSIT ;
                END IF;
            END IF;
        END IF;
		END IF;
    
        --������׽�����0,���Ԥ�����¼̨��
        IF v_PAYMONEY > 0 THEN 
            V_FEETYPE := 3;
        ELSE 
            V_FEETYPE := 2;
        END IF;

        SP_PB_DEPTBALFEE(p_TRADEID, V_FEETYPE ,--1Ԥ����,2��֤��,3Ԥ����ͱ�֤��
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

 

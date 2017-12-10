--��ʧ���˻��洢����
--���� 2012/8/15
CREATE OR REPLACE PROCEDURE SP_CA_BLOCKTRANSITBALANCE
(
  P_OCARDNO  NUMBER,   --��ʧ������
  P_ICARDNO  NUMBER,   --�¿�����
  P_ID       CHAR,     --̨�˼�¼��ˮ��
  P_CURROPER CHAR,     --��ǰ������
  P_CURRDEPT CHAR,     --��ǰ�����߲���
  P_RETCODE  OUT CHAR, --�������
  P_RETMSG   OUT VARCHAR2, --������Ϣ
  P_PWD      VARCHAR2
) AS
  V_OCARDNO CHAR(16);   --��ʧ������
  V_ICARDNO CHAR(16);   --�¿�����
  V_IACCT_ID NUMBER;    --�¿��ʺ�
  V_OACCT_ID NUMBER;    --�ɿ��˺�
  V_PAYMENT_ID varchar(16);
  V_PREMONEY INT;
  V_ACCT_BALANCE_ID INT;      --��ʧ������˱�ID
  V_ACCT_BALANCE_NEW_ID INT;  --�¿�����˱�ID
  V_ACCT_BALANCE INT;
  V_REL_BALANCE INT;
  V_SEQ CHAR(16);
  V_ACCT_ITEM_ID CHAR(30);
  V_TODAY DATE := SYSDATE;
  V_QUANTITY_A INT;
  V_QUANTITY_B INT;
  V_EX EXCEPTION;
  v_CORPNO         char(4);  --���ſͻ���
  V_COUNT INT := 0;
  
  V_PAPERTYPECODE   VARCHAR2(2); --֤������
  V_PAPERNO         VARCHAR2(200);   --֤������
  V_CUSTNAME        VARCHAR2(250);   --�ͻ�����
  V_CUSTSEX         VARCHAR2(2);   --�Ա�
  V_CUSTBIRTH       VARCHAR2(8);  --����
  V_CUSTADDR        VARCHAR2(600);  --��ַ
  V_CUSTPOST        VARCHAR2(6);  --�ʱ�
  V_CUSTPHONE       VARCHAR2(200); --�ֻ�
  V_CUSTTELPHONE    VARCHAR2(200);   --�̻�
  V_CUSTEMAIL       VARCHAR2(30);  --����
  
  V_CUST_ID NUMBER; --�ͻ�ID
  
  v_quantity  int;
  v_TOTAL_SUPPLY_TIMES  INT;
BEGIN

  --У���¿��Ƿ����۳�״̬
    BEGIN
        SELECT 1 INTO v_quantity 
        FROM   TF_F_CARDREC 
        WHERE  CARDNO = P_ICARDNO
        AND    USETAG = '1' 
		    AND    CARDSTATE IN ('10', '11');
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            p_retCode := 'A004P08B05'; p_retMsg  := '�¿��������۳�״̬';
            RETURN;
    END;
    
    --У���¿��Ƿ��ѿ�ͨ�����˻�
    begin
    		select count(*) into v_quantity  from tf_f_cust_acct A where A.ICCARD_NO = P_ICARDNO;
        if v_quantity > 0 then
        	  p_retCode := 'A004P08B07'; p_retMsg  := '�¿��ѿ�ͨ�����˻�';
        	  RETURN;
        end if;
    end;
    
    --У��ɿ��˻��Ƿ��ǹ�ʧ״̬
    BEGIN
        select 1 into v_quantity 
        from tf_f_cust_acct A 
        where A.ICCARD_NO = P_OCARDNO AND A.STATE = 'F';
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            p_retCode := 'A004P08B06'; p_retMsg  := '�ɿ��˻����ǹ�ʧ״̬';
            RETURN;
    END;
  
  --ѭ��������ʧ�����˻����� ����¿�û�ж�Ӧ���˻����ͣ����ʧ���Զ�����
  FOR V_CUR IN (select * from tf_f_cust_acct A where A.ICCARD_NO = P_OCARDNO AND A.STATE = 'F')  
    LOOP
         V_COUNT := 0;
         select count(*) into V_COUNT FROM tf_f_cust_acct WHERE ICCARD_NO = P_ICARDNO AND ACCT_TYPE_NO = V_CUR.acct_type_no;
         IF V_COUNT = 0 THEN  --û�п���
           
            --��ȡ��ʧ���Ŀͻ���ʶ
            SELECT CUST_ID INTO V_CUST_ID FROM  TF_F_CUST_ACCT WHERE ACCT_ID = V_CUR.ACCT_ID;
            
            --��ȡ��ʧ���Ŀͻ���Ϣ
            SELECT PAPER_TYPE_CODE,   PAPER_NO,			CUST_NAME,				CUST_SEX,				CUST_BIRTH,
                   CUST_ADDR,					CUST_POST,		CUST_PHONE,				CUST_TELPHONE,	CUST_EMAIL
            INTO 	 V_PAPERTYPECODE,		V_PAPERNO,		V_CUSTNAME,				V_CUSTSEX,			V_CUSTBIRTH,
            			 V_CUSTADDR,				V_CUSTPOST,		V_CUSTPHONE,			V_CUSTTELPHONE,	V_CUSTEMAIL
            FROM TF_F_CUST WHERE CUST_ID = V_CUST_ID;
            
            --ϵͳ�Զ�����
            BEGIN
                SP_CA_OPENACC(P_ICARDNO,  --�¿�����
                        V_CUR.acct_type_no, --�˻�����
                        V_CUSTNAME,
                        V_CUSTBIRTH,
                        V_PAPERTYPECODE,
                        V_PAPERNO,
                        V_CUSTSEX,
                        V_CUSTPHONE,
                        V_CUSTTELPHONE,
                        V_CUSTPOST,
                        V_CUSTADDR,
                        V_CUSTEMAIL,
                        '0',
                        P_PWD,
                        '0',
                        '0',
                        P_CURROPER,
                        P_CURRDEPT,
                        P_RETCODE,
                        P_RETMSG);
                IF P_RETCODE != '0000000000' THEN
                  ROLLBACK;
                  RAISE V_EX;
                END IF;
                EXCEPTION
                  WHEN OTHERS THEN
                    ROLLBACK;
                    RETURN;        
            END;
         END IF;
         
        --��ѯ���¿����˻���ʶ
        SELECT  ACCT_ID INTO V_IACCT_ID FROM TF_F_CUST_ACCT WHERE ICCARD_NO = P_ICARDNO AND ACCT_TYPE_NO = V_CUR.ACCT_TYPE_NO;
        --��ѯ���ɿ��˻���ʶ
        SELECT ACCT_ID INTO V_OACCT_ID FROM TF_F_CUST_ACCT WHERE ICCARD_NO = P_OCARDNO AND ACCT_TYPE_NO = V_CUR.ACCT_TYPE_NO; 
        --����ɿ����ſͻ���
        BEGIN
	        SELECT CORPNO INTO v_CORPNO FROM TD_GROUP_ACCT WHERE ACCT_ID = V_OACCT_ID ;
	        --�¿������˻����ſͻ���ϵ
	           BEGIN
	           		INSERT INTO TD_GROUP_ACCT (ACCT_ID,CORPNO,USETAG) VALUES (V_IACCT_ID,v_CORPNO,'1');
	           		EXCEPTION WHEN OTHERS THEN
	           			P_RETCODE := 'S006023016';
            			P_RETMSG := 'д���˻����ſͻ���ʧ��' || SQLERRM;
            			ROLLBACK;
	           			RETURN;
	           END;
	        --ɾ���ɿ��˻����ſͻ���ϵ
	          BEGIN
	             UPDATE TD_GROUP_ACCT SET USETAG = '0' WHERE ACCT_ID = V_OACCT_ID;
	             IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
	             EXCEPTION WHEN OTHERS THEN
	           			P_RETCODE := 'S006023017';
            			P_RETMSG := '�޸��˻����ſͻ���ʧ��' || SQLERRM;
            			ROLLBACK;
	           			RETURN;
	          END;
	        EXCEPTION
	           WHEN NO_DATA_FOUND THEN NULL;
        END;
        
        
          -- 1)д���ʧ���ͻ��˻���ʷ��
        BEGIN

          INSERT INTO TF_F_CUST_ACCT_HIS
            (ICCARD_NO,
             ACCT_ID,
             ACCT_TYPE_NO,
             CUST_ID,
             ACCT_NAME,
             STATE,
             STATE_DATE,
             CREATE_DATE,
             EFF_DATE,
             ACCT_PAYMENT_TYPE,
             ACCT_BALANCE,
             REL_BALANCE,
             CUST_PASSWORD,
             TOTAL_CONSUME_TIMES,
             TOTAL_SUPPLY_TIMES,
             TOTAL_CONSUME_MONEY,
             TOTAL_SUPPLY_MONEY,
             LAST_CONSUME_TIME,
             LAST_SUPPLY_TIME,
             LIMIT_DAYAMOUNT,
             AMOUNT_TODAY,
             LIMIT_EACHTIME,
             CODEERRORTIMES,
             BAK_DATE)
            SELECT ICCARD_NO,
                   ACCT_ID,
                   ACCT_TYPE_NO,
                   CUST_ID,
                   ACCT_NAME,
                   STATE,
                   STATE_DATE,
                   CREATE_DATE,
                   EFF_DATE,
                   ACCT_PAYMENT_TYPE,
                   ACCT_BALANCE,
                   REL_BALANCE,
                   CUST_PASSWORD,
                   TOTAL_CONSUME_TIMES,
                   TOTAL_SUPPLY_TIMES,
                   TOTAL_CONSUME_MONEY,
                   TOTAL_SUPPLY_MONEY,
                   LAST_CONSUME_TIME,
                   LAST_SUPPLY_TIME,
                   LIMIT_DAYAMOUNT,
                   AMOUNT_TODAY,
                   LIMIT_EACHTIME,
                   CODEERRORTIMES,
                   V_TODAY
              FROM TF_F_CUST_ACCT
             WHERE ACCT_ID = V_CUR.ACCT_ID
             AND   STATE = 'F';

        EXCEPTION
          WHEN OTHERS THEN
            P_RETCODE := 'S006023012';
            P_RETMSG := 'д��ͻ��˻���ʷ����ʧ��' || SQLERRM;
            ROLLBACK;
            RETURN;
        END;

        -- 2)���¹�ʧ���ͻ��˻���
        BEGIN
          SELECT ACCT_BALANCE, REL_BALANCE
            INTO V_ACCT_BALANCE, V_REL_BALANCE
            FROM TF_F_CUST_ACCT
           WHERE ACCT_ID = V_CUR.ACCT_ID
           AND   STATE = 'F';

          UPDATE TF_F_CUST_ACCT
             SET ACCT_BALANCE = 0, REL_BALANCE = 0, STATE = 'X'
           WHERE ACCT_ID = V_CUR.ACCT_ID
           AND   STATE = 'F';
          IF SQL%ROWCOUNT != 1 THEN
            RAISE V_EX;
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            P_RETCODE := 'S006023013';
            P_RETMSG := '���¿ͻ��˻���ʧ��' || SQLERRM;
            ROLLBACK;
            RETURN;
        END;

        -- 3)���¹�ʧ������˱���
        BEGIN
          
          UPDATE TF_F_ACCT_BALANCE
             SET BALANCE = 0, STATE = 'X'
           WHERE ACCT_ID = V_CUR.ACCT_ID
           AND   STATE = 'F';

          IF SQL%ROWCOUNT != 1 THEN
            RAISE V_EX;
          END IF;
          
          EXCEPTION
            WHEN OTHERS THEN
              P_RETCODE := 'S006023014';
              P_RETMSG := '��������˱���ʧ��' || SQLERRM;
              ROLLBACK;
              RETURN;
        END;

        -- 5)д���ʧ�����֧����¼��
        BEGIN
        	SP_GETSEQ(SEQ => V_SEQ);
          
          SELECT ACCT_BALANCE_ID
            INTO V_ACCT_BALANCE_ID
            FROM TF_F_ACCT_BALANCE
           WHERE ACCT_ID = V_CUR.ACCT_ID
           AND   STATE = 'X';

           INSERT INTO TF_F_BALANCE_PAYOUT
            (PAYOUT_ID,
             ACCT_BALANCE_ID,
             OPERATE_TYPE,
             STAFFNO,
             OPERATETIME,
             AMOUNT,
             BALANCE,
             STATECODE,
             UPDATETIME)
          VALUES
            (V_SEQ,
             V_ACCT_BALANCE_ID,
             'D', --ת��
             P_CURROPER,
             V_TODAY,
             V_REL_BALANCE,
             '0',
             '1', --��Ч
             V_TODAY
             );
        EXCEPTION
          WHEN OTHERS THEN
            P_RETCODE := 'S006023015';
            P_RETMSG := 'д�����֧����¼��ʧ��' || SQLERRM;
            ROLLBACK;
            RETURN;
        END;

        -- 6)д���ʧ��̨������
        BEGIN
          

          SELECT REL_BALANCE
            INTO V_PREMONEY
            FROM TF_F_CUST_ACCT
           WHERE ACCT_ID = V_CUR.ACCT_ID
           AND   STATE = 'X';

          SELECT ICCARD_NO
            INTO V_OCARDNO
            FROM TF_F_CUST_ACCT
           WHERE ACCT_ID = V_CUR.ACCT_ID
           AND   STATE = 'X';

          INSERT INTO TF_B_TRADE
            (TRADEID,
             ID,
             TRADETYPECODE,
             CARDNO,
             ASN,
             CARDTYPECODE,
             CURRENTMONEY,
             PREMONEY,
             OPERATESTAFFNO,
             OPERATEDEPARTID,
             OPERATETIME)
            SELECT V_SEQ,
                   V_SEQ,
                   '8W',
                   V_OCARDNO,
                   T.ASN,
                   T.CARDTYPECODE,
                   -V_REL_BALANCE,
                   V_PREMONEY,
                   P_CURROPER,
                   P_CURRDEPT,
                   V_TODAY
              FROM TF_F_CARDREC T
             WHERE T.CARDNO = V_OCARDNO;
        EXCEPTION
          WHEN OTHERS THEN
            P_RETCODE := 'S006023017';
            P_RETMSG := 'д��ҵ��̨������ʧ��' || SQLERRM;
            ROLLBACK;
            RETURN;
            
        END;
        --�ǹ�ʧ���˻�̨��
        BEGIN
          INSERT INTO TF_B_TRADE_ACCOUNT
            (TRADEID,
             ACCTID,
             ID,
             TRADETYPECODE,
             CARDNO,
             ASN,
             CARDTYPECODE,
             CURRENTMONEY,
             PREMONEY,
             OPERATESTAFFNO,
             OPERATEDEPARTID,
             OPERATETIME)
            SELECT V_SEQ,
                   V_CUR.ACCT_ID,
                   V_SEQ,
                   '8W',
                   V_OCARDNO,
                   T.ASN,
                   T.CARDTYPECODE,
                   -V_REL_BALANCE,
                   V_PREMONEY,
                   P_CURROPER,
                   P_CURRDEPT,
                   V_TODAY
              FROM TF_F_CARDREC T
             WHERE T.CARDNO = V_OCARDNO;
        EXCEPTION
          WHEN OTHERS THEN
            P_RETCODE := 'S006023030';
            P_RETMSG := 'д���˻�ҵ��̨������ʧ��' || SQLERRM;
            ROLLBACK;
            RETURN;
        END;

        -- 7)д��ת�뿨̨������

        BEGIN
          
          --SELECT TF_F_BALANCE_PAYIN_SEQ.NEXTVAL INTO V_PAYMENT_ID FROM DUAL;
          V_PAYMENT_ID := V_SEQ;
          --SP_GETTRADEID(SEQNAME  => 'TF_F_BALANCE_PAYIN_SEQ',TRADEID => V_PAYMENT_ID);
          
          SELECT REL_BALANCE
            INTO V_PREMONEY
            FROM TF_F_CUST_ACCT
           WHERE ACCT_ID = V_IACCT_ID
           AND   STATE = 'A';

          SELECT ICCARD_NO
            INTO V_ICARDNO
            FROM TF_F_CUST_ACCT
           WHERE ACCT_ID = V_IACCT_ID
           AND   STATE = 'A';

          INSERT INTO TF_B_TRADE
            (TRADEID,
             ID,
             TRADETYPECODE,
             CARDNO,
             OLDCARDNO,
             ASN,
             CARDTYPECODE,
             CURRENTMONEY,
             PREMONEY,
             OPERATESTAFFNO,
             OPERATEDEPARTID,
             OPERATETIME)
            SELECT V_SEQ,
                   V_PAYMENT_ID,
                   '8W',
                   V_ICARDNO,
                   V_OCARDNO,
                   T.ASN,
                   T.CARDTYPECODE,
                   V_REL_BALANCE,
                   V_PREMONEY,
                   P_CURROPER,
                   P_CURRDEPT,
                   V_TODAY
              FROM TF_F_CARDREC T
             WHERE T.CARDNO = V_ICARDNO;
        EXCEPTION
          WHEN OTHERS THEN
            P_RETCODE := 'S006023018';
            P_RETMSG := 'д��ҵ��̨������ʧ��' || SQLERRM;
            ROLLBACK;
            RETURN;

        END;
        
        BEGIN
             INSERT INTO TF_B_TRADE_ACCOUNT
            (TRADEID,
             ACCTID,
             ID,
             TRADETYPECODE,
             CARDNO,
             ASN,
             CARDTYPECODE,
             CURRENTMONEY,
             PREMONEY,
             OPERATESTAFFNO,
             OPERATEDEPARTID,
             OPERATETIME)
            SELECT V_SEQ,
                   V_IACCT_ID,
                   V_PAYMENT_ID,
                   '8W',
                   V_ICARDNO,
                   T.ASN,
                   T.CARDTYPECODE,
                   V_REL_BALANCE,
                   V_PREMONEY,
                   P_CURROPER,
                   P_CURRDEPT,
                   V_TODAY
              FROM TF_F_CARDREC T
             WHERE T.CARDNO = V_ICARDNO;
            EXCEPTION
              WHEN OTHERS THEN
                P_RETCODE := 'S006023027';
                P_RETMSG := 'д��ҵ��̨������ʧ��' || SQLERRM;
                ROLLBACK;
                RETURN;

        
          END;

				--д������˱���ֵ��¼��
		    BEGIN
		    	  SELECT ACCT_BALANCE_ID
            INTO V_ACCT_BALANCE_NEW_ID
            FROM TF_F_ACCT_BALANCE
           WHERE ACCT_ID = V_IACCT_ID
           AND   STATE = 'A';
		    		  INSERT INTO TF_F_BALANCE_PAYIN
				    		  (
					    		   PAYIN_ID, 		  ACCT_BALANCE_ID, 	OPERATE_TYPE, 	AMOUNT,         BALANCE,   	   
					    		   STAFFNO,    		OPERATETIME,     	STATECODE,      UPDATETIME, 	  ORDER_NO
				    		  )
		    		  VALUES
		    		  		(
			    		  		 V_PAYMENT_ID,	V_ACCT_BALANCE_NEW_ID,       'D',         		V_REL_BALANCE,  V_REL_BALANCE + V_PREMONEY,
			    		  		 P_CURROPER,    V_TODAY,     			'1',            V_TODAY,        V_PAYMENT_ID                 
		    		  		);
		    		  EXCEPTION
		          WHEN OTHERS THEN
		          P_RETCODE := 'S006001125';
		          P_RETMSG  := 'д������˱���ֵ��¼��ʧ��' || SQLERRM;
		          ROLLBACK; RETURN;				
		    END;

        
        
        -- 10)����ת�뿨����˱���
        BEGIN
          UPDATE TF_F_ACCT_BALANCE
             SET BALANCE = BALANCE + V_REL_BALANCE
           WHERE ACCT_ID = V_IACCT_ID
           AND   STATE = 'A';

          IF SQL%ROWCOUNT != 1 THEN
            RAISE V_EX;
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            P_RETCODE := 'S006023021';
            P_RETMSG := '��������˱���ʧ��' || SQLERRM;
            ROLLBACK;
            RETURN;
        END;

        -- 11)д��ת�뿨�ͻ��˻���ʷ��
        BEGIN

          INSERT INTO TF_F_CUST_ACCT_HIS
            (ICCARD_NO,
             ACCT_ID,
             ACCT_TYPE_NO,
             CUST_ID,
             ACCT_NAME,
             STATE,
             STATE_DATE,
             CREATE_DATE,
             EFF_DATE,
             ACCT_PAYMENT_TYPE,
             ACCT_BALANCE,
             REL_BALANCE,
             CUST_PASSWORD,
             TOTAL_CONSUME_TIMES,
             TOTAL_SUPPLY_TIMES,
             TOTAL_CONSUME_MONEY,
             TOTAL_SUPPLY_MONEY,
             LAST_CONSUME_TIME,
             LAST_SUPPLY_TIME,
             LIMIT_DAYAMOUNT,
             AMOUNT_TODAY,
             LIMIT_EACHTIME,
             CODEERRORTIMES,
             BAK_DATE)
            SELECT ICCARD_NO,
                   ACCT_ID,
                   ACCT_TYPE_NO,
                   CUST_ID,
                   ACCT_NAME,
                   STATE,
                   STATE_DATE,
                   CREATE_DATE,
                   EFF_DATE,
                   ACCT_PAYMENT_TYPE,
                   ACCT_BALANCE,
                   REL_BALANCE,
                   CUST_PASSWORD,
                   TOTAL_CONSUME_TIMES,
                   TOTAL_SUPPLY_TIMES,
                   TOTAL_CONSUME_MONEY,
                   TOTAL_SUPPLY_MONEY,
                   LAST_CONSUME_TIME,
                   LAST_SUPPLY_TIME,
                   LIMIT_DAYAMOUNT,
                   AMOUNT_TODAY,
                   LIMIT_EACHTIME,
                   CODEERRORTIMES,
                   V_TODAY
              FROM TF_F_CUST_ACCT
             WHERE ACCT_ID = V_IACCT_ID
             AND   STATE = 'A';

        EXCEPTION
          WHEN OTHERS THEN
            P_RETCODE := 'S006023022';
            P_RETMSG := 'д��ͻ��˻���ʷ����ʧ��' || SQLERRM;
            ROLLBACK;
            RETURN;
        END;

        -- 12)����ת�뿨�ͻ��˻���
        BEGIN
          UPDATE TF_F_CUST_ACCT
             SET ACCT_BALANCE       = ACCT_BALANCE + V_ACCT_BALANCE,
                 REL_BALANCE        = REL_BALANCE + V_REL_BALANCE,
                 LAST_SUPPLY_TIME   = V_TODAY,
                 TOTAL_SUPPLY_MONEY = TOTAL_SUPPLY_MONEY + V_REL_BALANCE,
                 TOTAL_SUPPLY_TIMES = TOTAL_SUPPLY_TIMES + 1
           WHERE ACCT_ID = V_IACCT_ID
           AND   STATE = 'A';
          IF SQL%ROWCOUNT != 1 THEN
            RAISE V_EX;
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            P_RETCODE := 'S006023023';
            P_RETMSG := '���¿ͻ��˻���ʧ��' || SQLERRM;
            ROLLBACK;
            RETURN;
        END;
        
        -- 3) Determine whether the recharge is the first time
				BEGIN
				    SELECT TOTAL_SUPPLY_TIMES INTO v_TOTAL_SUPPLY_TIMES
				    FROM  TF_F_CUST_ACCT WHERE ACCT_ID = V_IACCT_ID;
		
		    EXCEPTION
						    WHEN NO_DATA_FOUND THEN
						    p_retCode := 'A001002112';
						    p_retMsg  := 'A001002112:Can not find the record or Error';
						    ROLLBACK; RETURN;
		    END;
    
		    -- 4) for the first time
		    IF v_TOTAL_SUPPLY_TIMES = 1 THEN
				    BEGIN
				        UPDATE TF_F_CUST_ACCT
				        SET  FIRST_SUPPLY_TIME = V_TODAY
				        WHERE  ACCT_ID = V_IACCT_ID;
		
				        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
						EXCEPTION
					        WHEN OTHERS THEN
					            p_retCode := 'S001002113';
					            p_retMsg  := 'S001002113:Update failure';
					            ROLLBACK; RETURN;
				    END;
		    END IF;

        --13)��ʧ���˿��
        BEGIN
        	SP_GETITEMID(ITEMID  => V_ACCT_ITEM_ID,
                P_ICCARDNO => V_OCARDNO,
                P_SAMNO    => '000000000000');
          
          SELECT COUNT(*) INTO V_QUANTITY_A FROM TF_B_ACCT_SPEADJUSTACC WHERE ICCARD_NO = V_OCARDNO;
          
          UPDATE TF_B_ACCT_SPEADJUSTACC
             SET ICCARD_NO = V_ICARDNO
           WHERE ICCARD_NO = V_OCARDNO;
           
           IF SQL%ROWCOUNT != V_QUANTITY_A THEN RAISE V_EX; END IF;
        EXCEPTION
          WHEN OTHERS THEN
            P_RETCODE := 'S006023024';
            P_RETMSG := '�����������¼���ʧ��' || SQLERRM;
            ROLLBACK;
            RETURN;
        END;

        --14)��ʧ������Ƿ�Ѵ��� --�����¼�¼
        BEGIN
          INSERT INTO TF_F_ACCT_ITEM_OWE
            (ID,
             ACCT_ID,
             ACCT_TYPE,
             CONSUME_TYPE,
             TRADE_NO,
             ACCT_TYPE_NO,
             ICCARD_NO,
             ICCARD_PARTITION_ID,
             CARD_TRADE_NO,
             ORDER_NO,
             TRADE_CHARGE,
             TRADE_DATE,
             DEALTIME,
             STATE,
             CANCEL_TAG,
             STATE_DATE,
             POSNO,
             SAMNO,
             BALUNITNO,
             RSRV_FEE,
             RSRV_INFO)
            SELECT V_ACCT_ITEM_ID,
                   V_IACCT_ID,
                   ACCT_TYPE,
                   CONSUME_TYPE,
                   TRADE_NO,
                   ACCT_TYPE_NO,
                   V_ICARDNO,
                   ICCARD_PARTITION_ID,
                   CARD_TRADE_NO,
                   ORDER_NO,
                   TRADE_CHARGE,
                   TRADE_DATE,
                   DEALTIME,
                   STATE,
                   CANCEL_TAG,
                   STATE_DATE,
                   POSNO,
                   SAMNO,
                   BALUNITNO,
                   RSRV_FEE,
                   RSRV_INFO
              FROM TF_F_ACCT_ITEM_OWE
             WHERE STATE = 'A'
               AND ACCT_ID = V_CUR.ACCT_ID;
        EXCEPTION
          WHEN OTHERS THEN
            P_RETCODE := 'S006023025';
            P_RETMSG := '��������Ƿ����Ŀ��ʧ��' || SQLERRM;
            ROLLBACK;
            RETURN;
        END;

        --15)��ʧ������Ƿ�Ѵ��� --���¾ɼ�¼
        BEGIN
          
          SELECT COUNT(*) INTO V_QUANTITY_B FROM TF_F_ACCT_ITEM_OWE WHERE STATE = 'A' AND ACCT_ID = V_CUR.ACCT_ID;
          
          UPDATE TF_F_ACCT_ITEM_OWE
             SET STATE = 'X'
           WHERE STATE = 'A'
           AND ACCT_ID = V_CUR.ACCT_ID;
           
           IF SQL%ROWCOUNT != V_QUANTITY_B THEN RAISE V_EX; END IF;
          EXCEPTION WHEN OTHERS THEN P_RETCODE := 'S006023026';
          P_RETMSG := '��������Ƿ����Ŀ��ʧ��' || SQLERRM;
          ROLLBACK;
          RETURN;
        END;
        
    END LOOP;

  P_RETCODE := '0000000000';
  P_RETMSG := '';
  COMMIT;
  RETURN;
  
END;

/
  SHOW ERROR

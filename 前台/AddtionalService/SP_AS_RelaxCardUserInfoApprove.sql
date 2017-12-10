/* ------------------------------------
Copyright (C) 2015-2016 linkage Software 
 All rights reserved.
<author>gl</author>
<createDate>2015-04-24</createDate>
<description>�����޸�������˴洢����</description>
------------------------------------ */
CREATE OR REPLACE PROCEDURE SP_AS_RelaxCardUserInfoApprove
(
       p_SESSIONID varchar2,
       p_STATECODE char, --�Ƿ�ͨ��
       p_currOper  char, -- Current Operator
       p_currDept  char, -- Current Operator's Department
       p_retCode   out char, -- Return Code
       p_retMsg    out varchar2, -- Return Message
       p_TRADEIDS  out varchar2,
       p_CARDNOS   out varchar2
) AS
       v_TRADEID       char(16);
		V_SEQNO			CHAR(16);
       v_OLDCUSTNAME   varchar2(250);
       v_OLDPAPERTYPE  varchar2(2);
       v_OLDPAPERNO    varchar2(250);
       v_CUSTNAME      varchar2(200);
       v_CUSTSEX       varchar2(2);
       v_CUSTBIRTH     varchar2(8);
       v_PAPERTYPECODE char(2);
       v_PAPERNO       varchar2(200);
       v_CUSTADDR      varchar2(600);
       v_CUSTPOST      varchar2(6);
       v_CUSTPHONE     varchar2(200);
       v_CUSTEMAIL     varchar2(30);
       v_REMARK        varchar2(100);
       v_CURRENTTIME   date := sysdate;
       v_EX exception;
       v_COUNTINFO  int;
       v_COUNTIMAGE int;
       v_ID         char(20);
       v_ASN      CHAR(16);
			 v_endDate  CHAR(8);
			 v_tagValue      TD_M_TAG.TAGVALUE%TYPE;
			 v_totalTimes    INT;
			 v_PACKAGETYPECODE char(2);
			 v_ACCOUNTTYPE   CHAR(1);
			 v_Picture       BLOB;
			 v_XXPARKCOUNT   INT;
			 	V_ISSZPARKTAG	CHAR(1);
				V_ISHOTSPRING	CHAR(1);
				V_LENGTH		INT;
				V_CITY			CHAR(4);
BEGIN

  FOR v_cur in (SELECT A.CARDNO,A.PAPERNO,A.Custname,A.PAPERTYPECODE
                  FROM TMP_AS_CARDPARKCHANGEINFO A
                 WHERE A.SESSIONID = p_SESSIONID) LOOP
    --��鿨���Ƿ���� f9����
    BEGIN
       --1) ��ѯ�Ƿ��޸�����
        BEGIN
          SELECT COUNT(*)
            INTO v_COUNTINFO
            FROM TF_F_CARDPARKCUSTOMERREC_SZ t
           WHERE t.CARDNO = v_cur.CARDNO
             AND t.STATE = '0';
        END;

        --2) ��ѯ�Ƿ��޸���Ƭ
        BEGIN
          SELECT COUNT(*)
            INTO v_COUNTIMAGE
            FROM TF_F_CARDPARKPHOTOCHANGE_SZ t
           WHERE t.CARDNO = v_cur.CARDNO
             AND t.STATE = '0';
        END;

      if p_STATECODE = '1' then
        --������ͨ������

        -- 3) Get trade id
        SP_GetSeq(seq => v_TRADEID);

        -- 4) ��ȡ���ص�tradeID�Ϳ��ż���
        p_TRADEIDS := p_TRADEIDS || ',' || v_TRADEID;
        p_CARDNOS  := p_CARDNOS || ',' || v_cur.CARDNO;

        -- 5) Get old card's cust info add by hzl 20131212
        BEGIN
          IF SUBSTR(v_cur.CARDNO, 0, 6) = '215061' THEN
            SELECT A.CUSTNAME, A.PAPERTYPECODE, A.PAPERNO
              into v_OLDCUSTNAME, v_OLDPAPERTYPE, v_OLDPAPERNO
              FROM TF_F_CUSTOMERREC A
             WHERE A.CARDNO = v_cur.CARDNO;
          END IF;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            p_retCode := 'S001011131';
            p_retMsg  := 'Fail to find the card' || SQLERRM;
            ROLLBACK;
            RETURN;
        END;

        --6)����޸�����
        IF v_COUNTINFO = '1' THEN

          -- 7) ��ȡ�û��޸�����
          BEGIN
            SELECT A.CUSTNAME,
                   A.CUSTSEX,
                   A.CUSTBIRTH,
                   A.PAPERTYPECODE,
                   A.PAPERNO,
                   A.CUSTADDR,
                   A.CUSTPOST,
                   A.CUSTPHONE,
                   A.CUSTEMAIL,
                   A.REMARK
              INTO v_CUSTNAME,
                   v_CUSTSEX,
                   v_CUSTBIRTH,
                   v_PAPERTYPECODE,
                   v_PAPERNO,
                   v_CUSTADDR,
                   v_CUSTPOST,
                   v_CUSTPHONE,
                   v_CUSTEMAIL,
                   v_REMARK
              FROM TF_F_CARDPARKCUSTOMERREC_SZ A
             WHERE A.CARDNO = v_cur.CARDNO
               AND A.STATE = '0';
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              p_retCode := 'S001011132';
              p_retMsg  := 'Fail to find the  card' || SQLERRM;
              ROLLBACK;
              RETURN;
          END;

          -- 8) Update Customer Information
          BEGIN
            UPDATE TF_F_CUSTOMERREC
               SET CUSTNAME      = nvl(v_CUSTNAME, CUSTNAME),
                   CUSTSEX       = nvl(v_CUSTSEX, CUSTSEX),
                   CUSTBIRTH     = nvl(v_CUSTBIRTH, CUSTBIRTH),
                   PAPERTYPECODE = nvl(v_PAPERTYPECODE, PAPERTYPECODE),
                   PAPERNO       = nvl(v_PAPERNO, PAPERNO),
                   CUSTADDR      = nvl(v_CUSTADDR, CUSTADDR),
                   CUSTPOST      = nvl(v_CUSTPOST, CUSTPOST),
                   CUSTPHONE     = nvl(v_CUSTPHONE, CUSTPHONE),
                   CUSTEMAIL     = nvl(v_CUSTEMAIL, CUSTEMAIL),
                   REMARK        = nvl(v_REMARK, REMARK)
             WHERE CARDNO = v_cur.CARDNO;

            IF SQL%ROWCOUNT != 1 THEN
              RAISE v_EX;
            END IF;
          EXCEPTION
            WHEN OTHERS THEN
              p_retCode := 'S001011133';
              p_retMsg  := 'Error occurred while updating cust info' ||SQLERRM;
              ROLLBACK;
              RETURN;
          END;

          -- 9) Log the operation of information change
          BEGIN
            INSERT INTO TF_B_CUSTOMERCHANGE
              (TRADEID,
               CARDNO,
               CUSTNAME,
               CUSTSEX,
               CUSTBIRTH,
               PAPERTYPECODE,
               PAPERNO,
               CUSTADDR,
               CUSTPOST,
               CUSTPHONE,
               CUSTEMAIL,
               CHGTYPECODE,
               OPERATESTAFFNO,
               OPERATEDEPARTID,
               OPERATETIME,
               REMARK)
            VALUES
              (v_TradeID,
               v_cur.CARDNO,
               v_CUSTNAME,
               v_CUSTSEX,
               v_CUSTBIRTH,
               v_PAPERTYPECODE,
               v_PAPERNO,
               v_CUSTADDR,
               v_CUSTPOST,
               v_CUSTPHONE,
               v_CUSTEMAIL,
               '01',
               p_currOper,
               p_currDept,
               v_CURRENTTIME,
               v_REMARK);

          EXCEPTION
            WHEN OTHERS THEN
              p_retCode := 'S001011134';
              p_retMsg  := 'Fail to log the operation of information change' ||SQLERRM;
              ROLLBACK;
              RETURN;
          END;

        -- ) �޸����б����Ϣ��
          BEGIN
            update TF_F_CARDPARKCUSTOMERREC_SZ t
               set t.STATE = p_STATECODE
             where t.CARDNO = v_cur.CARDNO;
            IF SQL%ROWCOUNT != 1 THEN
              RAISE v_EX;
            END IF;
          EXCEPTION
            WHEN OTHERS THEN
              p_retCode := 'S001011135';
              p_retMsg  := 'Error occurred while updating TF_F_CARDPARKCUSTOMERREC_SZ info' ||SQLERRM;
              ROLLBACK;
              RETURN;
          END;
        END IF;

        --10������޸���Ƭ
        IF v_COUNTIMAGE = '1' THEN
					
				  SELECT picture INTO v_Picture FROM TF_F_CARDPARKPHOTOCHANGE_SZ t WHERE  t.STATE = '0' AND t.CARDNO=v_cur.CARDNO;
		--����¼��Ƭ��ʷ��
			BEGIN
				INSERT INTO TB_F_CARDPARKPHOTO_SZ(CARDNO,PICTURE,OPERATESTAFFNO,OPERATEDEPARTID,OPERATETIME)
				SELECT v_cur.CARDNO,t.PICTURE,p_currOper,p_currDept,v_CURRENTTIME
				FROM TF_F_CARDPARKPHOTOCHANGE_SZ t WHERE t.cardno=v_cur.CARDNO ;
				IF SQL%ROWCOUNT != 1 THEN
				  RAISE v_EX;
				END IF;
				EXCEPTION
				WHEN OTHERS THEN
				p_retCode := 'S001011144';
				p_retMsg  := 'Error occurred while insert TB_F_CARDPARKPHOTO_SZ info' ||SQLERRM;
				ROLLBACK;
				RETURN;
			END;
          --11) ���¿�Ƭ��Ƭ��Ӧ��ϵ��
          BEGIN
              MERGE INTO TF_F_CARDPARKPHOTO_SZ t USING DUAL
              ON (t.CARDNO = v_cur.CARDNO)
            WHEN MATCHED THEN
              UPDATE
                 SET t.PICTURE         = v_Picture,
                     t.OPERATETIME     = v_CURRENTTIME,
                     t.OPERATEDEPARTID = p_currDept,
                     t.OPERATESTAFFNO  = p_currOper
            WHEN NOT MATCHED THEN
              INSERT
                (CARDNO,
                 PICTURE,
                 OPERATETIME,
                 OPERATEDEPARTID,
                 OPERATESTAFFNO)
              VALUES
                (v_cur.CARDNO,
                 v_Picture,
                 v_CURRENTTIME,
                 p_currDept,
                 p_currOper);
          END;

          ---12�����������޸���Ƭ

          BEGIN
            update TF_F_CARDPARKPHOTOCHANGE_SZ t
               set t.STATE = p_STATECODE
             where t.CARDNO = v_cur.CARDNO;

            IF SQL%ROWCOUNT != 1 THEN
              RAISE v_EX;
            END IF;
          EXCEPTION
            WHEN OTHERS THEN
              p_retCode := 'S001011136';
              p_retMsg  := 'Error occurred while updating TF_F_CARDPARKPHOTOCHANGE_SZ info' ||SQLERRM;
              ROLLBACK;
              RETURN;
          END;
        END IF;

        -- 13) Log operation
        BEGIN
          INSERT INTO TF_B_TRADE
            (TRADEID,
             CARDNO,
             TRADETYPECODE,
             OPERATESTAFFNO,
             OPERATEDEPARTID,
             OPERATETIME)
          VALUES
            (v_TradeID,
             v_cur.CARDNO,
             '29',
             p_currOper,
             p_currDept,
             v_CURRENTTIME);

        EXCEPTION
          WHEN OTHERS THEN
            p_retCode := 'S001011137';
            p_retMsg  := 'Fail to log the operation' || SQLERRM;
            ROLLBACK;
            RETURN;
        END;

        -- 14) Log the sync information while CARD_TYPE is 61
        BEGIN
          IF SUBSTR(v_cur.CARDNO, 0, 6) = '215061' THEN
            INSERT INTO TF_B_SYNC
              (TRADEID,
               CITIZEN_CARD_NO,
               TRANS_CODE,
               Name,
               Paper_Type,
               Paper_No,
               Old_Name,
               Old_Paper_Type,
               Old_Paper_No,
               Card_Type,
               OPERATESTAFFNO,
               OPERATEDEPARTNO,
               OPERATETIME)
            VALUES
              (v_TradeID,
               v_cur.CARDNO,
               '9506',
               v_CUSTNAME,
               v_PAPERTYPECODE,
               v_PAPERNO,
               v_OLDCUSTNAME,
               v_OLDPAPERTYPE,
               v_OLDPAPERNO,
               '61',
               p_currOper,
               p_currDept,
               v_CURRENTTIME);
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            p_retCode := 'S001011138';
            p_retMsg  := 'Fail to log the sync information while CARD_TYPE is 61' ||SQLERRM;
            ROLLBACK;
            RETURN;
        END;

        --��������п� TF_F_CARDXXPARKACC_SZ
		BEGIN
			SELECT COUNT(*) INTO v_XXPARKCOUNT FROM  TF_F_CARDXXPARKACC_SZ t WHERE t.cardno=v_cur.CARDNO;
		END;
		
		IF v_XXPARKCOUNT!=0 THEN
		
			--����ͬ���������ݱ�
			BEGIN
				v_ASN    := '00215000' || SUBSTR(v_cur.CARDNO, -8);
			END;
			
		  --��ȡ�����ײ����ͣ��˻�����,����������ֹʱ��
			BEGIN
				SELECT t.PACKAGETYPECODE,t.accounttype,t.SPARETIMES,ENDDATE 
					INTO v_PACKAGETYPECODE,v_ACCOUNTTYPE,v_totalTimes,v_endDate 
					FROM  TF_F_CARDXXPARKACC_SZ t
					WHERE  t.cardno=v_cur.cardno;
			EXCEPTION WHEN NO_DATA_FOUND THEN
					p_retCode := 'S00505B002'; p_retMsg  := '��ѯ�����ײ�ʧ��';
				RETURN;
			END;
			
			--ͬ�����нӿ�
			  BEGIN
				SP_AS_SYNGARDENXXCARD(V_CUR.CARDNO,V_ASN,v_PAPERTYPECODE,v_PAPERNO,v_CUSTNAME,
						v_endDate,v_totalTimes,'4',v_CURRENTTIME,'','',V_TRADEID,
						V_PACKAGETYPECODE,V_ACCOUNTTYPE,'2150',
						p_currOper,p_currDept,P_RETCODE,P_RETMSG);

			  IF P_RETCODE != '0000000000' THEN RAISE V_EX; END IF;
				EXCEPTION
				WHEN OTHERS THEN
				  ROLLBACK; RETURN;
			  END;
      END IF;

      ELSIF p_STATECODE = '2' then
        --�����˷ϳ�����
        IF v_COUNTINFO = '1' THEN
          BEGIN
            update TF_F_CARDPARKCUSTOMERREC_SZ t
               set t.STATE = p_STATECODE
             where t.CARDNO = v_cur.CARDNO;
            IF SQL%ROWCOUNT != 1 THEN
              RAISE v_EX;
            END IF;
          EXCEPTION
            WHEN OTHERS THEN
              p_retCode := 'S001011140';
              p_retMsg  := 'Error occurred while updating TF_F_CARDPARKCUSTOMERREC_SZ info' ||SQLERRM;
              ROLLBACK;
              RETURN;
          END;
        END IF;

        IF v_COUNTIMAGE = '1' THEN
          BEGIN
            update TF_F_CARDPARKPHOTOCHANGE_SZ t
               set t.STATE = p_STATECODE
             where t.CARDNO = v_cur.CARDNO;

            IF SQL%ROWCOUNT != 1 THEN
              RAISE v_EX;
            END IF;
          EXCEPTION
            WHEN OTHERS THEN
              p_retCode := 'S001011141';
              p_retMsg  := 'Error occurred while updating TF_F_CARDPARKPHOTOCHANGE_SZ info' ||SQLERRM;
              ROLLBACK;
              RETURN;
          END;
        END IF;
      END IF;

    EXCEPTION
      WHEN OTHERS THEN
        p_retCode := 'S001011142';
        p_retMsg  := 'Error occurred in loop' || SQLERRM;
        ROLLBACK;
        RETURN;
    END;
  END LOOP;
  p_retCode := '0000000000';
  p_retMsg  := '';
  COMMIT;
  RETURN;
END;

/

show errors
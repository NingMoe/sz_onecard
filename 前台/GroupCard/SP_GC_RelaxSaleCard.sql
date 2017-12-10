CREATE OR REPLACE PROCEDURE SP_GC_RELAXSALECARD
(
    P_ORDERDETAILID    CHAR,      --�Ӷ�����
    P_ID        CHAR,
    P_CARDNO          CHAR,
    P_DEPOSIT          INT,
    P_CARDCOST          INT,
    P_OTHERFEE      INT,
    P_CARDTRADENO      CHAR,
    P_CARDTYPECODE    CHAR,
    P_CARDMONEY      INT,
    P_SELLCHANNELCODE  CHAR,
    P_SERSTAKETAG      CHAR,
    P_TRADETYPECODE    CHAR,
    P_CUSTNAME      VARCHAR2,
    P_CUSTSEX          VARCHAR2,
    P_CUSTBIRTH      VARCHAR2,
    P_PAPERTYPECODE    VARCHAR2,
    P_PAPERNO          VARCHAR2,
    P_CUSTADDR      VARCHAR2,
    P_CUSTPOST      VARCHAR2,
    P_CUSTPHONE      VARCHAR2,
    P_CUSTEMAIL      VARCHAR2,
    P_REMARK          VARCHAR2,
    P_CUSTRECTYPECODE  CHAR,
    P_TERMNO      CHAR,
    P_OPERCARDNO    CHAR,
    P_FUNCFEE      INT,      --�ײͽ��
    P_PACKAGETYPE    CHAR,      --�ײ�����
    P_PASSPAPERNO    VARCHAR2,    --����֤������
    P_PASSCUSTNAME    VARCHAR2,    --��������

    P_CURRENTTIME      OUT DATE,     -- RETURN OPERATE TIME
    P_SALECARDTRADEID  OUT CHAR,     -- RETURN TRADE ID
    P_RELAXTRADEID    OUT CHAR,     -- RETURN RELAXTRADE ID
    P_CURROPER      CHAR,
    P_CURRDEPT      CHAR,
    P_RETCODE          OUT CHAR,     -- RETURN CODE
    P_RETMSG           OUT VARCHAR2  -- RETURN MESSAGE

)
AS
  V_ID        CHAR(18);
  V_ASN        CHAR(16);
  v_CARDTRADENO    CHAR(4);
  V_PAYCANAL      CHAR(2);      --֧������
  V_PAYTRADEID    VARCHAR2(32);    --֧����ˮ
  V_CARDCOST      INT;
  V_FUNCFEE      INT;
  V_ENDDATE      CHAR(30);      --���������꿨��������
  V_USABLETIMES    CHAR(30);      --���������꿨��ͨ����
  V_XTIMES      CHAR(3);      --16���ƴ���
  V_ENDDATENUM    CHAR(12);      --���ڿ�ͨ���б�ʶ
  V_DEPARTNO      CHAR(4);
  V_STAFFNO      CHAR(6);
  V_OHTERCOUNT    INT;
    V_EX              EXCEPTION;
  V_TODAY        DATE := SYSDATE;
    V_SEQNO        CHAR(16);      --��ˮ��
  V_XFCARDNO      VARCHAR2(14);
    v_CHARGENO    VARCHAR2(512);       --�����Ż���
BEGIN
  BEGIN
    SP_PB_SALECARD(P_ID,P_CARDNO,P_DEPOSIT,P_CARDCOST,P_OTHERFEE,P_CARDTRADENO,P_CARDTYPECODE,
                   P_CARDMONEY,P_SELLCHANNELCODE,P_SERSTAKETAG,P_TRADETYPECODE,P_CUSTNAME,
                   P_CUSTSEX,P_CUSTBIRTH,P_PAPERTYPECODE,P_PAPERNO,P_CUSTADDR,P_CUSTPOST,
                   P_CUSTPHONE,P_CUSTEMAIL,P_REMARK,P_CUSTRECTYPECODE,P_TERMNO,P_OPERCARDNO,
                   P_CURRENTTIME,P_SALECARDTRADEID,P_CURROPER,P_CURRDEPT,P_RETCODE,P_RETMSG);

     IF P_RETCODE != '0000000000' THEN RAISE V_EX; END IF;
        EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK; RETURN;
   END;

  -- ����Ӫҵ���ֿ�Ԥ������ݱ�֤���޸Ŀ��쿨��ȣ�ADD BY LIUHE 20111230
  BEGIN
    SP_PB_DEPTBALFEE(P_SALECARDTRADEID, '3' ,--1Ԥ����,2��֤��,3Ԥ����ͱ�֤��
           P_DEPOSIT + P_CARDCOST + P_OTHERFEE + P_CARDMONEY,
                   P_CURRENTTIME,P_CURROPER,P_CURRDEPT,P_RETCODE,P_RETMSG);

     IF P_RETCODE != '0000000000' THEN RAISE V_EX; END IF;
        EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK; RETURN;
   END;

   --�������п�ͨ
   BEGIN
    --��ȡASN��
    BEGIN
      SELECT ASN INTO V_ASN FROM TL_R_ICUSER WHERE CARDNO = P_CARDNO;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        P_RETCODE := 'I094780007';
        P_RETMSG  := '��ȡASN��ʧ��' || SQLERRM;
        ROLLBACK; RETURN;
    END;

    --��ȡ���ڽ�������
    BEGIN
      SELECT TAGVALUE INTO V_ENDDATE FROM TD_M_TAG WHERE  TAGCODE = 'XXPARK_ENDDATE' AND USETAG = '1';
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
        P_RETCODE := 'S00505B001';
        P_RETMSG  := 'ȱ��ϵͳ����-���������꿨��������' || SQLERRM;
        ROLLBACK; RETURN;
    END;

    --���������꿨��ͨ����
    BEGIN
      SELECT TAGVALUE INTO V_USABLETIMES FROM  TD_M_TAG WHERE TAGCODE = 'XXPARK_NUM' AND USETAG = '1';
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
        P_RETCODE := 'S00505B002';
        P_RETMSG  := 'ȱ��ϵͳ����-���������꿨�ܹ�����' || SQLERRM;
        ROLLBACK; RETURN;
    END;

    --��ͨ����ת16����
    SELECT TO_CHAR(V_USABLETIMES,'XX') INTO V_XTIMES FROM DUAL;
    --���ڿ�ͨ���б�ʶ
    V_ENDDATENUM := SUBSTR(V_ENDDATE,1,8) || P_PACKAGETYPE || SUBSTR(V_XTIMES,-2);
    --��ȡ��¼��ˮ��
    V_ID := TO_CHAR(SYSDATE, 'MMDDHH24MISS') || SUBSTR(P_CARDNO, -8);
    --�趨�����������
    V_CARDTRADENO := '0000';
    --�趨��ֵ����
    V_XFCARDNO :='';

    --��ȡ������ϸ����ʹ���˶һ������ˮ��
    BEGIN
      SELECT T.DISCOUNTTRADEID,CHARGENO INTO P_RELAXTRADEID,v_CHARGENO FROM TF_F_XXOL_ORDERDETAIL T
      WHERE T.ORDERDETAILID = P_ORDERDETAILID
      AND DETAILSTATES = '0'
      AND DISCOUNTTYPE = '01';  --�Żݷ�ʽ���һ��롿
      EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
    END;

    IF(P_RELAXTRADEID is NULL) THEN
      SP_GetSeq(seq => P_RELAXTRADEID);
    ELSE
      BEGIN
        SELECT XFCARDNO INTO V_XFCARDNO FROM TD_XFC_INITCARD WHERE NEW_PASSWD = v_CHARGENO AND CARDTYPE = '01';
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
          P_RETCODE := 'S00505C001';
          P_RETMSG  := 'δ�ҵ���ֵ����' || SQLERRM;
          ROLLBACK; RETURN;
      END;
    END IF;

	IF P_PACKAGETYPE IN('E1','E2','E3','E4') THEN
		BEGIN
			SP_AS_AffectCardNew( p_ID              =>  v_ID      ,
					P_CARDNO          =>  P_CARDNO    ,
					P_CARDTRADENO     =>  V_CARDTRADENO  ,
					P_ASN             =>  V_ASN      ,
					P_TRADEFEE        =>  P_FUNCFEE    ,
					p_discount        =>  0    ,
					P_OPERCARDNO      =>  P_OPERCARDNO  ,  --����Ա����
					P_TERMINALNO      =>  '112233445566',  --Ĭ��
					P_OLDENDDATENUM   =>  'FFFFFFFFFFFF',  --�ϴ�д�����б�ʶ
					P_ENDDATENUM      =>  V_ENDDATENUM  ,  --���ڿ�ͨ���б�ʶ
					P_ACCOUNTTYPE    =>  '1'      ,
					P_PACKAGETPYECODE =>  P_PACKAGETYPE  ,
					p_XFCARDNO      =>  V_XFCARDNO  ,
					P_CUSTNAME        =>  P_CUSTNAME  ,
					P_CUSTSEX         =>  P_CUSTSEX    ,
					P_CUSTBIRTH       =>  P_CUSTBIRTH  ,
					P_PAPERTYPE       =>  P_PAPERTYPECODE,
					P_PAPERNO         =>  P_PAPERNO    ,
					P_CUSTADDR        =>  P_CUSTADDR  ,
					P_CUSTPOST        =>  P_CUSTPOST  ,
					P_CUSTPHONE       =>  P_CUSTPHONE  ,
					P_CUSTEMAIL       =>  P_CUSTEMAIL  ,
					P_REMARK          =>  ''      ,
					P_TRADEID      =>  P_RELAXTRADEID,
					P_PASSPAPERNO    =>  P_PASSPAPERNO  ,
					P_PASSCUSTNAME    =>  P_PASSCUSTNAME,
					p_CITYCODE        =>  '2150'      ,
					P_CURROPER        =>  P_CURROPER  ,
					P_CURRDEPT        =>  P_CURRDEPT  ,
					P_RETCODE         =>  P_RETCODE    ,
					P_RETMSG          =>  P_RETMSG);
		  IF  (P_RETCODE !='0000000000') THEN
		  ROLLBACK;RETURN;
		  END IF;
		END;
	ELSE
		BEGIN
		  SP_AS_RELAXCARDNEW( P_ID              =>  V_ID      ,
					P_CARDNO          =>  P_CARDNO    ,
					P_CARDTRADENO     =>  V_CARDTRADENO  ,
					P_ASN             =>  V_ASN      ,
					P_TRADEFEE        =>  P_FUNCFEE    ,
					P_OPERCARDNO      =>  P_OPERCARDNO  ,  --����Ա����
					P_TERMINALNO      =>  '112233445566',  --Ĭ��
					P_OLDENDDATENUM   =>  'FFFFFFFFFFFF',  --�ϴ�д�����б�ʶ
					P_ENDDATENUM      =>  V_ENDDATENUM  ,  --���ڿ�ͨ���б�ʶ
					P_ACCOUNTTYPE    =>  '1'      ,
					P_PACKAGETPYECODE =>  P_PACKAGETYPE  ,
					p_XFCARDNO      =>  V_XFCARDNO  ,
					P_CUSTNAME        =>  P_CUSTNAME  ,
					P_CUSTSEX         =>  P_CUSTSEX    ,
					P_CUSTBIRTH       =>  P_CUSTBIRTH  ,
					P_PAPERTYPE       =>  P_PAPERTYPECODE,
					P_PAPERNO         =>  P_PAPERNO    ,
					P_CUSTADDR        =>  P_CUSTADDR  ,
					P_CUSTPOST        =>  P_CUSTPOST  ,
					P_CUSTPHONE       =>  P_CUSTPHONE  ,
					P_CUSTEMAIL       =>  P_CUSTEMAIL  ,
					P_REMARK          =>  ''      ,
					P_TRADEID      =>  P_RELAXTRADEID,
					P_PASSPAPERNO    =>  P_PASSPAPERNO  ,
					P_PASSCUSTNAME    =>  P_PASSCUSTNAME,
					p_CITYCODE        =>  '2150'      ,
					P_CURROPER        =>  P_CURROPER  ,
					P_CURRDEPT        =>  P_CURRDEPT  ,
					P_RETCODE         =>  P_RETCODE    ,
					P_RETMSG          =>  P_RETMSG);
		  IF  (P_RETCODE !='0000000000') THEN
		  ROLLBACK;RETURN;
		  END IF;
		END;
	END IF;
   END;

  --�������������꿨������ϸ��
    BEGIN
       UPDATE   TF_F_XXOL_ORDERDETAIL
       SET      DETAILSTATES  = '1' ,
        CARDNO      = P_CARDNO,
                UPDATEDEPARTID  = P_CURRDEPT,
                UPDATESTAFFNO  = P_CURROPER,
                UPDATETIME    = V_TODAY
       WHERE    ORDERDETAILID  = P_ORDERDETAILID
      AND DETAILSTATES  = '0';
       IF SQL%ROWCOUNT != 1 THEN
         RAISE V_EX;
       END IF;
       EXCEPTION
          WHEN OTHERS THEN
            P_RETCODE := 'S094780090';
            P_RETMSG := '���¶�����ϸ��ʧ��' || SQLERRM;
          ROLLBACK;RETURN;
    END;

  --�������������꿨������
  BEGIN
    SELECT COUNT(1) INTO V_OHTERCOUNT FROM TF_F_XXOL_ORDERDETAIL
    WHERE DETAILSTATES !='1'
    AND ORDERNO IN
    (SELECT ORDERNO FROM TF_F_XXOL_ORDERDETAIL WHERE ORDERDETAILID = P_ORDERDETAILID);
    EXCEPTION
      WHEN OTHERS THEN NULL;
  END;

  IF V_OHTERCOUNT = 0 THEN
    BEGIN
    UPDATE TF_F_XXOL_ORDER
      SET    ORDERSTATES    = '1',
          UPDATESTAFFNO  = P_CURROPER,
          UPDATEDEPARTID  = P_CURRDEPT,
          UPDATETIME    = V_TODAY
      WHERE  ORDERNO  IN (SELECT ORDERNO FROM TF_F_XXOL_ORDERDETAIL WHERE ORDERDETAILID = P_ORDERDETAILID);
      IF SQL%ROWCOUNT != 1 THEN
        RAISE V_EX;
      END IF;
      EXCEPTION
        WHEN OTHERS THEN
        P_RETCODE := 'S094780091';
        P_RETMSG := '�������������꿨������' || SQLERRM;
      ROLLBACK;RETURN;
    END;
  END IF;

  --��ȡ���������֧����Ϣ
  BEGIN
    SELECT PAYCANAL,PAYTRADEID  INTO  V_PAYCANAL,V_PAYTRADEID FROM TF_F_XXOL_ORDER
    WHERE ORDERNO IN (SELECT ORDERNO FROM TF_F_XXOL_ORDERDETAIL WHERE ORDERDETAILID = P_ORDERDETAILID);
  END;

  --�Ź�ҵ��¼��
  BEGIN
    SP_FI_IFGroupBuy(P_MSGTRADEIDS   =>  P_RELAXTRADEID,
            P_MSGGROUPCODE  =>  V_PAYTRADEID,
            P_MSGSHOPNO     =>  V_PAYCANAL  ,
            P_MSGREMARK     =>  ''      ,
            P_CURROPER      =>  P_CURROPER  ,
            P_CURRDEPT      =>  P_CURRDEPT  ,
            P_RETCODE     =>  P_RETCODE  ,
            P_RETMSG      =>  P_RETMSG);
    IF  (P_RETCODE !='0000000000') THEN
    ROLLBACK;RETURN;
    END IF;
  END;

  --������Ƭ���
  BEGIN
    INSERT INTO TF_F_CARDPARKPHOTO_SZ
          (CARDNO      ,  PICTURE      ,  OPERATETIME  ,
          OPERATEDEPARTID  ,  OPERATESTAFFNO)
      SELECT   P_CARDNO    ,  PHTOT      ,  V_TODAY    ,
          P_CURRDEPT    ,  P_CURROPER
      FROM  TF_F_XXOL_ORDERDETAIL
      WHERE  ORDERDETAILID  = P_ORDERDETAILID;
    IF SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
    EXCEPTION
    WHEN OTHERS THEN
      P_RETCODE := 'S094780093';
      P_RETMSG := '���¿�������Ƭ��Ӧ��ϵ��ʧ��' || SQLERRM;
    ROLLBACK;RETURN;
  END;

     --��ȡ��ˮ��
    SP_GETSEQ(SEQ => V_SEQNO);

  --��¼����̨�ʱ�
    BEGIN
        INSERT INTO TF_B_XXOL_TRADE(
      TRADEID      , ORDERNO      ,ORDERDETAILID    , TRADETYPECODE  ,
      UPDATEDEPARTID  , UPDATESTAFFNO    ,OPERATETIME )
    SELECT
      V_SEQNO      ,ORDERNO      ,ORDERDETAILID    , '01'      ,
      P_CURRDEPT    , P_CURROPER    ,V_TODAY
    FROM TF_F_XXOL_ORDERDETAIL
    WHERE ORDERDETAILID = P_ORDERDETAILID;
    IF SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
    EXCEPTION
    WHEN OTHERS THEN
            P_RETCODE := 'S094780092';
            P_RETMSG  := '��¼����̨�ʱ�ʧ��'||SQLERRM;
            ROLLBACK; RETURN;
    END;

  P_RETCODE := '0000000000';
  P_RETMSG  := '';
  COMMIT; RETURN;
END;
/

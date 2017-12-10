/* ------------------------------------
COPYRIGHT (C) 2010-2015 LINKAGE SOFTWARE 
 ALL RIGHTS RESERVED.
<AUTHOR>JIANGBB</AUTHOR>
<CREATEDATE>2015-04-23</CREATEDATE>
<DESCRIPTION>�������ҳ����˹���</DESCRIPTION>
------------------------------------ */
CREATE OR REPLACE PROCEDURE SP_GC_RELAXORDERBACK
(

   P_SESSIONID  CHAR,
   P_CURROPER 	CHAR, --��ǰ������
   P_CURRDEPT 	CHAR,
   P_RETCODE  	OUT CHAR, --�������
   P_RETMSG   	OUT VARCHAR2 --������Ϣ

)
AS
    V_SEQNO			CHAR(16);		--��ˮ��
    V_ORDERNO		VARCHAR2(32);	--������
	V_ORDERDETAILID VARCHAR2(32);	--�Ӷ�����
    V_TODAY			DATE:=SYSDATE;
    V_EX			EXCEPTION;
BEGIN

  FOR V_CUR IN (
      SELECT F1,F2
      FROM TMP_ORDER WHERE F0 = P_SESSIONID
    )
  LOOP
    V_ORDERNO := V_CUR.F1;
    V_ORDERDETAILID := V_CUR.F2;
	
    --��ȡ��ˮ��
    SP_GETSEQ(SEQ => V_SEQNO);

	--�������������꿨������ϸ��
    BEGIN
       UPDATE   TF_F_XXOL_ORDERDETAIL
       SET      ISREJECT		= '0' ,  		--����
                UPDATEDEPARTID	= P_CURRDEPT,
                UPDATESTAFFNO	= P_CURROPER,
                UPDATETIME		= V_TODAY
       WHERE    ORDERDETAILID	= V_ORDERDETAILID;
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
       UPDATE   TF_F_XXOL_ORDER
       SET      ISREJECT		= '0' ,  		--����
                UPDATEDEPARTID	= P_CURRDEPT,
                UPDATESTAFFNO	= P_CURROPER,
                UPDATETIME		= V_TODAY
       WHERE    ORDERNO			= V_ORDERNO;
       IF SQL%ROWCOUNT != 1 THEN
         RAISE V_EX;
       END IF;
       EXCEPTION
          WHEN OTHERS THEN
            P_RETCODE := 'S094780091';
            P_RETMSG := '���¶�����ʧ��' || SQLERRM;
          ROLLBACK;RETURN;
    END;

  --��¼����̨�ʱ�
    BEGIN
        INSERT INTO TF_B_XXOL_TRADE(
        TRADEID			, ORDERNO			,ORDERDETAILID		, TRADETYPECODE	,
        UPDATEDEPARTID	, UPDATESTAFFNO		,OPERATETIME    
      )VALUES(
        V_SEQNO			,V_ORDERNO			,V_ORDERDETAILID	, '02'			,
        P_CURRDEPT		, P_CURROPER		,V_TODAY
      );
    IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
          EXCEPTION
          WHEN OTHERS THEN
            P_RETCODE := 'S094780092';
            P_RETMSG  := '��¼����̨�ʱ�ʧ��'||SQLERRM;
            ROLLBACK; RETURN;
    END;
  

  END LOOP;

   P_RETCODE := '0000000000';
   P_RETMSG  := '';
   COMMIT; RETURN;
END;

/
SHOW ERRORS;
  -- =============================================
  -- AUTHOR:    ����
  -- CREATE DATE: 2011-06-30
  -- DESCRIPTION:  ��鷵��״̬
  -- =============================================
CREATE OR REPLACE PROCEDURE SP_CHECKROOLBACK
(
  P_CARDNO        CHAR, --����
  P_TRADETYPECODE CHAR, -- ��������
  P_CURROPER      CHAR, --��ǰ������
  P_CURRDEPT      CHAR, --��ǰ�����߲���
  P_RETCODE       OUT CHAR, --�������
  P_RETMSG        OUT VARCHAR2 --������Ϣ
) AS
  V_OPERATESTAFFNO VARCHAR2(10);
  V_TRADETYPECODE VARCHAR2(2);
  V_COUNT      INT;
  V_EX EXCEPTION;
BEGIN

  -- ��ѯ���쵱�����һ�β�����¼
   SELECT COUNT(*) INTO V_COUNT  FROM TF_B_TRADE
   WHERE cardno = P_CARDNO
     AND OPERATETIME BETWEEN Trunc(SYSDATE, 'dd') AND SYSDATE
     AND CANCELTAG = '0'
     AND ROWNUM = 1;
    IF(V_COUNT != 1) THEN
              P_RETCODE := 'A001021100';
              P_RETMSG  := '���ǵ��쵱ӪҵԱ����';
              RETURN;
    END IF;
  
  SELECT OPERATESTAFFNO,TRADETYPECODE
    INTO V_OPERATESTAFFNO,V_TRADETYPECODE
    FROM TF_B_TRADE
   WHERE cardno = P_CARDNO
     AND OPERATETIME BETWEEN Trunc(SYSDATE, 'dd') AND SYSDATE
     AND CANCELTAG = '0'
     AND ROWNUM = 1
   ORDER BY operatetime DESC;
   

  -- �ж����һ�β�����¼�Ĳ����˺Ͳ��������Ƿ���������ƥ��
   IF (TRIM(V_OPERATESTAFFNO) = TRIM(P_CURROPER) AND TRIM(V_TRADETYPECODE) = TRIM(P_TRADETYPECODE) )  THEN
     P_RETCODE := '0000000000';
     P_RETMSG := '';
     RETURN;
  ELSIF(V_OPERATESTAFFNO != P_CURROPER) THEN
     P_RETCODE := 'A001021100';
     P_RETMSG := '���ǵ��쵱ӪҵԱ����';
     RETURN;
  ELSE
    P_RETCODE := 'A001022105';
    P_RETMSG := '���һ�β������ǿ���';
    RETURN;
  END IF;

END;

/
show errors;
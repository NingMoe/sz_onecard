  -- =============================================
  -- AUTHOR:    董翔
  -- CREATE DATE: 2011-06-30
  -- DESCRIPTION:  检查返销状态
  -- =============================================
CREATE OR REPLACE PROCEDURE SP_CHECKROOLBACK
(
  P_CARDNO        CHAR, --卡号
  P_TRADETYPECODE CHAR, -- 返销类型
  P_CURROPER      CHAR, --当前操作者
  P_CURRDEPT      CHAR, --当前操作者部门
  P_RETCODE       OUT CHAR, --错误编码
  P_RETMSG        OUT VARCHAR2 --错误信息
) AS
  V_OPERATESTAFFNO VARCHAR2(10);
  V_TRADETYPECODE VARCHAR2(2);
  V_COUNT      INT;
  V_EX EXCEPTION;
BEGIN

  -- 查询当天当卡最后一次操作记录
   SELECT COUNT(*) INTO V_COUNT  FROM TF_B_TRADE
   WHERE cardno = P_CARDNO
     AND OPERATETIME BETWEEN Trunc(SYSDATE, 'dd') AND SYSDATE
     AND CANCELTAG = '0'
     AND ROWNUM = 1;
    IF(V_COUNT != 1) THEN
              P_RETCODE := 'A001021100';
              P_RETMSG  := '不是当天当营业员操作';
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
   

  -- 判断最后一次操作记录的操作人和操作类型是否和输入参数匹配
   IF (TRIM(V_OPERATESTAFFNO) = TRIM(P_CURROPER) AND TRIM(V_TRADETYPECODE) = TRIM(P_TRADETYPECODE) )  THEN
     P_RETCODE := '0000000000';
     P_RETMSG := '';
     RETURN;
  ELSIF(V_OPERATESTAFFNO != P_CURROPER) THEN
     P_RETCODE := 'A001021100';
     P_RETMSG := '不是当天当营业员操作';
     RETURN;
  ELSE
    P_RETCODE := 'A001022105';
    P_RETMSG := '最近一次操作不是开户';
    RETURN;
  END IF;

END;

/
show errors;
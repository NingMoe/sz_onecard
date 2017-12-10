/* ------------------------------------
Copyright (C) 2015-2016 linkage Software 
 All rights reserved.
<author>gl</author>
<createDate>2015-04-24</createDate>
<description>休闲修改资料存储过程</description>
------------------------------------ */
CREATE OR REPLACE PROCEDURE SP_AS_RelaxCardChangeUserInfo
(
       P_CARDNO        char, --卡号
       P_CUSTNAME      varchar2,
       P_CUSTSEX       varchar2,
       P_CUSTBIRTH     varchar2,
       P_PAPERTYPECODE varchar2,
       P_PAPERNO       varchar2,
       P_CUSTADDR      varchar2,
       P_CUSTPOST      varchar2,
       P_CUSTPHONE     varchar2,
       P_CUSTEMAIL     varchar2,
       P_REMARK        varchar2,
       p_currOper      char, -- Current Operator
       p_currDept      char, -- Current Operator's Department
       p_retCode       out char, -- Return Code
       p_retMsg        out varchar2 -- Return Message
       ) AS
  
      v_CURRENTTIME date := sysdate;
       v_ex exception;
BEGIN

  -- 1) Log the refund
  BEGIN
   MERGE INTO TF_F_CARDPARKCUSTOMERREC_SZ t USING DUAL
        ON (t.CARDNO = P_CARDNO)
    WHEN MATCHED THEN
      UPDATE
         SET TRADEDATE     = TO_CHAR(v_CURRENTTIME, 'yyyyMMdd'),
             CUSTNAME      = P_CUSTNAME,
             CUSTSEX       = P_CUSTSEX,
             CUSTBIRTH     = P_CUSTBIRTH,
             PAPERTYPECODE = P_PAPERTYPECODE,
             PAPERNO       = P_PAPERNO,
             CUSTADDR      = P_CUSTADDR,
             CUSTPOST      = P_CUSTPOST,
             CUSTPHONE     = P_CUSTPHONE,
             CUSTEMAIL     = P_CUSTEMAIL,
             UPDATESTAFFNO = p_currOper,
             UPDATETIME    = v_CURRENTTIME,
             STATE         = '0',
             REMARK        = P_REMARK
    WHEN NOT MATCHED THEN
      INSERT
        (CARDNO, TRADEDATE,CUSTNAME, CUSTSEX, CUSTBIRTH,
         PAPERTYPECODE, PAPERNO,CUSTADDR,CUSTPOST,CUSTPHONE,
         CUSTEMAIL,USETAG,UPDATESTAFFNO,UPDATETIME, STATE,REMARK)
      VALUES
        (P_CARDNO,TO_CHAR(v_CURRENTTIME, 'yyyyMMdd'),P_CUSTNAME,P_CUSTSEX,P_CUSTBIRTH,
         P_PAPERTYPECODE,P_PAPERNO, P_CUSTADDR,P_CUSTPOST,P_CUSTPHONE,
         P_CUSTEMAIL,'1',p_currOper, v_CURRENTTIME, '0',
         P_REMARK);
  
  EXCEPTION
    WHEN OTHERS THEN
      p_retCode := 'S001014102';
      p_retMsg  := 'Fail to log the TF_F_CARDPARKCUSTOMERREC_SZ' || SQLERRM;
      ROLLBACK;
      RETURN;
  END;

  p_retCode := '0000000000';
  p_retMsg  := '';
  COMMIT;
  RETURN;
END;
/

show errors
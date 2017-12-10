CREATE OR REPLACE PROCEDURE SP_PB_ChangeUserInfoSync
(
    p_CARDNO         char,
    p_ASN            char,
    p_CARDTYPECODE  char,
    p_CUSTNAME       varchar2,
    p_CUSTSEX       varchar2,
    p_CUSTBIRTH      varchar2,
    p_PAPERTYPECODE  varchar2,
    p_PAPERNO        varchar2,
    p_CUSTADDR      varchar2,
    p_CUSTPOST      varchar2,
    p_CUSTPHONE      varchar2,
    p_CUSTEMAIL     varchar2,
    p_REMARK        varchar2,
    p_TRADETYPECODE  char,
    p_currOper      char,
    p_currDept      char,
    p_retCode        out char, -- Return Code
    p_retMsg         out varchar2  -- Return Message
)
AS
    v_TradeID char(16);
    v_CURRENTTIME date := sysdate;
    v_ex          exception;
BEGIN
    -- 1) Get trade id
    SP_GetSeq(seq => v_TradeID);

    -- 2) Update Customer Information
    BEGIN
        UPDATE TF_F_CUSTOMERREC
        SET CUSTNAME = p_CUSTNAME,
            CUSTSEX = p_CUSTSEX,
            CUSTBIRTH = p_CUSTBIRTH,
            PAPERTYPECODE = p_PAPERTYPECODE,
            PAPERNO = p_PAPERNO,
            CUSTADDR = p_CUSTADDR,
            CUSTPOST = p_CUSTPOST,
            CUSTPHONE = p_CUSTPHONE,
            CUSTEMAIL = p_CUSTEMAIL,
            REMARK = p_REMARK,
            UPDATESTAFFNO = p_currOper,
            UPDATETIME = v_CURRENTTIME
        WHERE  CARDNO = p_CARDNO;

        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION
          WHEN OTHERS THEN
              p_retCode := 'S001011130';
              p_retMsg  := 'Error occurred while updating cust info' || SQLERRM;
              ROLLBACK; RETURN;
    END;

    -- 3) Log operation
    BEGIN
        INSERT INTO TF_B_TRADE
            (TRADEID,CARDNO,TRADETYPECODE,ASN,CARDTYPECODE,OPERATESTAFFNO,OPERATEDEPARTID,OPERATETIME)
        VALUES
            (v_TradeID,p_CARDNO,p_TRADETYPECODE,p_ASN,p_CARDTYPECODE,p_currOper,p_currDept,v_CURRENTTIME);

    EXCEPTION
          WHEN OTHERS THEN
              p_retCode := 'S001011132';
              p_retMsg  := 'Fail to log the operation' || SQLERRM;
              ROLLBACK; RETURN;
    END;

    -- 4) Log the operation of information change
    BEGIN
        INSERT INTO TF_B_CUSTOMERCHANGE
            (TRADEID,CARDNO,CUSTNAME,CUSTSEX,CUSTBIRTH,PAPERTYPECODE,PAPERNO,CUSTADDR,CUSTPOST,CUSTPHONE,
            CUSTEMAIL,CHGTYPECODE,OPERATESTAFFNO,OPERATEDEPARTID,OPERATETIME,REMARK)
        VALUES
            (v_TradeID,p_CARDNO,p_CUSTNAME,p_CUSTSEX,p_CUSTBIRTH,p_PAPERTYPECODE,p_PAPERNO,p_CUSTADDR,
            p_CUSTPOST,p_CUSTPHONE,p_CUSTEMAIL,'01',p_currOper,p_currDept,v_CURRENTTIME,p_REMARK);

    EXCEPTION
          WHEN OTHERS THEN
              p_retCode := 'S001011133';
              p_retMsg  := 'Fail to log the operation of information change' || SQLERRM;
              ROLLBACK; RETURN;
    END;


  p_retCode := '0000000000';
  p_retMsg  := '';
  COMMIT; RETURN;
END;
/
show errors
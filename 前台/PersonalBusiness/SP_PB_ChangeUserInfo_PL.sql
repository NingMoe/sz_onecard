CREATE OR REPLACE PROCEDURE SP_PB_ChangeUserInfo
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
    p_TRADEID        out char, -- Return Trade Id
    p_currOper      char,
    p_currDept      char,
    p_retCode        out char, -- Return Code
    p_retMsg         out varchar2  -- Return Message   
)
AS
    v_TradeID char(16);
    v_OLDCUSTNAME  varchar2(250);
    v_OLDPAPERTYPE  varchar2(2);
    v_OLDPAPERNO  varchar2(250);
    v_CURRENTTIME date := sysdate;
    v_ex          exception;
BEGIN
    -- 1) Get trade id
    SP_GetSeq(seq => v_TradeID);
    p_TRADEID := v_TradeID;

-- 2) Get old card's cust info add by hzl 20131212
BEGIN
     IF SUBSTR(p_CARDNO,0,6)='215061' THEN
				SELECT
        A.CUSTNAME,A.PAPERTYPECODE,A.PAPERNO into v_OLDCUSTNAME,v_OLDPAPERTYPE,v_OLDPAPERNO
		    FROM TF_F_CUSTOMERREC A
		    WHERE A.CARDNO = p_CARDNO ;
     END IF;
    EXCEPTION
				    WHEN NO_DATA_FOUND THEN
				    p_retCode := 'A001004132';
				    p_retMsg  := 'Fail to find the card' || SQLERRM;
				    ROLLBACK; RETURN;
    END;
    
-- 3) Update Customer Information
    BEGIN
        UPDATE TF_F_CUSTOMERREC
		    SET CUSTNAME = nvl(p_CUSTNAME,CUSTNAME),    
		        CUSTSEX = nvl(p_CUSTSEX,CUSTSEX),    
		        CUSTBIRTH = nvl(p_CUSTBIRTH,CUSTBIRTH),    
		        PAPERTYPECODE = nvl(p_PAPERTYPECODE,PAPERTYPECODE),    
		        PAPERNO = nvl(p_PAPERNO,PAPERNO),    
		        CUSTADDR = nvl(p_CUSTADDR,CUSTADDR),    
		        CUSTPOST = nvl(p_CUSTPOST,CUSTPOST),    
		        CUSTPHONE = nvl(p_CUSTPHONE,CUSTPHONE),
		        CUSTEMAIL = nvl(p_CUSTEMAIL,CUSTEMAIL),
		        REMARK = nvl(p_REMARK,REMARK)    
        WHERE  CARDNO = p_CARDNO;

        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION
          WHEN OTHERS THEN
              p_retCode := 'S001011130';
              p_retMsg  := 'Error occurred while updating cust info' || SQLERRM;
              ROLLBACK; RETURN;
    END;

    -- 4) Log operation
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

    -- 5) Log the operation of information change
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

   -- 6) Log the sync information while CARD_TYPE is 61
  BEGIN
  IF SUBSTR(p_CARDNO,0,6)='215061' THEN
    INSERT INTO TF_B_SYNC(TRADEID,CITIZEN_CARD_NO,TRANS_CODE,Name,Paper_Type,Paper_No,Old_Name,Old_Paper_Type,Old_Paper_No,Card_Type,OPERATESTAFFNO,OPERATEDEPARTNO,OPERATETIME)
    VALUES(v_TradeID,p_CARDNO,'9506',p_CUSTNAME,p_PAPERTYPECODE,p_PAPERNO, v_OLDCUSTNAME,v_OLDPAPERTYPE,v_OLDPAPERNO,'61',p_currOper,p_currDept,v_CURRENTTIME);
  END IF;
    EXCEPTION
          WHEN OTHERS THEN
              p_retCode := 'S001011134';
              p_retMsg  := 'Fail to log the sync information while CARD_TYPE is 61' || SQLERRM;
              ROLLBACK; RETURN;
END;


  p_retCode := '0000000000';
  p_retMsg  := '';
  COMMIT; RETURN;
END;
/
show errors
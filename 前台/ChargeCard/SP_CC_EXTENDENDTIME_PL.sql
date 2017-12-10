/*
    充值卡有效期延期
    创建：殷华荣 2013-01-30
*/
create or replace procedure SP_CC_EXTENDENDTIME
(
    p_SessionID     char,
    p_fromCardNo    char,
    p_toCardNo      char,
    p_currOper      char,
    p_currDept      char,
    p_retCode      out char,     -- Return Code
    p_retMsg       out varchar2  -- Return Message
)
as
v_seqNo         char(16) ;
V_CARDSTATECODE CHAR(1);
V_EX            EXCEPTION;

BEGIN
    BEGIN
        FOR V_C IN (SELECT * FROM TMP_COMMON WHERE F0 = p_SessionID)
          LOOP
              SELECT CARDSTATECODE INTO V_CARDSTATECODE FROM TD_XFC_INITCARD WHERE XFCARDNO = V_C.F1;
              IF V_CARDSTATECODE <> '4' THEN
                 p_retCode := 'A006007003';
                 p_retMsg  := '有不是激活状态的卡片';
                 rollback;
                 return;
              END IF;
              BEGIN
                update TD_XFC_INITCARD set ENDDATE = add_months(sysdate,12) where XFCARDNO = V_C.F1;
                IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
                EXCEPTION
                WHEN OTHERS THEN
                   P_RETCODE := 'S094390100';
                   P_RETMSG  := '更新充值卡账户表失败'||SQLERRM;      
                   ROLLBACK; RETURN;    
              END;
          END LOOP;
    END;
    BEGIN
    	 SP_GetSeq(seq => v_seqNo);
    	 INSERT INTO TL_XFC_MANAGELOG
            (ID,STAFFNO,OPERTIME,OPERTYPECODE,STARTCARDNO,ENDCARDNO)
        VALUES
            (v_seqNo,p_currOper,SYSDATE,'09',p_fromCardNo,p_toCardNo);
    		EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S007P04B02'; p_retMsg := '更新充值卡操作日志失败,' || SQLERRM;
        ROLLBACK; RETURN;
    END;
    p_retcode := '0000000000';
    p_retMsg  := '';
    COMMIT; 
    return;
end;

/
show errors;

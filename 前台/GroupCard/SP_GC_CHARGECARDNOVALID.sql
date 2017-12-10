
create or replace procedure SP_GC_CHARGECARDNOVALID
(
       P_VALUE         integer,
       P_FROMCARDNO    varchar2,
       P_TOCARDNO      varchar2,
       
       p_currOper      char,           -- Current Operator
       p_currDept      char,           -- Curretn Operator's Department
       p_retCode       out char,       -- Return Code
       p_retMsg        out varchar2    -- Return Message
)
AS
       v_fromCard      NUMERIC(14);
       v_toCard        NUMERIC(14);
	     v_cardNo        CHAR(14);
       v_beginNo       char(6);
       v_valueCode     Char;
       v_money         integer;
       v_quantity      integer;
       V_COUNT         INT;
       v_today         date;
       v_ex            EXCEPTION;
BEGIN
  
   v_today := sysdate;
   
   BEGIN
        
        v_fromCard := TO_NUMBER(substr(P_FROMCARDNO,7,8));
        v_toCard   := TO_NUMBER(substr(P_FROMCARDNO,7,8));
        v_quantity := v_toCard - v_fromCard + 1;
        v_beginNo := substr(P_FROMCARDNO,1,6);
        BEGIN
          
          LOOP
              
              v_cardNo := v_beginNo || lpad(to_char(v_fromCard),8,'0');
              
              select count(*) into V_COUNT from TD_XFC_INITCARD where XFCARDNO = v_cardNo;
              
              if V_COUNT < 1 then
                  p_retCode := 'A002666601'; 
                  p_retMsg  := '卡号'|| v_cardNo || '不在充值卡库存表里';
                  ROLLBACK; RETURN;
              end if;
              
              select ValueCode into v_valueCode from TD_XFC_INITCARD where XFCARDNO = v_cardNo;
              
              select MONEY into v_money from TP_XFC_CARDVALUE where VALUECODE = UPPER(v_valueCode);
              
              if v_money != P_VALUE then
              
                  p_retCode := 'A002666602'; 
                  p_retMsg  := '卡号'|| v_cardNo || '面额不正确';
                  ROLLBACK; RETURN;
              
              end if;
              
              EXIT WHEN  v_fromCard  >=  v_toCard;

              v_fromCard := v_fromCard + 1;
          END LOOP;
          
          EXCEPTION
          WHEN OTHERS THEN
          p_retCode := 'A002666603'; p_retMsg  :=  SQLERRM;
          ROLLBACK; RETURN;
          
        END;
   
   END;
   
   p_retCode := '0000000000'; 
   p_retMsg  := '';
    
   COMMIT; RETURN;
   
END;

/ 
show errors;

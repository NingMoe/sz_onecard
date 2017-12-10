CREATE OR REPLACE PROCEDURE SP_SD_AutoTransferRecycle
(
    p_sessionID         VARCHAR2,
    p_currOper	        CHAR,
    p_currDept	        CHAR,
    p_retCode           OUT CHAR,
    p_retMsg            OUT VARCHAR2
)
AS
    v_ID    varchar2(30);
    v_ex    EXCEPTION;
BEGIN
FOR cur_renewdata IN ( 
      SELECT f0   
        FROM tmp_common t WHERE f1 = p_sessionID) LOOP      
         
        v_ID   := cur_renewdata.f0;
   
        --b.update the CARDACCMONEY, TOTALCONSUMEMONEY, TOTALCONSUMETIMES info
        BEGIN
          UPDATE TI_TRADE_MANUAL                                         
           SET SOURCESTATE='2'                                                               
           WHERE ID = v_ID and SOURCESTATE='1';    
        
          IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
          EXCEPTION
            WHEN OTHERS THEN
              p_retCode := 'S009103009';
              p_retMsg  := '';
              ROLLBACK; RETURN;
        END;
 
              
        --c.update the LASTCONSUMETIME, OFFLINECARDTRADENO, CONSUMEREALMONEY
     
              
    END LOOP;
     p_retCode := '0000000000';
              p_retMsg  := '';
              COMMIT; RETURN;
END;

/
show errors

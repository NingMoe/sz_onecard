CREATE OR REPLACE PROCEDURE SP_SD_SpeAdjustAccPassVoid
(
    p_sessionID          VARCHAR2, 
    p_currOper           CHAR,      
    p_currDept           CHAR,         
    p_retCode            OUT CHAR,
    p_retMsg             OUT VARCHAR2
)
AS
    v_currdate   DATE := SYSDATE;
    v_quantity   INT;
    v_ex         EXCEPTION;
    
    v_tradeid    char(16);
    v_cardno	     CHAR(16);
    v_refundMoney  INT;

BEGIN
  
  
  
  
  --3) get the current recycle one by one records from TMP_ADJUSTACC_IMP
  BEGIN
    FOR cur_AdjAcc IN ( SELECT TRADEID,CARDNO, REFUNDMENT 
      FROM  TMP_ADJUSTACC_IMP WHERE SessionId = p_sessionID) LOOP
     
        v_cardno      := cur_AdjAcc.CARDNO;
        v_refundMoney := cur_AdjAcc.REFUNDMENT;
        v_tradeid     :=cur_adjacc.tradeid;
      
        --�ж��Ƿ����ͨ��������״̬
    select count(*) into v_quantity from TF_B_SPEADJUSTACC t where 
    TRADEID =v_tradeid and 
     t.statecode='1';
     if v_quantity=0 then
        p_retCode := 'PV00B10002';
        p_retMsg  := '���ţ�'||v_cardno||'������˴�����״̬������';
        ROLLBACK; RETURN;
     end if;
  --2) update TF_B_SPEADJUSTACC info
  BEGIN
    UPDATE TF_B_SPEADJUSTACC                                                                                                
      SET   STATECODE = '3',                                      
           CHECKSTAFFNO = p_currOper,
           CHECKTIME    = v_currdate                                                                    
    WHERE   TRADEID =v_tradeid;
    
    IF SQL%ROWCOUNT !=1 THEN RAISE v_ex; END IF;
    EXCEPTION
      WHEN OTHERS THEN
        p_retCode := 'S009111002';
        p_retMsg  := '';
        ROLLBACK; RETURN;
  END; 
      
      
        SELECT COUNT(*) INTO v_quantity FROM TF_SPEADJUSTOFFERACC WHERE CARDNO = v_cardno;
        
        --when the cardno has existed
        IF v_quantity >= 1 THEN
          
           BEGIN
		      	--update the TF_SPEADJUSTOFFERACC info
		        UPDATE TF_SPEADJUSTOFFERACC																													
			         SET OFFERMONEY = OFFERMONEY - v_refundMoney																											
			       WHERE CARDNO = v_cardno;
			       
			       IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
             EXCEPTION
               WHEN OTHERS THEN
                 p_retCode := 'S009111003';
                 p_retMsg  := '';
                 ROLLBACK; RETURN;
           END;				
        ELSE 
    		   	p_retCode := 'PV001B0001';
            p_retMsg  := '������ʿɳ�ֵ�˻������޿���Ϊ��'||v_cardno||'�ļ�¼';
            rollback;return;	 
        END IF;   
    END LOOP;
  END;                                                                                 
   p_retCode := '0000000000';
   p_retMsg  := '';
   COMMIT;RETURN;            
END;
/
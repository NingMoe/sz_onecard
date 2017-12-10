CREATE OR REPLACE PROCEDURE SP_PB_SaleCardRollback_COMMIT
(
		p_ID              char,
		p_CARDNO	      char,
		p_CARDTRADENO     char,
		p_CARDMONEY	      int,
		p_DEPOSIT         int,
		p_CARDCOST        int,
		p_CANCELTRADEID   char,
		p_TRADEPROCFEE    int,
		p_OTHERFEE        int,
		p_TERMNO		  char,
		p_OPERCARDNO			char,
		p_TRADEID    	    out char, -- Return Trade Id
		p_currOper	      char,
		p_currDept	      char,
		p_retCode	        out char, -- Return Code
		p_retMsg     	    out varchar2  -- Return Message

)
AS
    v_ex            exception;
BEGIN
	BEGIN
		SP_PB_SaleCardRollback(p_ID,p_CARDNO,p_CARDTRADENO,p_CARDMONEY,p_DEPOSIT,p_CARDCOST,p_CANCELTRADEID,
													p_TRADEPROCFEE,p_OTHERFEE,p_TERMNO,p_OPERCARDNO,p_TRADEID,p_currOper,p_currDept,
		                 			p_retCode,p_retMsg);
		                 
     IF p_retCode != '0000000000' THEN RAISE v_ex; END IF;
        EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK; RETURN;
   END;
   
   -- ����Ӫҵ���ֿ�Ԥ������ݱ�֤���޸Ŀ��쿨��ȣ�add by liuhe 20111230
   BEGIN
		 SP_PB_DEPTBALFEEROLLBACK(p_TRADEID, p_CANCELTRADEID,
					'3' ,--1Ԥ����,2��֤��,3Ԥ����ͱ�֤��
					 p_DEPOSIT + p_CARDCOST + p_OTHERFEE + p_CARDMONEY,
	                 p_currOper,p_currDept,p_retCode,p_retMsg);
		                 
     IF p_retCode != '0000000000' THEN RAISE v_ex; END IF;
        EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK; RETURN;
   END;
   
    
  p_retCode := '0000000000';
	p_retMsg  := '';
	COMMIT; RETURN;
END;

/

show errors
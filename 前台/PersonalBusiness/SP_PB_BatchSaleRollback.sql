CREATE OR REPLACE PROCEDURE SP_PB_BatchSaleRollback
(
		p_beginCardno			char,
		p_endCardno				char,
		p_OPERCARDNO			char,
		p_TRADEID    	    out char, -- Return Trade Id
		p_currOper	      char,
		p_currDept	      char,
		p_retCode	        out char, -- Return Code
		p_retMsg     	    out varchar2  -- Return Message

)
AS
		v_ID	            char(18);
		v_CARDNO					char(16);
		v_DEPOSIT	        int;
		v_CARDCOST	      int;
		v_CANCELTRADEID   char(16);
    v_ex          		exception;

BEGIN

	 BEGIN
		FOR cur_renewdata IN (
			  SELECT a.CARDNO, b.DEPOSIT, b.CARDCOST, c.TRADEID
				  FROM TL_R_ICUSER a, TF_F_CARDREC b, TF_B_TRADE c
				 WHERE a.CARDNO BETWEEN p_beginCardno AND p_endCardno and a.CARDNO = b.CARDNO
							 and a.CARDNO = c.CARDNO and c.TRADETYPECODE = '01'
				) LOOP

				v_ID := to_char(sysdate, 'mmddhh24miss') ||'0000' || SUBSTR(cur_renewdata.CARDNO,-4);
				v_CARDNO := cur_renewdata.CARDNO;
				v_DEPOSIT := cur_renewdata.DEPOSit;
				v_CARDCOST := cur_renewdata.CARDCOST;
				v_CANCELTRADEID := cur_renewdata.TRADEID;

		 BEGIN
				SP_PB_SaleCardRollback(v_ID, v_CARDNO, '', 0, v_DEPOSIT, v_CARDCOST, v_CANCELTRADEID, 0, 0,
								'112233445566', p_OPERCARDNO, p_TRADEID, p_currOper,p_currDept,p_retCode,p_retMsg);

				IF p_retCode != '0000000000' THEN RAISE v_ex; END IF;
		        EXCEPTION
		        WHEN OTHERS THEN
		        ROLLBACK; RETURN;
		   	END;
   		END LOOP;
   END;

	p_retCode := '0000000000';
	p_retMsg  := '';
	COMMIT; RETURN;
END;
/

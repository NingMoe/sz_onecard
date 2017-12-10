CREATE OR REPLACE PROCEDURE SP_PB_BatchSaleCard
(
		p_beginCardno		char,
		p_endCardno			char,
		p_DEPOSIT	        int,
		p_CARDCOST	      	int,
		p_OPERCARDNO		char,
		p_CURRENTTIME	    in out date, -- Return Operate Time
		p_TRADEID    	    out char, -- Return Trade Id
		p_currOper	      	char,
		p_currDept	      	char,
		p_retCode	        out char, -- Return Code
		p_retMsg     	    out varchar2  -- Return Message

)
AS
		v_fromCard 			NUMERIC(16);
		v_toCard   			NUMERIC(16);
		p_ID	            char(18);
		p_CARDNO			char(16);
		p_CARDTYPECODE	  	char(2);
		v_ex          		exception;
		v_count				int;
		v_quantity 			INT;

BEGIN
    IF p_CURRENTTIME IS NULL then
        p_CURRENTTIME := sysdate;
    END IF;

    IF p_CURRENTTIME NOT BETWEEN ADD_MONTHS(sysdate,-1) AND ADD_MONTHS(sysdate,1) THEN
            p_retCode := 'S001001010';
            p_retMsg  := 'Input time is not propble,' || SQLERRM;
        ROLLBACK; RETURN;
    end IF;
	--判断是否是出库、领用或分配状态
	SELECT count(*) INTO v_count
	FROM TL_R_ICUSER
	WHERE CARDNO BETWEEN p_beginCardno AND p_endCardno
	and RESSTATECODE in ('01','02','05');
	v_fromCard := TO_NUMBER(p_beginCardno);
    v_toCard   := TO_NUMBER(p_endCardno);
    v_quantity := v_toCard - v_fromCard + 1;
	if(v_count!=v_quantity) THEN
		p_retCode := 'A009801B01'; p_retMsg  := 'error';
        RETURN;
	end if;
		-- 1) Get system time

	BEGIN
			FOR cur_renewdata IN (
				SELECT CARDNO,ASN,CARDTYPECODE FROM TL_R_ICUSER
				WHERE CARDNO BETWEEN p_beginCardno AND p_endCardno
				) LOOP

				p_ID := to_char(sysdate, 'mmddhh24miss') ||'0000' || SUBSTR(cur_renewdata.ASN,-4);
				p_CARDNO := cur_renewdata.CARDNO;
				p_CARDTYPECODE := cur_renewdata.CARDTYPECODE;

		    BEGIN
				SP_PB_SALECARD_TIMEINPUT(p_ID,p_CARDNO,p_DEPOSIT,p_CARDCOST,0,'0000',p_CARDTYPECODE,
			                 0,'01','0','01','','','','','','','',
			                 '','','','0','112233445566',p_OPERCARDNO,
			                 p_CURRENTTIME,p_TRADEID,p_currOper,p_currDept,p_retCode,p_retMsg);

		    IF p_retCode != '0000000000' THEN RAISE v_ex; END IF;
		    EXCEPTION WHEN OTHERS THEN
		        ROLLBACK; RETURN;
		   	END;
   		END LOOP;
   END;

	p_retCode := '0000000000';
	p_retMsg  := '';
	COMMIT; RETURN;
END;
/

show errors
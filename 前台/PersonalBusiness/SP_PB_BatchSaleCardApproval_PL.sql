CREATE OR REPLACE PROCEDURE SP_PB_BatchSaleCardApproval
(
	p_TRADEID    	  out char, -- Return Trade Id
    p_stateCode       char,
	p_currOper	      char,
	p_currDept	      char,
	p_retCode	      out char, -- Return Code
	p_retMsg     	  out varchar2  -- Return Message

)
AS
	v_fromCard 			NUMERIC(16);
	v_toCard   			NUMERIC(16);
	p_ID	            char(18);
	p_CARDNO			char(16);
	p_CARDTYPECODE	    char(2);
    v_count				int;
	v_quantity 			int;
    v_ex          		exception;
	v_beginCardNo		char(16);
	v_endCardNo			char(16);
	v_cardDeposit		int;
	v_cardCost			int;
	v_sellTime			date;
	v_operateStaffNo	char(6);
	v_operateDepartId	char(4);
	v_operateTime		date;
BEGIN
if p_stateCode = '2' then
   BEGIN
   FOR v_cur in(
       SELECT f1 FROM TMP_COMMON
   ) LOOP
begin
	select BEGINCARDNO,ENDCARDNO,CARDDEPOSIT,CARDCOST,SELLTIME,OPERATESTAFFNO,OPERATEDEPARTID,OPERATETIME
	  into v_beginCardNo,v_endCardNo,v_cardDeposit,v_cardCost,v_sellTime,v_operateStaffNo,v_operateDepartId,v_operateTime
	from TF_B_BATCHSALECARD where TRADEID=v_cur.f1;
	EXCEPTION
		WHEN no_data_found THEN
			p_retCode := 'A00501B014';
			p_retMsg  := '未在批量售卡审批台帐表中查询出售卡记录' || SQLERRM;
end;
    BEGIN
       UPDATE TF_B_BATCHSALECARD SET
              STATECODE = '2',   --通过
              CHECKSTAFFNO    =  p_currOper,
              CHECKDEPARTID   =  p_currDept,
              CHECKTIME       =  SYSDATE
       WHERE TRADEID = v_cur.f1;
       IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION
          WHEN OTHERS THEN
              p_retCode := 'S00601B021';
              p_retMsg  := '批量售卡审批台帐表更新失败' || SQLERRM;
              ROLLBACK; RETURN;
    END;

    IF v_sellTime IS NULL then
        v_sellTime := sysdate;
    END IF;

    IF v_sellTime NOT BETWEEN ADD_MONTHS(sysdate,-1) AND ADD_MONTHS(sysdate,1) THEN
            p_retCode := 'S001001010';
            p_retMsg  := 'Input time is not propble,' || SQLERRM;
        ROLLBACK; RETURN;
    end IF;
	
    --判断是否是出库、领用或分配状态
    SELECT count(*) INTO v_count
    FROM TL_R_ICUSER
    WHERE CARDNO BETWEEN v_beginCardNo AND v_endCardNo
    and RESSTATECODE in ('01','02','05');
    v_fromCard := TO_NUMBER(v_beginCardNo);
      v_toCard   := TO_NUMBER(v_endCardNo);
      v_quantity := v_toCard - v_fromCard + 1;
    if(v_count!=v_quantity) THEN
      p_retCode := 'A009801B01'; p_retMsg  := 'error';
          ROLLBACK;RETURN;
    end if;
		
		-- 1) Get system time

    BEGIN
        FOR cur_renewdata IN (
          SELECT CARDNO,ASN,CARDTYPECODE FROM TL_R_ICUSER
          WHERE CARDNO BETWEEN v_beginCardNo AND v_endCardNo
          ) LOOP

          p_ID := to_char(sysdate, 'mmddhh24miss') ||'0000' || SUBSTR(cur_renewdata.ASN,-4);
          p_CARDNO := cur_renewdata.CARDNO;
          p_CARDTYPECODE := cur_renewdata.CARDTYPECODE;

          BEGIN
          SP_PB_SALECARD_TIMEINPUT(p_ID,p_CARDNO,v_cardDeposit,v_cardCost,0,'0000',p_CARDTYPECODE,
                         0,'01','0','01','','','','','','','',
                         '','','','0','112233445566','',
                         v_sellTime,p_TRADEID,v_operateStaffNo,v_operateDepartId,p_retCode,p_retMsg);

           IF p_retCode != '0000000000' THEN RAISE v_ex; END IF;
              EXCEPTION
              WHEN OTHERS THEN
              ROLLBACK; RETURN;
           END;
      END LOOP;
    END;
    END LOOP;
    END;
elsif p_stateCode = '3' then
     FOR v_cur in(
         SELECT f1 FROM TMP_COMMON
     ) LOOP
       BEGIN
       UPDATE TF_B_BATCHSALECARD SET
              STATECODE = '3',   --作废
              CHECKSTAFFNO    =  p_currOper,
              CHECKDEPARTID   =  p_currDept,
              CHECKTIME       =  SYSDATE
       WHERE TRADEID = v_cur.f1;
       IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
       EXCEPTION WHEN OTHERS THEN
              p_retCode := 'S00601B021';
              p_retMsg  := '批量售卡审批台帐表更新失败' || SQLERRM;
              ROLLBACK; RETURN;
       END;
     END LOOP;
end if;

	p_retCode := '0000000000';
	p_retMsg  := '';
	COMMIT; RETURN;
END;
/
show errors
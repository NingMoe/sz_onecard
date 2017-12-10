CREATE OR REPLACE 
PROCEDURE SP_LIB_OPENCHECK --图书馆卡开通校验
(
	p_retCode	          out char, -- Return Code
	p_retMsg     	      out varchar2,  -- Return Message
  p_retStatus     	      out char,  -- Return Status
	p_CARDNO	          char     --卡号
)
AS
	v_USETAG          char(1);
	v_Count          int;
	v_ex               exception;
BEGIN
	--判断卡是否在黑名单
	 BEGIN
		 SELECT COUNT(*) INTO v_Count FROM TF_B_WARN_BLACK t 
			WHERE t.CARDNO=p_CARDNO;
			IF v_Count = 1 THEN
                 RAISE V_EX;
          END IF;

          EXCEPTION WHEN OTHERS THEN
            p_retStatus := '02';
						p_retCode :='0000000000';
            p_retMsg :='该卡在黑名单中'||SQLERRM;
            RETURN;
	 END;

	--判断卡状态
	BEGIN
	  SELECT COUNT(*) INTO v_Count FROM TL_R_ICUSER  
			WHERE CARDNO=p_CARDNO AND RESSTATECODE='06';
			IF v_Count = 0 THEN
                 RAISE V_EX;
          END IF;

          EXCEPTION WHEN OTHERS THEN
            p_retStatus := '02';
						p_retCode :='0000000000';
            p_retMsg :='该卡不存在或卡片并未售出'||SQLERRM;
            RETURN;
	END;
	 
 --判断是否开通
	BEGIN
		SELECT COUNT(*) INTO v_Count  FROM TF_F_CARDUSEAREA WHERE CARDNO=p_CARDNO AND FUNCTIONTYPE='17'; 
			IF v_Count > 0 THEN
          BEGIN
						SELECT USETAG INTO v_USETAG  FROM TF_F_CARDUSEAREA WHERE CARDNO=p_CARDNO AND FUNCTIONTYPE='17'; 
						IF v_USETAG=1 THEN 
							 RAISE V_EX;
						END IF;

						EXCEPTION WHEN OTHERS THEN
							p_retStatus := '01';
							p_retCode :='0000000000';
							p_retMsg :='该卡已开通'||SQLERRM;
							RETURN;
           end;
      END IF;
	END;
		p_retStatus :='00';
		p_retCode := '0000000000';
    p_retMsg  := '';
    RETURN;
END;
/
show errors

CREATE OR REPLACE 
PROCEDURE SP_LIB_OPENCHECK --ͼ��ݿ���ͨУ��
(
	p_retCode	          out char, -- Return Code
	p_retMsg     	      out varchar2,  -- Return Message
  p_retStatus     	      out char,  -- Return Status
	p_CARDNO	          char     --����
)
AS
	v_USETAG          char(1);
	v_Count          int;
	v_ex               exception;
BEGIN
	--�жϿ��Ƿ��ں�����
	 BEGIN
		 SELECT COUNT(*) INTO v_Count FROM TF_B_WARN_BLACK t 
			WHERE t.CARDNO=p_CARDNO;
			IF v_Count = 1 THEN
                 RAISE V_EX;
          END IF;

          EXCEPTION WHEN OTHERS THEN
            p_retStatus := '02';
						p_retCode :='0000000000';
            p_retMsg :='�ÿ��ں�������'||SQLERRM;
            RETURN;
	 END;

	--�жϿ�״̬
	BEGIN
	  SELECT COUNT(*) INTO v_Count FROM TL_R_ICUSER  
			WHERE CARDNO=p_CARDNO AND RESSTATECODE='06';
			IF v_Count = 0 THEN
                 RAISE V_EX;
          END IF;

          EXCEPTION WHEN OTHERS THEN
            p_retStatus := '02';
						p_retCode :='0000000000';
            p_retMsg :='�ÿ������ڻ�Ƭ��δ�۳�'||SQLERRM;
            RETURN;
	END;
	 
 --�ж��Ƿ�ͨ
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
							p_retMsg :='�ÿ��ѿ�ͨ'||SQLERRM;
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

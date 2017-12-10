CREATE OR REPLACE PROCEDURE SP_CC_Sale_ChargeCard
(
    p_fromCardNo char,
    p_toCardNo   char,

    p_totalValue out int,
    p_quantity   out int,
    p_today      out date,
    p_seqNo      char,

    p_currOper  char,
    p_currDept  char,
    p_retCode   out char, -- Return Code
    p_retMsg    out varchar2  -- Return Message
)
AS
    v_fromCard     numeric(8);
    v_toCard       numeric(8);
    v_ex           exception ;
	V_TAGCOUNT   		INT;
	V_DEPTCOUNT   		INT;
	V_TAGMONEY			INT;
BEGIN
    p_today := sysdate;

    v_fromCard := TO_NUMBER(SUBSTR(p_fromCardNo, -8));
    v_toCard   := TO_NUMBER(SUBSTR(p_toCardNo  , -8));
    p_quantity := v_toCard - v_fromCard + 1;

    -- 1) Update the voucher card info
    BEGIN
        UPDATE TD_XFC_INITCARD
        SET    CARDSTATECODE = DECODE(CARDSTATECODE, '5', '5', '4'),
               ACTIVETIME    = p_today    ,
               ACTIVESTAFFNO = p_currOper ,
               SALETIME      = p_today    ,
               SALESTAFFNO   = p_currOper
        WHERE  XFCARDNO BETWEEN p_fromCardNo AND p_toCardNo
        AND    CARDSTATECODE in ('3', '4', '5')
        AND    ASSIGNDEPARTNO=p_currDept
        AND    SALETIME is null and SALESTAFFNO is null;

        IF  SQL%ROWCOUNT != p_quantity THEN RAISE v_ex; END IF;
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S007P04B01'; p_retMsg := '���³�ֵ��״̬ʧ��,' || SQLERRM;
        ROLLBACK; RETURN;
    END;

    -- 2) Log the card operation
    BEGIN
        INSERT INTO TL_XFC_MANAGELOG
            (ID,STAFFNO,OPERTIME,OPERTYPECODE,STARTCARDNO,ENDCARDNO)
        VALUES
            (p_seqNo,p_currOper,p_today,'04',p_fromCardNo,p_toCardNo);
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S007P04B02'; p_retMsg := '���³�ֵ���ۿ�������־ʧ��,' || SQLERRM;
        ROLLBACK; RETURN;
    END;

    -- 3) Log the sale log
    SELECT sum(v.MONEY) INTO p_totalValue
    FROM  TD_XFC_INITCARD t, TP_XFC_CARDVALUE v
    WHERE t.XFCARDNO BETWEEN p_fromCardNo AND p_toCardNo
    AND   t.VALUECODE = v.VALUECODE;

	---����Ӫҵ����ֵ�޶� add by liuhe20121113
	SELECT COUNT(*) INTO V_TAGCOUNT 
	FROM TD_M_TAG  WHERE TAGCODE='PROXY_CHARGE_LIMIT' AND USETAG='1';
    
	IF V_TAGCOUNT = 1 THEN
			SELECT  COUNT(*) INTO V_DEPTCOUNT 
			FROM 	TF_DEPT_BALUNIT B , TD_DEPTBAL_RELATION R
			WHERE 	B.DBALUNITNO = R.DBALUNITNO
					AND B.DEPTTYPE = '1'
					AND R.USETAG = '1'
					AND B.USETAG = '1'
					AND R.DEPARTNO = P_CURRDEPT;
			IF V_DEPTCOUNT = 1 THEN--����Ǵ���Ӫҵ��
				--��ѯ��ֵ�޶�
				SELECT TAGVALUE INTO V_TAGMONEY FROM TD_M_TAG WHERE TAGCODE='PROXY_CHARGE_LIMIT' AND USETAG='1';
				---������մ����ֵ�ܶ�����õ���������ʾ����
				--���ܽ������ۿ������жϵ��Ž�ǰ����ҳ��������ͬʱ�۳��ĳ�ֵ��������ͬ���棬���������������ʱ��Գ�ֵ��Ҳ��������
				IF p_totalValue/p_quantity > V_TAGMONEY THEN 
					P_RETCODE := 'A009010091';
					P_RETMSG := '�ڴ���������ſ��ۿ����ܳ���'||V_TAGMONEY/100.00||'Ԫ';
				RETURN;
				END IF;
			END IF;
	END IF;
	
    p_retCode := '0000000000'; p_retMsg  := '';
END;
/

show errors

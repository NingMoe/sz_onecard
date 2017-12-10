CREATE OR REPLACE PROCEDURE SP_AS_ZJGMonthlyCardCheck
(
   
    p_cardNo            char,
	p_OPERCARDNO		char,
	p_currOper            char,
    p_currDept            char,
	p_ENDDATE			  out char,
    p_retCode   out char, -- Return Code
    p_retMsg    out varchar2  -- Return Message
)
AS
    v_today         date := sysdate;
    v_ex            exception;
    v_seqNo         char(16);
	v_ENDDATE		char(8);
	v_APPTYPE		char(2);
	v_TRADETYPECODE	char(2);
	v_TradeID		char(16);
	v_quantity		int;
BEGIN

	--�ж��Ƿ��Ѿ���ͨ��Ʊ����
	select count(1) into v_quantity 
	from TF_F_CARDCOUNTACC
	where cardno=p_cardno and usetag='1';
	if (v_quantity=0) THEN
		p_retCode := 'SWD509B001'; p_retMsg  := '��Ʊ����û�п�ͨ�����ȿ�ͨ';
        RETURN;
	end if;
	BEGIN
	SELECT APPTYPE into v_APPTYPE
	FROM TF_F_CARDCOUNTACC
	WHERE CARDNO=p_CARDNO
	and usetag='1';
	EXCEPTION WHEN NO_DATA_FOUND THEN
		p_retCode := 'SWD509B001'; p_retMsg  := 'δ���ҵ���Ʊ���ͣ�����';
        RETURN;
	END;
	IF(v_APPTYPE not in ('11','12','16','17')) THEN
		p_retCode := 'SWD509B001'; p_retMsg  := '��Ʊ���Ͳ�����Ҫ��';
        RETURN;
	end if;
	SELECT DECODE(v_APPTYPE,'11','8D','12','9D','16','9K','17','9P') into v_TRADETYPECODE
	FROM dual;
	--���ʱ��Ϊ10-12�·�������һ�죬��Ϊ1-9������������Ч�ڵ�����ף�10-12������������Ч�ڵ���һ���
	
	if(to_char(v_today,'MM')>'09') THEN
		v_ENDDATE:=(to_char(v_today,'yyyy')+1)||'1231';
	ELSE
		v_ENDDATE:=to_char(v_today,'yyyy')||'1231';
		--p_retCode := 'SWD509B001'; p_retMsg  := '���ʱ��Ϊ10-12�·�������һ��';
        --RETURN;
	end if;
	p_ENDDATE:=v_ENDDATE;
	--������Ч��
    BEGIN
        UPDATE TF_F_CARDCOUNTACC
        SET 	ENDTIME=v_ENDDATE,
				APPTIME=v_today,
				APPSTAFFNO=p_currOper,
				UPDATESTAFFNO = p_currOper,
                UPDATETIME    = v_today
        WHERE   CARDNO       = p_cardNo;
        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S00512B001'; p_retMsg  := '���¾ɿ���Ʊ������ʧ��,' || SQLERRM;
        ROLLBACK; RETURN;
    END;
	SP_GetSeq(seq => v_TradeID);
	--���̨��
	
     -- 2) Log the operate
    BEGIN
		    INSERT INTO TF_B_TRADE          
		        (TRADEID,TRADETYPECODE,CARDNO,ASN,CARDTYPECODE,OPERATESTAFFNO,OPERATEDEPARTID,        
		        OPERATETIME)     
			SELECT 	v_TradeID,v_TRADETYPECODE,p_CARDNO,ASN,CARDTYPECODE,p_currOper,p_currDept, v_today 
			FROM tl_r_icuser
			WHERE cardno=p_cardno;

		EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S001008106';
	            p_retMsg  := 'Error occurred while log the operation' || SQLERRM;
	            ROLLBACK; RETURN;
    END;
	--д��̨��
	BEGIN
		    INSERT INTO TF_CARD_TRADE
		    		(TRADEID,TRADETYPECODE,strOperCardNo,strCardNo,OPERATETIME,SUCTAG,strEndDateNum)
		    VALUES
		    		(v_TradeID,v_TRADETYPECODE,p_OPERCARDNO,p_CARDNO,v_today,'0',v_ENDDATE);

		EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S001001139';
	            p_retMsg  := 'Fail to log the writeCard' || SQLERRM;
	            ROLLBACK; RETURN;
    END;
    p_retCode := '0000000000'; p_retMsg  := '';
    COMMIT; RETURN;
END;
/

show errors

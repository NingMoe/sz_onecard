/* ------------------------------------
Copyright (C) 2012-2013 linkage Software 
 All rights reserved.
<author>jiangbb</author>
<createDate>2012-08-24</createDate>
<description>公交测试卡维护</description>
------------------------------------ */
CREATE OR REPLACE PROCEDURE SP_SD_TESTTOBUSCARD
(
    p_beginCardNo       VARCHAR2,		--起始卡号
    p_endCardNo 	    VARCHAR2,		--终止卡号
	p_dealType			char,		--处理类型 0增加 1删除
	
	p_currOper          char,
    p_currDept          char,
    p_retCode   out char, -- Return Code
    p_retMsg    out varchar2  -- Return Message
)
AS
    v_seqNo   			CHAR(16); 		--序号
	v_fromCard 			NUMERIC(16);
	v_toCard   			NUMERIC(16);	
	v_asn      			CHAR(16);
	v_cardNo   			CHAR(16);	
	V_QUANTITY          INT        ;   --数量
	v_paperNo			char;
	v_ex				EXCEPTION;
BEGIN
	
	--测试卡片数量
	V_QUANTITY :=SUBSTR(p_endCardNo,-8)-SUBSTR(p_beginCardNo,-8)+1;
	
	--get seq
	SP_GetSeq(seq => v_seqNo);
	
	IF	p_dealType = '0' THEN	--增加
	
		--判断卡号段在库中有没有记录
		SELECT COUNT(A.CARDNO) INTO V_QUANTITY FROM TF_BUS_TESTCARD A 
			WHERE A.CARDNO BETWEEN p_beginCardNo AND p_endCardNo;
		IF V_QUANTITY > 0	THEN
			p_retCode := 'S094780015';
		    p_retMsg  := '卡号在库中已存在';
		    ROLLBACK; RETURN;
		END IF;
		
		--to_number
		v_fromCard := TO_NUMBER(p_beginCardNo);
		v_toCard   := TO_NUMBER(p_endCardNo);
		
		--插入公交消费测试卡
		BEGIN
			LOOP
				v_cardNo := SUBSTR('0000000000000000' || TO_CHAR(v_fromCard), -16);
				v_asn    := '00215000' || SUBSTR(v_cardNo, -8);
				
				INSERT INTO TF_BUS_TESTCARD
					(ASN,CARDNO,OPERATESTAFFNO,OPERATEDEPARTID,OPERATETIME,USETAG,RSRVCHAR)
				VALUES(v_asn,v_cardNo,p_currOper,p_currDept,sysdate,'0','');
				
				EXIT WHEN	v_fromCard >= v_toCard;
					
				v_fromCard := v_fromCard + 1;	
			END LOOP;
		EXCEPTION
			WHEN OTHERS THEN
				p_retCode := 'S094780016'; p_retMsg  := '插入公交消费测试卡表失败' || SQLERRM;
				ROLLBACK; RETURN;	
		END;

	ELSIF p_dealType = '1' THEN
		--删除公交消费测试卡
		BEGIN
			DELETE FROM TF_BUS_TESTCARD WHERE CARDNO BETWEEN p_beginCardNo AND p_endCardNo;
		EXCEPTION
			WHEN OTHERS THEN
				p_retCode := 'S094780018'; p_retMsg  := '删除公交消费测试卡表失败' || SQLERRM;
				ROLLBACK; RETURN;		
		END;
	END IF;
	
	--记录公交消费测试卡操作台帐
	BEGIN
		INSERT INTO TF_B_BUS_TESTCARD(TRADEID,BEGINCARDNO,ENDCARDNO,USETAG,OPERATESTAFFNO,OPERATEDEPARTID,OPERATETIME,DEALTYPE)
			VALUES(v_seqNo,p_beginCardNo,p_endCardNo,'0',p_currOper,p_currDept,sysdate,p_dealType);
			
	EXCEPTION
		WHEN OTHERS THEN
		    p_retCode := 'S094780017'; p_retMsg  := '插入公交消费测试卡操作台帐表失败'|| SQLERRM;
		    ROLLBACK; RETURN;
	END;

    p_retCode := '0000000000'; p_retMsg := '';
    COMMIT; RETURN;
END;
/

show errors
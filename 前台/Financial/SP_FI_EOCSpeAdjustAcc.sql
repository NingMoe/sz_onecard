CREATE OR REPLACE PROCEDURE SP_FI_EOCSpeAdjustAcc
(
    P_FUNCTION          VARCHAR, --���ܱ���
    p_DATE              CHAR,    --����
    p_CateGory          CHAR,    --��֧���
    p_money             INT,     --���
    p_remark            VARCHAR, --��ע
	p_TYPE				CHAR,	 --ҵ������
	p_TRADETYPE			CHAR,	 --��������
	p_BFJTRADETYPECODE	CHAR,	 --֧��ҵ�����ͱ���
	p_ISCASH			CHAR,	 --�Ƿ��ֽ� 0���ֽ� 1�ֽ�
	p_ACCOUNT			CHAR,	 --�ʽ��˻�
    P_ID                CHAR,
    p_currOper          char,
    p_currDept          char,
    p_retCode       out char, -- Return Code
    p_retMsg        out varchar2  -- Return Message    
)
AS
	V_SEQNO     	CHAR(16);
	V_COUNT			INT;
    v_ex             exception;
	v_CateGofry      varchar2(20);
BEGIN
    IF P_FUNCTION = 'ADD' THEN
		IF p_TYPE = '1' THEN
			BEGIN
				--��¼�����ʽ������
				insert into TF_FUNDSANALYSIS(
					ID          , STATTIME   , CATEGORY   , NAME  ,
					MONEY       , REMARK
				)values(
					sys_guid()  , p_date     , p_category , '�������',
					decode(p_CateGory,'�����ʽ�����',p_money,-abs(p_money)), p_remark);

				IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
			EXCEPTION
				WHEN OTHERS THEN
					p_retCode := 'S094570360';
					p_retMsg  := '��¼�����ʽ������ʧ��' || SQLERRM;
					ROLLBACK; RETURN;
			END;
		ELSIF p_TYPE = '2' THEN
			SP_GETSEQ(SEQ => V_SEQNO);
			BEGIN
			--��¼ҵ�������б�
			INSERT INTO TF_F_BFJ_TRADERECORD
			(TRADEID,TRADEDATE,NAME,AMOUNTTYPE,TRADETYPECODE,TRADEMONEY,
			FEE,BFJTRADETYPECODE,OTHERBANK,OTHERUSERNAME,OTHERBANKACCOUNT,ISCASH,
			DEPARTID,USEDMONEY,LEFTMONEY,ISNEEDMATCH,ACCOUNT,REMARK)
			VALUES
			(V_SEQNO,TO_DATE(p_date,'YYYYMMDD'),p_remark||':�������ֹ�¼��',decode(p_CateGory,'�����ʽ�����','0','1'),p_TRADETYPE,p_money,
			'',p_BFJTRADETYPECODE,'','','',p_ISCASH,
			p_currDept,'0',p_money,'0',p_ACCOUNT,p_remark);
			
				IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
			EXCEPTION
				WHEN OTHERS THEN
					p_retCode := 'S094570467';
					p_retMsg  := '��¼ҵ�������б�ʧ��' || SQLERRM;
					ROLLBACK; RETURN;
			END;

		END IF;
    END IF;
    
    IF P_FUNCTION = 'DELETE' THEN
		IF p_TYPE = '1' THEN
			BEGIN
				--ɾ�������ʽ������
				DELETE FROM TF_FUNDSANALYSIS WHERE ID = p_ID;
				
				IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
			EXCEPTION
				WHEN OTHERS THEN
					p_retCode := 'S094570361';
					p_retMsg  := 'ɾ�������ʽ�������¼ʧ��' || SQLERRM;
					ROLLBACK; RETURN;        
			END;
		ELSIF p_TYPE = '2' THEN
			
			BEGIN
				SELECT COUNT(1) INTO V_COUNT FROM TF_F_BFJ_TRADERECORD T WHERE T.TRADEID = P_ID AND T.LEFTMONEY = '0';
				EXCEPTION 
					WHEN NO_DATA_FOUND THEN NULL;
			END;
			
			IF V_COUNT > 0 THEN
				p_retCode := 'S094570421';
				p_retMsg  := 'ҵ���¼�Ѿ�ʹ�ã�������ɾ��';
				ROLLBACK; RETURN;  
			END IF;
		
			BEGIN
				--ɾ��ҵ�������б�
				DELETE FROM TF_F_BFJ_TRADERECORD WHERE TRADEID = p_ID;
				
				IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
			EXCEPTION
				WHEN OTHERS THEN
					p_retCode := 'S094570468';
					p_retMsg  := 'ɾ��ҵ�������б��¼ʧ��' || SQLERRM;
					ROLLBACK; RETURN;
			END;
		END IF;
    END IF;
    
    p_retCode := '0000000000';
    p_retMsg  := '';
    COMMIT; RETURN;    
END;

/
SHOW ERRORS
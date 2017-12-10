 --ͼ���ҵ��
CREATE OR REPLACE PROCEDURE SP_LIB_CARDTRADE      
(
		p_retCode	          out char, -- Return Code
		p_retMsg     	      out varchar2,  -- Return Message
		p_SYNCTRADEID       char,     --ͬ����ˮ��
    	P_TRADETYPECODE     VARCHAR2, --01��ͨ,02��ͨ�ر�,03��ʧ�ر�,04���,05����(����ʹ��SP_LIB_CHANGECARDTRADE)
		p_CARDNO	          char,     --����
		p_SOCLSECNO         char,     --�籣��
		p_CUSTNAME	        varchar2, --�û�����
		p_CUSTBIRTH	        varchar2, --��������
		p_PAPERTYPECODE	    varchar2, --֤������
		p_PAPERNO        	  varchar2, --֤������
		p_CUSTSEX	          varchar2, --�û��Ա�
		p_CUSTADDR	        varchar2, --��ϵ��ַ
		p_CUSTPOST	        varchar2, --��������
		p_CUSTPHONE	        varchar2, --��ϵ�绰
		p_CUSTEMAIL         varchar2, --�����ʼ�
		p_OLDCARDNO         char,     --�ɿ�����
		p_REMARK	          varchar2, --��ע

		p_TRADEORIGIN       varchar2, --ҵ����Դ

		p_ENDTIME           char,     --��Чʱ��
		p_currOper	        char,
		p_currDept	        char
)
AS
    	v_Count          int;
    	v_today            DATE := sysdate;
    	v_TradeID          char(16);
		v_USETAG          char(1);
		v_USETAGDB          char(1);
		v_TRADETYPECODE    char(2);
    	v_ex               exception;
		v_retCode          CHAR(10);
    	v_retMsg           VARCHAR2(200);
BEGIN
	
	--1)�жϿ��Ƿ��ں�����
	 BEGIN
		 SELECT COUNT(*) INTO v_Count FROM TF_B_WARN_BLACK t 
			WHERE t.CARDNO=p_CARDNO;
			IF v_Count = 1 THEN
                 RAISE V_EX;
          END IF;

          EXCEPTION WHEN OTHERS THEN
            p_retCode := '0000000001';
            p_retMsg :='�ÿ��ں�������'||SQLERRM;
            RETURN;
	 END;

	--2)�жϿ�״̬
	BEGIN
	  SELECT COUNT(*) INTO v_Count FROM TL_R_ICUSER  
			WHERE CARDNO=p_CARDNO AND (RESSTATECODE='06'OR substr(p_CARDNO,5,2)='18');
			IF v_Count = 0 THEN
                 RAISE V_EX;
          END IF;

          EXCEPTION WHEN OTHERS THEN
            p_retCode := '0000000002';
            p_retMsg :='�ÿ������ڻ�Ƭ��δ�۳�'||SQLERRM;
            RETURN;
	END;
	
	--3)��ѯ�Ƿ���ڿ���ͨ�رռ�¼
		BEGIN
			SELECT COUNT(*) INTO v_Count FROM TF_F_CARDUSEAREA WHERE CARDNO=p_CARDNO AND FUNCTIONTYPE='17'; 
		END;


	--4)ҵ�����͸�ֵ
		IF (P_TRADETYPECODE ='01') THEN --��ͨ
			v_USETAG :='1';
			v_TRADETYPECODE :='85';
		ELSIF	(P_TRADETYPECODE ='02') THEN --��ͨ�ر�
			v_USETAG :='0';
			v_TRADETYPECODE :='86';
		ELSIF	(P_TRADETYPECODE ='03') THEN --��ʧ�ر�
			v_USETAG :='0';
			v_TRADETYPECODE :='86';
		ELSIF	(P_TRADETYPECODE ='04') THEN --���
			v_USETAG :='1';
			v_TRADETYPECODE :='85';
		END IF;

	--5) �м�¼����£��޼�¼�����
		IF v_Count = 0 THEN
			BEGIN 
					insert into TF_F_CARDUSEAREA(CARDNO,FUNCTIONTYPE,USETAG,ENDTIME,UPDATESTAFFNO,UPDATETIME,RSRV1,RSRV2)
					values(p_CARDNO,'17',v_USETAG, p_ENDTIME,p_currOper,v_today,p_REMARK,'') ;
					IF SQL%ROWCOUNT != 1 THEN
							RAISE V_EX;
					END IF;

						EXCEPTION WHEN OTHERS THEN
							p_retCode := '0000000001';
							p_retMsg :='����ͼ��ݹ���ʧ��'||SQLERRM;
							RETURN;
			END;
		ELSE 
			--)���¿���ͨ���߹ر�
			BEGIN
				UPDATE TF_F_CARDUSEAREA SET USETAG=v_USETAG,
				     ENDTIME=p_ENDTIME,
				     UPDATESTAFFNO=p_currOper,
				     UPDATETIME=v_today,
				     RSRV1=p_REMARK 
					WHERE CARDNO = p_CARDNO AND FUNCTIONTYPE='17';
				IF SQL%ROWCOUNT != 1 THEN
                 RAISE V_EX;
				END IF;

				EXCEPTION WHEN OTHERS THEN
				p_retCode := '0000000002';
				p_retMsg :='���¿�ͼ��ݹ���ʧ��'||SQLERRM;
				RETURN;
			END;
		END IF;

 -- 4) Get trade id
    SP_GetSeq(seq => v_TradeID);


-- 5)д����̨��
    BEGIN
		INSERT INTO TF_B_TRADE(
			TRADEID           , TRADETYPECODE     , CARDNO         ,OPERATESTAFFNO    ,
      OPERATEDEPARTID , OPERATETIME       , TRADEORIGIN
	   )VALUES(
			v_TradeID       , v_TRADETYPECODE   , p_CARDNO      ,p_currOper  ,
      p_currDept      , v_today           ,  p_TRADEORIGIN
			);

       IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
		EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := '0000000003';
	            p_retMsg  := '������̨�˼�¼��ʧ��' || SQLERRM;
	            RETURN;
    END;

 -- 6)д��ͼ�����̨�˱�
    BEGIN
		INSERT INTO TF_B_LIB_TRADE(
				TRADEID        ,SYNCTRADEID       ,TRADETYPECODE   ,CARDNO             ,
				SOCLSECNO      ,NAME              ,PAPERTYPECODE   ,PAPERNO            ,
				BIRTH          ,SEX               ,PHONE           ,CUSTPOST           ,
				ADDR           ,EMAIL             ,OLDCARDNO       ,OPERATESTAFFNO     ,
        OPERATETIME    ,RSRV1             ,RSRV2           ,RSRV3
				)VALUES(
				v_TradeID      ,p_SYNCTRADEID     ,P_TRADETYPECODE ,p_CARDNO          ,
				p_SOCLSECNO    ,p_CUSTNAME        ,p_PAPERTYPECODE ,p_PAPERNO         ,
				p_CUSTBIRTH    ,p_CUSTSEX         ,p_CUSTPHONE     ,p_CUSTPOST         ,
				p_CUSTADDR     ,p_CUSTEMAIL       ,p_OLDCARDNO     ,p_currOper         ,
				v_today        ,p_REMARK          ,''              ,''                 );
   IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
		EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := '0000000004';
	            p_retMsg  := '����ͼ���ҵ��̨�˱�ʧ��' || SQLERRM;
	            RETURN;         
		END;

    p_retCode := '0000000000';
    p_retMsg  := '';
    RETURN;
END;

/
show errors

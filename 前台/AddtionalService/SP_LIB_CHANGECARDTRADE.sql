--ͼ��ݻ���ҵ��
CREATE OR REPLACE PROCEDURE SP_LIB_CHANGECARDTRADE  
(
		p_retCode	          out char, -- Return Code
		p_retMsg     	      out varchar2,  -- Return Message
		p_SYNCTRADEID       char,     --ͬ����ˮ��
		P_TRADETYPECODE     VARCHAR2, --05 ����
		p_NEWCARDNO	        char,     --����
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
		p_REMARK	          varchar2, --��ע
		p_OLDCARDNO         char,     --�ɿ�����
		
		p_TRADEORIGIN       varchar2, --ҵ����Դ
	
		p_ENDTIME           char,     --��Чʱ��
		p_currOper	        char,
		p_currDept	        char
)
AS
		v_oldCount          int;
		v_newCount          int;
    	v_today            DATE := sysdate;
    	v_TradeID          char(16);
		v_USETAG           char(1);
		v_TRADETYPECODE    char(2);
    	v_ex               exception;
		v_retCode          CHAR(10);
    	v_retMsg           VARCHAR2(200);
		v_RESSTATECODE       char(2); 
BEGIN


--1)�жϿ��Ƿ��ں�����
	 BEGIN
		 SELECT COUNT(*) INTO v_newCount FROM TF_B_WARN_BLACK t 
			WHERE t.CARDNO=p_NEWCARDNO;
			IF v_newCount = 1 THEN
                 RAISE V_EX;
          END IF;

          EXCEPTION WHEN OTHERS THEN
            p_retCode := '0000000001';
            p_retMsg :='�ÿ��ں�������'||SQLERRM;
            RETURN;
	 END;

--2)�жϿ�״̬
	BEGIN
	  SELECT COUNT(*) INTO v_newCount FROM TL_R_ICUSER  
			WHERE CARDNO=p_NEWCARDNO AND (RESSTATECODE='06'OR substr(p_NEWCARDNO,5,2)='18');
			IF v_newCount = 0 THEN
                 RAISE V_EX;
          END IF;

          EXCEPTION WHEN OTHERS THEN
            p_retCode := '0000000002';
            p_retMsg :='�ÿ������ڻ�Ƭ��δ�۳�'||SQLERRM;
            RETURN;
	END;


	
--3)��ѯ�ɿ��Ƿ���ڿ���ͨ�رռ�¼
    BEGIN
      SELECT COUNT(*) INTO v_oldCount FROM TF_F_CARDUSEAREA WHERE CARDNO=p_OLDCARDNO AND FUNCTIONTYPE='17'; 
    END;
	
--4)�����¾ɿ�ͼ���״̬

    IF v_oldCount = 1 THEN --�ɿ��п�ͨ�رռ�¼
      
		--��ѯ�ɿ�״̬
		BEGIN 
			SELECT USETAG INTO v_USETAG FROM TF_F_CARDUSEAREA WHERE CARDNO=p_OLDCARDNO AND FUNCTIONTYPE='17'; 
		END;
		
		-- A���¿�Ĭ�Ͽ�ͨ
		
		IF (substr(p_NEWCARDNO,5,2)='18') THEN
			v_USETAG:= '1';
		END IF;
      
		--�ɿ��ر�ͼ��ݹ���
		BEGIN
			UPDATE TF_F_CARDUSEAREA SET USETAG='0' WHERE CARDNO = p_OLDCARDNO AND FUNCTIONTYPE='17';
            IF SQL%ROWCOUNT != 1 THEN
			RAISE V_EX;
			END IF;

			EXCEPTION WHEN OTHERS THEN
			p_retCode :=  '0000000003';
			p_retMsg :='�رվɿ�ͼ��ݹ���ʧ��'||SQLERRM;
			RETURN;
		END;
      
		--��ѯ�¿�����ͼ��ݿ�ͨ�رռ�¼
		BEGIN 
			SELECT COUNT(*) INTO v_newCount FROM TF_F_CARDUSEAREA WHERE CARDNO=p_NEWCARDNO AND FUNCTIONTYPE='17'; 
		END;
      
		if v_newCount=0 THEN
		--�޼�¼�����¼�¼
			BEGIN 
				insert into TF_F_CARDUSEAREA(CARDNO,FUNCTIONTYPE,USETAG,ENDTIME,UPDATESTAFFNO,UPDATETIME,RSRV1,RSRV2)
				values(p_NEWCARDNO,'17',v_USETAG, p_ENDTIME,p_currOper,v_today,p_REMARK,'') ;
				  IF SQL%ROWCOUNT != 1 THEN
					  RAISE V_EX;
				  END IF;

				  EXCEPTION WHEN OTHERS THEN
					p_retCode := '0000000004';
					p_retMsg :='��ͨ�¿�ͼ��ݹ���ʧ��'||SQLERRM;
				  RETURN;
			END;
		ELSE
		--�м�¼����
        BEGIN
			UPDATE TF_F_CARDUSEAREA SET USETAG=v_USETAG,
                        ENDTIME=p_ENDTIME,
                        UPDATESTAFFNO=p_currOper,
                        UPDATETIME=v_today,
                        RSRV1=p_REMARK
              WHERE CARDNO=p_NEWCARDNO AND FUNCTIONTYPE='17'; 
              IF SQL%ROWCOUNT != 1 THEN
              RAISE V_EX;
              END IF;

              EXCEPTION WHEN OTHERS THEN
                p_retCode := '0000000005';
                p_retMsg :='��ͨ�¿�ͼ��ݹ���ʧ��'||SQLERRM;
              RETURN;
            END;
		END IF;
      
		-- 3) Get trade id
		SP_GetSeq(seq => v_TradeID);

		-- 4) �¿���ͨʱ������̨��
		IF v_USETAG='1' THEN
			BEGIN
				INSERT INTO TF_B_TRADE(
					TRADEID         , TRADETYPECODE       , CARDNO        ,OLDCARDNO   ,
					  OPERATESTAFFNO  , OPERATEDEPARTID     , OPERATETIME   ,TRADEORIGIN
				)VALUES(
					v_TradeID       , '85'         , p_NEWCARDNO   , p_OLDCARDNO       , 
					  p_currOper     , p_currDept         ,    v_today      ,p_TRADEORIGIN
					);
				
				EXCEPTION
				WHEN OTHERS THEN
				p_retCode := '0000000006';
				p_retMsg  := '������̨�˼�¼��ʧ��' || SQLERRM;
				RETURN;
			END;
		END IF;
    
		-- 5) �ɿ��ر���̨��
         BEGIN
			INSERT INTO TF_B_TRADE(
			TRADEID         , TRADETYPECODE       , CARDNO        ,OLDCARDNO       ,
                OPERATESTAFFNO  , OPERATEDEPARTID     , OPERATETIME   ,TRADEORIGIN
			)VALUES(
			v_TradeID       , '86'                , p_OLDCARDNO   , ''          , 
                p_currOper     , p_currDept         ,    v_today      ,p_TRADEORIGIN
      );
          
      EXCEPTION
      WHEN OTHERS THEN
      p_retCode := '0000000007';
      p_retMsg  := '������̨�˼�¼��ʧ��' || SQLERRM;
      RETURN;
      END;


    -- 6) ����д��ͼ�����̨�˱�

      BEGIN
        INSERT INTO TF_B_LIB_TRADE(
            TRADEID        ,SYNCTRADEID       ,TRADETYPECODE   ,CARDNO             ,
            SOCLSECNO      ,NAME              ,PAPERTYPECODE   ,PAPERNO            ,
            BIRTH          ,SEX               ,PHONE           ,CUSTPOST           ,
            ADDR           ,EMAIL             ,OLDCARDNO       ,OPERATESTAFFNO     ,
        OPERATETIME    ,RSRV1             ,RSRV2           ,RSRV3
            )VALUES(
            v_TradeID      ,p_SYNCTRADEID     ,'05'            ,p_NEWCARDNO        ,
            p_SOCLSECNO    ,p_CUSTNAME        ,p_PAPERTYPECODE ,p_PAPERNO          ,
            p_CUSTBIRTH    ,p_CUSTSEX         ,p_CUSTPHONE     ,p_CUSTPOST         ,
            p_CUSTADDR     ,p_CUSTEMAIL       ,p_OLDCARDNO     ,p_currOper         ,
            v_today        ,''                ,''              ,''                 );
       IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
        EXCEPTION
          WHEN OTHERS THEN
            p_retCode := '000000008';
            p_retMsg  := '����ͼ���ҵ��̨�˱�ʧ��' || SQLERRM;
            RETURN;         
        END;
      
    END IF;
	p_retCode := '0000000000';
     p_retMsg  := '';
END;

/
show errors
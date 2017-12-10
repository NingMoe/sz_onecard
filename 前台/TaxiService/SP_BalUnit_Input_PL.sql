

CREATE OR REPLACE PROCEDURE SP_BalUnit_Input
(   
   p_CALLINGNO	      CHAR,             --��ҵ����
   p_CORPNO	          CHAR,             --��λ����
   p_DEPARTNO	        CHAR,             --���ű���
   p_CALLINGSTAFFNO   CHAR,             --��ҵԱ����     
   p_BANKCODE	        CHAR,             --�������б���
   p_BANKACCNO	      VARCHAR2,         --�����˺�
   p_SERMANAGERCODE	  CHAR,             --�̻��������
   p_currOper	        CHAR,             --����Ա��   
   p_currDept	        CHAR,             --����Ա�����ڲ���      
   p_retCode   	      OUT CHAR,         --���ش���
   p_retMsg     	    OUT VARCHAR2      --������Ϣ
                                           
)
AS
   v_quantity         INT;                 --��ʱ����    
   v_currdate         DATE := SYSDATE;     --��ǰ����
   v_seqNo            CHAR(16);            --ҵ����ˮ��  
   
                                            
   v_balComsID        CHAR(8);             --���㵥Ԫ��ӦӶ�𷽰�ID                                        
   v_COMSCHEMENO      CHAR(8);             --Ӷ�𷽰�����
   
   v_BALUNITNO        CHAR(8);             --���㵥Ԫ����(��ҵ���� + ��ҵԱ������)  
   v_BALUNIT          VARCHAR2(50);         --���㵥Ԫ����                            
   v_BALUNITTYPECODE	CHAR(2) := '03';     --��Ԫ���ͱ���(00��ҵ,01��λ,02����,03��ҵԱ��)
   v_CHANNELNO    	  CHAR(4);             --ͨ������
   v_SOURCETYPECODE	  CHAR(2) := '02';     --��Դʶ�����ͱ���(00PSAM����,01��Ϣͤ�ɷ���������ֵ, 02���⳵˾������)
   v_BALLEVEL       	CHAR(1) := '2';      --���㼶�����
                                           
   v_BALCYCLETYPECODE	CHAR(2);             --�����������ͱ���(00Сʱ,01��,02��,03�̶���,04 ��Ȼ��)
   v_BALINTERVAL	    INT;                 --�������ڿ��
                                           
   v_FINCYCLETYPECODE	CHAR(2);             --�����������ͱ���(00Сʱ,01��,02��,03�̶���,04 ��Ȼ��)
   v_FININTERVAL	    INT;                 --�������ڿ��
                                           
   v_FINTYPECODE	    CHAR(1) := '0';      --ת������(0������ת��,1����ת��)
                                           
   v_COMFEETAKECODE	  CHAR(1) := '0';      --Ӷ��ۼ���ʽ����(0����ת�˽��ۼ�,1ֱ�Ӵ�ת�˽��ۼ�)
   v_FINBANKCODE	    CHAR(4) := '';       --ת�������д���(Ϊ��)
      
      
   v_LINKMAN	        VARCHAR2(20) := '';   --��ϵ��
	 v_UNITPHONE	      VARCHAR2(20) := '';   --��ϵ�绰
	 v_UNITADD	        VARCHAR2(50) := '';   --��ϵ��ַ
	 
	 v_USETAG         	CHAR(1) := '1'    ;  --��Ч��־
	 
	 
	 v_STAFFNAME	        VARCHAR2(20) := '';   --��ҵԱ������
	 v_STAFFPAPERTYPECODE	CHAR(2) := '';        --Ա��֤������
	 v_STAFFPAPERNO	      VARCHAR2(20) := '';   --Ա��֤������
	
	 v_STAFFMOBILE	      VARCHAR2(15) := '';   --Ա���ƶ��绰
   v_STAFFPOST	        VARCHAR2(6) := '';    --�ʱ��ַ	  
   v_STAFFEMAIL	        VARCHAR2(30) := '';   --EMAIL��ַ	
   v_STAFFSEX	          CHAR(1) := '';        --Ա���Ա�	  
   v_OPERCARDNO	        VARCHAR2(16) := '';   --Ա������	  
   v_OPERCARDPWD	      VARCHAR2(8) := '';    --Ա��������	
	 v_COLLECTCARDNO	    VARCHAR2(16) := '';   --�ɼ�����
   v_COLLECTCARDPWD	    VARCHAR2(8) := '';    --�ɼ�������	
   v_POSID	            CHAR(8) := '';        --POS���	
   v_CARNO	            CHAR(8) := '';        --����
      
   v_eventHead          CHAR(2) := '00';      --�¼����ͱ���ͷ(00)    
     
	 v_EVENTTYPECODE    	CHAR(4);              --�¼����ͱ���(�¼����ͱ���ͷ + ҵ�����ͱ���)
     
   v_TRADETYPECODE      CHAR(2);              --ҵ�����ͱ���                    
   
BEGIN 
	
  --1) ���ɽ��㵥Ԫ����
  v_BALUNITNO :=  p_CALLINGNO || p_CALLINGSTAFFNO;
	
	--2)��ͬ��ҵ�µĽ��㵥Ԫ��ز�����ֵ
	BEGIN
		--IF p_CALLINGNO = '01' THEN
		  --������ҵ
		  --v_CHANNELNO        := 'A002';
		  
		  --v_BALCYCLETYPECODE := '01';
		  --v_BALINTERVAL      := 1;
		  
		  --v_FINCYCLETYPECODE := '01';
		  --v_FININTERVAL      := 1;
		  
		  --v_COMSCHEMENO      := 'WJGJ0001';
		  
		  --v_BALUNIT          := '�⽭����˾��';
		  
		  --v_TRADETYPECODE    := '46';
		  
		  
	  IF  p_CALLINGNO = '02' THEN
	    --������ҵ
	    v_CHANNELNO        := 'D001';
		  
		  v_BALCYCLETYPECODE := '00';
		  v_BALINTERVAL      := 12;
		  
		  v_FINCYCLETYPECODE := '00';
		  v_FININTERVAL      := 12;
		  
		  v_COMSCHEMENO      := 'TAXI0001';
		 
		  v_BALUNIT          := v_BALUNITNO;
		  
		  v_TRADETYPECODE    := '39';
		  
	  ELSE
	  	p_retCode := 'A003110002';
	    p_retMsg  := '��ҵ���벻��01����02,' || SQLERRM;
	    RETURN;
	  	
	  END IF;
	  
	  v_EVENTTYPECODE    := v_eventHead || v_TRADETYPECODE;
	  
	END; 	 
	 	  
	--3) �����ҵԱ�������Ƿ����
	BEGIN
	 SELECT COUNT(*) INTO v_quantity FROM TD_M_CALLINGSTAFF 
	   WHERE STAFFNO = p_CALLINGSTAFFNO AND CALLINGNO = p_CALLINGNO ;
	  
	  IF v_quantity >= 1 THEN
       p_retCode := 'A003100033';
       p_retMsg  := '��ҵԱ�������Ѵ���,' || SQLERRM;
       RETURN;
    END IF; 
  END;
	

  --4) �����㵥Ԫ�����Ƿ����
  BEGIN
	  SELECT COUNT(*) INTO v_quantity FROM TF_TRADE_BALUNIT
	    WHERE BALUNITNO = v_BALUNITNO ;
	    
	    IF v_quantity >= 1 THEN
         p_retCode := 'A003100133';
         p_retMsg  := '���㵥Ԫ�����Ѵ���,' || SQLERRM;
         RETURN;
       END IF; 
  END;
   

  --5) ���ӽ��㵥Ԫ�������Ϣ
	BEGIN 
    INSERT INTO TF_TRADE_BALUNIT
		  (BALUNITNO    , BALUNIT    , BALUNITTYPECODE ,   SOURCETYPECODE,   CALLINGNO       ,
		   CORPNO       , DEPARTNO   , CALLINGSTAFFNO  ,   BANKCODE      ,   BANKACCNO       ,
		   CREATETIME   , BALLEVEL   , BALCYCLETYPECODE,   BALINTERVAL   ,   FINCYCLETYPECODE,
		   FININTERVAL  , FINTYPECODE, COMFEETAKECODE  ,  
		   CHANNELNO    , USETAG     , SERMANAGERCODE  ,	 FINBANKCODE   ,	
		   LINKMAN      , UNITPHONE  , UNITADD         ,   UNITEMAIL     ,
		   UPDATETIME   , UPDATESTAFFNO )
    VALUES
	    (v_BALUNITNO  , v_BALUNIT  , v_BALUNITTYPECODE  , v_SOURCETYPECODE, p_CALLINGNO    ,
	     p_CORPNO     , p_DEPARTNO , p_CALLINGSTAFFNO   , p_BANKCODE      , p_BANKACCNO     ,
       v_currdate   , v_BALLEVEL , v_BALCYCLETYPECODE , v_BALINTERVAL   , v_FINCYCLETYPECODE,
       v_FININTERVAL, v_FINTYPECODE, v_COMFEETAKECODE , 
       v_CHANNELNO  , v_USETAG     , p_SERMANAGERCODE ,	v_FINBANKCODE   ,	
       v_LINKMAN    , v_UNITPHONE  , v_UNITADD        , v_STAFFEMAIL    ,
       v_currdate   , p_currOper    );
      
    EXCEPTION
     WHEN OTHERS THEN
      p_retCode := 'S003100002';
      p_retMsg  := '���ӽ��㵥Ԫ�������Ϣʧ��,' || SQLERRM;
      ROLLBACK; RETURN;
	END; 
	   
	   
	--6) ȡ�ý��㵥ԪӶ�𷽰���ӦID(8λ)
	SP_GetBizAppCode(1, 'A5', 8, v_balComsID);
	
  --7) ���ӽ��㵥ԪӶ���Ӧ����Ϣ
  BEGIN 
	  INSERT INTO TD_TBALUNIT_COMSCHEME																											
	   (BALUNITNO		 ,	COMSCHEMENO,	
	    BEGINTIME		 ,	  
	    ENDTIME      ,						
		  UPDATESTAFFNO,	UPDATETIME,	ID,  USETAG	)	
	  VALUES
	   (v_BALUNITNO  ,  v_COMSCHEMENO,	
	    TRUNC(SYSDATE,'month'), 
      TO_DATE('20501231235959','YYYYMMDDHH24MISS'),
		  p_currOper   , v_currdate , v_balComsID, v_USETAG );
			
	  EXCEPTION
      WHEN OTHERS THEN
        p_retCode := 'S008109002';
        p_retMsg  := '���ӽ��㵥ԪӶ���Ӧ����Ϣʧ��,' || SQLERRM;
        ROLLBACK; RETURN;
  END; 
	   
	   
	--8) ������ҵԱ���������Ϣ
  BEGIN
    INSERT INTO TD_M_CALLINGSTAFF
		  (STAFFNO    , CALLINGNO,
		   STAFFNAME  , STAFFPAPERTYPECODE, STAFFPAPERNO  , STAFFADDR ,
			 STAFFPHONE , STAFFMOBILE       , STAFFPOST     , STAFFEMAIL, STAFFSEX ,
		   OPERCARDNO , COLLECTCARDNO     , COLLECTCARDPWD, POSID     , CARNO    ,
			 DIMISSIONTAG, UPDATESTAFFNO    , UPDATETIME)

    VALUES
      (p_CALLINGSTAFFNO, p_CALLINGNO,
       v_STAFFNAME , v_STAFFPAPERTYPECODE, v_STAFFPAPERNO  ,  v_UNITADD  ,
       v_UNITPHONE , v_STAFFMOBILE       , v_STAFFPOST     , v_STAFFEMAIL, v_STAFFSEX ,
       v_OPERCARDNO, v_COLLECTCARDNO     , v_COLLECTCARDPWD, v_POSID     , v_CARNO    ,
       v_USETAG    , p_currOper          , v_currdate);
			
    EXCEPTION
     WHEN OTHERS THEN
       p_retCode := 'S003100003';
       p_retMsg  := '����������ҵԱ���������Ϣʧ��,' || SQLERRM;
       ROLLBACK; RETURN;
  END; 
		
	--9) �������ѽ�����Դʶ��������Ϣ
  BEGIN
		INSERT INTO TD_M_TRADE_SOURCE
		 (SOURCECODE,  BALUNITNO, USETAG, UPDATESTAFFNO, UPDATETIME)
		VALUES
		 (v_BALUNITNO, v_BALUNITNO, v_USETAG, p_currOper, v_currdate);
		    		
	  EXCEPTION
	    WHEN OTHERS THEN
	      p_retCode := 'S003100004';
	      p_retMsg  := '�������ѽ�����Դʶ��������Ϣʧ��,' || SQLERRM;
	      ROLLBACK; RETURN;
  END;  
		   
	--10) ȡ��ҵ����ˮ��
	SP_GetSeq(seq => v_seqNo); 
	   
	  
	--11) �������ѽ�����Ϣ����¼�����Ϣ
  BEGIN
	  INSERT INTO  TD_TRADE_BALEVENT
		 (ID, EVENTTYPECODE,	BALUNITNO,	DEALSTATECODE1,	DEALSTATECODE2,	OCCURTIME	)
		VALUES
		 (v_seqNo, v_EVENTTYPECODE,	v_BALUNITNO,	'0', '0',	v_currdate);
			
		EXCEPTION
	    WHEN OTHERS THEN
	      p_retCode := 'S003100011';
	      p_retMsg  := '�������ѽ�����Ϣ����¼�����Ϣʧ��,' || SQLERRM;
	      ROLLBACK; RETURN;
	END;
	   
	--12) ���Ӻ������ҵ��̨��������Ϣ  
	BEGIN
    INSERT INTO TF_B_ASSOCIATETRADE
		 (TRADEID, TRADETYPECODE, ASSOCIATECODE, OPERATESTAFFNO, OPERATEDEPARTID, OPERATETIME)
 	  VALUES
 	   (v_seqNo, v_TRADETYPECODE,  p_CALLINGSTAFFNO,  p_currOper, p_currDept , v_currdate);
 	 
 	  EXCEPTION
      WHEN OTHERS THEN
        p_retCode := 'S003100008';
        p_retMsg  := '���Ӻ������ҵ��̨��������Ϣʧ��,' || SQLERRM;
        ROLLBACK; RETURN;
  END;   
	
	--13) �������ѽ��㵥Ԫ�������ϱ���ӱ���Ϣ
	BEGIN 	
	  INSERT INTO TF_B_TRADE_BALUNITCHANGE
		  (TRADEID      ,
		   BALUNITNO    , BALUNIT    , BALUNITTYPECODE ,   SOURCETYPECODE,   CALLINGNO       ,
		   CORPNO       , DEPARTNO   , CALLINGSTAFFNO  ,   BANKCODE      ,   BANKACCNO       ,
		   CREATETIME   , BALLEVEL   , BALCYCLETYPECODE,   BALINTERVAL   ,   FINCYCLETYPECODE,
		   FININTERVAL  , FINTYPECODE, COMFEETAKECODE  ,  
		   CHANNELNO    , SERMANAGERCODE  ,	 FINBANKCODE   ,	
		   LINKMAN      , UNITPHONE  , UNITADD         ,   UNITEMAIL     )
    VALUES
	    (v_seqNo      ,
	     v_BALUNITNO  , v_BALUNIT  , v_BALUNITTYPECODE  , v_SOURCETYPECODE, p_CALLINGNO    ,
	     p_CORPNO     , p_DEPARTNO , p_CALLINGSTAFFNO   , p_BANKCODE      , p_BANKACCNO     ,
       v_currdate   , v_BALLEVEL , v_BALCYCLETYPECODE , v_BALINTERVAL   , v_FINCYCLETYPECODE,
       v_FININTERVAL, v_FINTYPECODE, v_COMFEETAKECODE , 
       v_CHANNELNO  , p_SERMANAGERCODE,	v_FINBANKCODE ,	
       v_LINKMAN    , v_UNITPHONE  , v_UNITADD        , v_STAFFEMAIL  );
	   	
	  EXCEPTION
	    WHEN OTHERS THEN
	      p_retCode := 'S003100009';
	      p_retMsg  := '�������ѽ��㵥Ԫ�������ϱ���ӱ���Ϣʧ��,' || SQLERRM;
	      ROLLBACK; RETURN;
	END;      
  
  --14) ������ҵԱ���������ϱ���ӱ���Ϣ    
  BEGIN 
  	INSERT INTO TF_B_CALLINGSTAFFCHANGE
		 (TRADEID    ,
		  STAFFNO    , CALLINGNO,
		  STAFFNAME  , STAFFPAPERTYPECODE, STAFFPAPERNO  , STAFFADDR ,
			STAFFPHONE , STAFFMOBILE       , STAFFPOST     , STAFFEMAIL, STAFFSEX ,
		  OPERCARDNO , COLLECTCARDNO     , COLLECTCARDPWD, POSID     , CARNO    ,
			DIMISSIONTAG)

   VALUES
     (v_seqNo     ,
      p_CALLINGSTAFFNO, p_CALLINGNO,
      v_STAFFNAME , v_STAFFPAPERTYPECODE, v_STAFFPAPERNO  ,  v_UNITADD  ,
      v_UNITPHONE , v_STAFFMOBILE       , v_STAFFPOST     , v_STAFFEMAIL, v_STAFFSEX ,
      v_OPERCARDNO, v_COLLECTCARDNO     , v_COLLECTCARDPWD, v_POSID     , v_CARNO    ,
      v_USETAG);
  	
       
 	 EXCEPTION
	   WHEN OTHERS THEN
	     p_retCode := 'S003100010';
	     p_retMsg  := '������ҵԱ���������ϱ���ӱ���Ϣʧ��,' || SQLERRM;
	     ROLLBACK; RETURN;
  END;    
		    
  --15)�������ѽ��㵥Ԫ-Ӷ�𷽰���Ӧ��ϵ�ӱ���Ϣ  
	BEGIN  
		INSERT INTO TF_TBALUNIT_COMSCHEMECHANGE																											
	   (TRADEID      ,
	    BALUNITNO		 ,	COMSCHEMENO,	
	    BEGINTIME		 ,	  
	    ENDTIME      ,	ID	)	
	  VALUES
	   (v_seqNo      ,
	    v_BALUNITNO  ,  v_COMSCHEMENO,	
	    TRUNC(SYSDATE,'month'), 
      TO_DATE('20501231235959','YYYYMMDDHH24MISS'),v_balComsID);
    
	  EXCEPTION
	    WHEN OTHERS THEN
	      p_retCode := 'S008104007';
	      p_retMsg  := '�������ѽ��㵥Ԫ-Ӷ�𷽰���Ӧ��ϵ�ӱ���Ϣʧ��,' || SQLERRM;
	      ROLLBACK; RETURN;
  END;
	
  p_retCode := '0000000000';
  p_retMsg  := '';
  COMMIT; RETURN;
  
END;

/
show errors   

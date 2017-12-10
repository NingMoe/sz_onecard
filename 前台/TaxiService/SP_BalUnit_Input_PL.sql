

CREATE OR REPLACE PROCEDURE SP_BalUnit_Input
(   
   p_CALLINGNO	      CHAR,             --行业编码
   p_CORPNO	          CHAR,             --单位编码
   p_DEPARTNO	        CHAR,             --部门编码
   p_CALLINGSTAFFNO   CHAR,             --行业员工号     
   p_BANKCODE	        CHAR,             --开户银行编码
   p_BANKACCNO	      VARCHAR2,         --银行账号
   p_SERMANAGERCODE	  CHAR,             --商户经理编码
   p_currOper	        CHAR,             --操作员工   
   p_currDept	        CHAR,             --操作员工所在部门      
   p_retCode   	      OUT CHAR,         --返回代码
   p_retMsg     	    OUT VARCHAR2      --返回消息
                                           
)
AS
   v_quantity         INT;                 --临时变量    
   v_currdate         DATE := SYSDATE;     --当前日期
   v_seqNo            CHAR(16);            --业务流水号  
   
                                            
   v_balComsID        CHAR(8);             --结算单元对应佣金方案ID                                        
   v_COMSCHEMENO      CHAR(8);             --佣金方案编码
   
   v_BALUNITNO        CHAR(8);             --结算单元编码(行业编码 + 行业员工工号)  
   v_BALUNIT          VARCHAR2(50);         --结算单元名称                            
   v_BALUNITTYPECODE	CHAR(2) := '03';     --单元类型编码(00行业,01单位,02部门,03行业员工)
   v_CHANNELNO    	  CHAR(4);             --通道编码
   v_SOURCETYPECODE	  CHAR(2) := '02';     --来源识别类型编码(00PSAM卡号,01信息亭缴费领域特殊值, 02出租车司机工号)
   v_BALLEVEL       	CHAR(1) := '2';      --结算级别编码
                                           
   v_BALCYCLETYPECODE	CHAR(2);             --结算周期类型编码(00小时,01天,02周,03固定月,04 自然月)
   v_BALINTERVAL	    INT;                 --结算周期跨度
                                           
   v_FINCYCLETYPECODE	CHAR(2);             --划账周期类型编码(00小时,01天,02周,03固定月,04 自然月)
   v_FININTERVAL	    INT;                 --划账周期跨度
                                           
   v_FINTYPECODE	    CHAR(1) := '0';      --转账类型(0财务部门转账,1财务不转账)
                                           
   v_COMFEETAKECODE	  CHAR(1) := '0';      --佣金扣减方式编码(0不在转账金额扣减,1直接从转账金额扣减)
   v_FINBANKCODE	    CHAR(4) := '';       --转出行银行代码(为空)
      
      
   v_LINKMAN	        VARCHAR2(20) := '';   --联系人
	 v_UNITPHONE	      VARCHAR2(20) := '';   --联系电话
	 v_UNITADD	        VARCHAR2(50) := '';   --联系地址
	 
	 v_USETAG         	CHAR(1) := '1'    ;  --有效标志
	 
	 
	 v_STAFFNAME	        VARCHAR2(20) := '';   --行业员工姓名
	 v_STAFFPAPERTYPECODE	CHAR(2) := '';        --员工证件类型
	 v_STAFFPAPERNO	      VARCHAR2(20) := '';   --员工证件号码
	
	 v_STAFFMOBILE	      VARCHAR2(15) := '';   --员工移动电话
   v_STAFFPOST	        VARCHAR2(6) := '';    --邮编地址	  
   v_STAFFEMAIL	        VARCHAR2(30) := '';   --EMAIL地址	
   v_STAFFSEX	          CHAR(1) := '';        --员工性别	  
   v_OPERCARDNO	        VARCHAR2(16) := '';   --员工卡号	  
   v_OPERCARDPWD	      VARCHAR2(8) := '';    --员工卡密码	
	 v_COLLECTCARDNO	    VARCHAR2(16) := '';   --采集卡号
   v_COLLECTCARDPWD	    VARCHAR2(8) := '';    --采集卡密码	
   v_POSID	            CHAR(8) := '';        --POS编号	
   v_CARNO	            CHAR(8) := '';        --车号
      
   v_eventHead          CHAR(2) := '00';      --事件类型编码头(00)    
     
	 v_EVENTTYPECODE    	CHAR(4);              --事件类型编码(事件类型编码头 + 业务类型编码)
     
   v_TRADETYPECODE      CHAR(2);              --业务类型编码                    
   
BEGIN 
	
  --1) 生成结算单元编码
  v_BALUNITNO :=  p_CALLINGNO || p_CALLINGSTAFFNO;
	
	--2)不同行业下的结算单元相关参数赋值
	BEGIN
		--IF p_CALLINGNO = '01' THEN
		  --公交行业
		  --v_CHANNELNO        := 'A002';
		  
		  --v_BALCYCLETYPECODE := '01';
		  --v_BALINTERVAL      := 1;
		  
		  --v_FINCYCLETYPECODE := '01';
		  --v_FININTERVAL      := 1;
		  
		  --v_COMSCHEMENO      := 'WJGJ0001';
		  
		  --v_BALUNIT          := '吴江公交司机';
		  
		  --v_TRADETYPECODE    := '46';
		  
		  
	  IF  p_CALLINGNO = '02' THEN
	    --出租行业
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
	    p_retMsg  := '行业编码不是01或者02,' || SQLERRM;
	    RETURN;
	  	
	  END IF;
	  
	  v_EVENTTYPECODE    := v_eventHead || v_TRADETYPECODE;
	  
	END; 	 
	 	  
	--3) 检查行业员工编码是否存在
	BEGIN
	 SELECT COUNT(*) INTO v_quantity FROM TD_M_CALLINGSTAFF 
	   WHERE STAFFNO = p_CALLINGSTAFFNO AND CALLINGNO = p_CALLINGNO ;
	  
	  IF v_quantity >= 1 THEN
       p_retCode := 'A003100033';
       p_retMsg  := '行业员工编码已存在,' || SQLERRM;
       RETURN;
    END IF; 
  END;
	

  --4) 检查结算单元编码是否存在
  BEGIN
	  SELECT COUNT(*) INTO v_quantity FROM TF_TRADE_BALUNIT
	    WHERE BALUNITNO = v_BALUNITNO ;
	    
	    IF v_quantity >= 1 THEN
         p_retCode := 'A003100133';
         p_retMsg  := '结算单元编码已存在,' || SQLERRM;
         RETURN;
       END IF; 
  END;
   

  --5) 增加结算单元编码表信息
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
      p_retMsg  := '增加结算单元编码表信息失败,' || SQLERRM;
      ROLLBACK; RETURN;
	END; 
	   
	   
	--6) 取得结算单元佣金方案对应ID(8位)
	SP_GetBizAppCode(1, 'A5', 8, v_balComsID);
	
  --7) 增加结算单元佣金对应表信息
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
        p_retMsg  := '增加结算单元佣金对应表信息失败,' || SQLERRM;
        ROLLBACK; RETURN;
  END; 
	   
	   
	--8) 增加行业员工编码表信息
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
       p_retMsg  := '增加增加行业员工编码表信息失败,' || SQLERRM;
       ROLLBACK; RETURN;
  END; 
		
	--9) 增加消费结算来源识别编码表信息
  BEGIN
		INSERT INTO TD_M_TRADE_SOURCE
		 (SOURCECODE,  BALUNITNO, USETAG, UPDATESTAFFNO, UPDATETIME)
		VALUES
		 (v_BALUNITNO, v_BALUNITNO, v_USETAG, p_currOper, v_currdate);
		    		
	  EXCEPTION
	    WHEN OTHERS THEN
	      p_retCode := 'S003100004';
	      p_retMsg  := '增加消费结算来源识别编码表信息失败,' || SQLERRM;
	      ROLLBACK; RETURN;
  END;  
		   
	--10) 取得业务流水号
	SP_GetSeq(seq => v_seqNo); 
	   
	  
	--11) 增加消费结算信息变更事件表信息
  BEGIN
	  INSERT INTO  TD_TRADE_BALEVENT
		 (ID, EVENTTYPECODE,	BALUNITNO,	DEALSTATECODE1,	DEALSTATECODE2,	OCCURTIME	)
		VALUES
		 (v_seqNo, v_EVENTTYPECODE,	v_BALUNITNO,	'0', '0',	v_currdate);
			
		EXCEPTION
	    WHEN OTHERS THEN
	      p_retCode := 'S003100011';
	      p_retMsg  := '增加消费结算信息变更事件表信息失败,' || SQLERRM;
	      ROLLBACK; RETURN;
	END;
	   
	--12) 增加合作伙伴业务台帐主表信息  
	BEGIN
    INSERT INTO TF_B_ASSOCIATETRADE
		 (TRADEID, TRADETYPECODE, ASSOCIATECODE, OPERATESTAFFNO, OPERATEDEPARTID, OPERATETIME)
 	  VALUES
 	   (v_seqNo, v_TRADETYPECODE,  p_CALLINGSTAFFNO,  p_currOper, p_currDept , v_currdate);
 	 
 	  EXCEPTION
      WHEN OTHERS THEN
        p_retCode := 'S003100008';
        p_retMsg  := '增加合作伙伴业务台帐主表信息失败,' || SQLERRM;
        ROLLBACK; RETURN;
  END;   
	
	--13) 增加消费结算单元编码资料变更子表信息
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
	      p_retMsg  := '增加消费结算单元编码资料变更子表信息失败,' || SQLERRM;
	      ROLLBACK; RETURN;
	END;      
  
  --14) 增加行业员工编码资料变更子表信息    
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
	     p_retMsg  := '增加行业员工编码资料变更子表信息失败,' || SQLERRM;
	     ROLLBACK; RETURN;
  END;    
		    
  --15)增加消费结算单元-佣金方案对应关系子表信息  
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
	      p_retMsg  := '增加消费结算单元-佣金方案对应关系子表信息失败,' || SQLERRM;
	      ROLLBACK; RETURN;
  END;
	
  p_retCode := '0000000000';
  p_retMsg  := '';
  COMMIT; RETURN;
  
END;

/
show errors   

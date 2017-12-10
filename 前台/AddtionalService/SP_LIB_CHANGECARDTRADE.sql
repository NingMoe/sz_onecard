--图书馆换卡业务
CREATE OR REPLACE PROCEDURE SP_LIB_CHANGECARDTRADE  
(
		p_retCode	          out char, -- Return Code
		p_retMsg     	      out varchar2,  -- Return Message
		p_SYNCTRADEID       char,     --同步流水号
		P_TRADETYPECODE     VARCHAR2, --05 换卡
		p_NEWCARDNO	        char,     --卡号
		p_SOCLSECNO         char,     --社保号
		p_CUSTNAME	        varchar2, --用户姓名
		p_CUSTBIRTH	        varchar2, --出生日期
		p_PAPERTYPECODE	    varchar2, --证件类型
		p_PAPERNO        	  varchar2, --证件号码
		p_CUSTSEX	          varchar2, --用户性别
		p_CUSTADDR	        varchar2, --联系地址
		p_CUSTPOST	        varchar2, --邮政编码
		p_CUSTPHONE	        varchar2, --联系电话
		p_CUSTEMAIL         varchar2, --电子邮件
		p_REMARK	          varchar2, --备注
		p_OLDCARDNO         char,     --旧卡卡号
		
		p_TRADEORIGIN       varchar2, --业务来源
	
		p_ENDTIME           char,     --有效时间
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


--1)判断卡是否在黑名单
	 BEGIN
		 SELECT COUNT(*) INTO v_newCount FROM TF_B_WARN_BLACK t 
			WHERE t.CARDNO=p_NEWCARDNO;
			IF v_newCount = 1 THEN
                 RAISE V_EX;
          END IF;

          EXCEPTION WHEN OTHERS THEN
            p_retCode := '0000000001';
            p_retMsg :='该卡在黑名单中'||SQLERRM;
            RETURN;
	 END;

--2)判断卡状态
	BEGIN
	  SELECT COUNT(*) INTO v_newCount FROM TL_R_ICUSER  
			WHERE CARDNO=p_NEWCARDNO AND (RESSTATECODE='06'OR substr(p_NEWCARDNO,5,2)='18');
			IF v_newCount = 0 THEN
                 RAISE V_EX;
          END IF;

          EXCEPTION WHEN OTHERS THEN
            p_retCode := '0000000002';
            p_retMsg :='该卡不存在或卡片并未售出'||SQLERRM;
            RETURN;
	END;


	
--3)查询旧卡是否存在卡开通关闭记录
    BEGIN
      SELECT COUNT(*) INTO v_oldCount FROM TF_F_CARDUSEAREA WHERE CARDNO=p_OLDCARDNO AND FUNCTIONTYPE='17'; 
    END;
	
--4)更新新旧卡图书馆状态

    IF v_oldCount = 1 THEN --旧卡有开通关闭记录
      
		--查询旧卡状态
		BEGIN 
			SELECT USETAG INTO v_USETAG FROM TF_F_CARDUSEAREA WHERE CARDNO=p_OLDCARDNO AND FUNCTIONTYPE='17'; 
		END;
		
		-- A卡新卡默认开通
		
		IF (substr(p_NEWCARDNO,5,2)='18') THEN
			v_USETAG:= '1';
		END IF;
      
		--旧卡关闭图书馆功能
		BEGIN
			UPDATE TF_F_CARDUSEAREA SET USETAG='0' WHERE CARDNO = p_OLDCARDNO AND FUNCTIONTYPE='17';
            IF SQL%ROWCOUNT != 1 THEN
			RAISE V_EX;
			END IF;

			EXCEPTION WHEN OTHERS THEN
			p_retCode :=  '0000000003';
			p_retMsg :='关闭旧卡图书馆功能失败'||SQLERRM;
			RETURN;
		END;
      
		--查询新卡有无图书馆开通关闭记录
		BEGIN 
			SELECT COUNT(*) INTO v_newCount FROM TF_F_CARDUSEAREA WHERE CARDNO=p_NEWCARDNO AND FUNCTIONTYPE='17'; 
		END;
      
		if v_newCount=0 THEN
		--无记录插入新记录
			BEGIN 
				insert into TF_F_CARDUSEAREA(CARDNO,FUNCTIONTYPE,USETAG,ENDTIME,UPDATESTAFFNO,UPDATETIME,RSRV1,RSRV2)
				values(p_NEWCARDNO,'17',v_USETAG, p_ENDTIME,p_currOper,v_today,p_REMARK,'') ;
				  IF SQL%ROWCOUNT != 1 THEN
					  RAISE V_EX;
				  END IF;

				  EXCEPTION WHEN OTHERS THEN
					p_retCode := '0000000004';
					p_retMsg :='开通新卡图书馆功能失败'||SQLERRM;
				  RETURN;
			END;
		ELSE
		--有记录更新
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
                p_retMsg :='开通新卡图书馆功能失败'||SQLERRM;
              RETURN;
            END;
		END IF;
      
		-- 3) Get trade id
		SP_GetSeq(seq => v_TradeID);

		-- 4) 新卡开通时插入主台账
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
				p_retMsg  := '插入主台账记录表失败' || SQLERRM;
				RETURN;
			END;
		END IF;
    
		-- 5) 旧卡关闭主台账
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
      p_retMsg  := '插入主台账记录表失败' || SQLERRM;
      RETURN;
      END;


    -- 6) 换卡写入图书馆主台账表

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
            p_retMsg  := '插入图书馆业务台账表失败' || SQLERRM;
            RETURN;         
        END;
      
    END IF;
	p_retCode := '0000000000';
     p_retMsg  := '';
END;

/
show errors
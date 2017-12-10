 --图书馆业务
CREATE OR REPLACE PROCEDURE SP_LIB_CARDTRADE      
(
		p_retCode	          out char, -- Return Code
		p_retMsg     	      out varchar2,  -- Return Message
		p_SYNCTRADEID       char,     --同步流水号
    	P_TRADETYPECODE     VARCHAR2, --01开通,02普通关闭,03挂失关闭,04解挂,05换卡(换卡使用SP_LIB_CHANGECARDTRADE)
		p_CARDNO	          char,     --卡号
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
		p_OLDCARDNO         char,     --旧卡卡号
		p_REMARK	          varchar2, --备注

		p_TRADEORIGIN       varchar2, --业务来源

		p_ENDTIME           char,     --有效时间
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
	
	--1)判断卡是否在黑名单
	 BEGIN
		 SELECT COUNT(*) INTO v_Count FROM TF_B_WARN_BLACK t 
			WHERE t.CARDNO=p_CARDNO;
			IF v_Count = 1 THEN
                 RAISE V_EX;
          END IF;

          EXCEPTION WHEN OTHERS THEN
            p_retCode := '0000000001';
            p_retMsg :='该卡在黑名单中'||SQLERRM;
            RETURN;
	 END;

	--2)判断卡状态
	BEGIN
	  SELECT COUNT(*) INTO v_Count FROM TL_R_ICUSER  
			WHERE CARDNO=p_CARDNO AND (RESSTATECODE='06'OR substr(p_CARDNO,5,2)='18');
			IF v_Count = 0 THEN
                 RAISE V_EX;
          END IF;

          EXCEPTION WHEN OTHERS THEN
            p_retCode := '0000000002';
            p_retMsg :='该卡不存在或卡片并未售出'||SQLERRM;
            RETURN;
	END;
	
	--3)查询是否存在卡开通关闭记录
		BEGIN
			SELECT COUNT(*) INTO v_Count FROM TF_F_CARDUSEAREA WHERE CARDNO=p_CARDNO AND FUNCTIONTYPE='17'; 
		END;


	--4)业务类型赋值
		IF (P_TRADETYPECODE ='01') THEN --开通
			v_USETAG :='1';
			v_TRADETYPECODE :='85';
		ELSIF	(P_TRADETYPECODE ='02') THEN --普通关闭
			v_USETAG :='0';
			v_TRADETYPECODE :='86';
		ELSIF	(P_TRADETYPECODE ='03') THEN --挂失关闭
			v_USETAG :='0';
			v_TRADETYPECODE :='86';
		ELSIF	(P_TRADETYPECODE ='04') THEN --解挂
			v_USETAG :='1';
			v_TRADETYPECODE :='85';
		END IF;

	--5) 有记录则更新，无记录则插入
		IF v_Count = 0 THEN
			BEGIN 
					insert into TF_F_CARDUSEAREA(CARDNO,FUNCTIONTYPE,USETAG,ENDTIME,UPDATESTAFFNO,UPDATETIME,RSRV1,RSRV2)
					values(p_CARDNO,'17',v_USETAG, p_ENDTIME,p_currOper,v_today,p_REMARK,'') ;
					IF SQL%ROWCOUNT != 1 THEN
							RAISE V_EX;
					END IF;

						EXCEPTION WHEN OTHERS THEN
							p_retCode := '0000000001';
							p_retMsg :='插入图书馆功能失败'||SQLERRM;
							RETURN;
			END;
		ELSE 
			--)更新卡开通或者关闭
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
				p_retMsg :='更新卡图书馆功能失败'||SQLERRM;
				RETURN;
			END;
		END IF;

 -- 4) Get trade id
    SP_GetSeq(seq => v_TradeID);


-- 5)写入主台账
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
	            p_retMsg  := '插入主台账记录表失败' || SQLERRM;
	            RETURN;
    END;

 -- 6)写入图书馆主台账表
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
	            p_retMsg  := '插入图书馆业务台账表失败' || SQLERRM;
	            RETURN;         
		END;

    p_retCode := '0000000000';
    p_retMsg  := '';
    RETURN;
END;

/
show errors

-- =============================================
-- AUTHOR:		liuhe
-- CREATE DATE: 2013-09-03
-- DESCRIPTION:	旅游卡-售卡存储过程
-- =============================================
CREATE OR REPLACE PROCEDURE SP_AS_SZTravelCardSale
(
	p_ID	          char,
	p_CARDNO	      char,
	p_DEPOSIT	      int,--押金
	p_TRADEPROCFEE    int,--手续费
	p_SUPPLYMONEY	  int,--充值金额
	p_CARDTRADENO	  char,--交易序号
	p_CUSTNAME	      varchar2,
	p_CUSTSEX	      varchar2,
	p_CUSTBIRTH	      varchar2,
	p_PAPERTYPECODE	  varchar2,
	p_PAPERNO         varchar2,
	p_CUSTADDR	      varchar2,
	p_CUSTPOST	      varchar2,
	p_CUSTPHONE	      varchar2,
	p_CUSTEMAIL       varchar2,
	p_REMARK	      varchar2,
	p_OPERCARDNO	  char,
	p_TRADEID    	    out char, -- Return Trade Id
	p_currOper	      char,
	p_currDept	      char,
	p_retCode	      out char, -- Return Code
	p_retMsg     	  out varchar2  -- Return Message
)
AS
    v_TradeID char(16);
	v_CARDTYPECODE	   char(2);
    v_CARDSURFACECODE  char(4); 
    v_MANUTYPECODE     char(2);
    v_CARDCHIPTYPECODE char(2);
    v_APPTYPECODE      char(2);
    v_APPVERNO         char(2);
    v_PRESUPPLYMONEY   int;
    v_VALIDENDDATE     char(8);
    v_ASN	             char(16);
	v_CARDSTATE    tl_r_icuser.resstatecode%type;    -- 卡片状态
    v_ex          exception;
	V_COUNT			INT;
	V_CURRENTTIME	DATE;
	v_tradeTypeCode char(2);
	v_CARDACCMONEY     int;--账户表余额
BEGIN

     -- 1) Get system time
    V_CURRENTTIME := sysdate;
	v_tradeTypeCode := '7H';

	--对代理点充值金额的限制
    SELECT  COUNT(*) INTO V_COUNT
    FROM     TF_DEPT_BALUNIT B , TD_DEPTBAL_RELATION R
    WHERE     B.DBALUNITNO = R.DBALUNITNO
            AND B.DEPTTYPE = '1'
            AND R.USETAG = '1'
            AND B.USETAG = '1'
            AND R.DEPARTNO = P_CURRDEPT;
    IF V_COUNT = 1 THEN
        SP_ProxyChargeLimit(P_CARDNO,V_CURRENTTIME,P_CARDTRADENO,p_SUPPLYMONEY,'02',p_currOper,p_currDept,p_retCode,p_retMsg);
        IF p_retCode != '0000000000' THEN
            ROLLBACK; RETURN;
        END IF;
    END IF;

	    -- 3) Get initialize info
    SELECT
        ASN, CARDTYPECODE , CARDSURFACECODE, MANUTYPECODE, CARDCHIPTYPECODE, APPTYPECODE,
        APPVERNO,PRESUPPLYMONEY,VALIDENDDATE,RESSTATECODE
    INTO v_ASN,v_CARDTYPECODE,v_CARDSURFACECODE,v_MANUTYPECODE,v_CARDCHIPTYPECODE,v_APPTYPECODE,
         v_APPVERNO,v_PRESUPPLYMONEY,v_VALIDENDDATE,v_CARDSTATE
    FROM TL_R_ICUSER
    WHERE CARDNO = p_CARDNO;
	
	if v_CARDSTATE = '04' then        -- 回收状态再售卡时，备份售卡处理相关表
	
	--验证卡片账户余额和卡内余额是否相等
		SELECT CARDACCMONEY INTO V_CARDACCMONEY FROM TF_F_CARDEWALLETACC WHERE CARDNO = P_CARDNO;
		IF V_CARDACCMONEY <> 0 THEN
			P_RETCODE := 'S094570359';
			P_RETMSG  := '回收卡库内余额不为0,暂时不能再售出';
			RETURN;
		END IF;	
			
        -- 备份卡资料表
        insert into TB_F_CARDREC(
            CARDNO,REUSEDATE,ASN,CARDTYPECODE,CARDSURFACECODE,CARDMANUCODE,
            CARDCHIPTYPECODE,APPTYPECODE,APPVERNO,DEPOSIT,CARDCOST,PRESUPPLYMONEY,
            CUSTRECTYPECODE,SELLTIME,SELLCHANNELCODE,DEPARTNO,STAFFNO,CARDSTATE,
            USETAG,SERSTARTTIME,SERTAKETAG,SERVICEMONEY,UPDATESTAFFNO,UPDATETIME,
            RSRV1,RSRV2,RSRV3,REMARK)
        select
            CARDNO,sysdate,ASN,CARDTYPECODE,CARDSURFACECODE,CARDMANUCODE,
            CARDCHIPTYPECODE,APPTYPECODE,APPVERNO,DEPOSIT,CARDCOST,PRESUPPLYMONEY,
            CUSTRECTYPECODE,SELLTIME,SELLCHANNELCODE,DEPARTNO,STAFFNO,CARDSTATE,
            USETAG,SERSTARTTIME,SERSTAKETAG,SERVICEMONEY,UPDATESTAFFNO,UPDATETIME,
            RSRV1,RSRV2,RSRV3,REMARK
        from TF_F_CARDREC
        where CARDNO = p_cardNo;

        delete from TF_F_CARDREC
        where CARDNO = p_cardNo;

        -- 电子钱包账户表
        insert into TB_F_CARDEWALLETACC(
            CARDNO,REUSEDATE,CARDACCMONEY,USETAG,CREDITSTATECODE,
            CREDITSTACHANGETIME,CREDITCONTROLCODE,CREDITCOLCHANGETIME,
            ACCSTATECODE,CONSUMEREALMONEY,SUPPLYREALMONEY,
            TOTALCONSUMETIMES,TOTALSUPPLYTIMES,TOTALCONSUMEMONEY,
            TOTALSUPPLYMONEY,FIRSTCONSUMETIME,LASTCONSUMETIME,
            FIRSTSUPPLYTIME,LASTSUPPLYTIME,OFFLINECARDTRADENO,
            ONLINECARDTRADENO,RSRV1,RSRV2,RSRV3,REMARK)
        select
            CARDNO,sysdate,CARDACCMONEY,USETAG,CREDITSTATECODE,
            CREDITSTACHANGETIME,CREDITCONTROLCODE,CREDITCOLCHANGETIME,
            ACCSTATECODE,CONSUMEREALMONEY,SUPPLYREALMONEY,
            TOTALCONSUMETIMES,TOTALSUPPLYTIMES,TOTALCONSUMEMONEY,
            TOTALSUPPLYMONEY,FIRSTCONSUMETIME,LASTCONSUMETIME,
            FIRSTSUPPLYTIME,LASTSUPPLYTIME,OFFLINECARDTRADENO,
            ONLINECARDTRADENO,RSRV1,RSRV2,RSRV3,REMARK
        from TF_F_CARDEWALLETACC
        where CARDNO = p_cardNo;

        delete from TF_F_CARDEWALLETACC
        where CARDNO = p_cardNo;

        -- 客户资料表直接删除
        delete from TF_F_CUSTOMERREC
        where CARDNO = p_cardNo;
		
		v_tradeTypeCode := '7I';

    end if;
	
    -- 2) Update card resource statecode
    BEGIN
		    UPDATE TL_R_ICUSER
		    SET RESSTATECODE  = '06',
		        SELLTIME = V_CURRENTTIME,
		        UPDATESTAFFNO = p_currOper,
		        UPDATETIME = V_CURRENTTIME
		    WHERE  CARDNO = p_CARDNO;

		    IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
		EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S001001105';
	            p_retMsg  := 'Error occurred while updating resource statecode' || SQLERRM;
	            ROLLBACK; RETURN;
    END;

    -- 4) Insert a row in CARDREC
    BEGIN
		    INSERT INTO TF_F_CARDREC
		        (CARDNO,ASN,CARDTYPECODE,CARDSURFACECODE,CARDMANUCODE,CARDCHIPTYPECODE,APPTYPECODE,APPVERNO,
		        DEPOSIT,CARDCOST,PRESUPPLYMONEY,CUSTRECTYPECODE,SELLTIME,SELLCHANNELCODE,DEPARTNO,STAFFNO,
		        CARDSTATE,VALIDENDDATE,USETAG,SERSTARTTIME,SERSTAKETAG,SERVICEMONEY,UPDATESTAFFNO,UPDATETIME)
		    VALUES
		        (p_CARDNO,v_ASN,v_CARDTYPECODE,v_CARDSURFACECODE,v_MANUTYPECODE,v_CARDCHIPTYPECODE,v_APPTYPECODE,v_APPVERNO,
		        p_DEPOSIT,0,v_PRESUPPLYMONEY,'0',V_CURRENTTIME,'01',p_currDept,
		        p_currOper,'10',v_VALIDENDDATE,'1',V_CURRENTTIME,'3',0,p_currOper,V_CURRENTTIME);

		EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S001001102';
	            p_retMsg  := 'Error occurred while insert a row in cardrec' || SQLERRM;
	            ROLLBACK; RETURN;
    END;

    --5) insert a row of elec wallet
    BEGIN
		    INSERT INTO TF_F_CARDEWALLETACC
		        (CARDNO,CARDACCMONEY,USETAG,CREDITSTATECODE,CREDITSTACHANGETIME,CREDITCONTROLCODE,
		        CREDITCOLCHANGETIME,ACCSTATECODE,CONSUMEREALMONEY,SUPPLYREALMONEY,TOTALCONSUMETIMES,
		        TOTALSUPPLYTIMES,TOTALCONSUMEMONEY,TOTALSUPPLYMONEY,OFFLINECARDTRADENO,ONLINECARDTRADENO)
		    VALUES
		        (p_CARDNO,0,'1','00',V_CURRENTTIME,'00',V_CURRENTTIME,'01',0,0,0,0,0,0,'0000',p_CARDTRADENO);

		EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S001001106';
	            p_retMsg  := 'Error occurred while insert a row of elec wallet' || SQLERRM;
	            ROLLBACK; RETURN;
    END;

	SP_PB_UpdateAcc (p_ID, p_CARDNO, p_CARDTRADENO, 0,
         0, v_TradeID, v_ASN, v_CARDTYPECODE, p_SUPPLYMONEY,
         '02', '112233445566', v_CURRENTTIME,p_currOper,p_currDept, p_retCode,p_retMsg);

    --6) insert a row of cust info
    BEGIN
		    INSERT INTO TF_F_CUSTOMERREC
		        (CARDNO,CUSTNAME,CUSTSEX,CUSTBIRTH,PAPERTYPECODE,PAPERNO,
		        CUSTADDR,CUSTPOST,CUSTPHONE,CUSTEMAIL,USETAG,UPDATESTAFFNO,UPDATETIME,REMARK)
		    VALUES
		        (p_CARDNO,p_CUSTNAME,p_CUSTSEX,p_CUSTBIRTH,p_PAPERTYPECODE,p_PAPERNO,p_CUSTADDR,p_CUSTPOST,
		        p_CUSTPHONE,p_CUSTEMAIL,'1',p_currOper,V_CURRENTTIME,p_REMARK);

		EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S001001103';
	            p_retMsg  := 'Error occurred while insert a row of cust info' || SQLERRM;
	            ROLLBACK; RETURN;
    END;


    -- 7) Get trade id
    SP_GetSeq(seq => v_TradeID);
    p_TRADEID := v_TradeID;

    -- 8) Log operation
    BEGIN
		    INSERT INTO TF_B_TRADE
		        (TRADEID,ID,TRADETYPECODE,CARDNO,ASN,CARDTYPECODE,CARDTRADENO,CURRENTMONEY,PREMONEY,
		        OPERATESTAFFNO,OPERATEDEPARTID,OPERATETIME)
		    VALUES
		        (v_TradeID,p_ID,v_tradeTypeCode,p_CARDNO,v_ASN,v_CARDTYPECODE,p_CARDTRADENO,
		        p_DEPOSIT + p_TRADEPROCFEE + p_SUPPLYMONEY,0,
		        p_currOper,p_currDept,V_CURRENTTIME);

		EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S001001107';
	            p_retMsg  := 'Fail to log the operation' || SQLERRM;
	            ROLLBACK; RETURN;
    END;

    -- 9) Log the operation of cust info change
    BEGIN
		    INSERT INTO TF_B_CUSTOMERCHANGE
		        (TRADEID,CARDNO,CUSTNAME,CUSTSEX,CUSTBIRTH,PAPERTYPECODE,PAPERNO,CUSTADDR,CUSTPOST,CUSTPHONE,
		        CUSTEMAIL,CHGTYPECODE,OPERATESTAFFNO,OPERATEDEPARTID,OPERATETIME)
		    VALUES
		        (v_TradeID,p_CARDNO,p_CUSTNAME,p_CUSTSEX,p_CUSTBIRTH,p_PAPERTYPECODE,p_PAPERNO,p_CUSTADDR,
		        p_CUSTPOST,p_CUSTPHONE,p_CUSTEMAIL,'00',p_currOper,p_currDept,V_CURRENTTIME);

		EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S001001108';
	            p_retMsg  := 'Fail to log the operation of cust info change' || SQLERRM;
	            ROLLBACK; RETURN;
    END;

    -- 10) Log the cash
    BEGIN
		    INSERT INTO TF_B_TRADEFEE
		        (ID,TRADEID,TRADETYPECODE,CARDNO,CARDTRADENO,CARDSERVFEE,CARDDEPOSITFEE,SUPPLYMONEY,TRADEPROCFEE,OTHERFEE,
		        OPERATESTAFFNO,OPERATEDEPARTID,OPERATETIME)
		    VALUES
		        (p_ID,v_TradeID,v_tradeTypeCode,p_CARDNO,p_CARDTRADENO,0,p_DEPOSIT,p_SUPPLYMONEY, p_TRADEPROCFEE,0 ,
		        p_currOper,p_currDept,V_CURRENTTIME);

		EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S001001109';
	            p_retMsg  := 'Fail to log the cash' || SQLERRM;
	            ROLLBACK; RETURN;
    END;

    -- 11) Log the writeCard
    BEGIN

			INSERT INTO TF_CARD_TRADE
                    (TRADEID,TRADETYPECODE,strOperCardNo,strCardNo,lMoney,lOldMoney,strTermno,
                    Cardtradeno,OPERATETIME,SUCTAG)
            VALUES
                    (v_TradeID,v_tradeTypeCode,p_OPERCARDNO,p_CARDNO,p_SUPPLYMONEY,0,'112233445566',
                    p_CARDTRADENO,v_CURRENTTIME,'0');
					
		EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S001001139';
	            p_retMsg  := 'Fail to log the writeCard' || SQLERRM;
	            ROLLBACK; RETURN;
    END;

		-- 代理营业厅抵扣预付款，根据保证金修改可领卡额度
	BEGIN
	  SP_PB_DEPTBALFEE(v_TradeID, '3' ,--1预付款,2保证金,3预付款和保证金
					 p_DEPOSIT + p_TRADEPROCFEE + p_SUPPLYMONEY,
	                 V_CURRENTTIME,p_currOper,p_currDept,p_retCode,p_retMsg);
	
     IF p_retCode != '0000000000' THEN RAISE v_ex; END IF;
        EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK; RETURN;
   END;
   
   
	p_retCode := '0000000000';
	p_retMsg  := '';
	COMMIT;	RETURN;
END;



/

show errors

create or replace procedure SP_SD_AdjustSale
(
	p_ID	            char,
	p_CARDNO	        char,
	p_DEPOSIT	        int,
	p_ADJUSTMONEY	    int,
	p_OTHERFEE		    int,
	p_CARDTRADENO	    char,
	p_CARDTYPECODE	    char,
	p_CARDMONEY	        int,
	p_SELLCHANNELCODE	char,
	p_SERSTAKETAG	    char,
	p_TRADETYPECODE	    char,
	p_OLDCARDNO	        char,
    p_VALIDENDDATE      char,
	p_TERMNO			char,
	p_OPERCARDNO		char,
	p_CURRENTTIME	    out date, -- Return Operate Time
	p_TRADEID    	    out char, -- Return Trade Id
	p_currOper	        char,
	p_currDept	        char,
	p_retCode	        out char, -- Return Code
	p_retMsg     	    out varchar2  -- Return Message

)
AS
    v_TRADEID               char(16);
    v_ASN               char(16);
    v_ex                exception;
BEGIN
    BEGIN
	  SP_PB_SaleCard(p_ID,p_CARDNO,p_DEPOSIT,0, p_OTHERFEE,p_CARDTRADENO,p_CARDTYPECODE,
	                 p_CARDMONEY,p_SELLCHANNELCODE,p_SERSTAKETAG,p_TRADETYPECODE, '',
	                  '', '', '', '', '', '', '', '', '','0',p_TERMNO,p_OPERCARDNO,
	                 p_CURRENTTIME,v_TRADEID,p_currOper,p_currDept,p_retCode,p_retMsg);

     IF p_retCode != '0000000000' THEN RAISE v_ex; END IF;
        EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK; RETURN;
    END;
        
    BEGIN
        delete from TF_B_TRADEFEE where tradeid = v_TRADEID;
      
      IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;    
		EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S001100111';
	            p_retMsg  := 'Error occurred while delete from tf_b_tradefee' || SQLERRM;
	            ROLLBACK; RETURN;
    END;
    
    BEGIN
        update TF_B_TRADE SET OLDCARDNO = p_OLDCARDNO 
        where tradeid = v_TRADEID;
      
      IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;    
		EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S001100112';
	            p_retMsg  := 'Error occurred while updating tf_b_trade' || SQLERRM;
	            ROLLBACK; RETURN;
    END;
    
    BEGIN  
        -- 修正写卡台帐cardtradeno
        update TF_CARD_TRADE t
        set    t.cardtradeno = p_CARDTRADENO,
               t.lMoney      = p_ADJUSTMONEY - p_DEPOSIT
        where  t.tradeid = v_TRADEID;
        
        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;    
		EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S001100113';
	            p_retMsg  := 'Error occurred while updating tf_card_trade' || SQLERRM;
	            ROLLBACK; RETURN;
    END;
    
    BEGIN
        -- 修正卡片失效日期
        update TF_F_CARDREC t
        set    t.VALIDENDDATE = p_VALIDENDDATE
        where  t.CARDNO       = p_CARDNO;
        
        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;    
		EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S001100100';
	            p_retMsg  := 'Fail to update tf_f_cardrec' || SQLERRM;
	            ROLLBACK; RETURN;
    END;
    
    BEGIN
        -- 修正卡账户信息
        update TF_F_CARDEWALLETACC t
        set    t.CARDACCMONEY     = p_ADJUSTMONEY,
               t.SUPPLYREALMONEY  = p_ADJUSTMONEY,
               t.TOTALSUPPLYTIMES = 1,
               t.TOTALSUPPLYMONEY = p_ADJUSTMONEY,
               t.LASTSUPPLYTIME   = p_CURRENTTIME
        where  t.CARDNO           = p_CARDNO;
        
        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;    
		EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S001100114';
	            p_retMsg  := 'S001002113:Unable to Updated electronic wallet account information' || SQLERRM;
	            ROLLBACK; RETURN;
    END;
    
    --4) update the TF_SPEADJUSTOFFERACC info
    BEGIN
        UPDATE TF_SPEADJUSTOFFERACC
        SET  OFFERMONEY       = 0,
             TOTALSUPPLYTIMES = TOTALSUPPLYTIMES + 1,
             TOTALSUPPLYMONEY = TOTALSUPPLYMONEY + p_ADJUSTMONEY
        WHERE CARDNO = p_OLDCARDNO;

        IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S009113114';
        p_retMsg  := SQLERRM;
        ROLLBACK; RETURN;
    END;

    --5) update TF_B_SPEADJUSTACC info

    BEGIN
        UPDATE TF_B_SPEADJUSTACC
        SET    STATECODE     = '2'       ,
               SUPPTRADEID   = v_TRADEID ,
               SUPPSTAFFNO   = p_currOper,
               SUPPTIME      = p_CURRENTTIME
        WHERE  CARDNO        = p_OLDCARDNO
        AND    TRADETYPECODE = '97'
        AND    STATECODE     = '1';

        IF SQL%ROWCOUNT = 0 THEN RAISE v_ex; END IF;
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S009111002';
        p_retMsg  := SQLERRM;
        ROLLBACK; RETURN;
    END;


    --6) add TF_SPEADJUST_SUPPLY info
    
    select ASN into v_ASN from tf_f_cardrec
    where cardno = p_CARDNO;
    
    BEGIN
        INSERT INTO TF_SPEADJUST_SUPPLY
            (TRADEID, ID  , CARDNO  , ASN  , CARDTYPECODE  , CARDTRADENO  , TRADEMONEY   ,
            PREMONEY   , TERMNO  , OPERATESTAFFNO, OPERATEDEPARTID, OPERATETIME)
        VALUES
           (v_TRADEID , p_ID, p_CARDNO, v_ASN, p_CARDTYPECODE, p_CARDTRADENO, p_ADJUSTMONEY,
            p_CARDMONEY, p_TERMNO, p_currOper    , p_currDept     , p_CURRENTTIME );

    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S009113115';
        p_retMsg  := SQLERRM;
        ROLLBACK; RETURN;
    END;

    p_retCode := '0000000000';
	p_retMsg  := '';
	COMMIT; RETURN;
END;

/

show errors



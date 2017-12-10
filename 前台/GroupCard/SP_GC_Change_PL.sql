CREATE OR REPLACE PROCEDURE SP_GC_Change
(
    p_oldCardNo char,
    p_newCardNo char,
    
    p_replaceInfo   char,
    
    p_custName          varchar2,
    p_custSex           varchar2,
    p_custBirth         varchar2,
    p_paperType         varchar2,
    p_paperNo           varchar2,
    p_custAddr          varchar2,
    p_custPost          varchar2,
    p_custPhone         varchar2,
    p_custEmail         varchar2,
    p_remark            varchar2,

    p_currOper  char,
    p_currDept  char,
    p_retCode   out char, -- Return Code
    p_retMsg    out varchar2  -- Return Message
)
AS
    v_today     date := sysdate;
    v_OFFERMONEY int;
    v_groupCode char(4);
    v_quantity  int;
    v_ex        exception;
    v_seqNo     char(16);
BEGIN
    
    -- 1) Check the old card status
    BEGIN
        SELECT CORPNO INTO v_groupCode FROM TD_GROUP_CARD
            WHERE CARDNO = p_oldCardNo AND USETAG = '1';
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
        p_retCode := 'A004P08B01'; p_retMsg  := '旧卡不是一个有效的企服卡,' || SQLERRM;
        RETURN;
    END;

    -- 2) Check the new card status
    BEGIN
        SELECT 1 INTO v_quantity FROM TD_GROUP_CARD WHERE CARDNO = p_newCardNo AND USETAG = '1';
        
        p_retCode := 'A004P08B02'; p_retMsg  := '新卡已经是企服卡,' || SQLERRM;
        RETURN;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN NULL;
    END;

    -- 3) Check whether the new card is already a sold card
    BEGIN
        SELECT 1 INTO v_quantity FROM TF_F_CARDREC WHERE CARDNO = p_newCardNo
            AND USETAG = '1' AND CARDSTATE in ('10', '11');
        
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            p_retCode := 'A004P08B03'; p_retMsg  := '新卡不是已售出状态（要求先做普通换卡）,';
            RETURN;
    END;
            

    -- 4) Setup the relation between new card and group
    BEGIN
        merge into TD_GROUP_CARD t using dual
        on (t.CARDNO = p_newCardNo)
        when matched then update set 
            t.CORPNO = v_groupCode,
            t.USETAG = '1',
            t.UPDATESTAFFNO = p_currOper,
            t.UPDATETIME = v_today
        when not matched then
            insert (CARDNO, CORPNO, USETAG, UPDATESTAFFNO, UPDATETIME)
            VALUES(p_newCardNo, v_groupCode, '1'   , p_currOper, v_today )
        ;
        
        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S004P08B04'; p_retMsg  := '新增新卡与集团客户的关联关系,' || SQLERRM;
            ROLLBACK; RETURN;
    END;
        
    -- 5) Break up the relation between old card and group
    BEGIN
        UPDATE TD_GROUP_CARD SET USETAG = '0' WHERE  CARDNO = p_oldCardNo;
        
        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S004P08B05'; p_retMsg  := '关闭老卡与集团客户的关联关系,' || SQLERRM;
            ROLLBACK; RETURN;
    END;


    -- 6) Setup the group account for the new card
    BEGIN
        update TF_F_CARDOFFERACC set (OFFERMONEY, USETAG, PASSWD, 
                BEGINTIME, ENDTIME, TOTALSUPPLYTIMES, TOTALSUPPLYMONEY) =
              (select OFFERMONEY, USETAG, PASSWD, 
                BEGINTIME, ENDTIME, TOTALSUPPLYTIMES, TOTALSUPPLYMONEY
               from TF_F_CARDOFFERACC
               where CARDNO = p_oldCardNo)
        where CARDNO = p_newCardNo;
        
        IF  SQL%ROWCOUNT = 0 THEN
            INSERT INTO TF_F_CARDOFFERACC (CARDNO, OFFERMONEY, USETAG, PASSWD, 
                BEGINTIME, ENDTIME, TOTALSUPPLYTIMES, TOTALSUPPLYMONEY)
            SELECT p_newCardNo, OFFERMONEY, USETAG, PASSWD, 
                BEGINTIME, ENDTIME, TOTALSUPPLYTIMES, TOTALSUPPLYMONEY
               from TF_F_CARDOFFERACC
               where CARDNO = p_oldCardNo;            
            IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
        END IF;
        
        select OFFERMONEY into v_OFFERMONEY from TF_F_CARDOFFERACC
        where cardno = p_oldCardNo;
    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S004P08B06'; p_retMsg  := '新增新卡企服卡帐户失败,' || SQLERRM;
            ROLLBACK; RETURN;
    END;
        
    -- 7) Break up the group account for the old card
    BEGIN
        UPDATE TF_F_CARDOFFERACC SET USETAG = '0' WHERE CARDNO = p_oldCardNo;
        
        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S004P08B07'; p_retMsg  := '关闭旧卡企服卡帐户失败,' || SQLERRM;
            ROLLBACK; RETURN;
    END;
        
    -- 8) Setup the relation between the new card and features.
    BEGIN
        UPDATE TF_F_CARDUSEAREA SET (USETAG, UPDATESTAFFNO , UPDATETIME) =
            (SELECT '1', p_currOper , v_today FROM DUAL)
        WHERE CARDNO = p_newCardNo AND FUNCTIONTYPE = '01';
        
        IF  SQL%ROWCOUNT = 0 THEN
            INSERT INTO TF_F_CARDUSEAREA
                  (CARDNO    , FUNCTIONTYPE, USETAG, UPDATESTAFFNO , UPDATETIME)
            VALUES(p_newCardNo, '01'        , '1'   , p_currOper, v_today );
            IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S004P08B08'; p_retMsg  := '新增新卡与企服卡功能项的关联关系失败,' || SQLERRM;
            ROLLBACK; RETURN;
    END;
        
    -- 9) Breakup the relation bwtween the old card and features.
    BEGIN
        UPDATE TF_F_CARDUSEAREA SET    USETAG = '0',  
               UPDATESTAFFNO = p_currOper, UPDATETIME = v_today
        WHERE CARDNO = p_oldCardNo AND FUNCTIONTYPE = '01';
        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
   EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S004P08B09'; p_retMsg  := '关闭新卡与企服卡功能项的关联关系失败,' || SQLERRM;
            ROLLBACK; RETURN;
    END;
        
    SP_GetSeq(seq => v_seqNo);

    -- 10) Log this operation
    BEGIN
        INSERT INTO TF_B_TRADE(TRADEID, TRADETYPECODE, CARDNO , CURRENTMONEY, OLDCARDNO , CORPNO,
                OPERATESTAFFNO, OPERATEDEPARTID, OPERATETIME)
        VALUES (v_seqNo , '18'         , p_newCardNo, v_OFFERMONEY,  p_oldCardNo, v_groupCode,
                p_currOper, p_currDept  , v_today  );
    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S004P08B10'; p_retMsg  := '新增企服卡换卡台帐失败,' || SQLERRM;
            ROLLBACK; RETURN;
    END;
    
    begin
        if p_replaceInfo = '0' then
            update TF_F_CUSTOMERREC set 
               CUSTNAME      = p_custName , 
               CUSTSEX       = p_custSex  , 
               CUSTBIRTH     = p_custBirth,
               PAPERTYPECODE = p_paperType, 
               PAPERNO       = p_paperNo  ,
               CUSTADDR      = p_custAddr , 
               CUSTPOST      = p_custPost , 
               CUSTPHONE     = p_custPhone,
               CUSTEMAIL     = p_CustEmail, 
               UPDATESTAFFNO = p_currOper , 
               UPDATETIME    = v_today    
            where CARDNO     = p_newCardNo;    
            IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;

            INSERT INTO TF_B_CUSTOMERCHANGE
            (   TRADEID, CARDNO, CUSTNAME, CUSTSEX, CUSTBIRTH, 
                PAPERTYPECODE, PAPERNO, CUSTADDR, CUSTPOST, CUSTPHONE, CUSTEMAIL,
                CHGTYPECODE, OPERATESTAFFNO, OPERATEDEPARTID, OPERATETIME )
            VALUES(v_seqNo, p_newCardNo, p_custName,p_custSex, p_custBirth,
                p_paperType, p_paperNo, p_custAddr, p_custPost, p_custPhone, p_CustEmail,
                '01', p_currOper, p_currDept, v_today);
        else
            update TF_F_CUSTOMERREC set (CUSTNAME, CUSTSEX, CUSTBIRTH, PAPERTYPECODE, PAPERNO, 
                CUSTADDR, CUSTPOST, CUSTPHONE, CUSTEMAIL, UPDATESTAFFNO, UPDATETIME) = 
            (select CUSTNAME, CUSTSEX, CUSTBIRTH, PAPERTYPECODE, PAPERNO, 
                CUSTADDR, CUSTPOST, CUSTPHONE, CUSTEMAIL, p_currOper, v_today
                from TF_F_CUSTOMERREC where CARDNO = p_oldCardNo)
            where CARDNO = p_newCardNo;
            IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
            
            INSERT INTO TF_B_CUSTOMERCHANGE
            (   TRADEID, CARDNO, CUSTNAME, CUSTSEX, CUSTBIRTH, 
                PAPERTYPECODE, PAPERNO, CUSTADDR, CUSTPOST, CUSTPHONE, CUSTEMAIL,
                CHGTYPECODE, OPERATESTAFFNO, OPERATEDEPARTID, OPERATETIME )
            select v_seqNo, CARDNO, CUSTNAME, CUSTSEX, CUSTBIRTH, 
                PAPERTYPECODE, PAPERNO, CUSTADDR, CUSTPOST, CUSTPHONE, CUSTEMAIL,
                '01', p_currOper, p_currDept, v_today
            from   TF_F_CUSTOMERREC
            where CARDNO = p_oldCardNo;
        end if;
        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    exception when others then
        p_retCode := 'S004P08B11'; p_retMsg  := '更新客户资料失败,' || SQLERRM;
        ROLLBACK; RETURN;
    end;   
         
    p_retCode := '0000000000'; p_retMsg  := '';
    COMMIT; RETURN;
END;
/

show errors

CREATE OR REPLACE PROCEDURE SP_EW_RETURNDISC
(
    p_CARDNO                 CHAR,  --卡号
    p_STRICUSER              OUT VARCHAR2, --卡库存表字符串
    p_STRSMKICUSERTRADE      OUT VARCHAR2, --市民卡库存操作台账字符串
    p_STRCARDEWALLETACC_BACK OUT VARCHAR2, --卡退值表字符串
    p_STRCARDREC             OUT VARCHAR2, --卡资料表字符串
    p_STRCARDEWALLETACC      OUT VARCHAR2, --卡账户表字符串
    p_STRCUSTOMERREC         OUT VARCHAR2, --持卡人资料表字符串
    p_STRCUSTOMERCHANGE      OUT VARCHAR2, --持卡人资料变更表字符串
    p_STRTRADE               OUT VARCHAR2, --主台账表字符串
    p_STRTRADEFEE            OUT VARCHAR2, --现金台账表字符串
    p_currOper          char    ,
    p_currDept          char    ,
    p_retCode       out char    ,  -- Return Code
    p_retMsg        out varchar2   -- Return Message
)
AS
    V_INSTIME           VARCHAR2(100):='''''';
    V_OUTTIME           VARCHAR2(100):='''''';
    V_ALLOCTIME         VARCHAR2(100):='''''';
    V_SELLTIME          VARCHAR2(100):='''''';
    V_DESTROYTIME       VARCHAR2(100):='''''';
    V_RECLAIMTIME       VARCHAR2(100):='''''';
    V_FREEZEDATE        VARCHAR2(100):='''''';
    V_SERSTARTTIME      VARCHAR2(100):='''''';
    V_RSRV              VARCHAR2(100):='''''';
    V_CREDITSTACHANGETIME VARCHAR2(100):='''''';
    V_CREDITCOLCHANGETIME VARCHAR2(100):='''''';
    V_FIRSTCONSUMETIME  VARCHAR2(100):='''''';
    V_LASTCONSUMETIME   VARCHAR2(100):='''''';
    V_FIRSTSUPPLYTIME   VARCHAR2(100):='''''';
    V_LASTSUPPLYTIME    VARCHAR2(100):='''''';
    V_CHECKTIME         VARCHAR2(100):='''''';
BEGIN
    --备份卡库存表
    FOR CUR IN (select * from TL_R_ICUSER where cardno = p_CARDNO)
    LOOP
        IF (CUR.INSTIME IS NOT NULL) OR (CUR.INSTIME <> '') THEN
            V_INSTIME := 'to_date('''||to_char(CUR.INSTIME,'dd-mm-yyyy hh24:mi:ss')||''', ''dd-mm-yyyy hh24:mi:ss'')';
        END IF;
        IF (CUR.OUTTIME IS NOT NULL) OR (CUR.OUTTIME <> '') THEN
            V_OUTTIME := 'to_date('''||to_char(CUR.OUTTIME,'dd-mm-yyyy hh24:mi:ss')||''', ''dd-mm-yyyy hh24:mi:ss'')';
        END IF;
        IF (CUR.ALLOCTIME IS NOT NULL) OR (CUR.ALLOCTIME <> '') THEN
            V_ALLOCTIME := 'to_date('''||to_char(CUR.ALLOCTIME,'dd-mm-yyyy hh24:mi:ss')||''', ''dd-mm-yyyy hh24:mi:ss'')';
        END IF;
        IF (CUR.SELLTIME IS NOT NULL) OR (CUR.SELLTIME <> '') THEN
            V_SELLTIME := 'to_date('''||to_char(CUR.SELLTIME,'dd-mm-yyyy hh24:mi:ss')||''', ''dd-mm-yyyy hh24:mi:ss'')';
        END IF;
        IF (CUR.DESTROYTIME IS NOT NULL) OR (CUR.DESTROYTIME <> '') THEN
            V_DESTROYTIME := 'to_date('''||to_char(CUR.DESTROYTIME,'dd-mm-yyyy hh24:mi:ss')||''', ''dd-mm-yyyy hh24:mi:ss'')';
        END IF;
        IF (CUR.RECLAIMTIME IS NOT NULL) OR (CUR.RECLAIMTIME <> '') THEN
            V_RECLAIMTIME := 'to_date('''||to_char(CUR.RECLAIMTIME,'dd-mm-yyyy hh24:mi:ss')||''', ''dd-mm-yyyy hh24:mi:ss'')';
        END IF;
        IF (CUR.FREEZEDATE IS NOT NULL) OR (CUR.FREEZEDATE <> '') THEN
            V_FREEZEDATE := 'to_date('''||to_char(CUR.FREEZEDATE,'dd-mm-yyyy hh24:mi:ss')||''', ''dd-mm-yyyy hh24:mi:ss'')';
        END IF;
        p_STRICUSER := p_STRICUSER||'INSERT INTO TL_R_ICUSER(CARDNO,RESSTATECODE,ASN,COSTYPECODE,CARDTYPECODE,
        CARDPRICE,MANUTYPECODE,CARDSURFACECODE,CARDCHIPTYPECODE,VALIDBEGINDATE,VALIDENDDATE,APPTYPECODE,
        APPVERNO,PRESUPPLYMONEY,SERVICECYCLE,EVESERVICEPRICE,INSTIME,OUTTIME,ALLOCTIME,SELLTIME,DESTROYTIME,
        RECLAIMTIME,FREEZEDATE,ASSIGNEDSTAFFNO,ASSIGNEDDEPARTID,UPDATESTAFFNO,UPDATETIME,RSRV1,SALETYPE)VALUES
        ('''||CUR.CARDNO||''','''||CUR.RESSTATECODE||''','''||CUR.ASN||''','''||CUR.COSTYPECODE||''','''||CUR.CARDTYPECODE||''',
        '''||CUR.CARDPRICE||''','''||CUR.MANUTYPECODE||''','''||CUR.CARDSURFACECODE||''','''||CUR.CARDCHIPTYPECODE||''','''||CUR.VALIDBEGINDATE||''',
        '''||CUR.VALIDENDDATE||''','''||CUR.APPTYPECODE||''','''||CUR.APPVERNO||''','''||CUR.PRESUPPLYMONEY||''','''||CUR.SERVICECYCLE||''',
        '''||CUR.EVESERVICEPRICE||''','||V_INSTIME||','||V_OUTTIME||','||V_ALLOCTIME||','||V_SELLTIME||','||V_DESTROYTIME||','||V_RECLAIMTIME||','||V_FREEZEDATE||',
        '''||CUR.ASSIGNEDSTAFFNO||''','''||CUR.ASSIGNEDDEPARTID||''','''||CUR.UPDATESTAFFNO||''',
        to_date('''||to_char(CUR.UPDATETIME,'dd-mm-yyyy hh24:mi:ss')||''', ''dd-mm-yyyy hh24:mi:ss''),'''||CUR.RSRV1||''','''||CUR.SALETYPE||''');';
    END LOOP;

    --备份市民卡出入库台账表
    FOR CUR IN (select * from TF_R_SMKICUSERTRADE where cardno = p_CARDNO)
    LOOP
        p_STRSMKICUSERTRADE := p_STRSMKICUSERTRADE||'INSERT INTO TF_R_SMKICUSERTRADE (TRADEID, OPETYPECODE, CARDNO, COSTYPECODE,
        CARDTYPECODE, MANUTYPECODE, CARDSURFACECODE, CARDCHIPTYPECODE, CARDPRICE, ASSIGNEDSTAFFNO,
        ASSIGNEDDEPARTID, OPERATESTAFFNO, OPERATEDEPARTID, OPERATETIME, RSRV1)
        values ('''||CUR.TRADEID||''', '''||CUR.OPETYPECODE||''', '''||CUR.CARDNO||''', '''||CUR.COSTYPECODE||''',
        '''||CUR.CARDTYPECODE||''', '''||CUR.MANUTYPECODE||''', '''||CUR.CARDSURFACECODE||''', '''||CUR.CARDCHIPTYPECODE||''',
        '''||CUR.CARDPRICE||''', '''||CUR.ASSIGNEDSTAFFNO||''', '''||CUR.ASSIGNEDDEPARTID||''', '''||CUR.OPERATESTAFFNO||''',
        '''||CUR.OPERATEDEPARTID||''', to_date('''||to_char(CUR.OPERATETIME,'dd-mm-yyyy hh24:mi:ss')||''', ''dd-mm-yyyy hh24:mi:ss''), '''||CUR.RSRV1||''');';
    END LOOP;

    --备份退值表
    FOR CUR IN (select * from TF_F_CARDEWALLETACC_BACK where cardno = p_CARDNO)
    LOOP
        p_STRCARDEWALLETACC_BACK := p_STRCARDEWALLETACC_BACK||'INSERT INTO TF_F_CARDEWALLETACC_BACK (CARDNO, JUDGEMONEY, JUDGEMODE,
        USETAG, UPDATESTAFFNO, UPDATETIME, REMARK)
        values ('''||CUR.CARDNO||''', '''||CUR.JUDGEMONEY||''', '''||CUR.JUDGEMODE||''', '''||CUR.USETAG||''',
        '''||CUR.UPDATESTAFFNO||''', to_date('''||to_char(CUR.UPDATETIME,'dd-mm-yyyy hh24:mi:ss')||''', ''dd-mm-yyyy hh24:mi:ss''), '''||CUR.REMARK||''');';
    END LOOP;

    --备份卡资料表
    FOR CUR IN (select * from TF_F_CARDREC where cardno = p_CARDNO)
    LOOP
        IF (CUR.SELLTIME IS NOT NULL) OR (CUR.SELLTIME <> '') THEN
            V_SELLTIME := 'to_date('''||to_char(CUR.SELLTIME,'dd-mm-yyyy hh24:mi:ss')||''', ''dd-mm-yyyy hh24:mi:ss'')';
        END IF;
        IF (CUR.SERSTARTTIME IS NOT NULL) OR (CUR.SERSTARTTIME <> '') THEN
            V_SERSTARTTIME := 'to_date('''||to_char(CUR.SERSTARTTIME,'dd-mm-yyyy hh24:mi:ss')||''', ''dd-mm-yyyy hh24:mi:ss'')';
        END IF;
        IF (CUR.RSRV3 IS NOT NULL) OR (CUR.RSRV3 <> '') THEN
            V_RSRV := 'to_date('''||to_char(CUR.RSRV3,'dd-mm-yyyy hh24:mi:ss')||''', ''dd-mm-yyyy hh24:mi:ss'')';
        END IF;
        p_STRCARDREC := p_STRCARDREC||'INSERT INTO TF_F_CARDREC (CARDNO, ASN, CARDTYPECODE, CARDSURFACECODE, CARDMANUCODE,
        CARDCHIPTYPECODE, APPTYPECODE, APPVERNO, DEPOSIT, CARDCOST, PRESUPPLYMONEY, CUSTRECTYPECODE, SELLTIME,
        SELLCHANNELCODE, DEPARTNO, STAFFNO, CARDSTATE, VALIDENDDATE, USETAG, SERSTARTTIME, SERSTAKETAG, SERVICEMONEY,
        UPDATESTAFFNO, UPDATETIME, RSRV1, RSRV2, RSRV3, REMARK)
        values ('''||CUR.CARDNO||''', '''||CUR.ASN||''', '''||CUR.CARDTYPECODE||''', '''||CUR.CARDSURFACECODE||''',
        '''||CUR.CARDMANUCODE||''', '''||CUR.CARDCHIPTYPECODE||''', '''||CUR.APPTYPECODE||''', '''||CUR.APPVERNO||''',
        '''||CUR.DEPOSIT||''', '''||CUR.CARDCOST||''', '''||CUR.PRESUPPLYMONEY||''', '''||CUR.CUSTRECTYPECODE||''',
        '||V_SELLTIME||', '''||CUR.SELLCHANNELCODE||''', '''||CUR.DEPARTNO||''',
        '''||CUR.STAFFNO||''', '''||CUR.CARDSTATE||''', '''||CUR.VALIDENDDATE||''', '''||CUR.USETAG||''', '||V_SERSTARTTIME||',
        '''||CUR.SERSTAKETAG||''', '''||CUR.SERVICEMONEY||''', '''||CUR.UPDATESTAFFNO||''', to_date('''||to_char(CUR.UPDATETIME,'dd-mm-yyyy hh24:mi:ss')||''', ''dd-mm-yyyy hh24:mi:ss''),
        '''||CUR.RSRV1||''', '''||CUR.RSRV2||''', '||V_RSRV||', '''||CUR.REMARK||''');';

    END LOOP;

    --备份卡账户表
    FOR CUR IN (select * from TF_F_CARDEWALLETACC where cardno = p_CARDNO)
    LOOP
        IF (CUR.CREDITSTACHANGETIME IS NOT NULL) OR (CUR.CREDITSTACHANGETIME <> '') THEN
            V_CREDITSTACHANGETIME := 'to_date('''||to_char(CUR.CREDITSTACHANGETIME,'dd-mm-yyyy hh24:mi:ss')||''', ''dd-mm-yyyy hh24:mi:ss'')';
        END IF;
        IF (CUR.CREDITCOLCHANGETIME IS NOT NULL) OR (CUR.CREDITCOLCHANGETIME <> '') THEN
            V_CREDITCOLCHANGETIME := 'to_date('''||to_char(CUR.CREDITCOLCHANGETIME,'dd-mm-yyyy hh24:mi:ss')||''', ''dd-mm-yyyy hh24:mi:ss'')';
        END IF;
        IF (CUR.FIRSTCONSUMETIME IS NOT NULL) OR (CUR.FIRSTCONSUMETIME <> '') THEN
            V_FIRSTCONSUMETIME := 'to_date('''||to_char(CUR.FIRSTCONSUMETIME,'dd-mm-yyyy hh24:mi:ss')||''', ''dd-mm-yyyy hh24:mi:ss'')';
        END IF;
        IF (CUR.LASTCONSUMETIME IS NOT NULL) OR (CUR.LASTCONSUMETIME <> '') THEN
            V_LASTCONSUMETIME := 'to_date('''||to_char(CUR.LASTCONSUMETIME,'dd-mm-yyyy hh24:mi:ss')||''', ''dd-mm-yyyy hh24:mi:ss'')';
        END IF;
        IF (CUR.FIRSTSUPPLYTIME IS NOT NULL) OR (CUR.FIRSTSUPPLYTIME <> '') THEN
            V_FIRSTSUPPLYTIME := 'to_date('''||to_char(CUR.FIRSTSUPPLYTIME,'dd-mm-yyyy hh24:mi:ss')||''', ''dd-mm-yyyy hh24:mi:ss'')';
        END IF;
        IF (CUR.LASTSUPPLYTIME IS NOT NULL) OR (CUR.LASTSUPPLYTIME <> '') THEN
            V_LASTSUPPLYTIME := 'to_date('''||to_char(CUR.LASTSUPPLYTIME,'dd-mm-yyyy hh24:mi:ss')||''', ''dd-mm-yyyy hh24:mi:ss'')';
        END IF;
        IF (CUR.RSRV3 IS NOT NULL) OR (CUR.RSRV3 <> '') THEN
            V_RSRV := 'to_date('''||to_char(CUR.RSRV3,'dd-mm-yyyy hh24:mi:ss')||''', ''dd-mm-yyyy hh24:mi:ss'')';
        END IF;

        p_STRCARDEWALLETACC := p_STRCARDEWALLETACC||'INSERT INTO TF_F_CARDEWALLETACC (CARDNO, CARDACCMONEY, USETAG, CREDITSTATECODE,
        CREDITSTACHANGETIME, CREDITCONTROLCODE, CREDITCOLCHANGETIME, ACCSTATECODE, CONSUMEREALMONEY, SUPPLYREALMONEY,
        TOTALCONSUMETIMES, TOTALSUPPLYTIMES, TOTALCONSUMEMONEY, TOTALSUPPLYMONEY, FIRSTCONSUMETIME, LASTCONSUMETIME,
        FIRSTSUPPLYTIME, LASTSUPPLYTIME, OFFLINECARDTRADENO, ONLINECARDTRADENO, RSRV1, RSRV2, RSRV3, REMARK)
        values ('''||CUR.CARDNO||''', '''||CUR.CARDACCMONEY||''', '''||CUR.USETAG||''', '''||CUR.CREDITSTATECODE||''',
        '||V_CREDITSTACHANGETIME||', '''||CUR.CREDITCONTROLCODE||''', '||V_CREDITCOLCHANGETIME||', '''||CUR.ACCSTATECODE||''',
        '''||CUR.CONSUMEREALMONEY||''', '''||CUR.SUPPLYREALMONEY||''', '''||CUR.TOTALCONSUMETIMES||''', '''||CUR.TOTALSUPPLYTIMES||''',
        '''||CUR.TOTALCONSUMEMONEY||''', '''||CUR.TOTALSUPPLYMONEY||''', '||V_FIRSTCONSUMETIME||', '||V_LASTCONSUMETIME||', '||V_FIRSTSUPPLYTIME||',
        '||V_LASTSUPPLYTIME||', '''||CUR.OFFLINECARDTRADENO||''', '''||CUR.ONLINECARDTRADENO||''', '''||CUR.RSRV1||''', '''||CUR.RSRV2||''',
        '||V_RSRV||', '''||CUR.REMARK||''');';
    END LOOP;

    --备份持卡人资料表
    FOR CUR IN (select * from TF_F_CUSTOMERREC where cardno = p_CARDNO)
    LOOP
        p_STRCUSTOMERREC := p_STRCUSTOMERREC||'INSERT INTO TF_F_CUSTOMERREC (CARDNO, CUSTNAME, CUSTSEX, CUSTBIRTH, PAPERTYPECODE,
        PAPERNO, CUSTADDR, CUSTPOST, CUSTPHONE, CUSTEMAIL, USETAG, UPDATESTAFFNO, UPDATETIME, REMARK)
        values ('''||CUR.CARDNO||''', '''||CUR.CUSTNAME||''', '''||CUR.CUSTSEX||''', '''||CUR.CUSTBIRTH||''', '''||CUR.PAPERTYPECODE||''',
        '''||CUR.PAPERNO||''', '''||CUR.CUSTADDR||''', '''||CUR.CUSTPOST||''', '''||CUR.CUSTPHONE||''', '''||CUR.CUSTEMAIL||''',
        '''||CUR.USETAG||''', '''||CUR.UPDATESTAFFNO||''', to_date('''||to_char(CUR.UPDATETIME,'dd-mm-yyyy hh24:mi:ss')||''', ''dd-mm-yyyy hh24:mi:ss''), '''||CUR.REMARK||''');';

    END LOOP;

    --备份持卡人资料变更表
    FOR CUR IN (select * from TF_B_CUSTOMERCHANGE where cardno = p_CARDNO)
    LOOP
        p_STRCUSTOMERCHANGE := p_STRCUSTOMERCHANGE||'INSERT INTO TF_B_CUSTOMERCHANGE (TRADEID, CARDNO, CUSTNAME, CUSTSEX, CUSTBIRTH, PAPERTYPECODE, PAPERNO, CUSTADDR,
        CUSTPOST, CUSTPHONE, CUSTEMAIL, PASSWD, CHGTYPECODE, OPERATESTAFFNO, OPERATEDEPARTID, OPERATETIME, REMARK)
        values ('''||CUR.TRADEID||''', '''||CUR.CARDNO||''', '''||CUR.CUSTNAME||''', '''||CUR.CUSTSEX||''', '''||CUR.CUSTBIRTH||''', '''||CUR.PAPERTYPECODE||''',
        '''||CUR.PAPERNO||''', '''||CUR.CUSTADDR||''', '''||CUR.CUSTPOST||''', '''||CUR.CUSTPHONE||''', '''||CUR.CUSTEMAIL||''','''||CUR.PASSWD||''',
        '''||CUR.CHGTYPECODE||''', '''||CUR.OPERATESTAFFNO||''', '''||CUR.OPERATEDEPARTID||''', to_date('''||to_char(CUR.OPERATETIME,'dd-mm-yyyy hh24:mi:ss')||''', ''dd-mm-yyyy hh24:mi:ss''),
        '''||CUR.REMARK||''');';

    END LOOP;

    --备份主台账表
    FOR CUR IN (select * from tf_b_trade where cardno = p_CARDNO and rownum = 1)
    LOOP
        IF (CUR.CHECKTIME IS NOT NULL) OR (CUR.CHECKTIME <> '') THEN
            V_CHECKTIME := 'to_date('''||to_char(CUR.CHECKTIME,'dd-mm-yyyy hh24:mi:ss')||''', ''dd-mm-yyyy hh24:mi:ss'')';
        END IF;
        p_STRTRADE := p_STRTRADE||'INSERT INTO tf_b_trade (TRADEID, CARDNO, ID, TRADETYPECODE, ASN, CARDTYPECODE, CARDTRADENO, REASONCODE,
        OLDCARDNO, DEPOSIT, OLDCARDMONEY, CURRENTMONEY, PREMONEY, NEXTMONEY, CORPNO, OPERATESTAFFNO, OPERATEDEPARTID, OPERATETIME,
        CHECKSTAFFNO, CHECKDEPARTNO, CHECKTIME, STATECODE, CANCELTAG, CANCELTRADEID, CARDSTATE, SERSTAKETAG, RSRV1, RSRV2, TRADEORIGIN)
        values ('''||CUR.TRADEID||''', '''||CUR.CARDNO||''', '''||CUR.ID||''', '''||CUR.TRADETYPECODE||''', '''||CUR.ASN||''', '''||CUR.CARDTYPECODE||''',
        '''||CUR.CARDTRADENO||''', '''||CUR.REASONCODE||''', '''||CUR.OLDCARDNO||''', '''||CUR.DEPOSIT||''', '''||CUR.OLDCARDMONEY||''', '''||CUR.CURRENTMONEY||''',
        '''||CUR.PREMONEY||''', '''||CUR.NEXTMONEY||''', '''||CUR.CORPNO||''', '''||CUR.OPERATESTAFFNO||''', '''||CUR.OPERATEDEPARTID||''',
        to_date('''||to_char(CUR.OPERATETIME,'dd-mm-yyyy hh24:mi:ss')||''', ''dd-mm-yyyy hh24:mi:ss''), '''||CUR.CHECKSTAFFNO||''', '''||CUR.CHECKDEPARTNO||''', '||V_CHECKTIME||',
        '''||CUR.STATECODE||''', '''||CUR.CANCELTAG||''', '''||CUR.CANCELTRADEID||''', '''||CUR.CARDSTATE||''', '''||CUR.SERSTAKETAG||''',
        '''||CUR.RSRV1||''', '''||CUR.RSRV2||''', '''||CUR.TRADEORIGIN||''');';

    END LOOP;

    --备份现金台账表
    FOR CUR IN (select * from tf_b_tradefee where cardno = p_CARDNO)
    LOOP
        p_STRTRADEFEE := p_STRTRADEFEE||'INSERT INTO tf_b_tradefee(ID, TRADEID, TRADETYPECODE, CARDNO, CARDTRADENO, PREMONEY, CARDSERVFEE, CARDDEPOSITFEE,
        SUPPLYMONEY, TRADEPROCFEE, FUNCFEE, OTHERFEE, OPERATESTAFFNO, OPERATEDEPARTID, OPERATETIME, CANCELTAG, COLLECTTAG, RSRV1, RSRV2, RSRV3, TRADEORIGIN)
        values('''||CUR.ID||''','''||CUR.TRADEID||''','''||CUR.TRADETYPECODE||''','''||CUR.CARDNO||''','''||CUR.CARDTRADENO||''','''||CUR.PREMONEY||''',
        '''||CUR.CARDSERVFEE||''','''||CUR.CARDDEPOSITFEE||''','''||CUR.SUPPLYMONEY||''','''||CUR.TRADEPROCFEE||''','''||CUR.FUNCFEE||''','''||CUR.OTHERFEE||''',
        '''||CUR.OPERATESTAFFNO||''','''||CUR.OPERATEDEPARTID||''',to_date('''||to_char(CUR.OPERATETIME,'dd-mm-yyyy hh24:mi:ss')||''', ''dd-mm-yyyy hh24:mi:ss''),'''||CUR.CANCELTAG||''',
        '''||CUR.COLLECTTAG||''','''||CUR.RSRV1||''','''||CUR.RSRV2||''','''||CUR.RSRV3||''','''||CUR.TRADEORIGIN||''');';
    END LOOP;

    --删除记录
    BEGIN
        delete from tf_b_trade where cardno = p_CARDNO;
        delete from tf_b_tradefee where cardno = p_CARDNO;
        delete from tl_r_icuser where cardno = p_CARDNO;
        delete from TF_R_SMKICUSERTRADE where cardno = p_CARDNO;
        delete from TF_F_CARDEWALLETACC_BACK where cardno = p_CARDNO;
        delete from TF_F_CARDREC where cardno = p_CARDNO;
        delete from TF_F_CARDEWALLETACC where cardno = p_CARDNO;
        delete from TF_F_CUSTOMERREC where cardno = p_CARDNO;
        delete from TF_B_CUSTOMERCHANGE where cardno = p_CARDNO;
    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S094570098'; p_retMsg  := '删除卡相关数据失败,'||SQLERRM;
            RETURN;
    END;
    p_retCode := '0000000000';
    p_retMsg  := '成功';
    RETURN;
END;
/
show error;

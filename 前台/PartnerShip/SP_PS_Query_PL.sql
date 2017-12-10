create or replace procedure SP_PS_Query
(
    p_funcCode   varchar2,
    p_var1       varchar2,
    p_var2       varchar2,
    p_var3       varchar2,
    p_var4       varchar2,
    p_var5       varchar2,
    p_var6       varchar2,
    p_var7       varchar2,
    p_var8       varchar2,
    p_var9       varchar2,
    p_cursor out SYS_REFCURSOR
)
as

begin
if p_funcCode = 'QueryGroupCustomer' then -- 查询集团客户资料表(TD_GROUP_CUSTOMER)
    open p_cursor for
    SELECT tgroup.CORPCODE, tgroup.CORPNAME, tgroup.LINKMAN, tgroup.CORPADD,
           tgroup.CORPPHONE, tgroup.USETAG, tgroup.REMARK, tgroup.SERMANAGERCODE,
           tgroup.CORPEMAIL, tstuff.STAFFNAME
    FROM   TD_GROUP_CUSTOMER tgroup left join TD_M_INSIDESTAFF tstuff
    ON     tgroup.SERMANAGERCODE = tstuff.STAFFNO
    WHERE  (p_var1 is null OR tgroup.CORPNAME like '%'|| p_var1 || '%' )
    ORDER BY tgroup.CORPCODE
    ;
elsif p_funcCode = 'QueryComScheme' then
    open p_cursor for
    SELECT tfbal.BALUNITNO, tfbal.BALUNITNO || ':' || tfbal.BALUNIT BALUNIT,
           tbcoms.BEGINTIME,tbcoms.ENDTIME,
           tcoms.NAME, tcoms.COMSCHEMENO, tcoms.TYPECODE, tbcoms.ID,
           tfbal.CALLINGNO, cllno.calling CALLINGNAME, tfbal.CORPNO,
           corp.CORP CORPNAME, tfbal.DEPARTNO , dept.DEPART DEPARTNAME
    FROM  TF_TRADE_BALUNIT tfbal,
          TD_TBALUNIT_COMSCHEME tbcoms,
          TF_TRADE_COMSCHEME tcoms,
          TD_M_CALLINGNO cllno,
          TD_M_CORP  corp,
          TD_M_DEPART dept,
          TD_M_INSIDEDEPART TMID,
          TD_M_INSIDESTAFF TMIS,
          (select regioncode from td_m_insidedepart where departno = p_var5) m
    WHERE tfbal.BALUNITNO = tbcoms.BALUNITNO
    AND   tcoms.COMSCHEMENO = tbcoms.COMSCHEMENO
    AND   tfbal.USETAG = '1'
    AND   tbcoms.USETAG = '1'
    AND   tfbal.CALLINGNO != '01'
    AND   tfbal.CALLINGNO != '02'
    AND   tfbal.CALLINGNO = cllno.CALLINGNO(+)
    AND   tfbal.CORPNO = corp.CORPNO(+)
    AND   tfbal.DEPARTNO = dept.DEPARTNO(+)
    AND  (p_var1 is null OR tfbal.CALLINGNO = p_var1)
    AND  (p_var2 is null OR tfbal.CORPNO = p_var2)
    AND  (p_var3 is null OR tfbal.DEPARTNO = p_var3)
    AND  (p_var4 is null OR tbcoms.ENDTIME <=
            ADD_MONTHS(sysdate, p_var4))
    AND  (tfbal.Updatestaffno = TMIS.STAFFNO)
    AND (TMIS.DEPARTNO = TMID.DEPARTNO)
    AND (TMID.REGIONCODE = m.REGIONCODE or m.REGIONCODE is null)
    ;

elsif p_funcCode = 'QueryBranch' then
    open p_cursor for
    select bank, bankcode from td_m_bank
    where bankcode like substr(p_var1,-1) || '%';

elsif p_funcCode = 'QueryBalUnit' then
    if p_var5 = '0' then -- 财审通过
        open p_cursor for
        SELECT ROWNUM, '' TRADEID, b.USETAG, b.BALUNITNO, b.BALUNIT, b.CREATETIME, b.CALLINGNO, c.CALLING CALLINGNAME,
               b.CORPNO, d.CORP CORPNAME, b.DEPARTNO, e.DEPART DEPARTNAME, b.BANKCODE, f.BANK BANKNAME,
               b.BANKACCNO, b.BALLEVEL, b.FININTERVAL, b.FINBANKCODE, g.BANK FINBANK, b.LINKMAN,
               b.UNITPHONE, b.UNITADD , b.SERMANAGERCODE, h.STAFFNO || ':' || h.STAFFNAME SERMANAGER, b.BALINTERVAL,
               b.BALUNITTYPECODE, b.SOURCETYPECODE, b.BALCYCLETYPECODE, b.FINCYCLETYPECODE,
               b.FINTYPECODE, b.COMFEETAKECODE, b.REMARK, b.UNITEMAIL, b.CHANNELNO,b.bankchannelcode,
               '' COMSCHEMENO, '' BEGINTIME, '' ENDTIME,
               b.CHANNELNO || ':' || i.CHANNELNAME CHANNELNAME,b.PURPOSETYPE,
        decode(b.BALUNITTYPECODE, '00', '行业', '01', '单位', '02', '部门', '03', '行业员工',
               b.BALUNITTYPECODE) BALUNITTYPE,
        decode(b.SOURCETYPECODE, '00', 'PSAM卡号', '01', '信息亭', '02', '司机工号',
               b.SOURCETYPECODE) SOURCETYPE,
        decode(b.BALCYCLETYPECODE, '00', '小时', '01','天', '02', '周', '03', '固定月', '04', '自然月',
               b.BALCYCLETYPECODE) BALCYCLETYPE,
        decode(b.FINCYCLETYPECODE, '00', '小时', '01','天', '02', '周', '03', '固定月', '04', '自然月',
               b.FINCYCLETYPECODE) FINCYCLETYPE,
        decode(b.FINTYPECODE, '0', '财务部门转账', '1', '财务不转账',
               b.FINTYPECODE) FINTYPE,
        decode(b.COMFEETAKECODE, '0', '不在转账金额扣减', '1', '直接从转帐金额扣减',
               b.COMFEETAKECODE) COMFEETAKE,
        decode(b.PURPOSETYPE, '1', '对公', '2', '对私',
               b.PURPOSETYPE) PURPOSE,
        decode(b.bankchannelcode, '1', '跨行支付', '3', '同城支付',
               b.bankchannelcode) BANKCHANNEL,
               b.REGIONCODE, j.REGIONNAME, b.DELIVERYMODECODE, k.DELIVERYMODE, b.APPCALLINGCODE, l.APPCALLING
        FROM  TF_TRADE_BALUNIT b, TD_M_CALLINGNO c, TD_M_CORP d,
              TD_M_DEPART e, TD_M_BANK f, TD_M_BANK g, TD_M_INSIDESTAFF h, TD_M_CHANNEL i, TD_M_REGIONCODE j, TD_M_DELIVERYMODECODE k, TD_M_APPCALLINGCODE l,Td_m_Insidedepart m,TD_M_INSIDESTAFF n,
              (select regioncode from td_m_insidedepart where departno = p_var7) O
        WHERE(p_var1 is null or p_var1 = b.CALLINGNO)
        AND  (P_var2 is null or p_var2 = b.CORPNO   )
        AND  (p_var3 is null or p_var3 = b.DEPARTNO )
        AND  (p_var4 is null or p_var4 = b.BALUNITNO)
        AND  (p_var6 is null or p_var6 = b.SERMANAGERCODE)
        AND  (b.updatestaffno = n.staffno)
        AND  (n.departno = m.departno)
        AND (m.Regioncode IN (select b.regioncode from td_m_regioncode b where b.regionname =(select r.regionname from td_m_regioncode r where r.regioncode = o.REGIONCODE)) or o.REGIONCODE is null)
        AND   b.CALLINGNO      = c.CALLINGNO(+)
        AND   b.CORPNO         = d.CORPNO   (+)
        AND   b.DEPARTNO       = e.DEPARTNO (+)
        AND   b.BANKCODE       = f.BANKCODE (+)
        AND   b.FINBANKCODE    = g.BANKCODE (+)
        AND   b.SERMANAGERCODE = h.STAFFNO  (+)
        AND   b.CHANNELNO      = i.CHANNELNO(+)
        AND   b.REGIONCODE     = j.REGIONCODE(+)
        AND   b.DELIVERYMODECODE = k.DELIVERYMODECODE(+)
        AND   b.APPCALLINGCODE = l.APPCALLINGCODE(+)
        AND   ROWNUM <= 100

        ;
    elsif p_var5 in ('1', '2') then -- 财审作废或者等待财审
        open p_cursor for
        SELECT ROWNUM, b.TRADEID, '1' USETAG, b.BALUNITNO, b.BALUNIT, b.CREATETIME, b.CALLINGNO, c.CALLING CALLINGNAME,
               b.CORPNO, d.CORP CORPNAME, b.DEPARTNO, e.DEPART DEPARTNAME, b.BANKCODE, f.BANK BANKNAME,
               b.BANKACCNO, b.BALLEVEL, b.FININTERVAL, b.FINBANKCODE, g.BANK FINBANK, b.LINKMAN,
               b.UNITPHONE, b.UNITADD , b.SERMANAGERCODE, h.STAFFNO || ':' || h.STAFFNAME SERMANAGER, b.BALINTERVAL,
               b.BALUNITTYPECODE, b.SOURCETYPECODE, b.BALCYCLETYPECODE, b.FINCYCLETYPECODE,
               b.FINTYPECODE, b.COMFEETAKECODE, b.REMARK, b.UNITEMAIL, b.CHANNELNO,
               k.COMSCHEMENO, to_char(k.BEGINTIME, 'YYYY-MM') BEGINTIME, to_char(k.ENDTIME, 'YYYY-MM') ENDTIME,
               b.CHANNELNO || ':' || i.CHANNELNAME CHANNELNAME,b.PURPOSETYPE,b.bankchannelcode,
        decode(b.BALUNITTYPECODE, '00', '行业', '01', '单位', '02', '部门', '03', '行业员工',
               b.BALUNITTYPECODE) BALUNITTYPE,
        decode(b.SOURCETYPECODE, '00', 'PSAM卡号', '01', '信息亭', '02', '司机工号',
               b.SOURCETYPECODE) SOURCETYPE,
        decode(b.BALCYCLETYPECODE, '00', '小时', '01','天', '02', '周', '03', '固定月', '04', '自然月',
               b.BALCYCLETYPECODE) BALCYCLETYPE,
        decode(b.FINCYCLETYPECODE, '00', '小时', '01','天', '02', '周', '03', '固定月', '04', '自然月',
               b.FINCYCLETYPECODE) FINCYCLETYPE,
        decode(b.FINTYPECODE, '0', '财务部门转账', '1', '财务不转账',
               b.FINTYPECODE) FINTYPE,
        decode(b.COMFEETAKECODE, '0', '不在转账金额扣减', '1', '直接从转帐金额扣减',
               b.COMFEETAKECODE) COMFEETAKE,
        decode(b.PURPOSETYPE, '1', '对公', '2', '对私',
               b.PURPOSETYPE) PURPOSE,
        decode(b.bankchannelcode, '1', '跨行支付', '3', '同城支付',
               b.bankchannelcode) BANKCHANNEL,
               b.REGIONCODE, l.Regionname, b.DELIVERYMODECODE, m.DELIVERYMODE, b.APPCALLINGCODE, n.appcalling
        FROM  TF_B_TRADE_BALUNITCHANGE b, TD_M_CALLINGNO c, TD_M_CORP d,
              TD_M_DEPART e, TD_M_BANK f, TD_M_BANK g, TD_M_INSIDESTAFF h, TD_M_CHANNEL i,
              TF_B_ASSOCIATETRADE_EXAM j, TF_TBALUNIT_COMSCHEMECHANGE k, TD_M_REGIONCODE l, TD_M_DELIVERYMODECODE m, TD_M_APPCALLINGCODE n
        WHERE b.TRADEID        = j.TRADEID  AND J.STATECODE = decode(p_var5, '1', '3', '2', '1')
        AND   j.TRADEID        = k.TRADEID(+)
        AND  (p_var1 is null or p_var1 = b.CALLINGNO)
        AND  (P_var2 is null or p_var2 = b.CORPNO   )
        AND  (p_var3 is null or p_var3 = b.DEPARTNO )
        AND  (p_var4 is null or p_var4 = b.BALUNITNO)
        AND  (p_var6 is null or p_var6 = b.SERMANAGERCODE)
        AND   b.CALLINGNO      = c.CALLINGNO(+)
        AND   b.CORPNO         = d.CORPNO   (+)
        AND   b.DEPARTNO       = e.DEPARTNO (+)
        AND   b.BANKCODE       = f.BANKCODE (+)
        AND   b.FINBANKCODE    = g.BANKCODE (+)
        AND   b.SERMANAGERCODE = h.STAFFNO  (+)
        AND   b.CHANNELNO      = i.CHANNELNO(+)
        AND   b.REGIONCODE = l.REGIONCODE(+)
        AND   b.DELIVERYMODECODE = m.Deliverymodecode(+)
        AND   b.APPCALLINGCODE = n.APPCALLINGCODE (+)
        AND   ROWNUM <= 100
        ;
    elsif p_var5 in ('3', '4') then -- 等待审批或审批作废
        open p_cursor for
        SELECT ROWNUM, b.TRADEID, '1' USETAG, b.BALUNITNO, b.BALUNIT, b.CREATETIME, b.CALLINGNO, c.CALLING CALLINGNAME,
               b.CORPNO, d.CORP CORPNAME, b.DEPARTNO, e.DEPART DEPARTNAME, b.BANKCODE, f.BANK BANKNAME,
               b.BANKACCNO, b.BALLEVEL, b.FININTERVAL, b.FINBANKCODE, g.BANK FINBANK, b.LINKMAN,
               b.UNITPHONE, b.UNITADD , b.SERMANAGERCODE, h.STAFFNO || ':' || h.STAFFNAME SERMANAGER, b.BALINTERVAL,
               b.BALUNITTYPECODE, b.SOURCETYPECODE, b.BALCYCLETYPECODE, b.FINCYCLETYPECODE,
               b.FINTYPECODE, b.COMFEETAKECODE, b.REMARK, b.UNITEMAIL, b.CHANNELNO,
               k.COMSCHEMENO, to_char(k.BEGINTIME, 'YYYY-MM') BEGINTIME, to_char(k.ENDTIME, 'YYYY-MM') ENDTIME,
               b.CHANNELNO || ':' || i.CHANNELNAME CHANNELNAME,b.PURPOSETYPE,b.bankchannelcode,
        decode(b.BALUNITTYPECODE, '00', '行业', '01', '单位', '02', '部门', '03', '行业员工',
               b.BALUNITTYPECODE) BALUNITTYPE,
        decode(b.SOURCETYPECODE, '00', 'PSAM卡号', '01', '信息亭', '02', '司机工号',
               b.SOURCETYPECODE) SOURCETYPE,
        decode(b.BALCYCLETYPECODE, '00', '小时', '01','天', '02', '周', '03', '固定月', '04', '自然月',
               b.BALCYCLETYPECODE) BALCYCLETYPE,
        decode(b.FINCYCLETYPECODE, '00', '小时', '01','天', '02', '周', '03', '固定月', '04', '自然月',
               b.FINCYCLETYPECODE) FINCYCLETYPE,
        decode(b.FINTYPECODE, '0', '财务部门转账', '1', '财务不转账',
               b.FINTYPECODE) FINTYPE,
        decode(b.COMFEETAKECODE, '0', '不在转账金额扣减', '1', '直接从转帐金额扣减',
               b.COMFEETAKECODE) COMFEETAKE,
        decode(b.PURPOSETYPE, '1', '对公', '2', '对私',
               b.PURPOSETYPE) PURPOSE,
        decode(b.bankchannelcode, '1', '跨行支付', '3', '同城支付',
               b.bankchannelcode) BANKCHANNEL,
               b.REGIONCODE, l.regionname, b.DELIVERYMODECODE, m.deliverymode, b.APPCALLINGCODE, n.appcalling
        FROM  TF_B_TRADE_BALUNITCHANGE b, TD_M_CALLINGNO c, TD_M_CORP d,
              TD_M_DEPART e, TD_M_BANK f, TD_M_BANK g, TD_M_INSIDESTAFF h, TD_M_CHANNEL i,
              TF_B_ASSOCIATETRADE j, TF_TBALUNIT_COMSCHEMECHANGE k, TD_M_REGIONCODE l, TD_M_DELIVERYMODECODE m, TD_M_APPCALLINGCODE n
        WHERE b.TRADEID        = j.TRADEID  AND J.STATECODE = decode(p_var5, '3', '3', '4', '1')
        AND   j.TRADEID        = k.TRADEID(+)
        AND  (p_var1 is null or p_var1 = b.CALLINGNO)
        AND  (P_var2 is null or p_var2 = b.CORPNO   )
        AND  (p_var3 is null or p_var3 = b.DEPARTNO )
        AND  (p_var4 is null or p_var4 = b.BALUNITNO)
        AND  (p_var6 is null or p_var6 = b.SERMANAGERCODE)
        AND   b.CALLINGNO      = c.CALLINGNO(+)
        AND   b.CORPNO         = d.CORPNO   (+)
        AND   b.DEPARTNO       = e.DEPARTNO (+)
        AND   b.BANKCODE       = f.BANKCODE (+)
        AND   b.FINBANKCODE    = g.BANKCODE (+)
        AND   b.SERMANAGERCODE = h.STAFFNO  (+)
        AND   b.CHANNELNO      = i.CHANNELNO(+)
        AND   b.REGIONCODE     = l.REGIONCODE(+)
        AND   b.Deliverymodecode = m.Deliverymodecode(+)
        AND   b.Appcallingcode = n.Appcallingcode(+)
        AND   ROWNUM <= 100
        ;

    end if;

elsif p_funcCode = 'ZEROTRADEPOS' then
    open p_cursor for
    select t.BALUNITNO, t.BALUNIT, r.posno
    from TF_TRADE_BALUNIT t, TF_R_PSAMPOSREC r, (
          select posno
          from TF_R_PSAMPOSREC
          where (p_var1 is null or p_var1 = BALUNITNO)
          AND   (P_var2 is null or p_var2 = POSNO)
        minus
          select t.posno
          from tq_trade_right t
          where t.tradedate between p_var3 and p_var4
          and (p_var1 is null or p_var1 = t.BALUNITNO)
          and (P_var2 is null or p_var2 = t.POSNO)) p
    where (p_var1 is null or p_var1 = t.BALUNITNO)
    AND   (P_var2 is null or p_var2 = r.POSNO)
    and t.BALUNITNO = r.BALUNITNO
    and r.posno = p.posno
    ;

elsif p_funcCode = 'CORPDETAIL' then
        open p_cursor for
        select '' CORPNO, '' CORP, x.BALUNITNO, x.BALUNIT,b.CALLING, c.CORP CORPNAME, x.BANKACCNO, x.LINKMAN, x.UNITPHONE
            from (
              select a.BALUNITNO, a.balunit, a.corpno, a.callingno, a.BANKACCNO, a.LINKMAN, a.UNITPHONE, d.statecode
              from TF_TRADE_BALUNIT a left join TF_UNITE_BALUNIT d on (a.BALUNITNO = d.DETAILNO)
              where a.CORPNO = P_var1 and a.usetag = '1' and balunittypecode != '04') x,
              TD_M_CALLINGNO b, TD_M_CORP c
            where (x.statecode is null or x.statecode <> '1')
            and x.CORPNO = P_var1 and x.CALLINGNO = b.CALLINGNO and c.CORPNO = x.CORPNO
        ;

elsif p_funcCode = 'BALDETAIL' then
        open p_cursor for
        SELECT e.BALUNITNO CORPNO, e.BALUNIT CORP, b.CALLING, c.CORP CORPNAME, a.BALUNITNO, a.BALUNIT,  a.BANKACCNO, a.LINKMAN, a.UNITPHONE
        FROM TF_TRADE_BALUNIT a, TD_M_CALLINGNO b, TD_M_CORP c, TF_UNITE_BALUNIT d, TF_TRADE_BALUNIT e
        where b.CALLINGNO = a.CALLINGNO and c.CORPNO = a.CORPNO and a.usetag= '1' and d.statecode in ('1','3')
        and d.BALUNITNO = P_var1 and d.DETAILNO = a.BALUNITNO and e.BALUNITNO = P_var1
        ;
elsif p_funcCode = 'CHARGETYPE_DEPT' then
        open p_cursor for
        SELECT A.CHARGETYPECODE , A.CHARGETYPENAME ,B.DEPTNO, C.DEPARTNAME , D.STAFFNAME , B.UPDATETIME
        FROM TD_M_CHARGETYPE A, TD_DEPT_CHARGETYPE B ,TD_M_INSIDEDEPART C , TD_M_INSIDESTAFF D
        WHERE A.CHARGETYPECODE = B.CHARGETYPECODE
        AND   B.DEPTNO = C.DEPARTNO
        AND   B.UPDATESTAFFNO = D.STAFFNO
        AND   B.USETAG = '1'
    AND   A.USETAG = '1'
        AND  (P_VAR1 IS NULL OR P_VAR1 = '' OR B.CHARGETYPECODE = P_VAR1)
        AND  (P_VAR2 IS NULL OR P_VAR2 = '' OR B.DEPTNO = P_VAR2)
        ORDER BY B.CHARGETYPECODE
        ;
elsif p_funcCode = 'CHARGETYPE' then
        open p_cursor for
        SELECT A.CHARGETYPECODE , A.CHARGETYPENAME , A.CHARGETYPESTATE , B.STAFFNAME , A.UPDATETIME
        FROM TD_M_CHARGETYPE A , TD_M_INSIDESTAFF B
        WHERE A.UPDATESTAFFNO = B.STAFFNO
        AND   A.USETAG = '1'
        ORDER BY A.CHARGETYPECODE
        ;
elsif p_funcCode = 'TD_M_CHARGETYPE' then
        open p_cursor for
        SELECT CHARGETYPENAME,CHARGETYPECODE
        FROM TD_M_CHARGETYPE
        WHERE USETAG = '1'
        ORDER BY CHARGETYPECODE
        ;
elsif p_funcCode = 'DEPTHASCHARGETYPE' then
        open p_cursor for
        SELECT A.CHARGETYPENAME , A.CHARGETYPECODE
        FROM TD_M_CHARGETYPE A, TD_DEPT_CHARGETYPE B
        WHERE A.CHARGETYPECODE = B.CHARGETYPECODE
        AND   B.USETAG = '1'
    AND   A.USETAG = '1'
        AND  (P_VAR1 IS NULL OR P_VAR1 = '' OR B.DEPTNO = P_VAR1)
        ORDER BY A.CHARGETYPECODE
        ;
elsif 	 p_funcCode = 'QueryUnitCorpApprovalInfo' then  ---商户安全值待审核记录查询
    open p_cursor for
    select t.id,a.CORPNO,a.CORP,tcalling.CALLING,a.CORPADD,a.CORPMARK,a.linkman,a.corpphone,
           a.COMPANYPAPERTYPE,a.COMPANYPAPERNO,a.COMPANYENDTIME,a.PAPERTYPE,a.PAPERNO,nvl2(c.appcallingcode,c.appcallingcode||':'||c.appcalling,null) appcalling,t.securityvalue/100.0 securityvalue,t.registeredcapital/100.0  registeredcapital
            from TF_F_CORPSECURITYAPPROVAL t,TD_M_CORP a,TD_DEPTBAL_RELATION b,TD_M_APPCALLINGCODE c,TD_M_CALLINGNO tcalling
    WHERE  t.CORPNO=a.CORPNO
    and    a.CALLINGNO = tcalling.CALLINGNO
    and    B.DEPARTNO in (select k.departno from TD_M_INSIDESTAFF k where k.staffno=a.updatestaffno)
    and    a.appcallingno = c.appcallingcode(+)
    AND    (p_var1 IS NULL OR p_var1 = '' OR p_var1 = a.callingno)
	  AND    (p_var2 IS NULL OR p_var2 = '' OR p_var2 = a.CORPNO)
    AND    P_VAR3 = B.DBALUNITNO
    and    t.approvestate='0'
    and    t.isvalid='1'
     order by t.operatetime desc;
elsif 	 p_funcCode = 'QueryDeptCorpApprovalInfo' then  ---商户安全值待审核记录查询
    open p_cursor for
    select t.id,a.CORPNO,a.CORP,tcalling.CALLING,a.CORPADD,a.CORPMARK,a.linkman,a.corpphone,
           a.COMPANYPAPERTYPE,a.COMPANYPAPERNO,a.COMPANYENDTIME,a.PAPERTYPE,a.PAPERNO,nvl2(c.appcallingcode,c.appcallingcode||':'||c.appcalling,null) appcalling,t.securityvalue/100.0 securityvalue,t.registeredcapital/100.0  registeredcapital
            from TF_F_CORPSECURITYAPPROVAL t,TD_M_CORP a,TD_M_APPCALLINGCODE c,TD_M_CALLINGNO tcalling
    WHERE  t.CORPNO=a.CORPNO
    and    a.CALLINGNO = tcalling.CALLINGNO
    and    a.appcallingno = c.appcallingcode(+)
	  AND    (p_var1 IS NULL OR p_var1 = '' OR p_var1 = a.callingno)
	  AND    (p_var2 IS NULL OR p_var2 = '' OR p_var2 = a.CORPNO)
    AND    P_VAR3 in (select k.departno from TD_M_INSIDESTAFF k where k.staffno=a.updatestaffno)
    and    t.approvestate='0'
    and    t.isvalid='1'
     order by t.operatetime desc;
elsif 	 p_funcCode = 'QueryStaffCorpApprovalInfo' then  ---商户安全值待审核记录查询
    open p_cursor for
     select t.id,a.CORPNO,a.CORP,tcalling.CALLING,a.CORPADD,a.CORPMARK,a.linkman,a.corpphone,
           a.COMPANYPAPERTYPE,a.COMPANYPAPERNO,a.COMPANYENDTIME,a.PAPERTYPE,a.PAPERNO,nvl2(c.appcallingcode,c.appcallingcode||':'||c.appcalling,null) appcalling,t.securityvalue/100.0 securityvalue,t.registeredcapital/100.0  registeredcapital
            from TF_F_CORPSECURITYAPPROVAL t,TD_M_CORP a,TD_M_APPCALLINGCODE c,TD_M_CALLINGNO tcalling
    WHERE  t.CORPNO=a.CORPNO
    and    a.CALLINGNO = tcalling.CALLINGNO
    and    a.appcallingno = c.appcallingcode(+)
	  AND    (p_var1 IS NULL OR p_var1 = '' OR p_var1 = a.callingno)
	  AND    (p_var2 IS NULL OR p_var2 = '' OR p_var2 = a.CORPNO)
    and    t.approvestate='0'
    and    t.isvalid='1'
     order by t.operatetime desc;
end if;

end;
/

show errors
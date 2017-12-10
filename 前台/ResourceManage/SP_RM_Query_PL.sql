create or replace procedure SP_RM_Query
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
    p_var10      varchar2,
    p_var11      varchar2,
    p_cursor out SYS_REFCURSOR
)
as
	v_sql varchar2(100) := '';
begin
      if p_funcCode = 'TP_XFC_CARDVALUE' then
          open p_cursor for
          select t.VALUE,t.VALUECODE from TP_XFC_CARDVALUE t;

      elsif  p_funcCode = 'InitCardFaceAffirmWay' then -- ��ʼ������ȷ�Ϸ�ʽ add by shil
          open p_cursor for
          select CODEDESC,CODEVALUE
          from   TD_M_RMCODING
          where  TABLENAME = 'TF_F_APPLYORDER'
          and    COLNAME   = 'CARDFACEAFFIRMWAY';

      elsif  p_funcCode = 'USECARD_ORDER' then -- ��ѯ�û������õ� add by Yin
          open p_cursor for
          select t.getcardorderid ���õ���,
          m.cardtypename ��Ƭ����,
          s.cardsurfacename ��������,
          t.applygetnum ��������,
          t.useway ��;,
          t.ordertime ����ʱ��,
          st.staffname ����Ա��,
          de.departname ���벿��,
          t.getcardorderstate || ':' ||  B.CODEDESC ���״̬,
          t.remark ��ע
          from  TF_F_GETCARDORDER t
          inner join TD_M_RMCODING B on  t.getcardorderstate = B.CODEVALUE
          inner join td_m_cardtype m on t.cardtypecode = m.cardtypecode
          inner join td_m_cardsurface s on t.cardsurfacecode = s.cardsurfacecode
          inner join td_m_insidestaff st on t.ORDERSTAFFNO =  st.STAFFNO
          inner join td_m_insidedepart de on st.departno = de.departno
          where
          B.TABLENAME = 'TF_F_GETCARDORDER' and B.Colname = 'GETCARDORDERSTATE'  and
          t.getcardordertype = '01' and
          (p_var1 is null or t.getcardorderstate = p_var1)  --���״̬
          and (p_var2 is null or to_char(t.ordertime,'yyyymmdd') >= p_var2) --��ʼ����
          and (p_var3 is null or to_char(t.ordertime,'yyyymmdd') <= p_var3) --��������
          and (p_var4 is null or t.orderstaffno = p_var4)
          and (p_var5 is null or de.departno = p_var5)
          Order by t.getcardorderid desc;

       elsif  p_funcCode = 'CHARGECARD_ORDER' then -- ��ѯ��ֵ�����õ� add by Yin
          open p_cursor for
          select t.getcardorderid ���õ���,
          m.value ��ֵ����ֵ,
          t.applygetnum ��������,
          t.useway ��;,
          t.ordertime ����ʱ��,
          st.staffname ����Ա��,
          de.departname ���벿��,
          t.getcardorderstate || ':' ||  B.CODEDESC ���״̬,
          t.remark ��ע
          from  TF_F_GETCARDORDER t inner join  TD_M_RMCODING B on  t.getcardorderstate = B.CODEVALUE
          inner join TP_XFC_CARDVALUE m on m.VALUECODE = t.valuecode
          inner join td_m_insidestaff st on t.ORDERSTAFFNO =  st.STAFFNO
          inner join td_m_insidedepart de on st.departno = de.departno
          where
          B.TABLENAME = 'TF_F_GETCARDORDER' and B.Colname = 'GETCARDORDERSTATE'  and
          t.getcardordertype = '02' and
          (p_var1 is null or t.getcardorderstate = p_var1)
          and (p_var2 is null or to_char(t.ordertime,'yyyymmdd') >= p_var2)
          and (p_var3 is null or to_char(t.ordertime,'yyyymmdd') <= p_var3)
          and (p_var4 is null or t.orderstaffno = p_var4)
          and (p_var5 is null or de.departno = p_var5)
          order by t.getcardorderid	desc;

elsif  p_funcCode = 'queryCardSample' then  --���ݿ������Ͳ�ѯ�������� add by shil
    open p_cursor for
    SELECT a.CARDSAMPLECODE , b.CARDSAMPLE
    FROM   TD_M_CARDSURFACE a, TD_M_CARDSAMPLE b
    WHERE  a.CARDSAMPLECODE = b.CARDSAMPLECODE
    AND    a.CARDSURFACECODE = p_var1;

elsif  p_funcCode = 'queryCardFaceByCardType' then  --ͨ�������Ͳ�ѯ�������� add by shil
    open p_cursor for
    SELECT CARDSURFACENAME , CARDSURFACECODE
    FROM   TD_M_CARDSURFACE
    WHERE  (p_var1 is null or p_var1 = '' or substr(CARDSURFACECODE,1,2) = p_var1);

elsif  p_funcCode = 'queryApplyStock' then  --��ѯ�µ����������� add by shil
    open p_cursor for
		SELECT A.APPLYORDERID ,                                     --���󵥺�
		       A.APPLYORDERSTATE||':'||B.CODEDESC STATE,            --����״̬
		       A.CARDTYPECODE||':'||D.CARDTYPENAME CARDTYPE,        --������
		       A.CARDSURFACECODE||':'||C.CARDSURFACENAME CARDFACE,  --��������
		       A.CARDSAMPLECODE,                            --��������
		       A.CARDNUM       ,                            --��Ƭ����
		       A.REQUIREDATE   ,                            --Ҫ�󵽻�����
		       A.ORDERDEMAND   ,                            --����Ҫ��
		       A.REMARK        ,                            --��ע
		       A.ORDERTIME     ,                            --�µ�ʱ��
		       A.ORDERSTAFFNO||':'||E.STAFFNAME ORDERSTAFF, --�µ�Ա��
		       A.ALREADYORDERNUM ,                          --�Ѷ�������
		       A.LATELYDATE    ,                            --�������ʱ��
		       (A.ALREADYARRIVENUM - A.RETURNCARDNUM) NUM   --�ѵ�������
		FROM   TF_F_APPLYORDER  A ,
		       TD_M_RMCODING    B ,
		       TD_M_CARDSURFACE C ,
		       TD_M_CARDTYPE    D ,
		       TD_M_INSIDESTAFF E
		WHERE  A.APPLYORDERSTATE = B.CODEVALUE
		AND    B.COLNAME = 'APPLYORDERSTATE'
		AND    B.TABLENAME = 'TF_F_APPLYORDER'
		AND    A.CARDTYPECODE = D.CARDTYPECODE
		AND    A.CARDSURFACECODE = C.CARDSURFACECODE
		AND    A.ORDERSTAFFNO = E.STAFFNO
		AND    A.APPLYORDERTYPE = '01'
		AND   (P_VAR1 IS NULL OR P_VAR1 = '' OR P_VAR1 = A.CARDSURFACECODE)
		AND   (P_VAR2 IS NULL OR P_VAR2 = '' OR P_VAR2 = A.APPLYORDERID)
		AND   (P_VAR3 IS NULL OR P_VAR3 = '' OR TO_DATE(P_VAR3||'000000','YYYYMMDDHH24MISS') <= A.ORDERTIME)
		AND   (P_VAR4 IS NULL OR P_VAR4 = '' OR TO_DATE(P_VAR4||'235959','YYYYMMDDHH24MISS') >= A.ORDERTIME)
		AND   (P_VAR5 IS NULL OR P_VAR5 = '' OR P_VAR5 = A.APPLYORDERSTATE)
		AND    P_VAR6 = A.USETAG
		ORDER BY A.ORDERTIME DESC;

elsif  p_funcCode = 'queryApplyNew' then    --��ѯ�µ��������ƿ�Ƭ add by shil
    open p_cursor for
		SELECT A.APPLYORDERID ,                             --���󵥺�
		       A.APPLYORDERSTATE||':'||B.CODEDESC STATE,    --����״̬
		       A.CARDNAME     ,                             --��Ƭ����
		       A.CARDFACEAFFIRMWAY||':'||C.CODEDESC WAY,    --����ȷ�Ϸ�ʽ
		       A.CARDNUM       ,                            --��Ƭ����
		       A.REQUIREDATE   ,                            --Ҫ�󵽻�����
		       A.ORDERDEMAND   ,                            --����Ҫ��
		       A.REMARK        ,                            --��ע
		       A.ORDERTIME     ,                            --�µ�ʱ��
		       A.ORDERSTAFFNO||':'||E.STAFFNAME ORDERSTAFF, --�µ�Ա��
		       A.ALREADYORDERNUM ,                          --�Ѷ�������
		       A.LATELYDATE    ,                            --�������ʱ��
		       (A.ALREADYARRIVENUM - A.RETURNCARDNUM) NUM   --�ѵ�������
		FROM   TF_F_APPLYORDER  A ,
		       TD_M_RMCODING    B ,
		       TD_M_RMCODING    C ,
		       TD_M_INSIDESTAFF E
		WHERE  A.APPLYORDERSTATE = B.CODEVALUE
		AND    B.COLNAME = 'APPLYORDERSTATE'
		AND    B.TABLENAME = 'TF_F_APPLYORDER'
		AND    A.CARDFACEAFFIRMWAY = C.CODEVALUE
		AND    C.COLNAME = 'CARDFACEAFFIRMWAY'
		AND    C.TABLENAME = 'TF_F_APPLYORDER'
		AND    A.ORDERSTAFFNO = E.STAFFNO
		AND    A.APPLYORDERTYPE = '02'
		AND   (P_VAR1 IS NULL OR P_VAR1 = '' OR P_VAR1 = A.CARDNAME)
		AND   (P_VAR2 IS NULL OR P_VAR2 = '' OR P_VAR2 = A.APPLYORDERID)
		AND   (P_VAR3 IS NULL OR P_VAR3 = '' OR TO_DATE(P_VAR3||'000000','YYYYMMDDHH24MISS') <= A.ORDERTIME)
		AND   (P_VAR4 IS NULL OR P_VAR4 = '' OR TO_DATE(P_VAR4||'235959','YYYYMMDDHH24MISS') >= A.ORDERTIME)
		AND   (P_VAR5 IS NULL OR P_VAR5 = '' OR P_VAR5 = A.APPLYORDERSTATE)
		AND    P_VAR6 = A.USETAG
		ORDER BY A.ORDERTIME DESC;

elsif  p_funcCode = 'queryApplyChargeCard' then  --��ѯ�µ������ֵ�� add by shil
    open p_cursor for
		SELECT A.APPLYORDERID ,                             --���󵥺�
		       A.APPLYORDERSTATE||':'||B.CODEDESC STATE,    --����״̬
		       A.VALUECODE||':'||C.VALUE VALUECODE,         --��ֵ����ֵ
		       A.CARDNUM       ,                            --��Ƭ����
		       A.REQUIREDATE   ,                            --Ҫ�󵽻�����
		       A.ORDERDEMAND   ,                            --����Ҫ��
		       A.REMARK        ,                            --��ע
		       A.ORDERTIME     ,                            --�µ�ʱ��
		       A.ORDERSTAFFNO||':'||E.STAFFNAME ORDERSTAFF, --�µ�Ա��
		       A.ALREADYORDERNUM ,                          --�Ѷ�������
		       A.LATELYDATE    ,                            --�������ʱ��
		       (A.ALREADYARRIVENUM - A.RETURNCARDNUM) NUM   --�ѵ�������
		FROM   TF_F_APPLYORDER  A ,
		       TD_M_RMCODING    B ,
		       TP_XFC_CARDVALUE C ,
		       TD_M_INSIDESTAFF E
		WHERE  A.APPLYORDERSTATE = B.CODEVALUE
		AND    B.COLNAME = 'APPLYORDERSTATE'
		AND    B.TABLENAME = 'TF_F_APPLYORDER'
		AND    A.VALUECODE = C.VALUECODE
		AND    A.ORDERSTAFFNO = E.STAFFNO
		AND    A.APPLYORDERTYPE = '03'
		AND   (P_VAR1 IS NULL OR P_VAR1 = '' OR P_VAR1 = A.VALUECODE)
		AND   (P_VAR2 IS NULL OR P_VAR2 = '' OR P_VAR2 = A.APPLYORDERID)
		AND   (P_VAR3 IS NULL OR P_VAR3 = '' OR TO_DATE(P_VAR3||'000000','YYYYMMDDHH24MISS') <= A.ORDERTIME)
		AND   (P_VAR4 IS NULL OR P_VAR4 = '' OR TO_DATE(P_VAR4||'235959','YYYYMMDDHH24MISS') >= A.ORDERTIME)
		AND   (P_VAR5 IS NULL OR P_VAR5 = '' OR P_VAR5 = A.APPLYORDERSTATE)
		AND    P_VAR6 = A.USETAG
		ORDER BY A.ORDERTIME DESC;

elsif  p_funcCode = 'queryCardFaceAffirmAppleyOrder' then  --��ѯ������ȷ�ϵ����� add by shil
    open p_cursor for
		SELECT A.APPLYORDERID ,                             --���󵥺�
		       A.CARDNAME     ,                             --��Ƭ����
		       A.CARDFACEAFFIRMWAY||':'||B.CODEDESC WAY,    --����ȷ�Ϸ�ʽ
		       A.CARDNUM       ,                            --��Ƭ����
		       A.REQUIREDATE   ,                            --Ҫ�󵽻�����
		       A.ORDERDEMAND   ,                            --����Ҫ��
		       A.ORDERTIME     ,                            --�µ�ʱ��
		       A.ORDERSTAFFNO||':'||C.STAFFNAME ORDERSTAFF, --�µ�Ա��
		       A.REMARK                                     --��ע
		FROM   TF_F_APPLYORDER  A ,
		       TD_M_RMCODING    B ,
		       TD_M_INSIDESTAFF C
		WHERE  A.CARDFACEAFFIRMWAY = B.CODEVALUE
		AND    B.COLNAME = 'CARDFACEAFFIRMWAY'
		AND    B.TABLENAME = 'TF_F_APPLYORDER'
		AND    A.ORDERSTAFFNO = C.STAFFNO
		AND    A.APPLYORDERTYPE = '02'
		AND    A.APPLYORDERSTATE = '0'
		AND    A.CARDSAMPLECODE IS NULL
		AND    A.USETAG = '1'
		ORDER BY A.ORDERTIME DESC;

elsif  p_funcCode = 'queryUseCardApplyOrder' then  --��ѯ�û������� add by shil
    open p_cursor for
		SELECT A.APPLYORDERID ,                                     --���󵥺�
		       A.APPLYORDERTYPE||':'||B.CODEDESC ORDERTYPE  ,       --��������
		       A.CARDTYPECODE||':'||D.CARDTYPENAME CARDTYPE ,       --������
		       A.CARDSURFACECODE||':'||C.CARDSURFACENAME CARDFACE,  --��������
		       A.CARDSAMPLECODE,                            --��������
		       A.CARDNAME      ,                            --��Ƭ����
		       A.CARDFACEAFFIRMWAY||':'||F.CODEDESC WAY ,   --����ȷ�Ϸ�ʽ
		       A.CARDNUM       ,                            --��Ƭ����
		       A.REQUIREDATE   ,                            --Ҫ�󵽻�����
		       A.ORDERDEMAND   ,                            --����Ҫ��
		       A.REMARK        ,                            --��ע
		       A.ORDERTIME     ,                            --�µ�ʱ��
		       A.ORDERSTAFFNO||':'||E.STAFFNAME ORDERSTAFF ,--�µ�Ա��
		       A.ALREADYORDERNUM                            --�Ѷ�������
		FROM   TF_F_APPLYORDER  A ,
		       TD_M_RMCODING    B ,
		       TD_M_CARDSURFACE C ,
		       TD_M_CARDTYPE    D ,
		       TD_M_INSIDESTAFF E ,
          (SELECT CODEVALUE,CODEDESC
           FROM  TD_M_RMCODING
           WHERE COLNAME = 'CARDFACEAFFIRMWAY'
           AND TABLENAME = 'TF_F_APPLYORDER') F
		WHERE  A.APPLYORDERTYPE = B.CODEVALUE
		AND    B.COLNAME = 'APPLYORDERTYPE'
		AND    B.TABLENAME = 'TF_F_APPLYORDER'
		AND    A.CARDFACEAFFIRMWAY = F.CODEVALUE(+)
		AND    A.CARDTYPECODE = D.CARDTYPECODE(+)
		AND    A.CARDSURFACECODE = C.CARDSURFACECODE(+)
		AND    A.ORDERSTAFFNO = E.STAFFNO
		AND    A.APPLYORDERTYPE IN ('01','02')
		AND    A.APPLYORDERSTATE IN ('0','1')
		AND    A.USETAG = '1'
		AND   (P_VAR1 IS NULL OR P_VAR1 = '' OR P_VAR1 = A.APPLYORDERID)
		AND   (P_VAR2 IS NULL OR P_VAR2 = '' OR TO_DATE(P_VAR2||'000000','YYYYMMDDHH24MISS') <= A.ORDERTIME)
		AND   (P_VAR3 IS NULL OR P_VAR3 = '' OR TO_DATE(P_VAR3||'235959','YYYYMMDDHH24MISS') >= A.ORDERTIME)
		ORDER BY A.ORDERTIME DESC;

elsif  p_funcCode = 'queryChargeCardApplyOrder' then  --��ѯ��ֵ�������� add by shil
    open p_cursor for
		SELECT A.APPLYORDERID ,                             --���󵥺�
		       A.VALUECODE||':'||C.VALUE VALUECODE ,        --��ֵ����ֵ
		       A.CARDNUM       ,                            --��Ƭ����
		       A.REQUIREDATE   ,                            --Ҫ�󵽻�����
		       A.ORDERDEMAND   ,                            --����Ҫ��
		       A.REMARK        ,                            --��ע
		       A.ORDERTIME     ,                            --�µ�ʱ��
		       A.ORDERSTAFFNO||':'||E.STAFFNAME ORDERSTAFF ,--�µ�Ա��
		       A.ALREADYORDERNUM                            --�Ѷ�������
		FROM   TF_F_APPLYORDER  A ,
		       TP_XFC_CARDVALUE C ,
		       TD_M_INSIDESTAFF E
		WHERE  A.VALUECODE = C.VALUECODE
		AND    A.ORDERSTAFFNO = E.STAFFNO
		AND    A.APPLYORDERTYPE = '03'
		AND    A.APPLYORDERSTATE IN ('0','1')
		AND    A.USETAG = '1'
		AND   (P_VAR1 IS NULL OR P_VAR1 = '' OR P_VAR1 = A.APPLYORDERID)
		AND   (P_VAR2 IS NULL OR P_VAR2 = '' OR TO_DATE(P_VAR2||'000000','YYYYMMDDHH24MISS') <= A.ORDERTIME)
		AND   (P_VAR3 IS NULL OR P_VAR3 = '' OR TO_DATE(P_VAR3||'235959','YYYYMMDDHH24MISS') >= A.ORDERTIME)
		ORDER BY A.ORDERTIME DESC;

elsif  p_funcCode = 'queryMaxCardNo' then  --��ȡ��ֵ���˻�������ر�����Ӧ��ݣ����ң���ֵ��Ӧ����󿨺� add by hzl
    open p_cursor for
    
    select Max(a.cardno) from (select  Max(t.xfcardno) cardno from TD_XFC_INITCARD t
    where t.YEAR =P_VAR2 and t.CORPCODE = P_VAR1
    and t.valuecode = P_VAR3 
    union all Select  Max(b.cardno) cardno from TD_M_CHARGECARDNO_EXCLUDE b where substr(b.cardno,0,2) = P_VAR2 
    and substr(b.cardno,6,1) =P_VAR1 
    and substr(b.cardno,5,1) = P_VAR3) a;
	
elsif  p_funcCode = 'queryCompanyNo' then  --��ѯ���ұ�� add by hzl
    open p_cursor for 
    Select a.NEW_PASSWD From TD_XFC_INITCARD a Where a.XFCARDNO = P_VAR1;
    
elsif  p_funcCode = 'queryCardValueNum' then  --��ѯ�쿨����ѡ����������  add by hzl
    open p_cursor for 
    select count(a.XFCARDNO) total from TD_XFC_INITCARD a  where a.CARDSTATECODE = '2' and a.VALUECODE = P_VAR1;

elsif  p_funcCode = 'queryCardValueLeftNum' then  --��ѯ�쿨��˿������  add by hzl
    open p_cursor for 
    select b.VALUE,count(a.XFCARDNO) total from TD_XFC_INITCARD a ,TP_XFC_CARDVALUE b 
    where a.CARDSTATECODE = '2' and a.VALUECODE = b.VALUECODE(+) and a.VALUECODE in P_VAR1 group by b.VALUE; 
    
elsif  p_funcCode = 'queryUseCardOrder' then  --��ѯ������û��������� add by shil
    open p_cursor for
		SELECT A.CARDORDERID      ,                                  --��������
		       A.APPLYORDERID     ,                                  --���󵥺�
		       A.CARDORDERTYPE||':'||B.CODEDESC     CARDORDERTYPE ,  --��������
		       A.CARDTYPECODE||':'||D.CARDTYPENAME       CARDTYPE ,  --��Ƭ����
		       A.CARDSURFACECODE||':'||C.CARDSURFACENAME CARDFACE ,  --��������
		       A.CARDSAMPLECODE   ,                                  --��������
		       A.CARDNUM          ,                                  --��Ƭ����
		       A.REQUIREDATE      ,                                  --Ҫ�󵽻�����
		       A.BEGINCARDNO      ,                                  --��ʼ����
		       A.ENDCARDNO        ,                                  --��������
		       A.CARDCHIPTYPECODE||':'||F.CARDCHIPTYPENAME CARDCHIP, --��оƬ
		       A.COSTYPECODE||':'||E.COSTYPE     COSTYPE  ,          --COS����
		       A.MANUTYPECODE||':'||G.MANUNAME   MANUNAME ,          --��Ƭ����
		       A.APPVERNO         ,                          --Ӧ�ð汾��
		       A.VALIDBEGINDATE   ,                          --��ʼ��Ч����
		       A.VALIDENDDATE     ,                          --������Ч����
		       A.ORDERTIME        ,                          --�µ�ʱ��
		       A.ORDERSTAFFNO||':'||H.STAFFNAME  ORDERSTAFF ,--�µ�Ա��
		       A.EXAMTIME         ,                          --���ʱ��
		       A.EXAMSTAFFNO||':'||I.STAFFNAME   EXAMSTAFF , --���Ա��
		       A.REMARK           ,                          --��ע
		       A.CARDORDERSTATE||':'||J.CODEDESC STATE       --���״̬
		FROM   TF_F_CARDORDER    A ,
		       TD_M_RMCODING     B ,
		       TD_M_CARDSURFACE  C ,
		       TD_M_CARDTYPE     D ,
		       TD_M_COSTYPE      E , --COS���ͱ����
		       TD_M_CARDCHIPTYPE F , --оƬ���ͱ����
		       TD_M_MANU         G , --��Ƭ���̱����
		       TD_M_INSIDESTAFF  H ,
		       TD_M_INSIDESTAFF  I ,
		       TD_M_RMCODING     J
		WHERE  A.CARDORDERTYPE = B.CODEVALUE
		AND    B.COLNAME = 'CARDORDERTYPE'
		AND    B.TABLENAME = 'TF_F_CARDORDER'
		AND    A.CARDORDERSTATE = J.CODEVALUE
		AND    J.COLNAME = 'CARDORDERSTATE'
		AND    J.TABLENAME = 'TF_F_CARDORDER'
		AND    A.CARDSURFACECODE = C.CARDSURFACECODE(+)
		AND    A.CARDTYPECODE = D.CARDTYPECODE(+)
		AND    A.COSTYPECODE = E.COSTYPECODE(+)
		AND    A.CARDCHIPTYPECODE = F.CARDCHIPTYPECODE(+)
		AND    A.MANUTYPECODE = G.MANUCODE(+)
		AND    A.ORDERSTAFFNO = H.STAFFNO(+)
		AND    A.EXAMSTAFFNO = I.STAFFNO(+)
		AND    A.CARDORDERTYPE IN ('01','02')
		AND    A.USETAG = '1'
		AND   (P_VAR1 IS NULL OR P_VAR1 = '' OR P_VAR1 = A.CARDORDERID )
		AND   (P_VAR2 IS NULL OR P_VAR2 = '' OR P_VAR2 = A.CARDORDERSTATE)
		ORDER BY A.ORDERTIME DESC;

elsif  p_funcCode = 'queryChargeCardOrder' then  --��ѯ����˳�ֵ���������� add by shil
    open p_cursor for
		SELECT A.CARDORDERID      ,                          --��������
		       A.APPLYORDERID     ,                          --���󵥺�
		       A.VALUECODE||':'||B.VALUE VALUECODE ,         --��ֵ����ֵ
		       A.CARDNUM          ,                          --��Ƭ����
		       A.REQUIREDATE      ,                          --Ҫ�󵽻�����
		       A.BEGINCARDNO      ,                          --��ʼ����
		       A.ENDCARDNO        ,                          --��������
		       A.ORDERTIME        ,                          --�µ�ʱ��
		       A.ORDERSTAFFNO||':'||C.STAFFNAME ORDERSTAFF , --�µ�Ա��
		       A.EXAMTIME         ,                          --���ʱ��
		       A.EXAMSTAFFNO||':'||D.STAFFNAME  EXAMSTAFF  , --���Ա��
		       A.REMARK           ,                          --��ע
		       A.CARDORDERSTATE||':'||E.CODEDESC STATE     , --���״̬
           A.VALIDENDDATE     ,                          --��Ч��
           F.CORPNAME                                    --��Ƭ����
		FROM   TF_F_CARDORDER    A ,
		       TP_XFC_CARDVALUE  B ,
		       TD_M_INSIDESTAFF  C ,
		       TD_M_INSIDESTAFF  D ,
		       TD_M_RMCODING     E ,
           TP_XFC_CORP       F
		WHERE  A.VALUECODE = B.VALUECODE(+)
		AND    A.ORDERSTAFFNO = C.STAFFNO(+)
		AND    A.EXAMSTAFFNO = D.STAFFNO(+)
    AND    A.MANUTYPECODE = F.CORPCODE(+)
		AND    A.CARDORDERSTATE = E.CODEVALUE
		AND    E.COLNAME = 'CARDORDERSTATE'
		AND    E.TABLENAME = 'TF_F_CARDORDER'
		AND    A.CARDORDERTYPE = '03'
		AND    A.USETAG = '1'
		AND   (P_VAR1 IS NULL OR P_VAR1 = '' OR P_VAR1 = A.CARDORDERID )
		AND   (P_VAR2 IS NULL OR P_VAR2 = '' OR P_VAR2 = A.CARDORDERSTATE)
		ORDER BY A.ORDERTIME DESC;

elsif  p_funcCode = 'UseCardOrderQuery' then  --�û�����������ѯ add by shil
	IF P_VAR3 IS NOT NULL THEN
		V_SQL := V_SQL||'AND  A.CARDORDERSTATE IN('||P_VAR3||')';
	END IF;
    DBMS_OUTPUT.PUT_LINE(V_SQL);
	open p_cursor for
		'SELECT A.CARDORDERID      ,                                  --��������
		       A.CARDORDERTYPE||'':''||B.CODEDESC  ORDERTYPE  ,       --��������
		       A.APPLYORDERID     ,                                   --���󵥺�
		       A.CARDTYPECODE||'':''||D.CARDTYPENAME    CARDTYPE ,    --��Ƭ����
		       A.CARDSURFACECODE||'':''||C.CARDSURFACENAME CARDFACE , --��������
		       A.CARDSAMPLECODE,                                    --��������
		       A.CARDNAME         ,                                 --��Ƭ����
		       A.CARDFACEAFFIRMWAY||'':''||J.CODEDESC  WAY,         --����ȷ�Ϸ�ʽ
		       A.CARDNUM          ,                                 --��Ƭ����
		       A.REQUIREDATE      ,                                 --Ҫ�󵽻�����
		       A.LATELYDATE       ,                                 --�����������
		       A.ALREADYARRIVENUM ,                                 --�ѵ�������
		       A.RETURNCARDNUM    ,                                 --�˻�����
		       A.BEGINCARDNO      ,                                 --��ʼ����
		       A.ENDCARDNO        ,                                 --��������
		       A.CARDCHIPTYPECODE||'':''||F.CARDCHIPTYPENAME CARDCHIP,--��оƬ
		       A.COSTYPECODE||'':''||E.COSTYPE      COSTYPE,          --COS����
		       A.MANUTYPECODE||'':''||G.MANUNAME    MANUNAME,         --��Ƭ����
		       A.APPVERNO         ,                          --Ӧ�ð汾��
		       A.VALIDBEGINDATE   ,                          --��ʼ��Ч����
		       A.VALIDENDDATE     ,                          --������Ч����
		       A.ORDERTIME        ,                          --�µ�ʱ��
		       A.ORDERSTAFFNO||'':''||H.STAFFNAME  ORDERSTAFF, --�µ�Ա��
		       A.EXAMTIME         ,                          --���ʱ��
		       A.EXAMSTAFFNO||'':''||I.STAFFNAME   EXAMSTAFF,  --���Ա��
		       A.REMARK           ,                          --��ע
		       A.CARDORDERSTATE||'':''||K.CODEDESC  STATE      --���״̬
		FROM   TF_F_CARDORDER    A ,
		       TD_M_RMCODING     B ,
		       TD_M_CARDSURFACE  C ,
		       TD_M_CARDTYPE     D ,
		       TD_M_COSTYPE      E , --COS���ͱ����
		       TD_M_CARDCHIPTYPE F , --оƬ���ͱ����
		       TD_M_MANU         G , --��Ƭ���̱����
		       TD_M_INSIDESTAFF  H ,
		       TD_M_INSIDESTAFF  I ,
		       (SELECT CODEVALUE,CODEDESC
           FROM  TD_M_RMCODING
           WHERE COLNAME = ''CARDFACEAFFIRMWAY''
           AND TABLENAME = ''TF_F_APPLYORDER'') J ,
		       TD_M_RMCODING     K
		WHERE  A.CARDORDERTYPE = B.CODEVALUE
		AND    B.COLNAME = ''CARDORDERTYPE''
		AND    B.TABLENAME = ''TF_F_CARDORDER''
		AND    A.CARDFACEAFFIRMWAY = J.CODEVALUE(+)
		AND    A.CARDORDERSTATE = K.CODEVALUE
		AND    K.COLNAME = ''CARDORDERSTATE''
		AND    K.TABLENAME = ''TF_F_CARDORDER''
		AND    A.CARDSURFACECODE = C.CARDSURFACECODE(+)
		AND    A.CARDTYPECODE = D.CARDTYPECODE(+)
		AND    A.COSTYPECODE = E.COSTYPECODE(+)
		AND    A.CARDCHIPTYPECODE = F.CARDCHIPTYPECODE(+)
		AND    A.MANUTYPECODE = G.MANUCODE(+)
		AND    A.ORDERSTAFFNO = H.STAFFNO(+)
		AND    A.EXAMSTAFFNO = I.STAFFNO(+)
		AND    A.CARDORDERTYPE IN (''01'',''02'')
		AND    A.USETAG = ''1''
		AND   ('''||P_VAR1||''' IS NULL OR '''||P_VAR1||''' = '''' OR TO_DATE('''||P_VAR1||'000000'',''YYYYMMDDHH24MISS'') <= A.ORDERTIME)
		AND   ('''||P_VAR2||''' IS NULL OR '''||P_VAR2||''' = '''' OR TO_DATE('''||P_VAR2||'235959'',''YYYYMMDDHH24MISS'') >= A.ORDERTIME)
		AND   ('''||P_VAR4||''' IS NULL OR '''||P_VAR4||''' = '''' OR '''||P_VAR4||''' = A.CARDORDERID)
		AND   ('''||P_VAR5||''' IS NULL OR '''||P_VAR5||''' = '''' OR '''||P_VAR5||''' = A.APPLYORDERID)
		AND   ('''||P_VAR6||''' IS NULL OR '''||P_VAR6||''' = '''' OR '''||P_VAR6||''' = A.CARDSURFACECODE)
		'||v_sql||'
		ORDER BY A.ORDERTIME DESC';
elsif  p_funcCode = 'ChargeCardOrderQuery' then  --��ֵ������������ѯ add by shil
	IF P_VAR3 IS NOT NULL THEN
		V_SQL := V_SQL||'AND  A.CARDORDERSTATE IN('||P_VAR3||')';
	END IF;
	DBMS_OUTPUT.PUT_LINE(V_SQL);
    open p_cursor for
		'SELECT A.CARDORDERID      ,                      --��������
		       A.APPLYORDERID     ,                      --���󵥺�
		       A.VALUECODE||'':''||B.VALUE CARDVALUE ,     --��ֵ����ֵ
		       A.CARDNUM          ,                      --��Ƭ����
		       A.REQUIREDATE      ,                      --Ҫ�󵽻�����
		       A.LATELYDATE       ,                      --�����������
		       A.ALREADYARRIVENUM ,                      --�ѵ�������
		       A.RETURNCARDNUM    ,                      --�˻�����
		       A.BEGINCARDNO      ,                      --��ʼ����
		       A.ENDCARDNO        ,                      --��������
		       A.ORDERTIME        ,                      --�µ�ʱ��
		       A.ORDERSTAFFNO||'':''||C.STAFFNAME ORDERSTAFF,  --�µ�Ա��
		       A.EXAMTIME         ,                          --���ʱ��
		       A.EXAMSTAFFNO||'':''||D.STAFFNAME EXAMSTAFF ,   --���Ա��
		       A.REMARK           ,                          --��ע
		       A.CARDORDERSTATE||'':''||E.CODEDESC  STATE      --���״̬
		FROM   TF_F_CARDORDER    A ,
		       TP_XFC_CARDVALUE  B ,
		       TD_M_INSIDESTAFF  C ,
		       TD_M_INSIDESTAFF  D ,
		       TD_M_RMCODING     E
		WHERE  A.VALUECODE = B.VALUECODE(+)
		AND    A.CARDORDERSTATE = E.CODEVALUE
		AND    E.COLNAME = ''CARDORDERSTATE''
		AND    E.TABLENAME = ''TF_F_CARDORDER''
		AND    A.ORDERSTAFFNO = C.STAFFNO(+)
		AND    A.EXAMSTAFFNO = D.STAFFNO(+)
		AND    A.CARDORDERTYPE = ''03''
		AND    A.USETAG = ''1''
		AND   ('''||P_VAR1||''' IS NULL OR '''||P_VAR1||''' = '''' OR TO_DATE('''||P_VAR1||'000000'',''YYYYMMDDHH24MISS'') <= A.ORDERTIME)
		AND   ('''||P_VAR2||''' IS NULL OR '''||P_VAR2||''' = '''' OR TO_DATE('''||P_VAR2||'235959'',''YYYYMMDDHH24MISS'') >= A.ORDERTIME)
		AND   ('''||P_VAR4||''' IS NULL OR '''||P_VAR4||''' = '''' OR '''||P_VAR4||''' = A.CARDORDERID)
		AND   ('''||P_VAR5||''' IS NULL OR '''||P_VAR5||''' = '''' OR '''||P_VAR5||''' = A.APPLYORDERID)
		'||v_sql||'
		ORDER BY A.ORDERTIME DESC';

elsif  p_funcCode = 'QuerySignInUseCardSORDER' then  --��ѯǩ����⿨���������� add by shil
    open p_cursor for
		SELECT A.CARDORDERID      ,                                --��������
		       A.CARDORDERTYPE||':'||B.CODEDESC ORDERTYPE,         --��������
		       A.CARDTYPECODE||':'||D.CARDTYPENAME CARDTYPE,       --��Ƭ����
		       A.CARDSURFACECODE||':'||C.CARDSURFACENAME CARDFACE, --��������
		       A.CARDNAME         ,                          --��Ƭ����
		       A.CARDNUM          ,                          --��������
		       A.BEGINCARDNO      ,                          --��ʼ����
		       A.ENDCARDNO        ,                          --��������
		       A.REQUIREDATE      ,                          --Ҫ�󵽻�����
		       A.LATELYDATE       ,                          --�����������
		       A.ALREADYARRIVENUM ,                          --�ѵ�������
		       A.RETURNCARDNUM    ,                          --�˻�����
		       A.MANUTYPECODE||':'||E.MANUNAME MANUNAME  ,   --��Ƭ����
		       A.ORDERTIME        ,                          --�µ�ʱ��
		       A.ORDERSTAFFNO||':'||F.STAFFNAME  STAFF  ,    --�µ�Ա��
		       A.REMARK                                      --��ע
		FROM   TF_F_CARDORDER    A ,
		       TD_M_RMCODING     B ,
		       TD_M_CARDSURFACE  C ,
		       TD_M_CARDTYPE     D ,
		       TD_M_MANU         E , --��Ƭ���̱����
		       TD_M_INSIDESTAFF  F
		WHERE  A.CARDORDERTYPE = B.CODEVALUE
		AND    B.COLNAME = 'CARDORDERTYPE'
		AND    B.TABLENAME = 'TF_F_CARDORDER'
		AND    A.CARDORDERSTATE IN ('1','3','4') --1���ͨ����3���ֵ�����4ȫ������
		AND    A.CARDSURFACECODE = C.CARDSURFACECODE
		AND    A.CARDTYPECODE = D.CARDTYPECODE
		AND    A.MANUTYPECODE = E.MANUCODE
		AND    A.ORDERSTAFFNO = F.STAFFNO
		AND    P_VAR1 = APPLYORDERID
		ORDER BY A.CARDORDERID DESC;

elsif  p_funcCode = 'QuerySignInChargeCardSORDER' then  --��ѯǩ����⿨���������� add by shil
    open p_cursor for
		SELECT A.CARDORDERID      ,                      --��������
		       A.VALUECODE||':'||B.VALUE CARDVALUE,      --��ֵ����ֵ
		       A.CARDNUM          ,                      --��������
		       A.BEGINCARDNO      ,                      --��ʼ����
		       A.ENDCARDNO        ,                      --��������
		       A.REQUIREDATE      ,                      --Ҫ�󵽻�����
		       A.LATELYDATE       ,                      --�����������
		       A.ALREADYARRIVENUM ,                      --�ѵ�������
		       A.RETURNCARDNUM    ,                      --�˻�����
		       A.ORDERTIME        ,                      --�µ�ʱ��
		       A.ORDERSTAFFNO||':'||C.STAFFNAME STAFF,   --�µ�Ա��
		       A.REMARK                                  --��ע
		FROM   TF_F_CARDORDER    A ,
		       TP_XFC_CARDVALUE  B ,
		       TD_M_INSIDESTAFF  C
		WHERE  A.VALUECODE = B.VALUECODE
		AND    A.ORDERSTAFFNO = C.STAFFNO
		AND    A.CARDORDERSTATE IN ('1','3','4') --1���ͨ����3���ֵ�����4ȫ������
		AND    P_VAR1 = APPLYORDERID
		ORDER BY A.CARDORDERID DESC;

elsif  p_funcCode = 'QuerySignInUseCardSApplyORDER' then  --��ѯǩ������û����������� add by shil
    open p_cursor for
    SELECT A.APPLYORDERID ,                                     --���󵥺�
		       A.APPLYORDERTYPE||':'||B.CODEDESC ORDERTYPE  ,       --��������
		       A.CARDTYPECODE||':'||D.CARDTYPENAME CARDTYPE,        --������
		       A.CARDSURFACECODE||':'||C.CARDSURFACENAME CARDFACE,  --��������
		       A.CARDNAME      ,                            --��Ƭ����
		       A.CARDNUM       ,                            --�µ�����
		       A.REQUIREDATE   ,                            --Ҫ�󵽻�����
		       A.REMARK        ,                            --��ע
		       A.ORDERTIME     ,                            --�µ�ʱ��
		       A.ORDERSTAFFNO||':'||E.STAFFNAME ORDERSTAFF, --�µ�Ա��
		       A.LATELYDATE    ,                            --�����������
		       A.ALREADYARRIVENUM  ,                        --�ѵ�������
		       A.RETURNCARDNUM                              --�˻�����
		FROM   TF_F_APPLYORDER  A ,
		       TD_M_RMCODING    B ,
		       TD_M_CARDSURFACE C ,
		       TD_M_CARDTYPE    D ,
		       TD_M_INSIDESTAFF E
		WHERE  A.APPLYORDERTYPE = B.CODEVALUE
		AND    B.COLNAME = 'APPLYORDERTYPE'
		AND    B.TABLENAME = 'TF_F_APPLYORDER'
		AND    A.CARDTYPECODE = D.CARDTYPECODE(+)
		AND    A.CARDSURFACECODE = C.CARDSURFACECODE(+)
		AND    A.ORDERSTAFFNO = E.STAFFNO
		AND    A.APPLYORDERID = P_VAR1;

elsif  p_funcCode = 'QuerySignInChargeCardSApplyORDER' then		--��ѯǩ������ֵ���������� add by shil
    open p_cursor for
		SELECT A.APPLYORDERID ,                             --���󵥺�
		       A.APPLYORDERTYPE||':'||B.CODEDESC ORDERTYPE ,--��������
		       A.VALUECODE||':'||C.VALUE VALUECODE,         --��ֵ����ֵ
		       A.CARDNUM       ,                            --�µ�����
		       A.REQUIREDATE   ,                            --Ҫ�󵽻�����
		       A.REMARK        ,                            --��ע
		       A.ORDERTIME     ,                            --�µ�ʱ��
		       A.ORDERSTAFFNO||':'||E.STAFFNAME ORDERSTAFF, --�µ�Ա��
		       A.LATELYDATE    ,                            --�������ʱ��
		       A.ALREADYARRIVENUM  ,                        --�ѵ�������
		       A.RETURNCARDNUM                              --�˻�����
		FROM   TF_F_APPLYORDER  A ,
		       TD_M_RMCODING    B ,
		       TP_XFC_CARDVALUE C ,
		       TD_M_INSIDESTAFF E
		WHERE  A.APPLYORDERTYPE = B.CODEVALUE
		AND    B.COLNAME = 'APPLYORDERTYPE'
		AND    B.TABLENAME = 'TF_F_APPLYORDER'
		AND    A.VALUECODE = C.VALUECODE
		AND    A.ORDERSTAFFNO = E.STAFFNO
		AND    A.APPLYORDERID = P_VAR1;

elsif  p_funcCode = 'STOCK_USECARD' then -- ��ѯ�û������
		IF p_var3 = '01' THEN
			open p_cursor for
			select '01' ��Ƭ״̬,��Ƭ����,��������, sum(�������) �������,sum(��������) ��������, sum(��������) ��������,��������
			FROM (
			select b.cardtypecode ||':'|| b.cardtypename ��Ƭ����,
				T.cardsurfacecode ||':'|| T.cardsurfacename ��������,
				T.total �������,0 ��������,0 ��������,T.CARDSAMPLECODE ��������
				from
				(
				SELECT c.cardsurfacecode,
				c.cardsurfacename,
				substr(c.cardsurfacecode,1,2) cardtypecode,
				c.CARDSAMPLECODE,
				count(a.cardno) total
				 FROM TD_M_CARDSURFACE c,
				 (select * from TL_R_ICUSER where
					 RESSTATECODE = '00') a --���
				  where c.cardsurfacecode = a.cardsurfacecode(+)
				  and c.cardsurfacecode not in(SELECT CARDSURFACECODE FROM TD_M_USECARDWARNCONFIG)
				  group by c.cardsurfacecode,c.cardsurfacename,a.cardtypecode,c.CARDSAMPLECODE
				 ) T ,TD_M_CARDTYPE b
				 where T.cardtypecode = b.cardtypecode
					and (p_var1 = '' or p_var1 is null or b.cardtypecode = p_var1)
					and (p_var2 = '' or p_var2 is null or T.CARDSURFACECODE = p_var2)
			union
			select b.cardtypecode ||':'|| b.cardtypename ��Ƭ����,
				T.cardsurfacecode ||':'|| T.cardsurfacename ��������,
				0 �������,T.total ��������,0 ��������,T.CARDSAMPLECODE ��������
				from
				(
				SELECT c.cardsurfacecode,
				c.cardsurfacename,
				substr(c.cardsurfacecode,1,2) cardtypecode,
				c.CARDSAMPLECODE,
				count(a.cardno) total
				 FROM TD_M_CARDSURFACE c,
				 (select * from TL_R_ICUSER where
					 RESSTATECODE in ('01','02')) a --����;����
				  where c.cardsurfacecode = a.cardsurfacecode(+)
				  and c.cardsurfacecode not in(SELECT CARDSURFACECODE FROM TD_M_USECARDWARNCONFIG)
				  group by c.cardsurfacecode,c.cardsurfacename,a.cardtypecode,c.CARDSAMPLECODE
				 ) T ,TD_M_CARDTYPE b
				 where T.cardtypecode = b.cardtypecode
					and (p_var1 = '' or p_var1 is null or b.cardtypecode = p_var1)
					and (p_var2 = '' or p_var2 is null or T.CARDSURFACECODE = p_var2)
      union
      select b.cardtypecode ||':'|| b.cardtypename ��Ƭ����,
				T.cardsurfacecode ||':'|| T.cardsurfacename ��������,
				0 �������,0 ��������,T.total ��������,T.CARDSAMPLECODE ��������
				from
				(
				SELECT c.cardsurfacecode,
				c.cardsurfacename,
				substr(c.cardsurfacecode,1,2) cardtypecode,
				c.CARDSAMPLECODE,
				count(a.cardno) total
				 FROM TD_M_CARDSURFACE c,
				 (select * from TL_R_ICUSER where
					 RESSTATECODE = '04') a --����
				  where c.cardsurfacecode = a.cardsurfacecode(+)
          and cardtypecode = '05'
				  and c.cardsurfacecode not in(SELECT CARDSURFACECODE FROM TD_M_USECARDWARNCONFIG)
				  group by c.cardsurfacecode,c.cardsurfacename,a.cardtypecode,c.CARDSAMPLECODE
				 ) T ,TD_M_CARDTYPE b
				 where T.cardtypecode = b.cardtypecode
					and (p_var1 = '' or p_var1 is null or b.cardtypecode = p_var1)
					and (p_var2 = '' or p_var2 is null or T.CARDSURFACECODE = p_var2)
			)
			GROUP BY ��Ƭ����,��������,�������� ORDER BY ��Ƭ����,��������
				 ;
		ELSIF p_var3 = '02' THEN
			open p_cursor for
			select '02' ��Ƭ״̬,b.cardtypecode ||':'|| b.cardtypename ��Ƭ����,
				T.cardsurfacecode ||':'|| T.cardsurfacename ��������,
				T.total ʣ������,0 ��������,T.CARDSAMPLECODE ��������
				from
				(
				SELECT c.cardsurfacecode,
				c.cardsurfacename,
				substr(c.cardsurfacecode,1,2) cardtypecode,
				c.CARDSAMPLECODE,
				count(a.cardno) total
				 FROM TD_M_CARDSURFACE c,
				 (select * from TL_R_ICUSER where
					 RESSTATECODE = '15') a --�µ�
				  where c.cardsurfacecode = a.cardsurfacecode(+)
				  and c.cardsurfacecode not in(SELECT CARDSURFACECODE FROM TD_M_USECARDWARNCONFIG)
				  group by c.cardsurfacecode,c.cardsurfacename,a.cardtypecode,c.CARDSAMPLECODE
				 ) T ,TD_M_CARDTYPE b
				 where T.cardtypecode = b.cardtypecode
				and (p_var1 = '' or p_var1 is null or b.cardtypecode = p_var1)
				and (p_var2 = '' or p_var2 is null or T.CARDSURFACECODE = p_var2)
				 ORDER BY ��Ƭ����,��������;
		END IF;
elsif  p_funcCode = 'STOCK_CHARGECARD' then -- ��ѯ��ֵ�������
		IF (p_var1 = '' or p_var1 is null) THEN
			IF p_var2 = '01' THEN
				open p_cursor for
					SELECT '01' ��Ƭ״̬,��ֵ,sum(�������) �������,sum(��������) ��������
					FROM (
					select f.valuecode||':'||f.VALUE ��ֵ,count(t.XFCARDNO) �������,0 ��������
					  from TP_XFC_CARDVALUE f,
					  (select * from  TD_XFC_INITCARD
					  where CARDSTATECODE = '2' --���
					  ) t
					  where f.VALUECODE = t.VALUECODE(+)
					  and f.VALUECODE not in (select VALUECODE from TD_M_CHCARDWARNCONFIG)
					  group by f.VALUE,f.valuecode,t.CARDSTATECODE
					union
					select f.valuecode||':'||f.VALUE ��ֵ,0 �������,count(t.XFCARDNO) ��������
					  from TP_XFC_CARDVALUE f,
					  (select * from  TD_XFC_INITCARD
					  where CARDSTATECODE = '3' --����
					  ) t
					  where f.VALUECODE = t.VALUECODE(+)
					  and f.VALUECODE not in (select VALUECODE from TD_M_CHCARDWARNCONFIG)
					  group by f.VALUE,f.valuecode,t.CARDSTATECODE
					)
					GROUP BY ��ֵ ORDER BY ��ֵ;

			ELSIF p_var2 = '02' THEN
					open p_cursor for
					select 'C' ��Ƭ״̬,f.valuecode||':'||f.VALUE ��ֵ,count(t.XFCARDNO) ʣ������
						  from TP_XFC_CARDVALUE f,
						  (select * from  TD_XFC_INITCARD
						  where CARDSTATECODE = 'C' --�µ�
						  ) t
						  where f.VALUECODE = t.VALUECODE(+)
						  and f.VALUECODE not in (select VALUECODE from TD_M_CHCARDWARNCONFIG)
						  group by f.VALUE,f.valuecode,t.CARDSTATECODE
						  ORDER BY f.valuecode;
			END IF;
		ELSE
			IF (p_var2 = '01') THEN
					open p_cursor for
					SELECT '01' ��Ƭ״̬,��ֵ,sum(�������) �������,sum(��������) ��������
					FROM (
					select f.valuecode||':'||f.VALUE ��ֵ,count(*) �������,0 ��������
					  from TD_XFC_INITCARD t,TP_XFC_CARDVALUE f
					  where t.VALUECODE = f.VALUECODE(+)
					  and (p_var1 = '' or p_var1 is null or t.VALUECODE = p_var1)
					  and t.CARDSTATECODE = '2'	--���
					  and f.VALUECODE not in (select VALUECODE from TD_M_CHCARDWARNCONFIG)
					  group by f.VALUE,f.valuecode,t.CARDSTATECODE
					  union
					select f.valuecode||':'||f.VALUE ��ֵ,0 �������,count(*) ��������
					  from TD_XFC_INITCARD t,TP_XFC_CARDVALUE f
					  where t.VALUECODE = f.VALUECODE(+)
					  and (p_var1 = '' or p_var1 is null or t.VALUECODE = p_var1)
					  and t.CARDSTATECODE = '3'  --����
					  and f.VALUECODE not in (select VALUECODE from TD_M_CHCARDWARNCONFIG)
					  group by f.VALUE,f.valuecode,t.CARDSTATECODE
					)
					GROUP BY ��ֵ ORDER BY ��ֵ;
			ELSIF (p_var2 = '02') THEN
					open p_cursor for
					select 'C' ��Ƭ״̬,f.valuecode||':'||f.VALUE ��ֵ,0 �������,count(*) ��������
					  from TD_XFC_INITCARD t,TP_XFC_CARDVALUE f
					  where t.VALUECODE = f.VALUECODE(+)
					  and (p_var1 = '' or p_var1 is null or t.VALUECODE = p_var1)
					  and t.CARDSTATECODE = 'C'  --�µ�
					  and f.VALUECODE not in (select VALUECODE from TD_M_CHCARDWARNCONFIG)
					  group by f.VALUE,f.valuecode,t.CARDSTATECODE;
			END IF;
		END IF;

   elsif p_funcCode = 'USECARD_NOAPPROVED' then -- ��ѯδ�������û������뵥  add by Yin
      open p_cursor for
      select
      t.getcardorderid , --���õ���
      m.cardtypecode,    --��Ƭ���ͱ���
      m.cardtypename ,   --��Ƭ��������
      s.cardsurfacecode, --�������ͱ���
      s.cardsurfacename ,	--������������
      t.applygetnum ,     --������������
      t.useway ,          --��;
      t.ordertime ,        --����ʱ��
      t.orderstaffno ,	  --����Ա������
      st.staffname,      --����Ա������
      de.departno,	         --���벿�ű���
      de.departname ,	     --���벿������
      t.remark 			      --��ע
      from  TF_F_GETCARDORDER t
      inner join td_m_cardtype m on t.cardtypecode = m.cardtypecode
      inner join td_m_cardsurface s on t.cardsurfacecode = s.cardsurfacecode
      inner join td_m_insidestaff st on t.ORDERSTAFFNO =  st.STAFFNO
      inner join td_m_insidedepart de on st.departno = de.departno
      where t.GETCARDORDERTYPE = '01' and  t.GETCARDORDERSTATE = '0'
      order by t.getcardorderid desc;

elsif p_funcCode = 'CHARGECARD_NOAPPROVED' then -- ��ѯδ�����ĳ�ֵ�����뵥  add by Yin
      open p_cursor for
      select
      t.getcardorderid ,    --���õ���
      m.valuecode,          --������
      m.value ,						 --���
      t.applygetnum ,      --������������
      t.useway ,           --��;
      t.ordertime ,        --����ʱ��
      t.orderstaffno ,     --����Ա������
      st.staffname,		     --����Ա������
      de.departno,				--���벿�ű���
      de.departname ,			--���벿������
      t.remark 						--��ע
      from  TF_F_GETCARDORDER t
      inner join TP_XFC_CARDVALUE m on m.VALUECODE = t.valuecode
      inner join td_m_insidestaff st on t.ORDERSTAFFNO =  st.STAFFNO
      inner join td_m_insidedepart de on st.departno = de.departno
      where t.GETCARDORDERTYPE = '02'and	t.GETCARDORDERSTATE = '0'
      order by t.getcardorderid desc;
elsif p_funcCode = 'USECARD_APPROVED' then -- ��ѯ����ͨ�����û������뵥  add by Yin
      if p_var5 = '0' then
        open p_cursor for
            select
            t.getcardorderid ,  -- ���õ���
            m.cardtypecode,    --��Ƭ����
            m.cardtypename ,  --��Ƭ��������
            s.cardsurfacecode, --�������ͱ���
            s.cardsurfacename ,--������������
            t.applygetnum ,  --������������
            t.agreegetnum ,  --ͬ����������
            t.alreadygetnum , --�Ѿ���������
            t.useway ,  --��;
            t.ordertime ,  --����ʱ��
            t.orderstaffno , --����Ա��
            st.staffname,		--����Ա������
            de.departname ,--���ò�������
            t.remark 						 --��ע
            from  TF_F_GETCARDORDER t
            inner join td_m_cardtype m on t.cardtypecode = m.cardtypecode
            inner join td_m_cardsurface s on t.cardsurfacecode = s.cardsurfacecode
            inner join td_m_insidestaff st on t.ORDERSTAFFNO =  st.STAFFNO
            inner join td_m_insidedepart de on st.departno = de.departno
            where
            (p_var1 is null or t.getcardorderid = p_var1)
            and (p_var2 is null or t.getstaffno = p_var2)
            and (p_var3 is null or to_char(t.ordertime,'yyyymmdd') >= p_var3)
            and (p_var4 is null or to_char(t.ordertime,'yyyymmdd') <= p_var4)
            and (t.getcardorderstate = '1'  or t.getcardorderstate = '3' or t.getcardorderstate = '4')
            and t.PRINTCOUNT >= p_var6 and (p_var7 is null or t.PRINTCOUNT <= p_var7)
            order by t.getcardorderid desc;
      elsif p_var5 = '1' then
          open p_cursor for
            select
            t.getcardorderid ,  -- ���õ���
            m.cardtypecode,    --��Ƭ����
            m.cardtypename ,  --��Ƭ��������
            s.cardsurfacecode, --�������ͱ���
            s.cardsurfacename ,--������������
            t.applygetnum ,  --������������
            t.agreegetnum ,  --ͬ����������
            t.alreadygetnum , --�Ѿ���������
            t.useway ,  --��;
            t.ordertime ,  --����ʱ��
            t.orderstaffno , --����Ա��
            st.staffname,		--����Ա������
            de.departname ,--���ò�������
            t.remark 						 --��ע
            from  TF_F_GETCARDORDER t
            inner join td_m_cardtype m on t.cardtypecode = m.cardtypecode
            inner join td_m_cardsurface s on t.cardsurfacecode = s.cardsurfacecode
            inner join td_m_insidestaff st on t.ORDERSTAFFNO =  st.STAFFNO
            inner join td_m_insidedepart de on st.departno = de.departno
            where  --(t.getcardorderstate = '1'  or t.getcardorderstate = '3') and
            (p_var1 is null or t.getcardorderid = p_var1)
            and (p_var2 is null or t.getstaffno = p_var2)
            and (p_var3 is null or to_char(t.ordertime,'yyyymmdd') >= p_var3)
            and (p_var4 is null or to_char(t.ordertime,'yyyymmdd') <= p_var4)
            and (t.getcardorderstate = '1'  or t.getcardorderstate = '3')
            and t.PRINTCOUNT >= p_var6 and (p_var7 is null or t.PRINTCOUNT <= p_var7)
            order by t.getcardorderid desc;
      elsif p_var5 = '2' then
          open p_cursor for
            select
            t.getcardorderid ,  -- ���õ���
            m.cardtypecode,    --��Ƭ����
            m.cardtypename ,  --��Ƭ��������
            s.cardsurfacecode, --�������ͱ���
            s.cardsurfacename ,--������������
            t.applygetnum ,  --������������
            t.agreegetnum ,  --ͬ����������
            t.alreadygetnum , --�Ѿ���������
            t.useway ,  --��;
            t.ordertime ,  --����ʱ��
            t.orderstaffno , --����Ա��
            st.staffname,		--����Ա������
            de.departname ,--���ò�������
            t.remark 						 --��ע
            from  TF_F_GETCARDORDER t
            inner join td_m_cardtype m on t.cardtypecode = m.cardtypecode
            inner join td_m_cardsurface s on t.cardsurfacecode = s.cardsurfacecode
            inner join td_m_insidestaff st on t.ORDERSTAFFNO =  st.STAFFNO
            inner join td_m_insidedepart de on st.departno = de.departno
            where  --(t.getcardorderstate = '1'  or t.getcardorderstate = '3') and
            (p_var1 is null or t.getcardorderid = p_var1)
            and (p_var2 is null or t.getstaffno = p_var2)
            and (p_var3 is null or to_char(t.ordertime,'yyyymmdd') >= p_var3)
            and (p_var4 is null or to_char(t.ordertime,'yyyymmdd') <= p_var4)
            and t.PRINTCOUNT >= p_var6 and (p_var7 is null or t.PRINTCOUNT <= p_var7)
            and  t.getcardorderstate = '4'
            order by t.getcardorderid desc;
      end if;
elsif p_funcCode = 'CHARGECARD_APPROVED' then -- ��ѯ����ͨ���ĳ�ֵ�����뵥  add by Yin
      if p_var5 = '0' then
        open p_cursor for
          select
          t.getcardorderid, --���õ���
          m.valuecode, --������
          m.value,				--���
          t.applygetnum, --������������
          t.agreegetnum, --ͬ����������
          t.alreadygetnum, --�Ѿ���������
          t.useway, --��;
          t.ordertime, --����ʱ��
          t.orderstaffno,	 --����Ա��
          st.staffname,		--����Ա������
          de.departname, --��������
          t.remark			--��ע
          from  TF_F_GETCARDORDER t
          inner join TP_XFC_CARDVALUE m on m.VALUECODE = t.valuecode
          inner join td_m_insidestaff st on t.ORDERSTAFFNO =  st.STAFFNO
          inner join td_m_insidedepart de on st.departno = de.departno
          where (t.getcardorderstate = '1' or t.getcardorderstate = '3' or t.getcardorderstate = '4')
          and (p_var1 is null or t.getcardorderid = p_var1)
          and (p_var2 is null or t.getstaffno = p_var2)
          and (p_var3 is null or to_char(t.ordertime,'yyyymmdd') >= p_var3)
          and (p_var4 is null or to_char(t.ordertime,'yyyymmdd') <= p_var4)
          and t.PRINTCOUNT >= p_var6 and (p_var7 is null or t.PRINTCOUNT <= p_var7)
          order by t.getcardorderid desc;
      elsif p_var5 = '1' then
        open p_cursor for
          select
          t.getcardorderid, --���õ���
          m.valuecode, --������
          m.value,				--���
          t.applygetnum, --������������
          t.agreegetnum, --ͬ����������
          t.alreadygetnum, --�Ѿ���������
          t.useway, --��;
          t.ordertime, --����ʱ��
          t.orderstaffno,	 --����Ա��
          st.staffname,		--����Ա������
          de.departname, --��������
          t.remark			--��ע
          from  TF_F_GETCARDORDER t
          inner join TP_XFC_CARDVALUE m on m.VALUECODE = t.valuecode
          inner join td_m_insidestaff st on t.ORDERSTAFFNO =  st.STAFFNO
          inner join td_m_insidedepart de on st.departno = de.departno
          where (t.getcardorderstate = '1' or t.getcardorderstate = '3')
          and (p_var1 is null or t.getcardorderid = p_var1)
          and (p_var2 is null or t.getstaffno = p_var2)
          and (p_var3 is null or to_char(t.ordertime,'yyyymmdd') >= p_var3)
          and (p_var4 is null or to_char(t.ordertime,'yyyymmdd') <= p_var4)
          and t.PRINTCOUNT >= p_var6 and (p_var7 is null or t.PRINTCOUNT <= p_var7)
          order by t.getcardorderid desc;
      elsif p_var5 = '2' then
        open p_cursor for
          select
          t.getcardorderid, --���õ���
          m.valuecode, --������
          m.value,				--���
          t.applygetnum, --������������
          t.agreegetnum, --ͬ����������
          t.alreadygetnum, --�Ѿ���������
          t.useway, --��;
          t.ordertime, --����ʱ��
          t.orderstaffno,	 --����Ա��
          st.staffname,		--����Ա������
          de.departname, --��������
          t.remark			--��ע
          from  TF_F_GETCARDORDER t
          inner join TP_XFC_CARDVALUE m on m.VALUECODE = t.valuecode
          inner join td_m_insidestaff st on t.ORDERSTAFFNO =  st.STAFFNO
          inner join td_m_insidedepart de on st.departno = de.departno
          where (t.getcardorderstate = '4')
          and (p_var1 is null or t.getcardorderid = p_var1)
          and (p_var2 is null or t.getstaffno = p_var2)
          and (p_var3 is null or to_char(t.ordertime,'yyyymmdd') >= p_var3)
          and (p_var4 is null or to_char(t.ordertime,'yyyymmdd') <= p_var4)
          and t.PRINTCOUNT >= p_var6 and (p_var7 is null or t.PRINTCOUNT <= p_var7)
          order by t.getcardorderid desc;
      end if;
elsif p_funcCode = 'USECARD_DEPART' then
		  open p_cursor for
		  select tm.DEPARTNO||':'||tm.DEPARTNAME ����,count(tr.CARDNO) ����
		  from (SELECT * FROM TL_R_ICUSER where RESSTATECODE = '01' and CARDTYPECODE = p_var1 and CARDSURFACECODE = p_var2) tr,TD_M_INSIDEDEPART tm
		  where tm.DEPARTNO = tr.ASSIGNEDDEPARTID
		  group by tm.DEPARTNO,tm.DEPARTNAME
		  order by ���� desc;
elsif p_funcCode = 'GIFTUSECARD_DEPART' then
      open p_cursor for
		  select ����,sum(����) ����, sum(��������) ��������
			FROM (
			select T.DEPARTNO||':'||T.DEPARTNAME ����,
        count(T.CARDNO) ����,0 ��������
        from
        (
        SELECT a.cardno,b.departno,b.departname FROM TL_R_ICUSER a,TD_M_INSIDEDEPART b
         where a.RESSTATECODE='01'
         and a.CARDTYPECODE = p_var1
         and a.CARDSURFACECODE = p_var2
         and a.assigneddepartid = b.departno
         ) T
         group by t.departno,t.departname
			union
			select T.DEPARTNO||':'||T.DEPARTNAME ����,
        0 ����,count(T.CARDNO) ��������
        from
        (
        SELECT a.cardno,b.departno,b.departname FROM TL_R_ICUSER a,TD_M_INSIDEDEPART b
         where a.RESSTATECODE='04'
         and a.CARDTYPECODE = p_var1
         and a.CARDSURFACECODE = p_var2
         and a.assigneddepartid = b.departno
         ) T
         group by t.departno,t.departname
         )
         group by ���� order by ����;
elsif p_funcCode = 'CHARGE_DEPART' then
		  open p_cursor for
		  select tm.DEPARTNO||':'||tm.DEPARTNAME ����,count(tr.XFCARDNO) ����
		  from TD_M_INSIDEDEPART tm,(select * from TD_XFC_INITCARD where CARDSTATECODE = '3' and VALUECODE = p_var1) tr
		  where tm.DEPARTNO = tr.ASSIGNDEPARTNO
		  group by tm.DEPARTNO,tm.DEPARTNAME
		  order by ���� desc;
elsif p_funcCode = 'HISTORY_USECARD' then
		  open p_cursor for
		  select b.CARDTYPECODE ||':'|| b.CARDTYPENAME ��Ƭ����,c.CARDSURFACECODE ||':'|| c.CARDSURFACENAME ��������,
		  a.BEGINCARDNO ��ʼ����,a.ENDCARDNO ��ֹ����,
		  a.ASSIGNEDDEPARTID ||':'|| e.DEPARTNAME ���ò���,a.ASSIGNEDSTAFFNO ||':'|| d.STAFFNAME ����Ա��,a.OPERATETIME ����ʱ��,
		  SUM(to_number(substr(a.ENDCARDNO,-8))-to_number(substr(a.BEGINCARDNO,-8))+1) ��������
		  from TF_R_ICUSERTRADE a,TD_M_CARDTYPE b,TD_M_CARDSURFACE c,TD_M_INSIDESTAFF d,TD_M_INSIDEDEPART e
		  where SUBSTR(a.ENDCARDNO,5,2) = b.CARDTYPECODE(+)
		  and SUBSTR(a.ENDCARDNO,5,4) = c.CARDSURFACECODE(+)
		  and a.ASSIGNEDSTAFFNO = d.STAFFNO(+)
		  and a.ASSIGNEDDEPARTID = e.DEPARTNO(+)
		  and a.OPETYPECODE in ('01')
		  and (p_var1 = '' or p_var1 is null or a.CARDTYPECODE = p_var1)
		  and (p_var2 = '' or p_var2 is null or a.CARDSURFACECODE = p_var2)
		  and (p_var3 = '' or p_var3 is null or a.ASSIGNEDSTAFFNO = p_var3)
		  and (p_var4 IS NULL OR p_var4 = '' OR a.OPERATETIME >=TO_DATE(p_var4||'000000','YYYYMMDDHH24MISS'))
		  and (p_var5 IS NULL OR p_var5 = '' OR a.OPERATETIME <= TO_DATE(p_var5||'235959','YYYYMMDDHH24MISS'))
		  and (p_var6 = '' or p_var6 is null or a.ASSIGNEDDEPARTID = p_var6)
		  and (p_var7 is null or p_var7 = '' or p_var7 between a.BEGINCARDNO and a.ENDCARDNO)
		  group by b.CARDTYPECODE,b.CARDTYPENAME,c.CARDSURFACECODE,c.CARDSURFACENAME,a.ASSIGNEDSTAFFNO,
		  d.STAFFNAME,a.OPERATETIME,a.ASSIGNEDDEPARTID,e.DEPARTNAME,a.BEGINCARDNO,a.ENDCARDNO
		  order by b.CARDTYPECODE , c.CARDSURFACECODE , a.OPERATETIME desc;
elsif p_funcCode = 'HISTORY_CHARGECARD' then
		  open p_cursor for
		  select t.valuecode||':'||x.VALUE ��ֵ,t.startcardno ��ʼ����,t.ENDCARDNO ��ֹ����,
		  t.GETDEPARTID ||':'|| e.DEPARTNAME ���ò���,t.GETSTAFFNO ||':'|| f.STAFFNAME ����Ա��,t.OPERTIME ����ʱ��,
		  SUM(to_number(substr(t.ENDCARDNO,-8))-to_number(substr(t.startcardno,-8))+1) ��������
		  from TL_XFC_MANAGELOG t,TD_M_INSIDESTAFF f,TP_XFC_CARDVALUE x,TD_M_INSIDEDEPART e
		  where t.GETSTAFFNO = f.STAFFNO(+)
		  and t.valuecode = x.valuecode(+)
		  and t.OPERTYPECODE in ('03')
		  and t.GETDEPARTID = e.DEPARTNO(+)
		  and (p_var1 = '' or p_var1 is null or t.valuecode = p_var1)
		  and  (p_var2 IS NULL OR p_var2 = '' OR t.OPERTIME >= TO_DATE(p_var2||'000000','YYYYMMDDHH24MISS'))
		  and  (p_var3 IS NULL OR p_var3 = '' OR t.OPERTIME <= TO_DATE(p_var3||'235959','YYYYMMDDHH24MISS'))
		  and (p_var4 = '' or p_var4 is null or t.GETSTAFFNO = p_var4)
		  and (p_var5 = '' or p_var5 is null or t.GETDEPARTID = p_var5)
		  and (p_var6 is null or p_var6 = '' or p_var6 between t.startcardno and t.ENDCARDNO)
		  group by t.valuecode,x.VALUE,t.GETSTAFFNO,F.STAFFNAME,T.OPERTIME,t.startcardno,t.ENDCARDNO,
		  t.GETDEPARTID,e.DEPARTNAME
		  order by x.VALUE , t.OPERTIME desc;
elsif p_funcCode = 'WARN_USECARD' then
      BEGIN
		 IF p_VAR3 = '0' THEN
     open p_cursor for
			SELECT a.CARDTYPECODE || ':' || a.CARDTYPENAME ��Ƭ����,b.CARDSURFACECODE || ':' || b.CARDSURFACENAME ��������
			FROM TD_M_CARDTYPE a,TD_M_CARDSURFACE b
			WHERE a.CARDTYPECODE = substr(b.CARDSURFACECODE,1,2)
			AND (P_VAR1 IS NULL OR P_VAR1 = '' OR a.CARDTYPECODE = P_VAR1)
			AND (p_VAR2 IS NULL OR p_VAR2 = '' OR b.CARDSURFACECODE = p_VAR2)
			AND b.CARDSURFACECODE not in (select CARDSURFACECODE from TD_M_USECARDWARNCONFIG)
			ORDER BY a.CARDTYPECODE,b.CARDSURFACECODE;
		ELSIF p_VAR3 = '1' THEN
    open p_cursor for
			SELECT a.CARDTYPECODE || ':' || a.CARDTYPENAME ��Ƭ����,b.CARDSURFACECODE || ':' || b.CARDSURFACENAME ��������
			FROM TD_M_CARDTYPE a,TD_M_CARDSURFACE b
			WHERE a.CARDTYPECODE = substr(b.CARDSURFACECODE,1,2)
			AND (P_VAR1 IS NULL OR P_VAR1 = '' OR a.CARDTYPECODE = P_VAR1)
			AND (p_VAR2 IS NULL OR p_VAR2 = '' OR b.CARDSURFACECODE = p_VAR2)
			AND b.CARDSURFACECODE in (select CARDSURFACECODE from TD_M_USECARDWARNCONFIG)
			ORDER BY a.CARDTYPECODE,b.CARDSURFACECODE;
		END IF;
		END;
elsif p_funcCode = 'WARN_CHARGECARD' then
      BEGIN
		 IF p_VAR2 = '0' THEN
     open p_cursor for
			SELECT a.VALUECODE || ':' || a.VALUE ��ֵ
			FROM TP_XFC_CARDVALUE a
			WHERE (P_VAR1 IS NULL OR P_VAR1 = '' OR a.VALUECODE = P_VAR1)
			AND a.VALUECODE not in (select VALUECODE from TD_M_CHCARDWARNCONFIG)
			ORDER BY a.VALUECODE;
		ELSIF p_VAR2 = '1' THEN
    open p_cursor for
			SELECT a.VALUECODE || ':' || a.VALUE ��ֵ
			FROM TP_XFC_CARDVALUE a
			WHERE (P_VAR1 IS NULL OR P_VAR1 = '' OR a.VALUECODE = P_VAR1)
			AND a.VALUECODE in (select VALUECODE from TD_M_CHCARDWARNCONFIG)
			ORDER BY a.VALUECODE;
		END IF;
		END;
elsif p_funcCode = 'CARDFACE' then
		BEGIN
		IF p_VAR3 = '0' THEN
		open p_cursor for
		select a.CARDTYPECODE ||':'|| a.CARDTYPENAME ��Ƭ����,b.CARDSURFACECODE ||':'|| b.CARDSURFACENAME ��������,
			b.CARDSURFACENOTE ��������˵��,b.CARDSAMPLECODE ��������,decode(b.USETAG,'0','��Ч','1','��Ч') ��Ч��־,
			b.UPDATESTAFFNO ||':'|| m.STAFFNAME ����Ա��,b.UPDATETIME ����ʱ��
		from TD_M_CARDTYPE a,TD_M_CARDSURFACE b,TD_M_INSIDESTAFF m
		where a.CARDTYPECODE = substr(b.CARDSURFACECODE,1,2)
			and b.UPDATESTAFFNO = m.STAFFNO(+)
			and (P_VAR1 = '' or P_VAR1 is null or a.CARDTYPECODE = P_VAR1)
			and (p_VAR2 = '' or p_VAR2 is null or b.CARDSURFACECODE = p_VAR2)
      ORDER BY A.CARDTYPECODE,B.CARDSURFACECODE;
		ELSIF p_VAR3 = '1' THEN
		open p_cursor for
		select a.CARDTYPECODE ||':'|| a.CARDTYPENAME ��Ƭ����,b.CARDSURFACECODE ||':'|| b.CARDSURFACENAME ��������,
			b.CARDSURFACENOTE ��������˵��,b.CARDSAMPLECODE ��������,decode(b.USETAG,'0','��Ч','1','��Ч') ��Ч��־,
			b.UPDATESTAFFNO ||':'|| m.STAFFNAME ����Ա��,b.UPDATETIME ����ʱ��
		from TD_M_CARDTYPE a,TD_M_CARDSURFACE b,TD_M_INSIDESTAFF m
		where a.CARDTYPECODE = substr(b.CARDSURFACECODE,1,2)
			and b.UPDATESTAFFNO = m.STAFFNO(+)
			and (P_VAR1 = '' or P_VAR1 is null or a.CARDTYPECODE = P_VAR1)
			and (p_VAR2 = '' or p_VAR2 is null or b.CARDSURFACECODE = p_VAR2)
			and (b.CARDSAMPLECODE is not null)
      ORDER BY A.CARDTYPECODE,B.CARDSURFACECODE;
		ELSIF p_VAR3 = '2' THEN
		open p_cursor for
		select a.CARDTYPECODE ||':'|| a.CARDTYPENAME ��Ƭ����,b.CARDSURFACECODE ||':'|| b.CARDSURFACENAME ��������,
			b.CARDSURFACENOTE ��������˵��,decode(b.USETAG,'0','��Ч','1','��Ч') ��Ч��־,
			b.UPDATESTAFFNO ||':'|| m.STAFFNAME ����Ա��,b.UPDATETIME ����ʱ��
		from TD_M_CARDTYPE a,TD_M_CARDSURFACE b,TD_M_INSIDESTAFF m
		where a.CARDTYPECODE = substr(b.CARDSURFACECODE,1,2)
			and b.UPDATESTAFFNO = m.STAFFNO(+)
			and (P_VAR1 = '' or P_VAR1 is null or a.CARDTYPECODE = P_VAR1)
			and (p_VAR2 = '' or p_VAR2 is null or b.CARDSURFACECODE = p_VAR2)
			and (b.CARDSAMPLECODE is null or b.CARDSAMPLECODE = '')
      ORDER BY A.CARDTYPECODE,B.CARDSURFACECODE;
		END IF;
		END;
ELSIF p_funcCode = 'CARDSECTION' then
	open p_cursor for
		select b.CARDNOCONFIGID,b.CARDTYPECODE ||':'|| a.CARDTYPENAME ��Ƭ����,b.BEGINCARDNO ��ʼ����,b.ENDCARDNO ��ֹ����
		from TD_M_CARDTYPE a,TD_M_CARDNOCONFIG b
		where b.CARDTYPECODE= a.CARDTYPECODE(+)
			and B.USETAG <> '0'
			and (P_VAR1 = '' or P_VAR1 is null or b.CARDTYPECODE = P_VAR1)
		ORDER BY b.CARDTYPECODE,b.BEGINCARDNO;

elsif p_funcCode = 'APPLYORDERSEARCH' then -- �������󵥺Ų�ѯ��������Ҫ��ӡ�Ĵ���������������ƿ����� add by Yin
    open p_cursor for

    'SELECT A.APPLYORDERID ,
		       A.CARDTYPECODE || '':'' || D.CARDTYPENAME CARDTYPE,
		       A.CARDSURFACECODE || '':'' || C.CARDSURFACENAME CARDFACE,
		       A.CARDSAMPLECODE,
		       A.CARDNUM       ,
		       A.CARDNAME      ,
		       decode(A.CARDFACEAFFIRMWAY,''1'',''1:����'',''2'',''2:����'',''3'',''3:����Ҫȷ��'',A.CARDFACEAFFIRMWAY) CARDFACEAFFIRMWAY ,
		       A.REQUIREDATE   ,
		       A.ORDERDEMAND   ,
		       A.REMARK        ,
		       A.ORDERTIME     ,
		       A.ORDERSTAFFNO || '':''|| E.STAFFNAME ORDERSTAFF ,
		       F.DEPARTNO || '':'' || F.DEPARTNAME DEPARTNAME
		FROM   TF_F_APPLYORDER  A ,
		       TD_M_CARDSURFACE C ,
		       TD_M_CARDTYPE    D ,
		       TD_M_INSIDESTAFF E,
		       td_m_insidedepart F

		WHERE  A.CARDTYPECODE = D.CARDTYPECODE
		AND    A.CARDSURFACECODE = C.CARDSURFACECODE
		AND    A.ORDERSTAFFNO = E.STAFFNO
		AND    E.DEPARTNO = F.DEPARTNO
    AND    A.APPLYORDERID in (' || p_var1 || ')
		AND    A.USETAG = ''1''
		ORDER BY A.ORDERTIME DESC';

elsif   p_funcCode = 'APPLYCHARGECARDSEARCH' then -- �������󵥺Ų�ѯ��������Ҫ��ӡ�ĳ�ֵ������ add by Yin
    open p_cursor for
		'SELECT A.APPLYORDERID ,
		       A.VALUECODE || '':'' || C.VALUE VALUECODE,
		       A.CARDNUM       ,
		       A.REQUIREDATE   ,
		       A.ORDERDEMAND   ,
		       A.REMARK        ,
		       A.ORDERTIME     ,
		       A.ORDERSTAFFNO || '':''|| E.STAFFNAME ORDERSTAFF,
           F.DEPARTNO || '':'' || F.DEPARTNAME DEPARTNAME
		FROM   TF_F_APPLYORDER  A ,
		       TP_XFC_CARDVALUE C ,
		       TD_M_INSIDESTAFF E ,
           td_m_insidedepart F

		WHERE  A.VALUECODE = C.VALUECODE
		AND    A.ORDERSTAFFNO = E.STAFFNO
		AND    E.DEPARTNO = F.DEPARTNO
    AND    A.APPLYORDERID in (' || p_var1 || ')
		AND    A.USETAG = ''1''
		ORDER BY A.ORDERTIME DESC';

elsif  p_funcCode = 'USERCARDORDERSEARCH' then -- ���ݶ������Ų�ѯ��������Ҫ��ӡ���û��������� add by Yin
    open p_cursor for
		'SELECT A.CARDORDERID,
		       A.CARDTYPECODE || '':'' || D.CARDTYPENAME    CARDTYPE ,
		       A.CARDSURFACECODE || '':'' || C.CARDSURFACENAME CARDFACE ,
		       A.CARDSAMPLECODE,
		       A.CARDNAME,
		       A.CARDNUM          ,
		       A.REQUIREDATE      ,
		       A.BEGINCARDNO      ,
		       A.ENDCARDNO        ,
		       A.ORDERSTAFFNO || '':'' || H.STAFFNAME  ORDERSTAFF,
           F.DEPARTNO || '':'' || F.DEPARTNAME DEPARTNAME,
		       A.REMARK
		FROM   TF_F_CARDORDER    A ,
		       TD_M_CARDSURFACE  C ,
		       TD_M_CARDTYPE     D ,
		       TD_M_INSIDESTAFF  H ,
           td_m_insidedepart F
		WHERE  A.CARDSURFACECODE = C.CARDSURFACECODE
		AND    A.CARDTYPECODE = D.CARDTYPECODE
		AND    A.ORDERSTAFFNO = H.STAFFNO
    AND    H.DEPARTNO = F.DEPARTNO
		AND    A.USETAG = ''1''
		AND    A.CARDORDERID in (' ||  p_var1 ||  ')
		ORDER BY A.ORDERTIME DESC';

elsif p_funcCode = 'CHARGECARDORDERSEARCH' then -- ���ݶ������Ų�ѯ��������Ҫ��ӡ�ĳ�ֵ�������� add by Yin

    open p_cursor for
		'SELECT A.CARDORDERID      ,
		       A.VALUECODE || '':'' || B.VALUE CARDVALUE ,
		       A.CARDNUM          ,
		       A.REQUIREDATE      ,
		       A.BEGINCARDNO      ,
		       A.ENDCARDNO        ,
		       A.ORDERTIME        ,
		       A.ORDERSTAFFNO || '':'' || C.STAFFNAME ORDERSTAFF,
           F.DEPARTNO || '':'' || F.DEPARTNAME ,
		       A.REMARK
		FROM   TF_F_CARDORDER    A ,
		       TP_XFC_CARDVALUE  B ,
		       TD_M_INSIDESTAFF  C ,
		       td_m_insidedepart F
		WHERE  A.VALUECODE = B.VALUECODE
		AND    A.ORDERSTAFFNO = C.STAFFNO
    AND    C.DEPARTNO = F.DEPARTNO
		AND    A.USETAG = ''1''
		AND    A.CARDORDERID in (' ||  p_var1 ||  ')
		ORDER BY A.ORDERTIME DESC';

ELSIF p_funcCode = 'TD_M_CARDSURFACE' then	--�������
	open p_cursor for
		select CARDSURFACENAME, CARDSURFACECODE from TD_M_CARDSURFACE
		where CARDSURFACECODE not in (select CARDSURFACECODE from TD_M_USECARDWARNCONFIG)
		and (P_VAR1 = '' or P_VAR1 is null or substr(CARDSURFACECODE,1,2) = P_VAR1)
		order by CARDSURFACECODE;
ELSIF p_funcCode = 'TP_XFC_CARDVALUESELECT' THEN --��ֵ����
	open p_cursor for
		select t.VALUE,t.VALUECODE from TP_XFC_CARDVALUE t
		where VALUECODE NOT IN(select VALUECODE from TD_M_CHCARDWARNCONFIG)
		ORDER BY t.VALUECODE;
ELSIF p_funcCode = 'GETCARDSAMPLECODE' THEN	--��ѯ������
	open p_cursor for
		SELECT CARDSAMPLECODE FROM TD_M_CARDSURFACE WHERE CARDSURFACECODE = P_VAR1;
elsif p_funcCode = 'GETUSECARDREPORT' then --�û���������ʷͳ��
		  open p_cursor for
		  select e.DEPARTNAME ���ò���,b.CARDTYPENAME ��Ƭ����,c.CARDSURFACENAME ��������,
		  SUM(to_number(substr(a.ENDCARDNO,-8))-to_number(substr(a.BEGINCARDNO,-8))+1) ��������
		  from TF_R_ICUSERTRADE a,TD_M_CARDTYPE b,TD_M_CARDSURFACE c,TD_M_INSIDEDEPART e
		  where SUBSTR(a.ENDCARDNO,5,2) = b.CARDTYPECODE(+)
		  and SUBSTR(a.ENDCARDNO,5,4) = c.CARDSURFACECODE(+)
		  and a.ASSIGNEDDEPARTID = e.DEPARTNO(+)
		  and a.OPETYPECODE in ('01')
		  and (p_var1 = '' or p_var1 is null or SUBSTR(a.ENDCARDNO,5,2) = p_var1)
		  and (p_var2 = '' or p_var2 is null or SUBSTR(a.ENDCARDNO,5,4) = p_var2)
		  and (p_var3 IS NULL OR p_var3 = '' OR a.OPERATETIME >=TO_DATE(p_var3||'000000','YYYYMMDDHH24MISS'))
		  and (p_var4 IS NULL OR p_var4 = '' OR a.OPERATETIME <= TO_DATE(p_var4||'235959','YYYYMMDDHH24MISS'))
		  and (p_var5 = '' or p_var5 is null or a.ASSIGNEDDEPARTID = p_var5)
		  group by b.CARDTYPENAME,c.CARDSURFACENAME,e.DEPARTNAME
		  order by e.DEPARTNAME,b.CARDTYPENAME,c.CARDSURFACENAME desc;
elsif p_funcCode = 'GETCHARGECARDREPORT' then --��ֵ��������ʷͳ��
		  open p_cursor for
		  select e.DEPARTNAME ���ò���,x.VALUE ��ֵ,SUM(to_number(substr(t.ENDCARDNO,-8))-to_number(substr(t.startcardno,-8))+1) ��������
		  from TL_XFC_MANAGELOG t,TD_M_INSIDESTAFF f,TP_XFC_CARDVALUE x,TD_M_INSIDEDEPART e
		  where t.STAFFNO = f.STAFFNO(+)
		  and t.valuecode = x.valuecode(+)
		  and t.OPERTYPECODE in ('03')
		  and f.DEPARTNO = e.DEPARTNO
		  and (p_var1 = '' or p_var1 is null or t.valuecode = p_var1)
		  and  (p_var2 IS NULL OR p_var2 = '' OR t.OPERTIME >= TO_DATE(p_var2||'000000','YYYYMMDDHH24MISS'))
		  and  (p_var3 IS NULL OR p_var3 = '' OR t.OPERTIME <= TO_DATE(p_var3||'235959','YYYYMMDDHH24MISS'))
		  and (p_var4 = '' or p_var4 is null or e.DEPARTNO = p_var4)
		  group by x.VALUE,e.DEPARTNAME
		  order by e.DEPARTNAME,x.VALUE desc;
elsif p_funcCode = 'TD_M_MANUWITHCODING' then
		open p_cursor for
		SELECT B.CODEDESC,B.CODEVALUE,A.MANUCODE
		FROM TD_M_MANU A,TD_M_RMCODING B
		WHERE A.MANUNAME=B.CODEDESC
		AND B.TABLENAME='TD_M_MANU' AND COLNAME='MANUNAME';
elsif p_funcCode = 'GETFILENAME' then
		open p_cursor for
		SELECT FILENAME,ID
		FROM TF_SYN_CARDFILE
		WHERE  DEALCODE = '0'
		   AND FILETYPE = '03'
		   AND (ORDERSATATE = '0' or ORDERSATATE is null and filename not like 'E%')
		   ORDER BY ID;
elsif p_funcCode = 'SMKOrderQuery' then --���񿨶�������ѯ
		  open p_cursor for
		  SELECT A.CARDORDERID      ,                                 --��������
			       A.CARDORDERTYPE||':'||B.CODEDESC  ORDERTYPE  ,       --��������
			       C.CODEVALUE ||'_' || A.BATCHNO || '_' || A.BATCHDATE || '_' || A.CARDNUM || '_SX.txt'        ORDERFILENAME,                                 --�ƿ��ļ���
			       A.MANUTYPECODE ||':'||G.MANUNAME  MANUNAME       ,   --������
			       C.CODEVALUE	 MANUFILECODE																	  ,   --������	����
			       A.BATCHNO ,                                      --���κ�
			       A.BATCHDATE   ,                                 --��������
			       A.CARDNUM ,                                  --��������
			       A.BEGINCARDNO      ,                                 --��ʼ����
			       A.ENDCARDNO        ,                                 --��������
			       A.ORDERTIME        ,                          --�µ�ʱ��
			       A.ORDERSTAFFNO||':'||H.STAFFNAME  ORDERSTAFF, --�µ�Ա��
			       A.EXAMTIME         ,                          --���ʱ��
			       A.EXAMSTAFFNO||':'||I.STAFFNAME   EXAMSTAFF,  --���Ա��
			       A.REMARK           ,                          --��ע
			       A.CARDORDERSTATE||':'||K.CODEDESC  STATE      --���״̬
			FROM   TF_F_SMK_CARDORDER A ,
			       TD_M_RMCODING     B ,
			       TD_M_MANU         G , --��Ƭ���̱���ֵ
			       TD_M_RMCODING		 C ,
			       TD_M_INSIDESTAFF  H ,
			       TD_M_INSIDESTAFF  I ,
			       TD_M_RMCODING       K	 -- ����״̬����ֵ
			WHERE  A.CARDORDERTYPE = B.CODEVALUE
			AND    B.COLNAME = 'CARDORDERTYPE'
			AND    B.TABLENAME = 'TF_F_SMK_CARDORDER'
			AND    A.CARDORDERSTATE = K.CODEVALUE
			AND    K.COLNAME = 'CARDORDERSTATE'
			AND    K.TABLENAME = 'TF_F_SMK_CARDORDER'
			AND    C.TABLENAME = 'TD_M_MANU'
			AND    C.COLNAME = 'MANUNAME'
			AND    C.CODEDESC = G.MANUNAME
			AND    A.MANUTYPECODE = G.MANUCODE(+)
			AND    A.ORDERSTAFFNO = H.STAFFNO(+)
			AND    A.EXAMSTAFFNO = I.STAFFNO(+)
			AND    A.USETAG = '1'
			AND   (P_VAR1 IS NULL OR P_VAR1 = '' OR TO_DATE(P_VAR1||'000000','YYYYMMDDHH24MISS') <= A.ORDERTIME)
			AND   (P_VAR2 IS NULL OR P_VAR2 = '' OR TO_DATE(P_VAR2||'235959','YYYYMMDDHH24MISS') >= A.ORDERTIME)
			AND   (P_VAR3 IS NULL OR P_VAR3 = '' OR P_VAR3 = A.CARDORDERSTATE)
			AND   (P_VAR4 IS NULL OR P_VAR4 = '' OR P_VAR4 = A.CARDORDERID)
			AND   (P_VAR5 IS NULL OR P_VAR5 = '' OR P_VAR5 = A.CARDORDERTYPE)
			ORDER BY A.ORDERTIME DESC;
elsif p_funcCode = 'selectSmkExam' then
		open p_cursor for
		SELECT A.CARDORDERID      ,                                  --��������
			   DECODE(A.CARDORDERTYPE,'01','��Ʒ��','02','���Ʒ��')     CARDORDERTYPE ,  --��������
			   DECODE(A.CARDORDERSTATE,'0','�����','1','���ͨ��','2','�������','3','���ֵ���','4','ȫ������')  CARDORDERSTATE,  --������״̬
			   A.FILENAME         ,                                  --�ƿ��ļ���
			   A.MANUTYPECODE||':'||G.MANUNAME   MANUNAME ,          --������
			   A.BATCHNO          ,                                  --���κ�
			   A.CARDNUM          ,                                  --��������
			   A.BATCHDATE        ,                                  --��������
			   A.BEGINCARDNO      ,                                  --��ʼ����
			   A.ENDCARDNO        ,                                  --��������
			   A.ORDERTIME        ,                          --�µ�ʱ��
			   A.ORDERSTAFFNO||':'||H.STAFFNAME  ORDERSTAFF ,--�µ�Ա��
			   A.EXAMTIME         ,                          --���ʱ��
			   A.EXAMSTAFFNO||':'||I.STAFFNAME   EXAMSTAFF , --���Ա��
			   A.REMARK                                      --��ע
		FROM   TF_F_SMK_CARDORDER    A ,
			   TD_M_MANU         G , --��Ƭ���̱����
         TD_M_INSIDESTAFF  H ,
         TD_M_INSIDESTAFF  I
    WHERE  A.MANUTYPECODE = G.MANUCODE(+)
    AND    A.ORDERSTAFFNO = H.STAFFNO(+)
    AND    A.EXAMSTAFFNO = I.STAFFNO(+)
    AND    A.USETAG = '1'
    AND   (P_VAR1 IS NULL OR P_VAR1 = '' OR P_VAR1 = A.CARDORDERID )
    AND   (P_VAR2 IS NULL OR P_VAR2 = '' OR P_VAR2 = A.CARDORDERSTATE)
    ORDER BY A.ORDERTIME DESC;
elsif p_funcCode = 'queryTask' then --�����ƿ�ҳ��������ѯ
    open p_cursor for
    SELECT         A.CARDORDERID ,                               --������
           A.VALUECODE||':'||C.VALUE VALUECODE ,         --��ֵ����ֵ
           A.CARDNUM       ,                             --�µ�����
           A.CARDORDERSTATE||':'||B.CODEDESC STATE,       --���״̬
           A.ORDERTIME      ,                            --�µ�ʱ��
           D.TASKID        ,                            --����ID
           A.APPVERNO      ,                            --���κ�
           A.MANUTYPECODE     ,                          --����
           DECODE( D.TASKSTATE,'0','0:������','1','1:������','2','2:����ɹ�','3','3:����ʧ��','4' ,'4:����','5','5:ɾ��','6','6:��ɾ��','7','7:��ɾ���ƿ��ļ�',D.TASKSTATE) TASKSTATE, --����״̬
           A.BEGINCARDNO||'-'||A.ENDCARDNO  SECTION,    --��ֵ���Ŷ�
           D.TASKSTARTTIME,                             --����ʼʱ��
           D.TASKENDTIME,                               --�������ʱ��
           nvl2(D.OPERATOR,D.OPERATOR||':'||E.STAFFNAME,null) ORDERSTAFF,     --����Ա��
           D.DATETIME ,                               --����ʱ��
           D.FILEPATH ,                               --�ļ����ص�ַ
           D.REMARK                                   --˵��
    FROM   TF_F_CARDORDER  A , --��Ƭ����
           TD_M_RMCODING    B ,
           TP_XFC_CARDVALUE C ,
           TF_F_MAKECARDTASK D, --�ƿ������
           TD_M_INSIDESTAFF E
    WHERE  B.COLNAME = 'CARDORDERSTATE'
    AND    B.TABLENAME = 'TF_F_CARDORDER'
    AND    A.CARDORDERSTATE = B.CODEVALUE
    AND    A.VALUECODE = C.VALUECODE
    AND    D.OPERATOR = E.STAFFNO(+)
    AND    A.CARDORDERID = D.CARDORDERID(+)
    AND    A.CARDORDERTYPE = '03' --��ֵ������
    AND   ( A.CARDORDERSTATE = '1' or  A.CARDORDERSTATE = '3' or A.CARDORDERSTATE = '4'or  A.CARDORDERSTATE = '5')--���������ͨ��
    AND    A.USETAG = '1'  --��Ч
    AND   (P_VAR1 IS NULL OR P_VAR1 = '' OR P_VAR1 = A.CARDORDERID ) --��������
    AND   (P_VAR2 IS NULL OR P_VAR2 = '' OR TO_DATE(P_VAR2||'000000','YYYYMMDDHH24MISS') <= A.ORDERTIME)
    AND   (P_VAR3 IS NULL OR P_VAR3 = '' OR TO_DATE(P_VAR3||'235959','YYYYMMDDHH24MISS') >= A.ORDERTIME)
    order by A.ORDERTIME desc;
elsif p_funcCode = 'queryKey' then --���ҹ�˽Կά��ҳ���ѯ
   open p_cursor for
   SELECT A.ID,nvl2(A.CORPCODE,A.CORPCODE||':'||B.CORPNAME,null) PRODUCER ,A.PUBLICKEY,A.PRIVATEKEY,A.OPERATETIME
   FROM TD_M_PUBLICANDPRIVATEKEY A,TP_XFC_CORP B
   WHERE A.CORPCODE = B.CORPCODE(+)
   AND   (P_VAR1 IS NULL OR P_VAR1 = '' OR P_VAR1 = A.CORPCODE )
   ORDER BY A.ID;
   
elsif p_funcCode = 'QryHasExistPwd' then
      open p_cursor for
      select XFCARDNO,NEW_PASSWD
              from TD_XFC_INITCARD 
      where NEW_PASSWD= p_var1;
elsif  p_funcCode = 'queryMaxCardNo2' then  --��ȡ��ֵ���˻�������ر�����󿨺ź�8λ add by youyue
    open p_cursor for
    select Max(a.cardno) from (select   Max(substr(t.xfcardno,7,8)) cardno from TD_XFC_INITCARD t
    union all Select   Max(substr(b.cardno,7,8)) cardno from TD_M_CHARGECARDNO_EXCLUDE b ) a;
 end if;
end;
/
show errors
create or replace procedure SP_PS_Query_Report
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
    if p_funcCode = 'QueryTotalOutcomeFin' then --佣金转账日报
    open p_cursor for 
    SELECT  B.DBALUNIT,decode(A.FINTYPECODE,'0','财务部门转账','1','结入预付款',A.FINTYPECODE) FINTYPE, SUM(A.TOTALBALFEE)/100.0 TOTALBALFEE, SUM(A.TOTALTIMES) TOTALTIMES,
    SUM(A.CANCELTOTALBALFEE)/100.0 CANCELTOTALBALFEE,
            SUM(A.CANCELTOTALTIMES) CANCELTOTALTIMES,
             SUM(A.TRANSFEE)/100.0 TRANSFEE, SUM(A.TRANSTIMES) TRANSTIMES,
             SUM(A.COMFEE)/100.0 COMFEE
        FROM TF_DEPTBALTRADE_AllFIN A,TF_DEPT_BALUNIT B
        WHERE A.DBALUNITNO = B.DBALUNITNO
        AND   (P_VAR1 IS NULL OR P_VAR1 = '' OR TO_CHAR(A.ENDTIME,'YYYYMMDD') >= TO_CHAR((TO_DATE(P_VAR1,'YYYYMMDD')+1),'YYYYMMDD'))
        AND   (P_VAR2 IS NULL OR P_VAR2 = '' OR TO_CHAR(A.ENDTIME,'YYYYMMDD') <= TO_CHAR((TO_DATE(P_VAR2,'YYYYMMDD')+1),'YYYYMMDD'))
        AND   (P_VAR3 IS NULL OR P_VAR3 = '' OR A.DBALUNITNO = P_VAR3)
		AND   (P_VAR4 IS NULL OR P_VAR4 = '' OR A.FINTYPECODE = P_VAR4)
        GROUP BY B.DBALUNIT,A.FINTYPECODE ORDER BY B.DBALUNIT;


    elsif p_funcCode = 'QueryOutcomeFin' then --佣金转账日报明细
     open p_cursor for
     SELECT
            B.DBALUNIT, D.TRADETYPE,
            SUM(A.TOTALBALFEE)/100.0  TOTALBALFEE, SUM(A.TOTALTIMES) TOTALTIMES,		E.TRADETYPE CANCELTYPECODE,
            SUM(A.CANCELTOTALBALFEE)/100.0  CANCELTOTALBALFEE,
            SUM(A.CANCELTOTALTIMES) CANCELTOTALTIMES , SUM(A.COMFEE)/100.0   COMFEE
        FROM TF_DEPTBALTRADE_OUTFIN A  left join TD_M_TRADETYPE E on A.CANCELTYPECODE = E.TRADETYPECODE,TF_DEPT_BALUNIT B,TD_TRADETYPE_SHOW C,TD_M_TRADETYPE D 
        WHERE  A.TRADETYPECODE = D.TRADETYPECODE
        AND    A.DBALUNITNO = B.DBALUNITNO
        AND    C.TRADETYPENO = A.TRADETYPECODE
        AND   (P_VAR1 IS NULL OR P_VAR1 = '' OR TO_CHAR(A.ENDTIME,'YYYYMMDD') >= TO_CHAR((TO_DATE(P_VAR1,'YYYYMMDD')+1),'YYYYMMDD'))
        AND   (P_VAR2 IS NULL OR P_VAR2 = '' OR TO_CHAR(A.ENDTIME,'YYYYMMDD') <= TO_CHAR((TO_DATE(P_VAR2,'YYYYMMDD')+1),'YYYYMMDD'))
        AND   (P_VAR3 IS NULL OR P_VAR3 = '' OR A.DBALUNITNO = P_VAR3)
        AND   (P_VAR4 = '0000' OR (P_VAR4 = C.SHOWNO))
   		  GROUP BY B.DBALUNIT,D.TRADETYPE,E.TRADETYPE ORDER BY B.DBALUNIT;


    /*elsif p_funcCode = 'StockCollect' then --网点库存统计
    begin
            if to_char(sysdate,'YYYYMMDD') > to_char(to_date(p_var3,'YYYYMMDD'),'YYYYMMDD') then --查询的是历史日期
               begin
                  open p_cursor for
                  select  B.CARDTYPENAME  , C.CARDSURFACENAME  , A.CARDCOUNT from
                  (
                      select CARDTYPECODE,CARDSURFACECODE,SUM(CARDCOUNT) CARDCOUNT FROM TF_DEPTBAL_STOCKCOL t
                      where  t.DEPARTNO = P_VAR1
                      AND   (P_VAR2 IS NULL OR P_VAR2 = '' OR t.CARDTYPECODE = P_VAR2)
                      AND   TO_CHAR(t.DEALTIME,'YYYYMMDD') = p_var3
                      group by CARDTYPECODE,CARDSURFACECODE
                  ) A , TD_M_CARDTYPE B,TD_M_CARDSURFACE C
                  WHERE A.CARDTYPECODE = B.CARDTYPECODE(+)
                  AND   A.CARDSURFACECODE = C.CARDSURFACECODE(+)
                  order by  B.CARDTYPENAME;
                 end;
                 else
                   open p_cursor for
                       SELECT B.CARDTYPENAME  , C.CARDSURFACENAME  , A.CARDCOUNT		FROM
                            (SELECT CARDTYPECODE,CARDSURFACECODE,COUNT(*) CARDCOUNT
                             FROM TL_R_ICUSER t
                             WHERE t.assigneddepartid = P_VAR1
                             AND   (P_VAR2 IS NULL OR P_VAR2 = '' OR t.CARDTYPECODE = P_VAR2)
                             AND   t.RESSTATECODE IN ('01','05')
                             GROUP BY t.CARDTYPECODE,t.CARDSURFACECODE) A,
                             TD_M_CARDTYPE B,TD_M_CARDSURFACE C
                         WHERE A.CARDTYPECODE = B.CARDTYPECODE(+)
                         AND   A.CARDSURFACECODE = C.CARDSURFACECODE(+)
                         ORDER BY B.CARDTYPENAME;
                end if;
      end;*/
    elsif p_funcCode = 'DeptBalAccBalance' then   --资金管理账单
    begin
      open p_cursor for
      select D.DBALUNIT DBALUNIT,P.PREDEPOSIT,C.DEPOSITIN DEPOSITIN , ABS(C.DEPOSITOUT) DEPOSITOUT ,D.DEPOSIT DEPOSIT,P.PREPREPAY, D.PREPAY PREPAY ,
      C.PREPAYIN PREPAYIN , ABS(C.PREPAYOUT)  PREPAYOUT,
      ABS(C.PREPAYCHARGEOUT) PREPAYCHARGEOUT , C.PREPAYCOMFEE PREPAYCOMFEE
      from (
            SELECT 	B.DBALUNITNO ,
            SUM(A.DEPOSITIN)/100.0  DEPOSITIN , SUM(A.DEPOSITOUT)/100.0      DEPOSITOUT ,
            SUM(A.PREPAYIN)/100.0        PREPAYIN ,
            SUM(A.PREPAYOUT)/100.0 PREPAYOUT , SUM(A.PREPAYCHARGEOUT)/100.0 PREPAYCHARGEOUT ,
            SUM(A.PREPAYCOMFEE)/100.0    PREPAYCOMFEE
            FROM TF_DEPTBALACC_BALANCE A,TF_DEPT_BALUNIT B
            WHERE  A.DBALUNITNO = B.DBALUNITNO
            AND   (P_VAR1 IS NULL OR P_VAR1 = '' OR TO_CHAR(A.ENDTIME,'YYYYMMDD') >= TO_CHAR((TO_DATE(P_VAR1,'YYYYMMDD')+1),'YYYYMMDD'))
            AND   (P_VAR2 IS NULL OR P_VAR2 = '' OR TO_CHAR(A.ENDTIME,'YYYYMMDD') <= TO_CHAR((TO_DATE(P_VAR2,'YYYYMMDD')+1),'YYYYMMDD'))
            AND   (P_VAR3 IS NULL OR P_VAR3 = '' OR A.DBALUNITNO = P_VAR3)
            GROUP BY B.DBALUNITNO
        ) C 
        inner join 
        (
            select E.DBALUNITNO ,E.DEPOSIT,E.ENDTIME ,E.PREPAY, F.DBALUNIT from
            (
                select T1.DBALUNITNO ,(T1.DEPOSIT)/100.0 DEPOSIT,(T1.PREPAY)/100.0 PREPAY ,T1.ENDTIME FROM 
                (
                     select * from TF_DEPTBALACC_BALANCE T where 
                      (P_VAR1 IS NULL OR P_VAR1 = '' OR TO_CHAR(T.ENDTIME,'YYYYMMDD') >= TO_CHAR((TO_DATE(P_VAR1,'YYYYMMDD')+1),'YYYYMMDD'))
                      AND   (P_VAR2 IS NULL OR P_VAR2 = '' OR TO_CHAR(T.ENDTIME,'YYYYMMDD') <= TO_CHAR((TO_DATE(P_VAR2,'YYYYMMDD')+1),'YYYYMMDD'))
                      AND   (P_VAR3 IS NULL OR P_VAR3 = '' OR T.DBALUNITNO = P_VAR3)
                
                ) T1 
                where ENDTIME = 
                (
                    select  max(ENDTIME) FROM 
                    (
                          select * from TF_DEPTBALACC_BALANCE T where 
                          (P_VAR1 IS NULL OR P_VAR1 = '' OR TO_CHAR(T.ENDTIME,'YYYYMMDD') >= TO_CHAR((TO_DATE(P_VAR1,'YYYYMMDD')+1),'YYYYMMDD'))
                          AND   (P_VAR2 IS NULL OR P_VAR2 = '' OR TO_CHAR(T.ENDTIME,'YYYYMMDD') <= TO_CHAR((TO_DATE(P_VAR2,'YYYYMMDD')+1),'YYYYMMDD'))
                          AND   (P_VAR3 IS NULL OR P_VAR3 = '' OR T.DBALUNITNO = P_VAR3)
                    
                    ) T2  WHERE  T1.DBALUNITNO = T2.DBALUNITNO
                )   
            ) E 
            inner join TF_DEPT_BALUNIT F on E.DBALUNITNO = F.DBALUNITNO
        ) D
        on  C.DBALUNITNO = D.DBALUNITNO
        left join
        (
            select E.DBALUNITNO ,E.DEPOSIT PREDEPOSIT,E.ENDTIME ,E.PREPAY PREPREPAY, F.DBALUNIT from
            (
                select T1.DBALUNITNO ,(T1.DEPOSIT)/100.0 DEPOSIT,(T1.PREPAY)/100.0 PREPAY ,T1.ENDTIME FROM 
                (
                     select * from TF_DEPTBALACC_BALANCE T where 
                      (P_VAR1 IS NULL OR P_VAR1 = '' OR TO_CHAR(T.ENDTIME,'YYYYMMDD') < TO_CHAR((TO_DATE(P_VAR1,'YYYYMMDD')+1),'YYYYMMDD'))
                      AND   (P_VAR3 IS NULL OR P_VAR3 = '' OR T.DBALUNITNO = P_VAR3)
                
                ) T1 
                where ENDTIME = 
                (
                    select  max(ENDTIME) FROM 
                    (
                          select * from TF_DEPTBALACC_BALANCE T where 
                          (P_VAR1 IS NULL OR P_VAR1 = '' OR TO_CHAR(T.ENDTIME,'YYYYMMDD') < TO_CHAR((TO_DATE(P_VAR1,'YYYYMMDD')+1),'YYYYMMDD'))
                          AND   (P_VAR3 IS NULL OR P_VAR3 = '' OR T.DBALUNITNO = P_VAR3)
                    
                    ) T2  WHERE  T1.DBALUNITNO = T2.DBALUNITNO
                )   
            ) E 
            inner join TF_DEPT_BALUNIT F on E.DBALUNITNO = F.DBALUNITNO
        )  P
        on C.DBALUNITNO = P.DBALUNITNO
        order by D.DBALUNITNO;
    end;

    elsif p_funcCode = 'DeptBalTradePrepay' then   --预付款转账日报
    begin
    open  p_cursor for
    select T.DBALUNITNO ,T.DBALUNIT,T.BANK,T.BANKACCNO,ABS(sum(T.CURRENTMONEY)/100.0) PREPAYCHARGEOUT,
    T.OPERATEDATE  from 
    (
        SELECT    B.DBALUNITNO    , B.DBALUNIT    , C.BANK    , B.BANKACCNO    ,
        CURRENTMONEY, TO_CHAR(A.OPERATETIME,'YYYYMMDD') OPERATEDATE
        FROM TF_B_DEPTACCTRADE A,TF_DEPT_BALUNIT B,TD_M_BANK C
        WHERE A.DBALUNITNO = B.DBALUNITNO
        AND   B.BANKCODE = C.BANKCODE
        AND   A.TRADETYPECODE in ('21','A2')
        AND   (P_VAR1 IS NULL OR P_VAR1 = '' OR TO_CHAR(A.OPERATETIME,'YYYYMMDD') >= P_VAR1)
        AND   (P_VAR2 IS NULL OR P_VAR2 = '' OR TO_CHAR(A.OPERATETIME,'YYYYMMDD') <= P_VAR2)
        AND   (P_VAR3 IS NULL OR P_VAR3 = '' OR A.DBALUNITNO = P_VAR3)
     ) T
        GROUP BY T.DBALUNITNO , T.DBALUNIT , T.BANK , T.BANKACCNO , T.OPERATEDATE
        ORDER BY OPERATEDATE DESC;
      end;
	 
	 elsif p_funcCode = 'QueryPrepayTrade' then --预付款交易明细
     open p_cursor for
		SELECT B.TRADEID,
		 DECODE(B.TRADETYPECODE, '11', '缴纳', '12','支取', '21', '业务抵扣', 'A2', '抵扣返销',   
			B.TRADETYPECODE) TRADETYPECODE,
		 D.DBALUNIT,
			 B.CURRENTMONEY/100.0 AS CURRENTMONEY,
			 B.PREMONEY/100.0 AS PREMONEY,
			 B.NEXTMONEY/100.0 AS NEXTMONEY,
			 S.STAFFNAME,B.OPERATETIME,
		 DECODE(B.CANCELTAG, '0', '未回退', '1','已回退',
			B.CANCELTAG) CANCELTAG,
			T.CARDNO , P.TRADETYPE 
		FROM TF_B_DEPTACCTRADE B,TF_DEPT_BALUNIT D,TD_M_INSIDESTAFF S ,TF_B_TRADE T,TD_M_TRADETYPE P
		WHERE B.DBALUNITNO=D.DBALUNITNO(+)
		AND B.OPERATESTAFFNO=S.STAFFNO(+)
		AND B.TRADEID=T.TRADEID(+)
		AND T.TRADETYPECODE=P.TRADETYPECODE(+)
		AND B.OPERATETIME >= TO_DATE(P_VAR1||'000000','YYYYMMDDHH24MISS')
			AND B.OPERATETIME <= TO_DATE(P_VAR2||'235959','YYYYMMDDHH24MISS')
		AND   (P_VAR3 IS NULL OR P_VAR3 = '' OR B.DBALUNITNO = P_VAR3)
		AND B.TRADETYPECODE IN ('11','12','21','A2')
		ORDER BY B.DBALUNITNO, B.OPERATETIME DESC;
end if;
end;


/

show errors

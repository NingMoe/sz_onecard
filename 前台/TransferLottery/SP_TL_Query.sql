create or replace procedure SP_TL_Query
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
      if p_funcCode = 'QUERY_LOTTERYTASK' then         --查询抽奖任务(准备数据完成)
          open p_cursor for
          SELECT LOTTERYPERIOD,PREPARESTATE,LOTTERYSTATE FROM TF_TT_LOTTERYTASK WHERE LOTTERYPERIOD = P_VAR1 AND PREPARESTATE = '1';
      elsif p_funcCode = 'QUERY_LOTTERYTASKALL' then           --查询抽奖任务(全部抽奖完成)
          open p_cursor for
          SELECT LOTTERYPERIOD FROM (SELECT rownum,LOTTERYPERIOD  
          FROM TF_TT_LOTTERYTASK WHERE PREPARESTATE = '1' AND (p_var1 IS NULL OR p_var1 = LOTTERYSTATE) ORDER BY LOTTERYPERIOD DESC
          ) where rownum <=13;
      elsif p_funcCode = 'QUERY_WINNERLIST' then         --查询中奖名单
          open p_cursor for
          SELECT NVL(SOCIALNO,CARDNO) CARDNO,STATES  FROM TF_TT_WINNERLIST WHERE LOTTERYPERIOD = P_VAR1 AND AWARDS = P_VAR2;
      elsif p_funcCode = 'QUERY_LOTTERYDAY' then         --查询抽奖日期
          open p_cursor for
          SELECT TAGVALUE FROM TD_M_TAG WHERE TAGCODE = 'LOTTERYDAY';
	  elsif p_funcCode = 'QUERY_CARDNO' THEN  --社保编号查电子钱包卡号
		  open p_cursor for
          SELECT CARDNO  FROM TF_F_RESIDENTCARD@www.smk.com T WHERE T.SOCLSECNO = P_VAR1;
      elsif p_funcCode = 'QUERY_AWARDS' then         --查询中奖信息
	  BEGIN   
		  IF SUBSTR(P_VAR1,1,4) = '2150' THEN 
			  BEGIN
				open p_cursor for
				--电子钱包卡号
				SELECT W.CARDNO,DECODE(W.CARDTYPECODE,'0','电子钱包卡','1','轻轨计次卡') CARDTYPE, W.CARDTYPECODE,W.LOTTERYPERIOD,AWARDSNAME,BONUS/100 BONUS,C.CUSTNAME,DECODE(CR.USETAG,'0','无效卡','1','有效卡')	CARDSTATE,BONUS/400 TAX																																									
				FROM TF_TT_WINNERLIST W																																												
				INNER JOIN TF_TT_LOTTERYTASK T ON W.LOTTERYPERIOD = T.LOTTERYPERIOD		
				INNER JOIN TD_M_AWARDS A ON W.AWARDS = A.AWARDSCODE																																										
				LEFT JOIN TF_F_CUSTOMERREC C ON W.CARDTYPECODE = '0' AND W.CARDNO = C.CARDNO 																																												
				LEFT JOIN TF_F_CARDREC CR ON W.CARDTYPECODE = '0' AND CR.CARDNO = W.CARDNO
				WHERE W.CARDNO = P_VAR1 
				AND W.STATES = 0 AND W.AWARDS != '0' 
				AND TO_DATE(T.LOTTERYPERIOD,'YYYYMM')  >=  add_months(sysdate,-13) 
				UNION 
				SELECT W.CARDNO,DECODE(W.CARDTYPECODE,'0','电子钱包卡','1','轻轨计次卡') CARDTYPE, W.CARDTYPECODE,W.LOTTERYPERIOD,AWARDSNAME,BONUS/100 BONUS,C.CUSTNAME,DECODE(CR.USETAG,'0','无效卡','1','有效卡')	CARDSTATE,BONUS/400 TAX																																										
				FROM TF_TT_WINNERLIST W		
				INNER JOIN (SELECT OLDCARDNO
						  FROM (select OLDCARDNO, cardno
								  from TF_B_TRADE
								 WHERE TRADETYPECODE IN ('03','54')
								   AND CANCELTAG = '0'
								   AND OLDCARDNO IS NOT NULL) t
						 START WITH CARDNO = P_VAR1
						CONNECT BY PRIOR OLDCARDNO = CARDNO) O ON W.CARDNO = O.OLDCARDNO
				INNER JOIN TF_TT_LOTTERYTASK T ON W.LOTTERYPERIOD = T.LOTTERYPERIOD		
				INNER JOIN TD_M_AWARDS A ON W.AWARDS = A.AWARDSCODE																																										
				LEFT JOIN TF_F_CUSTOMERREC C ON W.CARDTYPECODE = '0' AND W.CARDNO = C.CARDNO 																																												
				LEFT JOIN TF_F_CARDREC CR ON W.CARDTYPECODE = '0' AND CR.CARDNO = W.CARDNO
				WHERE  W.STATES = 0 AND W.AWARDS != '0' 
				AND TO_DATE(T.LOTTERYPERIOD,'YYYYMM')  >=  add_months(sysdate,-13);	
			  END;
		  ELSE
		   --轻轨卡号
			open p_cursor for
			SELECT W.CARDNO,DECODE(W.CARDTYPECODE,'0','电子钱包卡','1','轻轨计次卡') CARDTYPE, W.CARDTYPECODE,W.LOTTERYPERIOD,AWARDSNAME,BONUS/100 BONUS,C.CUSTNAME,DECODE(CR.USETAG,'0','无效卡','1','有效卡')	CARDSTATE,BONUS/400 TAX																																										
			FROM TF_TT_WINNERLIST W																																												
			INNER JOIN TF_TT_LOTTERYTASK T ON W.LOTTERYPERIOD = T.LOTTERYPERIOD		
			INNER JOIN TD_M_AWARDS A ON W.AWARDS = A.AWARDSCODE																																										
			LEFT JOIN TF_F_CUSTOMERREC C ON W.CARDTYPECODE = '0' AND W.CARDNO = C.CARDNO 																																												
			LEFT JOIN TF_F_CARDREC CR ON W.CARDTYPECODE = '0' AND CR.CARDNO = W.CARDNO
			WHERE W.CARDNO = P_VAR1 
			AND W.STATES = 0 AND W.AWARDS != '0' 
			AND TO_DATE(T.LOTTERYPERIOD,'YYYYMM')  >=  add_months(sysdate,-13);	 
		  END IF;
		  
        END;	
		elsif p_funcCode = 'QUERY_SPECIALAWARDS' then         --查询特等奖中奖信息
		BEGIN   
		  IF SUBSTR(P_VAR1,1,4) = '2150' THEN 
			  BEGIN
				open p_cursor for
				--电子钱包卡号
				SELECT  W.CARDNO,W.LOTTERYPERIOD																																									
				FROM TF_TT_WINNERLIST W																																												
				INNER JOIN TF_TT_LOTTERYTASK T ON W.LOTTERYPERIOD = T.LOTTERYPERIOD		 		 
				WHERE W.CARDNO = P_VAR1 
				AND W.STATES = 0 AND W.AWARDS = '0' 
				AND TO_DATE(T.LOTTERYPERIOD,'YYYYMM')  >=  add_months(sysdate,-13) 
				UNION 
				SELECT W.CARDNO,W.LOTTERYPERIOD																																												
				FROM TF_TT_WINNERLIST W		
				INNER JOIN (SELECT OLDCARDNO
						  FROM (select OLDCARDNO, cardno
								  from TF_B_TRADE
								 WHERE TRADETYPECODE IN ('03','54')
								   AND CANCELTAG = '0'
								   AND OLDCARDNO IS NOT NULL) t
						 START WITH CARDNO = P_VAR1
						CONNECT BY PRIOR OLDCARDNO = CARDNO) O ON W.CARDNO = O.OLDCARDNO
				INNER JOIN TF_TT_LOTTERYTASK T ON W.LOTTERYPERIOD = T.LOTTERYPERIOD		
				INNER JOIN TD_M_AWARDS A ON W.AWARDS = A.AWARDSCODE		 
				WHERE  W.STATES = 0 AND W.AWARDS = '0' 
				AND TO_DATE(T.LOTTERYPERIOD,'YYYYMM')  >=  add_months(sysdate,-13);	
			  END;
		  ELSE
		   --轻轨卡号
			open p_cursor for
			SELECT W.CARDNO,W.LOTTERYPERIOD																																							
			FROM TF_TT_WINNERLIST W																																												
			INNER JOIN TF_TT_LOTTERYTASK T ON W.LOTTERYPERIOD = T.LOTTERYPERIOD		
			INNER JOIN TD_M_AWARDS A ON W.AWARDS = A.AWARDSCODE																																										
			LEFT JOIN TF_F_CUSTOMERREC C ON W.CARDTYPECODE = '0' AND W.CARDNO = C.CARDNO 																																												
			LEFT JOIN TF_F_CARDREC CR ON W.CARDTYPECODE = '0' AND CR.CARDNO = W.CARDNO
			WHERE W.CARDNO = P_VAR1 
			AND W.STATES = 0 AND W.AWARDS = '0' 
			AND TO_DATE(T.LOTTERYPERIOD,'YYYYMM')  >=  add_months(sysdate,-13);	 
		  END IF; 
        END;	
		elsif p_funcCode = 'QUERY_CUSTOMERINFO' then         --查询专有帐户客户信息
					 open p_cursor for
					 SELECT CU.ICCARD_NO,PAPER_TYPE_CODE,PAPER_NO,CUST_NAME,CUST_SEX,CUST_PHONE																										
					 FROM TF_F_CUST CU  																										
					 INNER JOIN TF_F_CUST_ACCT A ON A.CUST_ID = CU.CUST_ID																										
					 WHERE A.ICCARD_NO = P_VAR1  AND A.ACCT_TYPE_NO = '0001';		
		 elsif p_funcCode = 'QUERY_LOTTERY' then         --查询奖期信息(不计算特等奖)
		 			open p_cursor for
		 			SELECT L.LOTTERYPERIOD 奖期,SUM(CASE WHEN w.STATES = 1 THEN 1 ELSE 0 END) 领奖数,SUM(CASE WHEN w.STATES = 1 THEN A.BONUS ELSE 0 END)/100 领奖额,
					SUM(CASE WHEN w.STATES = 0 THEN 1 ELSE 0 END) 未领奖数,SUM(CASE WHEN w.STATES = 0 THEN A.BONUS ELSE 0 END)/100 未领奖额
					FROM TF_TT_LOTTERYTASK L
					INNER JOIN TF_TT_WINNERLIST W ON L.LOTTERYPERIOD = W.LOTTERYPERIOD
					INNER JOIN TD_M_AWARDS A ON W.AWARDS = AWARDSCODE
					WHERE W.AWARDS != '0'
					GROUP BY L.LOTTERYPERIOD order by L.LOTTERYPERIOD desc;
		elsif p_funcCode = 'QUERY_AWARDSTRADE' then         --查询领奖台帐			
					open p_cursor for															
					SELECT CARDNO 中奖卡号,DECODE(CARDTYPECODE,'0','电子钱包卡','1','轻轨计次卡') 中奖卡号类型,DECODE(AWARDTYPE,'0','充值领奖','1','充值卡领奖') 领奖类型,
					AWARDCARDNO 领奖卡号,CHARGECARDNO 充值卡卡号,CHARGEMONEY/100 领奖金额,OPERATETIME 领奖时间,
					S.STAFFNO || ':' || S.STAFFNAME 操作员工,D.DEPARTNO || ':' || D.DEPARTNAME 操作部门
					FROM TF_B_AWARDS A
					INNER JOIN TD_M_INSIDESTAFF S ON A.OPERATESTAFFNO = S.STAFFNO
					INNER JOIN TD_M_INSIDEDEPART D ON A.OPERATEDEPARTID = D.DEPARTNO
					WHERE( p_var1 is null or p_var1 = '' or to_char(a.OPERATETIME,'yyyymmdd') >= to_char((to_date(p_var1,'yyyymmdd')),'yyyymmdd'))
					 AND ( p_var2 is null or p_var2 = '' or to_char(a.OPERATETIME,'yyyymmdd') <= to_char((to_date(p_var2,'yyyymmdd')),'yyyymmdd'))
					 AND ( p_var3 is null or p_var3 = '' or p_var3 = a.AWARDTYPE)
					 AND ( p_var4 is null or p_var4 = '' or p_var4 = a.OPERATEDEPARTID)
					 order by  OPERATETIME desc;
	     elsif p_funcCode = 'QUERY_LOTTERYDATA' then         --查询抽奖资格
					open p_cursor for
					SELECT CARDNO 卡号,DECODE(CARDTYPECODE,'0','电子钱包卡','1','轻轨计次卡') 卡类型,TRANSFERTIMES 换乘次数,MARK 抽奖标识
					FROM TF_TT_LOTTERYDATA
					WHERE ( p_var1 is null or p_var1 = '' or p_var1 = LOTTERYPERIOD)
					 AND ( p_var2 is null or p_var2 = '' or (p_var2 = CARDNO or p_var2 = SOCIALNO));
	    elsif p_funcCode = 'DOWNLOAD_LOTTERYDATA' then         --下载奖池
					open p_cursor for
					SELECT LOTTERYDATAFILE
					FROM TF_TT_LOTTERYTASK
					WHERE p_var1 = LOTTERYPERIOD ;
			elsif p_funcCode = 'QUERY_AWARDSHISTORY' then         --领奖历史记录查询
					 open p_cursor for
           SELECT  K.CARDNO,K.CARDTYPECODE,K.AWARDTYPE,K.AWARDCARDNO,K.CHARGECARDNO,K.OPERATETIME,K.CHARGEMONEY/100 MONEY,F.AWARDSNAME,K.CHARGEMONEY/400 TAX,
           K.OPERATEDEPARTID|| ':' || D.DEPARTNAME OPERATEDEPART ,K.NAME,K.PAPERTYPECODE||':'||E.PAPERTYPENAME PAPERTYPE,K.PAPERNO,K.TEL,K.LOTTERYPERIOD
           FROM TF_B_AWARDS K,TF_TT_WINNERLIST T,TD_M_INSIDEDEPART D,TD_M_PAPERTYPE E,TD_M_AWARDS F
           WHERE K.CARDNO=T.CARDNO
           AND K.LOTTERYPERIOD=T.LOTTERYPERIOD
           AND T.STATES='1'
           AND T.AWARDS=F.AWARDSCODE
           AND K.OPERATEDEPARTID=D.DEPARTNO
           AND K.PAPERTYPECODE=E.PAPERTYPECODE
           AND p_var1 = K.CARDNO ;	
      elsif p_funcCode = 'QUERY_WINNERLISTLOAD' then  --下载中奖名单
           open p_cursor for
           SELECT NVL(t.SOCIALNO,t.CARDNO) CARDNO,a.AWARDSNAME  
           FROM TF_TT_WINNERLIST t,TD_M_AWARDS a 
           WHERE t.awards=a.awardscode
           and t. LOTTERYPERIOD = P_VAR1
           order by t.awards ;	
     elsif p_funcCode = 'QUERY_AWARDSTRADETAX' then --领奖明细页面导出税
          open p_cursor for
          SELECT K.CARDNO 中奖卡号,K.NAME 姓名,K.PAPERNO 证件号码,K.TEL 手机号码,K.CHARGEMONEY/100+K.CHARGEMONEY/400 中奖金额,K.CHARGEMONEY/400 应納税额,K.CHARGEMONEY/100 实得金额
          FROM TF_B_AWARDS K
          WHERE ( p_var1 is null or p_var1 = '' or to_char(K.OPERATETIME,'yyyymmdd') >= to_char((to_date(p_var1,'yyyymmdd')),'yyyymmdd'))
          AND ( p_var2 is null or p_var2 = '' or to_char(K.OPERATETIME,'yyyymmdd') <= to_char((to_date(p_var2,'yyyymmdd')),'yyyymmdd'))
          AND ( p_var3 is null or p_var3 = '' or p_var3 = K.AWARDTYPE)
          AND ( p_var4 is null or p_var4 = '' or p_var4 = K.OPERATEDEPARTID)
          order by  OPERATETIME desc;
      	elsif p_funcCode = 'QUERY_ISBLOCK' then --查询中奖卡是否办理过挂失卡转值
          open p_cursor for
			SELECT CARDNO
			  FROM (select OLDCARDNO, cardno
					  from TF_B_TRADE
					 WHERE TRADETYPECODE = '8W'
					   AND CANCELTAG = '0'
					   AND OLDCARDNO IS NOT NULL) t
			 START WITH OLDCARDNO = p_var1
			CONNECT BY PRIOR  CARDNO = OLDCARDNO
			ORDER BY LEVEL DESC;
			elsif p_funcCode = 'QUERY_CARDWINNERINFO' then ---查询卡号有效中奖信息
         open p_cursor for
         SELECT a.AWARDSNAME FROM TF_TT_WINNERLIST t,TD_M_AWARDS a WHERE t.awards=a.awardscode and t.states='0' 
         and t.AWARDS != '0' and TO_DATE(T.LOTTERYPERIOD,'YYYYMM')  >=  add_months(sysdate,-13)
         and t.CARDNO = P_VAR1;
  end if;
end;


/
show errors
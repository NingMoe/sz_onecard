create or replace procedure SP_FI_UPDATECARDSTATTWO
(
    P_MONTH              CHAR    ,
    P_retCode            OUT INT ,
    P_retMsg             OUT VARCHAR2
)
AS
    v1        int := 0;
    v2        int := 0;
    v3        int := 0;
    v4        int := 0;
    v5        int := 0;
    v6        int := 0;
    v7        int := 0;
    v8        int := 0;
    v9        int := 0;
    
    v11        int := 0;
    v12        int := 0;
    v13        int := 0;
    v14        int := 0;
    v15        int := 0;
    v16        int := 0;
    v17        int := 0;
    v18        int := 0;
    v19        int := 0;    

    v_count   number(2):=1;
    v_c       SYS_REFCURSOR;
    v_year    varchar2(4);
    v_month   varchar2(2);
BEGIN
    v_year  := substr(P_MONTH,1,4);
	  v_month := substr(P_MONTH,5,2);


		
	  --除苏州通卡，各卡求和
	  select 
	      sum(nvl(TOTALNUM,0)) , sum(nvl(YEARNUM,0)) , sum(nvl(MONTHNUM,0)) , 
		    sum(nvl(CONSUMENUM,0)) , sum(nvl(UNCONSUNMENUM,0)) , sum(nvl(DEPOSITMONEY,0)) , 
		    sum(nvl(MONTHPAYMONEY,0)) , sum(nvl(YEARPAYMONEY,0)) , sum(nvl(TOTALPAYMONEY,0))
		into
		    v1,v2,v3,v4,v5,v6,v7,v8,v9
		from  TF_MONTHCARDSTAT
		where STATTIME = P_MONTH
		and   CARDID in('215005','215006','215013','215031','215016','215021','215022');
		
		select 
			  sum(nvl(TOTALNUM,0)) , sum(nvl(YEARNUM,0)) , sum(nvl(MONTHNUM,0)) , 
		    sum(nvl(CONSUMENUM,0)) , sum(nvl(UNCONSUNMENUM,0)) , sum(nvl(DEPOSITMONEY,0)) , 
		    sum(nvl(MONTHPAYMONEY,0)) , sum(nvl(YEARPAYMONEY,0)) , sum(nvl(TOTALPAYMONEY,0))
		into
		    v11,v12,v13,v14,v15,v16,v17,v18,v19		    
    from  TF_MONTHCARDSTAT
		where STATTIME = P_MONTH
		and   CARDID = '215033'	    ;
		
		--更新苏州通卡
	  UPDATE TF_MONTHCARDSTAT 
		SET    TOTALNUM      = v11    - v1  ,
		       YEARNUM       = v12    - v2  ,
		       MONTHNUM      = v13    - v3  ,
		       CONSUMENUM    = v14    - v4  ,
		       UNCONSUNMENUM = v15    - v5  ,
		       MONTHPAYMONEY = v17    - v7  ,		       
		       YEARPAYMONEY  = v18		- v8  ,     
		       TOTALPAYMONEY = v19    - v9  
		WHERE  STATTIME = P_MONTH
		AND    CARDID   = '215001';
		
		P_retCode := 0;
    P_retMsg  := 'OK';
    
EXCEPTION WHEN OTHERS THEN    
    p_retCode := SQLCODE;
    p_retMsg  := SQLERRM;
    ROLLBACK;RETURN;   		
END;		
/
show errors
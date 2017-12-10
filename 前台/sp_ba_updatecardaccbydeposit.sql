create or replace procedure SP_BA_UpdateCardAccByDeposit
(  p_retCode        out  int     ,
   p_retMsg         out  varchar2,
   p_rightProcTable      varchar2
) as
    v_c          SYS_REFCURSOR;
	v_chID    varchar2(50);
    v_id         TP_TRADE_RIGHT_C1.ID%type;
    v_cardno     TP_TRADE_RIGHT_C1.CARDNO%type;
    v_trademoney TP_TRADE_RIGHT_C1.TRADEMONEY%type;   
	v_tradedate date;
	v_tradeNO   TP_TRADE_RIGHT_C1.CARDTRADENO%type;
	v_accMoney   int;
begin
	v_accMoney := 0;
    open v_c for '
        select id,cardno,trademoney,to_date( TRADEDATE || TRADETIME , ''YYYYMMDDHH24MISS'' ),CARDTRADENO
        from   ' || p_rightProcTable || '
        where  ictradetypecode = ''06''
    ';

    loop
        fetch v_c into v_id,v_cardno,v_trademoney,v_tradedate,v_tradeNO;

        exit when v_c%NOTFOUND;

        -- 更改卡资料表 服务费收取标志和卡押金
        update tf_f_cardrec
        set    serstaketag = '6',
               deposit    = deposit - v_trademoney
        where  serstaketag = '5'
        and    cardno     =  v_cardno ;

        -- 如果没有更新到，认为该消费记录为错单，
        -- 从当日正常清单表搬到当日异常清单表
        if  SQL%ROWCOUNT != 1 then
            insert into tm_trade_error (
                ID              ,   CARDNO      ,   RECTYPE     ,   ICTRADETYPECODE ,
                ASN             ,   CARDTRADENO ,   SAMNO       ,   PSAMVERNO       ,
                POSNO           ,   POSTRADENO  ,   TRADEDATE   ,   TRADETIME       ,
                PREMONEY        ,   TRADEMONEY  ,   SMONEY      ,   BALUNITNO       ,
                CALLINGNO       ,   CORPNO      ,   DEPARTNO    ,   CALLINGSTAFFNO  ,
                CITYNO          ,   TAC         ,   TACSTATE    ,   MAC             ,
                SOURCEID        ,   BATCHNO     ,   DEALTIME    ,   ERRORREASONCODE ,
                DEALSTATECODE   ,   INLISTTIME  ,   MOVESTATE   ,   CHNLTYPE        ,
                RSRVCHAR
            ) select
                ID              ,   CARDNO      ,   RECTYPE     ,   ICTRADETYPECODE ,
                ASN             ,   CARDTRADENO ,   SAMNO       ,   PSAMVERNO       ,
                POSNO           ,   POSTRADENO  ,   TRADEDATE   ,   TRADETIME       ,
                PREMONEY        ,   TRADEMONEY  ,   SMONEY      ,   BALUNITNO       ,
                CALLINGNO       ,   CORPNO      ,   DEPARTNO    ,   CALLINGSTAFFNO  ,
                CITYNO          ,   TAC         ,   TACSTATE    ,   MAC             ,
                SOURCEID        ,   BATCHNO     ,   DEALTIME    ,   'E'             ,
                '0'             ,   sysdate     ,   MOVESTATE   ,   CHNLTYPE        ,
                RSRVCHAR
            from tm_trade_right
            where id = v_id;

            delete from tm_trade_right where id = v_id;
            v_chID := v_id;
      EXECUTE IMMEDIATE 'delete from ' ||  p_rightProcTable || ' where id = ' ||  '''' || trim(v_chID) || ''''  ;
      
       else
            -- 否则更新电子钱包账户余额、总消费金额、总消费次数
            update tf_f_cardewalletacc
            set    totalconsumetimes = totalconsumetimes + 1,
                   totalconsumemoney = totalconsumemoney + v_trademoney,
                   cardaccmoney      = cardaccmoney      - v_trademoney
            where  cardno = v_cardno;
                        --记录电子钱包的余额变动表
       begin
             select cardaccmoney into 
             v_accMoney
            from   tf_f_cardewalletacc acc
            where  acc.cardno = v_cardno;
      
        INSERT INTO TF_BALANCE_TRADE
            (TRADEID,CARDNO,TRADETYPE,CARDTRADENO,
             BFBALANCE,TRADEMONEY,AFTBALANCE,TRADETIME,
            INLISTTIME)
          values(v_id, v_cardno, 'ZA',  v_tradeNO,  
             v_accMoney +  v_trademoney , v_trademoney,  v_accMoney , v_tradedate,
            sysdate); --这里的ZA暂时代表的是消费
          
        EXCEPTION WHEN OTHERS THEN
          p_retCode := 0;
      END;         
        end if;

    end loop;

    p_retCode := 0;
    p_retMsg  := 'OK';

    close v_c;

exception when others then
    p_retCode := SQLCODE;
    p_retMsg  := 'PROC ERROR: ' || SQLERRM;

    close v_c;

end;



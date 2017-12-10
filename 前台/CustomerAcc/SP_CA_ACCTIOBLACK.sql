create or replace procedure SP_CA_ACCTIOBLACK
(
    p_funcCode     varchar2 , --业务类型
    p_cardno       char     , --卡号
    
    p_currOper     char     , --当前操作者
    p_currDept     char     , --当前操作者部门
    p_retCode  out char     , --错误编码
    p_retMsg   out varchar2   --错误信息
)
AS
    v_funcCode        varchar2(16) := p_funcCode ;
    v_today           date         := sysdate    ;
    v_state           varchar2(2) ;
    v_seq             CHAR(16)    ;
    v_ex              EXCEPTION   ;

BEGIN

	   IF v_funcCode = 'ACCTINTOBLACK' THEN --专有账户入黑名单，账户冻结
         --专有账户是否已经被冻结
         select nvl((select STATE from TF_F_CUST_ACCT where ICCARD_NO = p_cardno),'') into v_state from dual;

         --如果账户存在并且没有被冻结
         if v_state is not null and v_state != 'B' then
         
         --备份客户账户历史表
         BEGIN
             INSERT INTO TF_F_CUST_ACCT_HIS(
             ICCARD_NO            , ACCT_ID               , CUST_ID              , ACCT_NAME             ,
             STATE                , STATE_DATE            , CREATE_DATE          , EFF_DATE              ,
             ACCT_PAYMENT_TYPE    , ACCT_BALANCE          , REL_BALANCE          , 
             CUST_PASSWORD        , TOTAL_CONSUME_TIMES   , TOTAL_SUPPLY_TIMES   , TOTAL_CONSUME_MONEY   ,
             TOTAL_SUPPLY_MONEY   , LAST_CONSUME_TIME     , LAST_SUPPLY_TIME     , LIMIT_DAYAMOUNT       ,
             AMOUNT_TODAY         , LIMIT_EACHTIME        , CODEERRORTIMES       , 
             BAK_DATE
             )SELECT 
             ICCARD_NO            , ACCT_ID               , CUST_ID              , ACCT_NAME             ,
             STATE                , STATE_DATE            , CREATE_DATE          , EFF_DATE              ,
             ACCT_PAYMENT_TYPE    , ACCT_BALANCE          , REL_BALANCE          ,  
             CUST_PASSWORD        , TOTAL_CONSUME_TIMES   , TOTAL_SUPPLY_TIMES   , TOTAL_CONSUME_MONEY   , 
             TOTAL_SUPPLY_MONEY   , LAST_CONSUME_TIME     , LAST_SUPPLY_TIME     , LIMIT_DAYAMOUNT       ,
	           AMOUNT_TODAY         , LIMIT_EACHTIME        , CODEERRORTIMES       , 
             v_today
             FROM  TF_F_CUST_ACCT 
             WHERE ICCARD_NO = p_cardno;

         EXCEPTION
             WHEN OTHERS THEN
             P_RETCODE := 'S006001124';
             P_RETMSG  := '写入客户账户历史表失败' || SQLERRM;
             ROLLBACK; RETURN;
         END;
                   
         --更新客户账户表状态
         BEGIN
             UPDATE  TF_F_CUST_ACCT 
             SET     STATE = 'B' 
             WHERE   ICCARD_NO = p_cardno;
             
             IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
         EXCEPTION
             WHEN OTHERS THEN
             P_RETCODE := 'S006001123';
             P_RETMSG  := '更新客户账户表失败' || SQLERRM;
             ROLLBACK; RETURN;
         END;
         
         --更新余额账本表状态
         BEGIN
             UPDATE  TF_F_ACCT_BALANCE
             SET     STATE = 'B'
             WHERE   ICCARD_NO = p_cardno;

             IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
         EXCEPTION
             WHEN OTHERS THEN
             P_RETCODE := 'A099001102';
             P_RETMSG  := '更新余额账本表失败' || SQLERRM;
             ROLLBACK; RETURN;
         END;
         
         --记录业务主台帐
         BEGIN
              SP_GETSEQ(SEQ => V_SEQ);

             INSERT INTO TF_B_TRADE(
                   TRADEID       , CARDNO         , TRADETYPECODE    , ASN          , 
                   CARDTYPECODE  , OPERATESTAFFNO , OPERATEDEPARTID  , OPERATETIME
            )SELECT    
                  V_SEQ          , CARDNO         , '8M'               , ASN          ,
                  CARDTYPECODE   , p_currOper     , p_currDept       , v_today
             FROM TF_F_CARDREC
             WHERE CARDNO = P_CARDNO;

         EXCEPTION
             WHEN OTHERS THEN
             P_RETCODE := 'A099001103';
             P_RETMSG  := '记录业务主台账表失败' || SQLERRM;
             ROLLBACK; RETURN;
         END;

        end if;
         
     END IF;
     
     IF v_funcCode = 'ACCTOUTBLACK' THEN --专有账户出黑名单，账户状态还原
     
         --获取账户冻结前状态
         select   nvl((
         select   STATE 
         from(
         select   STATE 
         from     TF_F_CUST_ACCT_HIS 
         where    iccard_no = p_cardno
         order by bak_date desc)
         where    rownum <= 1),'') 
         into     v_state 
         from     dual;
         
         --如果最近历史表状态不为空，专有账户还原冻结前状态
         if v_state is not null then
         
             --备份客户账户历史表
             BEGIN
                 INSERT INTO TF_F_CUST_ACCT_HIS(
                 ICCARD_NO            , ACCT_ID               , CUST_ID              , ACCT_NAME             ,
                 STATE                , STATE_DATE            , CREATE_DATE          , EFF_DATE              ,
                 ACCT_PAYMENT_TYPE    , ACCT_BALANCE          , REL_BALANCE          , 
                 CUST_PASSWORD        , TOTAL_CONSUME_TIMES   , TOTAL_SUPPLY_TIMES   , TOTAL_CONSUME_MONEY   ,
                 TOTAL_SUPPLY_MONEY   , LAST_CONSUME_TIME     , LAST_SUPPLY_TIME     , LIMIT_DAYAMOUNT       ,
                 AMOUNT_TODAY         , LIMIT_EACHTIME        , CODEERRORTIMES       , 
                 BAK_DATE
                 )SELECT 
                 ICCARD_NO            , ACCT_ID               , CUST_ID              , ACCT_NAME             ,
                 STATE                , STATE_DATE            , CREATE_DATE          , EFF_DATE              ,
                 ACCT_PAYMENT_TYPE    , ACCT_BALANCE          , REL_BALANCE          ,  
                 CUST_PASSWORD        , TOTAL_CONSUME_TIMES   , TOTAL_SUPPLY_TIMES   , TOTAL_CONSUME_MONEY   , 
                 TOTAL_SUPPLY_MONEY   , LAST_CONSUME_TIME     , LAST_SUPPLY_TIME     , LIMIT_DAYAMOUNT       ,
	               AMOUNT_TODAY         , LIMIT_EACHTIME        , CODEERRORTIMES       , 
                 v_today
                 FROM  TF_F_CUST_ACCT 
                 WHERE ICCARD_NO = p_cardno;

             EXCEPTION
                 WHEN OTHERS THEN
                 P_RETCODE := 'S006001124';
                 P_RETMSG  := '写入客户账户历史表失败' || SQLERRM;
                 ROLLBACK; RETURN;
             END;
             
             --还原客户账户表
             BEGIN
                 UPDATE  TF_F_CUST_ACCT 
                 SET     STATE = v_state 
                 WHERE   ICCARD_NO = p_cardno;
             
                 IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
             EXCEPTION
                 WHEN OTHERS THEN
                 P_RETCODE := 'S006001123';
                 P_RETMSG  := '更新客户账户表失败' || SQLERRM;
                 ROLLBACK; RETURN;
             END;
             
             --还原余额账本表
             BEGIN
                 UPDATE  TF_F_ACCT_BALANCE
                 SET     STATE = v_state
                 WHERE   ICCARD_NO = p_cardno;

                 IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
             EXCEPTION
                 WHEN OTHERS THEN
                 P_RETCODE := 'A099001102';
                 P_RETMSG  := '更新余额账本表失败' || SQLERRM;
                 ROLLBACK; RETURN;
             END;
             
             --记录业务主台帐
             BEGIN
                 SP_GETSEQ(SEQ => V_SEQ);

                 INSERT INTO TF_B_TRADE(
                       TRADEID       , CARDNO         , TRADETYPECODE    , ASN          , 
                       CARDTYPECODE  , OPERATESTAFFNO , OPERATEDEPARTID  , OPERATETIME
                )SELECT    
                       V_SEQ         , CARDNO         , '8N'               , ASN          ,
                       CARDTYPECODE  , p_currOper     , p_currDept       , v_today
                 FROM TF_F_CARDREC
                 WHERE CARDNO = P_CARDNO;

             EXCEPTION
                 WHEN OTHERS THEN
                 P_RETCODE := 'A099001103';
                 P_RETMSG  := '记录业务主台账表失败' || SQLERRM;
                 ROLLBACK; RETURN;
             END;
             
         else 
             P_RETCODE := 'S006001130';
         	   P_RETMSG  := '未找到最近客户历史表记录' || SQLERRM;
             ROLLBACK; RETURN;
         end if;
     
     END IF;
     
     p_retCode := '0000000000'; p_retMsg  := '成功';
     return;

END;
/
show errors
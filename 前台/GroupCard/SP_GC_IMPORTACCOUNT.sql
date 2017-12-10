CREATE OR REPLACE PROCEDURE SP_GC_IMPORTACCOUNT
(
    p_sessionID       char,
    P_OUTRETMSG       out varchar2,
    P_CURROPER        CHAR,
    P_CURRDEPT        CHAR,
    p_retCode         out char, -- Return Code
    p_retMsg          out varchar2  -- Return Message
)
AS
    v_seqNo           CHAR(16);
    V_TODAY           DATE:=SYSDATE;
    V_EX              EXCEPTION;
    v_CHECKID         char(16);
    V_RETMSG2         varchar2(30000);
    v_tradeDate       char(8);       --交易日期
    v_money           int;           --收入金额
    v_openBank        varchar2(100); --对方开户行
    v_accountName     varchar2(100); --对方开户名
    v_accountNumber   varchar2(20);  --对方账号
    v_explain         varchar2(200); --交易说明
    v_summary         varchar2(200); --交易摘要
    v_postScript      varchar2(200); --交易附言
    v_toAccountBank   varchar2(100); --到账银行
    v_toAccountNumber varchar2(20);  --到账账号
    

   

BEGIN
V_RETMSG2:='';
  for v_c in (select * from tmp_common where f10 = p_sessionID)
    loop
      
    /*    select count(*) into v_count from TF_F_CHECK 
        where 
        TRADEDATE = v_c.f0 and MONEY = to_number(v_c.f1) * 100 and OPENBANK = v_c.f2 and ACCOUNTNAME = v_c.f3
        and ACCOUNTNUMBER = v_c.f4 and EXPLAIN = v_c.f5 and SUMMARY = v_c.f6 and POSTSCRIPT = v_c.f7 
        and TOACCOUNTBANK = v_c.f8 and TOACCOUNTNUMBER = v_c.f9
    and USETAG = '1';
        if v_count > 0 then
            p_retCode := 'S094390024';
            p_retMsg := '账单表中已存在完全相同的账单记录';
            rollback;
            return;
        end if; 
    */
        
        
        --获取流水号
        SP_GetSeq(seq => v_seqNo); 
        v_CHECKID:=v_seqNo;
        --新增账单表
        BEGIN
          INSERT INTO  TF_F_CHECK
          (                                                                
              CHECKID         , CHECKSTATE          , TRADEDATE       , MONEY          ,  OPENBANK      ,  ACCOUNTNAME    ,                                                               
              ACCOUNTNUMBER   , EXPLAIN             , SUMMARY         , POSTSCRIPT     ,  TOACCOUNTBANK ,  TOACCOUNTNUMBER,                                                            
              USEDMONEY       , LEFTMONEY           , USETAG          , UPDATEDEPARTNO ,  UPDATESTAFFNO ,  UPDATETIME     , 
              INSTAFFNO       , INTIME     
          )                                                            
          VALUES
          (                                                                 
              v_seqNo         ,   '1'                , v_c.f0         , to_number(v_c.f1) * 100,   v_c.f2        ,  v_c.f3,                                                             
              v_c.f4          ,   v_c.f5             , v_c.f6         , v_c.f7           ,   v_c.f8        ,  v_c.f9,                                                             
              0               ,  to_number(v_c.f1) * 100  ,  '1'           , P_CURRDEPT       ,  P_CURROPER     , V_TODAY       ,   
              P_CURROPER      ,  V_TODAY             
          );                                                             
                                  
          IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
                EXCEPTION
                WHEN OTHERS THEN
                  P_RETCODE := 'S094780024';
                  P_RETMSG  := '新增账单表失败'||SQLERRM;
                  ROLLBACK; RETURN;
         
        END;
        --获取流水号
        SP_GetSeq(seq => v_seqNo); 
        --记录帐单台帐表
        BEGIN
          INSERT INTO  TF_B_CHECK
          (                                                                    
                TRADEID          ,   CHECKID          ,  TRADECODE       ,  MONEY            , 
                TRADEDATE        ,   OPENBANK         ,  ACCOUNTNAME     ,                                                                   
                ACCOUNTNUMBER    ,   EXPLAIN          ,  SUMMARY         ,  POSTSCRIPT       , 
                TOACCOUNTBANK    ,   TOACCOUNTNUMBER  ,  USEDMONEY,                                                                
                LEFTMONEY        ,   OPERATESTAFFNO   ,  OPERATETIME    
          )                                                                
          VALUES
          (                                                                    
                v_seqNo          ,   v_CHECKID        ,  '2'             , to_number(v_c.f1) * 100 , 
                v_c.f0           ,   v_c.f2           ,  v_c.f3          ,                                                                 
                v_c.f4           ,   v_c.f5           ,  v_c.f6          , v_c.f7            , 
                v_c.f8           ,   v_c.f9           ,  0               ,                                                                
                to_number(v_c.f1) * 100,   P_CURROPER       ,  V_TODAY          
          );                                                                
                                            
          IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
                EXCEPTION
                WHEN OTHERS THEN
                  P_RETCODE := 'S094780024';
                  P_RETMSG  := '记录帐单台帐表失败'||SQLERRM;
                  ROLLBACK; RETURN;
         END;
         
         
         --查询是否有符合匹配条件的订单
          BEGIN
                
               SP_GC_ORDERACCOUNTAPPROVALAUTO(v_CHECKID, v_c.f1 ,v_c.f3,v_c.f4 ,
                    p_currOper, p_currDept, p_retCode, p_retMsg);

                IF p_retCode = '0000000000' THEN 
                   V_RETMSG2  :=V_RETMSG2|| '户名为'||v_c.f3||'的账单已执行自动审核'||';';
                 END IF;

                
            END;
                  
    end loop;
    P_OUTRETMSG:=V_RETMSG2;
    
  p_retCode := '0000000000';
  p_retMsg  := '';
  COMMIT; RETURN;
    
END;
/
show errors
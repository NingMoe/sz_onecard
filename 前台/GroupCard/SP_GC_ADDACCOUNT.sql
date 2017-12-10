CREATE OR REPLACE PROCEDURE SP_GC_ADDACCOUNT
(
    P_TRADEDATE        CHAR,           --交易日期
    P_MONEY            INT,        --收入金额
    P_OPENBANK          varchar2,      --对方开户行
    P_ACCOUNTNAME      varchar2,      --对方户名
    P_ACCOUNTNUMBER    varchar2,      --对方账号
    P_EXPLAIN          varchar2,      --交易说明
    P_SUMMARY          varchar2,      --交易摘要
    P_POSTSCRIPT       varchar2,      --交易附言
    P_TOACCOUNTBANK    varchar2,      --到账银行
    P_TOACCOUNTNUMBER  varchar2,      --到账账号
    P_CURROPER        CHAR,
    P_CURRDEPT        CHAR,
    p_retCode     out char, -- Return Code
    p_retMsg      out varchar2  -- Return Message
)
AS
    v_seqNo              CHAR(16);
    V_TODAY           DATE:=SYSDATE;
    V_EX              EXCEPTION;
    v_CHECKID       char(16);

BEGIN
  
  --获取流水号
  SP_GetSeq(seq => v_seqNo); 
  v_CHECKID:=v_seqNo;
  --新增账单表
  BEGIN
    INSERT INTO  TF_F_CHECK(                                                                
    CHECKID            , CHECKSTATE      , TRADEDATE       , MONEY          , OPENBANK    ,ACCOUNTNAME ,                                                               
    ACCOUNTNUMBER     ,EXPLAIN           , SUMMARY         , POSTSCRIPT     , TOACCOUNTBANK,TOACCOUNTNUMBER,                                                            
    USEDMONEY         ,LEFTMONEY         , USETAG          , UPDATEDEPARTNO  , UPDATESTAFFNO , UPDATETIME  ,INSTAFFNO,INTIME     )                                                            
VALUES(                                                                
    v_seqNo          ,'1'              , P_TRADEDATE      , P_MONEY        , P_OPENBANK      ,P_ACCOUNTNAME,                                                             
    P_ACCOUNTNUMBER  ,P_EXPLAIN        , P_SUMMARY        , P_POSTSCRIPT   , P_TOACCOUNTBANK ,P_TOACCOUNTNUMBER,                                                             
    0                ,P_MONEY          ,'1'               , P_CURRDEPT      , P_CURROPER     , V_TODAY ,P_CURROPER,V_TODAY             );                                                             
                            
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
    INSERT INTO  TF_B_CHECK(                                                                    
    TRADEID          ,CHECKID          , TRADECODE       , MONEY         ,TRADEDATE     , OPENBANK    ,ACCOUNTNAME ,                                                                   
    ACCOUNTNUMBER    ,EXPLAIN          , SUMMARY         , POSTSCRIPT    , TOACCOUNTBANK,TOACCOUNTNUMBER,USEDMONEY,                                                                
    LEFTMONEY        ,OPERATESTAFFNO  , OPERATETIME     )                                                                
VALUES(                                                                    
    v_seqNo          ,v_CHECKID        ,'2'              , P_MONEY       ,P_TRADEDATE    , P_OPENBANK   ,P_ACCOUNTNAME,                                                                 
    P_ACCOUNTNUMBER  ,P_EXPLAIN        , P_SUMMARY       , P_POSTSCRIPT  , P_TOACCOUNTBANK ,P_TOACCOUNTNUMBER,0 ,                                                                
    P_MONEY         , P_CURROPER       , V_TODAY          );                                                                
                                      
    IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
          EXCEPTION
          WHEN OTHERS THEN
            P_RETCODE := 'S094780024';
            P_RETMSG  := '记录帐单台帐表失败'||SQLERRM;
            ROLLBACK; RETURN;
  END;
  p_retCode := '0000000000';
  p_retMsg  := '';
  COMMIT; RETURN;   
END;
/
show errors;
CREATE OR REPLACE PROCEDURE SP_GC_ADDACCOUNT
(
    P_TRADEDATE        CHAR,           --��������
    P_MONEY            INT,        --������
    P_OPENBANK          varchar2,      --�Է�������
    P_ACCOUNTNAME      varchar2,      --�Է�����
    P_ACCOUNTNUMBER    varchar2,      --�Է��˺�
    P_EXPLAIN          varchar2,      --����˵��
    P_SUMMARY          varchar2,      --����ժҪ
    P_POSTSCRIPT       varchar2,      --���׸���
    P_TOACCOUNTBANK    varchar2,      --��������
    P_TOACCOUNTNUMBER  varchar2,      --�����˺�
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
  
  --��ȡ��ˮ��
  SP_GetSeq(seq => v_seqNo); 
  v_CHECKID:=v_seqNo;
  --�����˵���
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
            P_RETMSG  := '�����˵���ʧ��'||SQLERRM;
            ROLLBACK; RETURN;
   
  END;
  --��ȡ��ˮ��
  SP_GetSeq(seq => v_seqNo); 
  --��¼�ʵ�̨�ʱ�
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
            P_RETMSG  := '��¼�ʵ�̨�ʱ�ʧ��'||SQLERRM;
            ROLLBACK; RETURN;
  END;
  p_retCode := '0000000000';
  p_retMsg  := '';
  COMMIT; RETURN;   
END;
/
show errors;
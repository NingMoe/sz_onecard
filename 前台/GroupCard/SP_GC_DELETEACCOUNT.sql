CREATE OR REPLACE PROCEDURE SP_GC_DELETEACCOUNT
(
    P_CHECKID         CHAR,
    P_CURROPER        CHAR,
    P_CURRDEPT        CHAR,
    p_retCode     out char, -- Return Code
    p_retMsg      out varchar2  -- Return Message
)
AS
    V_TODAY           DATE:=SYSDATE;
    V_EX              EXCEPTION;
    v_seqNo            CHAR(16);
BEGIN
  
  
  --获取流水号
   SP_GetSeq(seq => v_seqNo); 
   
  --删除账单表
  UPDATE TF_F_CHECK 
  SET USETAG = '0' , 
      UPDATEDEPARTNO = P_CURRDEPT,
      UPDATESTAFFNO= P_CURROPER,
      UPDATETIME = V_TODAY
  WHERE  CHECKID = P_CHECKID;                                       

  
  --添加到账单台帐表
  BEGIN
    INSERT INTO  TF_B_CHECK(                                                                  
    TRADEID          ,CHECKID          , TRADECODE       , MONEY         ,TRADEDATE     , OPENBANK    ,ACCOUNTNAME ,                                                                 
    ACCOUNTNUMBER    ,EXPLAIN          , SUMMARY         , POSTSCRIPT    , TOACCOUNTBANK,TOACCOUNTNUMBER,USEDMONEY,                                                              
    LEFTMONEY        ,OPERATESTAFFNO  , OPERATETIME                                                                                                     
    )
    SELECT v_seqNo   ,P_CHECKID          ,'3'              , MONEY         ,TRADEDATE     , OPENBANK    ,ACCOUNTNAME ,                                          
    ACCOUNTNUMBER    ,EXPLAIN          , SUMMARY         , POSTSCRIPT    , TOACCOUNTBANK,TOACCOUNTNUMBER,USEDMONEY,                                          
    LEFTMONEY        ,P_CURROPER       , V_TODAY      
    FROM     TF_F_CHECK   
    WHERE  CHECKID = P_CHECKID;                                                                     
    IF  SQL%ROWCOUNT = 0 THEN RAISE V_EX; END IF;
      EXCEPTION
       WHEN OTHERS THEN
          p_retCode := 'S094780025'; p_retMsg  := '添加到账单台帐表' || SQLERRM;
          ROLLBACK; RETURN;    
  END;
  
  
  p_retCode := '0000000000';
  p_retMsg  := '';
  COMMIT; RETURN;   
END;
/
show errors;
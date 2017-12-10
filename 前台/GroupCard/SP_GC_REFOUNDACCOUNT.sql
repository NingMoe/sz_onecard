CREATE OR REPLACE PROCEDURE SP_GC_REFOUNDACCOUNT
(
    P_CHECKID         CHAR,
	P_LEFTMONEY		  INT,
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
  
  
  --��ȡ��ˮ��
   SP_GetSeq(seq => v_seqNo); 
   
  --ɾ���˵���
  UPDATE TF_F_CHECK 
  SET USETAG = '3' , 
	  LEFTMONEY = 0,
	  MONEY = USEDMONEY,
      UPDATEDEPARTNO = P_CURRDEPT,
      UPDATESTAFFNO= P_CURROPER,
      UPDATETIME = V_TODAY
  WHERE  CHECKID = P_CHECKID
		AND USETAG = '1';                                       

  
  --��ӵ��˵�̨�ʱ�
  BEGIN
    INSERT INTO  TF_B_CHECK(                                                                  
    TRADEID          ,CHECKID          , TRADECODE       , MONEY         ,TRADEDATE     , OPENBANK    ,ACCOUNTNAME ,                                                                 
    ACCOUNTNUMBER    ,EXPLAIN          , SUMMARY         , POSTSCRIPT    , TOACCOUNTBANK,TOACCOUNTNUMBER,USEDMONEY,                                                              
    LEFTMONEY        ,OPERATESTAFFNO  , OPERATETIME                                                                                                   
    )
    SELECT v_seqNo   ,P_CHECKID          ,'6'              , P_LEFTMONEY ,TRADEDATE     , OPENBANK    ,ACCOUNTNAME ,                                          
    ACCOUNTNUMBER    ,EXPLAIN          , SUMMARY         , POSTSCRIPT    , TOACCOUNTBANK,TOACCOUNTNUMBER,USEDMONEY,                                          
    LEFTMONEY        ,P_CURROPER       , V_TODAY      
    FROM     TF_F_CHECK   
    WHERE  CHECKID = P_CHECKID;                                                                     
    IF  SQL%ROWCOUNT = 0 THEN RAISE V_EX; END IF;
      EXCEPTION
       WHEN OTHERS THEN
          p_retCode := 'S094780025'; p_retMsg  := '��ӵ��˵�̨�ʱ�' || SQLERRM;
          ROLLBACK; RETURN;    
  END;
  
  
  p_retCode := '0000000000';
  p_retMsg  := '';
  COMMIT; RETURN;   
END;
/
show errors;
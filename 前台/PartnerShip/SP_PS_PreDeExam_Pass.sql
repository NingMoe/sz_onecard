CREATE OR REPLACE PROCEDURE SP_PS_PreDeExam_Pass
(
    P_ID              CHAR     , --审核流水号
    P_TRADETYPECODE   CHAR     , --业务类型编码
    P_DBALUNITNO      CHAR     , --网点结算单元编码
    P_MONEY           INT      , --操作金额
    P_CURROPER        CHAR     ,
    P_CURRDEPT        CHAR     ,
    P_RETCODE     OUT CHAR     ,
    P_RETMSG      OUT VARCHAR2
)
AS
    V_TRADETYPECODE   VARCHAR2(2)  := P_TRADETYPECODE ;
    V_SEQ             VARCHAR2(16)               ;
    V_TODAY           DATE         := SYSDATE    ;
    V_EX              EXCEPTION                  ;
    V_PREPAY          INT                        ;
    V_USABLEVALUE     INT                        ;
    V_DEPOSIT       int;
    v_cardnum       int;
    V_CARDPRICE     int;
BEGIN
    IF V_TRADETYPECODE= '01' THEN --财务存保证金
    BEGIN
      SP_GETSEQ(SEQ => V_SEQ); --获取业务流水号
      --记录网点结算单元资金管理台账表
      INSERT INTO TF_B_DEPTACCTRADE(
          TRADEID     , TRADETYPECODE    , DBALUNITNO      , CURRENTMONEY    ,
          PREMONEY    , NEXTMONEY        , OPERATESTAFFNO  , OPERATEDEPARTID ,
          OPERATETIME , REMARK
     )SELECT
          V_SEQ       , '01'             , b.DBALUNITNO    , b.CURRENTMONEY  ,
          a.DEPOSIT   , b.CURRENTMONEY+a.DEPOSIT , b.OPERATESTAFFNO  , b.OPERATEDEPARTID  , 
          V_TODAY   , b.REMARK
      FROM TF_F_DEPTBAL_DEPOSIT a, TF_B_DEPTACC_EXAM b
      WHERE a.DBALUNITNO = b.DBALUNITNO
      AND   a.ACCSTATECODE = '01'
      AND   b.ID = P_ID
      AND   b.STATECODE = '1';
    EXCEPTION WHEN OTHERS THEN
      P_RETCODE := 'S008905001';
      P_RETMSG  := '记录网点结算单元资金管理台账表失败'||SQLERRM;
      ROLLBACK;RETURN;
    END;
    BEGIN
      --更新网点结算单元保证金账户表
      UPDATE TF_F_DEPTBAL_DEPOSIT
      SET    DEPOSIT       = DEPOSIT+P_MONEY     ,
             USABLEVALUE   = USABLEVALUE+P_MONEY ,
             UPDATESTAFFNO = P_CURROPER          ,
             UPDATETIME    = V_TODAY
      WHERE  DBALUNITNO    = P_DBALUNITNO
      AND    ACCSTATECODE  = '01';  
    
      IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
    EXCEPTION WHEN OTHERS THEN
      P_RETCODE := 'S008905005';
      P_RETMSG  := '更新网点结算单元预付款账户表失败'||SQLERRM;
      ROLLBACK;RETURN;    
    END;
    BEGIN
      --更新预付款保证金业务台账审核表
      UPDATE TF_B_DEPTACC_EXAM
      SET    TRADEID       = V_SEQ      ,
             EXAMSTAFFNO   = P_CURROPER ,
             EXAMDEPARTNO  = P_CURRDEPT ,
             EXAMKTIME     = V_TODAY    ,
             STATECODE     = '2'
      WHERE  ID            = P_ID
      AND    STATECODE     = '1';  
    
      IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
    EXCEPTION WHEN OTHERS THEN
      P_RETCODE := 'S008905012';
      P_RETMSG  := '更新预付款保证金业务台账审核表失败'||SQLERRM;
      ROLLBACK;RETURN;    
    END;
    END IF;
    IF V_TRADETYPECODE= '02' THEN --财务支出保证金
      --计算是否可支出余额
      --获取已有卡
      select count(*) into v_cardnum from TL_R_ICUSER a
      where exists (select * from  TD_DEPTBAL_RELATION b where a.assigneddepartid=b.departno and b.dbalunitno = P_DBALUNITNO)
      and a.RESSTATECODE IN('01','05');
      --获取用户卡价值
      SELECT TAGVALUE INTO V_CARDPRICE FROM TD_M_TAG WHERE TAGCODE='USERCARD_MONEY'; 
      --获取保证金余额
      SELECT DEPOSIT INTO V_DEPOSIT FROM TF_F_DEPTBAL_DEPOSIT WHERE ACCSTATECODE='01' AND DBALUNITNO = P_DBALUNITNO; 
      --计算可领卡价值额度
      V_USABLEVALUE := V_DEPOSIT - v_cardnum*V_CARDPRICE;
      --如果支出金额大于预付款余额则提示错误
      IF P_MONEY > V_USABLEVALUE THEN
          P_RETCODE := 'S008905004';
          P_RETMSG  := '支出金额不能大于可领卡价值额度';
          ROLLBACK;RETURN; 
      ELSE--如果支出金额不大于预付款余额则执行		    	
      BEGIN
        SP_GETSEQ(SEQ => V_SEQ); --获取业务流水号
        --记录网点结算单元资金管理台账表
        INSERT INTO TF_B_DEPTACCTRADE(
            TRADEID     , TRADETYPECODE    , DBALUNITNO      , CURRENTMONEY    ,
            PREMONEY    , NEXTMONEY        , OPERATESTAFFNO  , OPERATEDEPARTID ,
            OPERATETIME , REMARK
       )SELECT
            V_SEQ       , '02'             , b.DBALUNITNO    , -b.CURRENTMONEY  ,
            a.DEPOSIT   , a.DEPOSIT-b.CURRENTMONEY , b.OPERATESTAFFNO  , b.OPERATEDEPARTID  , 
            V_TODAY   , b.REMARK
        FROM TF_F_DEPTBAL_DEPOSIT a, TF_B_DEPTACC_EXAM b
        WHERE a.DBALUNITNO = b.DBALUNITNO
        AND   a.ACCSTATECODE = '01'
        AND   b.ID = P_ID
        AND   b.STATECODE = '1';
      EXCEPTION WHEN OTHERS THEN
        P_RETCODE := 'S008905001';
        P_RETMSG  := '记录网点结算单元资金管理台账表失败'||SQLERRM;
        ROLLBACK;RETURN;
      END;
      BEGIN
        --更新网点结算单元保证金账户表
        UPDATE TF_F_DEPTBAL_DEPOSIT
        SET    DEPOSIT       = DEPOSIT-P_MONEY     ,
               USABLEVALUE   = USABLEVALUE-P_MONEY ,
               UPDATESTAFFNO = P_CURROPER          ,
               UPDATETIME    = V_TODAY
        WHERE  DBALUNITNO    = P_DBALUNITNO
        AND    ACCSTATECODE  = '01';  
    
        IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
      EXCEPTION WHEN OTHERS THEN
        P_RETCODE := 'S008905005';
        P_RETMSG  := '更新网点结算单元预付款账户表失败'||SQLERRM;
        ROLLBACK;RETURN;    
      END;
      BEGIN
        --更新预付款保证金业务台账审核表
        UPDATE TF_B_DEPTACC_EXAM
        SET    TRADEID       = V_SEQ      ,
               EXAMSTAFFNO   = P_CURROPER ,
               EXAMDEPARTNO  = P_CURRDEPT ,
               EXAMKTIME     = V_TODAY    ,
               STATECODE     = '2'
        WHERE  ID            = P_ID
        AND    STATECODE     = '1';  
    
        IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
      EXCEPTION WHEN OTHERS THEN
        P_RETCODE := 'S008905012';
        P_RETMSG  := '更新预付款保证金业务台账审核表失败'||SQLERRM;
        ROLLBACK;RETURN;    
      END;
      END IF;
    END IF;    
    IF V_TRADETYPECODE= '11' THEN --财务存预付款
    	BEGIN
      SP_GETSEQ(SEQ => V_SEQ); --获取业务流水号
      --记录网点结算单元资金管理台账表
      INSERT INTO TF_B_DEPTACCTRADE(
          TRADEID     , TRADETYPECODE    , DBALUNITNO      , CURRENTMONEY    ,
          PREMONEY    , NEXTMONEY        , OPERATESTAFFNO  , OPERATEDEPARTID ,
          OPERATETIME , REMARK , FINDATE, FINTRADENO,FINBANK,USEWAY
     )SELECT
          V_SEQ       , '11'             , b.DBALUNITNO    , b.CURRENTMONEY  ,
          a.PREPAY   , b.CURRENTMONEY+a.PREPAY , b.OPERATESTAFFNO  , b.OPERATEDEPARTID  , 
          V_TODAY , b.REMARK , b.FINDATE, b.FINTRADENO,b.FINBANK,b.USEWAY
      FROM TF_F_DEPTBAL_PREPAY a, TF_B_DEPTACC_EXAM b
      WHERE a.DBALUNITNO = b.DBALUNITNO
      AND   a.ACCSTATECODE = '01'
      AND   b.ID = P_ID
      AND   b.STATECODE = '1';
    EXCEPTION WHEN OTHERS THEN
      P_RETCODE := 'S008905001';
      P_RETMSG  := '记录网点结算单元资金管理台账表失败'||SQLERRM;
      ROLLBACK;RETURN;
    END;
    BEGIN
      --更新网点结算单元预付款账户表
      UPDATE TF_F_DEPTBAL_PREPAY
      SET    PREPAY       = PREPAY+P_MONEY     ,             
             UPDATESTAFFNO = P_CURROPER          ,
             UPDATETIME    = V_TODAY
      WHERE  DBALUNITNO    = P_DBALUNITNO
      AND    ACCSTATECODE  = '01';  
    
      IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
    EXCEPTION WHEN OTHERS THEN
      P_RETCODE := 'S008905005';
      P_RETMSG  := '更新网点结算单元预付款账户表失败'||SQLERRM;
      ROLLBACK;RETURN;    
    END;
    BEGIN
      --更新预付款保证金业务台账审核表
      UPDATE TF_B_DEPTACC_EXAM
      SET    TRADEID       = V_SEQ      ,
             EXAMSTAFFNO   = P_CURROPER ,
             EXAMDEPARTNO  = P_CURRDEPT ,
             EXAMKTIME     = V_TODAY    ,
             STATECODE     = '2'
      WHERE  ID            = P_ID
      AND    STATECODE     = '1';  
    
      IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
    EXCEPTION WHEN OTHERS THEN
      P_RETCODE := 'S008905012';
      P_RETMSG  := '更新预付款保证金业务台账审核表失败'||SQLERRM;
      ROLLBACK;RETURN;    
    END;
    END IF;
    IF V_TRADETYPECODE= '12' THEN --财务支出预付款
    	SELECT PREPAY INTO V_PREPAY FROM TF_F_DEPTBAL_PREPAY WHERE DBALUNITNO = P_DBALUNITNO;
      --如果支出金额大于预付款余额则提示错误
      IF P_MONEY > V_PREPAY THEN
          P_RETCODE := 'S008905002';
          P_RETMSG  := '支出金额不能大于预付款余额';
          ROLLBACK;RETURN; 
      ELSE--如果支出金额不大于预付款余额则执行		
    	BEGIN
        SP_GETSEQ(SEQ => V_SEQ); --获取业务流水号
        --记录网点结算单元资金管理台账表
        INSERT INTO TF_B_DEPTACCTRADE(
            TRADEID     , TRADETYPECODE    , DBALUNITNO      , CURRENTMONEY    ,
            PREMONEY    , NEXTMONEY        , OPERATESTAFFNO  , OPERATEDEPARTID ,
            OPERATETIME , REMARK, FINDATE, FINTRADENO,FINBANK,USEWAY
       )SELECT
            V_SEQ       , '12'             , b.DBALUNITNO    , -b.CURRENTMONEY  ,
            a.PREPAY   , a.PREPAY-b.CURRENTMONEY , b.OPERATESTAFFNO  , b.OPERATEDEPARTID  , 
            V_TODAY   , b.REMARK, b.FINDATE, b.FINTRADENO,b.FINBANK,b.USEWAY
        FROM TF_F_DEPTBAL_PREPAY a, TF_B_DEPTACC_EXAM b
        WHERE a.DBALUNITNO = b.DBALUNITNO
        AND   a.ACCSTATECODE = '01'
        AND   b.ID = P_ID
        AND   b.STATECODE = '1';
      EXCEPTION WHEN OTHERS THEN
        P_RETCODE := 'S008905001';
        P_RETMSG  := '记录网点结算单元资金管理台账表失败'||SQLERRM;
        ROLLBACK;RETURN;
      END;
      BEGIN
        --更新网点结算单元预付款账户表
        UPDATE TF_F_DEPTBAL_PREPAY
        SET    PREPAY        = PREPAY-P_MONEY     ,
               UPDATESTAFFNO = P_CURROPER          ,
               UPDATETIME    = V_TODAY
        WHERE  DBALUNITNO    = P_DBALUNITNO
        AND    ACCSTATECODE  = '01';  
    
        IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
      EXCEPTION WHEN OTHERS THEN
        P_RETCODE := 'S008905005';
        P_RETMSG  := '更新网点结算单元预付款账户表失败'||SQLERRM;
        ROLLBACK;RETURN;    
      END;
      BEGIN
        --更新预付款保证金业务台账审核表
        UPDATE TF_B_DEPTACC_EXAM
        SET    TRADEID       = V_SEQ      ,
               EXAMSTAFFNO   = P_CURROPER ,
               EXAMDEPARTNO  = P_CURRDEPT ,
               EXAMKTIME     = V_TODAY    ,
               STATECODE     = '2'
        WHERE  ID            = P_ID
        AND    STATECODE     = '1';  
    
        IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
      EXCEPTION WHEN OTHERS THEN
        P_RETCODE := 'S008905012';
        P_RETMSG  := '更新预付款保证金业务台账审核表失败'||SQLERRM;
        ROLLBACK;RETURN;    
      END;
      END IF;
    END IF;
    p_retCode := '0000000000'; p_retMsg  := '成功';
    commit; return;	
END;    

/
show errors
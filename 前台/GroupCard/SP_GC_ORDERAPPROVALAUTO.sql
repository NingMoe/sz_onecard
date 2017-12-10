CREATE OR REPLACE PROCEDURE SP_GC_ORDERAPPROVALAUTO
(
    P_ORDERNO           CHAR    , --订单号
    p_ISAPPROVE         CHAR    ,  --是否呈批单
    p_currOper          char    ,
    p_currDept          char    ,
    p_retCode       out char    ,  -- Return Code
    p_retMsg        out varchar2   -- Return Message  
)
AS 
    v_seqNo              CHAR(16); --业务流水号
    V_CHECKID            CHAR(16); --账单号
    V_GROUPNAME          VARCHAR2(100);--订单的单位名称
    V_NAME               VARCHAR2(50);--订单的联系人
    V_ORDERMONEY         INT;      --订单总金额
    V_ORDERSTATE         CHAR(2);  --订单状态
    V_ORDERTYPE          CHAR(1);  --订单类型
    V_ACCOUNTNAME        VARCHAR2(100);--对方户名
    V_ACCOUNTNUMBER      VARCHAR2(30);--对方账号
    V_COUNT              INT;
    V_COUNT2             INT;
    V_NUM                INT;
    V_EX                 EXCEPTION;
    V_TODAY              DATE := SYSDATE;

BEGIN
   
        --查询订单状态、单位名称和订单总金额，判断是否是未审核状态
        SELECT ORDERSTATE,GROUPNAME,NAME,TOTALMONEY,ORDERTYPE INTO V_ORDERSTATE,V_GROUPNAME,V_NAME,V_ORDERMONEY,V_ORDERTYPE FROM TF_F_ORDERFORM WHERE ORDERNO = P_ORDERNO;
        IF V_ORDERSTATE<>'01' THEN  --如果订单状态不为录入待审核就不处理
             p_retCode := 'A094570400';
             p_retMsg  := '订单状态不为录入待审核';
             RETURN; 
        END IF;
       
        
       
        IF p_ISAPPROVE <> '1' THEN --如果不是呈批单订单则关联账单
            
                --自动查询未匹配的财务到账信息,如果能符合匹配条件，则订单审核通过
            IF V_ORDERTYPE = '1' THEN--订单类型是单位订单 
                SELECT COUNT(*) INTO V_COUNT FROM TF_F_CHECK T,TF_F_ORDERCHECKRELATION P WHERE T.CHECKID = P.CHECKID(+) AND  P.CHECKID IS NULL AND 
                T.MONEY = V_ORDERMONEY AND T.USEDMONEY = 0 AND T.ACCOUNTNAME = V_GROUPNAME AND T.CHECKSTATE ='1' AND T.USETAG = '1';
                
            ELSE --个人订单
                SELECT COUNT(*) INTO V_COUNT2 FROM TF_F_CHECK T,TF_F_ORDERCHECKRELATION P WHERE T.CHECKID = P.CHECKID(+) AND  P.CHECKID IS NULL AND 
                T.MONEY = V_ORDERMONEY AND T.USEDMONEY = 0 AND T.ACCOUNTNAME = V_NAME AND T.CHECKSTATE ='1' AND T.USETAG = '1';
            
            END IF;
            
                
            IF  V_COUNT!=1 AND V_ORDERTYPE = '1' THEN
                 p_retCode := 'A094570401';
                 p_retMsg  := '未找到符合自动审核匹配条件的账单';
                 RETURN;
            END IF;
            IF  V_COUNT2!=1 AND V_ORDERTYPE = '2' THEN
                 p_retCode := 'A094570402';
                 p_retMsg  := '未找到符合自动审核匹配条件的账单';
                 RETURN;
            END IF;
                
                
            IF  V_COUNT=1 OR V_COUNT2=1 THEN --自动查询到未匹配的财务到账信息
                
                
                 IF  V_ORDERTYPE = '1' THEN
                  --查询匹配的账单号
                     SELECT T.CHECKID,T.ACCOUNTNAME,T.ACCOUNTNUMBER INTO V_CHECKID,V_ACCOUNTNAME,V_ACCOUNTNUMBER  FROM TF_F_CHECK T,TF_F_ORDERCHECKRELATION P WHERE T.CHECKID = P.CHECKID(+) AND  P.CHECKID IS NULL AND 
                     T.MONEY = V_ORDERMONEY AND T.USEDMONEY = 0 AND T.ACCOUNTNAME = V_GROUPNAME AND T.CHECKSTATE ='1' AND T.USETAG = '1';                  
                 ELSE
                     SELECT T.CHECKID,T.ACCOUNTNAME,T.ACCOUNTNUMBER INTO V_CHECKID,V_ACCOUNTNAME,V_ACCOUNTNUMBER  FROM TF_F_CHECK T,TF_F_ORDERCHECKRELATION P WHERE T.CHECKID = P.CHECKID(+) AND  P.CHECKID IS NULL AND 
                     T.MONEY = V_ORDERMONEY AND T.USEDMONEY = 0 AND T.ACCOUNTNAME = V_NAME AND T.CHECKSTATE ='1' AND T.USETAG = '1';  
                    
                  END IF;
                
                  --更新订单表
                  BEGIN
                      UPDATE TF_F_ORDERFORM
                     SET    ORDERSTATE = '02',--审核通过
                             FINANCEAPPROVERNO = p_currOper,
                             FINANCEAPPROVERTIME = V_TODAY,
                             FINANCEREMARK = NULL,
                             UPDATEDEPARTNO = p_currDept,
                             UPDATESTAFFNO = p_currOper,
                             UPDATETIME = V_TODAY
                    WHERE  ORDERNO = P_ORDERNO;    
                    IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
                      EXCEPTION WHEN OTHERS THEN
                      p_retCode := 'S094570401';
                      p_retMsg  := '自动审核时更新订单表失败,'|| SQLERRM;
                      ROLLBACK; RETURN;            
                   END;
                   
                     --更新账单表
                    BEGIN
                        UPDATE TF_F_CHECK 
                        SET    CHECKSTATE = '3', --完成使用
                               USEDMONEY = V_ORDERMONEY, --已用金额等于账单金额
                               LEFTMONEY = 0, --剩余金额为0
                               UPDATEDEPARTNO = p_currDept,
                               UPDATESTAFFNO = p_currOper,
                               UPDATETIME = V_TODAY
                        WHERE  CHECKID = V_CHECKID;
                    IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
                    EXCEPTION WHEN OTHERS THEN
                        p_retCode := 'S094570402';
                        p_retMsg  := '自动审核时更新账单表失败,'|| SQLERRM;
                        ROLLBACK; RETURN;            
                    END;
                
                 --生成流水号
                SP_GetSeq(seq => v_seqNo); 
                --记录订单与账单关联关系表
                BEGIN
                    INSERT INTO TF_F_ORDERCHECKRELATION(
                        ORDERNO   , CHECKID   , TRADEID , MONEY            , UPDATESTAFFNO , UPDATETIME
                    )VALUES(
                        P_ORDERNO , V_CHECKID , v_seqNo , V_ORDERMONEY     , p_currOper    , V_TODAY
                    );
                IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
                EXCEPTION WHEN OTHERS THEN
                    p_retCode := 'S094570403';
                    p_retMsg  := '自动审核时记录订单与账单关联关系表失败,'|| SQLERRM;
                    ROLLBACK; RETURN;            
                END;
                
                BEGIN
                  SELECT COUNT(*) INTO V_NUM FROM TF_F_COMBUYCARDREG T WHERE T.REMARK = P_ORDERNO;
                  
                  
                  IF V_NUM>0 THEN 
                  --更新单位购卡记录表
                  BEGIN
                    UPDATE TF_F_COMBUYCARDREG 
                    SET OUTBANK = v_ACCOUNTNUMBER,--转出银行帐号
                        OUTACCT = V_ACCOUNTNAME--转出账户户名
                    WHERE REMARK = P_ORDERNO;
                     IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
                    EXCEPTION WHEN OTHERS THEN
                        p_retCode := 'S094570404';
                        p_retMsg  := '自动审核时更新单位购卡记录表失败,'|| SQLERRM;
                        ROLLBACK; RETURN; 
                  END;
                  END IF;
                  
                END;
                
                  --记录订单台账  新增TRADECODE '17'为自动审核
                BEGIN
                    INSERT INTO TF_F_ORDERTRADE(
                        TRADEID , ORDERNO   ,TRADECODE , MONEY        , OPERATEDEPARTNO , OPERATESTAFFNO , OPERATETIME
                    )VALUES(
                        v_seqNo , P_ORDERNO ,'17'      , V_ORDERMONEY , p_currDept      , p_currOper     , V_TODAY
                    );
                IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
                EXCEPTION WHEN OTHERS THEN
                    p_retCode := 'S094570405';
                    p_retMsg  := '自动审核时记录订单台账失败,'|| SQLERRM;
                    ROLLBACK; RETURN;            
                END;
                --记录账单台账
                BEGIN
                    INSERT INTO TF_B_CHECK(
                        TRADEID , CHECKID   , TRADECODE , MONEY        , USEDMONEY        , LEFTMONEY        , OPERATESTAFFNO , OPERATETIME
                    )VALUES(
                        v_seqNo , V_CHECKID , '4'       , V_ORDERMONEY , V_ORDERMONEY     , 0                , p_currOper     , V_TODAY
                    );
                IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
                EXCEPTION WHEN OTHERS THEN
                    p_retCode := 'S094570406';
                    p_retMsg  := '自动审核时记录账单台账失败,'|| SQLERRM;
                    ROLLBACK; RETURN;            
                END;
                
                    
          END IF;
     
        END IF;
        
        

    p_retCode := '0000000000';
    p_retMsg  := '成功';
    COMMIT; RETURN;    
END;

 
    
/
show errors;
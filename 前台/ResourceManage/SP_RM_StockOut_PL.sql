--用户卡出库
--Create by Yin 20120720

CREATE OR REPLACE PROCEDURE SP_RM_StockOut
(
    p_fromCardNo    char,   -- From Card No.
    p_toCardNo      char,   -- End  Card No.
    p_assignedStaff char,   -- Assigned Staff No
    p_serviceCycle  char,   -- Service Cycle Type
    p_serviceFee    int ,   -- Service Fee per Service Cycle
    p_retValMode    char,   -- Value-Return Mode, like 'Return All' or 'No return'
    P_CARDPRICE     int ,   -- 代理营业厅领卡卡价值
    p_currOper      char,   -- Current Operator
    p_currDept      char,   -- Curretn Operator's Department
    
    p_saleType      char,   -- sale card type -- add by jiangbb 2012-05-10
    
    p_cardUnitPrice int,    --卡片单价  add by Yin
    p_getcardorderid char,  --领用单号
    p_alreadygetnum int,    --领用数量
    
    p_retCode       out char,     -- Return Code
    p_retMsg        out varchar2  -- Return Message

)
AS
    v_assignedDept  char(4); -- Assigned Staff's Department    
    v_fromCard      numeric(16);
    v_toCard        numeric(16);
    v_cardNo        char(16);
    v_quantity      int;
    v_dbquantity    int;
    v_today         date := sysdate;
    v_ex            EXCEPTION;
	  v_seqNo         CHAR(16);  
    
    v_cardType char(2);  --卡片类型
    v_cardFaceType char(4); --卡面类型
    v_applynum  int;
    v_agreegetnum  int;
    v_alreadynum   int;
    V_GETCARDORDERSTATE char(1);
    
BEGIN
    -- 1) tell the consistence of v_quantity 
    v_fromCard := TO_NUMBER(p_fromCardNo);
    v_toCard   := TO_NUMBER(p_toCardNo);
    v_quantity := v_toCard - v_fromCard + 1;

    BEGIN
        SELECT DEPARTNO INTO v_assignedDept
            FROM  TD_M_INSIDESTAFF
            WHERE STAFFNO = p_assignedStaff;
    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'A002P04D02'; p_retMsg  := '无法得到分配员工所在的部门编码' || SQLERRM;
            RETURN;
    END;


    SELECT COUNT(*) INTO v_dbquantity
    FROM TL_R_ICUSER
    WHERE CARDNO BETWEEN p_fromCardNo AND p_toCardNo
    AND   RESSTATECODE = '00';  -- IN STOCKIN
    IF v_quantity != v_dbquantity THEN
        p_retCode := 'A002P02B01'; p_retMsg  := '已有卡片不在库';
        RETURN; 
    END IF;    

    -- 2) update the ic card stock table
    BEGIN
        UPDATE  TL_R_ICUSER
        SET UPDATETIME       = v_today     ,
            UPDATESTAFFNO    = p_currOper     ,
            ASSIGNEDSTAFFNO  = p_assignedStaff,
            ASSIGNEDDEPARTID = v_assignedDept ,
            SERVICECYCLE     = p_serviceCycle ,
            EVESERVICEPRICE  = p_serviceFee   ,
            RESSTATECODE     = '01',   -- stockout
            OUTTIME          = v_today,
            SALETYPE         = p_saleType,
            CARDPRICE        = p_cardUnitPrice  --卡片单价 add  by Yin
        WHERE CARDNO  BETWEEN p_fromCardNo AND p_toCardNo
        AND   RESSTATECODE   = '00';
        
        IF  SQL%ROWCOUNT != v_quantity THEN RAISE v_ex; END IF;
    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S002P02B02'; p_retMsg  := '更新IC卡库存信息失败,' || SQLERRM;
            ROLLBACK; RETURN;
    END;

    -- 3) add the value-return information
    IF p_retValMode = '0' THEN     -- no returns
    BEGIN
        LOOP
            v_cardNo := SUBSTR('0000000000000000' || TO_CHAR(v_fromCard), -16);
    
            INSERT INTO TF_F_CARDEWALLETACC_BACK
                (CARDNO,JUDGEMONEY, JUDGEMODE,USETAG,UPDATESTAFFNO, UPDATETIME)
            VALUES
                (v_cardNo, 0, ' ', p_retValMode, p_currOper, v_today);
 
            EXIT WHEN v_fromCard >= v_toCard;
            
            v_fromCard := v_fromCard + 1;
        END LOOP; 
    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S002P02B03'; p_retMsg  := '新增卡片退值信息失败,' || SQLERRM;
            ROLLBACK; RETURN;
    END;
    END IF;
    
    --查询申请数量、同意领用数量、已经领用数量、卡片类型、卡面类型
    select APPLYGETNUM , AGREEGETNUM ,ALREADYGETNUM, CARDTYPECODE  , CARDSURFACECODE
     into  v_applynum, v_agreegetnum, v_alreadynum,  v_cardType,      v_cardFaceType   
    from TF_F_GETCARDORDER where getcardorderid = p_getcardorderid;																								
    if v_agreegetnum > v_alreadynum + p_alreadygetnum	then																							
        V_GETCARDORDERSTATE := '3'; --部分领用																								
    else																								
        V_GETCARDORDERSTATE := '4'; --全部领用																								
		end if;	

    -- 4) log this operation 
    -- get the sequence number 
    SP_GetSeq(seq => v_seqNo);
    
    BEGIN
        INSERT INTO TF_R_ICUSERTRADE
            (TRADEID,   BEGINCARDNO, ENDCARDNO, CARDNUM, RSRV1,
            ASSIGNEDSTAFFNO, ASSIGNEDDEPARTID,
            OPETYPECODE, OPERATESTAFFNO,OPERATEDEPARTID,OPERATETIME,CARDTYPECODE,CARDSURFACECODE)
        VALUES  
            (v_seqNo, p_fromCardNo, p_toCardNo, v_quantity, P_CARDPRICE,
             p_assignedStaff, v_assignedDept, 
            '01',       p_currOper     , p_currDept     ,  v_today,v_cardType,v_cardFaceType);
    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S002P02B04'; p_retMsg  := '新增IC卡出库日志失败,' || SQLERRM;
            ROLLBACK; RETURN;
    END;
    
    --更改领用单表
    begin																					
          update TF_F_GETCARDORDER tf set tf.alreadygetnum = v_alreadynum + p_alreadygetnum,																								
              tf.latelygetdate = v_today,tf.getstaffno = p_assignedStaff,																								
              tf.getcardorderstate = V_GETCARDORDERSTATE																							
              where tf.getcardorderid = p_getcardorderid;						
           IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;   																		
           EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S094390005'; p_retMsg  := '更新领用单表失败,' || SQLERRM;
            ROLLBACK; RETURN;																								
    end;
    
    --插入单据管理台账
    begin
      
          insert into TF_B_ORDERMANAGE 
          (
              TRADEID,                     ORDERTYPECODE,                     ORDERID,                OPERATETYPECODE,               ORDERDEMAND,																											
              CARDTYPECODE,                CARDSURFACECODE,                   CARDSAMPLECODE,         CARDNAME,                      CARDFACEAFFIRMWAY,
              VALUECODE,                   CARDNUM,							              REQUIREDATE,            LATELYDATE,                    ALREADYARRIVENUM,
              RETURNCARDNUM,               BEGINCARDNO,                       ENDCARDNO,              CARDCHIPTYPECODE,							 COSTYPECODE,
              MANUTYPECODE,                APPVERNO,                          VALIDBEGINDATE,         VALIDENDDATE,                  APPLYGETNUM,
              AGREEGETNUM,                 ALREADYGETNUM,							        LATELYGETDATE,          GETSTAFFNO,                    OPERATETIME,                   
              OPERATESTAFF,                REMARK
          )																											
          values																											
          (
              v_seqNo,                    '03',                               p_getcardorderid,            '09',                     null,
              v_cardType,                  v_cardFaceType,                    null,                        null,                     null,
              null,                        p_alreadygetnum,						        null,                        null,                     null,
              null,                        p_fromCardNo,                      p_toCardNo,                  null,                     null,
              null,                        null,                              null,                        null,                     v_applynum,
              v_agreegetnum,							 v_alreadynum + p_alreadygetnum,    v_today,                 p_assignedStaff,              v_today ,
              p_currOper,                  null
          );																										
      		
          EXCEPTION
              WHEN OTHERS THEN
                  p_retCode := 'S094390002'; p_retMsg  := '更新领用单表失败,' || SQLERRM;
                  ROLLBACK; RETURN;																							
																										
    end;
            
    p_retCode := '0000000000'; p_retMsg  := '';
    RETURN;
END;
/

show errors

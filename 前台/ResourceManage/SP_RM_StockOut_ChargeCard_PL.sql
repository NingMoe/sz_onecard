--充值卡出库  create by Yin
CREATE OR REPLACE PROCEDURE SP_RM_StockOut_ChargeCard
(
    p_fromCardNo     char, --起始卡号
    p_toCardNo       char, --结束卡号
    p_assignDepartNo char, --领用部门
    p_seqNo          char, --流水号
    p_getcardorderid char, --领用单号
    p_alreadygetnum  int,  --已领用数量
    p_getStaffNo     char, --领用员工
    p_currOper       char,
    p_currDept       char,
    p_retCode    out char, -- Return Code
    p_retMsg     out varchar2  -- Return Message
)
AS

    v_fromCard          numeric(8);
    v_toCard            numeric(8);
    v_ex                exception ;
    v_quantity          int;
    v_today             date:=sysdate;
    v_seqNo             CHAR(16);  
    v_valuecode         char(1); --卡片面额
    v_applynum          int;
    v_agreegetnum       int;
    v_alreadynum        int;    
    V_GETCARDORDERSTATE char(1);
    v_getdeptid         char(4);
BEGIN

    v_fromCard := TO_NUMBER(SUBSTR(p_fromCardNo, -8));
    v_toCard   := TO_NUMBER(SUBSTR(p_toCardNo  , -8));
    v_quantity := v_toCard - v_fromCard + 1;

    -- 1) Update the voucher card info
    BEGIN
        UPDATE TD_XFC_INITCARD            
        SET    OUTTIME    = v_today    ,            
               OUTSTAFFNO = p_currOper ,            
               ASSIGNDEPARTNO   = p_assignDepartNo,            
               CARDSTATECODE='3'  --出库状态            
        WHERE  CARDSTATECODE = '2' -- 入库状态            
        AND    XFCARDNO BETWEEN p_fromCardNo AND p_toCardNo;            


        IF  SQL%ROWCOUNT != v_quantity THEN RAISE v_ex; END IF;
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S007P04C01'; p_retMsg := '更新充值卡状态失败,' || SQLERRM;
        ROLLBACK; RETURN;
    END;
    
    --查询出申请数量、同意领用数量、已领用数量和面额
    select  APPLYGETNUM , AGREEGETNUM, ALREADYGETNUM, VALUECODE  
	into  v_applynum, v_agreegetnum,v_alreadynum, v_valuecode   
    from TF_F_GETCARDORDER 
	where getcardorderid = p_getcardorderid;                                                
    if v_agreegetnum > p_alreadygetnum + v_alreadynum  then                                              
        V_GETCARDORDERSTATE := '3'; --部分领用                                                
    else                                                
        V_GETCARDORDERSTATE := '4'; --全部领用                                                
    end if;  
    
    BEGIN
        SELECT DEPARTNO INTO v_getdeptid
        FROM  TD_M_INSIDESTAFF
        WHERE STAFFNO = p_getStaffNo;
    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'A002P04D02'; p_retMsg  := '无法得到分配员工所在的部门编码' || SQLERRM;
            RETURN;
    END;    
    
    -- 2) Log the card operation
    BEGIN
        INSERT INTO TL_XFC_MANAGELOG
            (ID,STAFFNO,OPERTIME,OPERTYPECODE,STARTCARDNO,ENDCARDNO,VALUECODE,GETSTAFFNO,GETDEPARTID)
        VALUES
            (p_seqNo,p_currOper,v_today,'03',p_fromCardNo,p_toCardNo,v_valuecode,p_getStaffNo,v_getdeptid);
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S007P04C02'; p_retMsg := '更新充值卡出库操作日志失败,' || SQLERRM;
        ROLLBACK; RETURN;
    END;
    
    --更改领用单表
    begin                                          
          update TF_F_GETCARDORDER tf set tf.alreadygetnum = v_alreadynum + p_alreadygetnum,                                                
              tf.latelygetdate = v_today,tf.getstaffno = p_getStaffNo,                                                
              tf.getcardorderstate = V_GETCARDORDERSTATE                                              
              where tf.getcardorderid = p_getcardorderid;      
          IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;                                          
           EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S094390005'; p_retMsg  := '更新领用单表失败,' || SQLERRM;
            ROLLBACK; RETURN;                                                
    end;
    --插入单据管理台账
    begin
      
          insert into TF_B_ORDERMANAGE 
          (
          TRADEID,                     ORDERTYPECODE,              ORDERID,                OPERATETYPECODE,               ORDERDEMAND,                                                      
          CARDTYPECODE,                CARDSURFACECODE,            CARDSAMPLECODE,         CARDNAME,                      CARDFACEAFFIRMWAY,
          VALUECODE,                   CARDNUM,                         REQUIREDATE,            LATELYDATE,                    ALREADYARRIVENUM,
          RETURNCARDNUM,               BEGINCARDNO,                ENDCARDNO,              CARDCHIPTYPECODE,                            COSTYPECODE,
          MANUTYPECODE,                APPVERNO,                   VALIDBEGINDATE,         VALIDENDDATE,                  APPLYGETNUM,
          AGREEGETNUM,                 ALREADYGETNUM,                             LATELYGETDATE,          GETSTAFFNO,                    OPERATETIME,                   
          OPERATESTAFF,                REMARK
          )                                                                                                            
          values                                                                                                            
          (
          p_seqNo,                    '03',                       p_getcardorderid,            '09',                      null,
          null,                        null,                      null,                         null,                     null,
          v_valuecode,                 null,                                  null,                         null,                     null,
          null,                        p_fromCardNo,              p_toCardNo,                   null,                     null,
          null,                        null,                      null,                         null,                     v_applynum,
          v_agreegetnum,                             p_alreadygetnum,           v_today,                 p_getStaffNo,                  v_today ,
          p_currOper,                  null
          );                                                                                                        
              
          EXCEPTION
              WHEN OTHERS THEN
                  p_retCode := 'S094390002'; p_retMsg  := '更新领用单表失败,' || SQLERRM;
                  ROLLBACK; RETURN;                                                                                            
                                                                                                        
    end;
    

    p_retCode := '0000000000'; p_retMsg  := '';
END;

/
show errors;

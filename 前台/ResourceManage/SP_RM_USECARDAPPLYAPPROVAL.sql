
-- create by Yin   2012/07/18
-- 用户卡领卡申请审批

create or replace procedure SP_RM_USECARDAPPLYAPPROVAL
(
       p_sessionID              varchar2, -- 会话ID
      
       p_currOper     char,           -- Current Operator
       p_currDept     char,           -- Curretn Operator's Department
       p_retCode      out char,       -- Return Code
       p_retMsg       out varchar2    -- Return Message
)
AS 
       v_seqNo          CHAR(16);
       v_operationCode  CHAR(2);
       v_today          date;
       v_ex             EXCEPTION;
BEGIN
   v_today := sysdate;
   BEGIN
       for v_c in (select * from tmp_common where F0 = p_sessionID AND F2 = '01')                                                          
        loop                                                          
            --更新领用单表
            BEGIN                                                       
                  update TF_F_GETCARDORDER t                                                          
                  set t.getcardorderstate = v_c.f3,                                                          
                  t.agreegetnum = v_c.f9,                                                          
                  t.examtime = v_today,                                                          
                  t.examstaffno = v_c.f15                                                          
                  where t.getcardorderid = v_c.f1;  
                  IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
                  exception when others then
                    p_retCode :=   'S094390003';
                    p_retMsg := v_c.f1 || '更新卡片领用单表失败' || sqlerrm;                                              
                    rollback;
                    return;                                                              
            END;   
                                                                   
            if v_c.f3 = '1' then                                                          
               v_operationCode := '05';                                                          
            elsif v_c.f3 = '2' then                                                          
               v_operationCode := '06' ;                                                          
            end if;   
                                                                   
            SP_GetSeq(seq => v_seqNo);
                                                                   
            --写单据管理台账表
            BEGIN                                                         
                  insert into TF_B_ORDERMANAGE 
                  (
                  TRADEID,        ORDERTYPECODE,         ORDERID,             OPERATETYPECODE,
                  ORDERDEMAND,    CARDTYPECODE,          CARDSURFACECODE,     CARDSAMPLECODE,
                  CARDNAME,       CARDFACEAFFIRMWAY,     VALUECODE,           CARDNUM,                                                          
                  REQUIREDATE,    LATELYDATE,            ALREADYARRIVENUM,    RETURNCARDNUM,
                  BEGINCARDNO,    ENDCARDNO,             CARDCHIPTYPECODE,    COSTYPECODE,
                  MANUTYPECODE,   APPVERNO,              VALIDBEGINDATE,      VALIDENDDATE,
                  APPLYGETNUM,    AGREEGETNUM,           ALREADYGETNUM,				LATELYGETDATE,
                  OPERATETIME,    OPERATESTAFF,          REMARK
                  )																													
                  values																													
                  (
                  v_seqNo,       '03',                   v_c.f1,              v_operationCode,
                  null,           v_c.f5,                v_c.f6,              null,
                  null,           null,                  null,                null,																													
                  null,           null,                  null,                null,
                  null,           null,                  null,                null,
                  null,           null,                  null,                null,
                  v_c.f8,         v_c.f9,                0,                   null,
                  v_today,        v_c.f15 ,              v_c.f16
                  );	
                  	
                  exception when others then
                    p_retCode :=   'S094390002';
                    p_retMsg := v_c.f1 || '插入单据管理台账表失败' || sqlerrm;                                              
                    rollback;
                    return;  																										
        		END;																											
        end loop;																													
    END;   
    p_retCode := '0000000000'; p_retMsg  := '';
    COMMIT; RETURN;
END;

/ 
show errors;


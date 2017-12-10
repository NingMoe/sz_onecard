create or replace procedure SP_RM_ResourceMaintainPass
(
       P_SESSION              varchar2, -- 会话ID

       p_currOper     char,           -- Current Operator
       p_currDept     char,           -- Curretn Operator's Department
       p_retCode      out char,       -- Return Code
       p_retMsg       out varchar2    -- Return Message
)
AS
       v_seqNo          CHAR(16);
       V_MAINTAINORDERID varchar2(18);
       V_MAINTAINSTAFF  CHAR(6);
       V_CHECKNOTE			varchar2(255);
       V_RESOURCECODE		varchar2(6);
       v_today          date;
       v_ex             EXCEPTION;
BEGIN
   v_today := sysdate;
   BEGIN
       for v_c in (select * from tmp_common where F1 = P_SESSION)
        loop
        		V_MAINTAINORDERID := v_c.f0;
        		V_CHECKNOTE := v_c.f3;
        		V_RESOURCECODE := v_c.f2;
        		V_MAINTAINSTAFF:= v_c.f4;
            --更新资源维护单表
            BEGIN
                 UPDATE  TF_F_RESOURCEMAINTAINORDER												
								 SET     ORDERSTATE = '1' 			,							
									       CHECKNOTE = V_CHECKNOTE,
									       MAINTAINSTAFF=	V_MAINTAINSTAFF											
								 WHERE   MAINTAINORDERID = V_MAINTAINORDERID;											
                  IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
                  exception when others then
                    p_retCode :=   'S001003401';
                    p_retMsg :=  '更新资源维护单表失败' || sqlerrm;
                    rollback;
                    return;
            END;
            
            SP_GetSeq(seq => v_seqNo);

            --写单据管理台账表
            BEGIN
                 INSERT INTO TF_B_RESOURCEORDERMANAGE(																							
								    TRADEID                 , ORDERTYPECODE         , ORDERID             , OPERATETYPECODE       ,																							
								    ORDERDEMAND             , MAINTAINREASON        , RESOURCECODE        , ATTRIBUTE1            ,																							
								    ATTRIBUTE2              , ATTRIBUTE3            , ATTRIBUTE4          , ATTRIBUTE5            ,																							
								    ATTRIBUTE6              , RESOURCENUM           , REQUIREDATE         , LATELYDATE            ,																							
									ALREADYORDERNUM         , ALREADYARRIVENUM      , APPLYGETNUM         , AGREEGETNUM           ,																						
									ALREADYGETNUM           , LATELYGETDATE         , GETSTAFFNO          , OPERATETIME           ,																						
									OPERATESTAFFNO	        , MAINTAINSTAFF																					
								)VALUES(																							
								    v_seqNo                  ,'04'                  , V_MAINTAINORDERID   ,'14'                   ,																							
								    NULL                     , NULL                 , V_RESOURCECODE      , NULL                  ,																							
								    NULL                     , NULL                 , NULL                , NULL                  ,																							
								    NULL                     , NULL                 , NULL                , NULL                  ,																							
								    0                        , 0                    , NULL                , NULL                ,																							
									0                        , NULL                 , NULL                , V_TODAY              ,   																						
									P_CURROPER  		         , V_MAINTAINSTAFF);																			

                  exception when others then
                    p_retCode := 'S001003402';
                    p_retMsg  := '记录资源单据台帐表失败' || sqlerrm;
                    rollback;
                    return;
        		END;
        end loop;
    END;
    
    --清空临时表
    delete tmp_common where F1 = P_SESSION;
    p_retCode := '0000000000'; p_retMsg  := '';
    COMMIT; RETURN;
END;

/
show error;



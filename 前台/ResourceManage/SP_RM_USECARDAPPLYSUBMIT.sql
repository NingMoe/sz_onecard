
-- create by Yin   2012/07/18
-- �û����쿨����

create or replace procedure SP_RM_USECARDAPPLYSUBMIT
(
       p_USEWAY              varchar2, -- ��;
       p_CARDTYPECODE        varchar2, --��Ƭ����
       p_CARDSURFACECODE     varchar2, --��������
       p_APPLYGETNUM         varchar2, --������������
       P_REMARK              varchar2, --��ע
       
       p_getCardOrderID      out char,
       
       p_currOper     char,           -- Current Operator
       p_currDept     char,           -- Curretn Operator's Department
       p_retCode      out char,       -- Return Code
       p_retMsg       out varchar2    -- Return Message
)
AS 
       v_seqNo          CHAR(16);
       v_getCardOrderID CHAR(18);
       v_today          date;
       v_ex             EXCEPTION;
BEGIN
   v_today := sysdate;
   SP_GetSeq(seq => v_seqNo); 
   v_getCardOrderID := 'LY' || v_seqNo;
   BEGIN
       --�������õ���                                                    
        insert into TF_F_GETCARDORDER  
        (
        GETCARDORDERID,               GETCARDORDERTYPE,       GETCARDORDERSTATE,          USETAG,           USEWAY,
        CARDTYPECODE,                 CARDSURFACECODE,        VALUECODE,                  APPLYGETNUM,      AGREEGETNUM,
        ALREADYGETNUM,                LATELYGETDATE,          GETSTAFFNO,                 ORDERTIME,        ORDERSTAFFNO,    
        EXAMTIME,                     EXAMSTAFFNO,           REMARK   ,                   PRINTCOUNT
        )                                                     
        values                                                    
        (
        v_getCardOrderID,               '01',                  '0',                        '1',              p_USEWAY,
        p_CARDTYPECODE,                 p_CARDSURFACECODE,     null,                      p_APPLYGETNUM,        0,
        0,                              null,                  null,                       v_today,          p_currOper,
        null,                            null,                 P_REMARK,                   0
        );                                                  
        EXCEPTION WHEN OTHERS THEN
            p_retCode :=   'S094390001';
            p_retMsg := '���뿨Ƭ���õ���ʧ��' || sqlerrm;                                              
            rollback;
            return;
    END;
    
    BEGIN
        --д���ݹ���̨�˱�                                                    
        insert into TF_B_ORDERMANAGE 
        (
        TRADEID,               ORDERTYPECODE,             ORDERID,             OPERATETYPECODE,        ORDERDEMAND,                                                    
        CARDTYPECODE,          CARDSURFACECODE,           CARDSAMPLECODE,      CARDNAME,               CARDFACEAFFIRMWAY,
        VALUECODE,             CARDNUM,                    REQUIREDATE,         LATELYDATE,             ALREADYARRIVENUM,
        RETURNCARDNUM,         BEGINCARDNO,               ENDCARDNO,           CARDCHIPTYPECODE,       COSTYPECODE,
        MANUTYPECODE,          APPVERNO,                  VALIDBEGINDATE,      VALIDENDDATE,           APPLYGETNUM,
        AGREEGETNUM,           ALREADYGETNUM,              LATELYGETDATE,       GETSTAFFNO,              OPERATETIME,            
        OPERATESTAFF,          REMARK
        )                                                    
        values                                                    
        (
        v_seqNo,              '03',                       v_getCardOrderID,        '02',                  null,
        p_CARDTYPECODE,        p_CARDSURFACECODE,         null,                    null,                  null,
        null,                  null,                      null,                    null,                  null,
        null,                  null,                      null,                    null,                  null,
        null,                  null,                      null,                    null,                  p_APPLYGETNUM,
        0,                     0,                         null,                    null,                  v_today ,           
        p_currOper,            P_REMARK
        )  ;                                                
                                                            
        EXCEPTION WHEN OTHERS THEN
            p_retCode :=   'S094390002';
            p_retMsg := '���뵥�ݹ���̨�˱�ʧ��' || sqlerrm;                                              
            rollback;
            return;                                        

    END;   
    
    p_getCardOrderID := v_getCardOrderID;
    
    p_retCode := '0000000000'; p_retMsg  := '';
    COMMIT; RETURN;
   
END;

/ 
show errors;


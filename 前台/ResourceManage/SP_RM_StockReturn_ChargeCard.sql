
--��ֵ���˿�   Yin  2012-07-24

CREATE OR REPLACE PROCEDURE SP_RM_StockReturn_ChargeCard
(
    p_fromCardNo     char, --��ʼ����
    p_toCardNo       char, --��������
    p_returnReason   char, --�˿�ԭ��
    p_seqNo          char, --��ˮ��

    
    p_currOper  char,
    p_currDept  char,
    p_retCode   out char, -- Return Code
    p_retMsg    out varchar2  -- Return Message
) 
AS

    v_fromCard     numeric(8);
    v_toCard       numeric(8);
    v_ex           exception ;
    v_quantity     int;
    v_today        date:=sysdate;
    v_seqNo         CHAR(16);  
    v_valuecode char(1); --��Ƭ���
    v_applynum  int;
    v_agreegetnum  int;
    v_alreadynum   int;    
    V_GETCARDORDERSTATE char(1);
    
    v_begin  char(14);
    v_end    char(14);
    v_count  int;
    
    v_FCard char(14); --�����˿��ÿ�����õ��е���ʼ����
    v_ECard char(14); --�����˿��ÿ�����õ��еĽ�������
    
BEGIN

    v_fromCard := TO_NUMBER(SUBSTR(p_fromCardNo, -8));
    v_toCard   := TO_NUMBER(SUBSTR(p_toCardNo  , -8));
    v_quantity := v_toCard - v_fromCard + 1;
	v_seqNo := p_seqNo;

    -- 1) Update the voucher card info
    BEGIN
        UPDATE TD_XFC_INITCARD			
        SET    OUTTIME    = null ,			
               OUTSTAFFNO = null ,			
               ASSIGNDEPARTNO   = null,			
               CARDSTATECODE='2'   --���״̬			
        WHERE  CARDSTATECODE = '3' --����״̬			
        AND    XFCARDNO BETWEEN p_fromCardNo AND p_toCardNo;			

        IF  SQL%ROWCOUNT != v_quantity THEN RAISE v_ex; END IF;
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S007P04C01'; p_retMsg := '���³�ֵ��״̬ʧ��,' || SQLERRM;
        ROLLBACK; RETURN;
    END;
    -- 2) Log the card operation
    BEGIN
        INSERT INTO TL_XFC_MANAGELOG
            (ID,STAFFNO,OPERTIME,OPERTYPECODE,STARTCARDNO,ENDCARDNO,RETURNREASON)
        VALUES
            (v_seqNo,p_currOper,v_today,'08',p_fromCardNo,p_toCardNo,p_returnReason);
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S007P04C02'; p_retMsg := '���³�ֵ�����������־ʧ��,' || SQLERRM;
        ROLLBACK; RETURN;
    END;
    
    
    --�鵥�ݹ���̨�ˣ�����������ڵ����õ���
    select BEGINCARDNO  into v_begin from 
    (
        select * from TF_B_ORDERMANAGE 
        where  TO_NUMBER(SUBSTR(BEGINCARDNO, -8)) <= TO_NUMBER(SUBSTR(p_fromCardNo, -8)) 
        and substr(BEGINCARDNO,1,6) = substr(p_fromCardNo,1,6)  
        and    TO_NUMBER(SUBSTR(ENDCARDNO, -8))  >=  TO_NUMBER(SUBSTR(p_fromCardNo, -8)) 
        and substr(ENDCARDNO,1,6)   = substr(p_fromCardNo,1,6)  
        and    OPERATETYPECODE = '09' 
        and ORDERTYPECODE = '03' 
        and VALUECODE is not null
        order by operatetime desc
    )
    where rownum = 1;
    
    select BEGINCARDNO into v_end from 
    (
        select * from TF_B_ORDERMANAGE 
        where  TO_NUMBER(SUBSTR(BEGINCARDNO, -8)) <= TO_NUMBER(SUBSTR(p_toCardNo, -8))  
        and  substr(BEGINCARDNO,1,6) = substr(p_toCardNo,1,6) 
        and    TO_NUMBER(SUBSTR(ENDCARDNO, -8))   >= TO_NUMBER(SUBSTR(p_toCardNo, -8))  
        and  substr(ENDCARDNO,1,6)   = substr(p_toCardNo,1,6) 
        and    OPERATETYPECODE = '09' 
        and ORDERTYPECODE = '03' 
        and VALUECODE is not null
        order by operatetime desc
    )
    where rownum = 1;
   
     begin
           for v_c in 
             (
                  select tf.orderid,max(tf.operatetime),tf.begincardno,tf.endcardno,tf.getstaffno
                  from TF_B_ORDERMANAGE tf 
                  where BEGINCARDNO between v_begin and v_end
                  and tf.ordertypecode = '03'
                  and tf.operatetypecode = '09'
                  and tf.valuecode is not null
                  group by tf.orderid,tf.begincardno,tf.endcardno,tf.getstaffno
              )
             
           loop
                if  TO_NUMBER(SUBSTR( v_c.begincardno, -8)) >= TO_NUMBER(SUBSTR(p_fromCardNo, -8))  
                    and TO_NUMBER(SUBSTR(v_c.endcardno, -8))  >= TO_NUMBER(SUBSTR(p_toCardNo, -8)) then
                  begin
                     v_count := TO_NUMBER(SUBSTR(p_toCardNo, -8)) - TO_NUMBER(SUBSTR(v_c.begincardno, -8)) + 1;  --�������õ����˿�����
                     v_FCard := v_c.begincardno;
                     v_ECard := p_toCardNo;
                  end;   
               elsif TO_NUMBER(SUBSTR(v_c.begincardno, -8))  >= TO_NUMBER(SUBSTR(p_fromCardNo, -8))  
                      and TO_NUMBER(SUBSTR(v_c.endcardno, -8)) < TO_NUMBER(SUBSTR(p_toCardNo, -8))  then  
                  begin
                      v_count := TO_NUMBER(SUBSTR(v_c.endcardno, -8)) - TO_NUMBER(SUBSTR(v_c.begincardno, -8)) + 1;  --�������õ����˿�����
                      v_FCard := v_c.begincardno;
                      v_ECard := v_c.endcardno;
                  end;    
               elsif TO_NUMBER(SUBSTR(v_c.begincardno, -8)) <= TO_NUMBER(SUBSTR(p_fromCardNo, -8))  
                     and TO_NUMBER(SUBSTR(v_c.endcardno, -8))  >= TO_NUMBER(SUBSTR(p_toCardNo, -8))  then
                  begin   
                      v_count := TO_NUMBER(SUBSTR(p_toCardNo, -8)) - TO_NUMBER(SUBSTR(p_fromCardNo, -8)) + 1;  --�������õ����˿�����
                      v_FCard := p_fromCardNo;
                      v_ECard := p_toCardNo;
                  end;    
               elsif TO_NUMBER(SUBSTR(v_c.begincardno, -8))  <= TO_NUMBER(SUBSTR(p_fromCardNo, -8))  
                     and TO_NUMBER(SUBSTR(v_c.endcardno, -8))  <= TO_NUMBER(SUBSTR(p_toCardNo, -8))  then
                  begin    
                      v_count := TO_NUMBER(SUBSTR(v_c.endcardno, -8)) - TO_NUMBER(SUBSTR(p_fromCardNo, -8)) + 1;  --�������õ����˿�����
                      v_FCard := p_fromCardNo;
                      v_ECard := v_c.endcardno;
                  end;
               end if;
               
               --�������õ���
              select APPLYGETNUM, AGREEGETNUM, ALREADYGETNUM, VALUECODE
              into  v_applynum, v_agreegetnum, v_alreadynum, v_valuecode   
              from TF_F_GETCARDORDER where getcardorderid = v_c.orderid;		
              																						
              /*if v_alreadynum - v_count > 0	then																							
                  V_GETCARDORDERSTATE := '3'; --��������
                  begin																					
                      update TF_F_GETCARDORDER tf set tf.alreadygetnum = v_alreadynum - v_count,																								
                          tf.getcardorderstate = V_GETCARDORDERSTATE																							
                          where tf.getcardorderid = v_c.orderid;	
                      IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;																							
                      EXCEPTION
                      WHEN OTHERS THEN
                          p_retCode := 'S094390005'; p_retMsg  := '�������õ���ʧ��,' || SQLERRM;
                          ROLLBACK; RETURN;																								
                  end;																								
              else																								
                  V_GETCARDORDERSTATE := '1'; --�ָ������ͨ��״̬
                  begin																					
                      update TF_F_GETCARDORDER tf set tf.alreadygetnum = v_alreadynum - v_count,																								
                          tf.latelygetdate = null,tf.getstaffno = null,																								
                          tf.getcardorderstate = V_GETCARDORDERSTATE																							
                          where tf.getcardorderid = v_c.orderid;	
                      IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;																							
                      EXCEPTION
                      WHEN OTHERS THEN
                          p_retCode := 'S094390005'; p_retMsg  := '�������õ���ʧ��,' || SQLERRM;
                          ROLLBACK; RETURN;																								
                  end;																									
              end if;*/
              
                --���뵥�ݹ���̨��
                begin
                              
                    insert into TF_B_ORDERMANAGE 
                    (
                    TRADEID,                     ORDERTYPECODE,              ORDERID,                OPERATETYPECODE,               ORDERDEMAND,																											
                    CARDTYPECODE,                CARDSURFACECODE,            CARDSAMPLECODE,         CARDNAME,                      CARDFACEAFFIRMWAY,
                    VALUECODE,                   CARDNUM,							       REQUIREDATE,            LATELYDATE,                    ALREADYARRIVENUM,
                    RETURNCARDNUM,               BEGINCARDNO,                ENDCARDNO,              CARDCHIPTYPECODE,							COSTYPECODE,
                    MANUTYPECODE,                APPVERNO,                   VALIDBEGINDATE,         VALIDENDDATE,                  APPLYGETNUM,
                    AGREEGETNUM,                 ALREADYGETNUM,							 LATELYGETDATE,          GETSTAFFNO,                    OPERATETIME,                   
                    OPERATESTAFF,                REMARK
                    )																											
                    values																											
                    (
                    v_seqNo,                    '03',                       v_c.orderid,                 '10',                     null,
                    null,                        null,                      null,                        null,                     null,
                    v_valuecode,                 v_count,										null,                        null,                     null,
                    null,                        v_FCard,                   v_ECard,                     null,                     null,
                    null,                        null,                      null,                        null,                     v_applynum,
                    v_agreegetnum,							 v_alreadynum - v_count,    v_today,                     null,                     v_today ,
                    p_currOper,                  null
                    );																										
                              		
                    EXCEPTION
                    WHEN OTHERS THEN
                    p_retCode := 'S094390002'; p_retMsg  := '�������õ���ʧ��,' || SQLERRM;
                    ROLLBACK; RETURN;
                        																										
                end;
				--���»�ȡ��ˮ��
                SP_GetSeq(seq => v_seqNo);
           
           end loop;
     end;
    
    p_retCode := '0000000000'; p_retMsg  := '';
END;

/
show errors;


--�û����˿� Create by Yin 20120720

CREATE OR REPLACE PROCEDURE SP_RM_StockReturn
(
    p_fromCardNo     char,    -- From Card No.
    p_toCardNo       char,    -- End  Card No.
    p_returnReason   varchar2, --�˿�ԭ��
    p_seqNo          out char,
    p_currOper       char, -- Current Operator
    p_currDept       char, -- Curretn Operator's Department
    p_retCode        out char, -- Return Code
    p_retMsg         out varchar2  -- Return Message
)
AS
 
    v_fromCard      numeric(16);
    v_toCard        numeric(16);
    v_cardNo        char(16);
    v_quantity      int;
    v_dbquantity    int;
    v_today         date := sysdate;
    v_ex            EXCEPTION;
	  v_seqNo         CHAR(16);  
    V_CARDPRICE     int;
    v_assignedDept  CHAR(4);
    V_IsDepaBal     int;
    V_DBALUNITNO    CHAR(8);

    
    v_cardType      char(2);  --��Ƭ����
    v_cardFaceType  char(4); --��������
    v_applynum      int;
    v_agreegetnum   int;
    v_alreadynum    int;
    V_GETCARDORDERSTATE char(1);
    
    v_count int; --���õ����˿�Ŀ�Ƭ����
    
    v_FCard  char(16);
    v_ECard  char(16);
    
BEGIN
    -- 1) tell the consistence of v_quantity 
    v_fromCard := TO_NUMBER(p_fromCardNo);
    v_toCard   := TO_NUMBER(p_toCardNo);
    v_quantity := v_toCard - v_fromCard + 1;

    SELECT COUNT(*) INTO v_dbquantity
    FROM TL_R_ICUSER
    WHERE CARDNO BETWEEN p_fromCardNo AND p_toCardNo
    AND   RESSTATECODE = '01' ;   -- ����״̬
    IF v_quantity != v_dbquantity THEN
        p_retCode := 'A094392B01'; p_retMsg  := '�˿⿨Ƭ��ȫΪ����״̬';
        RETURN; 
    END IF;    

    -- 2) update the ic card stock table
    BEGIN
        UPDATE  TL_R_ICUSER
        SET UPDATETIME       = v_today ,
            UPDATESTAFFNO    = p_currOper ,
            ASSIGNEDSTAFFNO  = null,
            ASSIGNEDDEPARTID = null ,
            SERVICECYCLE     = null ,
            EVESERVICEPRICE  = null ,
            RESSTATECODE     = '00',   -- stockin
            OUTTIME          = null,
            SALETYPE         = null,
            CARDPRICE        = 0  
        WHERE CARDNO  BETWEEN p_fromCardNo AND p_toCardNo
        AND   RESSTATECODE   = '01';  -- ����״̬  
        
        IF  SQL%ROWCOUNT != v_quantity THEN RAISE v_ex; END IF;
        EXCEPTION
            WHEN OTHERS THEN
                p_retCode := 'S002P02B02'; p_retMsg  := '����IC�������Ϣʧ��,' || SQLERRM;
                ROLLBACK; RETURN;
    END;

    -- 3) add the value-return information
    
    BEGIN
        
        delete from TF_F_CARDEWALLETACC_BACK where cardno between p_fromCardNo and p_toCardNo;
        /*LOOP
            v_cardNo := SUBSTR('0000000000000000' || TO_CHAR(v_fromCard), -16);
    
            delete from TF_F_CARDEWALLETACC_BACK where cardno = v_cardNo;
                
            EXIT WHEN v_fromCard >= v_toCard;
            
            v_fromCard := v_fromCard + 1;
        END LOOP; */
        EXCEPTION
            WHEN OTHERS THEN
                p_retCode := 'S094390007'; p_retMsg  := 'ɾ����Ƭ��ֵ��Ϣʧ��,' || SQLERRM;
                ROLLBACK; RETURN;
    END;
    

	--�鵥�ݹ���̨�ˣ�����������ڵ����õ���
    BEGIN
    select BEGINCARDNO into v_fromCard from 
    (
        select * from TF_B_ORDERMANAGE 
        where BEGINCARDNO <= p_fromCardNo 
        and ENDCARDNO >= p_fromCardNo 
        and OPERATETYPECODE = '09' 
        and ORDERTYPECODE = '03' 
        order by operatetime desc
    ) 
    where rownum = 1;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
		p_retCode := 'S094570111'; p_retMsg  := 'δ�ҵ���ʼ�����������õ�';
		ROLLBACK;RETURN;  
	END;
	
    BEGIN    
    select BEGINCARDNO into v_toCard from 
    (
        select * from TF_B_ORDERMANAGE 
        where BEGINCARDNO <= p_toCardNo 
        and ENDCARDNO >= p_toCardNo 
        and OPERATETYPECODE = '09' 
        and ORDERTYPECODE = '03'
        order by operatetime desc
    )
    where rownum = 1;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
		p_retCode := 'S094570120'; p_retMsg  := 'δ�ҵ����������������õ�';
		ROLLBACK;RETURN;	
	END;
   
     begin
           for v_c in 
             (
                 select tf.orderid,max(tf.operatetime),tf.begincardno,tf.endcardno,tf.getstaffno
                 from TF_B_ORDERMANAGE tf 
                 where BEGINCARDNO between to_char(v_fromCard) and to_char(v_toCard)
                 and tf.ordertypecode = '03'
                 and tf.operatetypecode = '09'
                 group by tf.orderid,tf.begincardno,tf.endcardno,tf.getstaffno
             )
           loop
             
               if v_c.begincardno >= p_fromCardNo and v_c.endcardno >= p_toCardNo then
                 begin
                     v_count := to_number(p_toCardNo) - to_number(v_c.begincardno) + 1;  --�������õ����˿�����
                     v_FCard := v_c.begincardno;
                     v_ECard := p_toCardNo;
                  end;   
               elsif v_c.begincardno >= p_fromCardNo and v_c.endcardno < p_toCardNo then  
                  begin
                      v_count := to_number(v_c.endcardno) - to_number(v_c.begincardno) + 1;  --�������õ����˿�����
                      v_FCard := v_c.begincardno;
                      v_ECard := v_c.endcardno;
                   end;   
               elsif v_c.begincardno <= p_fromCardNo and v_c.endcardno >= p_toCardNo then
                   begin  
                      v_count := to_number(p_toCardNo) - to_number(p_fromCardNo) + 1;  --�������õ����˿�����
                      v_FCard := p_fromCardNo;
                      v_ECard := p_toCardNo;
                   end;   
               elsif v_c.begincardno <= p_fromCardNo and v_c.endcardno <= p_toCardNo then
                   begin   
                      v_count := to_number(v_c.endcardno) - to_number(p_fromCardNo) + 1;  --�������õ����˿�����
                      v_FCard := p_fromCardNo;
                      v_ECard := v_c.endcardno;
                   end;
               end if;
               
               --�������Ӫҵ����֤��
               BEGIN
                    SELECT DEPARTNO INTO v_assignedDept
                        FROM  TD_M_INSIDESTAFF
                        WHERE STAFFNO = v_c.getstaffno;
                    EXCEPTION
                        WHEN OTHERS THEN
                            p_retCode := 'A002P04D02'; p_retMsg  := '�޷��õ�����Ա�����ڵĲ��ű���' || SQLERRM;
                            RETURN;
                END;
            
                --����Ǵ���Ӫҵ���쿨�����������㵥Ԫ��֤���˻���
                SELECT COUNT(*) INTO V_IsDepaBal 																	
                FROM TD_DEPTBAL_RELATION a,TF_DEPT_BALUNIT b																	
                WHERE  a.DEPARTNO = v_assignedDept																	
                AND    a.DBALUNITNO = b.DBALUNITNO
                AND    b.USETAG = '1'
                AND    a.USETAG = '1'
                AND    b.DEPTTYPE = '1';

                IF  V_IsDepaBal != 0 THEN --����Ǵ���Ӫҵ��
                  
                    --��ȡ������㵥Ԫ����
                    SELECT DBALUNITNO INTO V_DBALUNITNO FROM TD_DEPTBAL_RELATION WHERE USETAG = '1' AND DEPARTNO = v_assignedDept; 
                    
                    --��ȡ�û�����ֵ
                    SELECT TAGVALUE INTO V_CARDPRICE FROM TD_M_TAG WHERE TAGCODE = 'USERCARD_MONEY'; 
                   
                    BEGIN
                        --�ָ�������㵥Ԫ��֤���˻���
                        UPDATE TF_F_DEPTBAL_DEPOSIT
                        SET    USABLEVALUE   = USABLEVALUE + v_count * V_CARDPRICE		,
                               STOCKVALUE    = STOCKVALUE  - v_count * V_CARDPRICE		,
                               UPDATESTAFFNO = P_CURROPER		,
                               UPDATETIME    = V_TODAY
                        WHERE  ACCSTATECODE  = '01'
                        AND    DBALUNITNO    = V_DBALUNITNO;
                        IF  SQL%ROWCOUNT    != 1 THEN RAISE V_EX; END IF;
                        EXCEPTION WHEN OTHERS THEN
                            P_RETCODE := 'S008905101';
                            P_RETMSG  := '����������㵥Ԫ��֤���˻���ʧ��'|| SQLERRM;
                        ROLLBACK;RETURN;
                    END;
                   											
                END IF;	
                
                -- 4) ��¼�û���������̨�˱�
                -- get the sequence number 
                SP_GetSeq(seq => v_seqNo);
                    
                BEGIN
                    INSERT INTO TF_R_ICUSERTRADE
                       (
                           TRADEID,            OPETYPECODE,       BEGINCARDNO,         ENDCARDNO,           CARDNUM,  
                           COSTYPECODE,        CARDTYPECODE,      MANUTYPECODE,        CARDSURFACECODE,     CARDCHIPTYPECODE,
                           CARDPRICE,          CARDAMOUNTPRICE,   ASSIGNEDSTAFFNO,     ASSIGNEDDEPARTID,    OPERATESTAFFNO,  
                           OPERATEDEPARTID,    OPERATETIME,       RETURNREASON,        RSRV1
                       )
                    VALUES  
                       (
                            v_seqNo,               '21',          v_FCard,             v_ECard,             v_count, 
                            null,                  null,          null,                null,                null,
                            null,                  null,          null,                null,                p_currOper,
                            p_currDept,           v_today,        p_returnReason,      null
                       );
                    EXCEPTION
                        WHEN OTHERS THEN
                            p_retCode := 'S002P02B04'; p_retMsg  := '����IC��������־ʧ��,' || SQLERRM;
                            ROLLBACK; RETURN;
                END;	        
               
               --�������õ���
                select APPLYGETNUM, AGREEGETNUM, ALREADYGETNUM, CARDTYPECODE, CARDSURFACECODE
                into  v_applynum, v_agreegetnum, v_alreadynum, v_cardType, v_cardFaceType   
                from TF_F_GETCARDORDER where getcardorderid = v_c.orderid;	
                																							
                /*if v_alreadynum - v_count > 0	then																							
                    V_GETCARDORDERSTATE := '3'; --��������
                    begin																					
                        update TF_F_GETCARDORDER tf set tf.alreadygetnum = v_alreadynum - v_count,																								
                            tf.getcardorderstate = V_GETCARDORDERSTATE																							
                            where tf.getcardorderid = v_c.orderid;	
                        IF SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;																							
                        EXCEPTION
                        WHEN OTHERS THEN
                            p_retCode := 'S094390005'; p_retMsg  := '�������õ���ʧ��,' || SQLERRM;
                            ROLLBACK; RETURN;																								
                    end;																								
                else																								
                    V_GETCARDORDERSTATE := '1'; --�ָ������ͨ��״̬
                    begin																					
                        update TF_F_GETCARDORDER tf set tf.alreadygetnum = v_alreadynum - v_count,																								
                            tf.latelygetdate = null,tf.getstaffno = null																								
                            ,tf.getcardorderstate = V_GETCARDORDERSTATE																							
                            where tf.getcardorderid = v_c.orderid;
                        IF SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;																							
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
                        v_cardType,                  v_cardFaceType,            null,                        null,                     null,
                        null,                        v_count,										null,                        null,                     null,
                        null,                        v_FCard,                   v_ECard,                     null,                     null,
                        null,                        null,                      null,                        null,                     v_applynum,
                        v_agreegetnum,							 v_alreadynum - v_count,    null,                        null,                     v_today ,
                        p_currOper,                  null
                    );																										
                  		
                    EXCEPTION
                    WHEN OTHERS THEN
                    p_retCode := 'S094390002'; p_retMsg  := '���뵥�ݹ���̨�˱�ʧ��,' || SQLERRM;
                    ROLLBACK; RETURN;																							
            																										
                end;
                
           end loop;
     end;
     
    p_seqNo := v_seqNo;
    
    p_retCode := '0000000000'; 
    p_retMsg  := '';
    
    RETURN;
    
END;
/

show errors;

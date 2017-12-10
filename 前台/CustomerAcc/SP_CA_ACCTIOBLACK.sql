create or replace procedure SP_CA_ACCTIOBLACK
(
    p_funcCode     varchar2 , --ҵ������
    p_cardno       char     , --����
    
    p_currOper     char     , --��ǰ������
    p_currDept     char     , --��ǰ�����߲���
    p_retCode  out char     , --�������
    p_retMsg   out varchar2   --������Ϣ
)
AS
    v_funcCode        varchar2(16) := p_funcCode ;
    v_today           date         := sysdate    ;
    v_state           varchar2(2) ;
    v_seq             CHAR(16)    ;
    v_ex              EXCEPTION   ;

BEGIN

	   IF v_funcCode = 'ACCTINTOBLACK' THEN --ר���˻�����������˻�����
         --ר���˻��Ƿ��Ѿ�������
         select nvl((select STATE from TF_F_CUST_ACCT where ICCARD_NO = p_cardno),'') into v_state from dual;

         --����˻����ڲ���û�б�����
         if v_state is not null and v_state != 'B' then
         
         --���ݿͻ��˻���ʷ��
         BEGIN
             INSERT INTO TF_F_CUST_ACCT_HIS(
             ICCARD_NO            , ACCT_ID               , CUST_ID              , ACCT_NAME             ,
             STATE                , STATE_DATE            , CREATE_DATE          , EFF_DATE              ,
             ACCT_PAYMENT_TYPE    , ACCT_BALANCE          , REL_BALANCE          , 
             CUST_PASSWORD        , TOTAL_CONSUME_TIMES   , TOTAL_SUPPLY_TIMES   , TOTAL_CONSUME_MONEY   ,
             TOTAL_SUPPLY_MONEY   , LAST_CONSUME_TIME     , LAST_SUPPLY_TIME     , LIMIT_DAYAMOUNT       ,
             AMOUNT_TODAY         , LIMIT_EACHTIME        , CODEERRORTIMES       , 
             BAK_DATE
             )SELECT 
             ICCARD_NO            , ACCT_ID               , CUST_ID              , ACCT_NAME             ,
             STATE                , STATE_DATE            , CREATE_DATE          , EFF_DATE              ,
             ACCT_PAYMENT_TYPE    , ACCT_BALANCE          , REL_BALANCE          ,  
             CUST_PASSWORD        , TOTAL_CONSUME_TIMES   , TOTAL_SUPPLY_TIMES   , TOTAL_CONSUME_MONEY   , 
             TOTAL_SUPPLY_MONEY   , LAST_CONSUME_TIME     , LAST_SUPPLY_TIME     , LIMIT_DAYAMOUNT       ,
	           AMOUNT_TODAY         , LIMIT_EACHTIME        , CODEERRORTIMES       , 
             v_today
             FROM  TF_F_CUST_ACCT 
             WHERE ICCARD_NO = p_cardno;

         EXCEPTION
             WHEN OTHERS THEN
             P_RETCODE := 'S006001124';
             P_RETMSG  := 'д��ͻ��˻���ʷ��ʧ��' || SQLERRM;
             ROLLBACK; RETURN;
         END;
                   
         --���¿ͻ��˻���״̬
         BEGIN
             UPDATE  TF_F_CUST_ACCT 
             SET     STATE = 'B' 
             WHERE   ICCARD_NO = p_cardno;
             
             IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
         EXCEPTION
             WHEN OTHERS THEN
             P_RETCODE := 'S006001123';
             P_RETMSG  := '���¿ͻ��˻���ʧ��' || SQLERRM;
             ROLLBACK; RETURN;
         END;
         
         --��������˱���״̬
         BEGIN
             UPDATE  TF_F_ACCT_BALANCE
             SET     STATE = 'B'
             WHERE   ICCARD_NO = p_cardno;

             IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
         EXCEPTION
             WHEN OTHERS THEN
             P_RETCODE := 'A099001102';
             P_RETMSG  := '��������˱���ʧ��' || SQLERRM;
             ROLLBACK; RETURN;
         END;
         
         --��¼ҵ����̨��
         BEGIN
              SP_GETSEQ(SEQ => V_SEQ);

             INSERT INTO TF_B_TRADE(
                   TRADEID       , CARDNO         , TRADETYPECODE    , ASN          , 
                   CARDTYPECODE  , OPERATESTAFFNO , OPERATEDEPARTID  , OPERATETIME
            )SELECT    
                  V_SEQ          , CARDNO         , '8M'               , ASN          ,
                  CARDTYPECODE   , p_currOper     , p_currDept       , v_today
             FROM TF_F_CARDREC
             WHERE CARDNO = P_CARDNO;

         EXCEPTION
             WHEN OTHERS THEN
             P_RETCODE := 'A099001103';
             P_RETMSG  := '��¼ҵ����̨�˱�ʧ��' || SQLERRM;
             ROLLBACK; RETURN;
         END;

        end if;
         
     END IF;
     
     IF v_funcCode = 'ACCTOUTBLACK' THEN --ר���˻������������˻�״̬��ԭ
     
         --��ȡ�˻�����ǰ״̬
         select   nvl((
         select   STATE 
         from(
         select   STATE 
         from     TF_F_CUST_ACCT_HIS 
         where    iccard_no = p_cardno
         order by bak_date desc)
         where    rownum <= 1),'') 
         into     v_state 
         from     dual;
         
         --��������ʷ��״̬��Ϊ�գ�ר���˻���ԭ����ǰ״̬
         if v_state is not null then
         
             --���ݿͻ��˻���ʷ��
             BEGIN
                 INSERT INTO TF_F_CUST_ACCT_HIS(
                 ICCARD_NO            , ACCT_ID               , CUST_ID              , ACCT_NAME             ,
                 STATE                , STATE_DATE            , CREATE_DATE          , EFF_DATE              ,
                 ACCT_PAYMENT_TYPE    , ACCT_BALANCE          , REL_BALANCE          , 
                 CUST_PASSWORD        , TOTAL_CONSUME_TIMES   , TOTAL_SUPPLY_TIMES   , TOTAL_CONSUME_MONEY   ,
                 TOTAL_SUPPLY_MONEY   , LAST_CONSUME_TIME     , LAST_SUPPLY_TIME     , LIMIT_DAYAMOUNT       ,
                 AMOUNT_TODAY         , LIMIT_EACHTIME        , CODEERRORTIMES       , 
                 BAK_DATE
                 )SELECT 
                 ICCARD_NO            , ACCT_ID               , CUST_ID              , ACCT_NAME             ,
                 STATE                , STATE_DATE            , CREATE_DATE          , EFF_DATE              ,
                 ACCT_PAYMENT_TYPE    , ACCT_BALANCE          , REL_BALANCE          ,  
                 CUST_PASSWORD        , TOTAL_CONSUME_TIMES   , TOTAL_SUPPLY_TIMES   , TOTAL_CONSUME_MONEY   , 
                 TOTAL_SUPPLY_MONEY   , LAST_CONSUME_TIME     , LAST_SUPPLY_TIME     , LIMIT_DAYAMOUNT       ,
	               AMOUNT_TODAY         , LIMIT_EACHTIME        , CODEERRORTIMES       , 
                 v_today
                 FROM  TF_F_CUST_ACCT 
                 WHERE ICCARD_NO = p_cardno;

             EXCEPTION
                 WHEN OTHERS THEN
                 P_RETCODE := 'S006001124';
                 P_RETMSG  := 'д��ͻ��˻���ʷ��ʧ��' || SQLERRM;
                 ROLLBACK; RETURN;
             END;
             
             --��ԭ�ͻ��˻���
             BEGIN
                 UPDATE  TF_F_CUST_ACCT 
                 SET     STATE = v_state 
                 WHERE   ICCARD_NO = p_cardno;
             
                 IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
             EXCEPTION
                 WHEN OTHERS THEN
                 P_RETCODE := 'S006001123';
                 P_RETMSG  := '���¿ͻ��˻���ʧ��' || SQLERRM;
                 ROLLBACK; RETURN;
             END;
             
             --��ԭ����˱���
             BEGIN
                 UPDATE  TF_F_ACCT_BALANCE
                 SET     STATE = v_state
                 WHERE   ICCARD_NO = p_cardno;

                 IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
             EXCEPTION
                 WHEN OTHERS THEN
                 P_RETCODE := 'A099001102';
                 P_RETMSG  := '��������˱���ʧ��' || SQLERRM;
                 ROLLBACK; RETURN;
             END;
             
             --��¼ҵ����̨��
             BEGIN
                 SP_GETSEQ(SEQ => V_SEQ);

                 INSERT INTO TF_B_TRADE(
                       TRADEID       , CARDNO         , TRADETYPECODE    , ASN          , 
                       CARDTYPECODE  , OPERATESTAFFNO , OPERATEDEPARTID  , OPERATETIME
                )SELECT    
                       V_SEQ         , CARDNO         , '8N'               , ASN          ,
                       CARDTYPECODE  , p_currOper     , p_currDept       , v_today
                 FROM TF_F_CARDREC
                 WHERE CARDNO = P_CARDNO;

             EXCEPTION
                 WHEN OTHERS THEN
                 P_RETCODE := 'A099001103';
                 P_RETMSG  := '��¼ҵ����̨�˱�ʧ��' || SQLERRM;
                 ROLLBACK; RETURN;
             END;
             
         else 
             P_RETCODE := 'S006001130';
         	   P_RETMSG  := 'δ�ҵ�����ͻ���ʷ���¼' || SQLERRM;
             ROLLBACK; RETURN;
         end if;
     
     END IF;
     
     p_retCode := '0000000000'; p_retMsg  := '�ɹ�';
     return;

END;
/
show errors
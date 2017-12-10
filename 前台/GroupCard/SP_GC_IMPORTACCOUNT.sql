CREATE OR REPLACE PROCEDURE SP_GC_IMPORTACCOUNT
(
    p_sessionID       char,
    P_OUTRETMSG       out varchar2,
    P_CURROPER        CHAR,
    P_CURRDEPT        CHAR,
    p_retCode         out char, -- Return Code
    p_retMsg          out varchar2  -- Return Message
)
AS
    v_seqNo           CHAR(16);
    V_TODAY           DATE:=SYSDATE;
    V_EX              EXCEPTION;
    v_CHECKID         char(16);
    V_RETMSG2         varchar2(30000);
    v_tradeDate       char(8);       --��������
    v_money           int;           --������
    v_openBank        varchar2(100); --�Է�������
    v_accountName     varchar2(100); --�Է�������
    v_accountNumber   varchar2(20);  --�Է��˺�
    v_explain         varchar2(200); --����˵��
    v_summary         varchar2(200); --����ժҪ
    v_postScript      varchar2(200); --���׸���
    v_toAccountBank   varchar2(100); --��������
    v_toAccountNumber varchar2(20);  --�����˺�
    

   

BEGIN
V_RETMSG2:='';
  for v_c in (select * from tmp_common where f10 = p_sessionID)
    loop
      
    /*    select count(*) into v_count from TF_F_CHECK 
        where 
        TRADEDATE = v_c.f0 and MONEY = to_number(v_c.f1) * 100 and OPENBANK = v_c.f2 and ACCOUNTNAME = v_c.f3
        and ACCOUNTNUMBER = v_c.f4 and EXPLAIN = v_c.f5 and SUMMARY = v_c.f6 and POSTSCRIPT = v_c.f7 
        and TOACCOUNTBANK = v_c.f8 and TOACCOUNTNUMBER = v_c.f9
    and USETAG = '1';
        if v_count > 0 then
            p_retCode := 'S094390024';
            p_retMsg := '�˵������Ѵ�����ȫ��ͬ���˵���¼';
            rollback;
            return;
        end if; 
    */
        
        
        --��ȡ��ˮ��
        SP_GetSeq(seq => v_seqNo); 
        v_CHECKID:=v_seqNo;
        --�����˵���
        BEGIN
          INSERT INTO  TF_F_CHECK
          (                                                                
              CHECKID         , CHECKSTATE          , TRADEDATE       , MONEY          ,  OPENBANK      ,  ACCOUNTNAME    ,                                                               
              ACCOUNTNUMBER   , EXPLAIN             , SUMMARY         , POSTSCRIPT     ,  TOACCOUNTBANK ,  TOACCOUNTNUMBER,                                                            
              USEDMONEY       , LEFTMONEY           , USETAG          , UPDATEDEPARTNO ,  UPDATESTAFFNO ,  UPDATETIME     , 
              INSTAFFNO       , INTIME     
          )                                                            
          VALUES
          (                                                                 
              v_seqNo         ,   '1'                , v_c.f0         , to_number(v_c.f1) * 100,   v_c.f2        ,  v_c.f3,                                                             
              v_c.f4          ,   v_c.f5             , v_c.f6         , v_c.f7           ,   v_c.f8        ,  v_c.f9,                                                             
              0               ,  to_number(v_c.f1) * 100  ,  '1'           , P_CURRDEPT       ,  P_CURROPER     , V_TODAY       ,   
              P_CURROPER      ,  V_TODAY             
          );                                                             
                                  
          IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
                EXCEPTION
                WHEN OTHERS THEN
                  P_RETCODE := 'S094780024';
                  P_RETMSG  := '�����˵���ʧ��'||SQLERRM;
                  ROLLBACK; RETURN;
         
        END;
        --��ȡ��ˮ��
        SP_GetSeq(seq => v_seqNo); 
        --��¼�ʵ�̨�ʱ�
        BEGIN
          INSERT INTO  TF_B_CHECK
          (                                                                    
                TRADEID          ,   CHECKID          ,  TRADECODE       ,  MONEY            , 
                TRADEDATE        ,   OPENBANK         ,  ACCOUNTNAME     ,                                                                   
                ACCOUNTNUMBER    ,   EXPLAIN          ,  SUMMARY         ,  POSTSCRIPT       , 
                TOACCOUNTBANK    ,   TOACCOUNTNUMBER  ,  USEDMONEY,                                                                
                LEFTMONEY        ,   OPERATESTAFFNO   ,  OPERATETIME    
          )                                                                
          VALUES
          (                                                                    
                v_seqNo          ,   v_CHECKID        ,  '2'             , to_number(v_c.f1) * 100 , 
                v_c.f0           ,   v_c.f2           ,  v_c.f3          ,                                                                 
                v_c.f4           ,   v_c.f5           ,  v_c.f6          , v_c.f7            , 
                v_c.f8           ,   v_c.f9           ,  0               ,                                                                
                to_number(v_c.f1) * 100,   P_CURROPER       ,  V_TODAY          
          );                                                                
                                            
          IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
                EXCEPTION
                WHEN OTHERS THEN
                  P_RETCODE := 'S094780024';
                  P_RETMSG  := '��¼�ʵ�̨�ʱ�ʧ��'||SQLERRM;
                  ROLLBACK; RETURN;
         END;
         
         
         --��ѯ�Ƿ��з���ƥ�������Ķ���
          BEGIN
                
               SP_GC_ORDERACCOUNTAPPROVALAUTO(v_CHECKID, v_c.f1 ,v_c.f3,v_c.f4 ,
                    p_currOper, p_currDept, p_retCode, p_retMsg);

                IF p_retCode = '0000000000' THEN 
                   V_RETMSG2  :=V_RETMSG2|| '����Ϊ'||v_c.f3||'���˵���ִ���Զ����'||';';
                 END IF;

                
            END;
                  
    end loop;
    P_OUTRETMSG:=V_RETMSG2;
    
  p_retCode := '0000000000';
  p_retMsg  := '';
  COMMIT; RETURN;
    
END;
/
show errors
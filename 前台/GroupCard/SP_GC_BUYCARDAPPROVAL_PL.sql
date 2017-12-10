CREATE OR REPLACE PROCEDURE SP_GC_BUYCARDAPPROVAL
(
    P_ORDERNO               CHAR     ,
    P_ORDERTYPE             CHAR     ,
    P_CURROPER              CHAR     ,
    P_CURRDEPT              CHAR     ,
    P_RETCODE           OUT CHAR     ,
    P_RETMSG            OUT VARCHAR2 
)
AS
    V_TODAY           DATE         := SYSDATE    ;
    V_QUANTITY        INT                        ;
    V_COMPANYNO             CHAR(6);
    V_COMPANYPAPERTYPE      CHAR(2);
    V_COMPANYPAPERNO        VARCHAR2(30);
    V_PAPERTYPE             CHAR(2);
    V_PAPERNO               VARCHAR2(20);
    V_CALLINGNO             CHAR     ;--Ӧ����ҵ����
    V_REGISTEREDCAPITAL     INT      ;--ע���ʽ�
    V_SECURITYVALUE         INT      ;--��ȫֵ
    v_CALLINGRIGHTVALUE   FLOAT      ;
    v_tradeID               CHAR(16);
    V_EXITTRADEID           CHAR(16);
    V_EX                    EXCEPTION ;
    V_COUNT                 INT;
BEGIN
SP_GetSeq(seq => v_tradeID); --������ˮ��
--�����ͻ�
IF P_ORDERTYPE = '1' THEN
     SELECT T.COMPANYNO INTO V_COMPANYNO FROM TF_F_COMBUYCARDREG T WHERE T.REMARK = P_ORDERNO;
     SELECT K.CALLINGNO,K.REGISTEREDCAPITAL,K.COMPANYPAPERTYPE,K.COMPANYPAPERNO INTO V_CALLINGNO,V_REGISTEREDCAPITAL,V_COMPANYPAPERTYPE,V_COMPANYPAPERNO FROM TD_M_BUYCARDCOMINFO K WHERE K.COMPANYNO = V_COMPANYNO;
     
     IF V_REGISTEREDCAPITAL IS NOT NULL OR V_REGISTEREDCAPITAL<>'' then  --�¿ͻ�����ע���ʽ�
      if V_CALLINGNO is not null or V_CALLINGNO <>'' THEN
      select k.CALLINGRIGHTVALUE into v_CALLINGRIGHTVALUE from TD_M_CALLINGRIGHTVALUE k where k.CALLINGNO = V_CALLINGNO and k.applytype = '2';
       if v_CALLINGRIGHTVALUE is not null or v_CALLINGRIGHTVALUE<>'' then
       V_SECURITYVALUE:= v_CALLINGRIGHTVALUE*V_REGISTEREDCAPITAL;
       else
       P_RETCODE := 'A001002101';
        P_RETMSG  := '�ͻ���Ӧ����ҵȨֵδ����,����δ�ܼ������λ��ȫֵ,δ�ύ����ȫֵ��˽���';
        ROLLBACK;RETURN;
       end if;
       else
        P_RETCODE := 'A001002100';
        P_RETMSG  := '�˵�λ�����ͻ���Ӧ����ҵδ����,����δ�ܼ������λ��ȫֵ,δ�ύ����ȫֵ��˽���';
      ROLLBACK; RETURN;
    end if;
       
     ELSE
       SELECT T.TOTALMONEY*2 INTO V_SECURITYVALUE FROM TF_F_ORDERFORM T WHERE T.ORDERNO =  P_ORDERNO;
     
   END IF;
     
    

      BEGIN
          SP_GC_COMBUYCARDAPPROVAL(
              P_FUNCCODE         => 'MODIFY'              ,
              P_COMPANYNO        => V_COMPANYNO                ,
              P_COMPANYPAPERTYPE => V_COMPANYPAPERTYPE        ,
              P_COMPANYPAPERNO   => V_COMPANYPAPERNO ,
              P_CALLINGNO        => V_CALLINGNO   ,
              P_REGISTEREDCAPITAL=> V_REGISTEREDCAPITAL ,
              P_SECURITYVALUE    => V_SECURITYVALUE   ,
              P_CURROPER         => P_CURROPER         ,
              P_CURRDEPT         => P_CURRDEPT         ,
              P_RETCODE          => P_RETCODE          ,
              P_RETMSG           => P_RETMSG
          );
          IF p_retCode != '0000000000' THEN RAISE v_ex; END IF;
      EXCEPTION WHEN OTHERS THEN
          ROLLBACK; RETURN;
      END;
       
               
  END IF;
  
  --��������       
 IF P_ORDERTYPE = '2' THEN
    SELECT T.PAPERTYPE,T.PAPERNO INTO V_PAPERTYPE,V_PAPERNO FROM TF_F_PERBUYCARDREG T WHERE T.REMARK = P_ORDERNO;
    SELECT K.CALLINGNO,K.REGISTEREDCAPITAL INTO V_CALLINGNO,V_REGISTEREDCAPITAL FROM TD_M_BUYCARDPERINFO K WHERE K.PAPERTYPE = V_PAPERTYPE AND K.PAPERNO = V_PAPERNO;
    
    IF V_REGISTEREDCAPITAL IS NOT NULL OR V_REGISTEREDCAPITAL<>'' then  --�¿ͻ�����ע���ʽ�
      if V_CALLINGNO is not null or V_CALLINGNO <>'' THEN
      select k.CALLINGRIGHTVALUE into v_CALLINGRIGHTVALUE from TD_M_CALLINGRIGHTVALUE k where k.CALLINGNO = V_CALLINGNO and k.applytype = '2';
        if v_CALLINGRIGHTVALUE is not null or v_CALLINGRIGHTVALUE<>'' then
       V_SECURITYVALUE:= v_CALLINGRIGHTVALUE*V_REGISTEREDCAPITAL;
       else
      
        P_RETCODE := 'A001002102';
        P_RETMSG  := '�ͻ���Ӧ����ҵȨֵδ����,����δ�ܼ������λ��ȫֵ,δ�ύ����ȫֵ��˽���';
       ROLLBACK;RETURN;
       end if;
       else
        P_RETCODE := 'A001002103';
        P_RETMSG  := '�˸��˹����ͻ���Ӧ����ҵδ����,����δ�ܼ������λ��ȫֵ,δ�ύ����ȫֵ��˽���';
       ROLLBACK;RETURN;
    end if;
       
     ELSE
       SELECT T.TOTALMONEY*2 INTO V_SECURITYVALUE FROM TF_F_ORDERFORM T WHERE T.ORDERNO =  P_ORDERNO;
     
   END IF;
    BEGIN
          SP_GC_PERBUYCARDAPPROVAL(
              P_FUNCCODE         => 'MODIFY'              ,
              P_PAPERTYPE        => V_PAPERTYPE                ,
              P_PAPERNO          => V_PAPERNO        ,
              P_CALLINGNO        => V_CALLINGNO ,
              P_REGISTEREDCAPITAL=> V_REGISTEREDCAPITAL ,
              P_SECURITYVALUE    => V_SECURITYVALUE   ,
              P_CURROPER         => P_CURROPER         ,
              P_CURRDEPT         => P_CURRDEPT         ,
              P_RETCODE          => P_RETCODE          ,
              P_RETMSG           => P_RETMSG
          );
          IF p_retCode != '0000000000' THEN RAISE v_ex; END IF;
      EXCEPTION WHEN OTHERS THEN
          ROLLBACK; RETURN;
      END;
 
 
END IF; 

      
     
     
     
     p_retCode := '0000000000'; p_retMsg  := '�ɹ�';
     COMMIT; RETURN;   
END;
/
show errors;
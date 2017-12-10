CREATE OR REPLACE PROCEDURE SP_GC_COMBUYCARDAPPROVAL
(
    P_FUNCCODE              VARCHAR2 ,
    P_COMPANYNO             CHAR     ,
    P_COMPANYPAPERTYPE      CHAR     ,
    P_COMPANYPAPERNO        VARCHAR2 ,
    P_CALLINGNO             CHAR     ,--Ӧ����ҵ����
    P_REGISTEREDCAPITAL     INT      ,--ע���ʽ�
    P_SECURITYVALUE         INT      ,--��ȫֵ
    P_CURROPER              CHAR     ,
    P_CURRDEPT              CHAR     ,
    P_RETCODE           OUT CHAR     ,
    P_RETMSG            OUT VARCHAR2 
)
AS
    V_FUNCCODE        VARCHAR2(16) := P_FUNCCODE ;
    V_TODAY           DATE         := SYSDATE    ;
    V_QUANTITY        INT                        ;
    v_tradeID       CHAR(16);
    V_EXITTRADEID   CHAR(16);
    V_EX              EXCEPTION                  ;
    V_COUNT           INT;
BEGIN
SP_GetSeq(seq => v_tradeID); --������ˮ��
        -- ���
        IF V_FUNCCODE = 'ADD' THEN
        
            --��ѯ�Ƿ���ڴ˵�λ�İ�ȫֵ�����Ϣ
           SELECT  COUNT(*) INTO V_QUANTITY
           FROM   TF_F_COMBUYCARDAPPROVAL
           WHERE  COMPANYNO = P_COMPANYNO
           AND    ISVALID = '1';
           
       IF V_QUANTITY > 0 THEN
        P_RETCODE := 'A001002100';
        P_RETMSG  := '���д˵�λ�İ�ȫֵ�����Ϣ�����ڿ���,�����Ҫ�޸İ�ȫֵ,�����޸İ�ť';
        ROLLBACK; RETURN;
       END IF;
       
      IF V_QUANTITY <1 THEN     
          
        
        BEGIN
            
            --APPROVESTATEΪ0�Ǵ����״̬,1�����ͨ��״̬;ISVALIDΪ1����Ч,0����Ч
            INSERT INTO TF_F_COMBUYCARDAPPROVAL(
            ID              , COMPANYNO             , COMPANYPAPERTYPE     ,COMPANYPAPERNO    , APPROVESTATE  , 
            SECURITYVALUE   ,REGISTEREDCAPITAL      , APPCALLINGNO            ,OPERATOR          , OPERDEPT      ,
            OPERATETIME     , ISVALID      
            )VALUES(
            v_tradeID       , P_COMPANYNO           , P_COMPANYPAPERTYPE   , P_COMPANYPAPERNO , '0'           ,
            P_SECURITYVALUE , P_REGISTEREDCAPITAL   , P_CALLINGNO          , P_CURROPER        ,P_CURRDEPT         ,
            V_TODAY          , '1'
            );
        EXCEPTION WHEN OTHERS THEN
            P_RETCODE := 'S004102001' ;
            P_RETMSG  := '���빺����λ��ȫֵ��˱�ʧ��,'||SQLERRM ;
        ROLLBACK;RETURN;
        END;
        END IF;
       END IF;

     
     --�޸�
     IF V_FUNCCODE = 'MODIFY' THEN
    

      --��ѯ�Ƿ���ڴ˵�λ�İ�ȫֵ�������Ϣ
       SELECT  COUNT(*) INTO V_COUNT
       FROM   TF_F_COMBUYCARDAPPROVAL
       WHERE  COMPANYNO = P_COMPANYNO
       AND    ISVALID = '1'
       AND    APPROVESTATE='0';
       
       IF V_COUNT=1  THEN 
         SELECT ID INTO V_EXITTRADEID  FROM   TF_F_COMBUYCARDAPPROVAL 
         WHERE  COMPANYNO = P_COMPANYNO
         AND    ISVALID = '1'
         AND    APPROVESTATE='0'; 
       
        BEGIN
         UPDATE  TF_F_COMBUYCARDAPPROVAL tmb
        SET     tmb.SECURITYVALUE    = P_SECURITYVALUE      ,
                tmb.operator         = p_curroper           ,
                tmb.operdept         = p_currdept           ,
                tmb.operatetime      = v_today
        WHERE   tmb.ID          = V_EXITTRADEID   ;
        
        IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
     EXCEPTION
        WHEN OTHERS THEN
        P_RETCODE :=  'S004102002';
        P_RETMSG  := '���¹�����λ��ȫֵ��˱�ʧ��' || SQLERRM;
        ROLLBACK; RETURN;
     END;
     END IF;
     
     IF V_COUNT<1  THEN 
     
      BEGIN
            
            --APPROVESTATEΪ0�Ǵ����״̬,1�����ͨ��״̬;ISVALIDΪ1����Ч,0����Ч
            INSERT INTO TF_F_COMBUYCARDAPPROVAL(
            ID              , COMPANYNO             , COMPANYPAPERTYPE     ,COMPANYPAPERNO    , APPROVESTATE  , 
            SECURITYVALUE   ,REGISTEREDCAPITAL      , APPCALLINGNO            ,OPERATOR          , OPERDEPT      ,
            OPERATETIME     , ISVALID      
            )VALUES(
            v_tradeID       , P_COMPANYNO           , P_COMPANYPAPERTYPE   , P_COMPANYPAPERNO , '0'           ,
            P_SECURITYVALUE , P_REGISTEREDCAPITAL   , P_CALLINGNO          , P_CURROPER        ,P_CURRDEPT         ,
            V_TODAY          , '1'
            );
        EXCEPTION WHEN OTHERS THEN
            P_RETCODE := 'S004102003' ;
            P_RETMSG  := '���빺����λ��ȫֵ��˱�ʧ��,'||SQLERRM ;
        ROLLBACK;RETURN;
        END;
      END IF;
     
     
   END IF;
      
     
     
     
     p_retCode := '0000000000'; p_retMsg  := '�ɹ�';
     COMMIT; RETURN;   
END;
/
show errors;
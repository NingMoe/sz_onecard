CREATE OR REPLACE PROCEDURE SP_RM_OTHER_GETRESOURCE    --��Դ����ҳ��
(
  P_GETORDERID           char    ,  --���õ���
  P_SESSIONID            varchar2     ,
  P_STOCKOUTNUM          INT    ,   --��������
  P_RESOURCECODE         CHAR   , --��Դ����
  P_AGREEGETNUM          INT    ,   --ͬ����������
  P_APPLYGETNUM          INT    ,   --������������
  P_ALREADYGETNUM        INT    ,   --����������
  P_GETSTAFFNO           char     ,   --����Ա�� 
  P_ARRRIBUTESUM1        varchar2 ,
  P_ARRRIBUTESUM2        varchar2 ,
  P_ARRRIBUTESUM3        varchar2 ,
  P_ARRRIBUTESUM4        varchar2 ,
  P_ARRRIBUTESUM5        varchar2 ,
  P_ARRRIBUTESUM6        varchar2 ,
  p_currOper             char     ,
  p_currDept             char     ,
  p_retCode              out char     ,  -- Return Code
  p_retMsg               out varchar2   -- Return Message
  
)
AS
    v_seqNo             CHAR(16)       ;
    V_EX                EXCEPTION      ;
    V_ATTRIBUTE1           VARCHAR2(50)   ;
    V_ATTRIBUTE2           VARCHAR2(50)    ;
    V_ATTRIBUTE3           VARCHAR2(50)    ;
    V_ATTRIBUTE4           VARCHAR2(50)    ;
    V_ATTRIBUTE5           VARCHAR2(50)   ;
    V_ATTRIBUTE6           VARCHAR2(50)    ;
    V_ORDERATTRIBUTE1           VARCHAR2(50);
		V_ORDERATTRIBUTE2           VARCHAR2(50);
		V_ORDERATTRIBUTE3           VARCHAR2(50);
		V_ORDERATTRIBUTE4           VARCHAR2(50);
		V_ORDERATTRIBUTE5           VARCHAR2(50);
		V_ORDERATTRIBUTE6           VARCHAR2(50);
    V_DEPARTNO          CHAR(4)           ;  --����Ա�����ű���
    V_TODAY             DATE := SYSDATE;
    V_INDEX              INT  := 1;
    V_NUM               INT  ;
    V_TOTAL             INT :=0;

BEGIN


  
  --��ȡ����Ա�����ű���
  BEGIN 
    SELECT DEPARTNO INTO V_DEPARTNO FROM TD_M_INSIDESTAFF WHERE STAFFNO = P_GETSTAFFNO;
    EXCEPTION
       WHEN OTHERS THEN
           p_retCode := 'S001003100';
           p_retMsg  := '��ȡ����Ա�����ű���'|| SQLERRM;
           ROLLBACK; RETURN;
  END;
  --��ȡ����������
  BEGIN
			SELECT ATTRIBUTE1,ATTRIBUTE2,ATTRIBUTE3,ATTRIBUTE4,ATTRIBUTE5,ATTRIBUTE6 
			INTO V_ORDERATTRIBUTE1,V_ORDERATTRIBUTE2,V_ORDERATTRIBUTE3,V_ORDERATTRIBUTE4,V_ORDERATTRIBUTE5,V_ORDERATTRIBUTE6
		  FROM TF_F_GETRESOURCEORDER
			WHERE GETORDERID = P_GETORDERID;
			EXCEPTION
	    WHEN OTHERS THEN
	        p_retCode := 'S001003101';
	        p_retMsg  := '��ѯ��Դ���õ���ʧ��'|| SQLERRM;
	        ROLLBACK; RETURN;   
	END;

  WHILE V_INDEX <= P_STOCKOUTNUM
  LOOP
     --��ȡ��ˮ��
     SP_GetSeq(seq => v_seqNo);
    BEGIN
     SELECT COUNT(*) INTO V_TOTAL FROM TMP_COMMON;
     
    IF V_TOTAL>0 THEN
    BEGIN
       
       --��ȡ��Դ����
       SELECT a.F1, a.F2, a.F3,a.F4,a.F5,a.F6 
       INTO V_ATTRIBUTE1,V_ATTRIBUTE2,V_ATTRIBUTE3,V_ATTRIBUTE4,V_ATTRIBUTE5,V_ATTRIBUTE6
       FROM TMP_COMMON a WHERE a.F7 = P_SESSIONID AND a.F0 = TO_CHAR(V_INDEX);
       EXCEPTION
       WHEN OTHERS THEN
           p_retCode := 'S001003102';
           p_retMsg  := '��ȡ��Դ��������ʧ��'|| SQLERRM;
           ROLLBACK; RETURN;
     END;
     
     BEGIN
     
       
      SELECT COUNT(*) INTO  V_NUM                ---��ȡ�����ж�Ӧ�����Դ������ 
			FROM   TL_R_RESOURCE																			
			WHERE  RESOURCECODE = P_RESOURCECODE																			
			AND     (V_ATTRIBUTE1 IS NULL OR NVL(V_ATTRIBUTE1,V_ORDERATTRIBUTE1) = ATTRIBUTE1 )																			
			AND     (V_ATTRIBUTE2 IS NULL OR NVL(V_ATTRIBUTE2,V_ORDERATTRIBUTE2) = ATTRIBUTE2 )		
			AND     (V_ATTRIBUTE3 IS NULL OR NVL(V_ATTRIBUTE3,V_ORDERATTRIBUTE3) = ATTRIBUTE3 )																			
			AND     (V_ATTRIBUTE4 IS NULL OR NVL(V_ATTRIBUTE4,V_ORDERATTRIBUTE4) = ATTRIBUTE4 )	
			AND     (V_ATTRIBUTE5 IS NULL OR NVL(V_ATTRIBUTE5,V_ORDERATTRIBUTE5) = ATTRIBUTE5 )																			
			AND     (V_ATTRIBUTE6 IS NULL OR NVL(V_ATTRIBUTE6,V_ORDERATTRIBUTE6) = ATTRIBUTE6 )
			AND   STOCKSATECODE = '00';
       
     IF V_NUM=1  THEN
       BEGIN
         
         UPDATE   TL_R_RESOURCE                ---���¿����ж�Ӧ����Դ                                  
         SET      STOCKSATECODE = '01' ,--����                                     
                   USETIME = V_TODAY ,                                  
                   ASSIGNEDSTAFFNO = P_GETSTAFFNO ,                                  
                   ASSIGNEDDEPARTID = V_DEPARTNO ,                                  
                  UPDATESTAFFNO = P_CURROPER ,                                  
                   UPDATETIME = V_TODAY                                  
         WHERE    RESOURCECODE = P_RESOURCECODE 
         AND     (V_ATTRIBUTE1 IS NULL OR NVL(V_ATTRIBUTE1,V_ORDERATTRIBUTE1) = ATTRIBUTE1 )																			
				 AND     (V_ATTRIBUTE2 IS NULL OR NVL(V_ATTRIBUTE2,V_ORDERATTRIBUTE2) = ATTRIBUTE2 )		
				 AND     (V_ATTRIBUTE3 IS NULL OR NVL(V_ATTRIBUTE3,V_ORDERATTRIBUTE3) = ATTRIBUTE3 )																			
				 AND     (V_ATTRIBUTE4 IS NULL OR NVL(V_ATTRIBUTE4,V_ORDERATTRIBUTE4) = ATTRIBUTE4 )	
				 AND     (V_ATTRIBUTE5 IS NULL OR NVL(V_ATTRIBUTE5,V_ORDERATTRIBUTE5) = ATTRIBUTE5 )																			
				 AND     (V_ATTRIBUTE6 IS NULL OR NVL(V_ATTRIBUTE6,V_ORDERATTRIBUTE6) = ATTRIBUTE6 )
				 AND   STOCKSATECODE = '00';
         IF SQL%ROWCOUNT != 1 THEN
         RAISE V_EX;
          END IF;
       EXCEPTION
         WHEN OTHERS THEN
                P_RETCODE := 'S001003103';
                P_RETMSG := '���¿���ʧ��  ' || SQLERRM;
                ROLLBACK;
                RETURN;
        END;
                
      ELSE
        BEGIN
       ---��¼����
         INSERT INTO TL_R_RESOURCE(                                                                     
                     RESOURCECODE          ,ATTRIBUTE1             ,ATTRIBUTE2             ,ATTRIBUTE3             ,                                                      
                     ATTRIBUTE4            ,ATTRIBUTE5             ,ATTRIBUTE6             ,STOCKSATECODE          ,                                                      
                    INSTIME               ,USETIME                 ,REINTIME               ,ASSIGNEDSTAFFNO        ,                                                      
                    ASSIGNEDDEPARTID      ,UPDATESTAFFNO           ,UPDATETIME                                     )                                                      
          VALUES(                                                          
                    P_RESOURCECODE        ,NVL(V_ATTRIBUTE1,V_ORDERATTRIBUTE1) ,NVL(V_ATTRIBUTE2,V_ORDERATTRIBUTE2),NVL(V_ATTRIBUTE3,V_ORDERATTRIBUTE3),                                                      
                    NVL(V_ATTRIBUTE4,V_ORDERATTRIBUTE4),NVL(V_ATTRIBUTE5,V_ORDERATTRIBUTE5),NVL(V_ATTRIBUTE6,V_ORDERATTRIBUTE6) ,'01'                  ,                                                      
                    NULL                  ,V_TODAY                  ,NULL                   ,P_GETSTAFFNO          ,                                                      
                    V_DEPARTNO            ,P_CURROPER               ,V_TODAY                                      );                                                      
          IF SQL%ROWCOUNT != 1 THEN
            RAISE V_EX;
               END IF;
          EXCEPTION
          WHEN OTHERS THEN
                P_RETCODE := 'S001003104';
                P_RETMSG := '��¼����ʧ��  ' || SQLERRM;
                ROLLBACK;
                RETURN;
        END;        
        
      END IF;                                       
    END;
     

  V_INDEX:=V_INDEX+1;
  END IF; 
   END; 
  END LOOP;


  --������Դ���õ���
  BEGIN
     IF P_ALREADYGETNUM + P_STOCKOUTNUM < P_AGREEGETNUM  THEN

        UPDATE  TF_F_GETRESOURCEORDER
        SET     LATELYGETDATE = V_TODAY ,
                ALREADYGETNUM = ALREADYGETNUM+P_STOCKOUTNUM,
                ORDERSTATE = '3'  --��������
        WHERE   GETORDERID = P_GETORDERID ;
      ELSE
        UPDATE  TF_F_GETRESOURCEORDER
        SET      LATELYGETDATE = V_TODAY ,
                ALREADYGETNUM = ALREADYGETNUM+P_STOCKOUTNUM,
                ORDERSTATE = '4'  --�������
        WHERE   GETORDERID = P_GETORDERID ;
     END IF;
     EXCEPTION
      WHEN OTHERS THEN
          p_retCode := 'S001003105';
          p_retMsg  := '������Դ���õ���ʧ��'|| SQLERRM;
          ROLLBACK; RETURN;
   END;

  --���¿����ܱ�
  BEGIN
      UPDATE TL_R_RESOURCESUM
      SET USENUM = USENUM + P_STOCKOUTNUM,
          UPDATESTAFFNO = P_CURROPER ,                    
          UPDATETIME = V_TODAY                     
      WHERE RESOURCECODE = P_RESOURCECODE;
      EXCEPTION
        WHEN OTHERS THEN
        p_retCode := 'S001003106';
        p_retMsg  := '���¿����ܱ�ʧ��'|| SQLERRM;
        ROLLBACK; RETURN;
   END;

     --��ȡ��ˮ��
     SP_GetSeq(seq => v_seqNo);

  --��¼��Դ���ݹ���̨�˱�
  BEGIN
    INSERT INTO TF_B_RESOURCEORDERMANAGE(
        TRADEID           , ORDERTYPECODE           , ORDERID           , OPERATETYPECODE     ,
        ORDERDEMAND       , MAINTAINREASON          , RESOURCECODE      , ATTRIBUTE1          ,
        ATTRIBUTE2        , ATTRIBUTE3              , ATTRIBUTE4        , ATTRIBUTE5          ,
        ATTRIBUTE6        , RESOURCENUM             , REQUIREDATE       , LATELYDATE          ,
      ALREADYORDERNUM   ,ALREADYARRIVENUM         , APPLYGETNUM       , AGREEGETNUM         ,
      ALREADYGETNUM     , LATELYGETDATE           , GETSTAFFNO        , OPERATETIME         ,
      OPERATESTAFFNO
    )VALUES  (
        v_seqNo           ,  '03'                  , P_GETORDERID      , '09'                ,
        NULL              , NULL                   , P_RESOURCECODE    , P_ARRRIBUTESUM1     ,
        P_ARRRIBUTESUM2   ,P_ARRRIBUTESUM3         , P_ARRRIBUTESUM4   , P_ARRRIBUTESUM5     ,
        P_ARRRIBUTESUM6   ,NULL                    , NULL              , NULL                ,
        NULL              ,NULL                    , P_APPLYGETNUM     ,P_AGREEGETNUM        ,
        P_ALREADYGETNUM + P_STOCKOUTNUM  ,V_TODAY  , P_GETSTAFFNO      , V_TODAY             ,
      P_CURROPER )     ;
    EXCEPTION
      WHEN OTHERS THEN
          p_retCode := 'S001003107';
          p_retMsg  := '��¼��Դ���ݹ���̨�˱�'|| SQLERRM;
          ROLLBACK; RETURN;
  END;


  --�����ʱ��
  DELETE TMP_COMMON WHERE f7 = P_SESSIONID;

  p_retCode := '0000000000';
  p_retMsg  := '�ɹ�';

  COMMIT; RETURN;
END;
/
SHOW ERROR;
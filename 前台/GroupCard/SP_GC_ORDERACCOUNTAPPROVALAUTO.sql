CREATE OR REPLACE PROCEDURE SP_GC_ORDERACCOUNTAPPROVALAUTO
(
    P_CHECKID           CHAR    ,  --�˵���
    p_MONEY             CHAR    ,  --���
    p_ACCOUNTNAME       CHAR    ,  --����
    p_ACCOUNTNUMBER     CHAR    ,  --ת�������ʺ�
    p_currOper          char    ,
    p_currDept          char    ,
    p_retCode       out char    ,  -- Return Code
    p_retMsg        out varchar2   -- Return Message  
)
AS 
    v_seqNo              CHAR(16); --ҵ����ˮ��
    V_ORDERNO            CHAR(16);
    V_GROUPNAME          VARCHAR2(100);--�����ĵ�λ����
    V_NAME               VARCHAR2(50);--��������ϵ�� 
    V_NUM                INT;
    V_NUM2               INT;
    V_NUM3               INT;
    V_NUM4               INT;
    V_EX                 EXCEPTION;
    V_TODAY              DATE := SYSDATE;

BEGIN
     --��ѯ�Ƿ��з���ƥ�������Ķ���
       
          SELECT COUNT(*) INTO V_NUM FROM TF_F_ORDERFORM T WHERE T.ORDERSTATE='01' AND T.ORDERNO NOT IN (SELECT ORDERNO FROM TF_F_ORDERCHECKRELATION )
          AND T.TOTALMONEY =to_number(p_MONEY) * 100  AND (T.GROUPNAME = p_ACCOUNTNAME OR T.NAME =p_ACCOUNTNAME  ) AND T.USETAG = '1';
          
          IF V_NUM!= 1 THEN
                p_retCode := 'A094570401';
                p_retMsg  := '����Ϊ'||p_ACCOUNTNAME||'���˵�û���ҵ�����ƥ����������Ķ���,δ�����Զ����';
            RETURN;
          END IF;
          IF V_NUM = 1 THEN
            
            SELECT T.ORDERNO INTO V_ORDERNO FROM TF_F_ORDERFORM T WHERE T.ORDERSTATE='01' AND T.ORDERNO NOT IN (SELECT ORDERNO FROM TF_F_ORDERCHECKRELATION )
            AND T.TOTALMONEY =to_number(p_MONEY) * 100  AND (T.GROUPNAME = p_ACCOUNTNAME OR T.NAME =p_ACCOUNTNAME  ) AND T.USETAG = '1';
            
            
            SELECT COUNT(*) INTO V_NUM3 FROM TF_F_PAYTYPE K WHERE K.ORDERNO =V_ORDERNO;
            SELECT COUNT(*) INTO V_NUM4 FROM TF_F_PAYTYPE K WHERE K.ORDERNO =V_ORDERNO AND K.PAYTYPECODE='4';
            IF V_NUM3= 1 AND V_NUM4=1 THEN
                p_retCode := 'A094570402';
                p_retMsg  := '����Ϊ'||p_ACCOUNTNAME||'���˵�û���ҵ�����ƥ����������Ķ���,δ�����Զ����';
            RETURN;
            END IF;
            --���¶�����
            BEGIN
                UPDATE TF_F_ORDERFORM
               SET     ORDERSTATE = '02',--���ͨ��
                       FINANCEAPPROVERNO = P_CURROPER,
                       FINANCEAPPROVERTIME = V_TODAY,
                       FINANCEREMARK = NULL,
                       UPDATEDEPARTNO = P_CURRDEPT,
                       UPDATESTAFFNO = P_CURROPER,
                       UPDATETIME = V_TODAY
              WHERE  ORDERNO = V_ORDERNO;    
              IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
                EXCEPTION WHEN OTHERS THEN
                p_retCode := 'S094570401';
                p_retMsg  := '���˵����Զ����ʱ���¶�����ʧ��,������Ϊ'||V_ORDERNO|| SQLERRM;
                ROLLBACK; RETURN;            
             END;
            --�����˵���
            BEGIN
                UPDATE TF_F_CHECK 
                SET    CHECKSTATE = '3', --���ʹ��
                       USEDMONEY = to_number(p_MONEY) * 100, --���ý������˵����
                       LEFTMONEY = 0, --ʣ����Ϊ0
                       UPDATEDEPARTNO = p_currDept,
                       UPDATESTAFFNO = p_currOper,
                       UPDATETIME = V_TODAY
                WHERE  CHECKID = P_CHECKID;
            IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
            EXCEPTION WHEN OTHERS THEN
                p_retCode := 'S094570402';
                p_retMsg  := '���˵����Զ����ʱ�����˵���ʧ��,�˵���Ϊ'||P_CHECKID|| SQLERRM;
               ROLLBACK;  RETURN;            
            END;
            --��ȡ��ˮ��
             SP_GetSeq(seq => v_seqNo); 
            --��¼�������˵�������ϵ��
              BEGIN
                  INSERT INTO TF_F_ORDERCHECKRELATION(
                      ORDERNO   , CHECKID   , TRADEID , MONEY            , UPDATESTAFFNO , UPDATETIME
                  )VALUES(
                      V_ORDERNO , P_CHECKID , v_seqNo , to_number(p_MONEY) * 100 , p_currOper    , V_TODAY
                  );
              IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
              EXCEPTION WHEN OTHERS THEN
                  p_retCode := 'S094570403';
                  p_retMsg  := '���˵����Զ����ʱ��¼�������˵�������ϵ��ʧ��,������Ϊ'||V_ORDERNO|| SQLERRM;
                  ROLLBACK; RETURN;            
              END;
              
             BEGIN
                SELECT COUNT(*) INTO V_NUM2 FROM TF_F_COMBUYCARDREG T WHERE T.REMARK = V_ORDERNO;
                
                
                IF V_NUM2>0 THEN 
                --���µ�λ������¼��
                BEGIN
                  UPDATE TF_F_COMBUYCARDREG 
                  SET OUTBANK = p_ACCOUNTNUMBER,--ת�������ʺ�
                      OUTACCT = p_ACCOUNTNAME --ת���˻�����
                  WHERE REMARK = V_ORDERNO;
                   IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
                  EXCEPTION WHEN OTHERS THEN
                      p_retCode := 'S094570404';
                      p_retMsg  := '���˵����Զ����ʱ���µ�λ������¼��ʧ��,������Ϊ'||V_ORDERNO|| SQLERRM;
                     ROLLBACK;  RETURN; 
                END;
                END IF;
                
              END;
              
              --��¼����̨��  ����TRADECODE '18'Ϊ���˵����Զ����
              BEGIN
                  INSERT INTO TF_F_ORDERTRADE(
                      TRADEID , ORDERNO   ,TRADECODE  , MONEY                    , OPERATEDEPARTNO , OPERATESTAFFNO , OPERATETIME
                  )VALUES(
                      v_seqNo , V_ORDERNO ,'18'      , to_number(p_MONEY) * 100  , p_currDept      , p_currOper     , V_TODAY
                  );
              IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
              EXCEPTION WHEN OTHERS THEN
                  p_retCode := 'S094570405';
                  p_retMsg  := '���˵����Զ����ʱ��¼����̨��ʧ��'|| SQLERRM;
                  ROLLBACK; RETURN;            
              END;
              --��¼�˵�̨��
              BEGIN
                  INSERT INTO TF_B_CHECK(
                      TRADEID , CHECKID   , TRADECODE , MONEY                    , USEDMONEY                , LEFTMONEY        , OPERATESTAFFNO , OPERATETIME
                  )VALUES(
                      v_seqNo , P_CHECKID , '4'      , to_number(p_MONEY) * 100  ,to_number(p_MONEY) * 100    , 0                , p_currOper     , V_TODAY
                  );
              IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
              EXCEPTION WHEN OTHERS THEN
                  p_retCode := 'S094570406';
                  p_retMsg  := '���˵����Զ����ʱ��¼�˵�̨��ʧ��'|| SQLERRM;
                  ROLLBACK; RETURN;            
              END;
          
        END IF;
         
        

    p_retCode := '0000000000';
    p_retMsg  := '�ɹ�';
    COMMIT; RETURN;    
END;

 
/
show errors
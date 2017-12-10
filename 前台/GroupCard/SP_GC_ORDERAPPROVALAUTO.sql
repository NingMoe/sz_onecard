CREATE OR REPLACE PROCEDURE SP_GC_ORDERAPPROVALAUTO
(
    P_ORDERNO           CHAR    , --������
    p_ISAPPROVE         CHAR    ,  --�Ƿ������
    p_currOper          char    ,
    p_currDept          char    ,
    p_retCode       out char    ,  -- Return Code
    p_retMsg        out varchar2   -- Return Message  
)
AS 
    v_seqNo              CHAR(16); --ҵ����ˮ��
    V_CHECKID            CHAR(16); --�˵���
    V_GROUPNAME          VARCHAR2(100);--�����ĵ�λ����
    V_NAME               VARCHAR2(50);--��������ϵ��
    V_ORDERMONEY         INT;      --�����ܽ��
    V_ORDERSTATE         CHAR(2);  --����״̬
    V_ORDERTYPE          CHAR(1);  --��������
    V_ACCOUNTNAME        VARCHAR2(100);--�Է�����
    V_ACCOUNTNUMBER      VARCHAR2(30);--�Է��˺�
    V_COUNT              INT;
    V_COUNT2             INT;
    V_NUM                INT;
    V_EX                 EXCEPTION;
    V_TODAY              DATE := SYSDATE;

BEGIN
   
        --��ѯ����״̬����λ���ƺͶ����ܽ��ж��Ƿ���δ���״̬
        SELECT ORDERSTATE,GROUPNAME,NAME,TOTALMONEY,ORDERTYPE INTO V_ORDERSTATE,V_GROUPNAME,V_NAME,V_ORDERMONEY,V_ORDERTYPE FROM TF_F_ORDERFORM WHERE ORDERNO = P_ORDERNO;
        IF V_ORDERSTATE<>'01' THEN  --�������״̬��Ϊ¼�����˾Ͳ�����
             p_retCode := 'A094570400';
             p_retMsg  := '����״̬��Ϊ¼������';
             RETURN; 
        END IF;
       
        
       
        IF p_ISAPPROVE <> '1' THEN --������ǳ���������������˵�
            
                --�Զ���ѯδƥ��Ĳ�������Ϣ,����ܷ���ƥ���������򶩵����ͨ��
            IF V_ORDERTYPE = '1' THEN--���������ǵ�λ���� 
                SELECT COUNT(*) INTO V_COUNT FROM TF_F_CHECK T,TF_F_ORDERCHECKRELATION P WHERE T.CHECKID = P.CHECKID(+) AND  P.CHECKID IS NULL AND 
                T.MONEY = V_ORDERMONEY AND T.USEDMONEY = 0 AND T.ACCOUNTNAME = V_GROUPNAME AND T.CHECKSTATE ='1' AND T.USETAG = '1';
                
            ELSE --���˶���
                SELECT COUNT(*) INTO V_COUNT2 FROM TF_F_CHECK T,TF_F_ORDERCHECKRELATION P WHERE T.CHECKID = P.CHECKID(+) AND  P.CHECKID IS NULL AND 
                T.MONEY = V_ORDERMONEY AND T.USEDMONEY = 0 AND T.ACCOUNTNAME = V_NAME AND T.CHECKSTATE ='1' AND T.USETAG = '1';
            
            END IF;
            
                
            IF  V_COUNT!=1 AND V_ORDERTYPE = '1' THEN
                 p_retCode := 'A094570401';
                 p_retMsg  := 'δ�ҵ������Զ����ƥ���������˵�';
                 RETURN;
            END IF;
            IF  V_COUNT2!=1 AND V_ORDERTYPE = '2' THEN
                 p_retCode := 'A094570402';
                 p_retMsg  := 'δ�ҵ������Զ����ƥ���������˵�';
                 RETURN;
            END IF;
                
                
            IF  V_COUNT=1 OR V_COUNT2=1 THEN --�Զ���ѯ��δƥ��Ĳ�������Ϣ
                
                
                 IF  V_ORDERTYPE = '1' THEN
                  --��ѯƥ����˵���
                     SELECT T.CHECKID,T.ACCOUNTNAME,T.ACCOUNTNUMBER INTO V_CHECKID,V_ACCOUNTNAME,V_ACCOUNTNUMBER  FROM TF_F_CHECK T,TF_F_ORDERCHECKRELATION P WHERE T.CHECKID = P.CHECKID(+) AND  P.CHECKID IS NULL AND 
                     T.MONEY = V_ORDERMONEY AND T.USEDMONEY = 0 AND T.ACCOUNTNAME = V_GROUPNAME AND T.CHECKSTATE ='1' AND T.USETAG = '1';                  
                 ELSE
                     SELECT T.CHECKID,T.ACCOUNTNAME,T.ACCOUNTNUMBER INTO V_CHECKID,V_ACCOUNTNAME,V_ACCOUNTNUMBER  FROM TF_F_CHECK T,TF_F_ORDERCHECKRELATION P WHERE T.CHECKID = P.CHECKID(+) AND  P.CHECKID IS NULL AND 
                     T.MONEY = V_ORDERMONEY AND T.USEDMONEY = 0 AND T.ACCOUNTNAME = V_NAME AND T.CHECKSTATE ='1' AND T.USETAG = '1';  
                    
                  END IF;
                
                  --���¶�����
                  BEGIN
                      UPDATE TF_F_ORDERFORM
                     SET    ORDERSTATE = '02',--���ͨ��
                             FINANCEAPPROVERNO = p_currOper,
                             FINANCEAPPROVERTIME = V_TODAY,
                             FINANCEREMARK = NULL,
                             UPDATEDEPARTNO = p_currDept,
                             UPDATESTAFFNO = p_currOper,
                             UPDATETIME = V_TODAY
                    WHERE  ORDERNO = P_ORDERNO;    
                    IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
                      EXCEPTION WHEN OTHERS THEN
                      p_retCode := 'S094570401';
                      p_retMsg  := '�Զ����ʱ���¶�����ʧ��,'|| SQLERRM;
                      ROLLBACK; RETURN;            
                   END;
                   
                     --�����˵���
                    BEGIN
                        UPDATE TF_F_CHECK 
                        SET    CHECKSTATE = '3', --���ʹ��
                               USEDMONEY = V_ORDERMONEY, --���ý������˵����
                               LEFTMONEY = 0, --ʣ����Ϊ0
                               UPDATEDEPARTNO = p_currDept,
                               UPDATESTAFFNO = p_currOper,
                               UPDATETIME = V_TODAY
                        WHERE  CHECKID = V_CHECKID;
                    IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
                    EXCEPTION WHEN OTHERS THEN
                        p_retCode := 'S094570402';
                        p_retMsg  := '�Զ����ʱ�����˵���ʧ��,'|| SQLERRM;
                        ROLLBACK; RETURN;            
                    END;
                
                 --������ˮ��
                SP_GetSeq(seq => v_seqNo); 
                --��¼�������˵�������ϵ��
                BEGIN
                    INSERT INTO TF_F_ORDERCHECKRELATION(
                        ORDERNO   , CHECKID   , TRADEID , MONEY            , UPDATESTAFFNO , UPDATETIME
                    )VALUES(
                        P_ORDERNO , V_CHECKID , v_seqNo , V_ORDERMONEY     , p_currOper    , V_TODAY
                    );
                IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
                EXCEPTION WHEN OTHERS THEN
                    p_retCode := 'S094570403';
                    p_retMsg  := '�Զ����ʱ��¼�������˵�������ϵ��ʧ��,'|| SQLERRM;
                    ROLLBACK; RETURN;            
                END;
                
                BEGIN
                  SELECT COUNT(*) INTO V_NUM FROM TF_F_COMBUYCARDREG T WHERE T.REMARK = P_ORDERNO;
                  
                  
                  IF V_NUM>0 THEN 
                  --���µ�λ������¼��
                  BEGIN
                    UPDATE TF_F_COMBUYCARDREG 
                    SET OUTBANK = v_ACCOUNTNUMBER,--ת�������ʺ�
                        OUTACCT = V_ACCOUNTNAME--ת���˻�����
                    WHERE REMARK = P_ORDERNO;
                     IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
                    EXCEPTION WHEN OTHERS THEN
                        p_retCode := 'S094570404';
                        p_retMsg  := '�Զ����ʱ���µ�λ������¼��ʧ��,'|| SQLERRM;
                        ROLLBACK; RETURN; 
                  END;
                  END IF;
                  
                END;
                
                  --��¼����̨��  ����TRADECODE '17'Ϊ�Զ����
                BEGIN
                    INSERT INTO TF_F_ORDERTRADE(
                        TRADEID , ORDERNO   ,TRADECODE , MONEY        , OPERATEDEPARTNO , OPERATESTAFFNO , OPERATETIME
                    )VALUES(
                        v_seqNo , P_ORDERNO ,'17'      , V_ORDERMONEY , p_currDept      , p_currOper     , V_TODAY
                    );
                IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
                EXCEPTION WHEN OTHERS THEN
                    p_retCode := 'S094570405';
                    p_retMsg  := '�Զ����ʱ��¼����̨��ʧ��,'|| SQLERRM;
                    ROLLBACK; RETURN;            
                END;
                --��¼�˵�̨��
                BEGIN
                    INSERT INTO TF_B_CHECK(
                        TRADEID , CHECKID   , TRADECODE , MONEY        , USEDMONEY        , LEFTMONEY        , OPERATESTAFFNO , OPERATETIME
                    )VALUES(
                        v_seqNo , V_CHECKID , '4'       , V_ORDERMONEY , V_ORDERMONEY     , 0                , p_currOper     , V_TODAY
                    );
                IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
                EXCEPTION WHEN OTHERS THEN
                    p_retCode := 'S094570406';
                    p_retMsg  := '�Զ����ʱ��¼�˵�̨��ʧ��,'|| SQLERRM;
                    ROLLBACK; RETURN;            
                END;
                
                    
          END IF;
     
        END IF;
        
        

    p_retCode := '0000000000';
    p_retMsg  := '�ɹ�';
    COMMIT; RETURN;    
END;

 
    
/
show errors;
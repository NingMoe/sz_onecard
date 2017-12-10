CREATE OR REPLACE PROCEDURE SP_RM_CHARGECARDPWD
(
    P_STARTCARDNO         char, --��ֵ������ 
    p_currOper          char    ,
    p_currDept          char    ,
    p_retCode       out char    ,  -- Return Code
    p_retMsg        out varchar2   -- Return Message  
)
AS 
    v_seqNo              CHAR(16); --ҵ����ˮ��
    V_COUNT              INT;
    V_NUM                CHAR(30);
    V_EX                 EXCEPTION;
    V_TODAY              DATE := SYSDATE;

BEGIN
         BEGIN
         SELECT T.TAGVALUE INTO V_NUM  FROM td_m_tag T WHERE T.TAGCODE = 'FINDPASSWORD_NUM';
         EXCEPTION WHEN NO_DATA_FOUND THEN
           p_retCode := 'S094570313';
                p_retMsg  := 'ϵͳ�����������Ƴ�ֵ�����ܴ�������,'|| SQLERRM;
                ROLLBACK; RETURN; 
                END;  
         select count(*) INTO V_COUNT from TL_XFC_MANAGELOG  t where OPERTYPECODE='08' and to_char(t.OPERTIME,'yyyymmdd') =to_char(V_TODAY,'yyyymmdd');
         IF V_COUNT > TO_NUMBER(V_NUM) THEN
          p_retCode := 'S094570313';
                p_retMsg  := '�˵�����ܴ����Ѵ�����,���ɼ�������'|| SQLERRM;
                ROLLBACK; RETURN; 
         END IF;
            SP_GetSeq(seq => v_seqNo); 
                
            --��¼��ֵ��������־��
            BEGIN
                INSERT INTO TL_XFC_MANAGELOG(
                    ID       ,STAFFNO        ,OPERTIME , OPERTYPECODE,STARTCARDNO   
                )VALUES(
                    v_seqNo , p_currOper     , V_TODAY ,'08',P_STARTCARDNO
                );
            IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
            EXCEPTION WHEN OTHERS THEN
                p_retCode := 'S094570313';
                p_retMsg  := '��¼��ֵ��������־��,'|| SQLERRM;
                ROLLBACK; RETURN;            
            END;        
       
    p_retCode := '0000000000';
    p_retMsg  := '�ɹ�';
    COMMIT; RETURN;    
END;
   
/
show errors
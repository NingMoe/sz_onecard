--------------------------------------------------
--  ����������洢����
--  ���α�д
--  ʯ��
--  2012-08-21
--------------------------------------------------
CREATE OR REPLACE PROCEDURE SP_EM_READERSTOCKOUT
(
    P_FROMREADERNO         VARCHAR2 ,  --��ʼ���������к�
    P_TOREADERNO           VARCHAR2 ,  --�������������к�
    P_READERNUMBER         INT  ,      --����������
    p_ASSIGNEDSTAFF        CHAR ,      --����Ա��
    p_MONEY                INT  ,      --���۽��
    P_REMARK               VARCHAR2 ,  --��ע
    p_currOper               char     ,
    p_currDept               char     ,
    p_retCode          out char     ,  -- Return Code
    p_retMsg           out varchar2    -- Return Message  
)
AS 
    v_seqNo             CHAR(16)       ;
    V_ASSIGNEDDEPT      CHAR(4)        ;
    V_EX                EXCEPTION      ;
    V_TODAY             DATE := SYSDATE;
    V_EXIST             INT;
    v_quantity          int;
    V_IsDepaBal         int;
    V_CARDPRICE         int;
    V_READERPRICE       int;
    V_READERNUM         int;
    V_DBALUNITNO        CHAR(8);
    V_USABLEVALUE       int;    
    V_DEPOSIT           int;
    v_cardnum           int;    
BEGIN
    --��ȡ����Ա�����ڲ���
    BEGIN
        SELECT DEPARTNO INTO V_ASSIGNEDDEPT
        FROM   TD_M_INSIDESTAFF
        WHERE  STAFFNO = p_ASSIGNEDSTAFF;
    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S094570203'; p_retMsg  := '�޷��õ�����Ա�����ڵĲ��ű���' || SQLERRM;
            RETURN;
    END;

    --��֤�Ƿ����ж������ڿ���
    SELECT COUNT(*) INTO V_EXIST 
    FROM   TL_R_READER 
    WHERE (SERIALNUMBER BETWEEN P_FROMREADERNO AND P_TOREADERNO) 
    AND    READERSTATE = '0';

    IF V_EXIST != P_READERNUMBER THEN    
        p_retCode := 'S094570204'; p_retMsg  := '���ж��������ڿ���';
        RETURN;
    END IF;

    -- 1) tell the consistence of v_quantity 
    v_quantity := P_TOREADERNO - P_FROMREADERNO + 1;
    
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
        --��ȡ���п�
        select count(*) into v_cardnum from TL_R_ICUSER a
        where exists (select * from  TD_DEPTBAL_RELATION b where a.assigneddepartid=b.departno and b.dbalunitno = V_DBALUNITNO)
        and a.RESSTATECODE IN('01','05');
        --��ȡ�û�����ֵ
        SELECT TAGVALUE INTO V_CARDPRICE FROM TD_M_TAG WHERE TAGCODE='USERCARD_MONEY'; 
        --��ȡ���ж���������
        select count(*) into V_READERNUM from TL_R_READER a
        where exists (select * from  TD_DEPTBAL_RELATION b where a.ASSIGNEDDEPARTID=b.departno and b.dbalunitno = V_DBALUNITNO)
        and a.READERSTATE IN ('1','4');
        --��ȡ�������۸�
        SELECT TAGVALUE INTO V_READERPRICE FROM TD_M_TAG WHERE TAGCODE='READER_PRICE'; 
        --��ȡ��֤�����
        SELECT DEPOSIT INTO V_DEPOSIT FROM TF_F_DEPTBAL_DEPOSIT WHERE ACCSTATECODE='01' AND DBALUNITNO = V_DBALUNITNO; 
        --������쿨��ֵ���
        V_USABLEVALUE := V_DEPOSIT - v_cardnum*V_CARDPRICE - V_READERNUM*V_READERPRICE;
        
        IF v_quantity*V_READERPRICE <= V_USABLEVALUE THEN    --�û�����ֵ�ܶ���ڿ��쿨��ֵ���ʱ
        BEGIN
            --����������㵥Ԫ��֤���˻���
            UPDATE TF_F_DEPTBAL_DEPOSIT
            SET    USABLEVALUE   = USABLEVALUE-v_quantity*V_CARDPRICE        ,
                   STOCKVALUE    = STOCKVALUE +v_quantity*V_CARDPRICE        ,
                   UPDATESTAFFNO = P_CURROPER                                ,
                   UPDATETIME    = V_TODAY
            WHERE  ACCSTATECODE  = '01'
            AND    DBALUNITNO    = V_DBALUNITNO;
                IF  SQL%ROWCOUNT    != 1 THEN RAISE V_EX; END IF;
                EXCEPTION WHEN OTHERS THEN
                    P_RETCODE := 'S008905101';
                    P_RETMSG  := '����������㵥Ԫ��֤���˻���ʧ��'||SQLERRM;
                ROLLBACK;RETURN;
        END;
        ELSE    
                P_RETCODE := 'S008905102';
                P_RETMSG  := '����������ܼ�ֵ���ܳ������쿨��ֵ���'||SQLERRM;
                ROLLBACK;RETURN;                                                            
        END IF;                                                                    
    END IF;            
    
    --���¶���������
    BEGIN
        UPDATE TL_R_READER
        SET    READERSTATE      = '1'        ,
               MONEY            = p_MONEY    ,
               OUTTIME          = V_TODAY    ,
               OUTSTAFFNO       = p_currOper ,
               ASSIGNEDSTAFFNO  = p_ASSIGNEDSTAFF , 
               ASSIGNEDDEPARTID = V_ASSIGNEDDEPT
        WHERE  SERIALNUMBER BETWEEN P_FROMREADERNO AND P_TOREADERNO
        AND    READERSTATE = '0' ;
        
        IF SQL%ROWCOUNT != P_READERNUMBER THEN RAISE V_EX; END IF;
    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S094570205'; p_retMsg  := '���¶���������ʧ��' || SQLERRM;
            ROLLBACK; RETURN;
    END;
    
    --��ȡ��ˮ��
    SP_GetSeq(seq => v_seqNo); 
    
    --��¼����������̨�˱�
    BEGIN
        INSERT INTO TF_B_READER(
            TRADEID     , OPERATETYPECODE , BEGINSERIALNUMBER , ENDSERIALNUMBER ,
            MONEY       , READERNUMBER    , OPERATETIME       , OPERATESTAFFNO  , 
            REMARK      , ASSIGNEDSTAFFNO , ASSIGNEDDEPARTID  
       )VALUES(
            v_seqNo     , '01'            , P_FROMREADERNO    , P_TOREADERNO    ,
            p_MONEY     , P_READERNUMBER  , V_TODAY           , p_currOper      , 
            P_REMARK    , p_ASSIGNEDSTAFF , V_ASSIGNEDDEPT
            );
    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S094570206'; p_retMsg  := '��¼����������̨�˱�ʧ��' || SQLERRM;
            ROLLBACK; RETURN;            
    END;
    
    p_retCode := '0000000000';
    p_retMsg  := '';
    COMMIT; RETURN;    
END;    

/
show errors
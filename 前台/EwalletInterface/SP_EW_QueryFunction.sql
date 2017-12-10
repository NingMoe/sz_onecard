CREATE OR REPLACE PROCEDURE SP_EW_QueryFunction
(
    p_CARDNOSECTION     VARCHAR2, --�����ַ���
    p_retCode           out char, -- Return Code
    p_retMsg            out varchar2  -- Return Message
)
AS
    V_SQL         VARCHAR2(10000);
    V_MSG         VARCHAR2(2000):='';
    V_CURSOR      SYS_REFCURSOR;
    V_FUNCNAME    VARCHAR2(20);
    V_MONEY       INT;
BEGIN
    --ƴ�Ӳ�ѯ���
    V_SQL := 'SELECT distinct(NVL(b.FUNCTIONNAME, a.FUNCTIONTYPE)) FUNCNAME
    FROM TF_F_CARDUSEAREA a,TD_M_FUNCTION b
    WHERE a.cardno in ('||p_CARDNOSECTION||')
    AND   a.USETAG = ''1''
    AND   a.FUNCTIONTYPE <> ''01''
    AND   (a.ENDTIME IS NULL OR a.ENDTIME >= TO_CHAR(SYSDATE, ''YYYYMMDD''))
    AND   a.FUNCTIONTYPE = b.FUNCTIONTYPE(+)';
    
    BEGIN
    OPEN V_CURSOR FOR V_SQL;
    LOOP
        FETCH V_CURSOR INTO V_FUNCNAME;
        EXIT WHEN V_CURSOR%NOTFOUND;
        
        V_MSG := V_MSG||V_FUNCNAME||',';
    END LOOP;
    EXCEPTION
        WHEN OTHERS THEN
        p_retCode:='S094570099';
        p_retMsg :='��ѯ����Ǯ����ͨ����ʧ��,'||SQLERRM;
        RETURN;
    END;
    
    V_SQL := 'SELECT SUM(CARDACCMONEY) FROM TF_F_CARDEWALLETACC WHERE CARDNO IN ('||p_CARDNOSECTION||') AND USETAG = ''1'' ' ;
    EXECUTE IMMEDIATE V_SQL INTO V_MONEY;
    IF V_MONEY > 0 THEN
        V_MSG := V_MSG||'��Ҫתֵ';
    END IF;
    
    --��ͨ�Ĺ��ܸ�ֵ�����ص�msg
    IF LENGTH(V_MSG) = 0 THEN
        p_retMsg := V_MSG;
    ELSE
        p_retMsg:= trim (trailing ',' from V_MSG);
    END IF;    
    
    --�ɹ�
    p_retCode:='0000000000';
    RETURN;
END;
/
show errors
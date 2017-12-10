create or replace procedure SP_RM_SECTIONMODIFY
(
    p_cardnoconfigid    char,        --���ñ�ID
    p_cardtypecode      char,        --��Ƭ����
    p_begincardno       char,        --��ʼ����
    p_endcardno         char,        --��ֹ����
    p_currOper          char,        --Ա������
    p_currDept          char,        --���ű���
    p_retCode       out char, -- Return Code
    p_retMsg        out varchar2  -- Return Message
)
as
    v_count        int;
    v_data        date;
    v_ex        EXCEPTION;
BEGIN
    v_data :=sysdate;
    BEGIN
        SELECT count(*) INTO v_count FROM 
        (SELECT * FROM TD_M_CARDNOCONFIG
        WHERE CARDNOCONFIGID != p_cardnoconfigid
            AND USETAG <> '0'
            AND( BEGINCARDNO BETWEEN p_begincardno AND p_endcardno
            OR ENDCARDNO BETWEEN p_begincardno AND p_endcardno)
        UNION
        SELECT * FROM TD_M_CARDNOCONFIG
        WHERE CARDNOCONFIGID != p_cardnoconfigid
            AND USETAG <> '0'        
            AND(p_begincardno BETWEEN BEGINCARDNO AND ENDCARDNO
            OR p_endcardno BETWEEN BEGINCARDNO AND BEGINCARDNO));
        IF v_count != 0 THEN
            p_retCode := 'S094780014';
            p_retMsg  := '���Ŷ��ڿ��д����ظ���¼';
            ROLLBACK;RETURN;
        END IF;
    END;
    BEGIN
    UPDATE TD_M_CARDNOCONFIG
        SET CARDTYPECODE = p_cardtypecode,
            BEGINCARDNO  = p_begincardno,
            ENDCARDNO     = p_endcardno,
            UPDATETIME     = v_data,
            UPDATESTAFFNO = p_currOper,
			UPDATETAG = '1'
        WHERE CARDNOCONFIGID = p_cardnoconfigid;
        
    IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;    
        EXCEPTION
                  WHEN OTHERS THEN
                      p_retCode := 'S094780013';
                      p_retMsg  := '�����û������Ŷ����ñ�ʧ��' || SQLERRM;
                  ROLLBACK; RETURN;
    END;
    
    p_retCode := '0000000000';
    p_retMsg  := '';
    COMMIT; RETURN;
END;

/
show errors
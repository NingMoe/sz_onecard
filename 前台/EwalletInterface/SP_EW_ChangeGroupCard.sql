CREATE OR REPLACE PROCEDURE SP_EW_ChangeGroupCard
(
	p_OLDCARDNO	        char, --�ɿ�����
	p_NEWCARDNO	        char, --�ɿ�����
	p_TRADEORIGIN       varchar2, --ҵ����Դ
	p_currOper	        char, --Ա������
	p_currDept	        char, --���ű���
	p_TRADEID           out char, -- Return Trade Id
	p_retCode	          out char, -- Return Code
	p_retMsg            out varchar2  -- Return Message
)
AS
    v_today     date := sysdate;
    v_OFFERMONEY int;
    v_groupCode char(4);
    v_quantity  int;
    v_ex        exception;
    v_seqNo     char(16);
BEGIN
    
    --�������˻���תֵ
    BEGIN
        SP_CA_CHANGECARDTRANSITBALANCE(p_OLDCARDNO,p_NEWCARDNO,p_TRADEORIGIN,p_currOper,p_currDept,p_retCode,p_retMsg,p_TRADEID,'0.0-000*0/0.');
        IF (p_retCode = 'A004P08B04') THEN  --���ݾɿ�δ���˻������
              p_retCode := '0000000000' ; p_retMsg  := '';
              return; 
        ELSIF (p_retCode != '0000000000') THEN
            RAISE v_ex;
        END IF;
        EXCEPTION
            WHEN OTHERS THEN
            RETURN;
    END;
    
    p_retCode := '0000000000'; p_retMsg  := '';
    RETURN;
   
END;	

/
show errors

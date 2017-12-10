create or replace procedure SP_PS_BALUNITDETAILCANCEL
(
    p_UNITNO          char,
    p_BALUNITNO       char,
    p_currOper        char,
    p_currDept        char,
    p_retCode     out char, -- Return Code
    p_retMsg      out varchar2  -- Return Message
)
as
    v_seqNo     char(16);
    v_CURRENTTIME date := sysdate;

BEGIN
    UPDATE TF_UNITE_BALUNIT
    SET    STATECODE = '2'
    WHERE  BALUNITNO = p_UNITNO and DETAILNO = p_BALUNITNO;
    
    IF SQL%ROWCOUNT != 1 THEN 
        raise_application_error(-20102, '更新合帐结算单元关系失败');
    END IF;
    
    SP_GetSeq(seq => v_seqNo);
    
    INSERT INTO TF_B_ASSOCIATETRADE  
      (TRADEID, TRADETYPECODE, ASSOCIATECODE, OPERATESTAFFNO,OPERATEDEPARTID, OPERATETIME)  
    VALUES
      (v_seqNo, '60', p_BALUNITNO, p_currOper, p_currDept, v_CURRENTTIME );  


	p_retCode := '0000000000';
	p_retMsg  := '';
	COMMIT; RETURN;

EXCEPTION WHEN OTHERS THEN
    p_retCode := SQLCODE;
    p_retMsg  := SQLERRM;
    ROLLBACK; RETURN;
END;
/

show errors
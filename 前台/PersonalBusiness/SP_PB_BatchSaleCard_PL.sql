CREATE OR REPLACE PROCEDURE SP_PB_BatchSaleCard
(
		p_beginCardno		char,
		p_endCardno			char,
		p_DEPOSIT	        int,
		p_CARDCOST	      	int,
		p_CURRENTTIME	    date, -- Return Operate Time
		p_currOper	      	char,
		p_currDept	      	char,
		p_remark			char,
		p_retCode	        out char, -- Return Code
		p_retMsg     	    out varchar2  -- Return Message

)
AS
    v_CURRENTTIME   date;
		v_TradeID				CHAR(16);
BEGIN
    IF p_CURRENTTIME IS NULL then
        v_CURRENTTIME := sysdate;
    ELSE
        v_CURRENTTIME := p_CURRENTTIME;
    END IF;
	
	--get seq
	SP_GetSeq(seq => v_TradeID); 
	
	BEGIN
		INSERT INTO TF_B_BATCHSALECARD		
		(		
		   TRADEID          ,    BEGINCARDNO   ,    ENDCARDNO          ,    CARDDEPOSIT       ,		
		   CARDCOST         ,    SELLTIME      ,    OPERATESTAFFNO     ,    OPERATEDEPARTID   ,		
		   OPERATETIME      ,    CHECKSTAFFNO  ,    CHECKDEPARTID      ,    CHECKTIME         ,		
		   STATECODE        ,    REMARK       		
		)		
		VALUES		
		 (	
		   v_TradeID        ,    p_beginCardno ,    p_endCardno        ,    p_DEPOSIT         ,		
		   p_CARDCOST       ,    v_CURRENTTIME ,    p_currOper         ,    p_currDept        ,		
		   sysdate          ,    ''            ,    ''                 ,    ''                ,		
		   '1'              ,    p_remark      		
		  );		
		EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S00601B020';
	            p_retMsg  := '新增批量售卡审批台帐表失败' || SQLERRM;
	            ROLLBACK; RETURN;
	END;
	
	p_retCode := '0000000000';
	p_retMsg  := '';
	COMMIT; RETURN;
END;
/
show errors
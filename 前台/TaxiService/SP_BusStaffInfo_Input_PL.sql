

CREATE OR REPLACE PROCEDURE SP_BusStaffInfo_Input
(   
   p_CALLINGSTAFFNO   CHAR,          --行业员工号      
   p_CALLINGNO	      CHAR,          --行业编码
   --p_BALUNITNO	      CHAR,        --单元编码            
   p_currOper	        CHAR,          --操作员工   
   p_currDept	        CHAR,          --操作员工所在部门      
   p_retCode   	      OUT CHAR,      --返回代码
   p_retMsg     	    OUT VARCHAR2   --返回消息
                                           
)
AS
   v_quantity         INT;                 --临时变量    
   v_currdate         DATE := SYSDATE;     --当前日期
   v_seqNo            CHAR(16);            --业务流水号  
                 
BEGIN 
	
	--1) 检查行业员工编码是否存在
	BEGIN
	 SELECT COUNT(*) INTO v_quantity FROM TD_M_CALLINGSTAFF 
	   WHERE STAFFNO = p_CALLINGSTAFFNO AND CALLINGNO = p_CALLINGNO ;
	  
	  IF v_quantity >= 1 THEN
       p_retCode := 'A003100033';
       p_retMsg  := '行业员工编码已存在,' || SQLERRM;
       RETURN;
    END IF; 
  END;
	
   
	--2) 增加行业员工编码表信息
  BEGIN
    INSERT INTO TD_M_CALLINGSTAFF
		  (STAFFNO, CALLINGNO, UPDATESTAFFNO, UPDATETIME)
    VALUES
      (p_CALLINGSTAFFNO, p_CALLINGNO, p_currOper, v_currdate);
			
    EXCEPTION
     WHEN OTHERS THEN
       p_retCode := 'S003100003';
       p_retMsg  := '增加增加行业员工编码表信息失败,' || SQLERRM;
       ROLLBACK; RETURN;
  END; 
		
	--3) 取得业务流水号
	SP_GetSeq(seq => v_seqNo); 
	      
	--4) 增加合作伙伴业务台帐主表信息  
	BEGIN
    INSERT INTO TF_B_ASSOCIATETRADE
		 (TRADEID, TRADETYPECODE, ASSOCIATECODE, OPERATESTAFFNO, OPERATEDEPARTID, OPERATETIME)
 	  VALUES
 	   (v_seqNo, '46', p_CALLINGSTAFFNO, p_currOper, p_currDept, v_currdate);
 	 
 	  EXCEPTION
      WHEN OTHERS THEN
        p_retCode := 'S003100008';
        p_retMsg  := '增加合作伙伴业务台帐主表信息失败,' || SQLERRM;
        ROLLBACK; RETURN;
  END;   
	
  --5) 增加行业员工编码资料变更子表信息    
  BEGIN 
  	INSERT INTO TF_B_CALLINGSTAFFCHANGE(TRADEID, STAFFNO, CALLINGNO)
    VALUES (v_seqNo, p_CALLINGSTAFFNO, p_CALLINGNO);
  	 
 	 EXCEPTION
	   WHEN OTHERS THEN
	     p_retCode := 'S003100010';
	     p_retMsg  := '增加行业员工编码资料变更子表信息失败,' || SQLERRM;
	     ROLLBACK; RETURN;
  END;    
		    
  p_retCode := '0000000000';
  p_retMsg  := '';
  COMMIT; RETURN;
  
END;

/
show errors   

CREATE OR REPLACE PROCEDURE SP_UC_StockOut_COMMIT
(
    p_fromCardNo    char, -- From Card No.
    p_toCardNo      char, -- End  Card No.
    p_assignedStaff char, -- Assigned Staff No
    p_serviceCycle  char, -- Service Cycle Type
    p_serviceFee    int , -- Service Fee per Service Cycle
    p_retValMode    char, -- Value-Return Mode, like 'Return All' or 'No return'
    p_currOper      char, -- Current Operator
    p_currDept      char, -- Curretn Operator's Department
    
    p_saleType		char, -- sale card type -- add by jiangbb 2012-05-10
      
    p_retCode       out char, -- Return Code
    p_retMsg        out varchar2  -- Return Message
)
AS
    v_assignedDept  char(4); -- Assigned Staff's Department  
    v_fromCard      numeric(16);
    v_toCard        numeric(16);
    v_quantity      int;
    V_IsDepaBal     int;
    V_CARDPRICE     int;
    v_today         date := sysdate;
    v_ex            EXCEPTION;
    V_DBALUNITNO    CHAR(8);
    V_USABLEVALUE   int;    
    V_DEPOSIT       int;
    v_cardnum       int;
BEGIN
    -- 1) tell the consistence of v_quantity 
    v_fromCard := TO_NUMBER(p_fromCardNo);
    v_toCard   := TO_NUMBER(p_toCardNo);
    v_quantity := v_toCard - v_fromCard + 1;
    	
    BEGIN
        SELECT DEPARTNO INTO v_assignedDept
            FROM  TD_M_INSIDESTAFF
            WHERE STAFFNO = p_assignedStaff;
    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'A002P04D02'; p_retMsg  := '无法得到分配员工所在的部门编码' || SQLERRM;
            RETURN;
    END;
    
    --如果是代理营业厅领卡则更新网点结算单元保证金账户表
    SELECT COUNT(*) INTO V_IsDepaBal 																	
    FROM TD_DEPTBAL_RELATION a,TF_DEPT_BALUNIT b																	
    WHERE  a.DEPARTNO = v_assignedDept																	
    AND    a.DBALUNITNO = b.DBALUNITNO
    AND    b.USETAG = '1'
    AND    a.USETAG = '1'
    AND    b.DEPTTYPE = '1';

    IF  V_IsDepaBal != 0 THEN --如果是代理营业厅
        --获取网点结算单元编码
        SELECT DBALUNITNO INTO V_DBALUNITNO FROM TD_DEPTBAL_RELATION WHERE USETAG = '1' AND DEPARTNO = v_assignedDept; 
        --获取已有卡
        select count(*) into v_cardnum from TL_R_ICUSER a
        where exists (select * from  TD_DEPTBAL_RELATION b where a.assigneddepartid=b.departno and b.dbalunitno = V_DBALUNITNO)
        and a.RESSTATECODE IN('01','05');
        --获取用户卡价值
        SELECT TAGVALUE INTO V_CARDPRICE FROM TD_M_TAG WHERE TAGCODE='USERCARD_MONEY'; 
        --获取保证金余额
        SELECT DEPOSIT INTO V_DEPOSIT FROM TF_F_DEPTBAL_DEPOSIT WHERE ACCSTATECODE='01' AND DBALUNITNO = V_DBALUNITNO; 
        --计算可领卡价值额度
        V_USABLEVALUE := V_DEPOSIT - v_cardnum*V_CARDPRICE;
        
        IF v_quantity*V_CARDPRICE <= V_USABLEVALUE THEN	--用户卡价值总额不大于可领卡价值额度时
        BEGIN
            --更新网点结算单元保证金账户表
            UPDATE TF_F_DEPTBAL_DEPOSIT
            SET    USABLEVALUE   = USABLEVALUE-v_quantity*V_CARDPRICE		,
                   STOCKVALUE    = STOCKVALUE +v_quantity*V_CARDPRICE		,
                   UPDATESTAFFNO = P_CURROPER													,
                   UPDATETIME    = V_TODAY
            WHERE  ACCSTATECODE  = '01'
            AND    DBALUNITNO    = V_DBALUNITNO;
		        IF  SQL%ROWCOUNT    != 1 THEN RAISE V_EX; END IF;
		        EXCEPTION WHEN OTHERS THEN
		            P_RETCODE := 'S008905101';
		            P_RETMSG  := '更新网点结算单元保证金账户表失败'||SQLERRM;
		        ROLLBACK;RETURN;
        END;
        ELSE	
		        P_RETCODE := 'S008905102';
		        P_RETMSG  := '出库卡价值不能超过可领卡价值额度'||SQLERRM;
		        ROLLBACK;RETURN;															
        END IF;																	
    END IF;		    	
    
    --用户卡出库
    BEGIN
    SP_UC_StockOut(p_fromCardNo,p_toCardNo,p_assignedStaff,p_serviceCycle,p_serviceFee,
                   p_retValMode,V_CARDPRICE,p_currOper,p_currDept,p_saleType,p_retCode,p_retMsg);
    IF p_retCode != '0000000000' THEN RAISE v_ex; END IF;
       EXCEPTION
       WHEN OTHERS THEN
           ROLLBACK; RETURN;
    END;
    
    p_retCode := '0000000000';
	  p_retMsg  := '';
	  COMMIT; RETURN;    
END;

/
show errors
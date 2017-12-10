create or replace procedure SP_EM_BuildRelation
(
	p_posNo			char,
	p_psamNo		char,
	p_callingNo		char,
	p_corpNo		char,
	p_deptNo		char,
	p_svcMgrNo		char,
	p_posSource		char,
	p_balUnitNo		char,
	p_UnitNo		char,
	p_note			varchar2,
	p_psamtype      varchar2,
  P_isTradeLimit  char,
	p_currOper		char,
	p_currDept		char,
	p_retCode		out char,
	p_retMsg		out varchar2
)
as
	v_currentdate       date := sysdate;
	v_posResState       tl_r_equa.resstatecode%type;
	v_posReInTime       date;
	v_posFreezeSpan     numeric(3);
	v_posSourceInStock  tl_r_equa.equsource%type;
	v_psamResState      char(2);
	v_psamReInTime      date;
	v_psamFreezeSpan    numeric(3);
	v_balUnitUseTag     TD_M_TRADE_SOURCE.USETAG%TYPE;

  v_posNo             tl_r_equa.posno%type		:= p_posNo;
  v_corpNo            tl_r_equa.corpno%type		:= p_corpNo;
  v_deptNo            tl_r_equa.departno%type	:= p_deptNo;
  v_posSource         tl_r_equa.equsource%type	:= p_posSource;

  v_seqNo		      TF_R_STOCKRESOURCESTRADE.TRADEID%TYPE;

  v_empDeptNo         tl_r_equa.departno%type;
  v_ex        exception;
begin

	if p_posNo = '' then
		v_posNo := null;
	end if;

	if p_corpNo = '' then
		v_corpNo := null;
	end if;

	if p_deptNo = '' then
		v_deptNo := null;
	end if;

	if p_posSource = '' then
		v_posSource := null;
	end if;

	-- when posno is not  blank, check it
	if v_posNo is not null then

		begin
			select RESSTATECODE,REINTIME,EQUSOURCE into v_posResState,v_posReInTime,v_posSourceInStock from TL_R_EQUA where POSNO = v_posNo;
		exception
			when no_data_found then
				p_retCode := 'A006500050';
				p_retMsg  := '';
				rollback; return;
		end;

		-- check pos source
		if v_posSource != v_posSourceInStock then
			p_retCode := 'A006500106';
			p_retMsg  := '';
			rollback; return;
		end if;

		-- pos state must be '00'(in stock)
		if v_posResState != '00' then
			p_retCode := 'A006500051';
			p_retMsg  := '';
			rollback; return;
		end if;

		-- when pos REINTIME exists
		if v_posReInTime is not null then
			-- query  pos freezespan
			begin
				select to_number(TAGVALUE) into v_posFreezeSpan from TD_M_TAG where TAGCODE = 'POS_FREEZESPAN' and USETAG = '1';
				if v_currentdate-v_posReInTime <= v_posFreezeSpan then
					p_retCode := 'A006500052';
					p_retMsg  := '';
					rollback; return;
				end if;
			exception
				when no_data_found then null;
			end;
		end if;

	end if;

	-- when psamno desn't exist  in stock ,report error and exit
	begin
		select RESSTATECODE,REINTIME into v_psamResState,v_psamReInTime from TL_R_ICOTHER where CARDNO = p_psamNo;
		-- psam's state must be '00'(in stock)
		if v_psamResState != '00' then
			p_retCode := 'A006500054';
			p_retMsg  := '';
			rollback; return;
		end if;

		-- when psam's REINTIME exists, check whether it's freezed
		if v_psamReInTime is not null then
			-- query  psam freezespan
			begin
				select to_number(TAGVALUE) into v_psamFreezeSpan from TD_M_TAG where TAGCODE = 'PSAM_FREEZESPAN' and USETAG = '1';
				if v_currentdate-v_psamReInTime <= v_psamFreezeSpan then
					p_retCode := 'A006500055';
					p_retMsg  := '';
					rollback; return;
				end if;
			exception
				when no_data_found then null;
			end;
		end if;

	exception
		when no_data_found then
			p_retCode := 'A006500053';
			p_retMsg  := '';
			rollback; return;
	end;

	select DEPARTNO into v_empDeptNo from TD_M_INSIDESTAFF where STAFFNO = p_svcMgrNo;

	-- when posNo isn't blank , update the pos's information in stock
	if v_posNo is not null then
		begin
			update  TL_R_EQUA
			set		RESSTATECODE        =        '01',
					OUTTIME             =        v_currentdate,
					USETIME             =        v_currentdate,
					REINTIME            =        null,
					CALLINGNO           =        p_callingNo,
					CORPNO              =        v_corpNo,
					DEPARTNO            =        v_deptNo,
					ASSIGNEDSTAFFNO     =        p_svcMgrNo,
					ASSIGNEDDEPARTID    =        v_empDeptNo,
					UPDATESTAFFNO       =        p_currOper,
					UPDATETIME          =        v_currentdate
			where	POSNO               =        v_posNo;
			if  SQL%ROWCOUNT != 1 then raise v_ex; end if;
		exception
			when others then
				p_retCode := 'S006500056';
				p_retMsg  := '';
				rollback; return;
		end;
	end if;

	-- update the psam's information in stock
	begin
		update	TL_R_ICOTHER
		set		RESSTATECODE      =        '01',
				CALLINGNO         =        p_callingNo,
				CORPNO            =        v_corpNo,
				DEPARTNO          =        v_deptNo,
				OUTTIME           =        v_currentdate,
				USETIME           =        v_currentdate,
				REINTIME          =        null,
				ASSIGNEDSTAFFNO   =        p_svcMgrNo,
				ASSIGNEDDEPARTID  =        v_empDeptNo,
				UPDATESTAFFNO     =        p_currOper,
				UPDATETIME        =        v_currentdate
		where	CARDNO            =        p_psamNo;
		if  SQL%ROWCOUNT != 1 then raise v_ex; end if;
	exception
		when others then
			p_retCode := 'S006500057';
			p_retMsg  := '';
			rollback; return;
	end;

	-- record the relation of pos, psam and balance unit
	begin
		insert into TF_R_PSAMPOSREC (
			SAMNO,            POSNO,            CALLINGNO,         CORPNO,           DEPARTNO,
			SERMANAGERCODE,   BALUNITNO,        USETYPECODE,       TAKETIME,         UPDATESTAFFNO,
			UPDATETIME,       REMARK
		)
		values (
			p_psamNo,          v_posNo,  			p_callingNo,        v_corpNo,          v_deptNo,
			p_svcMgrNo,        p_balUnitNo,     	v_posSource,        v_currentdate,     p_currOper,
			v_currentdate,     p_note
		);
	exception
		when others then
			p_retCode := 'S006500058';
			p_retMsg  := '';
			rollback; return;
	end;

	-- update balance unit source info
	begin
		select USETAG into v_balUnitUseTag from TD_M_TRADE_SOURCE
		where SOURCECODE in (p_psamNo, p_psamNo || '0000', p_psamNo || '0001') and rownum < 2;
		--  when the balance unit info desn't  exist ,  check its USETAG, then update
		if v_balUnitUseTag = '1' then
			p_retCode := 'A006500059';
			p_retMsg  := '';
			rollback; return;
		end if;

    		begin
    			update	TD_M_TRADE_SOURCE
    			set		BALUNITNO       =        p_balUnitNo,
    					USETAG          =        '1',
    					UPDATESTAFFNO   =        p_currOper,
    					UPDATETIME      =        v_currentdate
    			where	SOURCECODE      in        (p_psamNo, p_psamNo || '0000', p_psamNo || '0001');
    		exception
    			when others then
    				p_retCode := 'S006500060';
    				p_retMsg  := '';
    				rollback; return;
    		end;
    exception
    		when no_data_found then
    		if p_psamtype = '0' and  p_balUnitNo != '0E000001' then    --普通商户
    			begin
    				--  when the balance unit info desn't  exist ,  insert a record
    				insert into TD_M_TRADE_SOURCE (
    					SOURCECODE,	BALUNITNO, 	USETAG,	UPDATESTAFFNO, 	UPDATETIME
    				)
    				values(
    					p_psamNo,    p_balUnitNo,	'1',    p_currOper,      v_currentdate
    				);
    			exception
    				when others then
    					p_retCode := 'S006500061';
    					p_retMsg  := '';
    					rollback; return;
    			end;
			elsif p_psamtype = '1' then
			    begin
    				--  when the balance unit info desn't  exist ,  insert a record
    				insert into TD_M_TRADE_SOURCE (
    					SOURCECODE,	BALUNITNO, 	USETAG,	UPDATESTAFFNO, 	UPDATETIME
    				)
    				values(
    					p_psamNo || '0000',    p_balUnitNo,	'1',    p_currOper,      v_currentdate
    				);

    				insert into TD_M_TRADE_SOURCE (
    					SOURCECODE,	BALUNITNO, 	USETAG,	UPDATESTAFFNO, 	UPDATETIME
    				)
    				values(
    					p_psamNo || '0001',    p_UnitNo,	'1',    p_currOper,      v_currentdate
    				);
    			exception
    				when others then
    					p_retCode := 'S006500061';
    					p_retMsg  := '';
    					rollback; return;
    			end;
			end if;
	end;

	-- log
	SP_GetSeq(seq => v_seqNo);

	begin
		insert into TF_R_STOCKRESOURCESTRADE (
			TRADEID,          OPETYPECODE,          POSNO,         SAMNO,
			CALLINGNO,        CORPNO,               DEPARTNO,      BALUNITNO,
			ASSIGNEDSTAFFNO,  ASSIGNEDDEPARTID,     OPERATESTAFFNO,   OPERATEDEPARTID,
			OPERATETIME
		)
		values(
			v_seqNo,        'K6',                 v_posNo,        p_psamNo,
			p_callingNo,       v_corpNo,              v_deptNo,       p_balUnitNo,
			p_svcMgrNo,        v_empDeptNo,         p_currOper,       p_currDept,
			v_currentdate
		);
	exception
		when others then
			p_retCode := 'S006500062';
			p_retMsg  := '';
			rollback; return;
	end;

	if p_psamtype = '1' then --非油品

	SP_GetSeq(seq => v_seqNo);

    	begin
    		insert into TF_R_STOCKRESOURCESTRADE (
    			TRADEID,          OPETYPECODE,          POSNO,         SAMNO,
    			CALLINGNO,        CORPNO,               DEPARTNO,      BALUNITNO,
    			ASSIGNEDSTAFFNO,  ASSIGNEDDEPARTID,     OPERATESTAFFNO,   OPERATEDEPARTID,
    			OPERATETIME
    		)
    		values(
    			v_seqNo,        'K6',                 v_posNo,        p_psamNo,
    			p_callingNo,       v_corpNo,              v_deptNo,       p_UnitNo,
    			p_svcMgrNo,        v_empDeptNo,         p_currOper,       p_currDept,
    			v_currentdate
    		);
    	exception
    		when others then
    			p_retCode := 'S006500062';
    			p_retMsg  := '';
    			rollback; return;
    	end;
	end if;
  if P_isTradeLimit='1' THEN  --支持联机消费
  BEGIN
     INSERT INTO TF_TRADE_LIMIT(
     ACCT_TYPE_NO  , SAMNO     ,ACCT_TYPE_NAME  ,POSNO    ,BALUNITNO   ,USETAG   ,CREATE_DATE
     )
     VALUES(
     '0001'        ,p_psamNo   ,'一卡通现金账户'  ,v_posNo  ,p_balUnitNo    ,'1'      ,v_currentdate
     );
     exception
    		when others then
    			p_retCode := 'S006500063:插入POS消费限制表失败';
    			p_retMsg  := '';
    			rollback; return;
  END;
  END IF;
	p_retCode := '0000000000';
	p_retMsg  := '';

	commit; return;

end;
/
show errors
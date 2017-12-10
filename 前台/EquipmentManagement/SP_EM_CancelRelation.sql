create or replace procedure SP_EM_CancelRelation
(
	p_posNo			char,
	p_psamNo		char,
	p_callingNo		char,
	p_corpNo		char,
	p_deptNo		char,
	p_svcMgrNo		char,
	p_posSource		char,
	p_balUnitNo		char,
	p_note			varchar2,
	p_currOper		char,
	p_currDept		char,
	p_retCode		out char,
	p_retMsg		out varchar2
)
as
	v_currentdate   date := sysdate;
	v_seqNo		    TF_R_STOCKRESOURCESTRADE.TRADEID%TYPE;
    v_tmp           int;

	v_posNo             tl_r_equa.posno%type		:= p_posNo;
	v_corpNo            tl_r_equa.corpno%type		:= p_corpNo;
	v_deptNo            tl_r_equa.departno%type		:= p_deptNo;
	v_posSource         tl_r_equa.equsource%type	:= p_posSource;

	v_empDeptNo         tl_r_equa.departno%type;
  v_oldLimit  int;
	v_ex	exception;
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

	-- when posno isn't  blank,  update the record
	if v_posNo is not null then
		begin
			update  TL_R_EQUA
			set		RESSTATECODE      =      '00',
					CALLINGNO         =      null,
					CORPNO            =      null,
					DEPARTNO          =      null,
					OUTTIME           =      null,
					USETIME           =      null,
					REINTIME          =      v_currentdate,
					ASSIGNEDSTAFFNO   =      p_currOper,
					ASSIGNEDDEPARTID  =      p_currDept,
					UPDATESTAFFNO     =      p_currOper,
					UPDATETIME        =      v_currentdate
			where	POSNO             =      v_posNo;
			if  SQL%ROWCOUNT != 1 then raise v_ex; end if;
		exception
			when others then
				p_retCode := 'S006500100';
				p_retMsg  := '';
				rollback; return;
		end;
	end if;

	-- update the  psam record
	begin
		update   TL_R_ICOTHER
		set
				RESSTATECODE      =      '00',
				CALLINGNO         =      null,
				CORPNO            =      null,
				DEPARTNO          =      null,
				OUTTIME           =      null,
				USETIME           =      null,
				REINTIME          =      v_currentdate,
				ASSIGNEDSTAFFNO   =      p_currOper,
				ASSIGNEDDEPARTID  =      p_currDept,
				UPDATESTAFFNO     =      p_currOper,
				UPDATETIME        =      v_currentdate
		where	CARDNO            =      p_psamNo;
		if  SQL%ROWCOUNT != 1 then raise v_ex; end if;
	exception
		when others then
			p_retCode := 'S006500101';
			p_retMsg  := '';
			rollback; return;
	end;

	-- delete the relation of pos, psam and balance unit
	begin
		delete from TF_R_PSAMPOSREC where SAMNO  =  p_psamNo;
		if  SQL%ROWCOUNT != 1 then raise v_ex; end if;
	exception
		when others then
			p_retCode := 'S006500102';
			p_retMsg  := '';
			rollback; return;
	end;
  
  --删除旧的SAMNO对应的联机消费
  begin 
     select count(*) into v_oldLimit from TF_TRADE_LIMIT where SAMNO = p_psamNo  and ACCT_TYPE_NO='0001';
      if v_oldLimit>0 then
        BEGIN
            delete from TF_TRADE_LIMIT where SAMNO  =  p_psamNo ;
            if  SQL%ROWCOUNT != 1 then raise v_ex; end if;
          exception
            when others then
              p_retCode := 'S006500096:删除POS消费限制表失败';
              p_retMsg  := '';
              rollback; return;
         END;
      end if;
  end;

	-- disable the balance unit source
	if p_balUnitNo != '0E000001' THEN
    	begin
    		update  TD_M_TRADE_SOURCE
    		set		USETAG          =     '0',
    				UPDATESTAFFNO   =     p_currOper,
    				UPDATETIME      =     v_currentdate
    		where	SOURCECODE      in    (p_psamNo, p_psamNo || '0000', p_psamNo || '0001');
    
    	exception
    		when others then
    			p_retCode := 'S006500103';
    			p_retMsg  := '';
    			rollback; return;
    	end;
    END IF;

	-- log
	SP_GetSeq(seq => v_seqNo);

    BEGIN
    	select DEPARTNO into v_empDeptNo from TD_M_INSIDESTAFF where STAFFNO = p_svcMgrNo;

    EXCEPTION
    	WHEN NO_DATA_FOUND THEN
    	p_retCode := 'A006500013';
    	p_retMsg  := '';
    	rollback; return;
    END;

	begin
		insert into TF_R_STOCKRESOURCESTRADE(
			TRADEID,          OPETYPECODE,          POSNO,         SAMNO,
			CALLINGNO,        CORPNO,               DEPARTNO,      BALUNITNO,
			ASSIGNEDSTAFFNO,  ASSIGNEDDEPARTID,     OPERATESTAFFNO, OPERATEDEPARTID,
			OPERATETIME
		)
		values(
			v_seqNo,        'K9',                 v_posNo,        p_psamNo,
			p_callingNo,       v_corpNo,              v_deptNo,       p_balUnitNo,
			p_svcMgrNo,      v_empDeptNo,           p_currOper,      p_currDept,
			v_currentdate
		);
	exception
		when others then
			p_retCode := 'S006500104';
			p_retMsg	:= '';
			rollback; return;
	end;

    p_retCode := '0000000000';
	p_retMsg	:= '';

	commit; return;

end;
/

show errors
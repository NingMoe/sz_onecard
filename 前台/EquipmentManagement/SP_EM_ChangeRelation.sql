create or replace procedure SP_EM_ChangeRelation
(
	p_newPosNo		char,
	p_oldPosNo		char,
	p_newPsamNo		char,
	p_oldPsamNo		char,
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
    v_NoteChange          char(1);
	v_currentdate         date    := sysdate;
	v_isNewPsamChanged    char(1) := '1';
	v_isNewPosChanged     char(1) := '1';
	v_newPsamState        tl_r_icother.resstatecode%type;
	v_newPsamReInTime     date;
	v_psamFreezeSpan      numeric(3);
	v_newPosState         char(2);
	v_newPosReInTime      date;
	v_posFreezeSpan       numeric(3);
	v_newPosSourceInStock tl_r_equa.equsource%type;
	v_newPsamSourceUseTag TD_M_TRADE_SOURCE.USETAG%TYPE;
	v_seqNo		          TF_R_STOCKRESOURCESTRADE.TRADEID%TYPE;

	v_newPosNo             tl_r_equa.posno%type		:= p_newPosNo;
	v_oldPosNo             tl_r_equa.posno%type		:= p_oldPosNo;
	v_corpNo            tl_r_equa.corpno%type		:= p_corpNo;
	v_deptNo            tl_r_equa.departno%type		:= p_deptNo;
	v_posSource         tl_r_equa.equsource%type	:= p_posSource;

	v_empDeptNo         tl_r_equa.departno%type;
  
  v_oldLimit   int;
  v_newLimit   int;
  v_newLimit2  int;
	v_ex	exception;
begin

	if p_newPosNo = '' then
		v_newPosNo := null;
	end if;

	if p_oldPosNo = '' then
		v_oldPosNo := null;
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

	if p_newPsamNo = p_oldPsamNo then
		v_isNewPsamChanged := '0';
	end if;

	if ((p_newPsamNo is null and p_oldPsamNo is null) or p_newPsamNo = p_oldPsamNo)
	    and ((v_newPosNo is null and v_oldPosNo is null) or v_newPosNo = v_oldPosNo) then
	    v_NoteChange := '0';
	end if;

	--when  the new PSAMNO is changed, check:
	-- (1) whether it exists in stock
	-- (2) its state must be  '00'(in stock)
	-- (3) whether it's freezed
	if v_isNewPsamChanged = '1' then
		begin
			select RESSTATECODE,REINTIME into v_newPsamState,v_newPsamReInTime from TL_R_ICOTHER where CARDNO = p_newPsamNo;
			if v_newPsamState != '00' then
				p_retCode := 'A006500081';
				p_retMsg  := '';
				rollback; return;
			end if;

			if v_newPsamReInTime is not null then
				begin
					select to_number(TAGVALUE) into v_psamFreezeSpan from TD_M_TAG where TAGCODE = 'PSAM_FREEZESPAN' and USETAG = '1';
					if v_currentdate-v_newPsamReInTime <= v_psamFreezeSpan then
						p_retCode := 'A006500082';
						p_retMsg  := '';
						rollback; return;
					end if;
				exception
					when no_data_found then null;
				end;
			end if;
		exception
			when no_data_found then
				p_retCode := 'A006500080';
				p_retMsg  := '';
				rollback; return;
		end;
	end if;

	--check POSNO

	if (v_newPosNo is null and  v_oldPosNo is null) or (v_newPosNo is not null and v_oldPosNo is not null and v_newPosNo = v_oldPosNo) then
		v_isNewPosChanged := '0';
	end if;

	--when  the new POSNO is changed, check:
	-- (1)if it exists in stock
	-- (2) its state must be  '00'(in stock)
	-- (3) if it's freezed
	if v_isNewPosChanged = '1' and v_newPosNo is not null then
		begin
			select RESSTATECODE,REINTIME,EQUSOURCE into v_newPosState,v_newPosReInTime,v_newPosSourceInStock from TL_R_EQUA where POSNO = v_newPosNo;
		exception
			when no_data_found then
				p_retCode := 'A006500083';
				p_retMsg  := '';
				rollback; return;
		end;

		if v_posSource != v_newPosSourceInStock then
			p_retCode := 'A006500106';
			p_retMsg  := '';
			rollback; return;
		end if;

		-- (2) its state must be  '00'(in stock)
		if v_newPosState != '00' then
			p_retCode := 'A006500084';
			p_retMsg  := '';
			rollback; return;
		end if;

		-- (3) if it's freezed
		if v_newPosReInTime is not null then
			begin
				select to_number(TAGVALUE) into v_posFreezeSpan from TD_M_TAG where TAGCODE = 'POS_FREEZESPAN' and USETAG = '1';
				if v_currentdate-v_newPosReInTime <= v_posFreezeSpan then
					p_retCode := 'A006500085';
					p_retMsg  := '';
					rollback; return;
				end if;
			exception
				when no_data_found then null;
			end;
		end if;

	end if;

	select DEPARTNO into v_empDeptNo from TD_M_INSIDESTAFF where STAFFNO = p_svcMgrNo;

	-- when new PSAMNO is changed
	-- (1) update trade source info
	-- (2) update PSAM, POS  relation
	-- (3) update PSAM stock info
	if v_isNewPsamChanged = '1' then
		begin
			update TD_M_TRADE_SOURCE
			set	   USETAG         =  '0',
			       UPDATESTAFFNO  =  p_currOper,
				   UPDATETIME     =  v_currentdate
			where  SOURCECODE   in  (p_oldPsamNo, p_oldPsamNo || '0000', p_oldPsamNo || '0001');
		exception
			when others then
				p_retCode := 'S006500086';
				p_retMsg  := '';
				rollback; return;
		end;

		begin
			select USETAG into v_newPsamSourceUseTag from TD_M_TRADE_SOURCE
			where SOURCECODE in (p_newPsamNo, p_newPsamNo || '0000', p_newPsamNo || '0001') and rownum < 2;
			if v_newPsamSourceUseTag = '1' then
				p_retCode := 'A006500087';
				p_retMsg  := '';
				rollback; return;
			else
				begin
					--   update new trade source info
					update	TD_M_TRADE_SOURCE
					set		BALUNITNO       =        p_balUnitNo,
							USETAG          =        '1',
							UPDATESTAFFNO   =        p_currOper,
							UPDATETIME      =        v_currentdate
					where	SOURCECODE      in      (p_newPsamNo, p_newPsamNo || '0000', p_newPsamNo || '0001');
				exception
					when no_data_found then
						p_retCode := 'S006500088';
						p_retMsg  := '';
						rollback; return;
				end;
			end if;
		exception
			when no_data_found then
			if p_psamtype = '0' and  p_balUnitNo != '0E000001' then    --普通商户
				begin
					insert into TD_M_TRADE_SOURCE (
						SOURCECODE,	BALUNITNO,	USETAG,	UPDATESTAFFNO,	UPDATETIME
					)
					values(
						p_newPsamNo, p_balUnitNo, '1',    p_currOper,   v_currentdate
					);
				exception
					when others then
						p_retCode := 'S006500089';
						p_retMsg  := '';
						rollback; return;
				end;
			elsif p_psamtype = '1' THEN
			    begin
    				--  when the balance unit info desn't  exist ,  insert a record
    				insert into TD_M_TRADE_SOURCE (
    					SOURCECODE,	BALUNITNO, 	USETAG,	UPDATESTAFFNO, 	UPDATETIME
    				)
    				values(
    					p_newPsamNo || '0000',    p_balUnitNo,	'1',    p_currOper,      v_currentdate
    				);

    				insert into TD_M_TRADE_SOURCE (
    					SOURCECODE,	BALUNITNO, 	USETAG,	UPDATESTAFFNO, 	UPDATETIME
    				)
    				values(
    					p_newPsamNo || '0001',    p_UnitNo,	'1',    p_currOper,      v_currentdate
    				);

				exception
    				when others then
    					p_retCode := 'S006500061';
    					p_retMsg  := '';
    					rollback; return;
    			end;
			end if;
		end;

		-- (2) update PSAM, POS  relation

		--  delete old relation
		begin
			delete from TF_R_PSAMPOSREC where SAMNO  =  p_oldPsamNo;
			if  SQL%ROWCOUNT != 1 then raise v_ex; end if;
		exception
			when others then
				p_retCode := 'S006500090';
				p_retMsg  := '';
				rollback; return;
		end;

		-- add new relation
		begin
			insert into TF_R_PSAMPOSREC(
				SAMNO,            POSNO,            CALLINGNO,         CORPNO,           DEPARTNO,
				SERMANAGERCODE,   BALUNITNO,        USETYPECODE,       TAKETIME,         UPDATESTAFFNO,
				UPDATETIME,       REMARK
			)
			values (
				p_newPsamNo,       v_oldPosNo,        p_callingNo,        v_corpNo,          v_deptNo,
				p_svcMgrNo,        p_balUnitNo,       v_posSource,        v_currentdate,     p_currOper,
				v_currentdate,     p_note
			);
		exception
			when others then
				p_retCode := 'S006500091';
				p_retMsg  := '';
				rollback; return;
		end;


		-- (3) update PSAM stock info

		-- update old PSAM info
		begin
			update	TL_R_ICOTHER
			set		RESSTATECODE      =      '00',
					CALLINGNO         =      NULL,
					CORPNO            =      NULL,
					DEPARTNO          =      NULL,
					OUTTIME           =      NULL,
					USETIME           =      NULL,
					REINTIME          =      v_currentdate,
					ASSIGNEDSTAFFNO   =      p_currOper,
					ASSIGNEDDEPARTID  =      p_currDept,
					UPDATESTAFFNO     =      p_currOper,
					UPDATETIME        =      v_currentdate
			where	CARDNO            =      p_oldPsamNo;
			if  SQL%ROWCOUNT != 1 then raise v_ex; end if;
		exception
			when others then
				p_retCode := 'S006500092';
				p_retMsg  := '';
				rollback; return;
		end;

		-- update new PSAM info
		begin
			update	TL_R_ICOTHER
			set		RESSTATECODE      =        '01',
					CALLINGNO         =        p_callingNo,
					CORPNO            =        v_corpNo,
					DEPARTNO          =        v_deptNo,
					OUTTIME           =        v_currentdate,
					REINTIME          =        null,
					USETIME           =        v_currentdate,
					ASSIGNEDSTAFFNO   =        p_svcMgrNo,
					ASSIGNEDDEPARTID  =        v_empDeptNo,
					UPDATESTAFFNO     =        p_currOper,
					UPDATETIME        =        v_currentdate
			where	CARDNO            =        p_newPsamNo;
			if  SQL%ROWCOUNT != 1 then raise v_ex; end if;
		exception
			when others then
				p_retCode := 'S006500093';
				p_retMsg  := '';
				rollback; return;
		end;
    
    ----支持联机消费  psam改变
    BEGIN
    
      select count(*) into v_oldLimit from TF_TRADE_LIMIT where SAMNO = p_oldPsamNo  and ACCT_TYPE_NO='0001';
      --删除旧的SAMNO对应的联机消费
      if v_oldLimit>0 then
        BEGIN
            delete from TF_TRADE_LIMIT where SAMNO  =  p_oldPsamNo ;
            if  SQL%ROWCOUNT != 1 then raise v_ex; end if;
          exception
            when others then
              p_retCode := 'S006500096:删除POS消费限制表失败';
              p_retMsg  := '';
              rollback; return;
         END;
      end if;
      
      IF P_isTradeLimit='1' and v_isNewPosChanged='1'  and p_newPsamNo is not null THEN  --支持联机消费
        BEGIN
           INSERT INTO TF_TRADE_LIMIT(
           ACCT_TYPE_NO  , SAMNO     ,ACCT_TYPE_NAME  ,POSNO    ,BALUNITNO   ,USETAG   ,CREATE_DATE
           )
           VALUES(
           '0001'        ,p_newPsamNo   ,'一卡通现金账户',p_newPosNo  ,p_balUnitNo    ,'1'      ,v_currentdate
           );
           exception
              when others then
                p_retCode := 'S006500097:插入POS消费限制表失败';
                p_retMsg  := '';
                rollback; return;
        END;
       END IF;
        IF P_isTradeLimit='1' and v_isNewPosChanged='0'  and p_newPsamNo is not null THEN  
        BEGIN
           INSERT INTO TF_TRADE_LIMIT(
           ACCT_TYPE_NO  , SAMNO     ,ACCT_TYPE_NAME  ,POSNO    ,BALUNITNO   ,USETAG   ,CREATE_DATE
           )
           VALUES(
           '0001'        ,p_newPsamNo   ,'一卡通现金账户',p_oldPosNo  ,p_balUnitNo    ,'1'      ,v_currentdate
           );
           exception
              when others then
                p_retCode := 'S006500098:插入POS消费限制表失败';
                p_retMsg  := '';
                rollback; return;
        END;
       END IF;
     
    END;

  end if;

  -- when POSNO  is changed
  --  update POS,PSAM relation
  --  update POS stock info
  if v_isNewPosChanged = '1' then
    --  update POS,PSAM relation
    begin
      update  TF_R_PSAMPOSREC
      set    POSNO           =        v_newPosNo,
          USETYPECODE     =        v_posSource,
          REMARK          =        p_note,
          UPDATESTAFFNO   =        p_currOper,
          UPDATETIME      =        v_currentdate
      where  SAMNO           =        p_newPsamNo;
      if  SQL%ROWCOUNT != 1 then raise v_ex; end if;
    exception
      when others then
        p_retCode := 'S006500094';
        p_retMsg  := '';
        rollback; return;
    end;

    --  update old POS stock info
    if v_oldPosNo is not null then
      begin
        update  TL_R_EQUA
        set    RESSTATECODE      =      '00',
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
        where  POSNO             =      v_oldPosNo;
        if  SQL%ROWCOUNT != 1 then raise v_ex; end if;
      exception
        when others then
          p_retCode := 'S006500095';
          p_retMsg  := '';
          rollback; return;
      end;
    end if;

    --  update new POS stock info
    if v_newPosNo is not null then
      begin
        update  TL_R_EQUA
        set    RESSTATECODE  =        '01',
            OUTTIME       =        v_currentdate,
            USETIME       =        v_currentdate,
            REINTIME      =        null,
            CALLINGNO     =        p_callingNo,
            CORPNO        =        v_corpNo,
            DEPARTNO      =        v_deptNo,
            ASSIGNEDSTAFFNO =      p_svcMgrNo,
            ASSIGNEDDEPARTID  =    v_empDeptNo,
            UPDATESTAFFNO   =      p_currOper,
            UPDATETIME    =        v_currentdate
        where  POSNO         =        v_newPosNo;
        if  SQL%ROWCOUNT != 1 then raise v_ex; end if;
      exception
        when others then
          p_retCode := 'S006500096';
          p_retMsg  := '';
          rollback; return;
      end;
    end if;
  
  
  end if;
  
  
    if v_isNewPsamChanged='0' AND  v_isNewPosChanged = '1' and p_newPsamNo is not null then
    
      select count(*) into v_newLimit from TF_TRADE_LIMIT where SAMNO = p_oldPsamNo and  ACCT_TYPE_NO='0001';
      if v_newLimit>0 then
       if P_isTradeLimit='1' then
         BEGIN
            update TF_TRADE_LIMIT 
            set POSNO = v_newPosNo,
                BALUNITNO = p_balUnitNo,
                CREATE_DATE = v_currentdate 
            where SAMNO = p_oldPsamNo;
            if  SQL%ROWCOUNT != 1 then raise v_ex; end if;
          exception
            when others then
              p_retCode := 'S006500100:更新POS消费限制表失败';
              p_retMsg  := '';
              rollback; return;
         END;  
       end if;
       if P_isTradeLimit='0' then
          BEGIN
            delete from TF_TRADE_LIMIT where SAMNO  =  p_oldPsamNo ;
            if  SQL%ROWCOUNT != 1 then raise v_ex; end if;
          exception
            when others then
              p_retCode := 'S006500101:删除POS消费限制表失败';
              p_retMsg  := '';
              rollback; return;
         END;
       end if;
       else
       
        if P_isTradeLimit='1' then
           BEGIN
               INSERT INTO TF_TRADE_LIMIT(
               ACCT_TYPE_NO  , SAMNO     ,ACCT_TYPE_NAME  ,POSNO    ,BALUNITNO   ,USETAG   ,CREATE_DATE
               )
               VALUES(
               '0001'        ,p_newPsamNo   ,'一卡通现金账户' ,p_newPosNo  ,p_balUnitNo    ,'1'      ,v_currentdate
               );
               exception
                  when others then
                    p_retCode := 'S006500102:插入POS消费限制表失败';
                    p_retMsg  := '';
                    rollback; return;
          END;
        
        end if;
       
     
    end if;
    
    
    end if; 
    -- change note
    if v_NoteChange = '0' then
    begin
      update  TF_R_PSAMPOSREC
      set    POSNO           =        v_newPosNo,
          USETYPECODE     =        v_posSource,
          REMARK          =        p_note,
          UPDATESTAFFNO   =        p_currOper,
          UPDATETIME      =        v_currentdate
      where  SAMNO           =        p_newPsamNo;
      if  SQL%ROWCOUNT != 1 then raise v_ex; end if;
    exception
      when others then
        p_retCode := 'S006500094';
        p_retMsg  := '';
        rollback; return;
    end;
    if p_newPsamNo is not null then
      select count(*) into v_newLimit2 from TF_TRADE_LIMIT where SAMNO = p_oldPsamNo  and ACCT_TYPE_NO='0001'; 
      if v_newLimit2<1 then
        if P_isTradeLimit='1' then 
           BEGIN
             INSERT INTO TF_TRADE_LIMIT(
             ACCT_TYPE_NO  , SAMNO     ,ACCT_TYPE_NAME  ,POSNO    ,BALUNITNO   ,USETAG   ,CREATE_DATE
             )
             VALUES(
             '0001'        ,p_newPsamNo   ,'一卡通现金账户' ,p_oldPosNo  ,p_balUnitNo    ,'1'      ,v_currentdate
             );
             exception
                when others then
                  p_retCode := 'S006500103:插入POS消费限制表失败';
                  p_retMsg  := '';
                  rollback; return;
           END;

        end if;
       else
        if P_isTradeLimit='0' then 
          BEGIN
            delete from TF_TRADE_LIMIT where SAMNO  =  p_newPsamNo ;
            if  SQL%ROWCOUNT != 1 then raise v_ex; end if;
          exception
            when others then
              p_retCode := 'S006500104:删除POS消费限制表失败';
              p_retMsg  := '';
              rollback; return;
         END;

        end if;
       
      end if;
    end if;
  end if;
  
  
  -- log
  SP_GetSeq(seq => v_seqNo);

  begin
    insert into TF_R_STOCKRESOURCESTRADE (
      TRADEID,          OPETYPECODE,     POSNO,           SAMNO,
      OLDPOSNO,         OLDSAMNO,        CALLINGNO,       CORPNO,
      DEPARTNO,         BALUNITNO,       ASSIGNEDSTAFFNO, ASSIGNEDDEPARTID,
      OPERATESTAFFNO,   OPERATEDEPARTID,  OPERATETIME
    )
    values(
      v_seqNo,        'K8',            v_newPosNo,       p_newPsamNo,
      v_oldPosNo,        p_oldPsamNo,      p_callingNo,      v_corpNo,
      v_deptNo,          p_balUnitNo,      p_svcMgrNo,       v_empDeptNo,
      p_currOper,       p_currDept,        v_currentdate
    );
  exception
    when no_data_found then
      p_retCode   := 'S006500097';
      p_retMsg  := '';
      rollback; return;
  end;

  if p_psamtype = '1' then --非油品

      SP_GetSeq(seq => v_seqNo);

      begin
        insert into TF_R_STOCKRESOURCESTRADE (
      TRADEID,          OPETYPECODE,     POSNO,           SAMNO,
      OLDPOSNO,         OLDSAMNO,        CALLINGNO,       CORPNO,
      DEPARTNO,         BALUNITNO,       ASSIGNEDSTAFFNO, ASSIGNEDDEPARTID,
      OPERATESTAFFNO,   OPERATEDEPARTID,  OPERATETIME
    )
    values(
      v_seqNo,        'K8',            v_newPosNo,       p_newPsamNo,
      v_oldPosNo,        p_oldPsamNo,      p_callingNo,      v_corpNo,
      v_deptNo,          p_UnitNo,      p_svcMgrNo,       v_empDeptNo,
      p_currOper,       p_currDept,        v_currentdate
    );
      exception
        when others then
          p_retCode := 'S006500062';
          p_retMsg  := '';
          rollback; return;
      end;
  end if;

  p_retCode := '0000000000';
  p_retMsg  := '';

  commit; return;

end;
/
show errors
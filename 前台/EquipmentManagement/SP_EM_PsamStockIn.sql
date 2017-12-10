create or replace procedure SP_EM_PsamStockIn
(
  p_prefix           char,
	p_firstNo          int,
	p_amount           int,
	p_length           int,   -- v_prefix+v_cardNo, the total length
	p_cardKind		     char,
	p_cosType			     char,
	p_appVersion		   char,
	p_cardType		     char,
	p_cardPrice		     int,
	p_cardManu		     char,
	p_validBeginDate	 char,
	p_validEndDate	   char,
	p_currOper		     char,
	p_currDept		     char,
	p_retCode			 out char,
	p_retMsg			 out varchar2
)
as
	v_currentdate   date   := sysdate;
	v_cardNo		    TL_R_ICOTHER.CARDNO%TYPE;     -- PSAMNO
	v_seqNo		      TF_R_STOCKRESOURCESTRADE.TRADEID%TYPE;
	v_pre_len    int := length(p_prefix);
  v_tmp           int;
  v_ex			      exception;
	v_beginNo	 TF_R_STOCKRESOURCESTRADE.BEGINCARDNO%TYPE;
	v_endNo	     TF_R_STOCKRESOURCESTRADE.ENDCARDNO%TYPE;
begin

	-- check psamnos, if there is one which already v_exists in stock , report  error and v_exit
	begin
		select 1 into v_tmp from dual
    where exists (select 1
			from TL_R_ICOTHER t
			where p_prefix=substr(t.CARDNO,1,v_pre_len)
			and to_number(substr(t.CARDNo, v_pre_len+1, p_length+1)) between p_firstNo and p_firstNo+p_amount-1 );
		p_retCode   := 'A006001035';
		p_retMsg    := '';
		return;
	exception
		when no_data_found then null;
	end;

	-- insert each psam record into stock in loop
	v_tmp  :=  0;
	begin
		while v_tmp < p_amount loop
			v_cardNo := concat(p_prefix, lpad(p_firstNo+v_tmp,p_length-v_pre_len,'0'));
			insert into TL_R_ICOTHER(
	  			CARDNo,			   	   CARDKINDCODE,  	COSTYPECODE,   	SAMVERSION,
	  			CARDTYPECODE,      	CARDPRICE,       MANUTYPECODE,   VALIDBEGINDATE,
	  			VALIDENDDATE,      	RESSTATECODE,    INSTIME,        ASSIGNEDSTAFFNO,
	  			UPDATESTAFFNO,    	ASSIGNEDDEPARTID, UPDATETIME
	  		)
	  		values(
	  			v_cardNo,				p_cardKind,		p_cosType,		p_appVersion,
	  			p_cardType,			p_cardPrice,		p_cardManu,		p_validBeginDate,
	  			p_validEndDate,		'00',			v_currentdate,	p_currOper,
	  			p_currOper,			p_currDept,      v_currentdate
	  		);
			v_tmp := v_tmp + 1;
		end loop;
	exception
    	when others then
    		p_retCode := 'S006001036';
    		p_retMsg	:= '';
    		rollback; return;
	end;

	-- log
	SP_GetSeq(seq => v_seqNo);
	v_beginNo := concat(p_prefix, lpad(p_firstNo,p_length-v_pre_len,'0'));
	v_endNo := concat(p_prefix, lpad(p_firstNo+p_amount-1,p_length-v_pre_len,'0'));

	begin
		insert into TF_R_STOCKRESOURCESTRADE(
			TRADEID,		  OPETYPECODE,          BEGINCARDNO,          ENDCARDNO,
			CARDNUM,          VALIDBEGINDATE,       VALIDENDDATE,         EQUPRICE,
			ASSIGNEDSTAFFNO,  ASSIGNEDDEPARTID,     OPERATESTAFFNO,        OPERATEDEPARTID,
			OPERATETIME
		)
		values(
			v_seqNo,		  	'K0',				v_beginNo,		      v_endNo,
			p_amount,		p_validBeginDate,		p_validEndDate,		  p_cardPrice,
			p_currOper,     p_currDept,             p_currOper,	          p_currDept,
			v_currentdate
		);
	exception
		when others then
			p_retCode := 'S006001037';
			p_retMsg	:= '';
			rollback; return;
	end;

	p_retCode := '0000000000';
	p_retMsg	:= '';

	commit; return;

end;
/





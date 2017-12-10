create or replace procedure SP_EM_PosStockIn
(
	p_posNo			char,
	p_posSort		char,
	p_posModel		char,
	p_touchType		char,
	p_layType		char,
	p_commType		char,
	p_posPrice		int,
	p_posManu		char,
	p_posSource		char,
	p_hardwareNum	char,	--POSHARDWARENUM
	p_currOper		char,
	p_currDept		char,
	p_retCode		out char,
	p_retMsg		out	varchar2
)
as
  v_currentdate   date            := sysdate;
  v_seqNo		  TF_R_STOCKRESOURCESTRADE.TRADEID%TYPE;
  v_tmp           int;
begin
	--  if the posno exists in stock, exit
	begin
		select 1 into v_tmp from TL_R_EQUA where POSNO = p_posNo;
		p_retCode   := 'A006001040';
		p_retMsg    := '';
		return;
	exception
		when no_data_found then null;
	end;

	-- add pos record into stock
	begin
		insert into TL_R_EQUA(
			POSNO,            EQUSORT,          POSMODECODE,      TOUCHTYPECODE,
			LAYTYPECODE,      COMMTYPECODE,     EQUPRICE,         POSMANUCODE,
			POSHARDWARENUM,   RESSTATECODE,     UPDATESTAFFNO,    ASSIGNEDDEPARTID,
			UPDATETIME,	      INSTIME,          ASSIGNEDSTAFFNO,  EQUSOURCE
		)
		values(
			p_posNo,		  p_posSort,		p_posModel,	  p_touchType,
			p_layType,		  p_commType,		p_posPrice,	  p_posManu,
			p_hardwareNum,	  '00',				p_currOper,   p_currDept,
			v_currentdate,    v_currentdate,	p_currOper,       p_posSource
		);
	exception
		when others then
			p_retCode := 'S006001041';
			p_retMsg  := '';
			rollback; return;
	end;

	-- log
	SP_GetSeq(seq => v_seqNo);

	begin
		insert into TF_R_STOCKRESOURCESTRADE(
			TRADEID,          OPETYPECODE,      POSNO,            EQUPRICE,
			ASSIGNEDSTAFFNO,  ASSIGNEDDEPARTID, OPERATESTAFFNO,   OPERATEDEPARTID,
			OPERATETIME
		)
		values(
			v_seqNo,		  'K0',				p_posNo,		  p_posPrice,
			p_currOper,		  p_currDept,		p_currOper,		  p_currDept,
			v_currentdate
		);
	exception
		when others then
			p_retCode := 'S006001042';
			p_retMsg  := '';
			rollback; return;
	end;

    p_retCode := '0000000000';
	p_retMsg	:= '';

	commit; return;

end;
/




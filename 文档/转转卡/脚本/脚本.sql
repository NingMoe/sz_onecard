insert into td_m_menu (MENUNO, MENUNAME, PMENUNO, URL, TARGET, TIPS, CLICKFUC, DEFAULFLAG, MENULEVEL, UPDATESTAFFNO, UPDATETIME, REMARK, ISNEW)
values ('230600', 'תת�������������', '230500', 'ASP/GroupCard/GC_ZZOrderApproval.aspx', 'content', null, null, null, null, null, null, null, null);

insert into td_m_menu (MENUNO, MENUNAME, PMENUNO, URL, TARGET, TIPS, CLICKFUC, DEFAULFLAG, MENULEVEL, UPDATESTAFFNO, UPDATETIME, REMARK, ISNEW)
values ('230605', 'תת�������ƿ�', '230500', 'ASP/GroupCard/GC_ZZOrderProduce.aspx', 'content', null, null, null, null, null, null, null, null);

insert into td_m_menu (MENUNO, MENUNAME, PMENUNO, URL, TARGET, TIPS, CLICKFUC, DEFAULFLAG, MENULEVEL, UPDATESTAFFNO, UPDATETIME, REMARK, ISNEW)
values ('230610', 'תת����������', '230500', 'ASP/GroupCard/GC_ZZOrderDistrabution.aspx', 'content', null, null, null, null, null, null, null, null);

insert into td_m_menu (MENUNO, MENUNAME, PMENUNO, URL, TARGET, TIPS, CLICKFUC, DEFAULFLAG, MENULEVEL, UPDATESTAFFNO, UPDATETIME, REMARK, ISNEW)
values ('230615', 'תת���쿨�ۿ�', '230500', 'ASP/GroupCard/GC_ZZReceiveCard.aspx', 'content', null, null, null, null, null, null, null, null);

insert into td_m_menu (MENUNO, MENUNAME, PMENUNO, URL, TARGET, TIPS, CLICKFUC, DEFAULFLAG, MENULEVEL, UPDATESTAFFNO, UPDATETIME, REMARK, ISNEW)
values ('871320', 'תת��������¼����', '870000', 'ASP/Financial/FI_ZZTradeReport.aspx', 'content', null, null, null, null, null, null, null, null);

insert into td_m_menu (MENUNO, MENUNAME, PMENUNO, URL, TARGET, TIPS, CLICKFUC, DEFAULFLAG, MENULEVEL, UPDATESTAFFNO, UPDATETIME, REMARK, ISNEW)
values ('871325', 'תת���쿨ͳ�Ʊ���', '870000', 'ASP/Financial/FI_ZZReceiveCardReport.aspx', 'content', null, null, null, null, null, null, null, null);

insert into td_m_menu (MENUNO, MENUNAME, PMENUNO, URL, TARGET, TIPS, CLICKFUC, DEFAULFLAG, MENULEVEL, UPDATESTAFFNO, UPDATETIME, REMARK, ISNEW)
values ('871330', 'תת����������ͳ��', '870000', 'ASP/Financial/FI_ZZPayCanalDataReport.aspx', 'content', null, null, null, null, null, null, null, null);

insert into td_m_menu (MENUNO, MENUNAME, PMENUNO, URL, TARGET, TIPS, CLICKFUC, DEFAULFLAG, MENULEVEL, UPDATESTAFFNO, UPDATETIME, REMARK, ISNEW)
values ('871335', 'תת������ˢ��ͳ��', '870000', 'ASP/Financial/FI_ZZParkConsumerReport.aspx', 'content', null, null, null, null, null, null, null, null);

insert into td_m_menu (MENUNO, MENUNAME, PMENUNO, URL, TARGET, TIPS, CLICKFUC, DEFAULFLAG, MENULEVEL, UPDATESTAFFNO, UPDATETIME, REMARK, ISNEW)
values ('871340', 'תת��ˢ����¼����', '870000', 'ASP/Financial/FI_ZZCardConsumerReport.aspx', 'content', null, null, null, null, null, null, null, null);


grant execute on SP_GC_ZZSALECARD to Uopapp_B_SZ;
grant execute on SP_GC_ZZUpdateSync to Uopapp_B_SZ;

create or replace synonym SP_GC_ZZSALECARD FOR ucrapp_b_sz.SP_GC_ZZSALECARD;
create or replace synonym SP_GC_ZZUpdateSync FOR ucrapp_b_sz.SP_GC_ZZUpdateSync;
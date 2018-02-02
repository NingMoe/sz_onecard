insert into td_m_menu (MENUNO, MENUNAME, PMENUNO, URL, TARGET, TIPS, CLICKFUC, DEFAULFLAG, MENULEVEL, UPDATESTAFFNO, UPDATETIME, REMARK, ISNEW)
values ('230600', '转转卡订单资料审核', '230500', 'ASP/GroupCard/GC_ZZOrderApproval.aspx', 'content', null, null, null, null, null, null, null, null);

insert into td_m_menu (MENUNO, MENUNAME, PMENUNO, URL, TARGET, TIPS, CLICKFUC, DEFAULFLAG, MENULEVEL, UPDATESTAFFNO, UPDATETIME, REMARK, ISNEW)
values ('230605', '转转卡订单制卡', '230500', 'ASP/GroupCard/GC_ZZOrderProduce.aspx', 'content', null, null, null, null, null, null, null, null);

insert into td_m_menu (MENUNO, MENUNAME, PMENUNO, URL, TARGET, TIPS, CLICKFUC, DEFAULFLAG, MENULEVEL, UPDATESTAFFNO, UPDATETIME, REMARK, ISNEW)
values ('230610', '转转卡订单配送', '230500', 'ASP/GroupCard/GC_ZZOrderDistrabution.aspx', 'content', null, null, null, null, null, null, null, null);

insert into td_m_menu (MENUNO, MENUNAME, PMENUNO, URL, TARGET, TIPS, CLICKFUC, DEFAULFLAG, MENULEVEL, UPDATESTAFFNO, UPDATETIME, REMARK, ISNEW)
values ('230615', '转转卡领卡售卡', '230500', 'ASP/GroupCard/GC_ZZReceiveCard.aspx', 'content', null, null, null, null, null, null, null, null);

insert into td_m_menu (MENUNO, MENUNAME, PMENUNO, URL, TARGET, TIPS, CLICKFUC, DEFAULFLAG, MENULEVEL, UPDATESTAFFNO, UPDATETIME, REMARK, ISNEW)
values ('871320', '转转卡操作记录报表', '870000', 'ASP/Financial/FI_ZZTradeReport.aspx', 'content', null, null, null, null, null, null, null, null);

insert into td_m_menu (MENUNO, MENUNAME, PMENUNO, URL, TARGET, TIPS, CLICKFUC, DEFAULFLAG, MENULEVEL, UPDATESTAFFNO, UPDATETIME, REMARK, ISNEW)
values ('871325', '转转卡领卡统计报表', '870000', 'ASP/Financial/FI_ZZReceiveCardReport.aspx', 'content', null, null, null, null, null, null, null, null);

insert into td_m_menu (MENUNO, MENUNAME, PMENUNO, URL, TARGET, TIPS, CLICKFUC, DEFAULFLAG, MENULEVEL, UPDATESTAFFNO, UPDATETIME, REMARK, ISNEW)
values ('871330', '转转卡销售渠道统计', '870000', 'ASP/Financial/FI_ZZPayCanalDataReport.aspx', 'content', null, null, null, null, null, null, null, null);

insert into td_m_menu (MENUNO, MENUNAME, PMENUNO, URL, TARGET, TIPS, CLICKFUC, DEFAULFLAG, MENULEVEL, UPDATESTAFFNO, UPDATETIME, REMARK, ISNEW)
values ('871335', '转转卡景点刷卡统计', '870000', 'ASP/Financial/FI_ZZParkConsumerReport.aspx', 'content', null, null, null, null, null, null, null, null);

insert into td_m_menu (MENUNO, MENUNAME, PMENUNO, URL, TARGET, TIPS, CLICKFUC, DEFAULFLAG, MENULEVEL, UPDATESTAFFNO, UPDATETIME, REMARK, ISNEW)
values ('871340', '转转卡刷卡记录报表', '870000', 'ASP/Financial/FI_ZZCardConsumerReport.aspx', 'content', null, null, null, null, null, null, null, null);

insert into td_m_menu (MENUNO, MENUNAME, PMENUNO, URL, TARGET, TIPS, CLICKFUC, DEFAULFLAG, MENULEVEL, UPDATESTAFFNO, UPDATETIME, REMARK, ISNEW)
values ('871375', '转转卡激活统计报表', '870000', 'ASP/Financial/FI_ZZPackageActivateReport.aspx', 'content', null, null, null, null, null, null, null, null);

insert into td_m_menu (MENUNO, MENUNAME, PMENUNO, URL, TARGET, TIPS, CLICKFUC, DEFAULFLAG, MENULEVEL, UPDATESTAFFNO, UPDATETIME, REMARK, ISNEW)
values ('871380', '转转卡景点刷卡报表', '870000', 'ASP/Financial/FI_ZZParkActivateReport.aspx', 'content', null, null, null, null, null, null, null, null);

insert into td_m_menu (MENUNO, MENUNAME, PMENUNO, URL, TARGET, TIPS, CLICKFUC, DEFAULFLAG, MENULEVEL, UPDATESTAFFNO, UPDATETIME, REMARK, ISNEW)
values ('871385', '转转卡转账报表', '870000', 'ASP/Financial/FI_ZZTransferReport.aspx', 'content', null, null, null, null, null, null, null, null);


grant execute on SP_GC_ZZSALECARD to Uopapp_B_SZ;
grant execute on SP_GC_ZZUpdateSync to Uopapp_B_SZ;
grant execute on SP_CC_ActivatezzOrder to Uopapp_B_SZ;
grant execute on SP_CC_ActivatezzOrder to Uopapp_B_SZ;
grant execute on SP_AS_XFCommit_ZZ to Uopapp_B_SZ,uopsett_b_sz;


create or replace synonym SP_GC_ZZSALECARD FOR ucrapp_b_sz.SP_GC_ZZSALECARD;
create or replace synonym SP_GC_ZZUpdateSync FOR ucrapp_b_sz.SP_GC_ZZUpdateSync;
create or replace synonym SP_CC_ActivatezzOrder FOR ucrapp_b_sz.SP_CC_ActivatezzOrder;
create or replace synonym SP_CC_ActivatezzOrder FOR ucrapp_b_sz.SP_CC_ActivatezzOrder;
create or replace synonym SP_AS_XFCommit_ZZ FOR ucrapp_b_sz.SP_AS_XFCommit_ZZ;
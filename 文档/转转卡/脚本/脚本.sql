insert into td_m_menu (MENUNO, MENUNAME, PMENUNO, URL, TARGET, TIPS, CLICKFUC, DEFAULFLAG, MENULEVEL, UPDATESTAFFNO, UPDATETIME, REMARK, ISNEW)
values ('230600', '转转卡订单资料审核', '230500', 'ASP/GroupCard/GC_ZZOrderApproval.aspx', 'content', null, null, null, null, null, null, null, null);

insert into td_m_menu (MENUNO, MENUNAME, PMENUNO, URL, TARGET, TIPS, CLICKFUC, DEFAULFLAG, MENULEVEL, UPDATESTAFFNO, UPDATETIME, REMARK, ISNEW)
values ('230605', '转转卡订单制卡', '230500', 'ASP/GroupCard/GC_ZZOrderProduce.aspx', 'content', null, null, null, null, null, null, null, null);

insert into td_m_menu (MENUNO, MENUNAME, PMENUNO, URL, TARGET, TIPS, CLICKFUC, DEFAULFLAG, MENULEVEL, UPDATESTAFFNO, UPDATETIME, REMARK, ISNEW)
values ('230610', '转转卡订单配送', '230500', 'ASP/GroupCard/GC_ZZOrderDistrabution.aspx', 'content', null, null, null, null, null, null, null, null);

insert into td_m_menu (MENUNO, MENUNAME, PMENUNO, URL, TARGET, TIPS, CLICKFUC, DEFAULFLAG, MENULEVEL, UPDATESTAFFNO, UPDATETIME, REMARK, ISNEW)
values ('230615', '转转卡领卡售卡', '230500', 'ASP/GroupCard/GC_ZZReceiveCard.aspx', 'content', null, null, null, null, null, null, null, null);


grant execute on SP_GC_ZZSALECARD to Uopapp_B_SZ;
grant execute on SP_GC_ZZUpdateSync to Uopapp_B_SZ;

create or replace synonym SP_GC_ZZSALECARD FOR ucrapp_b_sz.SP_GC_ZZSALECARD;
create or replace synonym SP_GC_ZZUpdateSync FOR ucrapp_b_sz.SP_GC_ZZUpdateSync;
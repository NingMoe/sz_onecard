/*1、 休闲年卡订单表 */
select * from order_yearcard where order_no = '151170816005082150V';

/*2、 休闲年卡订单详情表 */
select * from order_yearcard_detail where order_id = (select id from order_yearcard where order_no = '151170816005082150V');

/*3、 休闲年卡小额失败表 */
select * from order_mp_log where order_no = '151170816005082150V';

/*4、订单日志表 */
select * from order_yearcard_log where order_no = '151170816005082150V' ORDER BY created;


select * from user_card_no where id = '481158';

select * from user_card_no where user_id = '430483';

select * from user_info where id = '119071';

select * from user_card_no where card_no = '2150089624209999';

/*休闲套餐相关信息*/
select * from yc_scenery_group where code = 'E1' or code = 'E2' or code = 'E3' or code = 'E4';

/* POS上显示套餐的表*/

/*在yearcard_pos数据库中的 yearcardgroupconfig表中*/
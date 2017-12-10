/*1、 休闲年卡订单表 */
select * from order_yearcard where order_no = '151170815001402150V';

/*2、 休闲年卡订单详情表 */
select * from order_yearcard_detail where order_id = (select id from order_yearcard where order_no = '151170815001402150V');

/*3、 休闲年卡小额失败表 */
select * from order_mp_log where order_no = '151170815001402150V';

/*4、订单日志表 */
select * from order_yearcard_log where order_no = '151170815001402150V' ORDER BY created;


select * from user_card_no where id = '451238';

select * from user_card_no where user_id = '405388';

select * from user_info where id = '383070';
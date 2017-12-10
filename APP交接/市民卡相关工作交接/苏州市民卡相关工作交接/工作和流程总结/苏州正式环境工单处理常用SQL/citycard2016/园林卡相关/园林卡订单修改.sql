/*1、园林卡订单信息 */
select * from order_garden_card   where order_no = '311170629016602150G';

/*2、园林卡订单用到的卡号 */
select * from user_card_no where user_id = (select user_id from order_garden_card where order_no = '311170629016602150G');

/*3、园林卡订单详情 */
select * from order_garden_card_detail where order_id = (select id from order_garden_card where order_no = '311170629016602150G');

/*4、园林卡订单小额失败表 */
select * from order_garden_card_mp_log where order_no = '311170629016602150G';

/*5、园林卡订单交易详情 */
select * from trans_common where order_no = '311170629016602150G';

/*6、园林卡订单用户信息 */
select * from user_info where id = (select user_id from order_garden_card where order_no = '311170629016602150G');

/* 查看园林卡中错误订单（卡号包含空格的） */
select * from order_garden_card_detail where card_no like '% %';
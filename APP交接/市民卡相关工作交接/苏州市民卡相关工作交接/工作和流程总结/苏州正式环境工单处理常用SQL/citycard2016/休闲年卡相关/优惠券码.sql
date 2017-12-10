
/*1、 优惠券码使用情况 */
/* UNUSED(0, "未使用"), OCCUPPIED(1, "已占用"),USED(2, "已使用")*/

select * from yearcard_sale_code_used t2 where t2.sale_code = '1833164818630085';

/* 删除占用的优惠券码（注意先备份） */
/* 优惠券码备份数据:*/
/* 24417	219275	1	1833164818630085	2017-08-15 17:43:42.291	379	2017-09-30 00:00:00	 */
/* delete from  yearcard_sale_code_used where    sale_code = '1833164818630085';  */

/*2、根据优惠券码查询年卡订单*/
select * from order_yearcard_detail where id = (select  order_yearcard_detail_id from yearcard_sale_code_used where sale_code = '1833164818630085');

/*3、 休闲年卡订单表 */
select * from order_yearcard where order_no = '151170817008312150V';

/*4、 休闲年卡订单详情表 */
select * from order_yearcard_detail where order_id = 219629;

/*5、订单日志表 */
select * from order_yearcard_log where order_no = '151170817008312150V' ORDER BY created;

select * from user_info where id = '429464';

select * from yearcard_sale_code_used where order_yearcard_detail_id = 220436;

select * from order_yearcard where user_id = '429464';
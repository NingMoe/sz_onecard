
/* 1 预充值订单情表 */
/* select * from order_prepay where create_time BETWEEN '2017-06-17' and '2017-06-18' ;  */
/*
select * from order_prepay where card_no = '2150080326572863';
*/

select * from order_prepay where order_no = '251170305003262150S';

/* 2 预充值订单退款详情表 */
select * from refund_detail where order_no = '251170305003262150S';


/* 3 预充值订单 小额文件详情表 */
select * from order_prepay_mp_file_detail where order_no = '251170305003262150S';

/* 4 预充值订单提交给小额失败表 */
select * from order_prepay_to_mp_fail where order_no = '251170305003262150S';


/* 5 云闪充订单交易日志*/
SELECT * from order_prepay_log where order_no = '251170305003262150S';

/*手动退款几个参数查询 
deleted	0
enabled 1
orderStatus	1 已支付
mpOrderStatus 	0或 空未写卡
issucTomp	1		已成功提交到小额
isRefundMp	1		小额退款文件通知
*/
/* 6 */
select order_no,deleted,enabled,order_status,mp_order_status,issuc_tomp,is_refund_mp from  order_prepay where order_no = '251170305003262150S'

/* 1、手表订单信息 */
select * from order_card_topup where order_no = '231170723004312150Z';


/* 2、手表订单在线在线账户交易详情*/
select * from trans_detail_online_account where order_id  = (select id from order_card_topup where order_no = '231170723004312150Z');

/* 3、手表交易信息 */
select * from order_card_topup_transaction where order_no  = '231170723004312150Z';

/* 4、transaction表中的每次阿里交易详情*/
select * from  trans_detail_alipay where order_no = '231170723004312150Z';

/* 5、 */
select * from trans_common where id = (select trans_com_id from order_card_topup where order_no  = '231170723004312150Z');


select * from user_info where id = '382449' or id = '122954';


/*
select * from order_card_topup_transaction where created_by = '请求小额MAC2' and topup_status = 4 and created > '2017-06-26';


select * from order_card_topup_transaction where order_card_topup_id = 48256;

*/
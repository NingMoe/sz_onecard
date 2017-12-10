SELECT
	t2.*,t1.*
FROM
	order_yearcard t1,
	order_yearcard_detail t2
WHERE
	t1.order_no in ( '151170809006082150V')
AND t1. ID = t2.order_id;


select * from order_yearcard where order_no  = '151170809006082150V';
select * from order_yearcard_detail where order_id = 217986;

/*
update order_yearcard_detail set card_name = '黄贵琴',id_no='321283199107251028' where order_id = 189241;
*/
/*
update order_yearcard set ogistics_user = '黄贵琴' where order_no = '151170629016572150V';
*/

/*
update order_yearcard_detail set id_no = '320621196910265929' where order_id = 217986;

*/
SELECT * from user_card_no where user_id = 405388;

/*
update user_card_no set card_no = '2150080225444719',wallet_account= '2150080225444719' where id = 436793;

*/

select * from user_info where user_name = '17315858176'
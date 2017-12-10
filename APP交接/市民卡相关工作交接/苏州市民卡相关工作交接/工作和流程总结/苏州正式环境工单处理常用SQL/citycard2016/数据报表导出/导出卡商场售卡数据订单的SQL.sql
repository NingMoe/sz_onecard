SELECT t2.user_name AS "用户账号", t2.true_name AS "用户姓名", t1.contact_tel AS "联系电话", t1.ogistics_address AS "地址", t1.subject AS "产品名称"
	, t1.quantity AS "购买数量", t1.order_no AS "订单号", CASE WHEN t1.order_status = 1 THEN '待支付' WHEN t1.order_status = 2 THEN '已支付' WHEN t1.order_status = 3 THEN '已发货' WHEN t1.order_status = 4 THEN '已完成' WHEN t1.order_status = 5 THEN '关闭' ELSE '' END AS "订单状态", t1.tracking_no AS "物流单号", t1.create_time AS "创建时间"
	, t1.total_price AS "总价"
FROM order_card_buy t1
	LEFT JOIN user_info t2 ON t1.user_id = t2.id
WHERE deleted = 0
	AND enabled = 1
  AND t1.create_time between '2017-01-01' and '2017-06-30'
ORDER BY create_time ASC;
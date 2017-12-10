select order_no,deleted,enabled,order_status,mp_order_status,issuc_tomp,is_refund_mp from order_prepay where order_no in( '251170623004222150S');
update order_prepay set issuc_tomp = 1 , mp_order_status = '1' where order_no = '251170623004222150S';
select order_no,deleted,enabled,order_status,mp_order_status,issuc_tomp,is_refund_mp from order_prepay where order_no in( '251170623004222150S');

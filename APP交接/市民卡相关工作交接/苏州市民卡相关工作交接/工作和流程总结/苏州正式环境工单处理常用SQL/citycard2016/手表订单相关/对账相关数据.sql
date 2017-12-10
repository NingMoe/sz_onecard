/*1、对账基本信息*/
select * from order_bill_base where bill_date between '2017-06-27' and '2017-06-29';

/*2、对账详情*/
select * from order_bill_detail where order_no = '231170627000442150Z';

/*3、对账日志*/
select * from bill_compare_log where order_no = '231170627000442150Z';

/* 1、查询某段时间之间创建的商店  */
select * from shop  where created_date between '2017-07-16' and '2017-07-20';

/* 1、查询地址信息  */
select * from area_info;

select * from shop_region;

/*3、市民卡客服网点一览表 service_office */
select * from service_office limit 10;
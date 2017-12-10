/* 客服网点来源地址 http://www.szsmk.com/Service/Index.aspx?CategoryID=5e63c412-31de-42ce-a94f-04f83783281e */

/* 1、 查询一段时间内创建的网点*/
select * from service_office where created_date between '2017-07-18 00:00:00' and '2017-07-19 23:00:00';

/* 2、 查询一段时间内更新的网点*/
select * from service_office where updated_date between '2017-07-18 00:00:00' and '2017-07-19 23:00:00';

/* 3、按照号码查询网点 */
select * from service_office where telephone = '67729823';

select * from service_office_fav;

/* 5、网点同步文件 */
select * from service_office_files;
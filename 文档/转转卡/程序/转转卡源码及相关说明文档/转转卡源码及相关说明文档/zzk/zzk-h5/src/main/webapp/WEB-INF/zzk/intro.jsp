<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="../publics/jstl.jsp" %>
<!doctype html>
<html>
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, minimum-scale=1, user-scalable=no, minimal-ui">
    <meta content="yes" name="apple-mobile-web-app-capable">
    <meta content="black" name="apple-mobile-web-app-status-bar-style">
    <meta content="telephone=no" name="format-detection">
    <meta content="email=no" name="format-detection">
    <title>订单确认</title>
    <link rel="stylesheet" href="${ctx}/zzk/resource/zzk/dest/base.css">
    <script src="${ctx}/zzk/resource/zzk/js/flexible.js"></script>
</head>
<body>
  <section class="intro">
         <p>普通正文也</p>
  </section>
  <section class="global-nav">
    <ul class="flex">
      <li class="flex-1 active"><a href="${ctx}/zzk/index"><span class="icn-palance"></span><strong>首页</strong></a></li>
      <li class="flex-1"><a href="${ctx}/zzk/my-orders"><span class="icn-board"></span><strong>我的订单</strong></a></li>
      
      <li class="flex-1"><a href="${ctx}/zzk/cart"><span class="icn-cart"></span><strong>我的购物车</strong></a></li>
      <!--购物车里面有商品-->
      <%--<li class="flex-1"><a href="${ctx}/zzk/cart"><span class="icn-carts"></span><strong>我的购物车</strong></a></li>--%>
    </ul>
  </section>
  <script src="${ctx}/zzk/resource/zzk/js/jquery.min.js"> </script>
  <script src="${ctx}/zzk/resource/zzk/js/fastclick.js"> </script>
  <script src="${ctx}/zzk/resource/zzk/js/base.js"></script>
  <script>
    jQuery(function(){
        //查询购物车商品数量
        $.ajax({
            url: '${ctx}/zzk/getCartCount',
            dataType: 'json',
            type: 'post',
            traditional :true,
            data: {}
        }).done(function(data){
            if(data.ret == 0 && data.data > 0){
                $('.icn-cart').attr('class', 'icn-carts');
            }
        }).always(function(){
        });
    });
  </script>
</body>
</html>
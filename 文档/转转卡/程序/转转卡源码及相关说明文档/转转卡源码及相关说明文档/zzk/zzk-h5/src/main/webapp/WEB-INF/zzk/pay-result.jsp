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
    <c:choose>
      <c:when test="${ret == 0}">
        <div class="pay-sc text-center">
          <div class="pay-sc-main">
            <div class="pay-sc-cloud"></div>
            <p>恭喜您成功办理转转卡套餐</p>
            <div><a href="${ctx}/zzk/packages">继续办理</a></div>
          </div>
          <div class="pay-sc-fence"></div>
            <%--<div class="pay-sc-ext">--%>
            <%--<p>小主，请邀请你的小伙伴一起办理吧</p>--%>
            <%--<div><a class="btn round" href="./packages.html">去邀请</a></div>--%>
            <%--</div>--%>
          <div class="pay-sc-ext">
            <a class="btn btn-block round" href="${ctx}/zzk/index">&nbsp; &nbsp;返 回</a>
          </div>
        </div>
      </c:when>
      <c:otherwise>
        <div class="pay-sc text-center">
          <div class="pay-sc-main">
            <div class="pay-sc-break"></div>
            <p>办理失败，请确认订单是否支付成功</p>
          </div>
          <div class="pay-sc-fence"></div>
          <div class="pay-sc-ext">
            <a class="btn btn-block round" href="${ctx}/zzk/my-orders">&nbsp; &nbsp;返 回</a>
          </div>
        </div>
      </c:otherwise>
    </c:choose>

  <section class="global-nav">
    <ul class="flex">
      <li class="flex-1"><a href="${ctx}/zzk/index"><span class="icn-palance"></span><strong>首页</strong></a></li>
      <li class="flex-1"><a href="${ctx}/zzk/my-orders"><span class="icn-board"></span><strong>我的订单</strong></a></li>
      <li class="flex-1"><a href="${ctx}/zzk/cart"><span class="icn-cart"></span><strong>我的购物车</strong></a></li>
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
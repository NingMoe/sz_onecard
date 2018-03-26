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
    <title>可选套餐</title>
    <link rel="stylesheet" href="${ctx}/zzk/resource/zzk/dest/base.css">
    <script src="${ctx}/zzk/resource/zzk/js/flexible.js"></script>
</head>
<body>
  <section class="package">
    <a class="ka-item ka-item-a" href="${ctx}/zzk/function-selection?sp=Z1">
      <div class="ka-item-cover"><img src="${ctx}/zzk/resource/zzk/temp/zxk24.png" width="100%"></div>
      <div class="ka-item-main package-item">
        <div class="package-item-label"><i>A</i><span>套餐</span></div>
        <div class="package-item-main">
            <div class="package-item-hd">
              <span class="package-item-title">苏州转转卡优享卡套餐</span>
              <%--<span class="package-item-stats pull-right">正在办理中...</span>--%>
            </div>
            <div class="package-item-info">
                <p class="text-nowrap">24小时免费&nbsp; &nbsp; 环游全城苏州园林、古镇、及其他休闲、</p>
                <p class="text-nowrap">文化类人气旅游景点19处，欣赏评弹表演</p>
                <p class="text-nowrap"></p>
            </div>
        </div>
        <div class="ka-item-line"></div>
        <div class="ka-item-mask"></div>
      </div>
    </a>
    <a class="ka-item ka-item-b" href="${ctx}/zzk/function-selection?sp=Z2">
      <div class="ka-item-cover"><img src="${ctx}/zzk/resource/zzk/temp/zxk48.png" width="100%"></div>
      <div class="ka-item-main package-item">
        <div class="package-item-label"><i>B</i><span>套餐</span></div>
        <div class="package-item-main">
            <div class="package-item-hd">
              <span class="package-item-title">苏州转转卡尊享卡套餐</span>
              <%--<span class="package-item-stats pull-right">正在办理中...</span>--%>
            </div>
            <div class="package-item-info">
                <p class="text-nowrap">48小时免费&nbsp; &nbsp; 环游全城苏州园林、古镇、及其他休闲、</p>
                <p class="text-nowrap">文化类人气旅游景点20处，欣赏评弹表演，领取价值</p>
                <p class="text-nowrap">35元老字号伴手礼</p>
            </div>
        </div>
        <div class="ka-item-line"></div>
        <div class="ka-item-mask"></div>
      </div>
    </a>  
  </section>
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
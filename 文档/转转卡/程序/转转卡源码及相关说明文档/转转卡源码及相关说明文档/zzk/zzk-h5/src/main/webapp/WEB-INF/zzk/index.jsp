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
  <title>转转卡</title>
  <link rel="stylesheet" href="${ctx}/zzk/resource/zzk/dest/base.css">
  <link rel="stylesheet" href="${ctx}/zzk/resource/zzk/dest/swiper.min.css">
  <script src="${ctx}/zzk/resource/zzk/js/flexible.js"></script><!--这个要在前面-->
</head>
<body>
<section class="swiper-container swiper-order">
  <div class="swiper-wrapper">
    <c:choose>
      <c:when test="${indexOrderCardDetailList != null}">
        <c:forEach items="${indexOrderCardDetailList}" var="cardDetail" varStatus="status">
          <div class="swiper-slide<c:if test="${status.first}"> swiper-slide-active</c:if>">
            <a class="ka-item ka-item-b" href="#">
              <div class="ka-item-cover">
                <c:choose><c:when test='${"Z2".equals(cardDetail.packageName)}'><img src="${ctx}/zzk/resource/zzk/temp/zxk48.png" width="100%"></c:when><c:otherwise><img src="${ctx}/zzk/resource/zzk/temp/zxk24.png" width="100%"></c:otherwise></c:choose>
              </div>
              <div class="ka-item-main ka-order">
                <div class="ka-order-title">您的订单<strong><c:choose><c:when test='${"Z2".equals(cardDetail.packageName)}'>转转卡尊享卡</c:when><c:otherwise>转转卡优享卡</c:otherwise></c:choose></strong></div>
                <c:choose>
                  <c:when test='${empty cardDetail.cardNo}'>
                    <div class="no-order-text text-center text-nowrap">您的订单正在处理中!</div>
                  </c:when>
                  <c:otherwise>
                    <div class="ka-order-cn">卡号 <span>Card Number</span></div>
                    <div class="ka-order-number">
                        <c:forEach var="i" begin="0" end="${cardDetail.cardNo.length() - 1}" varStatus="status"><c:if test="${i%4==0}"><c:choose><c:when test="${status.first}"><span></c:when><c:otherwise></span><span></c:otherwise></c:choose></c:if>${cardDetail.cardNo.charAt(i)}<c:if test="${status.last}"></span></c:if></c:forEach>
                    </div>
                    <div class="ka-order-complex flex">

                      <div class="flex-auto">
                        <c:if test="${not empty cardDetail.activeEndTime}">
                          剩余时间
                          <div class="counter" data-seconds="${cardDetail.activeEndTime}"><span class="hours">0</span>小时<span class="minutes">0</span>分<span class="seconds">0</span>秒</div>
                        </c:if>
                      </div>
                      <div class="ka-order-stats flex-auto text-right">
                        状态：<span><c:choose><c:when test="${empty cardDetail.activeEndTime}">未激活</c:when><c:otherwise>已激活</c:otherwise></c:choose></span>
                      </div>
                    </div>
                  </c:otherwise>
                </c:choose>
                <div class="ka-item-line"></div>
                <div class="ka-item-mask"></div>
              </div>
            </a>
          </div>
        </c:forEach>
      </c:when>
      <c:otherwise>
        <div class="swiper-slide swiper-slide-active">
          <a class="ka-item ka-item-a" href="${ctx}/zzk/function-selection?sp=Z1">
            <div class="ka-item-cover"><img src="${ctx}/zzk/resource/zzk/temp/zxk24.png" width="100%"></div>
            <div class="ka-item-main ka-order">
              <div class="ka-order-title">您的订单<strong>转转卡优享卡</strong></div>
              <div class="no-order-text text-center text-nowrap">您当前还没有订单，赶快去选购吧!</div>
              <div class="ka-item-line"></div>
              <div class="ka-item-mask"></div>
            </div>
          </a>
        </div><!--swiper-slide-->
        <div class="swiper-slide">
          <a class="ka-item" href="${ctx}/zzk/function-selection?sp=Z2">
            <div class="ka-item-cover"><img src="${ctx}/zzk/resource/zzk/temp/zxk48.png" width="100%"></div>
            <div class="ka-item-main ka-order">
              <div class="ka-order-title">您的订单<strong>转转卡尊享卡</strong></div>
              <div class="no-order-text text-center text-nowrap">您当前还没有订单，赶快去选购吧!</div>
              <div class="ka-item-line"></div>
              <div class="ka-item-mask"></div>
            </div>
          </a>
        </div><!--swiper-slide-->
      </c:otherwise>
    </c:choose>
  </div>
  <!-- Add Arrows -->
  <div class="swiper-button-next"></div>
  <div class="swiper-button-prev"></div>
</section>

<section class="main-menu">
  <ul class="clearfix">
    <li><a class="button one" href="http://huodong.szsmk.com/hd/2018/01/zhuanzhuan/spot.html">景点介绍</a></li>
    <li><a class="button two" href="http://huodong.szsmk.com/hd/2018/01/zhuanzhuan/introduction.html">转转卡介绍</a></li>
    <li><a class="button three" href="http://huodong.szsmk.com/hd/2018/01/zhuanzhuan/guide.html">使用介绍</a></li>
    <li><a class="button four" href="http://huodong.szsmk.com/hd/2018/01/zhuanzhuan/handle.html">如何办理</a></li>
  </ul>
  <div class="main-menu-shadow"></div>
</section>

<footer class="footer"><a class="buy-now" href="${ctx}/zzk/packages"><span>立即购买</span></a></footer>
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
<script src="${ctx}/zzk/resource/zzk/js/swiper.min.js"></script>
<script src="${ctx}/zzk/resource/zzk/js/base.js"></script>
<script>
  var swiperOrder = new Swiper('.swiper-order', {
    navigation: {
      nextEl: '.swiper-button-next',
      prevEl: '.swiper-button-prev',
    },
    loop: true,
    on: {
      // transitionStart: function(){
      //   $('.swiper-button-next, .swiper-button-prev').css('opacity', '0.3');
      // },
      // transitionEnd: function(){
      //   $('.swiper-button-next, .swiper-button-prev').css('opacity', '1');
      // }
    }
  });

  $('.counter').counter();

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
</script>
<%@ include file="../publics/wxshare.jsp"%>
</body>
</html>
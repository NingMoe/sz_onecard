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
    <title>订单详情</title>
    <link rel="stylesheet" href="${ctx}/zzk/resource/zzk/dest/base.css">
    <script src="${ctx}/zzk/resource/zzk/js/flexible.js"></script>
    <style>
        .commodity-item-update{margin:-.266667rem .533333rem .4rem}
        .commodity-item-update a{color:#f05e4f;text-decoration:underline;font-size:.32rem;}
    </style>
</head>
<body>
  <section class="order">
    <%--<div class="card-box card-box-opposite">--%>
      <%--<div class="card-box-icn icn-warn"></div>--%>
      <%--<div class="card-box-main warn-text">您已成功办理转转卡A套餐，已于2017年11月27日成功--%>
          <%--激活,有效期还剩24小时。--%>
      <%--</div>--%>
    <%--</div>--%>
    <div class="card-box">
      <div class="card-box-icn icn-car"></div>
      <div class="card-box-main">
        <label class="pull-left">派送方式</label>
        <div class="pull-right">
          <c:choose>
              <c:when test='${"01".equals(order.fetchType)}'>
                  <label class="radio-label">自取</label>
              </c:when>
              <c:otherwise>
                  <label class="radio-label">快递8.00元</label>
              </c:otherwise>
          </c:choose>
        </div>
      </div>
    </div>
    <c:if test='${"01".equals(order.fetchType)}'>
    <div class="card-box" id="orderAddress">
        <div class="card-box-icn icn-abacus"></div>
        <div class="card-box-main order-address">
            <c:forEach items="${fetchCodeList}" var="fetchCode">
                <div class="address-item-person"><label>取件码信息：</label><span class="address-item-span">${fetchCode.custName}</span><span class="address-item-span pull-right">${fetchCode.fetchCode}</span></div>
            </c:forEach>
        </div>
    </div>
    </c:if>
    <div class="order-self-pick text-right" id="orderSelf">
        <a<c:if test='${"01".equals(order.fetchType)}'> class="pull-left"</c:if> href="http://huodong.szsmk.com/hd/2018/01/zhuanzhuan/spot.html">可去景点</a>
        <c:if test='${"01".equals(order.fetchType)}'><a href="http://huodong.szsmk.com/hd/2018/01/zhuanzhuan/map.html">查看可取卡地址</a></c:if>
    </div>
    <c:if test='${"00".equals(order.fetchType)}'>
    <div class="card-box" id="orderAddress">
        <div class="card-box-icn icn-loc"></div>
        <div class="card-box-main order-address">
            <div class="address-item-person"><label>收货人：</label><span class="address-item-span">${order.receiveCustName}</span><span class="pull-right">${order.receiveCustPhone}</span></div>
            <div><label>收货地址：</label><span class="address-item-span">${order.receiveAddress}</span></div>
        </div>
    </div>
    </c:if>
    <div class="card-box commodity-lst">
        <div class="card-box-icn icn-rmb"></div>
        <c:forEach items="${order.orderCardList}" var="orderCardDetail" varStatus="status">
            <div class="card-box-main commodity-item">
                <div class="commodity-item-total">
                    <label class="card-box-label">套餐总额</label>
                    <span class="commodity-total-price pull-right">￥${orderCardDetail.packageMoney + orderCardDetail.supplyMoney}</span>
                </div>
                <div class="commodity-item-hd">
                    <span class="commodity-item-title">
                        <c:choose>
                            <c:when test='${"Z2".equals(orderCardDetail.packageName)}'>
                                转转卡尊享卡套餐
                            </c:when>
                            <c:otherwise>
                                转转卡优享卡套餐
                            </c:otherwise>
                        </c:choose>
                    </span>
                    <span class="commodity-item-price pull-right">￥${orderCardDetail.packageMoney}</span>
                </div>
                <c:if test='${"01".equals(orderCardDetail.discountType)}'>
                <div class="commodity-item-bd">
                    <span class="commodity-item-prepare">兑换码</span>
                    <span class="commodity-item-price pull-right">￥-${orderCardDetail.chargeNoPrice}</span>
                </div>
                </c:if>
                <div class="commodity-item-bd">
                    <span class="commodity-item-prepare">预充值</span>
                    <span class="commodity-item-price pull-right">￥${orderCardDetail.supplyMoney}</span>
                </div>
                <div class="commodity-item-bar">
                    <span class="commodity-item-holder">持卡人:</span>
                    <span class="commodity-item-name">${orderCardDetail.custName}</span>
                    <span class="commodity-item-phone">${orderCardDetail.custPhone}</span>
                    <c:if test='${"1".equals(orderCardDetail.rejectType)}'>
                    <span class="commodity-item-update"><a href="javascript:window.location='${ctx}/zzk/auth-update?orderNo=${order.orderNo}&detailNo=${orderCardDetail.detailNo}&custPhone=${orderCardDetail.custPhone}&paperNo=${orderCardDetail.paperNo}&custName=${orderCardDetail.custName}'">更新照片</a></span>
                    </c:if>
                </div>
            </div>
        </c:forEach>
        <c:forEach items="${order.orderChargeList}" var="orderChargeDetail" varStatus="status">
            <div class="card-box-main commodity-item">
                <div class="commodity-item-total">
                    <label class="card-box-label">套餐总额</label>
                    <span class="commodity-total-price pull-right">￥${orderChargeDetail.funcFee}</span>
                </div>
                <div class="commodity-item-hd">
                    <span class="commodity-item-title">
                        <c:choose>
                            <c:when test='${"Z2".equals(orderChargeDetail.packageName)}'>
                                转转卡尊享卡套餐兑换券
                            </c:when>
                            <c:otherwise>
                                转转卡优享卡套餐兑换券
                            </c:otherwise>
                        </c:choose>
                    </span>
                    <span class="commodity-item-price pull-right">￥${orderChargeDetail.funcFee}</span>
                </div>
            </div>
        </c:forEach>
    </div>
    <c:if test="${not empty order.remark}">
    <div class="card-box">
        <div class="card-box-icn icn-edit"></div>
        <div class="card-box-main">
            <label>我的留言</label>
            <div class="order-message commodity-item-title">${order.remark}</div>
        </div>
    </div>
    </c:if>
    <div class="card-box card-total">
        <div class="card-box-icn icn-card"></div>
        <div class="card-box-main">
            <label>
                <c:choose>
                    <c:when test='${"0".equals(order.paymentState)}'>
                        应付总额
                    </c:when>
                    <c:otherwise>
                        订单总额
                    </c:otherwise>
                </c:choose>
            </label>
            <span class="commodity-total-price pull-right" id="zqBill">￥${order.orderMoney}</span>
        </div>
    </div>
    <c:if test='${"0".equals(order.paymentState)}'>
    <div class="order-tobe-pay text-center">
    <a class="btn btn-block round" href="${ctx}/zzk/pay?payOrderNo=${order.orderNo}&payOrderMoney=${order.orderMoney}&payOrderSubject=${payOrderSubject}">立即支付</a>
    </div>
    </c:if>
  </section>

  <section class="global-nav">
    <ul class="flex">
      <li class="flex-1"><a href="${ctx}/zzk/index"><span class="icn-palance"></span><strong>首页</strong></a></li>
      <li class="flex-1 active"><a href="${ctx}/zzk/my-orders"><span class="icn-board"></span><strong>我的订单</strong></a></li>
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
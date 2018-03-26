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
    <title>我的订单</title>
    <link rel="stylesheet" href="${ctx}/zzk/resource/zzk/dest/base.css">
    <script src="${ctx}/zzk/resource/zzk/js/flexible.js"></script>
</head>
<body>
  <section class="cart">
    <div class="card-box card-box-fixed">
      <input class="checkbox" type="checkbox" id="checkAll" name="checkAll">
      <div class="card-box-main">
        <label class="pull-left" for="checkAll">选择全部商品</label>
        <button class="del-card pull-right">删除</button>
      </div>
    </div>
    <div class="commodity-lst">
      <c:forEach items="${orderList}" var="order" varStatus="status">
          <div class="card-box commodity-item<c:if test='${"1".equals(order.rejectType)}'> card-box-opposite</c:if>">
              <c:if test='${"0".equals(order.paymentState) || "2".equals(order.paymentState)}'>
              <input class="checkbox check-item" type="checkbox"  name="checkItem" value="${order.orderNo}" data-id="${order.orderNo}" data-num="1" data-price="${order.orderMoney}" data-pre="0">
              </c:if>
                  <a class="card-box-main" href="${ctx}/zzk/order-detail?orderNo=${order.orderNo}">
                  <div class="commodity-item-hd">
                      <span class="commodity-item-title">${order.orderTitle}</span>
                      <span class="commodity-item-price pull-right">￥${order.orderMoney}</span>
                  </div>
                  <div class="commodity-item-det">
                      <p>订单：${order.orderNo} </p>
                      <p>时间：${order.createTime} </p>
                      <p>状态：
                        <c:choose>
                            <c:when test='${"0".equals(order.paymentState) || "2".equals(order.paymentState)}'>
                                <c:if test='${"0".equals(order.paymentState)}'>未支付</c:if>
                                <c:if test='${"2".equals(order.paymentState)}'>已过期</c:if>
                            </c:when>
                            <c:otherwise>
                                <c:choose>
                                    <c:when test='${"1".equals(order.rejectType)}'>已驳回</c:when>
                                    <c:otherwise>
                                        <c:if test='${"0".equals(order.orderState)}'>处理中</c:if>
                                        <c:if test='${"1".equals(order.orderState)}'>已制卡</c:if>
                                        <c:if test='${"2".equals(order.orderState)}'>已发货</c:if>
                                        <c:if test='${"3".equals(order.orderState)}'>已领卡</c:if>
                                    </c:otherwise>
                                </c:choose>
                            </c:otherwise>
                        </c:choose>
                      </p>
                  </div>
              </a>
          </div>
      </c:forEach>
    </div>
  </section>

  <section class="popup transition" id="delPopup">
    <div class="popup-inner">
      <div class="popup-content">确定要删除？</div>
      <div class="popup-action">
        <button class="btn btn-sm popup-cancel round"><span class="icn icn-cancel"></span>取消</button>
        <button class="btn btn-sm do-del round"><span class="icn icn-next"></span>确定</button>
      </div>
    </div>
  </section>

  <section class="popup transition" id="resPopup">
      <%--<div class="cart-success">--%>
          <%--<div class="popup-content"> 成功！</div>--%>
          <%--<div class="popup-action">--%>
              <%--<button class="btn btn-sm go-check-out round"><span class="icn icn-bag"></span>结账</button>--%>
              <%--<button class="btn btn-sm go-buy-more round"><span class="icn icn-cart"></span>加购</button>--%>
          <%--</div>--%>
      <%--</div>--%>
      <%--<div class="cart-fail">--%>
          <div class="popup-content">失败！</div>
          <div class="popup-action">
              <button class="btn btn-sm popup-cancel round"><span class="icn icn-next"></span>确定</button>
          </div>
      <%--</div>--%>
  </section>

  <section class="popup-mask"></section>

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

      $("body").on("click", "#checkAll", function(){
          $('.commodity-lst .check-item').prop("checked", this.checked ?  "checked" : false);
      });
      $("body").on("click", ".check-item", function(event){
          var $table = $(this).closest(".commodity-lst"), checked = false;
          event.stopPropagation();
          if(this.checked && ($table.find(".check-item:checked").length == $table.find(".check-item").length) ){
              checked = "checked";
          }
          $("#checkAll").prop("checked", checked);
      });

      //删除弹窗
      var pop1 = new Popup($('#delPopup'), {
        maskClose: true
      });

    var popres = new Popup($('#resPopup'), {
        maskClose: true
    });

      $('.del-card').on('click', function(){
        var $checked = $('.commodity-lst .check-item:checked');
        if(!$checked.length){ return }
        pop1.show();
      })

      //删除
      $('.do-del').on('click', function(){
          var checkeds = $('.commodity-lst .check-item:checked');
          if(!checkeds.length){return false}
        $('#checkAll').prop('checked', false);
      $.ajax({
          url: '${ctx}/zzk/deleteOrder',
          dataType: 'json',
          type: 'post',
          traditional :true,
          data: {
              orderIds: checkeds.map(function(){return this.value}).get().join()
          }
      }).done(function(data){
          if(data.ret == 0){
           checkeds.parent().remove();
          }else{
//              pop1.$popup.find('.cart-fail').show().siblings().hide();
              popres.show();
          }
      }).always(function(){
          $(this).data('ajax', null);
      });
        pop1.hide();
      });

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
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
  <section class="popup popup-darken transition active" id="payPopup">
    <div class="popup-inner">
      <div class="popup-content pay-type">
        <a class="weixin transition" data-type="weixin" href="javascript:void(0);">微信支付</a>
        <a class="alipay transition" data-type="alipay" href="javascript:void(0);">支付宝支付</a>
      </div>
      <div class="popup-action">
        <button class="btn btn-sm go-back round">取消</button>
      </div>
    </div>
  </section>
  <section class="popup-mask" style="display: block;"></section>

  <script src="${ctx}/zzk/resource/zzk/js/jquery.min.js"> </script>
  <script src="${ctx}/zzk/resource/zzk/js/fastclick.js"> </script>
  <script src="${ctx}/zzk/resource/zzk/js/base.js"></script>
  <script>
    jQuery(function(){

    if(APP.weixinReg.test(navigator.userAgent)){
        $('.pay-type .alipay').hide();
    } else {
        $('.pay-type .weixin').hide();
    }

      //取消支付
      $('.go-back').on('click', function(){
        history.back();
      });
      

      //选择支付方式
      $('.pay-type a').on('click', function(){
        $('.pay-type').removeClass('pay-weixin pay-alipay').addClass('pay-' + $(this).data('type'));

          var payType = $(this).data('type');
          if (payType == 'weixin') {
              location.href = '${ctx}/zzk/tenpay?payOrderNo=${payOrderNo}&payOrderMoney=${payOrderMoney}&payOrderSubject=${payOrderSubject}&openId=${openId}';
          } else {
              location.href = '${ctx}/zzk/alipay?payOrderNo=${payOrderNo}&payOrderMoney=${payOrderMoney}&payOrderSubject=${payOrderSubject}';
          }

        // APP.showLoading();
        // setTimeout(function(){
        //   APP.showLoading();
        // }, 5000);

        <%--//跳转至支付结果页--%>
        <%--setTimeout(function(){--%>
          <%--location.replace('${ctx}/zzk/pay-result');--%>
        <%--}, 5000)--%>
      });

    });
  </script>
</body>
</html>
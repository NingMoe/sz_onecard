<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="../publics/jstl.jsp" %>
<!doctype html>
<html>
<head>
<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
<meta content="telephone=no" name="format-detection" />
</head>
<body>
<script src="${ctx}/zzk/resource/zzk/js/jquery.min.js"> </script>
<script>
function onBridgeReady(){
    WeixinJSBridge.invoke(
            'getBrandWCPayRequest', {
                "appId" : "${appId}",
                "timeStamp" : "${timeStamp}",
                "nonceStr" : "${nonceStr}",
                "package" : "prepay_id=${prepay_id}",
                "signType" : "${signType}",
                "paySign" : "${paySign}"
    }, function(res){
        if(res.err_msg == "get_brand_wcpay_request:ok"){
            window.location.replace('${ctx}/zzk/pay-result?ret=0');
        } else {
            window.location.replace('${ctx}/zzk/pay-result?ret=1');
        }
    });
}
if (typeof WeixinJSBridge == "undefined"){
    if( document.addEventListener ){
        document.addEventListener('WeixinJSBridgeReady', onBridgeReady, false);
    }else if (document.attachEvent){
        document.attachEvent('WeixinJSBridgeReady', onBridgeReady);
        document.attachEvent('onWeixinJSBridgeReady', onBridgeReady);
    }
}else{
    onBridgeReady();
}
</script>
</body>
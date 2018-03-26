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
    <title>地址管理</title>
    <link rel="stylesheet" href="${ctx}/zzk/resource/zzk/dest/base.css">
    <script src="${ctx}/zzk/resource/zzk/js/flexible.js"></script>
</head>
<body>
<section class="address">
    <c:forEach items="${addressList}" var="address" varStatus="status">
    <div class="card-box address-item" id="address${address.addressId}" data-id="${address.addressId}">
        <input<c:if test='${"1".equals(address.isDefault)}'> checked="checked"</c:if> class="checkbox checkbox-default hide" type="radio" name="default" value="${address.addressId}" id="default${address.addressId}" data-id="${address.addressId}" data-custname="${address.custName}" data-custphone="${address.custPhone}" data-address="${address.address}" data-location="${address.location}">
        <div class="card-box-main" data-id="${address.addressId}">
            <div class="address-item-person"><label class="card-box-label">收货人：</label><span class="address-item-span">${address.custName}</span><span class="pull-right">${address.custPhone}</span></div>
            <div class="address-item-det"><label class="card-box-label">收货地址：</label><span class="address-item-span" data-custlocation="${address.location}">${address.address}</span></div>
            <div class="address-item-bar text-right" data-pos="bar">
                <label class="pull-left" for="default${address.addressId}" data-id="${address.addressId}" data-pos="bar">设为默认</label>
                <span class="addr-edit" data-id="${address.addressId}"  data-pos="bar">编辑</span>
                <span class="del-span" data-id="${address.addressId}"  data-pos="bar">删除</span>
            </div>
        </div>
    </div>
    </c:forEach>
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
<section class="popup-mask"></section>
<footer class="footer"><a class="button go-buy" href="${ctx}/zzk/address">新增地址</a></footer>
<script src="${ctx}/zzk/resource/zzk/js/jquery.min.js"> </script>
<script src="${ctx}/zzk/resource/zzk/js/fastclick.js"> </script>
<script src="${ctx}/zzk/resource/zzk/js/base.js"></script>
<script>
    jQuery(function(){

        $('.checkbox-default').each(function(){
            $main = $(this).siblings('.card-box-main')
            $(this).css('margin-top', $main.height() - $main.find('.address-item-bar').height() - 1 ).show();
        }).on('change', function(){
//            console.log($('.checkbox-default:checked').val())

            var addressId = $('.checkbox-default:checked').val();
            var custName = $('.checkbox-default:checked').data('custname');
            var custPhone = $('.checkbox-default:checked').data('custphone');
            var address = $('.checkbox-default:checked').data('address');
            var addlocation = $('.checkbox-default:checked').data('location');

            $.post('${ctx}/zzk/saveAddressDefault', {"addressId":addressId, "custName":custName, "custPhone":custPhone, "address":address, "location":addlocation}, function(data){})
        });

        $('.address-item-bar label').on('click', function(){
            $('#' + $(this).attr('for')).trigger('click')
        });

        $('.card-box-main').on('click', function(event){
            if($(event.target).data('pos') == 'bar'){
                return false;
            }
            location.replace('${ctx}/zzk/order?addressId='+ $(this).data('id'));
        });

        $('.addr-edit').on('click', function(){
            window.location.href='${ctx}/zzk/address?id=' + $(this).data('id');
        });

        //删除弹窗
        var pop1 = new Popup($('#delPopup'), {
            maskClose: true
        });
        var delId;

        $('.del-span').on('click', function(){
            delId = $(this).data('id');
            pop1.show();
        });

        //删除
        $('.do-del').on('click', function(){

            $.post('${ctx}/zzk/deleteAddress', {"addressId":delId}, function(data){

            })

            $('#address' + delId).remove();
            pop1.hide();
        });

    });
</script>
</body>
</html>
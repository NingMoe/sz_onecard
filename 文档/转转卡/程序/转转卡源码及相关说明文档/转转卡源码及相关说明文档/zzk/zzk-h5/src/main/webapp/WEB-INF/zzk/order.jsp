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
  <section class="order">
    <div class="order-header">
      <div class="cloud"></div>
      <div class="car"></div>
    </div>
    <div class="card-box">
      <div class="card-box-icn icn-car"></div>
      <div class="card-box-main">
        <label class="pull-left card-box-label">派送方式</label>
        <div class="pull-right">
          <label class="radio-label">快递8.00元<input class="radio" type="radio" name="delivery" value="kd"></label>
          <label class="radio-label">自取<input class="radio" type="radio" name="delivery" value="zq"></label>
        </div>
        <div class="pull-right">2月13日至21日停止快递发货</div>
      </div>
    </div>
    <div class="order-self-pick text-right" id="orderSelf"><a href="http://huodong.szsmk.com/hd/2018/01/zhuanzhuan/map.html">查看自取地址</a></div>
    <div class="card-box hide" id="orderAddress" data-xxx="">
        <div class="card-box-icn icn-loc"></div>
        <a class="card-box-main order-address" href="${ctx}/zzk/addresses">
            <c:choose>
                <c:when test="${selectedAddress != null}">
                    <div class="address-item-person"><label class="card-box-label">收货人：</label><span class="address-item-span">${selectedAddress.custName}</span><span class="pull-right">${selectedAddress.custPhone}</span></div>
                    <div class="address-item-det"><label class="card-box-label">收货地址：</label><span class="address-item-span" data-custlocation="${selectedAddress.location}">${selectedAddress.address}</span></div>
                </c:when>
                <c:otherwise>
                    <div class="address-item-person"><label class="card-box-label">收货人：</label><span class="address-item-span"></span><span class="pull-right"></span></div>
                    <div class="address-item-det"><label class="card-box-label">收货地址：</label><span class="address-item-span" data-custlocation=""></span></div>
                </c:otherwise>
            </c:choose>
        </a>
    </div>
    <div class="card-box">
        <div class="card-box-icn icn-edit"></div>
        <div class="card-box-main">
            <label class="card-box-label">我要留言</label>
            <div class="order-message"><textarea placeholder="留言"></textarea></div>
        </div>
    </div>  
    <div class="card-box card-total">
        <div class="card-box-icn icn-card"></div>
        <div class="card-box-main">
            <label class="card-box-label">应付总额</label>
            <span class="commodity-total-price pull-right" id="zqBill"></span>
            <span class="commodity-total-price pull-right hide" id="kdBill"></span>
        </div>
    </div>           
  </section>

  <section class="popup transition" id="orderPopup">
          <div class="popup-content"> 订单生成失败 ！</div>
          <div class="popup-action">
              <button class="btn btn-sm popup-cancel round"><span class="icn icn-next"></span>确定</button>
          </div>
  </section>
  <section class="popup transition" id="addressPopup">
      <div class="popup-content"> 收货人信息不能为空 ！</div>
      <div class="popup-action">
          <button class="btn btn-sm popup-cancel round"><span class="icn icn-next"></span>确定</button>
      </div>
  </section>
  <section class="popup transition" id="doublePopup">
      <div class="popup-content"> 已购买过，请至我的订单查看！</div>
      <div class="popup-action">
          <button class="btn btn-sm popup-cancel round"><span class="icn icn-next"></span>确定</button>
      </div>
  </section>
  <section class="popup-mask"></section>

  <footer class="footer"><a class="button go-payment" data-submitflag="" data-url="" href="${ctx}/zzk/pay">立即支付</a></footer>
  <script src="${ctx}/zzk/resource/zzk/js/jquery.min.js"> </script>
  <script src="${ctx}/zzk/resource/zzk/js/fastclick.js"> </script>
  <script src="${ctx}/zzk/resource/zzk/js/base.js"></script>
  <script>
    jQuery(function(){

      //配送方式变更
      $('input[name=delivery]').on('click', function(){
        if(this.value == "kd"){
          $('#orderAddress, #kdBill').show();
          $('#zqBill, #orderSelf').hide();
        }else{
          $('#orderAddress, #kdBill').hide();
          $('#zqBill, #orderSelf').show();
        }

        //更新默认派送方式
        localStorage.setItem('delivery', this.value);
      });      
      
      //从storage中获取派送方式,并作为默认派送方式
      var delivery = localStorage.getItem('delivery') || 'zq';
      $('input[name=delivery]').each(function(){
        if(this.value == delivery){
          $(this).trigger('click');
        }
      });

      var orders;

      function updateCommodity(){

          orders = localStorage.getItem('orders');
          var comdoStr = '    <div class="card-box commodity-lst">'
                  +' <div class="card-box-icn icn-rmb"></div>';
          var totalPrice = 0;
          localStorage.removeItem(orders);

          orders  = JSON.parse(orders);

          for(var i = 0 ; i< orders.length; i++){
              comdoStr +=
                      ' <div class="card-box-main commodity-item">'
                      +' <div class="commodity-item-total">'
                      +'<span class="commodity-item-title">套餐总额</span>'
                      +'<span class="commodity-total-price pull-right">￥' + orders[i].totalprice + '</span>'
                      +'</div>'
                      +'<div class="commodity-item-hd">'
                      +' <span class="commodity-item-title">' + orders[i].title + '</span>'
                      +' <span class="commodity-item-price pull-right">￥' + orders[i].price + '</span>'
                      +'</div>';

              //兑换码抵扣
              if(orders[i].discounttype == '01'){
                  comdoStr +=
                          '<div class="commodity-item-hd">'
                          +'<span class="commodity-item-title">兑换码</span>'
                          +'<span class="commodity-item-price pull-right">￥-'+orders[i].chargenoprice+'</span>'
                          +'</div>';
              }

              //预充值
              if(orders[i].prepay){
                  comdoStr += '<div class="commodity-item-bd">'
                          +'<span class="commodity-item-prepare">预充值</span>'
                          +'<span class="commodity-item-price pull-right">￥' + orders[i].prepay + '</span>'
                          +'</div>';

                  //有预支付，只能快递
                  if (orders[i].prepay > 0) {
                      setKd();
                  }
              }

              //含有兑换券只能快递
              if (orders[i].ordertype == '1') {
                  setKd();
              }

              if(orders[i].custname){
                  comdoStr += '<div class="commodity-item-bar">'
                          +'<span class="commodity-item-holder">持卡人:</span>'
                          +'<span class="commodity-item-name">' + orders[i].custname + '</span>'
                          +'<span class="commodity-item-phone">' + orders[i].custtel + '</span>'
                          +'</div>';
              }


              comdoStr +='</div>';
              totalPrice += orders[i].totalprice;
          }

          comdoStr += '</div>';
          $('#orderAddress').after(comdoStr);
          $('#kdBill').html('￥' + (totalPrice + 8));
          $('#kdBill').data('price', totalPrice + 8);
          $('#zqBill').html('￥' + totalPrice);
          $('#zqBill').data('price', totalPrice);
      }

    updateCommodity();

    //加入购物车弹窗
    var pop1 = new Popup($('#orderPopup'), {
        maskClose: true
    });

    //地址弹窗
    var pop2 = new Popup($('#addressPopup'), {
        maskClose: true
    });

    //重复提交处理
    var pop3 = new Popup($('#doublePopup'), {
        maskClose: true,
        closeAfter: function() {
            window.location.replace('${ctx}/zzk/my-orders');
        }
    });

    $('.go-payment').on('click', function(event){
        var $this = $(this);
        event.preventDefault();
        if($this.data('ajax')){ return  false }

        //判断是否成功提交过
        if ($this.data('submitflag') == '1') {
            window.location = $this.data('url');
            return false;
        }

        //打开一个加载器
        APP.showLoading();

        $this.data('ajax', true);

        //收货信息
        var custname = $('.address-item-person span.address-item-span').text();
        var custphone = $('.address-item-person span.pull-right').text();
        var address = $('.address-item-det span.address-item-span').text();
        var custlocation = $('.address-item-det span.address-item-span').data('custlocation');

        var orderMoney;
        var fetchType = $('input[name=delivery]:checked').val();
        if (fetchType == 'kd') {
            //判断收货信息是否为空
            if (custname == '' || custphone == '' || address == '') {
                APP.closeLoading();
                pop2.show();
                return false;
            }
            orderMoney = $('#kdBill').data('price');
        } else {
            orderMoney = $('#zqBill').data('price');
        }

        $.ajax({
            url: '${ctx}/zzk/saveOrder',
            dataType: 'json',
            type: 'post',
            traditional :true,
            data: {
                orders: localStorage.getItem('orders'),
                orderMoney: orderMoney,
                delivery: $('input[name=delivery]:checked').val(),
                deliveryMoney: '8',
                custname : custname,
                custphone : custphone,
                address : address,
                custlocation : custlocation,
                remark : $('.order-message textarea').val()
            }
        }).done(function(data){
            //关闭加载器
            APP.closeLoading();
            if(data.ret == 0){
                var url = "${ctx}/zzk/pay?payOrderNo="+data.data.payOrderNo+"&payOrderMoney="+data.data.payOrderMoney+"&payOrderSubject="+data.data.payOrderSubject;
                $this.data('submitflag', '1');
                $this.data('url', url);
                window.location.href = url;
            } else if (data.ret == 2) {
                var url = "${ctx}/zzk/pay-result?ret=0&msg=成功";
                $this.data('submitflag', '1');
                $this.data('url', url);
                window.location.href = url;
            } else if (data.ret == 3) {
                pop3.show();
            } else {
                pop1.show();
            }
        }).always(function(){
            $this.data('ajax', null);
        });

        //关闭套餐选择器
        $('#voucherOption .select-main-close').trigger('click');

        // pop1.show();
    });

    function setKd(){
        $('input[name=delivery]').each(function(){
            if(this.value == 'kd'){
                $(this).trigger('click');
            }else{
                $(this).parent().hide();
            }
        });
    }

});

  </script>
</body>
</html>
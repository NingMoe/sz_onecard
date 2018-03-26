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
    <title>卡订单</title>
    <link rel="stylesheet" href="${ctx}/zzk/resource/zzk/dest/base.css">
    <script src="${ctx}/zzk/resource/zzk/js/flexible.js"></script>
</head>
<body>
  <section class="buy-card">
    <div class="card-info">
      <div class="card-info-cover pull-left">
          <c:choose>
              <c:when test='${"Z2".equals(sp)}'><img src="${ctx}/zzk/resource/zzk/temp/zxk.png" width="100%" height="100%"></c:when>
              <c:otherwise><img src="${ctx}/zzk/resource/zzk/temp/yxk.png" width="100%" height="100%"></c:otherwise>
          </c:choose>

      </div>
      <div class="card-info-main">
        <div class="card-info-title"><c:choose><c:when test='${"Z2".equals(sp)}'>转转卡尊享卡套餐</c:when><c:otherwise>转转卡优享卡套餐</c:otherwise></c:choose></div>
        <div class="card-info-desc text-nowrap">
            <c:choose>
                <c:when test='${"Z2".equals(sp)}'>
                    激活后48h内凭尊享卡可以游览套餐内景点
                </c:when>
                <c:otherwise>
                    激活后24h内凭优享卡可以游览套餐内景点
                </c:otherwise>
            </c:choose>
        </div>
        <div class="card-info-price" data-price='<c:choose><c:when test='${"Z2".equals(sp)}'>288</c:when><c:otherwise>200</c:otherwise></c:choose>'><c:choose><c:when test='${"Z2".equals(sp)}'>￥288</c:when><c:otherwise>￥200</c:otherwise></c:choose></div>
      </div>
    </div>
    <div class="card-box card-buyer">
        <div class="card-box-icn icn-note"></div>
        <div class="card-box-main">
            <label>基本信息</label>
        </div>
        <div class="buyer-info">
          <div><span>姓名：</span>${name}</div>
          <div><span>手机号：</span>${phone}</div>
          <div><span>证件号码：</span>${idCard}</div>
        </div>
    </div>
    <div class="card-box card-prepay">
        <div class="card-box-icn icn-piggy"></div>
        <div class="card-box-main">
          <div class="card-box-hd"><label class="card-box-label">预充值</label></div>
          <div class="card-prepay-lst">
            <span>预充值</span>
            <label class="radio-label">0<input class="radio" type="radio" name="prepay" checked value="0"></label>
            <label class="radio-label">20<input class="radio" type="radio" name="prepay" value="20"></label>
            <label class="radio-label">50<input class="radio" type="radio" name="prepay" value="50"></label>
            <label class="radio-label">100<input class="radio" type="radio" name="prepay" value="100"></label>
          </div>
          <div class="card-prepay-tip">注：充值后，持卡享受公交6折、轨道交通9.5折、有轨电车7折优惠；当余额少于7.6元，不能乘坐轨道交通；充值金额不过期、可退；</div>
        </div>
    </div>   
    <div class="card-box card-vouch">
        <div class="card-box-icn icn-coupon"></div>
        <div class="card-box-main">
          <div class="card-box-hd"><label class="card-box-label">兑换券</label></div>
          <div class="card-vouch-no">
            <input maxlength="16" placeholder="请输入兑换码" name="vouchNo" id="vouchNo">
            <button id="vouch" data-price="0" class="btn round pull-right">点击验证</button>
          </div>
        </div>
    </div>   
    <div class="card-box card-total">
        <div class="card-box-main">
          <div class="card-box-hd">
              <label class="card-box-label">合计</label>
              <span class="card-total-price pull-right" data-price="0">￥0</span>
          </div>
          <div class="card-total-desc">
              卡套餐￥200+预充值￥0-兑换券200
          </div>
        </div>
    </div>      
  </section>

  <section class="popup transition" id="cartPopup">
      <div class="cart-success">
          <div class="popup-content">您的订单已成功加入购物车！</div>
          <div class="popup-action">
              <button class="btn btn-sm go-check-out round"><span class="icn icn-bag"></span>结账</button>
              <button class="btn btn-sm go-buy-more round"><span class="icn icn-cart"></span>加购</button>
          </div>
      </div>
      <div class="cart-fail">
          <div class="popup-content">加入购物车失败！</div>
          <div class="popup-action">
              <button class="btn btn-sm go-check-fail round"><span class="icn icn-next"></span>确定</button>
          </div>
      </div>
  </section>
  <section class="popup transition" id="infoPopup">
      <div class="popup-inner">
          <div class="popup-content">-</div>
          <div class="popup-action">
              <button class="btn btn-sm popup-cancel round"><span class="icn icn-cancel"></span>确定</button>
          </div>
      </div>
  </section>
  <section class="popup transition" id="newPop">
      <div class="popup-inner">
          <div class="popup-content">请您注意！含预充值金额的转转卡订单，仅支持快递配送，不支持到取服务。</div>
          <div class="popup-action">
              <button class="btn btn-sm popup-cancel round"><span class="icn icn-cancel"></span>确定</button>
          </div>
      </div>
  </section>
  <section class="popup-mask"></section>


  <footer class="footer"><a class="button go-buy" href="${ctx}/zzk/cart">加入购物车</a></footer>
  <script src="${ctx}/zzk/resource/zzk/js/jquery.min.js"> </script>
  <script src="${ctx}/zzk/resource/zzk/js/fastclick.js"> </script>
  <script src="${ctx}/zzk/resource/zzk/js/base.js"></script>
  <script>
      jQuery(function(){

          //info弹窗
          var infoPop = new Popup($('#infoPopup'), {
              maskClose: true
          });

          //提示弹窗
          var newPop = new Popup($('#newPop'), {
              maskClose: true
          });
          $('.card-prepay-lst input').on('change', function(){
              if (this.value != '0') {
                  newPop.show();
              }
          });

          //初始化vouchers购物车
          vouchers.init();
          var vStore = vouchers.store;

          //更改预充值
          $('.card-prepay-lst .radio-label').on('click', updateTotal);

          $('#vouch').on('click', function(event){
              var  $this = $(this),
                      vouchNo =  $('#vouchNo').val();
              event.preventDefault();

              if(!vouchNo || $this.data('ajax') || $this.data('isuse')){ return  false }

              //打开一个加载器
              APP.showLoading();

              $this.data('ajax', true);
              $.ajax({
                  url: '${ctx}/zzk/chargeQuery',
                  dataType: 'json',
                  type: 'post',
                  data: {
                      id: vouchNo,
                      sp: '${sp}'
                  }
              }).done(function(data){
                  //关闭加载器
                  APP.closeLoading();
                  if (data.ret == 0) {
                      $('#vouchNo').attr('readonly', 'readonly');
                      $this.data({
                          'isuse':  true,
                          'price': data.data.price
                      });
                      updateTotal();
                  } else {
                      $('#vouchNo').val('');
                  }
                  infoPop.updateContent(data.msg).show();
              }).always(function(){
                  $this.data('ajax', null);
              });
          });

          function updateTotal(){
              var price = $('.card-info-price').data('price'),
                      prepay = $('input[name=prepay]:checked').val(),
                      vouch = $('#vouch').data('isuse') ? $('#vouch').data('price') : 0,
                      total = price  + parseInt(prepay, 10) - vouch,
                      totalStr = '卡套餐￥'+price+'+预充值￥' + prepay;

              if(vouch){
                  totalStr += '-兑换券' + vouch;
              }

              $('.card-total-desc').html(totalStr);
              $('.card-total-price').html('￥' + total);
              $('.card-total-price').data('price', total);
          }

          updateTotal();

          //加入购物车弹窗
          var pop1 = new Popup($('#cartPopup'), {
              maskClose: true
          });

          $('.go-buy').on('click', function(event){
              var prepay = $('input[name=prepay]:checked').val(),
                      vouchNo = $('#vouchNo').val(),
                      isuse = $('#vouch').data('isuse'),
                      packageMoney = $('.card-info-price').data('price'),
                      total = $('.card-total-price').data('price'),
                      $this = $(this);

              event.preventDefault();

              if (!isuse) {
                  vouchNo = "";
              }

              // //购物车
              // if(vStore[packageId]){//已经存在的
              //   vouchers.add(packageId, Math.min(packageMax, vStore[packageId].num + packageNum))
              // }else{
              //   vouchers.add(packageId, packageNum);
              // }

              if($this.data('ajax')){ return  false }

              //打开一个加载器
              APP.showLoading();

              $this.data('ajax', true);
              $.ajax({
                  url: '${ctx}/zzk/addBuyCard',
                  dataType: 'json',
                  type: 'post',
                  data: {
                      name: '${name}',
                      phone: '${phone}',
                      idCard: '${idCard}',
                      avatarPath: '${avatarPath}',
                      vouchNo: vouchNo,
                      packageType: '${sp}',
                      packageMoney: packageMoney,
                      prepay: prepay,
                      total: total
                  }
              }).done(function(data){
                  //关闭加载器
                  APP.closeLoading();
                  if(data.ret == 0){
                      pop1.$popup.find('.cart-success').show().siblings().hide();
                  }else{
                      pop1.$popup.find('.cart-fail').show().siblings().hide();
                  }
                  pop1.show();
              }).always(function(){
                  $this.data('ajax', null);
              });

          });

          //加购
          $('.go-buy-more').on('click', function(){
              //回退两页
//              history.go(-2);
              //或者
              window.location.href = '${ctx}/zzk/packages';
              //pop1.hide()
          });

          //去结算
          $('.go-check-out').on('click', function(){
              window.location.href = '${ctx}/zzk/cart';
              //pop1.hide()
          });
          //失败
          $('.go-check-fail').on('click', function(){
              // window.location.href = './cart.html';
              pop1.hide()
          });
      });
  </script>
</body>
</html>
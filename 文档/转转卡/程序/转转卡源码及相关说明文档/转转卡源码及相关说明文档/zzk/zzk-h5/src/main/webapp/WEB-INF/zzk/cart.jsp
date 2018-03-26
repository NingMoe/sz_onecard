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
  <title>购物车</title>
  <link rel="stylesheet" href="${ctx}/zzk/resource/zzk/dest/base.css">
  <script src="${ctx}/zzk/resource/zzk/js/flexible.js"></script>
  <script>
      function reload(event) {
          if(event.persisted){
            window.location.reload();
          }
      }
  </script>
</head>
<body onpageshow="reload(event)">
<section class="cart">
  <div class="card-box card-box-fixed">
    <input class="checkbox" type="checkbox" id="checkAll" name="checkAll">
    <div class="card-box-main">
      <label class="card-box-label pull-left" for="checkAll">选择全部商品</label>
      <button class="del-card pull-right">删除</button>
    </div>
  </div>
  <c:if test="${orderCardDetailList != null}">
  <div class="commodity-cate">
      <div class="commodity-cate-hd"><span class="icn-desktop"></span>我的办理</div>
      <div class="commodity-lst">
        <c:forEach items="${orderCardDetailList}" var="orderCardDetail" varStatus="cardStatus">
          <div class="card-box commodity-item">
            <input class="checkbox check-item" type="checkbox" name="checkItem"
                   data-id="${orderCardDetail.detailNo}"
                   data-pid="${orderCardDetail.orderNo}"
                   data-packagename="${orderCardDetail.packageName}"
                   data-ordertype="0"
                   data-num="1"
                   data-title="<c:choose><c:when test='${"Z2".equals(orderCardDetail.packageName)}'>转转卡尊享卡套餐</c:when><c:otherwise>转转卡优享卡套餐</c:otherwise></c:choose>"
                   data-price="${orderCardDetail.packageMoney}"
                   data-pre="${orderCardDetail.supplyMoney}"
                   data-custtel="${orderCardDetail.custPhone}"
                   data-paperno="${orderCardDetail.paperNo}"
                   data-discounttype="${orderCardDetail.discountType}"
                   data-chargeno="${orderCardDetail.chargeNo}"
                   data-chargenoprice="${orderCardDetail.chargeNoPrice}"
                   data-custname="${orderCardDetail.custName}">
            <div class="card-box-main">
              <div class="commodity-item-hd">
            <span class="commodity-item-title  card-box-label">
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
                <span class="commodity-item-holder">持卡人</span>
                <span class="commodity-item-name">${orderCardDetail.custName}</span>
                <span class="commodity-item-phone">${orderCardDetail.custPhone}</span>
              </div>
            </div>
          </div>
        </c:forEach>
      </div>
  </div>
  </c:if>
  <c:if test="${orderChargeDetailList != null}">
  <div class="commodity-cate">
    <div class="commodity-cate-hd"><span class="icn-tag"></span>兑换券</div>
    <div class="commodity-lst">
      <c:forEach items="${orderChargeDetailList}" var="orderChargeDetail" varStatus="chargeStatus">
      <div class="card-box commodity-item">
        <input class="checkbox check-item" type="checkbox" name="checkItem"
               data-id="${orderChargeDetail.detailNo}"
               data-pid="${orderChargeDetail.orderNo}"
               data-ordertype="1"
               data-packagename="${orderChargeDetail.packageName}"
               data-num="1"
               data-price="${orderChargeDetail.funcFee}"
               data-title="<c:choose><c:when test='${"Z2".equals(orderChargeDetail.packageName)}'>转转卡尊享卡套餐兑换券</c:when><c:otherwise>转转卡优享卡套餐兑换券</c:otherwise></c:choose>"
               data-pre="0"
               data-custtel=""
               data-paperno=""
               data-discounttype="00"
               data-chargeno=""
               data-chargenoprice="0"
               data-custname="">
        <div class="card-box-main">
          <div class="commodity-item-hd">
            <span class="commodity-item-title card-box-label">
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
      </div>
      </c:forEach>
    </div>
  </div>
  </c:if>
  <div class="card-box commodity-total">
    <div class="card-box-main">
      <label class="card-box-label">合计</label>
      <span class="commodity-total-price pull-right">￥0</span>
    </div>
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
<section class="popup-mask"></section>

<footer class="footer"><a class="button go-buy" href="javascript:window.location.replace('${ctx}/zzk/order')">立即购买</a></footer>
<script src="${ctx}/zzk/resource/zzk/js/jquery.min.js"> </script>
<script src="${ctx}/zzk/resource/zzk/js/fastclick.js"> </script>
<script src="${ctx}/zzk/resource/zzk/js/base.js"></script>
<script>
  jQuery(function(){
//    //初始化vouchers购物车
//    vouchers.init();
//
//    // alert(window.innerWidth);
//    //购物车商品
//    var vStore = vouchers.store;
//    console.log(vStore)
//    //按active排序后的商品id
//    var cardIds = vouchers.storeSorted();
//    console.log(cardIds);

    $("body").on("click", "#checkAll", function(){
      $('.commodity-lst .check-item').prop("checked", this.checked ?  "checked" : false);
      updateTotalPrice();
    });
    $("body").on("click", ".check-item", function(event){
      var $table = $(this).closest(".cart"), checked = false;
      event.stopPropagation();
      if(this.checked && ($table.find(".check-item:checked").length == $table.find(".check-item").length) ){
        checked = "checked";
      }
      $("#checkAll").prop("checked", checked);
      updateTotalPrice();
    });

    function updateTotalPrice(){
      var total = 0;
      $('.cart .check-item:checked').each(function(){
        total += $(this).data('price') * $(this).data('num');
        if($(this).data('pre')){
          total += $(this).data('pre') * $(this).data('num')
        }
        if($(this).data('discounttype') == '01'){
          total -= $(this).data('chargenoprice');
        }
      });

      $('.commodity-total-price').html('￥' + total);
    }

    //删除弹窗
    var pop1 = new Popup($('#delPopup'), {
      maskClose: true
    });

    $('.del-card').on('click', function(){
      var $checked = $('.commodity-lst .check-item:checked');
      if(!$checked.length){ return }
      pop1.show();
    })

    //删除
    $('.do-del').on('click', function(){

      var detailIds = new Array();
      var orderTypes = new Array();
      $('.commodity-lst .check-item:checked').each(function(){
        detailIds.push($(this).data('id'));
        orderTypes.push($(this).data('ordertype'));
      });

      $.ajax({
        url: '${ctx}/zzk/deleteCart',
        dataType: 'json',
        type: 'post',
        traditional :true,
        data: {
          detailIds: detailIds.join(','),
          orderTypes: orderTypes.join(',')
        }
      }).done(function(data){
        if(data.ret == 0){
          //从购物车中删除
          $('.commodity-lst .check-item:checked').each(function(){
            vouchers.remove($(this).data('id'));
          });
          $('.commodity-lst .check-item:checked').parent().remove();
          $('#checkAll').prop('checked', false);
          updateTotalPrice();

        }
      }).always(function(){
        $(this).data('ajax', null);
      });
      pop1.hide();
    });

    //立即购买
    $('.go-buy').on('click', function(event){
      var $checked = $('.commodity-lst .check-item:checked');
      var paystr = ''
      if(!$checked.length){
        event.preventDefault();
        return;
      }

      $checked.map(function(){return $(this).data('id')}).get().join();

      var orders = [];
      $checked.each(function(){
        var dataset = $(this).data();
        var totalprice = dataset.price + dataset.pre;
        if ($(this).attr('data-discounttype') == '01') {
            totalprice = totalprice - dataset.chargenoprice;
        }
        orders.push({
          id: dataset.id,
          pid: dataset.pid,
          ordertype: dataset.ordertype,
          packagename: dataset.packagename,
          num: dataset.num,
          title: dataset.title,
          totalprice: totalprice,
          prepay: dataset.pre,
          price: dataset.price,
          custname: dataset.custname,
          paperno: dataset.paperno,
          custtel: dataset.custtel,
          discounttype: $(this).attr('data-discounttype'),
          chargeno: $(this).attr('data-chargeno'),
          chargenoprice: dataset.chargenoprice
        });
      });
      //保存到本地
      localStorage.setItem('orders', JSON.stringify(orders));
    });

  });
</script>
</body>
</html>
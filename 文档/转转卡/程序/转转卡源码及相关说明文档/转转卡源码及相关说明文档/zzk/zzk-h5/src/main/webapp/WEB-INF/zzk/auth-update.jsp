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
    <title>身份确认</title>
    <link rel="stylesheet" href="${ctx}/zzk/resource/zzk/dest/base.css">
    <script src="${ctx}/zzk/resource/zzk/js/flexible.js"></script>
    <link rel="stylesheet" href="${ctx}/zzk/resource/zzk/dest/cropper.css">
</head>
<body>
  <section class="auth">
      <div class="auth-ready">
        <p>持卡人姓名：${custName}</p>
        <p>持卡人手机号：${custPhone}</p>
        <p>持卡人证件号码：${paperNo}</p>
      </div>
      <div class="auth-bottom">
        <div class="auth-bottom-title">上传头像</div>
        <div class="auth-avatar-upload">
          <div class="auth-avatar-hold">
            <div class="auth-avatar-pic"><img id="holder" src="${ctx}/zzk/resource/zzk/images/avatarholder.png" width="100%" height="100%"></div>
            <!-- <div class="auth-avatar-text">上传头像</div> -->
          </div>
          <div class="auth-avatar-info">注：头像为持卡人入园重要凭证，为了您能够顺利通过入园认
              证，请上传本人真实、并能予于辨认的头像。</div>
          <div class="auth-avatar-control">
            <input type="file" name="avatar" id="avatar" accept="image/*" >
          </div>
        </div>
      </div>
      <input type="hidden" id="avatarPath" name="avatarPath">
      <input type="hidden" id="custName" name="custName" value="${custName}">
      <input type="hidden" id="custPhone" name="custPhone" value="${custPhone}">
      <input type="hidden" id="paperNo" name="paperNo" value="${paperNo}">
  </section>
  <section class="popup transition" id="Popup">
    <div class="popup-inner">
      <div class="popup-content">确定要删除？</div>
      <div class="popup-action">
        <button class="btn btn-sm popup-cancel round"><span class="icn icn-cancel"></span>确定</button>
      </div>
    </div>
  </section>
  <section class="popup-mask"></section>
  <footer class="footer"><a class="button btn-auth" href="">更新照片</a></footer>
  <section id="cropperWrap" style="position: fixed;top: 0;bottom: 0;left: 0;right: 0;background: #fff;padding: 20px;z-index: 203;display: none;">
      <div class="text-center" style="margin-top: 20px;position: relative;z-index: 10001">
          <button class="btn round cropper-done" style="position: relative;z-index: 10001">裁切</button>
          <button class="btn round cropper-rotate" style="position: relative;z-index: 10001">旋转</button>
      </div>
      <div class="cropper-inner" style="margin-top: 20px;overflow: hidden;">
          <img src="" id="cropperImg" width="100%">
      </div>
  </section>
  <script src="${ctx}/zzk/resource/zzk/js/jquery.min.js"> </script>
  <script src="${ctx}/zzk/resource/zzk/js/fastclick.js"> </script>
  <script src="${ctx}/zzk/resource/zzk/js/base.js"></script>
  <script src="${ctx}/zzk/resource/zzk/js/cropper.js"></script>
  <script>
      jQuery(function(){
          var isNative = false; /*是否是客户端调用*/
          var postForm = new FormData();

          //提示弹窗
          var pop = new Popup($('#Popup'), {
              maskClose: true,
              closeAfter: function() {
                  if ($('.btn-sm').data('success')) {
                      window.location = '${ctx}/zzk/order-detail?orderNo=${orderNo}';
                  }
              }
          });

          var reader = new FileReader();
          reader.onload =  function(event){
              console.log(event);
              $('#holder').attr('src', event.target.result);
              $('#cropperImg').attr('src', event.target.result);
              APP.closeLoading();
              initCropper()

          }

          $('#avatar').on('change', function(){
              var file = this.files[0];

              if(!file){return false}

              /*微信等调用*/
              if(!isNative){
                 APP.showLoading();
                  reader.readAsDataURL(file);
              }
              postForm = new FormData();
//              postForm.append('file', file)

          });

          function uploadFile(callback){
              var  $this = $('#avatarPath');

              if($this.data('ajax')){ return  false }

              $this.data('ajax', true);
              $.ajax({
                  url: '${ctx}/zzk/uploadFile',
                  dataType: 'json',
                  type: 'post',
                  data: postForm,
                  processData: false,
                  contentType: false
              }).done(function(data){
                  //关闭加载器
                  APP.closeLoading();

                  //上传文件成功
                  if (data.ret == 0) {
                      callback && callback.call(null, data.data.filePath);
                  }
              }).always(function(){
                  $this.data('ajax', null);
              }).fail(function(res, xhr, e){
              })
          }

          $('.cropper-done').on('click', function(){
              if(!cropper){return false}

                //打开一个加载器
                APP.showLoading();
                $('#cropperWrap').hide();

                setTimeout(function(){
                    var base64Data = cropper.getCroppedCanvas().toDataURL('image/png');
                    $('#holder').attr('src', base64Data)
                    cropper.destroy();
                    postForm.append('metadata', base64Data);
                    uploadFile(function(filePath){
                        $('#avatarPath').val(filePath);
                    });
                }, 0);     
          });

          $('.cropper-rotate').on('click', function(){
              if(!cropper){return false}
              var data = cropper.rotate(90);
              console.log(data);
          });

          var cropper;
          function initCropper(){
              $('#cropperWrap').show();

              var image = document.getElementById('cropperImg');
              cropper = new Cropper(image, {
                  aspectRatio: 3 / 4,
                  crop: function(e) {
//                      console.log(e.detail.x);
//                      console.log(e.detail.y);
//                      console.log(e.detail.width);
//                      console.log(e.detail.height);
//                      console.log(e.detail.rotate);
//                      console.log(e.detail.scaleX);
//                      console.log(e.detail.scaleY);
                  },
                  checkOrientation: true
                  // cropend: function(e){
                  //   console.log(e);
                  // }
              });
          }

          //ajax demo
          $('.btn-auth').on('click', function(event){
              var  $this = $(this);
              event.preventDefault();

              if($this.data('ajax')){ return  false }

              var avatarPath = $('#avatarPath').val();
              if (!avatarPath) {
                  pop.updateContent('头像不能为空!').show();
                  return false;
              }

              //打开一个加载器
              APP.showLoading();
              $this.data('ajax', true);
              $.ajax({
                  url: '${ctx}/zzk/saveAuthUpdate',
                  dataType: 'json',
                  type: 'post',
                  data: {"orderNo":"${orderNo}",
                      "detailNo":"${detailNo}",
                      "custName":"${custName}",
                      "custPhone":"${custPhone}",
                      "paperNo":"${paperNo}",
                      "avatarPath":avatarPath
                  }
              }).done(function(data){

                  //关闭加载器
                  APP.closeLoading();

                  //更新成功
                  if (data.ret == 0) {
                      $('.btn-sm').data('success', true);
                      pop.updateContent("更新成功").show();
                  } else {
                      $('.btn-sm').data('success', null);
                      pop.updateContent("更新失败，重新上传").show();
                  }

              }).always(function(){
                  $this.data('ajax', null);

              }).fail(function(res, xhr, e){
              });

          });

      });
  </script>

</body>
</html>
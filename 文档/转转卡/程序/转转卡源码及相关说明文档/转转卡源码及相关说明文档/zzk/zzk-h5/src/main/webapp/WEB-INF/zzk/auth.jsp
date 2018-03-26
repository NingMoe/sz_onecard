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
    <link rel="stylesheet" href="${ctx}/zzk/resource/zzk/dest/base.css?v=2">
    <script src="${ctx}/zzk/resource/zzk/js/flexible.js"></script>
    <link rel="stylesheet" href="${ctx}/zzk/resource/zzk/dest/cropper.css">
</head>
<body>
<section class="auth">

    <div class="auth-top">
        <form action="${ctx}/zzk/buy-card" method="post">
            <div class="auth-top-info">为了保证您顺利办卡，请如实填写您的身份信息</div>
            <div class="form-group">
                <input class="form-control" type="text" name="name" maxlength="20" placeholder="请输入姓名" >
            </div>
            <div class="form-group">
                <input class="form-control" type="tel" name="phone" maxlength="11" placeholder="请输入手机号" >
            </div>
            <div class="form-group">
                <input class="form-control" type="text" name="idcard" id="idcard" placeholder="请输入有效证件号码" >
            </div>
            <input type="hidden" id="sp" name="sp" value="${sp}">
            <input type="hidden" id="avatarPath" name="avatarPath">
            <input class="hide" type="submit"  id="submit" value="提交">
        </form>
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
<footer class="footer"><a class="button btn-auth" href="${ctx}/zzk/buy-card">下一步 </a></footer>
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

        //证件号码只能输入数字和字母
        $("#idcard").on("keydown", function(e){if(!/[0-9a-zA-Z]/.test(e.key)){return false }});

        var isNative = false; /*是否是客户端调用*/
        var postForm = new FormData();

        //提示弹窗
        var pop = new Popup($('#Popup'), {
            maskClose: true
        });


        var reader = new FileReader();
        reader.onload =  function(event){
            console.log(event);
            $('#holder').attr('src', event.target.result);
            $('#cropperImg').attr('src', event.target.result);
            APP.closeLoading();
            initCropper();

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
//            postForm.append('file', file)

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



        //ajax demo
        $('.btn-auth').on('click', function(event){
            event.preventDefault();
            //提交form表单
            $('#submit').trigger('click');
        })
        $('.auth-top form').on('submit', function(){
            var  $this = $(this),
                    phone, name, idcard;


            if($this.data('ajax')){ return  false }

            phone = $('input[name=phone]').val();
            if(!phone || !APP.phoneReg.test(phone)){
                pop.updateContent('手机号不正确!').show();
                return false;
            }
            // postForm.set('phone', phone);

            name = $('input[name=name]').val();
            if(!name){
                pop.updateContent('姓名不能为空!').show();
                return false;
            }
            // postForm.set('name', name);

            idcard = $('input[name=idcard]').val();
//            if(!APP.idReg.test(idcard)){
//                pop.updateContent('身份证号不正确').show();
//                return false;
//            }
            if(!idcard){
                pop.updateContent('有效证件号码不能为空!').show();
                return false;
            }
            // postForm.set('idcard', idcard);

            if (!$('#avatarPath').val()) {
                pop.updateContent('头像不能为空!').show();
                return false;
            }


        });

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
//                    console.log(e.detail.x);
//                    console.log(e.detail.y);
//                    console.log(e.detail.width);
//                    console.log(e.detail.height);
//                    console.log(e.detail.rotate);
//                    console.log(e.detail.scaleX);
//                    console.log(e.detail.scaleY);
                },
                checkOrientation: true
                // cropend: function(e){
                //   console.log(e);
                // }
            });
        }

    });
</script>

</body>
</html>
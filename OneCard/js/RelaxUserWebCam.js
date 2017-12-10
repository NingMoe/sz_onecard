function loadWebcam() {
	$('#btnShowWebCam').attr('disabled','disabled');
    $("#webcam").webcam({
        width: 150,
        height: 200,
        mode: "save",
        swffile: "../../js/webcam/jscam_240320.swf",
        onSave: function (data) {
            var d = new Date();
            $('#preview_size_fake').attr('src', "../../tmp/pic_" + $('#hidStaffNo').val() + ".jpg?time=" + d.getUTCMilliseconds());
            MyExtHide();
        },
        onCapture: function () {
            var result = webcam.save("AS_RelaxUserWebCam.ashx");
        },
		onLoad: function() {
			$('#btnShowWebCam').attr('disabled',false);
		}
    });
}

function Capture() {
    MyExtShow('请等待', '正在处理中...');
    setTimeout('webcam.capture()', 200);
    return false;
}
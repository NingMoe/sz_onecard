$(function(){ 
	$("#webcam").webcam({ 
		width: 320,
		height: 240,
		mode: "save",
		swffile: "/Scripts/jscam.swf",
		onSave: function (data) {
		    $('#message').html('').html('拍照成功');
		    var d = new Date();
		    $('#webcamPic').attr('src', "/tmp/test.jpg?time=" + d.getUTCMilliseconds());
		}, 
		onCapture: function () { 
		    var result = webcam.save("/GetPic.ashx");

		}, 
		debug: function (type, string) {
			console.log(string); 
		} 
 
	}); 
});




function loadWebcam() {
    $("#webcam").webcam({
        width: 150,
        height: 200,
        mode: "save",
        swffile: "../../js/webcam/jscam_240320.swf",
        onSave: function (data) {
            var d = new Date();
            $('#preview_size_fake').attr('src', "../../tmp/pic_.jpg?time=" + d.getUTCMilliseconds());
        },
        onCapture: function () {
            var result = webcam.save("../../Handler.ashx");

        }
    });
}

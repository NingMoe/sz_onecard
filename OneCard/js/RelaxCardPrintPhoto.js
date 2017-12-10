 
function loadWebcam() { 
		var btnState = $('#btnShowWebCam').attr('disabled');
		if(!btnState){
			$('#btnShowWebCam').attr('disabled',true);
		} 
        $("#webcam").webcam({
            width: 150,
            height: 200,
            mode: "save",
            swffile: "../../js/webcam/jscam_240320.swf",
            onSave: function (data) {
                var d = new Date();
                $('#imgCustomerPic').attr('src', "../../tmp/printImg" + $('#hidStaffno').val() + ".jpg?time=" + d.getUTCMilliseconds());
                $('#hidIsCapture').val('1');
                MyExtHide();
            },
            onCapture: function () { 
                var result = webcam.save("AS_RelaxcardWebCam.ashx");
            },
            onLoad: function() {
				if(!btnState){
					$('#btnShowWebCam').attr('disabled',false);
				} 
			}
        });
        $('#webcamDiv').hide();
}


function Capture()
{
    MyExtShow('请等待', '正在处理中...');
    setTimeout('webcam.capture()',200);
    return false;
}

//切换模板
function ChangeTemplate(template) {
    $('.tdTemplate').css('background', '#FFFFFF');
    $('#tdTemplate' + template).css('background', '#E0E0E0'); 
    $('#rdoPrintTemplate' + template).attr("checked",true);
}

 

//打印点击事件
function PrintCard() {
    var cardTemplate;
    var templates = document.getElementsByName("rdoPrintTemplate");
    if ($('#hidIsCapture').val() == '1') {
        var d = new Date();
        $('#imgPrint').attr('src', "../../tmp/printImg" + $('#hidStaffno').val() + ".jpg?time=" + d.getUTCMilliseconds());
    } 
    for (var i = 0; i < templates.length; i++) {
        if (templates[i].checked) cardTemplate = (i + 1);
    }
    if (!cardTemplate) {
        MyExtAlert("警告", "请选择打印模板！"); 
    }
    else {
        PrintTemplate(cardTemplate);
        $('#btnPrint').attr("disabled", 'disabled');
    }
    return false;
}

//打印模板
function PrintTemplate(template) { 

    document.getElementById('divImg').className = 'juedui' + ' template' + template.toString();
   
    var headarr = [];
    headarr.push("<html><head><title>打印</title>");
    headarr.push("<style type='text/css'>");
    headarr.push(".juedui {");
    headarr.push("margin-left: 0px; ");
    headarr.push("margin-top:  0px;  ");
    headarr.push("margin-right: 0px;");
    headarr.push("margin-bottom: 0px;");
    headarr.push("background-repeat: no-repeat;");
    headarr.push("position: absolute; }");
    headarr.push(".template5{top:79px;left:210px;}");
    headarr.push(".template5 img{width:91px !important; height:111px !important;}");
    headarr.push(".template1{top:32px;left:22px;}");
    headarr.push(".template1 img{width:118px !important; height:148px !important;}");
    headarr.push(".template2{top:51px;left:10px;}");
    headarr.push(".template2 img{width:84px !important; height:117px !important;}");
    headarr.push(".template3{top:10px;left:214px;}");
    headarr.push(".template3 img{width:88px !important; height:108px !important;}");
    headarr.push(".template4{top:119px;left:22px;}");
    headarr.push(".template4 img{width:75px !important; height:75px !important;}");
    headarr.push(".template6{top:51px;left:214px;}");
    headarr.push(".template6 img{width:88px !important; height:108px !important;}");
    headarr.push("</style>");
    headarr.push("</head><body>");
    var headstr = headarr.join('');
    var footstr = "</body></html>";
    var newstr = document.all('PrintArea').innerHTML; 
    var printWin = open('', 'printWindow', 'left=50000,top=50000,width=375,height=220');
    printWin.document.write(headstr + newstr + footstr); 
    printWin.document.close();

    printWin.document.body.insertAdjacentHTML("beforeEnd", " \
        <object id=\"printFactory\" style=\"display:none\"   \
         classid=\"clsid:1663ED61-23EB-11D2-B92F-008048FDD814\"> \
        </object>");

    printWin.focus(); 
    
    printWin.print(); 
    printWin.close();

    if ($('#hidIsCapture').val() == '1')
        setTimeout("$('#btnSave').click()", 1000);
    return false;
}
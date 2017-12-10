$(document).ready(function () {
    MoveWindow();
})

function MoveWindow() {
    //拖动功能
    var _obj = "none";
    var pX = 0;
    var pY = 0;
    var eventX = 0;
    var eventY = 0;

    $("#window_Head").mousedown(function (evt) {
        eventX = evt.pageX;
        eventY = evt.pageY;

        _obj = "pop_up_box";

        pX = parseInt($("#pop_up_box").css("left")) - eventX;
        pY = parseInt($("#pop_up_box").css("top")) - eventY;
    });

    $("#window_Head").mousemove(function (evt) {
        eventX = evt.pageX;
        eventY = evt.pageY;

        if (_obj != "none") {
            $("#pop_up_box").css("left", pX + eventX);
            $("#pop_up_box").css("top", pY + eventY);
            event.returnValue = false;
        }
    });

    $("#window_Head").mouseup(function () {
        _obj = "none";
    });
}

function CreateWindow(id, url, l, t) {
    //设置窗口位置
    var height = $("#" + id + "").innerHeight();
    var width = $("#" + id + "").innerWidth();
    
    var left1 = parseInt(document.documentElement.clientWidth) / 2 - parseInt(width / 2);
    var top1 = (parseInt(document.documentElement.clientHeight) / 2 - (height / 2)) / 2;

    if (typeof l != "undefined") {
        left1 = l;
    }
    if (typeof t != "undefined") {
        top1 = t
    }

    $("#" + id + "").css("left", left1);
    $("#" + id + "").css("top", top1);

    if (url != null) {
        var iframe = "<iframe name='mainContent' src='" + url + "' width='100%' height='100%' frameborder='0' frameborder='0' scrolling='no' noresize='noresize'></iframe>";
        $("#" + id + "").append(iframe);
    }

    $("#" + id + "").fadeIn(500);

    //显示模式层
    var ModuleWindowDom = '<div id="ModuleWindow" style="width: 100%;height: 100px;background-color: Gray;position: absolute;z-index: 1;top: 0px;left: 0px;display: none;"></div>';
    $("body").append(ModuleWindowDom);
    $("#ModuleWindow").css("height", document.documentElement.clientHeight);
    $("#ModuleWindow").css("display", "block");
    $("#ModuleWindow").css("opacity", "0.6");
    return false;
}

function CloseWindow(id) {
    $("#" + id + "").fadeOut(500, function () {
        $("#ModuleWindow").css("display", "none");
        $("#ModuleWindow").remove();
    });
    if (id == "pop_up_box") {
        //清空输入框
        clearTxtVal("tt");
    }
    else {
        $("#" + id + "").html("");
    }
    return false;
}

function clearTxtVal(id) {
    $("input[type='text'][id^='" + id + "']").each(function (index) {
        $(this).val("");
    });
}

function AllSelect(object) {
    if ($(object).attr("checked") == true) {
        $("input[type='checkbox'][id$='toSelect']").attr("checked", "true");
    }
    if ($(object).attr("checked") == false) {
        $("input[type='checkbox'][id$='toSelect']").attr("checked", "");
    }
}

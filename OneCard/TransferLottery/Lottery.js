$(function () {
    var awards = $('#hidAward').val();
    var lottery = $('#hidLottery').val();
    if (lottery !== '1') {
        $('#divWinnerList').hide();
        if (lottery === '2') {
            $("#btnLottery").attr('disabled', true).css('background', 'gray');
        }
    }
    else {
        $('#divLottery').hide();
    }
    if ($('#hidShowAward').val() === '1') {
        $('#divAward').show();
    }
    $('.menu>li').each(function (i, n) {
        if (i.toString() === awards)
            $(n).addClass('active');
    });
    $('.tab ul.menu li').hover(function () {
        var Index = $(this).index() - 1;
        $(this).addClass('active').siblings().removeClass('active'); 
    }, function () {
        $(this).removeClass('active');
        $('.menu>li').eq(awards).addClass('active');
    });

 
    $("#btnLottery").click(function () {
        if ($('#hideLottery').val() === '0') {
            $("#btnLottery").attr('disabled', true).css('background', 'gray');
            $('#divProgressbar').hide();
            $('#divProgressbar').text('抽奖初始化中...');
            $('#divProgressbar').fadeIn(1000, function () { $('#banner').attr('src', 'images/03.gif'); });
            $.ajax({
                type: "POST",
                url: "DoLottery.aspx",
                data: "award=" + awards,
                success: function (msg) {
                    //console.log(msg);
                    if (msg === "1") { 
                        $('#hideLottery').val('1');
                        $('#btnLottery span').text('停止');
                        $('#divProgressbar').fadeOut(1000, function () {
                            $('#divProgressbar').text('正在抽奖中,请单击停止按钮结束抽奖');
                            $('#divProgressbar').fadeIn('1000');
                            $("#btnLottery").attr('disabled', false).css('background', '#226F97');;
                        });
                    }
                    else {
                        $('#divProgressbar').text('抽奖失败，请刷新页面.' + msg);
                    }
                }
            });
        }
        else {
            $("#btnLottery").hide();
            $('#divProgressbar').fadeOut(1000, function () {
                $('#divProgressbar').text('抽奖成功,正在生成中奖名单...');
                $('#divProgressbar').fadeIn(1000, function () {
                    $('#divWinnerList0').fadeIn(1500);
                    __doPostBack('linkShow', '');
                });
            });
        }
        return false;
    });

    $('#linkAward').toggle(function () {
        $('#divAward').show();
        $('#hidCardno').val($(this).attr('data-cardno'));
    }, function () {
        $('#divAward').hide();
    });


});
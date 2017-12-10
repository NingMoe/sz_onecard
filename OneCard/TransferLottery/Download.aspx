<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Download.aspx.cs" Inherits="TransferLottery_Download" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <meta charset="UTF-8" />
    <title>苏州市公共交通换乘抽奖活动--下载奖池数据</title>
    <meta name="keywords" content="苏州市公共交通换乘抽奖活动" />
    <meta name="description" content="苏州市公共交通换乘抽奖活动" />
    <link href="base.css" rel="stylesheet" />
    <link rel="stylesheet" type="text/css" href="prize.css" />
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
</head>
<body>
    <form id="form1" runat="server">
        <div class="head">
            <h1 class="logo">
                <a href="../TransferLottery/Lottery.aspx" title="苏州市社会保障·市民卡官方网站">苏州市社会保障·市民卡官方网站</a>
            </h1>
        </div>
        <asp:BulletedList ID="bulMsgShow" runat="server" />
        <script runat="server">public override void ErrorMsgShow() { ErrorMsgHelper(bulMsgShow); }</script>
        <div class="list-prize">
            <div class="bd">
                <div class="search-card">
                    <label for="" style="padding-right:20px">抽奖期数：</label>
                    <asp:DropDownList ID="ddlLotteryPeriod" runat="server"></asp:DropDownList> 
                    <p style="padding:10px 0 20px 0">
                        <asp:Button ID="btnDownlodad" runat="server" Text="下载" CssClass="input-btn" OnClick="btnDownlodad_Click" />
                    </p>
                </div>
            </div>
        </div> 
        <div class="wrap footer">
            <p>主办单位： 苏州市交通局&nbsp;&nbsp;&nbsp;&nbsp; </p>
        </div>
    </form>
</body>
</html>

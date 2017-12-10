<%@ Page Language="C#" AutoEventWireup="true" CodeFile="ChangePWD.aspx.cs" Inherits="TransferLottery_ChangePWD" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta charset="UTF-8" />
    <title>修改密码</title>
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
                    <label for="" style="padding-right:20px">原密码：</label>
                    <asp:TextBox ID="txtOPwd" TextMode="password" runat="server" CssClass="input-txt" MaxLength="20"></asp:TextBox>
                    <label for="" style="padding-right:20px">新密码：</label>
                    <asp:TextBox ID="txtNPwd" runat="server" TextMode="password"  CssClass="input-txt" MaxLength="20"></asp:TextBox>
                    <label for="">新密码确认：</label>
                    <asp:TextBox ID="txtANPwd" TextMode="password" runat="server" CssClass="input-txt" MaxLength="20"></asp:TextBox>
                    <p style="padding:10px 0 20px 0">
                        <asp:Button ID="btnChangePassword" runat="server" Text="修改" CssClass="input-btn" OnClick="btnChangePassword_Click" />
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

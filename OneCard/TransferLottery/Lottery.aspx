<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Lottery.aspx.cs" Inherits="TransferLottery_Lottery" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta charset="UTF-8" />
    <title>苏州市公共交通换乘抽奖活动</title>
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
                <a href="Lottery.aspx" title="苏州市社会保障·市民卡官方网站">苏州市社会保障·市民卡官方网站</a>
            </h1>
        </div>
        <div class="list-prize">
            <div class="hd">
                <asp:DropDownList ID="ddlLotteryPeriod" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlLotteryPeriod_SelectedIndexChanged"></asp:DropDownList>
                <h2>开奖期数:<asp:Label ID="lblPeriod" runat="server"></asp:Label></h2>
                <asp:HiddenField ID="hidAward" runat="server" />
                <asp:HiddenField ID="hidLottery" runat="server" />
                <asp:HiddenField ID="hidShowAward" runat="server" />
            </div>
            <div class="bd">
                <div class="tab">
                    <ul class="menu">
                        <li>
                            <asp:LinkButton ID="linkAward0" runat="server" OnClick="linkAward0_Click">特等奖</asp:LinkButton></li>
                        <li>
                            <asp:LinkButton ID="linkAward1" runat="server" OnClick="linkAward1_Click">一等奖</asp:LinkButton></li>
                        <li>
                            <asp:LinkButton ID="linkAward2" runat="server" OnClick="linkAward2_Click">二等奖</asp:LinkButton></li>
                        <li>
                            <asp:LinkButton ID="linkAward3" runat="server" OnClick="linkAward3_Click">三等奖</asp:LinkButton></li>
                    </ul>
                    <div class="content">
                        <asp:BulletedList ID="bulMsgShow" runat="server" />
                        <script runat="server">public override void ErrorMsgShow() { ErrorMsgHelper(bulMsgShow); }</script>
                        <div id="divLottery">
                            <div id="divProgressbar">
                                请单击抽奖按钮开始抽奖
                            </div>
                            <div id="progressbar">
                                <img id="banner" src="images/05.jpg" />
                            </div>
                            <button id="btnLottery" role="button"><span class="ui-button-text">抽奖</span></button>
                            <input type="hidden" id="hideLottery" value="0" />
                        </div>
                        <asp:LinkButton ID="linkShow" runat="server" CssClass="hide" OnClick="linkShow_Click"></asp:LinkButton>
                        <div id="divWinnerList">
                            <asp:Literal ID="litWinnerList" runat="server" EnableViewState="false"></asp:Literal>
                            <div class="search-card" id="divAward" style="display: none">
                                <table>
                                    <tr> 
                                        <td style="text-align:center;padding-right:20px" colspan="2">
                                            <label for="">充值卡卡号（逗号分隔）：</label>
                                          <asp:TextBox ID="txtChargeCard" runat="server" CssClass="input-long" MaxLength="100"></asp:TextBox></td>
                                    </tr>
                                    <tr> 
                                        <td style="text-align:right;padding-right:20px">
                                            <label for="">领奖人证件类型：</label>
                                            <asp:DropDownList ID="selPapertype" runat="server"></asp:DropDownList></td>
                                        <td style="text-align:left;">
                                            <label for="">领奖人证件号码：</label>
                                            <asp:TextBox ID="txtCustpaperno" runat="server" CssClass="input-txt" MaxLength="20"></asp:TextBox></td>
                                    </tr>
                                    <tr>
                                        <td style="text-align:right;padding-right:20px">
                                            <label for="">领奖人姓名：</label>
                                            <asp:TextBox ID="txtCusname" runat="server" CssClass="input-txt" MaxLength="25"></asp:TextBox></td>
                                        <td style="text-align:left;">
                                            <label for="">领奖人电话号码：</label>
                                            <asp:TextBox ID="txtCustphone" runat="server" CssClass="input-txt" MaxLength="20"></asp:TextBox>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td colspan="2" style="height:50px">
                                            <asp:HiddenField ID="hidCardno" runat="server" />
                                            <asp:Button ID="btnAward" runat="server" Text="领奖登记" CssClass="input-btn" OnClick="btnAward_Click" />
                                        </td>
                                    </tr>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="wrap footer">
            <p>主办单位： 苏州市交通局&nbsp;&nbsp;&nbsp;&nbsp;<a href="ChangePWD.aspx">修改密码</a> <a href="Download.aspx">下载抽奖数据</a></p>
        </div>
    </form>
</body>
<script src="jquery-1.5.min.js"></script>
<script src="Lottery.min.js"></script>
</html>

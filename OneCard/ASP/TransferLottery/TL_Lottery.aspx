<%@ Page Language="C#" AutoEventWireup="true" CodeFile="TL_Lottery.aspx.cs" Inherits="ASP_TransferLottery_TL_Lottery" %>
<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="../../js/myext.js"></script>
    <script type="text/javascript" src="../../js/print.js"></script>
    <title>换乘抽奖</title>
    <script type="text/javascript">
        function mover() {
            //去除相邻节点样式
            var object_nav = arguments[0].parentElement.parentElement;
            for (var i = 0; i < object_nav.children.length; ++i) {
                var object_cld = object_nav.children[i].children[0];
                object_cld.children[0].style.color = "#000";
                object_cld.className = null;

            }

            //当前节点添加样式
            arguments[0].className = "on";
            arguments[0].children[0].style.color = "#fff";
            arguments[0].children[0].style.cursor = "pointer";
        }

        function mout() {
            var cardname = 'tagAward' + $get('hidAward').value.toString();
            var object = document.getElementById(cardname);
            mover(object);
        }
        function Init() {
            var logo = parent.parent.frames[0].document.getElementById('logo');
            logo.style.backgroundImage = 'url(Images/welcomein_tl.gif)';
            parent.parent.frames[0].StopTimeout();
        }
    </script>
</head>
<body onload="Init()"> 
    <form id="form1" runat="server">
        <div class="tb">
            换乘抽奖->抽奖
        </div>
        <ajaxToolkit:ToolkitScriptManager runat="Server" EnableScriptGlobalization="true"
            EnableScriptLocalization="true" ID="ToolkitScriptManager1" />
        <script type="text/javascript" language="javascript">
            var swpmIntance = Sys.WebForms.PageRequestManager.getInstance();
            swpmIntance.add_initializeRequest(BeginRequestHandler);
            swpmIntance.add_pageLoading(EndRequestHandler);
            function BeginRequestHandler(sender, args) {
                try { MyExtShow('请等待', '正在提交后台处理中...'); } catch (ex) { }
            }
            function EndRequestHandler(sender, args) {
                try { MyExtHide(); } catch (ex) { }
            }
        </script>
        <asp:UpdatePanel ID="UpdatePanel1" UpdateMode="Conditional" runat="server">
            <ContentTemplate>
                <asp:BulletedList ID="bulMsgShow" runat="server" />
                <script runat="server">public override void ErrorMsgShow() { ErrorMsgHelper(bulMsgShow); }</script>
                <asp:HiddenField ID="hidAward" runat="server" />
                <div style="height: 22px">
                    <table>
                        <tr>
                            <td width="10%"></td>
                            <td align="center">
                                <ul class="nav_list">
                                    <li>
                                        <asp:LinkButton ID="tagAward0" runat="server" onmouseover="mover(this);"
                                            onmouseout="mout();" OnClick="tagAward0_Click"><span class="signA">特等奖</span></asp:LinkButton></li>
                                    <li>
                                        <asp:LinkButton ID="tagAward1" runat="server" onmouseover="mover(this);"
                                            onmouseout="mout();" OnClick="tagAward1_Click"><span class="signB">一等奖</span></asp:LinkButton></li>
                                    <li>
                                        <asp:LinkButton ID="tagAward2" runat="server" onmouseover="mover(this);"
                                            onmouseout="mout();" OnClick="tagAward2_Click"><span class="signB">二等奖</span></asp:LinkButton></li>
                                    <li>
                                        <asp:LinkButton ID="tagAward3" runat="server" onmouseover="mover(this);"
                                            onmouseout="mout();" OnClick="tagAward3_Click"><span class="signB">三等奖</span></asp:LinkButton></li>
                                </ul>
                            </td>
                        </tr>
                    </table>
                </div>
                <div class="con">
                    <div class="card">
                        抽奖
                    </div>
                    <div class="kuang5" style="text-align: left">
                        <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                            <tr>
                                <td width="10%">
                                    <div align="right">
                                        开奖期数:
                                    </div>
                                </td>
                                <td width="15%">
                                    <asp:Label ID="lblPeriod" runat="server" />
                                </td>
                                <td width="10%">
                                    <div align="right">
                                        开奖奖项:
                                    </div>
                                </td>
                                <td width="15%">
                                    <asp:Label ID="lblAward" runat="server" />
                                </td>
                                <td width="10%">
                                    <div align="right">
                                        抽奖时间:
                                    </div>
                                </td>
                                <td>
                                    <asp:Label ID="lblLotteryTime" runat="server" />
                                </td>
                            </tr>
                            <tr>
                                <td colspan="6" align="right">
                                    <asp:Button ID="btnLottery" CssClass="button1" runat="server" Text="抽奖" Enabled="false" OnClick="btnLottery_Click" />
                                </td>
                            </tr>
                        </table>
                    </div>
                    <div class="jieguo">
                        中奖名单
                    </div>
                    <div class="kuang5 ">
                        <div class="gdtbfix" style="height: 280px; overflow: auto; display: block; padding-left: 20px">
                            <div id="printArea">
                            <asp:Label ID="lalTitle" runat="server" ></asp:Label>
                            <table class="tab2" id="gvResult" style="width: 95%; border-collapse: collapse;" border="1" rules="all" cellspacing="0">
                                <tbody>
                                    <tr class="tabbt">
                                        <th>卡号</th>
                                        <th>卡号</th>
                                        <th>卡号</th>
                                        <th>卡号</th>
                                        <th>卡号</th>
                                        <th>卡号</th>
                                        <th>卡号</th> 
                                    </tr>
                                    <asp:Literal ID="litWinnerList" runat="server" EnableViewState="false"></asp:Literal>
                                </tbody>
                            </table>
                            </div>
                        </div>
                        <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                            <tr>
                                <td  align="right">
                                    <asp:Button ID="btnPrint" Width="100" Text="打印中奖名单" CssClass="button1" runat="server" Enabled="false" OnClientClick="return printGridView('printArea');" /></td>
                            </tr>
                        </table>

                    </div>
                </div>
                <div class="footall">
                </div> 
            </ContentTemplate>
        </asp:UpdatePanel>
    </form>
</body>
</html>

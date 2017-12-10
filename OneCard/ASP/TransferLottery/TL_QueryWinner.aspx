<%@ Page Language="C#" AutoEventWireup="true" CodeFile="TL_QueryWinner.aspx.cs" Inherits="ASP_TransferLottery_TL_QueryWinner" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="../../js/myext.js"></script>
    <script type="text/javascript" src="../../js/print.js"></script>
    <script type="text/javascript">
        function printDiv(award, awardTitle) {
            $get('lblTitle' + award).innerHTML = $get('ddlLotteryPeriod').value + ' ' + awardTitle + '中奖名单';
            return printGridView('printArea' + award);
        } 
    </script>
    <style type="text/css">
        .forprint
        {
            display:none;
        }
        @media print
        {
            .forprint
            {
                display:block;
            }
        }
    </style>
    <title>换乘奖励->中奖名单</title>
</head>
<body>
    <form id="form1" runat="server">
        <div class="tb">
            换乘奖励->中奖名单
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
                <div>
                    <table>
                        <tr>
                            <td width="10%"></td>
                            <td align="left" valign="middle" height="30">抽奖期数：
                    <asp:DropDownList CssClass="input" ID="ddlLotteryPeriod" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlLotteryPeriod_SelectedIndexChanged"></asp:DropDownList>
                            </td>
                        </tr>
                    </table>
                </div>
                <div class="con">
                    <div class="jieguo">
                        <table width="95%" border="0" cellpadding="0" cellspacing="0">
                            <tr>
                                <td>特等奖</td>
                                <td align="right">
                                    <asp:Button ID="btnPrint" Width="100" Text="打印" CssClass="button1" runat="server" OnClientClick="return printDiv('0','特等奖');" /></td>
                            </tr>
                        </table>
                    </div>
                    <div class="kuang5 ">
                        <div class="gdtbfix" style="height: 200px; overflow: auto; display: block; padding-left: 20px">
                            <div id="printArea0">
                                <span id="lblTitle0" class="forprint"></span>
                                <table class="tab2" id="gvResult0" style="width: 95%; border-collapse: collapse;" border="1" rules="all" cellspacing="0">
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
                                        <asp:Literal ID="litWinnerList0" runat="server" EnableViewState="false"></asp:Literal>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>

                    <div class="jieguo">
                        <table width="95%" border="0" cellpadding="0" cellspacing="0">
                            <tr>
                                <td>一等奖</td>
                                <td align="right">
                                    <asp:Button ID="Button1" Width="100" Text="打印" CssClass="button1" runat="server" OnClientClick="return printDiv('1','一等奖');" /></td>
                            </tr>
                        </table>
                    </div>
                    <div class="kuang5 ">
                        <div class="gdtbfix" style="height: 200px; overflow: auto; display: block; padding-left: 20px">
                            <div id="printArea1">
                                <span id="lblTitle1" class="forprint"></span>
                                <table class="tab2" id="gvResult1" style="width: 95%; border-collapse: collapse;" border="1" rules="all" cellspacing="0">
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
                                        <asp:Literal ID="litWinnerList1" runat="server" EnableViewState="false"></asp:Literal>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                    <div class="jieguo">
                        <table width="95%" border="0" cellpadding="0" cellspacing="0">
                            <tr>
                                <td>二等奖</td>
                                <td align="right">
                                    <asp:Button ID="Button2" Width="100" Text="打印" CssClass="button1" runat="server" OnClientClick="return printDiv('2','二等奖');" /></td>
                            </tr>
                        </table>
                    </div>
                    <div class="kuang5 ">
                        <div class="gdtbfix" style="height: 200px; overflow: auto; display: block; padding-left: 20px">
                            <div id="printArea2">
                                <span id="lblTitle2" class="forprint"></span>
                                <table class="tab2" id="gvResult2" style="width: 95%; border-collapse: collapse;" border="1" rules="all" cellspacing="0">
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
                                        <asp:Literal ID="litWinnerList2" runat="server" EnableViewState="false"></asp:Literal>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                    <div class="jieguo">
                        <table width="95%" border="0" cellpadding="0" cellspacing="0">
                            <tr>
                                <td>三等奖</td>
                                <td align="right">
                                    <asp:Button ID="Button3" Width="100" Text="打印" CssClass="button1" runat="server" OnClientClick="return printDiv('3','三等奖');" /></td>
                            </tr>
                        </table>
                    </div>
                    <div class="kuang5 ">
                        <div class="gdtbfix" style="height: 200px; overflow: auto; display: block; padding-left: 20px">
                            <div id="printArea3">
                                <span id="lblTitle3" class="forprint"></span>
                                <table class="tab2" id="gvResult3" style="width: 95%; border-collapse: collapse;" border="1" rules="all" cellspacing="0">
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
                                        <asp:Literal ID="litWinnerList3" runat="server" EnableViewState="false"></asp:Literal>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="footall">
                </div>
            </ContentTemplate>
        </asp:UpdatePanel>
    </form>
</body>
</html>

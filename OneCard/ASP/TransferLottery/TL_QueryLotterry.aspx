<%@ Page Language="C#" AutoEventWireup="true" CodeFile="TL_QueryLotterry.aspx.cs" Inherits="ASP_TransferLottery_TL_QueryLotterry" %>
<%@ Register Src="../../CardReader.ascx" TagName="CardReader" TagPrefix="cr" %>
<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="../../js/myext.js"></script>
    <title>奖励资格查询</title>
</head>
<body>
    <cr:CardReader ID="cardReader" runat="server" />
    <form id="form1" runat="server">
        <div class="tb">
            换乘奖励->奖励资格查询
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
                <div class="con">
                    <div class="card">
                        查询
                    </div>
                    <div class="kuang5" style="text-align: left">
                        <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                            <tr>
                                <td width="15%">
                                    <div align="right">
                                        卡号:
                                    </div>
                                </td>
                                <td width="15%">
                                    <asp:TextBox runat="server" ID="txtCardno" CssClass="input" MaxLength="16"></asp:TextBox>
                                </td>
                                <td width="15%"> <div align="right">抽奖期数:</div></td>
                                <td width="15%">
                                    <asp:DropDownList CssClass="input" ID="ddlLotteryPeriod" runat="server"></asp:DropDownList></td>
                                <td align="right">
                                    <asp:Button ID="btnQuery" CssClass="button1" runat="server" Text="读卡" OnClientClick="return ReadCardInfo()"
                                        OnClick="btnReadCard_Click" />
                                    <asp:Button ID="btnQueryDB" CssClass="button1" runat="server" Text="查询" OnClick="btnReadCard_Click" />
                                    <asp:HiddenField ID="hiddencMoney" runat="server" />
                                    <asp:HiddenField ID="hiddentradeno" runat="server" />
                                    <asp:HiddenField ID="hidSupplyFee" runat="server" />
                                    <asp:HiddenField ID="hidSupplyOtherFee" runat="server" />
                                    <asp:HiddenField ID="hidSupplyMoney" runat="server" />
                                    <asp:HiddenField ID="hideCardno" runat="server" />
                                    <asp:HiddenField runat="server" ID="hidCardReaderToken" />
                                </td>
                            </tr>
                        </table>
                    </div>
                    <div class="jieguo">
                        查询结果
                    </div>
                    <div class="kuang5">
                        <div id="divResult" style="height: 180px; overflow: auto; display: block">
                            <asp:GridView ID="gvResult" runat="server" Width="98%" CssClass="tab1"
                                HeaderStyle-CssClass="tabbt" FooterStyle-CssClass="tabcon" AlternatingRowStyle-CssClass="tabjg"
                                SelectedRowStyle-CssClass="tabsel" AutoGenerateColumns="false">
                                <Columns>
                                    <asp:BoundField DataField="卡号" HeaderText="卡号" />
                                    <asp:BoundField DataField="卡类型" HeaderText="卡类型" />
                                    <asp:BoundField DataField="换乘次数" HeaderText="换乘次数" />
                                    <asp:BoundField DataField="抽奖标识" HeaderText="抽奖标识" /> 
                                </Columns>
                                <EmptyDataTemplate>
                                    <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                        <tr class="tabbt">
                                            <td>卡号 
                                            </td>
                                            <td>卡类型 
                                            </td>
                                            <td>换乘次数
                                            </td>
                                            <td>抽奖标识 
                                            </td> 
                                        </tr>
                                    </table>
                                </EmptyDataTemplate>
                            </asp:GridView>
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

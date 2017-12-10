<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PN_QueryFinance.aspx.cs"
    Inherits="ASP_ProvisionNote_PN_QueryFinance" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>出入金查询</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <script type="text/javascript" src="../../js/print.js"></script>
    <script type="text/javascript" src="../../js/myext.js"></script>
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
    <div class="tb">
        备付金管理->出入金查询
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
    <asp:UpdatePanel ID="UpdatePanel2" runat="server">
        <ContentTemplate>
            <!-- #include file="../../ErrorMsg.inc" -->
            <div class="con">
                <div class="card">
                    查询</div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td>
                                <div align="right">
                                    开始日期:</div>
                            </td>
                            <td>
                                <asp:TextBox runat="server" ID="txtFromDate" MaxLength="8" CssClass="input"></asp:TextBox>
                                -
                                <asp:TextBox runat="server" ID="txtToDate" MaxLength="8" CssClass="input"></asp:TextBox>
                                <ajaxToolkit:CalendarExtender ID="FCalendar1" runat="server" TargetControlID="txtFromDate"
                                    Format="yyyyMMdd" />
                                <ajaxToolkit:CalendarExtender ID="FCalendar2" runat="server" TargetControlID="txtToDate"
                                    Format="yyyyMMdd" />
                            </td>
                            <td>
                                <div align="right">
                                </div>
                            </td>
                            <td>
                            </td>
                            <td>
                                <div align="right">
                                </div>
                            </td>
                            <td>
                            </td>
                            <td align="right">
                                <asp:Button ID="Button1" CssClass="button1" runat="server" Text="查询" OnClick="btnQuery_Click" />
                            </td>
                        </tr>
                    </table>
                </div>
                <table border="0" width="95%">
                    <tr>
                        <td align="left">
                            <div class="jieguo">
                                查询结果</div>
                        </td>
                        <td align="right">
                            <asp:Button ID="btnExport" CssClass="button1" runat="server" Text="下载" OnClick="btnExport_Click"
                                Enabled="true" />
                        </td>
                    </tr>
                </table>
                <asp:HiddenField ID="hidBankName" runat="server" />
                <asp:HiddenField ID="hidSystemName" runat="server" />
                <div id="printarea" class="kuang5">
                    <div id="gdtbfix" style="height: 380px; overflow: auto;">
                        <asp:GridView ID="gvResult" runat="server" Width="95%" CssClass="tab2" HeaderStyle-CssClass="tabbt"
                            FooterStyle-CssClass="tabcon" AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel"
                            PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top"
                            OnSelectedIndexChanged="gvResult_SelectedIndexChanged" AutoGenerateColumns="false"
                            OnRowDataBound="gvResult_RowDataBound" OnRowCreated="gvResult_RowCreated" ShowFooter="true">
                            <Columns>
                                <asp:BoundField HeaderText="日期" DataField="FILEDATE" />
                                <asp:BoundField HeaderText="入账总金额" DataField="INMONEY" />
                                <asp:BoundField HeaderText="出帐总金额" DataField="OUTMONEY" />
                                <asp:BoundField HeaderText="银行未达账金额" DataField="BANKLESS" />
                                <asp:BoundField HeaderText="业务未达账金额" DataField="BUSINESSLESS" />
                            </Columns>
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                        <td width="8%">
                                            日期
                                        </td>
                                        <td width="8%">
                                            入账总金额
                                        </td>
                                        <td width="5%">
                                            出帐总金额
                                        </td>
                                        <td width="5%">
                                            银行未达账金额
                                        </td>
                                        <td width="8%">
                                            业务未达账金额
                                        </td>
                                    </tr>
                                </table>
                            </EmptyDataTemplate>
                        </asp:GridView>
                    </div>
                </div>
                <div class="card">
                    详细信息</div>
                <div id="Div1" class="kuang5">
                    <div id="Div2" style="height: 380px">
                        <asp:GridView ID="gvDetail" runat="server" Width="100%" CssClass="tab2" HeaderStyle-CssClass="tabbt"
                            FooterStyle-CssClass="tabcon" AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel"
                            PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top"
                            AutoGenerateColumns="false" OnRowDataBound="gvDetail_RowDataBound" AllowPaging="true"
                            PageSize="50" OnPageIndexChanging="gvDetail_Page">
                            <Columns>
                                <asp:BoundField HeaderText="业务日期" DataField="TRADEDATE" />
                                <asp:BoundField HeaderText="匹配金额" DataField="MONEY" />
                                <asp:BoundField HeaderText="银行账单号" DataField="BANKTRADEID" />
                                <asp:BoundField HeaderText="系统账单号" DataField="TRADEID" />
                                <asp:BoundField HeaderText="银行名称" DataField="SYSTEMNAME" />
                                <asp:BoundField HeaderText="银行帐号" DataField="BANKACCOUNT" />
                                <asp:BoundField HeaderText="银行业务类型" DataField="TRADENAME" />
                                <asp:BoundField HeaderText="银行业务摘要" DataField="TRADEMEG" />
                                <asp:BoundField HeaderText="业务交易对象" DataField="NAME" />
                                <asp:BoundField HeaderText="业务交易类型" DataField="TRADETYPE" />
                            </Columns>
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                        <td>
                                            业务日期
                                        </td>
                                        <td>
                                            匹配金额
                                        </td>
                                        <td>
                                            银行账单号
                                        </td>
                                        <td>
                                            系统账单号
                                        </td>
                                        <td>
                                            银行名称
                                        </td>
                                        <td>
                                            银行帐号
                                        </td>
                                        <td>
                                            银行业务类型
                                        </td>
                                        <td>
                                            银行业务摘要
                                        </td>
                                        <td>
                                            业务交易对象
                                        </td>
                                        <td>
                                            业务交易类型
                                        </td>
                                    </tr>
                                </table>
                            </EmptyDataTemplate>
                        </asp:GridView>
                    </div>
                </div>
            </div>
        </ContentTemplate>
        <Triggers>
            <asp:PostBackTrigger ControlID="btnExport" />
        </Triggers>
    </asp:UpdatePanel>
    </form>
</body>
</html>

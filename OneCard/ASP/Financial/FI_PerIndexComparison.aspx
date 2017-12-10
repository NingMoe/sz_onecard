<%@ Page Language="C#" AutoEventWireup="true" CodeFile="FI_PerIndexComparison.aspx.cs" Inherits="ASP_Financial_FI_PerIndexComparison" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>指标对比表</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <script type="text/javascript" src="../../js/print.js"></script>
    <script type="text/javascript" src="../../js/myext.js"></script>
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
        <div class="tb">
            财务管理->指标对比表
        </div>
        <ajaxToolkit:ToolkitScriptManager runat="Server" EnableScriptGlobalization="true"
            AsyncPostBackTimeout="600"
            EnableScriptLocalization="true" ID="ScriptManager2" />
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

                    <div class="card">查询</div>
                    <div class="kuang5">
                        <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                            <tr>
                                <td>
                                    <div align="right">汇总年月:</div>
                                </td>
                                <td>
                                    <asp:TextBox runat="server" ID="txtStatMonth" MaxLength="6" CssClass="input"></asp:TextBox>
                                    <ajaxToolkit:CalendarExtender ID="FCalendar1" runat="server" TargetControlID="txtStatMonth" Format="yyyyMM" />
                                </td>
                                <td align="center">
                                    <asp:Button ID="Button1" CssClass="button1" runat="server" Text="查询" OnClick="btnQuery_Click" />
                                </td>
                            </tr>
                        </table>
                    </div>
                    <div id="printarea" class="kuang5">
                        <div id="gdtbfix" style="height: 600px">
                            <table id="printReport" width="95%">
                                <tr align="center">
                                    <td style="font-size: 16px; font-weight: bold">指标对比表</td>
                                </tr>
                            </table>
                            <asp:GridView ID="gvResult" runat="server"
                                Width="95%"
                                CssClass="tab2"
                                HeaderStyle-CssClass="tabbt"
                                FooterStyle-CssClass="tabcon"
                                AlternatingRowStyle-CssClass="tabjg"
                                SelectedRowStyle-CssClass="tabsel"
                                PagerSettings-Mode="NumericFirstLast"
                                PagerStyle-HorizontalAlign="left"
                                PagerStyle-VerticalAlign="Top"
                                AutoGenerateColumns="false" ShowHeader="False"
                                ShowFooter="false" OnRowCreated="gvResult_OnRowCreated">
                                <Columns>
                                    <asp:BoundField DataField="Index" HeaderStyle-Width="200px" HeaderText="指标" />
                                    <asp:BoundField DataField="LastYear" HeaderStyle-Width="200px" HeaderText="" />
                                    <asp:BoundField DataField="LastYearMonth" HeaderStyle-Width="200px" HeaderText="" />
                                    <asp:BoundField DataField="ThisYear" HeaderStyle-Width="200px" HeaderText="" />
                                </Columns>
                            </asp:GridView>
                            <asp:GridView ID="gvMerchant" runat="server"
                                Width="95%"
                                CssClass="tab2"
                                HeaderStyle-CssClass="tabbt"
                                FooterStyle-CssClass="tabcon"
                                AlternatingRowStyle-CssClass="tabjg"
                                SelectedRowStyle-CssClass="tabsel"
                                PagerSettings-Mode="NumericFirstLast"
                                PagerStyle-HorizontalAlign="left"
                                PagerStyle-VerticalAlign="Top"
                                AutoGenerateColumns="false"
                                ShowHeader="true"
                                ShowFooter="false">
                                <Columns>
                                    <asp:BoundField DataField="group_no" HeaderStyle-Width="200px" HeaderText="七：前十大商户及对应佣金比例（按收取佣金金额排序）" />
                                    <asp:BoundField DataField="Merchant1" HeaderStyle-Width="100px" HeaderText="商户" />
                                    <asp:BoundField DataField="Slope1" HeaderStyle-Width="100px" HeaderText="佣金比例" />
                                    <asp:BoundField DataField="Merchant2" HeaderStyle-Width="100px" HeaderText="商户" />
                                    <asp:BoundField DataField="Slope2" HeaderStyle-Width="100px" HeaderText="佣金比例" />
                                    <asp:BoundField DataField="Merchant3" HeaderStyle-Width="100px" HeaderText="商户" />
                                    <asp:BoundField DataField="Slope3" HeaderStyle-Width="100px" HeaderText="佣金比例" />
                                </Columns>
                            </asp:GridView>
                        </div>
                    </div>
                </div>
            </ContentTemplate>
        </asp:UpdatePanel>
    </form>
</body>
</html>

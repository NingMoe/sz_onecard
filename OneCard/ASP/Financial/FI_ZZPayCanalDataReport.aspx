<%@ Page Language="C#" AutoEventWireup="true" CodeFile="FI_ZZPayCanalDataReport.aspx.cs"
    Inherits="ASP_Financial_FI_ZZPayCanalDataReport" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>转转卡销售渠道统计</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <script type="text/javascript" src="../../js/print.js"></script>
    <script type="text/javascript" src="../../js/myext.js"></script>
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
    <div class="tb">
        财务管理->转转卡销售渠道统计
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
                                <ajaxToolkit:CalendarExtender ID="FCalendar1" runat="server" TargetControlID="txtFromDate"
                                    Format="yyyyMMdd" />
                            </td>
                            <td>
                                <div align="right">
                                    结束日期:</div>
                            </td>
                            <td colspan="3">
                                <asp:TextBox runat="server" ID="txtToDate" MaxLength="8" CssClass="input"></asp:TextBox>
                                <ajaxToolkit:CalendarExtender ID="FCalendar2" runat="server" TargetControlID="txtToDate"
                                    Format="yyyyMMdd" />
                            </td>
                            <td>
                                <div align="right">
                                    支付渠道:</div>
                            </td>
                            <td>
                                <asp:DropDownList ID="selTradeType" CssClass="inputmid" runat="server">
                                    <asp:ListItem Text="---请选择---" Value="" />
                                    <asp:ListItem Text="01:支付宝" Value="01" />
                                    <asp:ListItem Text="02:微信" Value="02" />
                                    <asp:ListItem Text="03:银联" Value="03" />
                                    <asp:ListItem Text="04:兑换券" Value="04" />
                                    <asp:ListItem Text="05:旅游局" Value="05" />
                                </asp:DropDownList>
                            </td>
                            <td>
                                <div align="right">
                                    </div>
                            </td>
                            <td>
                            </td>
                            <td>
                            </td>
                            <td align="right">
                                <asp:Button ID="Button1" CssClass="button1" runat="server" Text="查询" OnClick="btnQuery_Click" />
                            </td>
                        </tr>
                        <tr>
                        </tr>
                    </table>
                </div>
                <asp:HiddenField ID="hidNo" runat="server" Value="" />
                <table border="0" width="95%">
                    <tr>
                        <td align="left">
                            <div class="jieguo">
                                查询结果</div>
                        </td>
                        <td align="right">
                            <asp:Button ID="btnExport" CssClass="button1" runat="server" Text="导出Excel" OnClick="btnExport_Click" />
                            <asp:Button ID="btnPrint" CssClass="button1" runat="server" Text="打印" OnClientClick="return printGridView('printarea');" />
                        </td>
                    </tr>
                </table>
                <div id="printarea" class="kuang5">
                    <div id="gdtbfix" style="height: 380px; overflow: auto;">
                        <table id="printReport" width="80%">
                            <tr align="center">
                                <td style="font-size: 16px; font-weight: bold">
                                    转转卡销售渠道统计
                                </td>
                            </tr>
                        </table>
                        <asp:GridView ID="gvResult" runat="server" Width="95%" CssClass="tab2" HeaderStyle-CssClass="tabbt"
                            FooterStyle-CssClass="tabcon" AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel"
                            PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top"
                            AutoGenerateColumns="false" OnRowDataBound="gvResult_RowDataBound" ShowFooter="true" OnPreRender="gvResult_PreRender">
                            <Columns>
                                <asp:BoundField DataField="PAYCANAL" HeaderText="支付渠道" />
                                <asp:BoundField DataField="POSTAGE" HeaderText="邮费" />
                                <asp:BoundField DataField="PAYCANALTOTALMONEY" HeaderText="渠道总金额" />
                                <asp:BoundField DataField="ORDERTYPE" HeaderText="订单类型" />
                                <asp:BoundField DataField="PACKAGETYPE" HeaderText="套餐类型" />
                                <asp:BoundField DataField="OPENTIMES" HeaderText="数量/张数" />
                                <asp:BoundField DataField="SUPPLYMONEY" HeaderText="充值金额" />
                                <asp:BoundField DataField="FUNCFEE" HeaderText="功能费合计" />
                                <asp:BoundField DataField="CARDPRICE" HeaderText="卡费合计" />
                                <asp:BoundField DataField="ORDERTOTAL" HeaderText="订单总额" />
                                <asp:BoundField DataField="ACTIVITYDISCOUNT" HeaderText="直减优惠金额" />
                                <asp:BoundField DataField="DISCOUNT" HeaderText="兑换券" />
                                <asp:BoundField DataField="TRANSFEE" HeaderText="实际功能费" />
                            </Columns>
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                        <td>
                                            支付渠道
                                        </td>
                                        <td>
                                            邮费
                                        </td>
                                        <td>
                                            渠道总金额
                                        </td>
                                        <td>
                                            套餐类型
                                        </td>
                                        <td>
                                            数量/张数
                                        </td>
                                        <td>
                                            充值金额
                                        </td>
                                        <td>
                                            功能费合计
                                        </td>
                                        <td>
                                            卡费合计
                                        </td>
                                        <td>
                                            订单总额
                                        </td>
                                        <td>
                                            直减优惠金额
                                        </td>
                                        <td>
                                            兑换券
                                        </td>
                                        <td>
                                            实际功能费
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

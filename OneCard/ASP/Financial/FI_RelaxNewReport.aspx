<%@ Page Language="C#" AutoEventWireup="true" CodeFile="FI_RelaxNewReport.aspx.cs"
    Inherits="ASP_Financial_FI_RelaxNewReport" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>APP开通对账</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <script type="text/javascript" src="../../js/print.js"></script>
    <script type="text/javascript" src="../../js/myext.js"></script>
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
    <div class="tb">
        财务管理->APP开通对账
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
                                    业务类型:</div>
                            </td>
                            <td>
                                <asp:DropDownList ID="selTradeType" CssClass="inputmid" runat="server">
                                    <asp:ListItem Text="---请选择---" Value="" />
                                    <asp:ListItem Text="新办卡开通" Value="0" />
                                    <asp:ListItem Text="有卡开通" Value="1" />
                                </asp:DropDownList>
                            </td>
                            <td>
                                <div align="right">
                                    支付渠道:</div>
                            </td>
                            <td>
                                <asp:DropDownList ID="selPayCanal" CssClass="inputmid" runat="server">
                                    <asp:ListItem Text="---请选择---" Value="" />
                                    <asp:ListItem Text="支付宝" Value="01" />
                                    <asp:ListItem Text="微信" Value="02" />
                                    <asp:ListItem Text="银联" Value="03" />
                                    <asp:ListItem Text="兑换码" Value="04" />
                                </asp:DropDownList>
                            </td>
                            <td>
                                <asp:DropDownList ID="selFunType" CssClass="inputmid" runat="server"> 
                                    <asp:ListItem Text="休闲" Value="0" />
                                    <asp:ListItem Text="园林" Value="1" />
                                </asp:DropDownList>
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
                            <asp:Button ID="btnExportList" CssClass="button1" runat="server" Text="导出明细" OnClick="btnExportList_Click" />
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
                                    休闲APP开通对账
                                </td>
                            </tr>
                        </table>
                        <asp:GridView ID="gvResult" runat="server" Width="95%" CssClass="tab2" HeaderStyle-CssClass="tabbt"
                            FooterStyle-CssClass="tabcon" AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel"
                            PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top"
                            AutoGenerateColumns="false" OnRowDataBound="gvResult_RowDataBound" ShowFooter="true"
                            OnPreRender="gvResult_PreRender">
                            <Columns>
                                <asp:BoundField DataField="paycanal" HeaderText="支付渠道" />
                                <asp:BoundField DataField="packagetypename" HeaderText="套餐类型" />
                                <asp:BoundField DataField="opentimes" HeaderText="开通数量" />
                                <asp:BoundField DataField="cardcost" HeaderText="卡费" />
                                <asp:BoundField DataField="funcfee" HeaderText="功能费" />
                                <asp:BoundField DataField="ptdiscount" HeaderText="普通优惠" />
                                <asp:BoundField DataField="dhdiscount" HeaderText="兑换码优惠" />
                                <asp:BoundField DataField="postage" HeaderText="邮费" />
                                <asp:BoundField DataField="orderfee" HeaderText="实际功能费" />
                            </Columns>
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                        <td>
                                            套餐类型
                                        </td>
                                        <td>
                                            支付渠道
                                        </td>
                                        <td>
                                            开通数量
                                        </td>
                                        <td>
                                            卡费
                                        </td>
                                        <td>
                                            功能费
                                        </td>
                                        <td>
                                            普通优惠金额
                                        </td>
                                        <td>
                                            兑换码优惠金额
                                        </td>
                                        <td>
                                            邮费
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
            <asp:PostBackTrigger ControlID="btnExportList" />
        </Triggers>
    </asp:UpdatePanel>
    </form>
</body>
</html>

<%@ Page Language="C#" AutoEventWireup="true" CodeFile="FI_WALLETACCALYSIS_REPORT.aspx.cs"
    Inherits="ASP_Financial_FI_WALLETACCALYSIS_REPORT" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>卡账户余额汇总表</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />

    <script type="text/javascript" src="../../js/print.js"></script>

    <script type="text/javascript" src="../../js/myext.js"></script>

    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
    <div class="tb">
        财务管理->卡账户余额汇总表
    </div>
    <ajaxToolkit:ToolkitScriptManager runat="Server" EnableScriptGlobalization="true"
        AsyncPostBackTimeout="600" EnableScriptLocalization="true" ID="ScriptManager2" />

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
                                    Format="yyyyMM" />
                            </td>
                         
                            <td align="right">
                                <asp:Button ID="Button1" CssClass="button1" runat="server" Text="查询" OnClick="btnQuery_Click" />
                            </td>
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
                    <div id="gdtbfix" style="height: auto; min-height: 100px">
                        <table id="printReport" width="95%" runat="server">
                            <tr align="center">
                                <td style="font-size: 16px; font-weight: bold">
                                    卡账户余额汇总表
                                </td>
                            </tr>
                        </table>
                        <asp:GridView ID="gvResult" runat="server" Width="95%" CssClass="tab2" HeaderStyle-CssClass="tabbt"
                            FooterStyle-CssClass="tabcon" AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel"
                            PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top"
                            AutoGenerateColumns="false" ShowFooter="true" OnRowDataBound="gvResult_RowDataBound">
                            <Columns>
                                <asp:BoundField HeaderText="统计月份" DataField="STATTIME" />
                                <asp:BoundField HeaderText="充值卡账户总额" DataField="CHARGECARDMONEY" />
                                <asp:BoundField HeaderText="企服卡账户总额" DataField="CUSTACCTMONEY" />
                                <asp:BoundField HeaderText="卡片余额总额" DataField="CARDACCTMONEY" />
                                <asp:BoundField HeaderText="汇总金额" DataField="TOTALMONEY" />
                            </Columns>
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

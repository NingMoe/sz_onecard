<%@ Page Language="C#" AutoEventWireup="true" CodeFile="FI_ZZTransferReport.aspx.cs"
    Inherits="ASP_Financial_FI_ZZTransferReport" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>转转卡转账报表</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <script type="text/javascript" src="../../js/print.js"></script>
    <script type="text/javascript" src="../../js/myext.js"></script>
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
    <div class="tb">
        财务管理->转转卡转账报表
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
                                        行业名称:
                                    </div>
                                </td>
                                <td>
                                    <asp:DropDownList ID="selCalling" CssClass="inputmidder" runat="server" AutoPostBack="true"
                                        OnSelectedIndexChanged="selCalling_SelectedIndexChanged">
                                        <asp:ListItem Text="---请选择---" Value=""></asp:ListItem>
                                        <asp:ListItem Text="06:园林" Value="06"></asp:ListItem>
                                    </asp:DropDownList>
                                </td>
                                <td>
                                    <div align="right">
                                        单位名称:
                                    </div>
                                </td>
                                <td>
                                    <asp:DropDownList ID="selCorp" CssClass="inputmidder" runat="server" AutoPostBack="true"
                                        OnSelectedIndexChanged="selCorp_SelectedIndexChanged">
                                    </asp:DropDownList>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <div align="right">
                                        部门名称:
                                    </div>
                                </td>
                                <td>
                                    <asp:DropDownList ID="selDepart" CssClass="inputmidder" runat="server" AutoPostBack="true"
                                        OnSelectedIndexChanged="selDepart_SelectedIndexChanged">
                                    </asp:DropDownList>
                                </td>
                                <td>
                                    <div align="right">
                                        结算单元:
                                    </div>
                                </td>
                                <td>
                                    <asp:DropDownList ID="selBalUint" CssClass="inputmidder" runat="server">
                                    </asp:DropDownList>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <div align="right">
                                        开始日期:
                                    </div>
                                </td>
                                <td>
                                    <asp:TextBox runat="server" ID="txtFromDate" MaxLength="8" CssClass="input"></asp:TextBox>
                                    <ajaxToolkit:CalendarExtender ID="FCalendar1" runat="server" TargetControlID="txtFromDate"
                                        Format="yyyyMMdd" />
                                </td>
                                <td>
                                    <div align="right">
                                        结束日期:
                                    </div>
                                </td>
                                <td>
                                    <asp:TextBox runat="server" ID="txtToDate" MaxLength="8" CssClass="input"></asp:TextBox>
                                    <ajaxToolkit:CalendarExtender ID="FCalendar2" runat="server" TargetControlID="txtToDate"
                                        Format="yyyyMMdd" />
                                </td>
                            </tr>
                            <tr>
                                <td></td>
                                <td></td>
                                <td></td>
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
                            <asp:Button ID="btnExportTransfer" CssClass="button1" runat="server" Text="导出转账表格" OnClick="btnExportTransfer_Click" />
                            <asp:Button ID="btnPrint" CssClass="button1" runat="server" Text="打印" OnClientClick="return printGridView('printarea');" />
                        </td>
                    </tr>
                </table>
                <div id="printarea" class="kuang5">
                    <div id="gdtbfix" style="height: 380px; overflow: auto;">
                        <table id="printReport" width="80%">
                            <tr align="center">
                                <td style="font-size: 16px; font-weight: bold">
                                    转转卡转账报表
                                </td>
                            </tr>
                        </table>
                        <asp:GridView ID="gvResult" runat="server" Width="95%" CssClass="tab2" HeaderStyle-CssClass="tabbt"
                            FooterStyle-CssClass="tabcon" AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel"
                            PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top"
                            AutoGenerateColumns="false" OnRowDataBound="gvResult_RowDataBound" ShowFooter="false">
                            <Columns>
                                <asp:BoundField DataField="BANKCODE" HeaderText="转账银行" />
                                <asp:BoundField DataField="BALUNITNO" HeaderText="结算单元编码" />
                                <asp:BoundField DataField="BALUNITNAME" HeaderText="结算单元名称" />
                                <asp:BoundField DataField="PURPOSETYPE" HeaderText="收款人账户类型" />
                                <asp:BoundField DataField="BANKACCNO" HeaderText="收款账号" />
                                <asp:BoundField DataField="TRANSFEE" HeaderText="转账金额" />
                                <asp:BoundField DataField="ENDTIME" HeaderText="结算时间" />
                            </Columns>
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                        <td>
                                            银行编码
                                        </td>
                                        <td>
                                            结算单元编码
                                        </td>
                                        <td>
                                            结算单元名称
                                        </td>
                                        <td>
                                            收款人账户类型
                                        </td>
                                        <td>
                                            收款账号
                                        </td>
                                        <td>
                                            转账金额
                                        </td>
                                        <td>
                                            结算时间
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
            <asp:PostBackTrigger ControlID="btnExportTransfer" />
        </Triggers>
    </asp:UpdatePanel>
    </form>
</body>
</html>

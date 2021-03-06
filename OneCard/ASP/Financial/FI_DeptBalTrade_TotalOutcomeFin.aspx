﻿<%@ Page Language="C#" AutoEventWireup="true" CodeFile="FI_DeptBalTrade_TotalOutcomeFin.aspx.cs"
    Inherits="ASP_Financial_FI_DeptBalTrade_TotalOutcomeFin" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>佣金转账日报</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />

    <script type="text/javascript" src="../../js/print.js"></script>

    <script type="text/javascript" src="../../js/myext.js"></script>

    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
    <ajaxToolkit:ToolkitScriptManager EnableScriptGlobalization="true" EnableScriptLocalization="true"
        ID="ScriptManager1" runat="server" />

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
            <div class="tb">
                财务管理->佣金转账日报
            </div>
            <asp:HiddenField ID="hidNo" runat="server" Value="" />
            <asp:BulletedList ID="bulMsgShow" runat="server" />

            <script runat="server">public override void ErrorMsgShow() { ErrorMsgHelper(bulMsgShow); }</script>

            <div class="con">
                <div class="base">
                    查询条件</div>
                <div class="kuang5">
                    <table border="0" cellpadding="0" cellspacing="0" class="text25" width="100%">
                        <tr>
                            <td width="10%">
                                <div align="right">
                                    营业厅:</div>
                            </td>
                            <td width="35%" align="left">
                                <asp:TextBox ID="txtBalUnitName" CssClass="inputmid" runat="server" AutoPostBack="true"
                                    OnTextChanged="txtBalUnitName_Changed"></asp:TextBox>
                                <asp:DropDownList ID="selBalUnit" CssClass="input" runat="server" Width="190px">
                                </asp:DropDownList>
                            </td>
                            <td width="15%">
                                <div align="right">
                                    转账类型:</div>
                            </td>
                            <td width="15%" align="left">
                                <asp:DropDownList ID="ddlFinTypecode" CssClass="input" runat="server">
                                    <asp:ListItem Text="---请选择---" Value=""></asp:ListItem>
                                    <asp:ListItem Text="0:财务部门转账" Value="0"></asp:ListItem>
                                    <asp:ListItem Text="1:结入预付款" Value="1"></asp:ListItem>
                                </asp:DropDownList>
                            </td>
                            <td width="5%">
                                &nbsp;
                            </td>
                            <td width="15%">
                                &nbsp;
                            </td>
                        </tr>
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
                            <td>
                                <asp:TextBox runat="server" ID="txtToDate" MaxLength="8" CssClass="input"></asp:TextBox>
                                <ajaxToolkit:CalendarExtender ID="FCalendar2" runat="server" TargetControlID="txtToDate"
                                    Format="yyyyMMdd" />
                            </td>
                            <td align="left">
                                &nbsp;
                            </td>
                            <td align="left">
                                <asp:Button ID="btnQuery" CssClass="button1" runat="server" Text="查询" OnClick="btnQuery_Click" />
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
                            <asp:Button ID="btnExport" CssClass="button1fix" runat="server" Text="导出表格" OnClick="btnExport_Click" />
                            <%--<asp:Button ID="btnExportPayFile" CssClass="button1fix" runat="server" Text="导出转账文件"
                                    OnClick="btnExportPayFile_Click" />--%>
                            <asp:Button ID="btnPrint" CssClass="button1" runat="server" Text="打印" OnClientClick="return printGridView('printarea');" />
                        </td>
                    </tr>
                </table>
                <div id="printarea" class="kuang5">
                    <div class="gdtbfix" style="height: 380px;">
                        <table id="printReport" width="95%">
                            <tr align="center">
                                <td style="font-size: 16px; font-weight: bold">
                                    佣金转账日报
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <table width="300px" align="left">
                                        <tr align="left">
                                            <td>
                                            </td>
                                        </tr>
                                    </table>
                                    <table width="300px" align="right">
                                        <tr align="right">
                                            <td>
                                                开始日期：<%=txtFromDate.Text%>
                                            </td>
                                            <td>
                                                结束日期：<%=txtToDate.Text%>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                        </table>
                        <asp:GridView ID="gvResult" runat="server" Width="95%" CssClass="tab2" HeaderStyle-CssClass="tabbt"
                            FooterStyle-CssClass="tabcon" AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel"
                            PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top"
                            AutoGenerateColumns="false" OnRowDataBound="gvResult_RowDataBound" ShowFooter="true">
                            <Columns>
                                <asp:BoundField DataField="DBALUNIT" HeaderText="营业厅" />
                                <asp:BoundField DataField="TOTALBALFEE" HeaderText="交易金额" />
                                <asp:BoundField DataField="TOTALTIMES" HeaderText="交易笔数" />
                                <asp:BoundField DataField="CANCELTOTALBALFEE" HeaderText="返销金额" />
                                <asp:BoundField DataField="CANCELTOTALTIMES" HeaderText="返销笔数" />
                                <asp:BoundField DataField="TRANSFEE" HeaderText="退卡销户金额" />
                                <asp:BoundField DataField="TRANSTIMES" HeaderText="退卡销户笔数" />
                                <asp:BoundField DataField="COMFEE" HeaderText="佣金" />
                                <asp:BoundField DataField="FINTYPE" HeaderText="转账类型" />
                            </Columns>
                            <%--<EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                        <td>
                                            营业厅
                                        </td>
                                        <td>
                                            交易金额
                                        </td>
                                        <td>
                                            交易笔数
                                        </td>
                                        <td>
                                            返销金额
                                        </td>
                                        <td>
                                            返销笔数
                                        </td>
                                        <td>
                                            退卡销户金额
                                        </td>
                                        <td>
                                            退卡销户笔数
                                        </td>
                                        <td>
                                            佣金
                                        </td>
                                    </tr>
                                </table>
                            </EmptyDataTemplate>--%>
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

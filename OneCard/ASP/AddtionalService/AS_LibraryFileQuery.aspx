<%@ Page Language="C#" AutoEventWireup="true" CodeFile="AS_LibraryFileQuery.aspx.cs"
    Inherits="ASP_AddtionalService_AS_LibraryFileQuery" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>图书馆对账文件查询</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <script type="text/javascript" src="../../js/print.js"></script>
    <script type="text/javascript" src="../../js/myext.js"></script>
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
    <div class="tb">
        附加业务->图书馆对账文件查询
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
                                    业务类型:</div>
                            </td>
                            <td>
                                <asp:DropDownList ID="selTradeType" CssClass="inputmid" runat="server">
                                </asp:DropDownList>
                            </td>
                            <td>
                                <div align="right">
                                    处理状态:</div>
                            </td>
                            <td>
                                <asp:DropDownList ID="selTradeStates" CssClass="inputmid" runat="server">
                                </asp:DropDownList>
                            </td>
                            <td>
                                <div align="right">
                                    开始日期:</div>
                            </td>
                            <td>
                                <asp:TextBox runat="server" ID="txtFromDate" MaxLength="8" CssClass="inputmid"></asp:TextBox>
                                <ajaxToolkit:CalendarExtender ID="FromDateCalendar" runat="server" TargetControlID="txtFromDate"
                                    Format="yyyyMMdd" />
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    结束日期:</div>
                            </td>
                            <td>
                                <asp:TextBox runat="server" ID="txtToDate" MaxLength="8" CssClass="inputmid"></asp:TextBox>
                                <ajaxToolkit:CalendarExtender ID="ToDateCalendar" runat="server" TargetControlID="txtToDate"
                                    Format="yyyyMMdd" />
                            </td>
                            <td colspan="4" align="right">
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
                        </td>
                    </tr>
                </table>
                <div id="printarea" class="kuang5">
                    <div style="height: 380px; overflow: auto;">
                        <asp:GridView ID="gvResult" runat="server" Width="150%" CssClass="tab1" HeaderStyle-CssClass="tabbt"
                            FooterStyle-CssClass="tabcon" AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel"
                            PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top"
                            AutoGenerateColumns="false" ShowFooter="true" AllowPaging="True" PageSize="20"
                            OnPageIndexChanging="gvResult_PageIndexChanging">
                            <Columns>
                                <asp:BoundField HeaderText="文件名" DataField="FILENAME" />
                                <asp:BoundField HeaderText="交易日期" DataField="TRADEDATE" />
                                <asp:BoundField HeaderText="IC卡号" DataField="CARDNO" />
                                <asp:BoundField HeaderText="业务类型" DataField="TRADETYPECODE" />
                                <asp:BoundField HeaderText="处理状态" DataField="STATES" />
                                <asp:BoundField HeaderText="错误描述" DataField="ERRINFO" />
                                <asp:BoundField HeaderText="传送日期" DataField="FILEDATE" />
                                <asp:BoundField HeaderText="操作员工" DataField="STAFFNAME" />
                                <asp:BoundField HeaderText="操作时间" DataField="OPERATETIME" />
                            </Columns>
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                        <td width="5%">
                                            文件名
                                        </td>
                                        <td width="5%">
                                            交易日期
                                        </td>
                                        <td width="8%">
                                            IC卡号
                                        </td>
                                        <td width="5%">
                                            业务类型
                                        </td>
                                        <td width="5%">
                                            处理状态
                                        </td>
                                        <td width="8%">
                                            错误描述
                                        </td>
                                        <td width="8%">
                                            传送日期
                                        </td>
                                        <td width="5%">
                                            操作员工
                                        </td>
                                        <td width="8%">
                                            操作时间
                                        </td>
                                    </tr>
                                </table>
                            </EmptyDataTemplate>
                        </asp:GridView>
                    </div>
                </div>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
    </form>
</body>
</html>

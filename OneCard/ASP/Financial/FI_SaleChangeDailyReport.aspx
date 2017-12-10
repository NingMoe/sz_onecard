<%@ Page Language="C#" AutoEventWireup="true" CodeFile="FI_SaleChangeDailyReport.aspx.cs" Inherits="ASP_Financial_FI_SaleChangeDailyReport" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>售换卡库存表</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <script type="text/javascript" src="../../js/myext.js"></script>
    <script type="text/javascript" src="../../js/print.js"></script>
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
    <div class="tb">
        管理报表->售换卡库存表
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
                    <table  width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td><div align="right">开始日期:</div></td>
                        <td>
                            <asp:TextBox runat="server" ID="txtFromDate" MaxLength="8" CssClass="input"></asp:TextBox>
                            <ajaxToolkit:CalendarExtender ID="FCalendar1" runat="server" TargetControlID="txtFromDate" Format="yyyyMMdd" />
                        </td>
                        <td><div align="right">结束日期:</div></td>
                        <td colspan="3">
                            <asp:TextBox runat="server" ID="txtToDate" MaxLength="8" CssClass="input"></asp:TextBox>
                            <ajaxToolkit:CalendarExtender ID="FCalendar2" runat="server" TargetControlID="txtToDate" Format="yyyyMMdd" />
                        </td>
                            <td >
                                <div align="right">
                                    部门:</div>
                            </td>
                            <td >
                                <asp:DropDownList ID="selDept" CssClass="inputmid" runat="server">
                                </asp:DropDownList>
                            </td>
                            <%--<td align="right">
                                <asp:CheckBox ID="chkQueryAll" runat="server" Checked="false" Text="查询全部卡面" />
                            </td>--%>
                            <td align="right">
                                <asp:Button ID="Button1" CssClass="button1" runat="server" Text="查询" OnClick="btnQuery_Click" />
                            </td>
                           
                        </tr>

                        
                         
                        
                    </table>
                    
                </div>
                <div class="card">
                    部门多选</div>
                <div class="kuang5">
                 <table  width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                     <tr>
                            <asp:CheckBoxList ID="cblDept" runat="server" RepeatDirection="Horizontal" RepeatColumns="8">
                            </asp:CheckBoxList>
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
                            <asp:Button ID="btnExport" CssClass="button1" runat="server" Text="导出" OnClick="btnExport_Click" />
                            <asp:Button ID="btnPrint" CssClass="button1" runat="server" Text="打印" OnClientClick="return printGridView('printarea');" />
                        </td>
                    </tr>
                </table>
                <div id="printarea" class="kuang5">
                    <div id="gdtbfix" style="height: 320px;">
                        <table id="printReport" width="95%">
                            <tr align="center">
                                <td style="font-size: 16px; font-weight: bold">
                                    售换卡库存表
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    
                                    <table width="300px" align="right">
                                        <tr align="right">
                                            <td>开始日期：<%=txtFromDate.Text%></td>
                                            <td>结束日期：<%=txtToDate.Text%></td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                        </table>
                        <asp:GridView ID="gvResult" runat="server" Width="95%" CssClass="tab2" HeaderStyle-CssClass="tabbt"
                            FooterStyle-CssClass="tabcon" AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel"
                            PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top"
                            AutoGenerateColumns="true" OnRowDataBound="gvResult_RowDataBound" ShowFooter="true">
                        </asp:GridView>
                    </div>
                </div>
            </div>
           <%-- <div class="btns">
            <span class="red">提示: 默认查询有售换卡记录的卡。选择查询全部卡面时，可以查询出有库存但没有售换卡记录的卡。</span>
            </div>--%>
        </ContentTemplate>
        <Triggers>
            <asp:PostBackTrigger ControlID="btnExport" />
        </Triggers>
    </asp:UpdatePanel>
    </form>
</body>
</html>

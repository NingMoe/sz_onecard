<%@ Page Language="C#" AutoEventWireup="true" CodeFile="FI_TaxiTransferMoneyDialyReport.aspx.cs"
    Inherits="ASP_Financial_FI_TaxiTransferMoneyDialyReport" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>出租车转账日报</title>
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
								function BeginRequestHandler(sender, args){
    							try {MyExtShow('请等待', '正在提交后台处理中...'); } catch(ex){}
								}
								function EndRequestHandler(sender, args) {
    							try {MyExtHide(); } catch(ex){}
								}
        </script>

        <asp:UpdatePanel ID="UpdatePanel1" UpdateMode="Conditional" runat="server">
            <ContentTemplate>
                <div class="tb">
                    财务管理->出租车转账日报
                </div>
                <asp:HiddenField runat="server" ID="hidSeqNo" />
                <asp:BulletedList ID="bulMsgShow" runat="server" />

                <script runat="server">public override void ErrorMsgShow() { ErrorMsgHelper(bulMsgShow); }</script>

                <div class="con">
                    <div class="base">
                        查询</div>
                    <div class="kuang5">
                        <table border="0" cellpadding="0" cellspacing="0" class="text25">
                            <tr>
                                <td width="100">
                                    <div align="center">
                                        出账时间:</div>
                                </td>
                                <td width="120">
                                    <asp:TextBox ID="txtDate" CssClass="input" runat="server"></asp:TextBox>
                                    <ajaxToolkit:CalendarExtender ID="CalendarExtender1" runat="server" TargetControlID="txtDate"
                                        Format="yyyy-MM-dd" />
                                </td>
                                <td width="140">
                                    <asp:RadioButtonList ID="radTime" runat="server" RepeatDirection="Horizontal">
                                        <asp:ListItem Text="上午" Value="000000" Selected="true"></asp:ListItem>
                                        <asp:ListItem Text="下午" Value="120000"></asp:ListItem>
                                    </asp:RadioButtonList>
                                </td>
                                <td width="150" align="center">
                                    <asp:DropDownList ID="selTrans" CssClass="input" runat="server">
                                    <asp:ListItem Text="不选择" Value="" Selected="true"></asp:ListItem>
                                        <asp:ListItem Text="0:财务农行转账" Value="0" ></asp:ListItem>
                                        <asp:ListItem Text="1:财务农商行转账" Value="1"></asp:ListItem>
                                        <asp:ListItem Text="2:财务交行转账" Value="2"></asp:ListItem>
                                        <asp:ListItem Text="3:财务张家港转账" Value="3"></asp:ListItem>
                                    </asp:DropDownList>
                                </td>
                                <td width="150" align="center">
                                    <asp:Button ID="Button1" CssClass="button1" runat="server" Text="查询" OnClick="btnQuery_Click" />
                                    <input type="hidden" runat="server" id="hidDateText" />
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
                                <asp:Button ID="btnExport" CssClass="button1fix" runat="server" Text="导出表格" OnClick="btnExport_Click" />
                                <asp:Button ID="btnExportPayFile" CssClass="button1fix" runat="server" Text="导出转账文件"
                                    OnClick="btnExportPayFile_Click" />
                                <asp:Button ID="btnPrint" CssClass="button1" runat="server" Text="打印" OnClientClick="return printGridView('printarea');" />
                            </td>
                        </tr>
                    </table>
                    <div id="printarea" class="kuang5">
                        <div class="gdtbfix" style="height: 380px;">
                            <table id="Table1" width="60%">
                                <tr align="center">
                                    <td style="font-size: 16px; font-weight: bold">
                                        出租车转账日报</td>
                                </tr>
                                <tr>
                                    <td>
                                        <table width="300px" align="left">
                                            <tr align="left">
                                                <td>
                                                    凭证号：<%=hidNo.Value%></td>
                                            </tr>
                                        </table>
                                        <table width="300px" align="right">
                                            <tr align="right">
                                                <td>
                                                    日期：<%=txtDate.Text%>
                                                    <%=radTime.SelectedItem.Text%>
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                            </table>
                            <asp:GridView ID="gvResult" runat="server" Width="98%" CssClass="tab2" HeaderStyle-CssClass="tabbt"
                                FooterStyle-CssClass="tabcon" AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel"
                                PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top"
                                AutoGenerateColumns="true" OnRowDataBound="gvResult_RowDataBound" ShowFooter="true">
                            </asp:GridView>
                        </div>
                    </div>
                </div>
            </ContentTemplate>
            <Triggers>
                <asp:PostBackTrigger ControlID="btnExport" />
                <asp:PostBackTrigger ControlID="btnExportPayFile" />
            </Triggers>
        </asp:UpdatePanel>
    </form>
</body>
</html>

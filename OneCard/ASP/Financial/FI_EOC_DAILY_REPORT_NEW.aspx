<%@ Page Language="C#" AutoEventWireup="true" CodeFile="FI_EOC_DAILY_REPORT_NEW.aspx.cs" Inherits="ASP_Financial_FI_EOC_DAILY_REPORT_NEW" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>新商户转账日报</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <script type="text/javascript" src="../../js/print.js"></script>
    <script type="text/javascript" src="../../js/myext.js"></script>
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <style type="text/css">
        .Hide
        {
            display: none;
        }
    </style>
    <script language="javascript" type="text/javascript">
        function PrintInfo(ID) {
            //清除隐藏域
            var controls = document.getElementsByTagName('th');
            for (var i = 0; i < controls.length; i++) {
                if (controls[i].className == 'Hide') {
                    controls[i].innerHTML = "";
                    controls[i].removeNode();
                    --i;
                }
            }
            controls = document.getElementsByTagName('td');
            for (var i = 0; i < controls.length; i++) {
                if (controls[i].className == 'Hide') {
                    controls[i].innerHTML = "";
                    controls[i].removeNode();
                    --i;
                }
            }
            var flag = printGridViewDAILY_REPORT(ID);
            //刷新页面
            document.getElementById("btnQuery").click();
            return flag;
        }
    </script>
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
                财务管理->商户转账日报
            </div>
            <asp:HiddenField ID="hidNo" runat="server" Value="" />
            <asp:HiddenField ID="hidBeginDate" runat="server" Value="" />
            <asp:HiddenField ID="hidEndDate" runat="server" Value="" />
            <asp:BulletedList ID="bulMsgShow" runat="server" />
            <script runat="server">public override void ErrorMsgShow() { ErrorMsgHelper(bulMsgShow); }</script>
            <div class="con">
                <div class="base">
                    查询条件</div>
                <div class="kuang5">
                    <table border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td width="100">
                                <div align="right">
                                    开始日期:</div>
                            </td>
                            <td width="100">
                                <asp:TextBox runat="server" ID="txtFromDate" MaxLength="8" CssClass="input"></asp:TextBox>
                                <ajaxToolkit:CalendarExtender ID="FCalendar1" runat="server" TargetControlID="txtFromDate"
                                    Format="yyyyMMdd" />
                            </td>
                            <td width="100">
                                <div align="right">
                                    结束日期:</div>
                            </td>
                            <td width="100">
                                <asp:TextBox runat="server" ID="txtToDate" MaxLength="8" CssClass="input"></asp:TextBox>
                                <ajaxToolkit:CalendarExtender ID="FCalendar2" runat="server" TargetControlID="txtToDate"
                                    Format="yyyyMMdd" />
                            </td>
                            <td width="150" align="center">
                                <asp:DropDownList ID="selTrans" CssClass="input" runat="server">
                                    <asp:ListItem Text="不选择" Value="" Selected="true"></asp:ListItem>
                                    <asp:ListItem Text="1:财务不转账" Value="1"></asp:ListItem>
                                </asp:DropDownList>
                            </td>
                            <td width="150" align="center">
                                <asp:Button ID="btnQuery" CssClass="button1" runat="server" Text="查询" OnClick="btnQuery_Click" />
                            </td>
                        </tr>
                    </table>
                </div>
                <div class="base">
                    凭证信息</div>
                <div class="kuang5">
                    <table border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <%--<td width="110">
                                <div align="right">
                                    凭证编号:</div>
                            </td>--%>
                            <%--<td width="150">
                                <asp:TextBox runat="server" ID="txtiNoId"  MaxLength='4' CssClass="input"></asp:TextBox><span class="red">*</span>
                            </td>--%>
                            <td width="120">
                                <div align="right">
                                    凭证类别:</div>
                            </td>
                            <td width="160">
                                <asp:DropDownList ID="dropSignType" CssClass="input" runat="server">
                                    <asp:ListItem Text="付" Value="5" Selected="true"></asp:ListItem>
                                </asp:DropDownList>
                            </td>
                            <td width="120">
                                <div align="right">
                                    项目大类编码:</div>
                            </td>
                            <td width="160">
                                <asp:DropDownList ID="dropcItemClass" CssClass="input" runat="server">
                                    <asp:ListItem Text="01:现金流量" Value="01" Selected="true"></asp:ListItem>
                                </asp:DropDownList>
                            </td>
                            <td width="120">
                                <div align="right">
                                    项目编码:</div>
                            </td>
                            <td width="160">
                                <asp:DropDownList ID="dropcItemId" CssClass="input" runat="server">
                                    <asp:ListItem Text="YJR:充值、押金" Value="YJR" Selected="true"></asp:ListItem>
                                </asp:DropDownList>
                            </td>
                            <td width="120">
                                <div align="right">
                                </div>
                            </td>
                            <td width="160">
                                &nbsp;
                            </td>
                        </tr>
                        <tr>
                            <td width="120">
                                <div align="right">
                                    供应商编码:</div>
                            </td>
                            <td width="160">
                                <asp:DropDownList ID="dropcSupId" runat="server" CssClass="input">
                                    <asp:ListItem Selected="true" Text="GRCZ:充值" Value="GRCZ"></asp:ListItem>
                                </asp:DropDownList>
                            </td>
                            <td width="120">
                                <div align="right">
                                    贷方科目编码:</div>
                            </td>
                            <td width="160">
                                <asp:DropDownList ID="dropcCodeD" CssClass="input" runat="server">
                                    <asp:ListItem Text="10020203" Value="10020203" Selected="true"></asp:ListItem>
                                </asp:DropDownList>
                                &nbsp;
                            </td>
                            <td width="120">
                                <div align="right">
                                    借方科目编码:</div>
                            </td>
                            <td width="160">
                                <asp:DropDownList ID="dropcCodeJ" CssClass="input" runat="server">
                                    <asp:ListItem Text="220201" Value="220201" Selected="true"></asp:ListItem>
                                </asp:DropDownList>
                                &nbsp;
                            </td>
                            <td width="120">
                                <div align="right">
                                </div>
                            </td>
                            <td width="160">
                                &nbsp;
                                <asp:Button ID="btnExportSql" runat="server" CssClass="button1fix" OnClick="btnExportSql_Click"
                                    Text="导出财务凭证" Width="100px" />
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
                            <asp:Button ID="btnExportPayFile" CssClass="button1fix" runat="server" Text="导出转账文件"
                                OnClick="btnExportPayFile_Click" Visible="false" />
                            <asp:Button ID="btnExportXML" CssClass="button1fix" runat="server" Text="导出转账表格"
                                OnClick="btnExportXML_Click" />
                            <asp:Button ID="btnPrint" CssClass="button1" runat="server" Text="打印" OnClientClick="PrintInfo('printarea')" />
                        </td>
                    </tr>
                </table>
                <div id="printarea" class="kuang5">
                    <div class="gdtbfix" style="height: 380px;">
                        <table id="printReport" width="95%">
                            <tr align="center">
                                <td style="font-size: 16px; font-weight: bold">
                                    商户转账日报
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <table width="300px" align="left">
                                        <tr align="left">
                                            <td>
                                                凭证号：<%=hidNo.Value%>
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
                        <asp:GridView ID="gvResult" runat="server" Width="980px" CssClass="tab2" HeaderStyle-CssClass="tabbt"
                            FooterStyle-CssClass="tabcon" AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel"
                            PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top"
                            AutoGenerateColumns="true" OnRowDataBound="gvResult_RowDataBound" ShowFooter="true">
                        </asp:GridView>
                    </div>
                </div>
            </div>
        </ContentTemplate>
        <Triggers>
            <asp:PostBackTrigger ControlID="btnExportSql" />
            <asp:PostBackTrigger ControlID="btnExport" />
            <asp:PostBackTrigger ControlID="btnExportPayFile" />
            <asp:PostBackTrigger ControlID="btnExportXML" />
        </Triggers>
    </asp:UpdatePanel>
    </form>
</body>
</html>
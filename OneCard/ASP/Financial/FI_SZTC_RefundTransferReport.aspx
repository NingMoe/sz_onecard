<%@ Page Language="C#" AutoEventWireup="true" CodeFile="FI_SZTC_RefundTransferReport.aspx.cs"
    Inherits="ASP_Financial_FI_SZTC_RefundTransferReport" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>旅游卡客户退款</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <script type="text/javascript" src="../../js/print.js"></script>
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
            var flag = printGridView(ID);
            //刷新页面
            document.getElementById("Button1").click();
            return flag;
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
    <div class="tb">
        财务管理->旅游卡客户退款
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
                        </tr>
                        <tr>
                            <td><div align="right">部门:</div></td>
                            <td><asp:DropDownList ID="selDept" CssClass="inputmid" runat="server" AutoPostBack="true" OnSelectedIndexChanged="selDept_Changed"></asp:DropDownList></td>
                            <td><div align="right">员工:</div></td>
                            <td><asp:DropDownList ID="selStaff" CssClass="inputmid" runat="server"></asp:DropDownList></td>
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
                            <asp:Button ID="btnExportPayFile" CssClass="button1fix" runat="server" Text="导出转账文件"
                                OnClick="btnExportPayFile_Click" Visible="false" />
                            <asp:Button ID="btnExportXML" CssClass="button1fix" runat="server" Text="导出转账文件"
                                OnClick="btnExportXML_Click" />
                            <asp:Button ID="btnPrint" CssClass="button1" runat="server" Text="打印" OnClientClick="return PrintInfo('printarea');" />
                        </td>
                    </tr>
                </table>
                <div id="printarea" class="kuang5">
                    <div id="gdtbfix" style="height: 380px;overflow:auto;">
                        <table id="printReport" width="95%">
                            <tr align="center">
                                <td style="font-size: 16px; font-weight: bold">
                                    旅游卡客户退款
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
                        <asp:GridView ID="gvResult" runat="server" Width="95%" CssClass="tab2" HeaderStyle-CssClass="tabbt"
                            FooterStyle-CssClass="tabcon" AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel"
                            PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top"
                            AutoGenerateColumns="false" OnRowDataBound="gvResult_RowDataBound" ShowFooter="false">
                            <Columns>
                                <asp:BoundField DataField="BANKNAME" HeaderText="开户行简写" />
                                <asp:BoundField DataField="BANKLIST" HeaderText="开户行" />
                                <asp:BoundField DataField="BANKACCNO" HeaderText="开户帐号" />
                                <asp:BoundField DataField="CUSTNAME" HeaderText="收款人" />
                                <asp:BoundField DataField="BACKDEPOSIT" HeaderText="退押金" />
                                <asp:BoundField DataField="BACKMONEY" HeaderText="退余额" />
                                <asp:BoundField DataField="BACKALL" HeaderText="合计退款" />
                                <asp:BoundField DataField="CARDNO" HeaderText="卡号" />
                                <asp:BoundField DataField="PAPERTYPENAME" HeaderText="证件类型" />
                                <asp:BoundField DataField="PAPERNO" HeaderText="证件号码" />
                                <asp:BoundField DataField="CUSTPHONE" HeaderText="联系电话" />
                                <asp:BoundField DataField="DEPARTNAME" HeaderText="操作部门" />
                                <asp:BoundField DataField="STAFFNAME" HeaderText="操作员工" />
                                <asp:BoundField DataField="OPERATETIME" HeaderText="操作时间" />
                                <asp:BoundField DataField="REMARK" HeaderText="备注" />
                                <asp:BoundField DataField="PURPOSETYPE" HeaderText="收款人账户类型" />
                            </Columns>
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                        <td>
                                            开户行
                                        </td>
                                        <td>
                                            开户帐号
                                        </td>
                                        <td>
                                            收款人
                                        </td>
                                        <td>
                                            退押金
                                        </td>
                                        <td>
                                            退余额
                                        </td>
                                        <td>
                                            合计退款
                                        </td>
                                        <td>
                                            卡号
                                        </td>
                                        <td>
                                            证件类型
                                        </td>
                                        <td>
                                            证件号码
                                        </td>
                                        <td>
                                            联系电话
                                        </td>
                                        <td>
                                            操作部门
                                        </td>
                                        <td>
                                            操作员工
                                        </td>
                                        <td>
                                            操作时间
                                        </td>
                                        <td>
                                            备注
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
            <asp:PostBackTrigger ControlID="btnExportPayFile" />
            <asp:PostBackTrigger ControlID="btnExportXML" />
        </Triggers>
    </asp:UpdatePanel>
    </form>
</body>
</html>

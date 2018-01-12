<%@ Page Language="C#" AutoEventWireup="true" CodeFile="FI_ZZTradeReport.aspx.cs"
    Inherits="ASP_Financial_FI_ZZTradeReport" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>转转卡操作记录表</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <script type="text/javascript" src="../../js/print.js"></script>
    <script type="text/javascript" src="../../js/myext.js"></script>
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
    <div class="tb">
        财务管理->转转卡操作记录表
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
                                    <asp:ListItem Text="00:订单录入" Value="00" />
                                    <asp:ListItem Text="01:售卡" Value="01" />
                                    <asp:ListItem Text="02:驳回" Value="02" />
                                    <asp:ListItem Text="03:发货" Value="03" />
                                    <asp:ListItem Text="04:修改资料" Value="04" />
                                    <asp:ListItem Text="05:撤销驳回" Value="05" />
                                    <asp:ListItem Text="06:激活领卡" Value="06" />
                                    <asp:ListItem Text="07:充值" Value="07" />
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
                            </td>
                        </tr>
                        <tr><td>
                                <div align="right">
                                    操作部门:</div>
                            </td>
                            <td>
                                    <asp:DropDownList ID="selDept" CssClass="inputmid" runat="server" AutoPostBack="true" OnSelectedIndexChanged="selDept_Changed"></asp:DropDownList>
                            </td>
                            <td>
                                <div align="right">
                                    操作员工:</div>
                            </td>
                            <td colspan="3">
                                    <asp:DropDownList ID="selStaff" CssClass="inputmid" runat="server"></asp:DropDownList>
                            </td>
                            <td>
                                <div align="right">
                                    </div>
                            </td>
                            <td>
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
                                    转转卡操作记录
                                </td>
                            </tr>
                        </table>
                        <asp:GridView ID="gvResult" runat="server" Width="95%" CssClass="tab2" HeaderStyle-CssClass="tabbt"
                            FooterStyle-CssClass="tabcon" AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel"
                            PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top"
                            AutoGenerateColumns="false" OnRowDataBound="gvResult_RowDataBound" ShowFooter="false">
                            <Columns>
                                <asp:BoundField DataField="tradetype" HeaderText="业务类型" />
                                <asp:BoundField DataField="cardno" HeaderText="卡号" />
                                <asp:BoundField DataField="operatetime" HeaderText="操作时间" />
                                <asp:BoundField DataField="operatedepartid" HeaderText="操作部门" />
                                <asp:BoundField DataField="operatestaffno" HeaderText="操作员工" />
                                <asp:BoundField DataField="posno" HeaderText="POS编号" />
                                <asp:BoundField DataField="psamno" HeaderText="PSAM编号" />
                            </Columns>
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                        <td>
                                            业务类型
                                        </td>
                                        <td>
                                            卡号
                                        </td>
                                        <td>
                                            操作时间
                                        </td>
                                        <td>
                                            操作部门
                                        </td>
                                        <td>
                                            操作员工
                                        </td>
                                        <td>
                                            POS编号
                                        </td>
                                        <td>
                                            PSAM编号
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

<%@ Page Language="C#" AutoEventWireup="true" EnableEventValidation="false" CodeFile="PN_QueryTradeAccounts.aspx.cs"
    Inherits="ASP_ProvisionNote_PN_QueryTradeAccounts" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>业务账务查询</title>
    <%--<link rel="stylesheet" type="text/css" href="../../css/frame.css" />--%>
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="../../js/myext.js"></script>
    <script type="text/javascript" src="../../js/mootools.js"></script>
    <script type="text/javascript" src="../../js/jquery-1.5.min.js"></script>
</head>
<body>
    <form id="form1" runat="server">
    <div class="tb">
        业务账务查询
    </div>
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
    <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
            <asp:BulletedList ID="bulMsgShow" runat="server" />
            <script runat="server">public override void ErrorMsgShow() { ErrorMsgHelper(bulMsgShow); }</script>
            <asp:HiddenField ID="hidShowCheckQuery" runat="server" />
            <asp:HiddenField ID="hidRemind" runat="server" />
            <asp:HiddenField ID="hidApprove" runat="server" />
            <div class="con">
                <div class="card">
                    查询</div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td>
                                <div align="right">
                                    业务交易类型:</div>
                            </td>
                            <td>
                                <asp:DropDownList ID="selTradeType" CssClass="inputmid" runat="server">
                                </asp:DropDownList>
                            </td>
                            <td>
                                <div align="right">
                                    日期:</div>
                            </td>
                            <td>
                                <asp:TextBox runat="server" ID="txtFromDate" MaxLength="8" CssClass="input"></asp:TextBox>
                                <asp:Label ID="lbWh" runat="server" Text="-"></asp:Label>
                                <asp:TextBox runat="server" ID="txtToDate" MaxLength="8" CssClass="input"></asp:TextBox>
                                <ajaxToolkit:CalendarExtender ID="FromDateCalendar" runat="server" TargetControlID="txtFromDate"
                                    Format="yyyyMMdd" />
                                <ajaxToolkit:CalendarExtender ID="ToDateCalendar" runat="server" TargetControlID="txtToDate"
                                    Format="yyyyMMdd" />
                            </td>
                            <td>
                                <div align="right">
                                </div>
                            </td>
                            <td>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    业务交易对象:</div>
                            </td>
                            <td>
                                <asp:TextBox runat="server" ID="txtName" CssClass="input"></asp:TextBox>
                            </td>
                            <td>
                                <div align="right">
                                    业务金额:</div>
                            </td>
                            <td>
                                <asp:TextBox runat="server" ID="txtTradeFromMoney" CssClass="input"></asp:TextBox>
                                -
                                <asp:TextBox runat="server" ID="txtTradeToMoney" CssClass="input"></asp:TextBox>
                            </td>
                            <td colspan="1">
                            </td>
                            <td>
                                <asp:Button runat="server" CssClass="button1" ID="btnQuery" Text="查询" OnClick="btnQuery_Click" />
                            </td>
                        </tr>
                    </table>
                </div>
                <asp:HiddenField ID="hidTypeValue" runat="server" />
                <asp:HiddenField ID="hidDate" runat="server" />
                <div style="width: 99%; background-color: #ddddff; border: 1px solid #aaaaff; margin-top: 5px;
                    margin-left: 5px;" id="supplyUseCard">
                    <div class="base">
                        业务帐务</div>
                    <div class="kuang5">
                        <div class="gdtb" style="height: 300px; overflow: auto;">
                            <asp:GridView ID="gvTrade" runat="server" Width="98%" CssClass="tab1" HeaderStyle-CssClass="tabbt"
                                FooterStyle-CssClass="tabcon" AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel"
                                PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top"
                                AllowPaging="True" PageSize="50" AutoGenerateColumns="False" OnRowCreated="gvTrade_RowCreated"
                                OnPageIndexChanging="gvTrade_PageIndexChanging" OnSelectedIndexChanged="gvTrade_SelectedIndexChanged"
                                OnRowDataBound="gvTrade_RowDataBound">
                                <Columns>
                                    <asp:BoundField DataField="交易时间" HeaderText="交易日期" />
                                    <asp:BoundField DataField="未匹配金额" HeaderText="未匹配金额" />
                                    <asp:BoundField DataField="交易金额" HeaderText="交易金额" />
                                    <asp:BoundField DataField="交易对象" HeaderText="交易对象" />
                                    <asp:BoundField DataField="交易类型" HeaderText="交易类型" />
                                    <asp:BoundField DataField="对方开户行" HeaderText="对方开户行" />
                                    <asp:BoundField DataField="对方开户名" HeaderText="对方开户名" />
                                    <asp:BoundField DataField="TRADEID" HeaderText="TRADEID" />
                                </Columns>
                                <EmptyDataTemplate>
                                    <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                        <tr class="tabbt">
                                            <td>
                                                交易日期
                                            </td>
                                            <td>
                                                未匹配金额
                                            </td>
                                            <td>
                                                交易金额
                                            </td>
                                            <td>
                                                交易对象
                                            </td>
                                            <td>
                                                交易类型
                                            </td>
                                            <td>
                                                对方开户行
                                            </td>
                                            <td>
                                                对方开户名
                                            </td>
                                        </tr>
                                    </table>
                                </EmptyDataTemplate>
                            </asp:GridView>
                        </div>
                    </div>
                </div>
                <div style="width: 99%; background-color: #ddddff; border: 1px solid #aaaaff; margin-top: 5px;
                    margin-left: 5px;" id="Div1">
                    <div class="base">
                        匹配业务信息</div>
                    <div class="kuang5">
                        <div class="gdtb" style="height: 300px; overflow: auto;">
                            <asp:GridView ID="gvList" Width="100%" CssClass="tab1" HeaderStyle-CssClass="tabbt"
                                FooterStyle-CssClass="tabcon" AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel"
                                PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top"
                                runat="server" AutoGenerateColumns="false">
                                <Columns>
                                    <asp:TemplateField>
                                        <HeaderTemplate>
                                            <asp:CheckBox ID="chkAll" runat="server" AutoPostBack="true" OnCheckedChanged="chkList_CheckedChanged" />
                                        </HeaderTemplate>
                                        <ItemTemplate>
                                            <asp:CheckBox ID="chkList" runat="server" />
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:BoundField DataField="BANKTRADEID" HeaderText="银行流水号" />
                                    <asp:BoundField DataField="匹配金额" HeaderText="匹配金额" />
                                    <asp:BoundField DataField="匹配日期" HeaderText="匹配日期" DataFormatString="{0:yyyyMMdd}" />
                                    <asp:BoundField DataField="匹配操作员工" HeaderText="匹配操作员工" />
                                    <asp:BoundField DataField="操作部门" HeaderText="操作部门" />
                                    <asp:BoundField DataField="银行金额" HeaderText="银行金额" />
                                    <asp:BoundField DataField="银行名称" HeaderText="银行名称" />
                                    <asp:BoundField DataField="对方开户行" HeaderText="对方开户行" />
                                    <asp:BoundField DataField="交易日期" HeaderText="交易日期" DataFormatString="{0:yyyyMMdd}" />
                                    <asp:BoundField DataField="批次号" HeaderText="批次号" />
                                </Columns>
                                <EmptyDataTemplate>
                                    <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                        <tr class="tabbt">
                                            <td>
                                                <input type="checkbox" />
                                            </td>
                                            <td>
                                                匹配金额
                                            </td>
                                            <td>
                                                匹配日期
                                            </td>
                                            <td>
                                                匹配操作员工
                                            </td>
                                            <td>
                                                操作部门
                                            </td>
                                            <td>
                                                银行金额
                                            </td>
                                            <td>
                                                银行名称
                                            </td>
                                            <td>
                                                对方开户行
                                            </td>
                                            <td>
                                                交易日期
                                            </td>
                                            <td>
                                                批次号
                                            </td>
                                        </tr>
                                    </table>
                                </EmptyDataTemplate>
                            </asp:GridView>
                        </div>
                    </div>
                </div>
                <div style="width: 99%; background-color: #ddddff; border: 1px solid #aaaaff; margin-top: 5px;
                    margin-left: 5px;" id="Div2">
                    <div class="base">
                        修改业务信息</div>
                    <div class="kuang5">
                        <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                            <tr>
                                <td width="5%" align="right">
                                    <div>
                                        业务金额:</div>
                                </td>
                                <td width="20%" align="left">
                                    <asp:TextBox runat="server" ID="txtMoney" CssClass="input"></asp:TextBox>
                                </td>
                                <td>
                                </td>
                                <td>
                                </td>
                            </tr>
                        </table>
                    </div>
                </div>
                <div class="btns">
                    <table width="200px" border="0" align="right" cellpadding="0" cellspacing="0">
                        <asp:HiddenField ID="hidTrade" runat="server" />
                        <tr>
                            <td>
                                <asp:HiddenField ID="hidMoney" runat="server" />
                                <asp:Button ID="btnUpdate" Text="更新" CssClass="button1" runat="server" OnClick="btnUpdate_Click" />
                            </td>
                            <td>
                                <asp:Button ID="btnCancel" Text="取消匹配" CssClass="button1" runat="server" OnClick="btnCancel_Click" />
                            </td>
                        </tr>
                    </table>
                </div>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
    </form>
</body>
</html>

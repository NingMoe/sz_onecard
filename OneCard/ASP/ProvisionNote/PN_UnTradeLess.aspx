<%@ Page Language="C#" AutoEventWireup="true" EnableEventValidation="false" CodeFile="PN_UnTradeLess.aspx.cs"
    Inherits="ASP_ProvisionNote_PN_UnTradeLess" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>不匹配业务帐务</title>
    <%--<link rel="stylesheet" type="text/css" href="../../css/frame.css" />--%>
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="../../js/myext.js"></script>
    <script type="text/javascript" src="../../js/mootools.js"></script>
    <script type="text/javascript" src="../../js/jquery-1.5.min.js"></script>
    <script type="text/javascript">
        function SelectBankAll(tempControl) {

            var theBox = tempControl;
            xState = theBox.checked;
            var inputs = document.getElementById("gvBank").getElementsByTagName("input");
            for (i = 0; i < inputs.length; i++)
                if (inputs[i].type == "checkbox") {
                    if (inputs[i].checked != xState)
                        inputs[i].click();
                }
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
    <div class="tb">
        不匹配业务取消
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
                                    日期:</div>
                            </td>
                            <td>
                                <asp:TextBox runat="server" ID="txtFromDate" MaxLength="8" CssClass="input"></asp:TextBox>
                                -
                                <asp:TextBox runat="server" ID="txtToDate" MaxLength="8" CssClass="input"></asp:TextBox>
                                <ajaxToolkit:CalendarExtender ID="CalendarExtender1" runat="server" TargetControlID="txtFromDate"
                                    Format="yyyyMMdd" />
                                <ajaxToolkit:CalendarExtender ID="CalendarExtender2" runat="server" TargetControlID="txtToDate"
                                    Format="yyyyMMdd" />
                            </td>
                            <td>
                                <div align="right">
                                    </div>
                            </td>
                            <td>
                            </td>
                            <td>
                                <asp:Button runat="server" CssClass="button1" ID="btnQuery" Text="查询" OnClick="btnQuery_Click" />
                            </td>
                        </tr>
                    </table>
                </div>
                <asp:HiddenField ID="hidTypeValue" runat="server" />
                <asp:HiddenField ID="hidDate" runat="server" />
                    <table width="100%">
                        <tr>
                            <td width="100%">
                                <div style="width: 99%; background-color: #ddddff; border: 1px solid #aaaaff; margin-top: 5px;
                                    margin-left: 5px;" id="supplyUseCard">
                                    <div class="base">
                                        银行帐务</div>
                                    <div class="kuang5">
                                    <div class="gdtb" style="height: 330px; overflow: auto;">
                                        <asp:GridView ID="gvBank" Width="100%" CssClass="tab1" HeaderStyle-CssClass="tabbt"
                                                FooterStyle-CssClass="tabcon" AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel"
                                                PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top"
                                                runat="server" AutoGenerateColumns="false" OnRowDataBound="gvBank_RowDataBound"
                                                OnPageIndexChanging="gvBank_Page" PageSize="50">
                                                <Columns>
                                                    <asp:TemplateField>
                                                        <HeaderTemplate>
                                                            <asp:CheckBox ID="chkAllBank" runat="server" onclick="SelectBankAll(this);" />
                                                        </HeaderTemplate>
                                                        <ItemTemplate>
                                                            <asp:CheckBox ID="chkBankList" runat="server" />
                                                        </ItemTemplate>
                                                    </asp:TemplateField>
                                                    <asp:BoundField DataField="交易时间" HeaderText="交易时间" />
                                                    <asp:BoundField DataField="未匹配金额" HeaderText="未匹配金额" />
                                                    <asp:BoundField DataField="交易金额" HeaderText="交易金额" />
                                                    <asp:BoundField DataField="交易对象" HeaderText="交易对象" />
                                                    <asp:BoundField DataField="交易类型" HeaderText="交易类型" />
                                                    <asp:BoundField DataField="BFJTRADETYPE" HeaderText="业务类型" />
                                                    <asp:BoundField DataField="对方开户行" HeaderText="对方开户行" />
                                                    <asp:BoundField DataField="对方开户名" HeaderText="对方开户名" />
                                                    <asp:BoundField DataField="OTHERBANKACCOUNT" HeaderText="对方银行账号" />
                                                    <asp:BoundField DataField="ISCASH" HeaderText="是否现金" />
                                                    <asp:BoundField DataField="TRADEID" HeaderText="TRADEID" />
                                                </Columns>
                                                <EmptyDataTemplate>
                                                    <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                                        <tr class="tabbt">
                                                            <td>
                                                                <input type="checkbox" />
                                                            </td>
                                                            <td>
                                                                交易时间
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
                                                                业务类型
                                                            </td>
                                                            <td>
                                                                对方开户行
                                                            </td>
                                                            <td>
                                                                对方开户名
                                                            </td>
                                                            <td>
                                                                对方银行账号
                                                            </td>
                                                            <td>
                                                                是否现金
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </EmptyDataTemplate>
                                            </asp:GridView>
                                        </div>
                                    </div>
                                </div>
                            </td>
                        </tr>
                    </table>
                <div class="btns">
                    <table width="200px" align="right" border="0" cellpadding="0" cellspacing="0">
                        <tr>
                         <td align="left">
                                <asp:Button ID="btnTrade" Text="匹配" CssClass="button1" runat="server" OnClick="btnTrade_Click" />
                            </td>
                            <td align="left">
                                <asp:Button ID="btnSubmit" Text="撤销" CssClass="button1" runat="server" OnClick="btnSubmit_Click" />
                            </td>
                            <td align="left">
                                <asp:Button ID="btnHide" Text="隐藏" CssClass="button1" runat="server" OnClick="btnHide_Click" />
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

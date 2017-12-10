<%@ Page Language="C#" AutoEventWireup="true" EnableEventValidation="false" CodeFile="PN_DeptTransfer.aspx.cs"
    Inherits="ASP_ProvisionNote_PN_DeptTransfer" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>解款确认</title>
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

        function SumBankMoney(thisControl) {
            var gv = document.getElementById("gvBank");
            var inputs = gv.getElementsByTagName("input");
            var vale = 0;

            for (var i = 0; i < inputs.length; i++) {
                if (inputs[i].type == "checkbox" && inputs[i].checked && gv.rows[i].cells[2].innerText != "未匹配金额") {
                    vale += Number(gv.rows[i].cells[2].innerText);
                }
            }

            document.getElementById('labBank').innerText = Number(vale).toFixed(2); ;
        }

        function SelectTradeAll(tempControl) {

            var theBox = tempControl;
            xState = theBox.checked;
            var inputs = document.getElementById("gvTrade").getElementsByTagName("input");
            for (i = 0; i < inputs.length; i++)
                if (inputs[i].type == "checkbox") {
                    if (inputs[i].checked != xState)
                        inputs[i].click();
                }
        }

        function SumTradeMoney(thisControl) {
            var gv = document.getElementById("gvTrade");
            var inputs = gv.getElementsByTagName("input");
            var vale = 0;

            for (var i = 0; i < inputs.length; i++) {
                if (inputs[i].type == "checkbox" && inputs[i].checked && gv.rows[i].cells[2].innerText != "未匹配金额") {
                    vale += Number(gv.rows[i].cells[2].innerText);
                }
            }

            document.getElementById('labTrade').innerText = Number(vale).toFixed(2); ;
        }
        

    </script>
</head>
<body>
    <form id="form1" runat="server">
    <div class="tb">
        网点解款确认
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
                                    操作类型:</div>
                            </td>
                            <td>
                                <asp:DropDownList ID="selTradeType" runat="server" OnSelectedIndexChanged="selTradeType_Changed"
                                    AutoPostBack="true">
                                    <asp:ListItem Text="匹配" Value="0" Selected="True" />
                                    <asp:ListItem Text="取消匹配" Value="1" />
                                </asp:DropDownList>
                            </td>
                            <td>
                                <div align="right">
                                    部门名称:</div>
                            </td>
                            <td>
                                <asp:DropDownList ID="selDept" runat="server" CssClass="inputmid">
                                </asp:DropDownList>
                            </td>
                            <td align="right">
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    <asp:Label ID="lbFromName" runat="server" Text="日期:"></asp:Label></div>
                            </td>
                            <td>
                                <asp:TextBox runat="server" ID="txtFromDate" MaxLength="8" CssClass="input"></asp:TextBox>
                                <asp:Label ID="lbWh" runat="server" Text="-"></asp:Label>
                                <asp:TextBox runat="server" ID="txtToDate" MaxLength="8" CssClass="input"></asp:TextBox>
                                <ajaxToolkit:CalendarExtender ID="CalendarExtender1" runat="server" TargetControlID="txtFromDate"
                                    Format="yyyyMMdd" />
                                <ajaxToolkit:CalendarExtender ID="FCalendar1" runat="server" TargetControlID="txtToDate"
                                    Format="yyyyMMdd" />
                            </td>
                            <td>
                                <div align="right">
                                    银行金额范围:</div>
                            </td>
                            <td>
                                <asp:TextBox runat="server" ID="txtFromMoney" CssClass="input"></asp:TextBox>
                                -
                                <asp:TextBox runat="server" ID="txtToMoney" CssClass="input"></asp:TextBox>
                            </td>
                            <td>
                                <asp:Button ID="Button1" CssClass="button1" runat="server" Text="查询" OnClick="btnQuery_Click" />
                            </td>
                        </tr>
                    </table>
                </div>
                <asp:HiddenField ID="hidTypeValue" runat="server" />
                <table width="100%">
                    <tr>
                        <td width="50%">
                            <div style="width: 99%; background-color: #ddddff; border: 1px solid #aaaaff; margin-top: 5px;
                                margin-left: 5px;" id="supplyUseCard">
                                <div class="base">
                                    银行帐务</div>
                                <div class="kuang5">
                                    <div class="gdtb" style="height: 300px; overflow: auto;">
                                        <asp:GridView ID="gvBank" Width="140%" CssClass="tab1" HeaderStyle-CssClass="tabbt"
                                            FooterStyle-CssClass="tabcon" AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel"
                                            PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top"
                                            runat="server" AutoGenerateColumns="false" OnRowDataBound="gvBank_RowDataBound">
                                            <Columns>
                                                <asp:TemplateField>
                                                    <HeaderTemplate>
                                                        <asp:CheckBox ID="chkAllBank" runat="server" onclick="SelectBankAll(this);" />
                                                    </HeaderTemplate>
                                                    <ItemTemplate>
                                                        <asp:CheckBox ID="chkBankList" runat="server" onclick="SumBankMoney(this);" />
                                                    </ItemTemplate>
                                                </asp:TemplateField>
                                                <asp:BoundField DataField="文件日期" HeaderText="文件日期" />
                                                <asp:BoundField DataField="未匹配金额" HeaderText="未匹配金额" />
                                                <asp:BoundField DataField="交易金额" HeaderText="交易金额" />
                                                <asp:BoundField DataField="银行名称" HeaderText="银行名称" />
                                                <asp:BoundField DataField="业务类型" HeaderText="业务类型" />
                                                <asp:BoundField DataField="对方银行帐号" HeaderText="对方银行帐号" />
                                                <asp:BoundField DataField="业务摘要" HeaderText="业务摘要" />
                                                <asp:BoundField DataField="TRADEID" HeaderText="TRADEID" />
                                            </Columns>
                                            <EmptyDataTemplate>
                                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                                    <tr class="tabbt">
                                                        <td>
                                                            <input type="checkbox" />
                                                        </td>
                                                        <td>
                                                            文件日期
                                                        </td>
                                                        <td>
                                                            未匹配金额
                                                        </td>
                                                        <td>
                                                            交易金额
                                                        </td>
                                                        <td>
                                                            银行名称
                                                        </td>
                                                        <td>
                                                            银行行号
                                                        </td>
                                                        <td>
                                                            对方银行帐号
                                                        </td>
                                                        <td>
                                                            业务摘要
                                                        </td>
                                                    </tr>
                                                </table>
                                            </EmptyDataTemplate>
                                        </asp:GridView>
                                    </div>
                                </div>
                            </div>
                        </td>
                        <td width="50%">
                            <div style="width: 98%; background-color: #ddddff; border: 1px solid #aaaaff; margin-top: 5px;
                                margin-left: 5px;" id="supplyUseCardNo">
                                <div class="jieguo">
                                    业务帐务</div>
                                <div class="kuang5">
                                    <div class="gdtb" style="height: 300px; overflow: auto;">
                                        <asp:GridView ID="gvTrade" runat="server" Width="140%" CssClass="tab1" HeaderStyle-CssClass="tabbt"
                                            FooterStyle-CssClass="tabcon" AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel"
                                            PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top"
                                            AutoGenerateColumns="False" OnRowDataBound="gvTrade_RowDataBound">
                                            <Columns>
                                                <asp:TemplateField>
                                                    <HeaderTemplate>
                                                        <asp:CheckBox ID="chkAllTrade" runat="server" onclick="SelectTradeAll(this);" />
                                                    </HeaderTemplate>
                                                    <ItemTemplate>
                                                        <asp:CheckBox ID="chkTradeList" runat="server" onclick="SumTradeMoney(this);" />
                                                    </ItemTemplate>
                                                </asp:TemplateField>
                                                <asp:BoundField DataField="交易时间" HeaderText="交易日期" />
                                                <asp:BoundField DataField="未匹配金额" HeaderText="未匹配金额" />
                                                <asp:BoundField DataField="交易金额" HeaderText="交易金额" />
                                                <asp:BoundField DataField="交易对象" HeaderText="交易对象" />
                                                <asp:BoundField DataField="交易类型" HeaderText="交易类型" />
                                                <asp:BoundField DataField="OTHERBANKACCOUNT" HeaderText="业务摘要" />
                                                <asp:BoundField DataField="TRADEID" HeaderText="TRADEID" />
                                            </Columns>
                                            <EmptyDataTemplate>
                                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                                    <tr class="tabbt">
                                                        <td>
                                                            <input type="checkbox" />
                                                        </td>
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
                                                            业务摘要
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
                    <tr>
                        <td>
                            小计：
                            <asp:Label ID="labBank" runat="server" Text="0.00"></asp:Label>
                        </td>
                        <td>
                            小计：
                            <asp:Label ID="labTrade" runat="server" Text="0.00"></asp:Label>
                        </td>
                    </tr>
                </table>
            </div>
            <div class="btns">
                <table width="200px" border="0" align="right" cellpadding="0" cellspacing="0">
                    <tr>
                        <td>
                            <asp:Button ID="btnSubmit" Text="确定" CssClass="button1" runat="server" OnClick="btnSubmit_Click" />
                        </td>
                    </tr>
                </table>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
    </form>
</body>
</html>

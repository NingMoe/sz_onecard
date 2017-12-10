<%@ Page Language="C#" AutoEventWireup="true" CodeFile="GC_AccountQueryAndMaintain.aspx.cs"
    Inherits="ASP_GroupCard_GC_AccountQueryAndMaintain" EnableEventValidation="false" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>账单查询及维护</title>
    <%--<link rel="stylesheet" type="text/css" href="../../css/frame.css" />--%>
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="../../js/printorder.js"></script>
    <script type="text/javascript" src="../../js/myext.js"></script>
    <script type="text/javascript" src="../../js/jquery-1.5.min.js"></script>
    <script type="text/javascript" src="../../js/Window.js"></script>
    <script type="text/javascript">
        function refundMoney() {
            MyExtConfirm('确认', '是否确认退款金额：' + $get('hidLeftMoney').value + '元?', refundSubmit);
            return false;
        }

        function refundSubmit(btn) {
            if (btn == 'no') {

            }
            else {
                $get('btnRefundSubmit').click();
            }
        }

        function deleteCheck() {
            MyExtConfirm('确认', '是否确认删除账单?', deleteSubmit);
            return false;
        }

        function deleteSubmit(btn) {
            if (btn == 'no') {

            }
            else {
                $get('btnDeleteSubmit').click();
            }
        }
    </script>
    <style type="text/css">
        table.data
        {
            font-size: 90%;
            border-collapse: collapse;
            border: 0px solid black;
        }
        table.data th
        {
            background: #bddeff;
            width: 25em;
            text-align: left;
            padding-right: 8px;
            font-weight: normal;
            border: 1px solid black;
        }
        table.data td
        {
            background: #ffffff;
            vertical-align: middle;
            padding: 0px 2px 0px 2px;
            border: 1px solid black;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
    <div class="tb">
        账单查询及维护
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
            <div class="con">
                <div class="base">
                    账单查询及维护</div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td width="8%">
                                <div align="right">
                                    户名:</div>
                            </td>
                            <td width="44%" colspan='3'>
                                <asp:TextBox ID="txtAccountName" CssClass="inputmid" runat="server" AutoPostBack="true"
                                    OnTextChanged="queryAccountName"></asp:TextBox>
                                <asp:DropDownList ID="selAccountName" CssClass="inputmid" Width="206" runat="server"
                                    AutoPostBack="true" OnSelectedIndexChanged="selAccountName_Changed">
                                </asp:DropDownList>
                            </td>
                            <td width="10%">
                                <div align="right">
                                    录入员工:</div>
                            </td>
                            <td width="14%">
                                <asp:DropDownList ID="selStaff" CssClass="inputmid" runat="server">
                                </asp:DropDownList>
                            </td>
                            <td width="10%">
                                <div align="right">
                                    金额:</div>
                            </td>
                            <td width="14%">
                                <asp:TextBox ID="txtTotalMoney" CssClass="input" runat="server"></asp:TextBox>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    开始日期:</div>
                            </td>
                            <td>
                                <asp:TextBox runat="server" ID="txtFromDate" MaxLength="8" CssClass="input"></asp:TextBox>
                                <ajaxToolkit:CalendarExtender ID="CalendarExtender1" runat="server" TargetControlID="txtFromDate"
                                    Format="yyyyMMdd" />
                            </td>
                            <td>
                                <div align="right">
                                    结束日期:</div>
                            </td>
                            <td>
                                <asp:TextBox runat="server" ID="txtToDate" MaxLength="8" CssClass="input"></asp:TextBox>
                                <ajaxToolkit:CalendarExtender ID="CalendarExtender2" runat="server" TargetControlID="txtToDate"
                                    Format="yyyyMMdd" />
                            </td>
                            <td>
                                <div align="right">
                                    账单状态:</div>
                            </td>
                            <td>
                                <asp:DropDownList ID="ddlAccountState" CssClass="inputmid" runat="server">
                                </asp:DropDownList>
                            </td>
                            <td>
                                <div align="right">
                                    对方帐号:</div>
                            </td>
                            <td>
                                <asp:TextBox ID="txtAccount" CssClass="input" MaxLength="16" runat="server"></asp:TextBox>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    到账银行:</div>
                            </td>
                            <td>
                                <asp:TextBox ID="txtBankName" CssClass="input" MaxLength="16" runat="server"></asp:TextBox>
                            </td>
                            <td>
                                <div align="right">
                                    剩余金额:</div>
                            </td>
                            <td>
                               <asp:DropDownList ID="selLeftMoney" CssClass="inputmid" runat="server">
                                <asp:ListItem Text="---请选择---" Value=""></asp:ListItem>
                                <asp:ListItem Text="剩余金额大于0" Value="1"></asp:ListItem>
                                <asp:ListItem Text="剩余金额等于0" Value="2"></asp:ListItem>
                                </asp:DropDownList>
                            </td>
                            <td colspan="3">
                            </td>
                            <td>
                                <asp:Button runat="server" CssClass="button1" ID="btnQuery" Text="查询" OnClick="btnQuery_Click" />
                            </td>
                        </tr>
                    </table>
                </div>
                <div>
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td width="16%">
                                <div class="jieguo">
                                查询结果</div>
                            </td>
                            <td width="84%" align="right">
                                <asp:Button ID="btnExport" CssClass="button1" runat="server" Text="导出Excel" OnClick="btnExport_Click" />
                            </td>
                        </tr>
                    </table>
                </div>
                <div class="kuang5">
                    <div id="gvUseCard" style="height: 270px; overflow: auto; display: block">
                        <asp:GridView ID="gvAccountList" CssClass="tab2" HeaderStyle-CssClass="tabbt" FooterStyle-CssClass="tabcon"
                            AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel" PagerSettings-Mode="NumericFirstLast"
                            PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top" runat="server"
                            AutoGenerateColumns="false" Width="150%" OnSelectedIndexChanged="gvAccountList_SelectedIndexChanged"
                            OnRowCreated="gvAccountList_RowCreated" AllowPaging="true" PageSize="50" OnPageIndexChanging="gvAccountList_Page"
                            OnRowDataBound="gvAccountList_RowDataBound">
                            <Columns>
                                <asp:TemplateField>
                                    <ItemTemplate>
                                        <asp:HiddenField ID="tradID" runat="server" Value='<%#Eval("checkid")%>' />
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField DataField="TRADEDATE" HeaderText="交易日期" />
                                <asp:BoundField DataField="MONEY" HeaderText="收入金额" />
                                <asp:BoundField DataField="TOACCOUNTBANK" HeaderText="到账银行" />
                                <asp:BoundField DataField="TOACCOUNTNUMBER" HeaderText="到账帐号" />
                                <asp:BoundField DataField="USEDMONEY" HeaderText="已用金额" />
                                <asp:BoundField DataField="LEFTMONEY" HeaderText="剩余金额" />
                                <asp:BoundField DataField="ACCOUNTNAME" HeaderText="对方户名" />
                                <asp:BoundField DataField="ACCOUNTNUMBER" HeaderText="对方帐号" />
                                <asp:BoundField DataField="OPENBANK" HeaderText="对方开户行" />
                                <asp:BoundField DataField="EXPLAIN" HeaderText="交易说明" />
                                <asp:BoundField DataField="SUMMARY" HeaderText="交易摘要" />
                                <asp:BoundField DataField="POSTSCRIPT" HeaderText="交易附言" />
                            </Columns>
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                        <td>
                                            交易日期
                                        </td>
                                        <td>
                                            收入金额
                                        </td>
                                        <td>
                                            到账银行
                                        </td>
                                        <td>
                                            到账帐号
                                        </td>
                                        <td>
                                            已用金额
                                        </td>
                                        <td>
                                            剩余金额
                                        </td>
                                        <td>
                                            对方户名
                                        </td>
                                        <td>
                                            对方帐号
                                        </td>
                                        <td>
                                            对方开户行
                                        </td>
                                        <td>
                                            交易说明
                                        </td>
                                        <td>
                                            交易摘要
                                        </td>
                                        <td>
                                            交易附言
                                        </td>
                                    </tr>
                                </table>
                            </EmptyDataTemplate>
                        </asp:GridView>
                    </div>
                </div>
                <div id ="detail" runat="server" >
                <table border="0" width="95%">
                    <tr>
                        <td align="left">
                            <div class="jieguo">
                                账单信息</div>
                        </td>
                    </tr>
                </table>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td width="8%">
                                <div align="right">
                                    交易日期:</div>
                            </td>
                            <td width="8%">
                                <asp:TextBox runat="server" ID="txtTradeDate" MaxLength="8" CssClass="input"></asp:TextBox><span class="red"">*</span>
                                <ajaxToolkit:CalendarExtender ID="CalendarExtender3" runat="server" TargetControlID="txtTradeDate"
                                    Format="yyyyMMdd" />
                            </td>
                            <td width="8%">
                                <div align="right">
                                    收入金额:</div>
                            </td>
                            <td width="8%">
                                <asp:TextBox ID="txtIncome" CssClass="input" runat="server"></asp:TextBox><span class="red"">*</span>
                            </td>
                            <td width="8%">
                                <div align="right">
                                    对方开户行:</div>
                            </td>
                            <td width="8%">
                                <asp:TextBox ID="txtOtherDepositBank" CssClass="inputmid" MaxLength="50" runat="server"></asp:TextBox>
                            </td>
                            <td width="6%">
                                <div align="right">
                                    对方户名:</div>
                            </td>
                            <td width="8%">
                                <asp:TextBox ID="txtOtherAccountName" CssClass="inputmid" MaxLength="50" runat="server"></asp:TextBox>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    对方帐号:</div>
                            </td>
                            <td>
                                <asp:TextBox ID="txtOtherAccount" CssClass="inputmid" MaxLength="20" runat="server"></asp:TextBox>
                            </td>
                            <td>
                                <div align="right">
                                    交易说明:</div>
                            </td>
                            <td>
                                <asp:TextBox ID="txtTradeInstruction" CssClass="inputmid" MaxLength="100" runat="server"
                                    TextMode="MultiLine"></asp:TextBox>
                            </td>
                            <td>
                                <div align="right">
                                    交易摘要:</div>
                            </td>
                            <td>
                                <asp:TextBox ID="txtTradeSummary" CssClass="inputmid" MaxLength="100" runat="server"
                                    TextMode="MultiLine"></asp:TextBox>
                            </td>
                            <td>
                                <div align="right">
                                    交易附言:</div>
                            </td>
                            <td>
                                <asp:TextBox ID="txtTradePostscript" CssClass="inputmid" MaxLength="100" runat="server"
                                    TextMode="MultiLine"></asp:TextBox>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    到账银行:</div>
                            </td>
                            <td>
                                <asp:TextBox ID="txtPaymentBank" CssClass="inputmid" MaxLength="50" runat="server"></asp:TextBox>
                            </td>
                            <td>
                                <div align="right">
                                    到账帐号:</div>
                            </td>
                            <td colspan="5">
                                <asp:TextBox ID="txtPaymentAccount" CssClass="inputmid" MaxLength="20" runat="server"></asp:TextBox><span class="red"">*</span>
                            </td>
                        </tr>
                        <asp:HiddenField ID="hidLeftMoney" runat="server" />
                    </table>
                </div>
                <div class="btns">
                <table width="95%" border="0" cellpadding="0" cellspacing="0">
                    <tr>
                        <td width="70%">
                            &nbsp;
                        </td>
                        <td align="right">
                            <asp:Button ID="btnAdd" CssClass="button1" Text="新增" runat="server" OnClick="btnAdd_Click" />
                        </td>
                        <td align="right">
                            <asp:Button ID="btnDelete" CssClass="button1" Text="删除" runat="server"  OnClientClick="return deleteCheck()" />
                            <asp:LinkButton runat="server" ID="btnDeleteSubmit" OnClick="btnDeleteSubmit_Click" />
                        </td>
                        <td align="right">
                            <asp:Button ID="btnRefund" CssClass="button1" Text="退款" runat="server" OnClientClick="return refundMoney()" />
                            <asp:LinkButton runat="server" ID="btnRefundSubmit" OnClick="btnRefundSubmit_Click" />
                        </td>
                    </tr>
                </table>
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

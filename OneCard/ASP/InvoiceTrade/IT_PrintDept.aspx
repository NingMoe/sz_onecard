<%@ Page Language="C#" AutoEventWireup="true" CodeFile="IT_PrintDept.aspx.cs" Inherits="ASP_InvoiceTrade_IT_PrintDept" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>发票打印</title>
    <script type="text/javascript" src="../../js/print.js"></script>
    <script type="text/javascript" src="../../js/myext.js"></script>
    <script type="text/javascript" src="../../js/currency.js"></script>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <link href="../../css/invoice.css" rel="stylesheet" type="text/css" />
    <script language="javascript" type="text/javascript">
        function SelectAllCheckBox(chk) {

            var oItem = chk.children;
            var theBox = (chk.type == "checkbox") ? chk : chk.children.item[0];
            xState = theBox.checked;
            elm = theBox.form.elements;
            for (i = 0; i < elm.length; i++) {

                if (elm[i].type == "checkbox" && elm[i].id != theBox.id) {
                    if (elm[i].checked != xState) {

                        elm[i].click();
                    }
                }
            }
        }

        function AutoCaculate(chk) {

            var tblRow = chk.parentNode.parentNode;
            var volumeno = tblRow.cells[7].innerText;
            var invoiceno = tblRow.cells[8].innerText;
            var money = tblRow.cells[4].innerText;

            var txtAmount = document.getElementById("txtAmount");
            if (txtAmount.value == " " || txtAmount.value == "" || txtAmount.value == "NaN") {
                txtAmount.value == 0.00;
            }

            if (chk.checked) {
                if (volumeno != " " || invoiceno != " ") {

                    alert("该笔已打印");
                    chk.checked = false;
                    return;
                }

                if (money == 'NaN')
                    return;

                txtAmount.value = (parseFloat(money) + parseFloat(txtAmount.value)).toFixed(2);
            }
            else {
                if (money == 'NaN')
                    return;

                txtAmount.value = (parseFloat(txtAmount.value) - parseFloat(money)).toFixed(2);
            }

            sumCurrency('txtAmount', 'txtTotal', 'txtTotal2');

        }

        function sumCurrency(txtAmount, txtTotal1, txtTotal2) {
            var sum = 0.00;
            var el1 = document.getElementById(txtAmount);
            if (el1.value)
                sum = sum + Number(el1.value);

            var eltotal2 = document.getElementById(txtTotal2);
            eltotal2.value = sum;

            var cn_sum = convertCurrency(sum);
            var eltotal1 = document.getElementById(txtTotal1);
            eltotal1.value = cn_sum;
        }

        function printFaPiao() {
            printdiv('printfapiao');
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
    <div class="tb">
        发票 -> 网点发票打印</div>
    <ajaxToolkit:ToolkitScriptManager runat="Server" EnableScriptGlobalization="true"
        EnableScriptLocalization="true" ID="ScriptManager2" />
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
            <!-- #include file="../../ErrorMsg.inc" -->
            <aspControls:PrintFaPiao ID="ptnFaPiao" runat="server" PrintArea="printfapiao" />
            <asp:HiddenField ID="hidPrinted" Value="false" runat="server" />
            <div class="con">
                <div class="card">
                    查询条件</div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td width="7%">
                                <div align="right">
                                    起始卡号：</div>
                            </td>
                            <td width="15%">
                                <asp:TextBox ID="txtBeginCardNo" CssClass="input" runat="server" MaxLength="19"></asp:TextBox>
                            </td>
                            <td width="7%">
                                <div align="right">
                                    终止卡号：
                                </div>
                            </td>
                            <td width="15%">
                                <asp:TextBox ID="txtEndCardNo" CssClass="input" runat="server" MaxLength="19"></asp:TextBox>
                            </td>
                            <td width="7%">
                                <div align="right">
                                    部门:</div>
                            </td>
                            <td width="15%">
                                <asp:DropDownList ID="selDept" CssClass="input" runat="server" AutoPostBack="true"
                                    OnSelectedIndexChanged="selDept_Changed">
                                </asp:DropDownList>
                            </td>
                            <td width="7%">
                                <div align="right">
                                    员工:</div>
                            </td>
                            <td width="15%">
                                <asp:DropDownList ID="selStaff" CssClass="input" runat="server">
                                </asp:DropDownList>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    业务类型：
                                </div>
                            </td>
                            <td>
                                <asp:DropDownList ID="selTradeType" AutoPostBack="true" OnSelectedIndexChanged="selTradeType_Changed"
                                    CssClass="input" runat="server">
                                    <asp:ListItem Text="普通充值" Value="1"></asp:ListItem>
                                    <asp:ListItem Text="充值卡售出" Value="2"></asp:ListItem>
                                    <asp:ListItem Text="礼金卡售出" Value="3"></asp:ListItem>
                                    <asp:ListItem Text="代理充值" Value="4"></asp:ListItem>
                                    <asp:ListItem Text="省卡充值" Value="5"></asp:ListItem>
                                    <asp:ListItem Text="手Q充值" Value="6"></asp:ListItem>
                                    <asp:ListItem Text="充值补登" Value="7"></asp:ListItem>
                                </asp:DropDownList>
                            </td>
                            <td>
                                <div align="right">
                                    开始日期：</div>
                            </td>
                            <td>
                                <asp:TextBox ID="txtBeginDate" CssClass="input" runat="server" MaxLength="10"></asp:TextBox>
                                <ajaxToolkit:CalendarExtender ID="BeginCalendar" runat="server" TargetControlID="txtBeginDate"
                                    Format="yyyy-MM-dd" />
                            </td>
                            <td>
                                <div align="right">
                                    结束日期：</div>
                            </td>
                            <td>
                                <asp:TextBox ID="txtEndDate" CssClass="input" runat="server" MaxLength="10"></asp:TextBox>
                                <ajaxToolkit:CalendarExtender ID="EndCalendar" runat="server" TargetControlID="txtEndDate"
                                    Format="yyyy-MM-dd" />
                            </td>
                            <td align="right">
                            </td>
                            <td align="center">
                                <asp:Button ID="btnQuery" CssClass="button1" OnClick="btnQuery_Click" Text="查询" runat="server" />
                            </td>
                        </tr>
                    </table>
                </div>
                <div class="card">
                    查询结果
                </div>
                <div class="kuang5">
                    <div class="gdtb" style="height: 120px; padding: 5px 0 0 0;">
                        <asp:GridView ID="lvwInvoice" runat="server" Width="1150" CssClass="tab1" HeaderStyle-CssClass="tabbt"
                            AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel" AllowPaging="True"
                            PageSize="200" OnPageIndexChanging="lvwInvoice_Page" PagerSettings-Mode="NumericFirstLast"
                            PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top" AutoGenerateColumns="False"
                            OnRowDataBound="lvwInvoice_RowDataBound">
                            <Columns>
                                <asp:TemplateField>
                                    <HeaderTemplate>
                                        <asp:CheckBox ID="AllCheckBox" Text="全选" runat="server" onclick="SelectAllCheckBox(this)"/>
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                        <asp:CheckBox ID="ItemCheckBox" runat="server" onclick='javascript:AutoCaculate(this)' />
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField DataField="TRADEID" HeaderText="交易流水号" />
                                <asp:BoundField DataField="CARDNO" HeaderText="卡号(段)" />
                                <asp:BoundField DataField="TRADETYPE" HeaderText="业务类型" />
                                <asp:BoundField DataField="CURRENTMONEY" HeaderText="交易金额" />
                                <asp:BoundField DataField="OPERATESTAFFNO" HeaderText="操作员工" />
                                <asp:BoundField DataField="OPERATETIME" HeaderText="操作时间" />
                                <asp:BoundField DataField="VOLUMENO" HeaderText="发票代码" />
                                <asp:BoundField DataField="INVOICENO" HeaderText="发票号码" />
                            </Columns>
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                        <td>
                                            交易流水号
                                        </td>
                                        <td>
                                            卡号(段)
                                        </td>
                                        <td>
                                            业务类型
                                        </td>
                                        <td>
                                            交易金额
                                        </td>
                                        <td>
                                            操作员工
                                        </td>
                                        <td>
                                            操作时间
                                        </td>
                                        <td>
                                            发票代码
                                        </td>
                                        <td>
                                            发票号码
                                        </td>
                                        <td>
                                        </td>
                                    </tr>
                                </table>
                            </EmptyDataTemplate>
                        </asp:GridView>
                    </div>
                </div>
                <div class="card">
                    发票打印
                </div>
                <div class="kuang5">
                    <table width="806" border="0" cellpadding="0" cellspacing="0">
                        <tr>
                            <td width="60" height="38">
                                &nbsp;
                            </td>
                            <td colspan="6">
                                <table width="100%">
                                    <tr>
                                        <td width="60">
                                            <div align="right">
                                                <asp:Label ID="lblValidateCode" runat="server"></asp:Label></div>
                                        </td>
                                        <td class="bt">
                                            <div align="center">
                                                苏州市民卡有限公司通用机打发票
                                            </div>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                            <td width="65">
                                &nbsp;
                            </td>
                        </tr>
                        <tr style="height: 15px">
                            <td colspan="8">
                            </td>
                        </tr>
                        <tr style="height: 25px">
                            <td width="10px">
                                &nbsp;
                            </td>
                            <td class="head" colspan="5">
                                开票日期：&nbsp;&nbsp;<asp:TextBox ID="txtDate" CssClass="labeltext" ReadOnly="true" runat="server"></asp:TextBox>
                                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 行业分类：&nbsp;&nbsp;
                                <asp:DropDownList ID="selCalling" Enabled="false" CssClass="input" runat="server">
                                    <asp:ListItem Value="0799" Selected="True">其他服务</asp:ListItem>
                                </asp:DropDownList>
                            </td>
                            <td align="left">
                            </td>
                            <td>
                            </td>
                            <td>
                                &nbsp;
                            </td>
                        </tr>
                        <tr>
                            <td height="78">
                                &nbsp;
                            </td>
                            <td colspan="6">
                                <table style="border: 2px; border-color: #000000; border-style: solid">
                                    <tr>
                                        <td width="10px">
                                            &nbsp;
                                        </td>
                                        <td>
                                            <table width="100%" height="100" border="0" cellpadding="0" cellspacing="0">
                                                <tr>
                                                    <td width="9%" class="head">
                                                        付款方：
                                                    </td>
                                                    <td colspan="3">
                                                        <asp:TextBox ID="txtPayer" CssClass="textbox200" runat="server"></asp:TextBox>
                                                    </td>
                                                    <td width="13%" class="head">
                                                        <div align="right">
                                                            发票代码：</div>
                                                    </td>
                                                    <td width="23%">
                                                        <asp:TextBox ID="txtCode" MaxLength="12" CssClass="textbox100" runat="server"></asp:TextBox>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td width="19%" class="head">
                                                        付款方纳税人识别号：
                                                    </td>
                                                    <td colspan="5">
                                                        <asp:TextBox ID="txtPayCode" CssClass="textbox200" runat="server"></asp:TextBox>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td class="head">
                                                        收款方：
                                                    </td>
                                                    <td colspan="3">
                                                        <asp:TextBox ID="txtPayee" CssClass="labeltextlonger" MaxLength="100" ReadOnly="true"
                                                            runat="server"></asp:TextBox>
                                                    </td>
                                                    <td class="head">
                                                        <div align="right">
                                                            发票号码：</div>
                                                    </td>
                                                    <td>
                                                        <asp:TextBox ID="txtInvoiceId" CssClass="textbox100" MaxLength="8" runat="server"></asp:TextBox>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td colspan="2" class="head">
                                                        纳税人识别号：
                                                    </td>
                                                    <td width="27%" class="head">
                                                        <asp:TextBox ID="txtTaxPayerId" CssClass="labeltext" ReadOnly="true" runat="server"></asp:TextBox>
                                                    </td>
                                                    <td>
                                                    </td>
                                                    <td class="head">
                                                        <div align="right">
                                                            &nbsp;
                                                        </div>
                                                    </td>
                                                    <td>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td colspan="2" class="head">
                                                        苏信开户行：
                                                    </td>
                                                    <td width="27%" class="head">
                                                        <asp:DropDownList ID="selSZBank" CssClass="inputmidder" runat="server" AutoPostBack="true"
                                                            OnSelectedIndexChanged="selSZBank_SelectedIndexChanged">
                                                        </asp:DropDownList>
                                                    </td>
                                                    <td>
                                                    </td>
                                                    <td class="head">
                                                        <div align="right">
                                                            &nbsp;
                                                        </div>
                                                    </td>
                                                    <td>
                                                    </td>
                                                </tr>
                                            </table>
                                            <table width="679" height="210" border="0" cellpadding="0" cellspacing="0" class="">
                                                <tr>
                                                    <td height="193" colspan="4" valign="top">
                                                        <table width="100%" height="193" border="0" cellpadding="0" cellspacing="0" class="">
                                                            <tr>
                                                                <td width="69%" valign="top">
                                                                    <table width="100%" height="64" border="0" cellpadding="0" cellspacing="0" class="line3">
                                                                        <tr>
                                                                            <td width="60%">
                                                                                <div align="left" class="head">
                                                                                    项目内容</div>
                                                                            </td>
                                                                            <td>
                                                                                <div align="left" class="head">
                                                                                    金额</div>
                                                                            </td>
                                                                        </tr>
                                                                        <tr>
                                                                            <td>
                                                                                <div align="left">
                                                                                    <asp:DropDownList ID="selProj" CssClass="textbox200" runat="server">
                                                                                    </asp:DropDownList>
                                                                                </div>
                                                                            </td>
                                                                            <td>
                                                                                <div align="left">
                                                                                    <asp:TextBox ID="txtAmount" CssClass="textbox100" ReadOnly="true" Text="0.00" runat="server"></asp:TextBox>
                                                                                </div>
                                                                            </td>
                                                                        </tr>
                                                                        <tr>
                                                                            <td>
                                                                                <div align="left">
                                                                                    <asp:DropDownList ID="selProj2" Visible="false" CssClass="textbox200" runat="server">
                                                                                    </asp:DropDownList>
                                                                                </div>
                                                                            </td>
                                                                            <td>
                                                                                <div align="left">
                                                                                    <asp:TextBox ID="txtAmount2" Visible="false" CssClass="textbox100" runat="server"></asp:TextBox>
                                                                                </div>
                                                                            </td>
                                                                        </tr>
                                                                        <tr>
                                                                            <td>
                                                                                <div align="left">
                                                                                    <asp:DropDownList ID="selProj3" Visible="false" CssClass="textbox200" runat="server">
                                                                                    </asp:DropDownList>
                                                                                </div>
                                                                            </td>
                                                                            <td>
                                                                                <div align="left">
                                                                                    <asp:TextBox ID="txtAmount3" Visible="false" CssClass="textbox100" runat="server"></asp:TextBox>
                                                                                </div>
                                                                            </td>
                                                                        </tr>
                                                                        <tr>
                                                                            <td>
                                                                                <div align="left">
                                                                                    <asp:DropDownList ID="selProj4" Visible="false" CssClass="textbox200" runat="server">
                                                                                    </asp:DropDownList>
                                                                                </div>
                                                                            </td>
                                                                            <td>
                                                                                <div align="left">
                                                                                    <asp:TextBox ID="txtAmount4" Visible="false" CssClass="textbox100" runat="server"></asp:TextBox>
                                                                                </div>
                                                                            </td>
                                                                        </tr>
                                                                        <tr>
                                                                            <td>
                                                                                <div align="left">
                                                                                    <asp:DropDownList ID="selProj5" Visible="false" CssClass="textbox200" runat="server">
                                                                                    </asp:DropDownList>
                                                                                </div>
                                                                            </td>
                                                                            <td>
                                                                                <div align="left">
                                                                                    <asp:TextBox ID="txtAmount5" Visible="false" CssClass="textbox100" runat="server"></asp:TextBox>
                                                                                </div>
                                                                            </td>
                                                                        </tr>
                                                                    </table>
                                                                </td>
                                                                <td width="31%" valign="top">
                                                                    <table width="195" height="192" border="0" align="center" cellpadding="0" cellspacing="0">
                                                                        <tr>
                                                                            <td class="head" align="left">
                                                                                附注
                                                                            </td>
                                                                        </tr>
                                                                        <tr>
                                                                            <td align="left">
                                                                                <asp:TextBox ID="txtNote" Height="140" Rows="5" Columns="20" MaxLength="100" TextMode="MultiLine"
                                                                                    runat="server"></asp:TextBox>
                                                                            </td>
                                                                        </tr>
                                                                    </table>
                                                                </td>
                                                            </tr>
                                                        </table>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td width="18%">
                                                        <span class="head">合计（大写）：</span>
                                                    </td>
                                                    <td width="54%">
                                                        <asp:TextBox ID="txtTotal" CssClass="labeltextlong" ReadOnly="true" runat="server"></asp:TextBox>
                                                    </td>
                                                    <td width="11%" class="head">
                                                        ￥：
                                                    </td>
                                                    <td width="17%">
                                                        <asp:TextBox ID="txtTotal2" CssClass="labeltext" ReadOnly="true" runat="server"></asp:TextBox>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                            <td>
                                &nbsp;
                            </td>
                        </tr>
                        <tr style="height: 25px">
                            <td>
                                &nbsp;
                            </td>
                            <td width="190" class="head">
                                收款单位（盖章有效）：
                            </td>
                            <td width="160">
                                &nbsp;
                            </td>
                            <td width="70" class="head">
                            </td>
                            <td width="81">
                            </td>
                            <td width="84" class="head">
                                开票人：
                            </td>
                            <td width="96">
                                <asp:TextBox ID="txtStaff" CssClass="labeltext" ReadOnly="true" runat="server"></asp:TextBox>
                            </td>
                            <td>
                                &nbsp;
                            </td>
                        </tr>
                    </table>
                </div>
            </div>
            <div class="btns">
                <table width="100" border="0" align="right" cellpadding="0" cellspacing="0">
                    <tr>
                        <td>
                            <asp:Button ID="btnPrintFaPiao" runat="server" Text="打印发票" CssClass="button1" OnClick="Print_Click" />
                        </td>
                        <td>
                            &nbsp;
                        </td>
                        <td>
                            <asp:Button ID="btnClear" runat="server" Text="新发票" CssClass="button1" OnClick="btnClear_Click" />
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

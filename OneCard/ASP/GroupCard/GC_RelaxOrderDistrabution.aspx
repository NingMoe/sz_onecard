<%@ Page Language="C#" AutoEventWireup="true" EnableEventValidation="false" CodeFile="GC_RelaxOrderDistrabution.aspx.cs"
    Inherits="ASP_GroupCard_GC_RelaxOrderDistrabution" %>

<%@ Register Src="../../CardReader.ascx" TagName="CardReader" TagPrefix="cr" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>休闲订单配送</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="../../js/myext.js"></script>
    <script type="text/javascript" src="../../js/mootools.js"></script>
    <script type="text/javascript" src="../../js/jquery-1.5.min.js"></script>
    <script type="text/javascript" src="../../js/print.js"></script>
    <script type="text/javascript">
        function submitConfirm(remind) {

            if (true) {
                MyExtConfirm('确认',
		        '订单和账单的单位名称不一致，包括：' + remind + '<br>是否确认调配？'
		        , submitConfirmCallback);
            }

        }
        function submitConfirmCallback(btn) {
            if (btn == 'yes') {
                $get('btnConfirm').click();
            }
        }

        function SetFinanceRemark() {
            $('#hidFinanceRemark').val($('#txt').val());
        }

        function SetText() {
            if ($('#txt') != null)
                $('#txt').value = $('#hidFinanceRemark').value;
        }
        function SelectAll(tempControl) {
            //将除头模板中的其它所有的CheckBox取反 

            var theBox = tempControl;
            xState = theBox.checked;

            elem = theBox.form.elements;
            for (i = 0; i < elem.length; i++)
                if (elem[i].type == "checkbox" && elem[i].id != theBox.id) {
                    if (elem[i].checked != xState)
                        elem[i].click();
                }
        }
        function printExPress() {
            printdiv('printExpress1');
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
    <cr:CardReader ID="cardReader" runat="server" />
    <form id="form1" runat="server">
    <div class="tb">
        休闲订单配送
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
            <aspControls:PrintExpress ID="ptnExpress" runat="server" PrintArea="printExpress1" />
            <asp:BulletedList ID="bulMsgShow" runat="server" />
            <script runat="server">public override void ErrorMsgShow() { ErrorMsgHelper(bulMsgShow); }</script>
            <asp:HiddenField ID="hidShowCheckQuery" runat="server" />
            <asp:HiddenField ID="hidRemind" runat="server" />
            <asp:HiddenField ID="hidApprove" runat="server" />
            <div class="con" width="95%">
                <div class="card">
                    订单查询</div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td>
                                <div align="right">
                                    订单状态:</div>
                            </td>
                            <td>
                                <asp:DropDownList ID="selOrderStates" CssClass="inputmid" runat="server">
                                    <asp:ListItem Text="等待处理" Value="0" />
                                    <asp:ListItem Text="制卡完成" Value="1" Selected="True" />
                                    <asp:ListItem Text="已发货" Value="2" />
                                </asp:DropDownList>
                            </td>
                            <td>
                                <div align="right">
                                    订单号:</div>
                            </td>
                            <td>
                                <asp:TextBox runat="server" ID="txtOrderNo" CssClass="inputmid"></asp:TextBox>
                            </td>
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
                            <td>
                                <asp:TextBox runat="server" ID="txtToDate" MaxLength="8" CssClass="input"></asp:TextBox>
                                <ajaxToolkit:CalendarExtender ID="FCalendar2" runat="server" TargetControlID="txtToDate"
                                    Format="yyyyMMdd" />
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    用户手机号:</div>
                            </td>
                            <td>
                                <asp:TextBox runat="server" ID="txtCustPhone" MaxLength="15" CssClass="input"></asp:TextBox>
                            </td>
                            <td>
                                <div align="right">
                                    支付渠道:</div>
                            </td>
                            <td>
                                <asp:DropDownList ID="selPayCanal" CssClass="inputmid" runat="server">
                                    <asp:ListItem Text="---请选择---" Value="" />
                                    <asp:ListItem Text="支付宝" Value="01" />
                                    <asp:ListItem Text="微信" Value="02" />
                                    <asp:ListItem Text="银联" Value="03" />
                                </asp:DropDownList>
                            </td>
                            <td colspan="2">
                            </td>
                            <td align="right">
                            </td>
                            <td>
                                <asp:Button runat="server" CssClass="button1" ID="btnQuery" Text="查询" OnClick="btnQuery_Click" />
                            </td>
                        </tr>
                    </table>
                </div>
            </div>
            <asp:HiddenField runat="server" ID="hidCustPost" />
            <asp:HiddenField runat="server" ID="hidCustEmail" />
            <asp:HiddenField ID="hiddencMoney" runat="server" />
            <asp:HiddenField ID="hiddentradeno" runat="server" />
            <asp:HiddenField ID="hiddenDepositFee" runat="server" />
            <asp:HiddenField ID="hiddenCardcostFee" runat="server" />
            <asp:HiddenField ID="hidOtherFee" runat="server" />
            <asp:HiddenField ID="hiddenLabCardtype" runat="server" />
            <asp:HiddenField ID="hiddenAsn" runat="server" />
            <div style="width: 99%; background-color: #ddddff; border: 1px solid #aaaaff; margin-top: 5px;
                margin-left: 5px;" id="supplyUseCard">
                <div class="base">
                    <table border="0" width="95%">
                        <tr>
                            <td align="left">
                                <div class="jieguo">
                                    订单列表</div>
                            </td>
                            <td align="right">
                            </td>
                            <td align="right">
                                <asp:Button ID="btnPrint" CssClass="button1fix" runat="server" Text="打印" OnClick="btnPrint_Click" />
                                <asp:Button ID="btnExport" CssClass="button1fix" runat="server" Text="导出表格" OnClick="btnExport_Click" />
                            </td>
                        </tr>
                    </table>
                </div>
                <div class="kuang5">
                    <div class="gdtb" style="height: 190px;">
                        <asp:GridView ID="gvOrder" Width="100%" CssClass="tab1" HeaderStyle-CssClass="tabbt"
                            FooterStyle-CssClass="tabcon" AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel"
                            PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top"
                            runat="server" AutoGenerateColumns="false" AllowPaging="True" PageSize="10" OnPageIndexChanging="gvOrder_Page"
                            OnRowCreated="gvOrder_RowCreated" OnRowDataBound="gvOrder_RowDataBound" OnRowCommand="gvOrder_RowCommand">
                            <Columns>
                                <asp:TemplateField>
                                    <HeaderTemplate>
                                        <asp:CheckBox ID="chkAllOrder" runat="server" onclick="javascript:SelectAll(this);" />
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                        <asp:CheckBox ID="chkOrderList" runat="server" Height="20px" />
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField>
                                    <HeaderTemplate>
                                        <asp:Label ID="labClickList" runat="server" Text="查看明细"></asp:Label>
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                        <%--<asp:Button runat="server" CssClass="button1" ID="btnQueryList" Text="查看明细"/>--%>
                                        <%--<linkbutton runat="server" id="asd" text="chakan" />--%>
                                        <asp:LinkButton ID="linkQueryList" runat="server" Text="查看明细" CausesValidation="true"
                                            CommandName="QueryList" CommandArgument='<%# Eval("orderno")%>' />
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField>
                                    <HeaderTemplate>
                                        <asp:Label ID="labHeadCopName" runat="server" Text="物流公司"></asp:Label>
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                        <asp:DropDownList ID="selCopName" runat="server">
                                        </asp:DropDownList>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField>
                                    <HeaderTemplate>
                                        <asp:Label ID="labHeadCopNo" runat="server" Text="物流单号"></asp:Label>
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                        <asp:TextBox ID="txtCopNo" runat="server" CssClass="input"></asp:TextBox>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField DataField="orderno" HeaderText="订单号" />
                                <asp:BoundField DataField="orderstates" HeaderText="订单状态" />
                                <asp:BoundField DataField="custname" HeaderText="物流联系人" />
                                <asp:BoundField DataField="address" HeaderText="物流地址" />
                                <asp:BoundField DataField="custphone" HeaderText="物流电话" />
                                <asp:BoundField DataField="custpost" HeaderText="物流邮编" />
                                <asp:BoundField DataField="createtime" HeaderText="订单日期" />
                                <asp:BoundField DataField="trackingcopcode" HeaderText="物流公司名称" />
                                <asp:BoundField DataField="trackingno" HeaderText="物流单号" />
                            </Columns>
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                        <td>
                                            <input type="checkbox" />
                                        </td>
                                        <td>
                                            物流公司
                                        </td>
                                        <td>
                                            物流单号
                                        </td>
                                        <td>
                                            订单号
                                        </td>
                                        <td>
                                            订单状态
                                        </td>
                                        <td>
                                            物流联系人
                                        </td>
                                        <td>
                                            物流地址
                                        </td>
                                        <td>
                                            物流邮编
                                        </td>
                                        <td>
                                            订单日期
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
                    订单明细列表
                </div>
                <div class="kuang5">
                    <div class="gdtb" style="height: 200px;">
                        <asp:GridView ID="gvList" Width="200%" CssClass="tab1" HeaderStyle-CssClass="tabbt"
                            FooterStyle-CssClass="tabcon" AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel"
                            PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top"
                            runat="server" AutoGenerateColumns="false" OnRowDataBound="gvList_RowDataBound">
                            <Columns>
                                <asp:BoundField DataField="ordertype" HeaderText="订单类型" />
                                <asp:BoundField DataField="detailstates" HeaderText="订单状态" />
                                <asp:TemplateField>
                                    <HeaderTemplate>
                                        <asp:Label ID="labHeadPhoto" runat="server" Text="人物照片"></asp:Label>
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                        <asp:Image ID="imgPerson" runat="server" Width="50px" Height="50px" ImageUrl="~/Images/nom.jpg" />
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField>
                                    <HeaderTemplate>
                                        <asp:Label ID="labHeadPaperPhoto" runat="server" Text="身份证照片"></asp:Label>
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                        <asp:Image ID="imgIDCard" runat="server" Width="50px" Height="50px" ImageUrl="~/Images/nom.jpg" />
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField DataField="cardno" HeaderText="电子钱包卡号" />
                                <asp:BoundField DataField="packagetypename" HeaderText="套餐类型" />
                                <asp:BoundField DataField="custname" HeaderText="客户姓名" />
                                <asp:BoundField DataField="papertypename" HeaderText="证件类型" />
                                <asp:BoundField DataField="paperno" HeaderText="证件号码" />
                                <asp:BoundField DataField="custbirth" HeaderText="生日" />
                                <asp:BoundField DataField="custsex" HeaderText="性别" />
                                <asp:BoundField DataField="custphone" HeaderText="联系电话" />
                                <asp:BoundField DataField="address" HeaderText="地址" />
                                <asp:BoundField DataField="custpost" HeaderText="邮编" />
                                <asp:BoundField DataField="custemail" HeaderText="邮箱" />
                                <asp:BoundField DataField="orderno" HeaderText="订单号" />
                                <asp:BoundField DataField="paycanal" HeaderText="支付渠道" />
                                <asp:BoundField DataField="orderdetailid" HeaderText="子订单号" />
                                <asp:BoundField DataField="updatetime" HeaderText="更新日期" />
                                <asp:BoundField DataField="recename" HeaderText="收货人姓名" />
                                <asp:BoundField DataField="receaddress" HeaderText="收货人地址" />
                                <asp:BoundField DataField="recephone" HeaderText="收货人电话" />
                                <asp:BoundField DataField="recepost" HeaderText="收货人邮编" />
                                <asp:BoundField DataField="papertype" HeaderText="证件类型" />
                                <asp:BoundField DataField="packagetypecode" HeaderText="套餐类型编码" />
                                <asp:BoundField DataField="funcfee" HeaderText="功能费" />
                            </Columns>
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                        <td>
                                            <input type="checkbox" />
                                        </td>
                                        <td>
                                            订单类型
                                        </td>
                                        <td>
                                            订单状态
                                        </td>
                                        <td>
                                            人物照片
                                        </td>
                                        <td>
                                            身份证照片
                                        </td>
                                        <td>
                                            操作方式
                                        </td>
                                        <td>
                                            电子钱包卡号
                                        </td>
                                        <td>
                                            套餐类型
                                        </td>
                                        <td>
                                            客户姓名
                                        </td>
                                        <td>
                                            证件类型
                                        </td>
                                        <td>
                                            地址
                                        </td>
                                        <td>
                                            邮编
                                        </td>
                                        <td>
                                            性别
                                        </td>
                                        <td>
                                            生日
                                        </td>
                                        <td>
                                            邮箱
                                        </td>
                                        <td>
                                            订单号
                                        </td>
                                        <td>
                                            支付渠道
                                        </td>
                                        <td>
                                            子订单号
                                        </td>
                                        <td>
                                            订单日期
                                        </td>
                                    </tr>
                                </table>
                            </EmptyDataTemplate>
                        </asp:GridView>
                    </div>
                </div>
            </div>
            <div class="btns">
                <table width="300px" border="0" align="right" cellpadding="0" cellspacing="0">
                    <tr>
                        <td align="center">
                            <asp:Button ID="btnDistrabution" Text="配送" CssClass="button1" runat="server" Enabled="false"
                                OnClick="btnDistrabution_Click" />
                        </td>
                    </tr>
                </table>
            </div>
        </ContentTemplate>
        <Triggers>
            <asp:PostBackTrigger ControlID="btnExport" />
        </Triggers>
    </asp:UpdatePanel>
    </form>
</body>
</html>

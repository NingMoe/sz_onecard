<%@ Page Language="C#" AutoEventWireup="true" CodeFile="GC_OrderApprovalCheck.aspx.cs" Inherits="ASP_GroupCard_GC_OrderApprovalCheck"
EnableEventValidation="false" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>呈批单到账确认</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="../../js/myext.js"></script>
    <script type="text/javascript" src="../../js/mootools.js"></script>
    <script type="text/javascript" src="../../js/jquery-1.5.min.js"></script>
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
        function showMoreToggle() {
            $("#divCardInfoTitle").toggle("slow");
            $("#divCardInfo").toggle();

            if ($("#btnMore").val() == "显示账单查询") {
                $("#btnMore").val("隐藏账单查询");
                $("#hidShowCheckQuery").val("1");
            }
            else {
                $("#btnMore").val("显示账单查询");
                $("#hidShowCheckQuery").val("2");
            }
            return false;
        }
        function showCheckQuery() {
            $("#divCardInfoTitle").toggle();
            $("#divCardInfo").toggle();

            if ($("#btnMore").val() == "显示账单查询") {
                $("#btnMore").val("隐藏账单查询");
                $("#hidShowCheckQuery").val("1");
            }
            else {
                $("#btnMore").val("显示账单查询");
                $("#hidShowCheckQuery").val("2");
            }
            return false;
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
        订单审批
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
            <div class="con" width="95%">
                <div class="card">
                    订单查询</div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td width="8%">
                                <div align="right">
                                    单位名称:</div>
                            </td>
                            <td width="44%" colspan='3'>
                                <asp:TextBox ID="txtGroupName" CssClass="inputmid" runat="server" AutoPostBack="true"
                                    OnTextChanged="txtGroupName_Changed"></asp:TextBox>
                                <asp:DropDownList ID="selCompany" CssClass="inputmid" Width="206" runat="server"
                                    AutoPostBack="true" OnSelectedIndexChanged="selCompany_Changed">
                                </asp:DropDownList>
                            </td>
                            <td width="10%">
                                <div align="right">
                                    联系人:</div>
                            </td>
                            <td width="12%">
                                <asp:TextBox ID="txtName" CssClass="input" runat="server"></asp:TextBox>
                            </td>
                            <td width="12%">
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
                                    部门:</div>
                            </td>
                            <td>
                                <asp:DropDownList ID="selDept" CssClass="inputmid" runat="server" AutoPostBack="true"
                                    OnSelectedIndexChanged="selDept_Changed">
                                </asp:DropDownList>
                            </td>
                            <td>
                                <div align="right">
                                    经办人:</div>
                            </td>
                            <td>
                                <asp:DropDownList ID="selStaff" CssClass="inputmid" runat="server">
                                </asp:DropDownList>
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
                            <td colspan="6">
                            </td>
                            <td align="right">
                                <asp:Button runat="server" CssClass="button1" Width="100px" ID="btnMore" Text="显示账单查询"
                                    OnClientClick="return showMoreToggle();" />&nbsp; &nbsp;
                            </td>
                            <td>
                                <asp:Button runat="server" CssClass="button1" ID="btnQuery" Text="查询" OnClick="btnQuery_Click" />
                            </td>
                        </tr>
                    </table>
                </div>
                <div class="base" id="divCardInfoTitle" style="display: none">
                    账单查询</div>
                <div class="kuang5" id="divCardInfo" style="display: none">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td width="8%">
                                <div align="right">
                                    户名:</div>
                            </td>
                            <td width="44%" colspan="3">
                                <asp:TextBox ID="txtAccountName" CssClass="inputmid" runat="server" AutoPostBack="true"
                                    OnTextChanged="txtAccountName_Changed"></asp:TextBox>
                                <asp:DropDownList ID="selAccountName" CssClass="inputmid" Width="206" runat="server"
                                    AutoPostBack="true" OnSelectedIndexChanged="selAccountName_Changed">
                                </asp:DropDownList>
                            </td>
                            <td width="10%">
                                <div align="right">
                                    录入员工:</div>
                            </td>
                            <td width="12%">
                                <asp:DropDownList ID="selCheckInStaff" CssClass="inputmid" runat="server">
                                </asp:DropDownList>
                            </td>
                            <td width="12%">
                                <div align="right">
                                    金额:</div>
                            </td>
                            <td width="14%">
                                <asp:TextBox ID="txtCheckMoney" CssClass="input" runat="server"></asp:TextBox>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    开始日期:</div>
                            </td>
                            <td>
                                <asp:TextBox runat="server" ID="txtStartDate" MaxLength="8" CssClass="input"></asp:TextBox>
                                <ajaxToolkit:CalendarExtender ID="CalendarExtender1" runat="server" TargetControlID="txtStartDate"
                                    Format="yyyyMMdd" />
                            </td>
                            <td>
                                <div align="right">
                                    结束日期:</div>
                            </td>
                            <td>
                                <asp:TextBox runat="server" ID="txtEndDate" MaxLength="8" CssClass="input"></asp:TextBox>
                                <ajaxToolkit:CalendarExtender ID="CalendarExtender2" runat="server" TargetControlID="txtEndDate"
                                    Format="yyyyMMdd" />
                            </td>
                            <td>
                                <div align="right">
                                    对方帐号:</div>
                            </td>
                            <td>
                                <asp:TextBox ID="txtAccount" CssClass="input" MaxLength="16" runat="server"></asp:TextBox>
                            </td>
                            <td>
                            </td>
                            <td>
                            </td>
                        </tr>
                        <tr>
                            <td colspan="7">
                            </td>
                            <td>
                                <asp:Button runat="server" CssClass="button1" ID="Button1" Text="查询" OnClick="btnQueryCheck_Click" />
                            </td>
                        </tr>
                    </table>
                </div>
            </div>
            <div>
                <table>
                    <tr>
                        <td width="60%">
                            <div style="width: 99%;background-color: #ddddff;border: 1px solid #aaaaff;margin-top: 5px;margin-left: 5px;" id="supplyUseCard">
                                <div class="base">
                                    订单列表</div>
                                <div class="kuang5">
                                    <div class="gdtb" style="height: 250px;">
                                        <asp:GridView ID="gvOrderList" Width="140%" CssClass="tab1" HeaderStyle-CssClass="tabbt"
                                            FooterStyle-CssClass="tabcon" AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel"
                                            PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top"
                                            runat="server" AutoGenerateColumns="false" OnRowCreated="gvOrderList_RowCreated"
                                            OnSelectedIndexChanged="gvOrderList_SelectedIndexChanged">
                                            <Columns>
                                                <asp:TemplateField>
                                                    <HeaderTemplate>
                                                        <asp:CheckBox ID="chkAllOrder" runat="server" onclick="javascript:SelectAll(this);" />
                                                    </HeaderTemplate>
                                                    <ItemTemplate>
                                                        <asp:CheckBox ID="chkOrderList" runat="server" />
                                                    </ItemTemplate>
                                                </asp:TemplateField>
                                                <asp:BoundField DataField="orderno" HeaderText="订单号" />
                                                <asp:BoundField DataField="groupname" HeaderText="单位名称" />
                                                <asp:BoundField DataField="name" HeaderText="联系人" />
                                                <asp:BoundField DataField="totalmoney" HeaderText="购卡总金额(元)" />
                                                <asp:BoundField DataField="idcardno" HeaderText="身份证号码" />
                                                <asp:BoundField DataField="phone" HeaderText="联系电话" />
                                                <asp:BoundField DataField="transactor" HeaderText="经办人" />
                                                <asp:BoundField DataField="inputtime" HeaderText="录入时间" />
                                            </Columns>
                                            <EmptyDataTemplate>
                                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                                    <tr class="tabbt">
                                                        <td>
                                                            <input type="checkbox" />
                                                        </td>
                                                        <td>
                                                            订单号
                                                        </td>
                                                        <td>
                                                            单位名称
                                                        </td>
                                                        <td>
                                                            联系人
                                                        </td>
                                                        <td>
                                                            购卡总金额(元)
                                                        </td>
                                                        <td>
                                                            身份证号码
                                                        </td>
                                                        <td>
                                                            联系电话
                                                        </td>
                                                        <td>
                                                            经办人
                                                        </td>
                                                        <td>
                                                            录入时间
                                                        </td>
                                                    </tr>
                                                </table>
                                            </EmptyDataTemplate>
                                        </asp:GridView>
                                    </div>
                                </div>
                            </div>
                        </td>
                        <td>
                            <div style="width: 98%;background-color: #ddddff;border: 1px solid #aaaaff;margin-top: 5px;margin-left: 5px;" id="supplyUseCardNo">
                                <div class="jieguo">
                                    账单</div>
                                <div class="kuang5">
                                    <div class="gdtb" style="height: 250px;">
                                        <asp:GridView ID="gvResult" runat="server" Width="200%" CssClass="tab1" HeaderStyle-CssClass="tabbt"
                                            FooterStyle-CssClass="tabcon" AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel"
                                            PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top"
                                            AutoGenerateColumns="False">
                                            <Columns>
                                                <asp:TemplateField>
                                                    <HeaderTemplate>
                                                        <asp:CheckBox ID="chkAllCheck" runat="server" onclick="javascript:SelectAll(this);" />
                                                    </HeaderTemplate>
                                                    <ItemTemplate>
                                                        <asp:CheckBox ID="chkCheck" runat="server" />
                                                    </ItemTemplate>
                                                </asp:TemplateField>
                                                <asp:BoundField DataField="ACCOUNTNAME" HeaderText="户名" />
                                                <asp:BoundField DataField="TRADEDATE" HeaderText="交易日期" />
                                                <asp:BoundField DataField="MONEY" HeaderText="总金额" />
                                                <asp:BoundField DataField="USEDMONEY" HeaderText="已使用金额" />
                                                <asp:BoundField DataField="LEFTMONEY" HeaderText="余额" />
                                                <asp:BoundField DataField="toaccountbank" HeaderText="到账银行" />
                                                <asp:BoundField DataField="CHECKID" HeaderText="账单号" />
                                            </Columns>
                                            <EmptyDataTemplate>
                                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                                    <tr class="tabbt">
                                                        <td>
                                                            <input type="checkbox" />
                                                        </td>
                                                        <td>
                                                            户名
                                                        </td>
                                                        <td>
                                                            交易日期
                                                        </td>
                                                        <td>
                                                            总金额
                                                        </td>
                                                        <td>
                                                            已使用金额
                                                        </td>
                                                        <td>
                                                            余额
                                                        </td>
                                                        <td>
                                                            到账银行
                                                        </td>
                                                        <td>
                                                            账单号
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
            </div>
            <div class="con">
                <div class="jieguo">
                    详细信息</div>
                <div class="kuang5" runat="server" id="divInfo">
                </div>
                <asp:HiddenField ID="hidFinanceRemark" runat="server" />
            </div>
            <div class="btns">
                <table width="200px" border="0" align="right" cellpadding="0" cellspacing="0">
                    <tr>
                        <td>
                            <asp:LinkButton runat="server" ID="btnConfirm" OnClick="btnConfirm_Click" />
                            <asp:Button ID="btnSubmit" Text="通 过" CssClass="button1" runat="server" OnClick="btnSubmit_Click" />
                        </td>
                    </tr>
                </table>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
    </form>
</body>
</html>

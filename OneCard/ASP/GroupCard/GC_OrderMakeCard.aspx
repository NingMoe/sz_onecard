<%@ Page Language="C#" AutoEventWireup="true" CodeFile="GC_OrderMakeCard.aspx.cs"
    Inherits="ASP_GroupCard_GC_OrderMakeCard" EnableEventValidation="false" %>

<%@ Register Src="../../CardReader.ascx" TagName="CardReader" TagPrefix="cr" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>订单制卡/确认</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="../../js/printorder.js"></script>
   <%-- <script type="text/javascript" src="../../js/jquery-1.5.min.js"></script>--%>
    <script type="text/javascript" src="../../js/mootools.js"></script>
    <script type="text/javascript">
        function ShowIsRelated(ISRELATED) {
            divInfo.style.display = "block";
            if (ISRELATED == "1") {
                //利金卡制卡区
                if ($get("showCashGift").value == "1") {
                    makeCashGiftcard.style.display = "block";
                }
                else {
                    makeCashGiftcard.style.display = "none";
                }
                //市民卡B卡制卡区
                if ($get("showSZTCard").value == "1") {
                    makeSZTCard.style.display = "block";
                }
                else {
                    makeSZTCard.style.display = "none";
                }
                //旅游卡制卡区
                if ($get("showLvYou").value == "1") {
                    makeLvYou.style.display = "block";
                }
                else {
                    makeLvYou.style.display = "none";
                }
                //充值卡制卡区
                if ($get("showChargeCard").value == "1") {
                    makeChargeCard.style.display = "block";
                }
                else {
                    makeChargeCard.style.display = "none";
                }
                //专有账户制卡区
                if ($get("showCutomerAcc").value == "1") {
                    makeCustomerAccCard.style.display = "block";
                }
                else {
                    makeCustomerAccCard.style.display = "none";
                }
                //读卡器制卡区
                if ($get("showReader").value == "1") {
                    makeReader.style.display = "block";
                }
                else {
                    makeReader.style.display = "none";
                }
            }
            else {
                makeCashGiftcard.style.display = "none";
                makeSZTCard.style.display = "none";
                makeLvYou.style.display = "none";
                //充值卡制卡区
                if ($get("showChargeCard").value == "1") {
                    makeChargeCard.style.display = "block";
                }
                else {
                    makeChargeCard.style.display = "none";
                }
                //专有账户制卡区
                if ($get("showCutomerAcc").value == "1") {
                    makeCustomerAccCard.style.display = "block";
                }
                else {
                    makeCustomerAccCard.style.display = "none";
                }
                //读卡器制卡区
                if ($get("showReader").value == "1") {
                    makeReader.style.display = "block";
                }
                else {
                    makeReader.style.display = "none";
                }
            }
            return false;
        }

        function assignGiftFunc(cardNoId, cardInfo) {
            assignValue('txtCashGiftCardNo', cardInfo.cardNo);
            assignValue('hidAsn', cardInfo.appSn);
            assignValue('hidStartDate', cardInfo.appStartDate);
            assignValue('hidEndDate', cardInfo.appEndDate);
            assignValue('hidCardBalance', (cardInfo.balance / 100).toFixed(2));
            assignValue('hidWallet2', (cardInfo.wallet2 / 100).toFixed(2));
            assignValue('hidTradeNo', cardInfo.tradeNo);
        }

        function Change() {
            var table = document.getElementById('gvChargeCard');
            var tr = table.getElementsByTagName("tr");
            var total = 0;
            for (i = 1; i < tr.length; i++) {
                var FromCardno = tr[i].getElementsByTagName("td")[0].getElementsByTagName("input")[0].value;
                var EndCardno = tr[i].getElementsByTagName("td")[0].getElementsByTagName("input")[1].value;
                var sFCard = FromCardno.substr(6, 8);
                var sECard = EndCardno.substr(6, 8);
                var lCardSum = 0;
                var lCardMoney = 0;

                if(sFCard.test("^\\s*\\d{8}\\s*$") && sECard.test("\\s*^\\d{8}\\s*$")){
                    var FValue = FromCardno.substr(4, 1);
                    var EValue = EndCardno.substr(4, 1);
                    if (FValue == EValue) {
                        if (FValue == "A") {
                            lCardMoney = "20";
                        }
                        if (FValue == "B") {
                            lCardMoney = "30";
                        }
                        if (FValue == "C") {
                            lCardMoney = "50";
                        }
                        if (FValue == "D") {
                            lCardMoney = "100";
                        }
                        if (FValue == "E") {
                            lCardMoney = "500";
                        }
                        if (FValue == "H") {
                            lCardMoney = "300";
                        }
                        if (FValue == "F") {
                            lCardMoney = "200";
                        }
                        if (FValue == "X") {
                            lCardMoney = "0.01";
                        }
                        if (FValue == "Y") {
                            lCardMoney = "0.02";
                        }
                        if (FValue == "G") {
                            lCardMoney = "1000";
                        }
                        if (FValue == "Z") {
                            lCardMoney = "1";
                        }
                        if (FValue == "I") {
                            lCardMoney = "2";
                        }
                        if (FValue == "J") {
                            lCardMoney = "5";
                        }
                        if (FValue == "K") {
                            lCardMoney = "10";
                        }
                        if (FValue == "M") {
                            lCardMoney = "180";
                        }
                        if (FValue == "N") {
                            lCardMoney = "298";
                        }
                        if (FValue == "O") {
                            lCardMoney = "379";
                        }
                        if (FValue == "P") {
                            lCardMoney = "479";
                        }
                        if (FValue == "Q") {
                            lCardMoney = "198";
                        }
                    }

                    var lFCard = sFCard.toInt();
                    var lECard = sECard.toInt();
                    if (lECard - lFCard >= 0)
                        lCardSum = lECard - lFCard + 1;
                }

                tr[i].getElementsByTagName("td")[2].getElementsByTagName("input")[0].value = lCardSum;
                tr[i].getElementsByTagName("td")[1].getElementsByTagName("input")[0].value = lCardMoney;
            }
        }
        function SumChargeCard() {
            var table = document.getElementById('gvChargeCard');
            var tr = table.getElementsByTagName("tr");
            var total = 0;
            for (i = 1; i < tr.length; i++) {
                var valuetext = tr[i].getElementsByTagName("td")[1].getElementsByTagName("input")[0].value;
                var count = tr[i].getElementsByTagName("td")[2].getElementsByTagName("input")[0].value;
                if (valuetext != "" && count != "") {
                    total += valuetext * 100 * count;
                }
            }
            $('lblChargeCardTotal').innerText = total / 100.0;

        }
        function SumReaderCard() {
            var table = document.getElementById('gvReader');
            var tr = table.getElementsByTagName("tr");
            var total = 0;
            for (i = 1; i < tr.length; i++) {
                var valuetext = tr[i].getElementsByTagName("td")[1].getElementsByTagName("input")[0].value;
                var count = tr[i].getElementsByTagName("td")[2].getElementsByTagName("input")[0].value;
                if (valuetext != "" && count != "") {
                    total += valuetext * 100 * count;
                }
            }
            $('lblReaderCardTotal').innerText = total / 100.0;

        }

        function ReaderChange() {
            var table = document.getElementById('gvReader');
            var tr = table.getElementsByTagName("tr");
            var total = 0;
            for (i = 1; i < tr.length; i++) {
                var FromCardno = tr[i].getElementsByTagName("td")[0].getElementsByTagName("input")[0].value;
                var EndCardno = tr[i].getElementsByTagName("td")[0].getElementsByTagName("input")[1].value;
                var lCardSum = 0;
                if (EndCardno - FromCardno >= 0) {
                    lCardSum = EndCardno - FromCardno + 1;
                }
                //读卡器数量
                tr[i].getElementsByTagName("td")[2].getElementsByTagName("input")[0].value = lCardSum;
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
            border: 0px solid black;
        }
    </style>
</head>
<body>
    <cr:CardReader ID="cardReader" runat="server" />
    <form id="form1" runat="server">
    <div class="tb">
        订单制卡/确认
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
            <asp:HiddenField ID="showCashGift" runat="server" />
            <asp:HiddenField ID="showSZTCard" runat="server" />
            <asp:HiddenField ID="showLvYou" runat="server" />
            <asp:HiddenField ID="showChargeCard" runat="server" />
            <asp:HiddenField ID="showCutomerAcc" runat="server" />
            <asp:HiddenField ID="showReader" runat="server" />
            <asp:HiddenField ID="hiddentradeno" runat="server" />
            <asp:HiddenField ID="hiddencMoney" runat="server" />
            <asp:HiddenField ID="hiddenAsn" runat="server" />
            <asp:HiddenField ID="hidoutTradeid" runat="server" />
            <asp:HiddenField ID="hidMaketype" runat="server" />
            <asp:HiddenField ID="hidSaletype" runat="server" />
            <asp:HiddenField ID="hidIsJiMing" runat="server" />
            <asp:HiddenField ID="hidCardcostFee" runat="server" />
            <asp:HiddenField ID="hidDepositFee" runat="server" />
            <asp:HiddenField ID="hidCashGiftValue" runat="server" />
            <asp:HiddenField ID="hidSZTCardtype" runat="server" />
            <asp:HiddenField ID="hideLvYouCardtype" runat="server" />
            <asp:HiddenField ID="hidIsCompleted" runat="server" />
            <asp:HiddenField ID="hidPageIndex" runat="server" />
            <asp:HiddenField ID="hidRowIndex" runat="server" />
            <asp:HiddenField ID="hidSupplyMoney" runat="server" />
            <asp:HiddenField runat="server" ID="hidWarning" />
            <asp:HiddenField runat="server" ID="hidAsn" />
            <asp:HiddenField runat="server" ID="hidTradeNo" />
            <asp:HiddenField runat="server" ID="hidSeqNo" />
            <asp:HiddenField runat="server" ID="hidCardnoForCheck" />
            <asp:HiddenField runat="server" ID="hidStartDate" />
            <asp:HiddenField runat="server" ID="hidEndDate" />
            <asp:HiddenField runat="server" ID="hidCardBalance" />
            <asp:HiddenField runat="server" ID="hidWallet2" />
            <asp:HiddenField runat="server" ID="hidCardReaderToken" />
            <asp:LinkButton runat="server" ID="btnConfirm" OnClick="btnConfirm_Click" />
            <div class="con">
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
                            <td>
                                <div align="right">
                                    审核员工:</div>
                            </td>
                            <td>
                                <asp:DropDownList ID="ddlApprover" CssClass="inputmid" runat="server">
                                </asp:DropDownList>
                            </td>
                            <td>
                                <div align="right">
                                    关联卡:</div>
                            </td>
                            <td>
                                <asp:DropDownList ID="selIsRelation" CssClass="input" runat="server">
                                <asp:ListItem Value="" Text="---请选择---"></asp:ListItem>
                                <asp:ListItem Value="0" Text="0:领卡关联"></asp:ListItem>
                                <asp:ListItem Value="1" Text="1:制卡关联"></asp:ListItem>
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
                <table border="0" width="95%">
                    <tr>
                        <td align="left">
                            <div class="jieguo">
                                订单列表</div>
                        </td>
                    </tr>
                </table>
                <div class="kuang5" style="height: 170px; overflow: auto">
                    <asp:GridView ID="gvOrderList" CssClass="tab2" HeaderStyle-CssClass="tabbt" FooterStyle-CssClass="tabcon"
                        AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel" PagerSettings-Mode="NumericFirstLast"
                        PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top" runat="server"
                        AutoGenerateColumns="false" Width="150%" OnRowCreated="gvOrderList_RowCreated"
                        OnSelectedIndexChanged="gvOrderList_SelectedIndexChanged"  PageSize="5" 
                        OnPageIndexChanging="gvOrderList_Page" AllowPaging="true">
                        <Columns>
                            <asp:BoundField DataField="ORDERNO" HeaderText="订单号" />
                            <asp:BoundField DataField="GROUPNAME" HeaderText="单位名称" />
                            <asp:BoundField DataField="NAME" HeaderText="联系人" />
                            <asp:BoundField DataField="IDCARDNO" HeaderText="身份证号码" />
                            <asp:BoundField DataField="PHONE" HeaderText="联系电话" />
                            <asp:BoundField DataField="TOTALMONEY" HeaderText="购卡总金额(元)" />
                            <asp:BoundField DataField="TRANSACTOR" HeaderText="经办人" />
                            <asp:BoundField DataField="INPUTTIME" HeaderText="录入时间" />
                            <asp:BoundField DataField="FINANCEAPPROVERNO" HeaderText="审核员工" />
                            <asp:BoundField DataField="FINANCEAPPROVERTIME" HeaderText="审核时间" />
                            <asp:BoundField DataField="ISRELATED" HeaderText="关联卡" />
                        </Columns>
                        <EmptyDataTemplate>
                            <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                <tr class="tabbt">
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
                                        身份证号码
                                    </td>
                                    <td>
                                        联系电话
                                    </td>
                                    <td>
                                        购卡总金额(元)
                                    </td>
                                    <td>
                                        经办人
                                    </td>
                                    <td>
                                        录入时间
                                    </td>
                                    <td>
                                        审核员工
                                    </td>
                                    <td>
                                        审核时间
                                    </td>
                                    <td>
                                        关联卡
                                    </td>
                                </tr>
                            </table>
                        </EmptyDataTemplate>
                    </asp:GridView>
                </div>
                <div class="kuang5" runat="server" id="divInfo" style="display: none">
                </div>
                <div id="makeCashGiftcard" style="display: none">
                    <div class="card">
                        利金卡</div>
                    <div class="kuang5">
                        <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                            <tr>
                                <td width="10%">
                                    <div align="right">
                                        面额:</div>
                                </td>
                                <td width="20%">
                                    <asp:DropDownList ID="selCashGiftValue" CssClass="inputmid" Width="206" runat="server"
                                        AutoPostBack="true" OnSelectedIndexChanged="selCashGiftValue_Changed">
                                    </asp:DropDownList>
                                </td>
                                <td width="10%">
                                    <div align="right">
                                        确认卡号:</div>
                                </td>
                                <td width="60%" colspan="6">
                                    <asp:TextBox ID="txtCashGiftCardNo" CssClass="labeltext" runat="server" />
                                    <%--<asp:Label ID="labComfirmCashGiftCardno" runat="server"></asp:Label>--%>
                                </td>
                            </tr>
                            <tr>
                                <td width="10%">
                                    <div align="right">
                                        面额:</div>
                                </td>
                                <td width="20%">
                                    <asp:Label ID="labCashGiftValue" runat="server"></asp:Label>
                                </td>
                                <td width="10%">
                                    <div align="right">
                                        订购数量:</div>
                                </td>
                                <td width="10%">
                                    <asp:Label ID="labCashGiftOrderNum" runat="server"></asp:Label>
                                </td>
                                <td width="10%">
                                    <div align="right">
                                        剩余数量:</div>
                                </td>
                                <td width="10%">
                                    <asp:Label ID="labCashGiftLeftNum" runat="server"></asp:Label>
                                </td>
                                <td width="10%">
                                </td>
                                <td width="10%">
                                </td>
                                <td width="10%" align="center">
                                    <asp:Button ID="btnCashGiftMake" runat="server" CssClass="button1" Text="制 卡" OnClientClick="return ReadCashGiftInfo(assignGiftFunc,'txtCashGiftCardNo')"
                                        OnClick="btnCashGiftMake_Click" Enabled="false" />
                                </td>
                            </tr>
                        </table>
                    </div>
                </div>
                <div id="makeSZTCard" style="display: none">
                    <div class="card">
                        市民卡B卡</div>
                    <div class="kuang5">
                        <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                            <tr>
                                <td width="10%">
                                    <div align="right">
                                        卡类型:</div>
                                </td>
                                <td width="20%">
                                    <asp:DropDownList ID="selSZTCardType" CssClass="inputmid" Width="206" runat="server"
                                        AutoPostBack="true" OnSelectedIndexChanged="selSZTCardType_Changed">
                                    </asp:DropDownList>
                                </td>
                                <td width="10%">
                                    <div align="right">
                                        确认卡号:</div>
                                </td>
                                <td width="60%" colspan="6">
                                    <asp:TextBox ID="txtSZTCardNo" CssClass="labeltext" runat="server" />
                                    <%--<asp:Label ID="labComfirmSZTCarnno" runat="server"></asp:Label>--%>
                                </td>
                            </tr>
                            <tr>
                                <td width="10%">
                                    <div align="right">
                                        卡类型:</div>
                                </td>
                                <td width="20%">
                                    <asp:Label ID="labSZTCardType" runat="server"></asp:Label>
                                </td>
                                <td width="10%">
                                    <div align="right">
                                        充值金额:</div>
                                </td>
                                <td width="10%">
                                    <asp:Label ID="labSZTCardChargeMoney" runat="server"></asp:Label>
                                </td>
                                <td width="10%">
                                    <div align="right">
                                        订购数量:</div>
                                </td>
                                <td width="10%">
                                    <asp:Label ID="labSZTCardOrderNum" runat="server"></asp:Label>
                                </td>
                                <td width="10%">
                                    <div align="right">
                                        剩余数量:</div>
                                </td>
                                <td width="10%">
                                    <asp:Label ID="labSZTCardLeftNum" runat="server"></asp:Label>
                                </td>
                                <td width="10%" align="center">
                                    <asp:Button ID="btnSZTCardMake" runat="server" CssClass="button1" Text="制 卡" OnClick="btnSZTCardMake_Click"
                                        OnClientClick="return ReadCardInfo('txtSZTCardNo')" Enabled="false" />
                                         <asp:Button ID="btnOldSZTCardMake" runat="server" CssClass="button1" 
                                        Text="旧卡充值完成" OnClick="btnOldSZTCardMake_Click"
                                         Enabled="false"  />
                                </td>
                            </tr>
                        </table>
                    </div>
                </div>
                <div id="makeLvYou" style="display: none">
                    <div class="card">
                        旅游卡</div>
                    <div class="kuang5">
                        <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                            <tr>
                                <td width="10%">
                                    <div align="right">
                                        卡类型:</div>
                                </td>
                                <td width="20%">
                                    <asp:DropDownList ID="selLvYouType" CssClass="inputmid" Width="206" runat="server"
                                        AutoPostBack="true" OnSelectedIndexChanged="selLvYouType_Changed">
                                    </asp:DropDownList>
                                </td>
                                <td width="10%">
                                    <div align="right">
                                        确认卡号:</div>
                                </td>
                                <td width="60%" colspan="6">
                                    <asp:TextBox ID="txtLvYouNo" CssClass="labeltext" runat="server" />
                                    <%--<asp:Label ID="labComfirmSZTCarnno" runat="server"></asp:Label>--%>
                                </td>
                            </tr>
                            <tr>
                                <td width="10%">
                                    <div align="right">
                                        卡类型:</div>
                                </td>
                                <td width="20%">
                                    <asp:Label ID="labLvYouType" runat="server"></asp:Label>
                                </td>
                                <td width="10%">
                                    <div align="right">
                                        充值金额:</div>
                                </td>
                                <td width="10%">
                                    <asp:Label ID="labLvYouChargeMoney" runat="server"></asp:Label>
                                </td>
                                <td width="10%">
                                    <div align="right">
                                        订购数量:</div>
                                </td>
                                <td width="10%">
                                    <asp:Label ID="labLvYouOrderNum" runat="server"></asp:Label>
                                </td>
                                <td width="10%">
                                    <div align="right">
                                        剩余数量:</div>
                                </td>
                                <td width="10%">
                                    <asp:Label ID="labLvYouLeftNum" runat="server"></asp:Label>
                                </td>
                                <td width="10%" align="center">
                                    <asp:Button ID="btnLvYouMake" runat="server" CssClass="button1" Text="制 卡" OnClick="btnLvYouMake_Click"
                                        OnClientClick="return ReadCardInfo('txtLvYouNo')" Enabled="false" />
                                </td>
                            </tr>
                        </table>
                    </div>
                </div>
                <div id="makeChargeCard" style="display: none">
                    <div>
                        <table border="0" width="95%">
                            <tr>
                                <td align="left" width="100px">
                                    <div class="card">
                                        充值卡</div>
                                </td>
                                <td width="50px" style="font-weight: bolder">
                            总计:
                             </td>
                             <td width="300px">
                            <asp:Label ID="lblChargeCardTotal" runat="server" Text="0"></asp:Label>
                             </td>
                                <td>
                                    <asp:Button ID="btnChargeCardAdd" CssClass="button1" runat="server" Text="新增" OnClick="btnChargeCardAdd_Click" />
                                </td>
                            </tr>
                        </table>
                    </div>
                    <div class="kuang5">
                        <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                            <tr>
                                <td width="90%">
                                    <asp:GridView ID="gvChargeCard" CssClass="tab2" HeaderStyle-CssClass="tabbt" FooterStyle-CssClass="tabcon"
                                        AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel" PagerSettings-Mode="NumericFirstLast"
                                        PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top" runat="server"
                                        AutoGenerateColumns="False" OnRowDeleting="gvChargeCard_RowDeleting" OnRowCommand="gvChargeCard_RowCommand">
                                        <Columns>
                                            <asp:TemplateField HeaderText="卡号段">
                                                <ItemTemplate>
                                                    <asp:TextBox ID="txtFromCardNo" Style="text-align: center" runat="server" MaxLength="14"
                                                        Text='<%# Bind("FromCardNo") %>' onblur='Change();SumChargeCard()'></asp:TextBox>&nbsp;-&nbsp;
                                                    <asp:TextBox ID="txtToCardNo" Style="text-align: center" runat="server" MaxLength="14"
                                                        Text='<%# Bind("ToCardNo") %>' onblur='Change();SumChargeCard()'></asp:TextBox>
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                            <%--<asp:BoundField DataField="ChargeCardValue" HeaderText="面额" />--%>
                                            <asp:TemplateField HeaderText="面额">
                                                <ItemTemplate>
                                                    <asp:TextBox ID="txtChargeCardValue" Style="text-align: center" CssClass="labeltext"
                                                        runat="server" Text='<%# Bind("ChargeCardValue") %>' onblur='SumChargeCard();'></asp:TextBox>
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                            <%--<asp:BoundField DataField="ChargeCardNum" HeaderText="数量" />--%>
                                            <asp:TemplateField HeaderText="购卡数量">
                                                <ItemTemplate>
                                                    <asp:TextBox ID="txtChargeCardNum" Style="text-align: center" CssClass="labeltext"
                                                        runat="server" Text='<%# Bind("ChargeCardNum") %>' onblur='SumChargeCard();'></asp:TextBox>
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                            <asp:TemplateField>
                                                <ItemTemplate>
                                                    <asp:Button ID="btnChargeCardDelete" CssClass="button1" runat="server" CommandName="delete"
                                                        CommandArgument="<%#Container.DataItemIndex%>" Text='删除' CausesValidation="False" />
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                        </Columns>
                                    </asp:GridView>
                                </td>
                                <td width="10%" align="center">
                                    <asp:Button ID="btnChargeCardMake" runat="server" CssClass="button1" Text="关 联" OnClick="btnChargeCardMake_Click" />
                                </td>
                            </tr>
                        </table>
                    </div>
                </div>
                <div id="makeReader" style="display: none">
                    <div>
                        <table border="0" width="95%">
                            <tr>
                                <td align="left" width="100px">
                                    <div class="card">
                                        读卡器</div>
                                </td>
                                <td width="50px" style="font-weight: bolder">
                            总计:
                             </td>
                             <td width="300px">
                            <asp:Label ID="lblReaderCardTotal" runat="server" Text="0"></asp:Label>
                             </td>
                                <td>
                                    <asp:Button ID="Button1" CssClass="button1" runat="server" Text="新增" OnClick="btnReaderAdd_Click" />
                                </td>
                            </tr>
                        </table>
                    </div>
                    <div class="kuang5">
                        <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                            <tr>
                                <td width="90%">
                                    <asp:GridView ID="gvReader" CssClass="tab2" HeaderStyle-CssClass="tabbt" FooterStyle-CssClass="tabcon"
                                        AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel" PagerSettings-Mode="NumericFirstLast"
                                        PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top" runat="server"
                                        AutoGenerateColumns="False" OnRowDeleting="gvReader_RowDeleting" OnRowCommand="gvReader_RowCommand">
                                        <Columns>
                                            <asp:TemplateField HeaderText="读卡器序列号号段">
                                                <ItemTemplate>
                                                    <asp:TextBox ID="txtBeginCardNo" Style="text-align: center" runat="server" MaxLength="16"
                                                        Text='<%# Bind("BeginCardNo") %>' onblur='ReaderChange();SumReaderCard();'></asp:TextBox>&nbsp;-&nbsp;
                                                    <asp:TextBox ID="txtEndCardNo" Style="text-align: center" runat="server" MaxLength="16"
                                                        Text='<%# Bind("EndCardNo") %>' onblur='ReaderChange();SumReaderCard();'></asp:TextBox>
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="单价">
                                                <ItemTemplate>
                                                    <asp:TextBox ID="txtReaderValue" Style="text-align: center" CssClass="labeltext"
                                                        runat="server" Text='<%# Bind("ReaderValue") %>' onblur='SumReaderCard();'></asp:TextBox>
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="购买数量">
                                                <ItemTemplate>
                                                    <asp:TextBox ID="txtReaderNum" Style="text-align: center" CssClass="labeltext"
                                                        runat="server" Text='<%# Bind("ReaderNum") %>'></asp:TextBox>
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                            <asp:TemplateField>
                                                <ItemTemplate>
                                                    <asp:Button ID="btnReaderDelete" CssClass="button1" runat="server" CommandName="delete"
                                                        CommandArgument="<%#Container.DataItemIndex%>" Text='删除' CausesValidation="False" />
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                        </Columns>
                                    </asp:GridView>
                                </td>
                                <td width="10%" align="center">
                                    <asp:Button ID="Button2" runat="server" CssClass="button1" Text="关 联" OnClick="btnReaderMake_Click" />
                                </td>
                            </tr>
                        </table>
                    </div>
                </div>
                <div id="makeCustomerAccCard" style="display: none">
                    <div class="card">
                        专有账户</div>
                    <div class="kuang5">
                        <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                            <tr>
                                <td width="10%">
                                    <div align="right">
                                        批量充值批次号:</div>
                                </td>
                                <td width="80%">
                                    <asp:TextBox ID="txtCustomerAccBatchNo" runat="server" CssClass="inputmid" MaxLength="16"></asp:TextBox>
                                </td>
                                <td width="10%" align="center">
                                    <asp:Button ID="btnCustomerAccMake" runat="server" CssClass="button1" Text="关 联"
                                        OnClick="btnCustomerAccMake_Click" />
                                </td>
                            </tr>
                        </table>
                    </div>
                </div>
            </div>
            <div class="btns">
                <table width="100%" border="0" align="right" cellpadding="0" cellspacing="0">
                    <tr>
                        <td width="80%" align="right">
                            <asp:Button ID="btnComfirmNotRelation" CssClass="button1" Visible="false" runat="server"
                                Text="确认领卡关联" OnClick="btnComfirmNotRelation_Click" Width="88px" />
                        </td>
                    </tr>
                </table>
            </div>
        </ContentTemplate>
        <%--<Triggers>
            <asp:PostBackTrigger ControlID="btnExport" />
        </Triggers>--%>
    </asp:UpdatePanel>
    </form>
</body>
</html>

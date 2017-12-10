<%@ Page Language="C#" AutoEventWireup="true" CodeFile="GC_OrderCardChange.aspx.cs"
    Inherits="ASP_GroupCard_GC_OrderCardChange" EnableEventValidation="false" %>

<%@ Register Src="../../CardReader.ascx" TagName="CardReader" TagPrefix="cr" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>订单卡更换</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="../../js/mootools.js"></script>
    <%--<script type="text/javascript" src="../../js/jquery-1.5.min.js"></script>--%>
    <script type="text/javascript">
        function ShowIsRelated() {
            divInfo.style.display = "block";
            return false;
        }
        function submitStockInConfirm() {
            var GCTotalChargeMoney = "0";
            if ($('txtGCTotalChargeMoney').value != "") {
                GCTotalChargeMoney = $('txtGCTotalChargeMoney').value;
            }
            MyExtConfirm('确认', '利金卡小计: ' + $('lblCashGiftTotal').innerText + '元<br>' +
                                '充值卡小计: ' + $('lblChargeCardTotal').innerText + '元<br>' +
                                '市民卡B卡小计:' + $('lblSztTotal').innerText + '元<br>' +
                                '旅游卡小计:' + $('lblLvYouTotal').innerText + '元<br>' +
                                '专有账户小计: ' + GCTotalChargeMoney + '元<br>' +
                                '读卡器小计: ' + $('labReaderMoney').innerText + '元<br>' +
                                '园林年卡小计: ' + $('labParkMoney').innerText + '元<br>' +
                                '休闲年卡小计: ' + $('labXXMoney').innerText + '元<br>' +
                                '总计: ' + $('txtTotalMoney').value + '元<br>' +
                                '是否确认更换'
                                , submitStockInConfirmCallback);
            return false;
        }

        function submitStockInConfirmCallback(btn) {
            if (btn == 'no') {
            }
            else {
                $get('btnStockInConfirm').click();
            }
        }

        function SumCashGift() {
            var total = 0;
            var table = document.getElementById('gvCashGift');
            if (table != null) {
                var tr = table.getElementsByTagName("tr");
                for (i = 1; i < tr.length; i++) {
                    var value = tr[i].getElementsByTagName("td")[0].getElementsByTagName("input")[0].value;
                    var count = tr[i].getElementsByTagName("td")[1].getElementsByTagName("input")[0].value;
                    total += value * 100 * count;
                }
            }
            //var totalCashGift = $('txtTotalCashGift').value;
            //if (total == 0) {
            //   total = totalCashGift * 100;
            //}
            $('lblCashGiftTotal').innerText = total / 100.0;
            SumAll();
        }

        function SumChargeCard() {
            var table = document.getElementById('gvChargeCard');
            var tr = table.getElementsByTagName("tr");
            var total = 0;
            for (i = 1; i < tr.length; i++) {
                var select = tr[i].getElementsByTagName("td")[0].getElementsByTagName("select")[0];
                var valuetext = select.options[select.selectedIndex].innerText;

                var value = valuetext.substring(2, valuetext.length);
                var count = tr[i].getElementsByTagName("td")[1].getElementsByTagName("input")[0].value;
                if (value != "" && count != "") {
                    total += value * 100 * count;
                }
            }
            $('lblChargeCardTotal').innerText = total / 100.0;
            SumAll();
        }

        function SumSztCard() {
            var table = document.getElementById('gvSZTCard');
            var tr = table.getElementsByTagName("tr");
            var total = 0;
            for (i = 1; i < tr.length; i++) {
                var count = tr[i].getElementsByTagName("td")[1].getElementsByTagName("input")[0].value;
                var price = tr[i].getElementsByTagName("td")[2].getElementsByTagName("input")[0].value;
                var chargemoney = tr[i].getElementsByTagName("td")[3].getElementsByTagName("input")[0].value;
                total += (count * 100 * price + chargemoney * 100);
            }
            $('lblSztTotal').innerText = total / 100.0;
            SumAll();
        }

        function SumLvYou() {
            var table = document.getElementById('gvLvYou');
            var tr = table.getElementsByTagName("tr");
            var total = 0;
            for (i = 1; i < tr.length; i++) {
                var count = tr[i].getElementsByTagName("td")[0].getElementsByTagName("input")[0].value;
                var price = tr[i].getElementsByTagName("td")[1].getElementsByTagName("input")[0].value;
                var chargemoney = tr[i].getElementsByTagName("td")[2].getElementsByTagName("input")[0].value;
                total += (count * 100 * price + chargemoney * 100);
            }
            $('lblLvYouTotal').innerText = total / 100.0;
            SumAll();
        }

        function SumGroupCard() {
            SumAll();
        }

        function SumReader() {
            var total = 0;
            if ($('txtReaderPrice').value == "") {
                var readerPrice = 0;
            }
            else {
                var readerPrice = parseFloat($('txtReaderPrice').value) * 100;
            }
            if ($('txtReadernum').value == "") {
                var readerNum = 0;
            }
            else {
                var readerNum = parseFloat($('txtReadernum').value);
            }
            total += readerPrice * readerNum;
            $('labReaderMoney').innerText = total / 100.0;
            SumAll();
        }

        function SumGardenCard() {
            var total = 0;
            if ($('txtParkOpenPrice').value == "") {
                var gardenCardPrice = 0;
            }
            else {
                var gardenCardPrice = parseFloat($('txtParkOpenPrice').value) * 100;
            }
            if ($('txtParkOpennum').value == "") {
                var gardenCardnum = 0;
            }
            else {
                var gardenCardnum = parseFloat($('txtParkOpennum').value);
            }
            total += gardenCardPrice * gardenCardnum;
            $('labParkMoney').innerText = total / 100.0;
            SumAll();
        }

        function SumRelaxCard() {
            var total = 0;
            if ($('txtXXPrice').value == "") {
                var relaxCardPrice = 0;
            }
            else {
                var relaxCardPrice = parseFloat($('txtXXPrice').value) * 100;
            }
            if ($('txtXXOpennum').value == "") {
                var relaxCardnum = 0;
            }
            else {
                var relaxCardnum = parseFloat($('txtXXOpennum').value);
            }
            total += relaxCardPrice * relaxCardnum;
            $('labXXMoney').innerText = total / 100.0;
            SumAll();
        }

        function SumAll() {
            var cashGiftTotal = parseFloat($('lblCashGiftTotal').innerText) * 100
            var chargeCardTotal = parseFloat($('lblChargeCardTotal').innerText) * 100;
            var lvyouTotal = ($('lblLvYouTotal').innerText) * 100;
            var sztTotal = ($('lblSztTotal').innerText) * 100;
            if ($('txtGCTotalChargeMoney').value == "") {
                var gcTotal = 0;
            }
            else {
                var gcTotal = parseFloat($('txtGCTotalChargeMoney').value) * 100;
            }
            var readerTotal = ($('labReaderMoney').innerText) * 100;
            var gardenCardTotal = ($('labParkMoney').innerText) * 100;
            var relaxCardTotal = ($('labXXMoney').innerText) * 100;

            $('txtTotalMoney').value = (cashGiftTotal + chargeCardTotal + sztTotal + lvyouTotal + gcTotal + readerTotal + gardenCardTotal + relaxCardTotal) / 100.0;
        }

        function SumInvoiceMoney() {
            var table = document.getElementById('gvInvoice');
            var tr = table.getElementsByTagName("tr");
            var total = 0;
            for (i = 1; i < tr.length; i++) {
                var chargemoney = tr[i].getElementsByTagName("td")[1].getElementsByTagName("input")[0].value;
                total += chargemoney * 100;
            }
            $('labInvoiceMoney').innerText = total / 100.0;
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
        订单卡更换
    </div>
    <ajaxToolkit:ToolkitScriptManager runat="Server" EnableScriptGlobalization="true"
        EnableScriptLocalization="true" ID="ScriptManager1" />
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
            <%--<asp:HiddenField ID="hidSex" runat="server" />
            <asp:HiddenField ID="hidCustbirth" runat="server" />
            <asp:HiddenField ID="hidPapertype" runat="server" />
            <asp:HiddenField ID="hidCustaddr" runat="server" />--%>
            <div class="con">
                <div class="base">
                    订单卡更换</div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td width="8%">
                                <div align="right">
                                    单位名称:</div>
                            </td>
                            <td width="8%" colspan="3">
                                <asp:TextBox ID="txtCompany" CssClass="inputmid" runat="server" AutoPostBack="true"
                                    OnTextChanged="queryCompany"></asp:TextBox>
                                <asp:DropDownList ID="selCompany" CssClass="inputmid" Width="206" AutoPostBack="true"
                                    OnSelectedIndexChanged="selCompany_Change" runat="server">
                                </asp:DropDownList>
                            </td>
                            <td width="8%">
                                <div align="right">
                                    联系人:</div>
                            </td>
                            <td width="8%">
                                <asp:TextBox ID="txtName" CssClass="input" runat="server"></asp:TextBox>
                            </td>
                            <td width="8%">
                                <div align="right">
                                    部门:</div>
                            </td>
                            <td width="8%">
                                <asp:DropDownList ID="selDept" CssClass="inputmid" runat="server" AutoPostBack="true"
                                    OnSelectedIndexChanged="selDept_Changed">
                                </asp:DropDownList>
                            </td>
                        </tr>
                        <tr>
                            <td width="8%">
                                <div align="right">
                                    经办人:</div>
                            </td>
                            <td width="8%">
                                <asp:DropDownList ID="selStaff" CssClass="inputmid" runat="server">
                                </asp:DropDownList>
                            </td>
                            <td width="8%">
                                <div align="right">
                                    金额:</div>
                            </td>
                            <td width="8%">
                                <asp:TextBox ID="txtQueryMoney" CssClass="input" runat="server"></asp:TextBox>
                            </td>
                            <td width="8%">
                                <div align="right">
                                    开始日期:</div>
                            </td>
                            <td width="8%">
                                <asp:TextBox runat="server" ID="txtFromDate" MaxLength="8" CssClass="input"></asp:TextBox>
                                <ajaxToolkit:CalendarExtender ID="CalendarExtender1" runat="server" TargetControlID="txtFromDate"
                                    Format="yyyyMMdd" />
                            </td>
                            <td width="8%">
                                <div align="right">
                                    结束日期:</div>
                            </td>
                            <td width="8%">
                                <asp:TextBox runat="server" ID="txtToDate" MaxLength="8" CssClass="input"></asp:TextBox>
                                <ajaxToolkit:CalendarExtender ID="CalendarExtender2" runat="server" TargetControlID="txtToDate"
                                    Format="yyyyMMdd" />
                            </td>
                        </tr>
                        <tr>
                            <td colspan="7">
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
                <div class="kuang5">
                    <div style="height: 170px; overflow: auto; display: block">
                        <asp:GridView ID="gvOrderList" CssClass="tab2" HeaderStyle-CssClass="tabbt" FooterStyle-CssClass="tabcon"
                            AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel" PagerSettings-Mode="NumericFirstLast"
                            PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top" runat="server"
                            AutoGenerateColumns="false" Width="120%" OnRowCreated="gvOrderList_RowCreated"
                            OnSelectedIndexChanged="gvOrderList_SelectedIndexChanged">
                            <Columns>
                                <asp:BoundField DataField="orderno" HeaderText="订单号" />
                                <asp:BoundField DataField="groupname" HeaderText="单位名称" />
                                <asp:BoundField DataField="name" HeaderText="联系人" />
                                <asp:BoundField DataField="idcardno" HeaderText="身份证号码" />
                                <asp:BoundField DataField="phone" HeaderText="联系电话" />
                                <asp:BoundField DataField="totalmoney" HeaderText="购卡总金额(元)" />
                                <asp:BoundField DataField="transactor" HeaderText="经办人" />
                                <asp:BoundField DataField="inputtime" HeaderText="录入时间" />
                                <asp:BoundField DataField="ORDERSTATE" HeaderText="订单状态" />
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
                                            订单状态
                                        </td>
                                    </tr>
                                </table>
                            </EmptyDataTemplate>
                        </asp:GridView>
                    </div>
                </div>
                <div class="kuang5" runat="server" id="divInfo" style="display: none">
                </div>
                <table border="0" width="95%">
                    <tr>
                        <td align="left" width="50%">
                            <div class="card">
                                总金额</div>
                        </td>
                        <td width="50%" style="font-weight: bolder">
                        </td>
                    </tr>
                </table>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td  width="80px" align="right">
                                <div align="right">
                                    变更后总金额:</div>
                            </td>
                            <td>
                                <asp:TextBox ID="txtTotalMoney" CssClass="labeltext" Width="100" runat="server" Text="0"
                                    ReadOnly="true"></asp:TextBox>元
                            </td>
                        </tr>
                    </table>
                </div>
                <table border="0" width="95%">
                    <tr>
                        <td align="left" width="100px">
                            <div class="card">
                                利金卡</div>
                        </td>
                        <td width="50px" style="font-weight: bolder">
                            总计:
                        </td>
                        <td width="300px">
                            <asp:Label runat="server" ID="lblCashGiftTotal" Text="0"></asp:Label>
                        </td>
                        <td>
                            <asp:Button ID="btnCashGiftAdd" CssClass="button1" runat="server" Text="新增" OnClientClick=""
                                OnClick="btnCashGiftAdd_Click" />
                        </td>
                    </tr>
                </table>
                <div class="kuang5" id="div1" runat="server" enableviewstate="true">
                    <table>
                        <tr>
                            <td>
                                <asp:GridView ID="gvCashGift" CssClass="tab2" HeaderStyle-CssClass="tabbt" FooterStyle-CssClass="tabcon"
                                    AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel" PagerSettings-Mode="NumericFirstLast"
                                    PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top" runat="server"
                                    AutoGenerateColumns="False" OnRowCommand="gvCashGift_RowCommand" OnRowDeleting="gvCashGift_RowDeleting">
                                    <Columns>
                                        <asp:TemplateField HeaderText="面额">
                                            <ItemTemplate>
                                                <asp:TextBox ID="txtCashGiftValue" Style="text-align: center" runat="server" Text='<%# Bind("CashGiftValue") %>'
                                                    onblur="SumCashGift();"></asp:TextBox>&nbsp;元&nbsp;
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="购卡数量">
                                            <ItemTemplate>
                                                <asp:TextBox ID="txtCashGiftNum" Style="text-align: center" runat="server" Text='<%# Bind("CashGiftNum") %>'
                                                    onblur="SumCashGift();"></asp:TextBox>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField>
                                            <ItemTemplate>
                                                <asp:Button ID="btnDelete" CssClass="button1" runat="server" CommandName="delete"
                                                    CommandArgument="<%#Container.DataItemIndex%>" Text='删除' CausesValidation="False" />
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                    </Columns>
                                </asp:GridView>
                            </td>
                            <%--<td valign="top">
                                总金额:
                                <asp:TextBox ID="txtTotalCashGift" CssClass="input" runat="server" onblur='SumCashGift();'></asp:TextBox>&nbsp;元
                            </td>--%>
                        </tr>
                    </table>
                </div>
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
                <div class="kuang5">
                    <asp:GridView ID="gvChargeCard" CssClass="tab2" HeaderStyle-CssClass="tabbt" FooterStyle-CssClass="tabcon"
                        AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel" PagerSettings-Mode="NumericFirstLast"
                        PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top" runat="server"
                        AutoGenerateColumns="False" OnRowDeleting="gvChargeCard_RowDeleting" OnRowCommand="gvChargeCard_RowCommand"
                        OnRowCreated="gvChargeCard_RowCreated">
                        <Columns>
                            <asp:TemplateField HeaderText="面额">
                                <ItemTemplate>
                                    <%--<asp:TextBox ID="txtChargeCardValue" onblur='SumChargeCard();' Style="text-align: center"
                                        runat="server" Text='<%# Bind("ChargeCardValue") %>'></asp:TextBox>&nbsp;元&nbsp;--%>
                                    <asp:DropDownList ID="selChargeCardValue" CssClass="inputmid" runat="server" onblur='SumChargeCard();'>
                                    </asp:DropDownList>
                                    &nbsp;元&nbsp;
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="购卡数量">
                                <ItemTemplate>
                                    <asp:TextBox ID="txtChargeCardNum" onblur='SumChargeCard();' Style="text-align: center"
                                        runat="server" Text='<%# Bind("ChargeCardNum") %>'></asp:TextBox>
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
                </div>
                <table border="0" width="95%">
                    <tr>
                        <td align="left" width="20%">
                            <div class="card">
                                市民卡B卡(代理及零售)</div>
                        </td>
                        <td width="50px" style="font-weight: bolder">
                            总计:
                        </td>
                        <td width="300px">
                            <asp:Label ID="lblSztTotal" runat="server" Text="0"></asp:Label>
                        </td>
                        <td>
                            <asp:Button ID="btnSZTCardAdd" CssClass="button1" runat="server" Text="新增" OnClick="btnSZTCardAdd_Click" />
                        </td>
                    </tr>
                </table>
                <div class="kuang5">
                    <asp:GridView ID="gvSZTCard" CssClass="tab2" HeaderStyle-CssClass="tabbt" FooterStyle-CssClass="tabcon"
                        AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel" PagerSettings-Mode="NumericFirstLast"
                        PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top" runat="server"
                        AutoGenerateColumns="False" OnRowDeleting="gvSZTCard_RowDeleting" OnRowCommand="gvSZTCard_RowCommand"
                        OnRowCreated="gvSZTCard_RowCreated">
                        <Columns>
                            <asp:TemplateField HeaderText="卡类型">
                                <ItemTemplate>
                                    <asp:DropDownList ID="selSZTCardtype" CssClass="inputmid" runat="server">
                                    </asp:DropDownList>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="购卡数量">
                                <ItemTemplate>
                                    <asp:TextBox ID="txtSZTCardNum" Style="text-align: center" runat="server" Text='<%# Bind("SZTCardNum") %>'
                                        onblur='SumSztCard();'></asp:TextBox>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="单价">
                                <ItemTemplate>
                                    <asp:TextBox ID="txtSZTCardPrice" Style="text-align: center" runat="server" MaxLength="6"
                                        Text='<%# Bind("SZTCardPrice") %>' onblur='SumSztCard();'></asp:TextBox>&nbsp;元&nbsp;
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="总充值金额">
                                <ItemTemplate>
                                    <asp:TextBox ID="txtSZTCardChargeMoney" Style="text-align: center" runat="server"
                                        MaxLength="10" Text='<%# Bind("SZTCardChargeMoney") %>' onblur='SumSztCard();'></asp:TextBox>&nbsp;元&nbsp;
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField>
                                <ItemTemplate>
                                    <asp:Button ID="btnSZTCardDelete" CssClass="button1" runat="server" CommandName="delete"
                                        CommandArgument="<%#Container.DataItemIndex%>" Text='删除' CausesValidation="False" />
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                </div>
                <table border="0" width="95%">
                    <tr>
                        <td align="left" width="20%">
                            <div class="card">
                                旅游卡</div>
                        </td>
                        <td width="50px" style="font-weight: bolder">
                            总计:
                        </td>
                        <td width="300px">
                            <asp:Label ID="lblLvYouTotal" runat="server" Text="0"></asp:Label>
                        </td>
                        <td>
                            <asp:Button ID="btnLvYouAdd" CssClass="button1" runat="server" Text="新增" OnClick="btnLvYouAdd_Click" />
                        </td>
                    </tr>
                </table>
                 <asp:HiddenField ID="hiddenLvYouPrice" runat="server" />
                 <div class="kuang5">
                    <asp:GridView ID="gvLvYou" CssClass="tab2" HeaderStyle-CssClass="tabbt" FooterStyle-CssClass="tabcon"
                        AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel" PagerSettings-Mode="NumericFirstLast"
                        PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top" runat="server"
                        AutoGenerateColumns="False" OnRowDeleting="gvLvYou_RowDeleting" OnRowCommand="gvLvYou_RowCommand"
                        OnRowCreated="gvLvYou_RowCreated">
                        <Columns>
                            <asp:TemplateField HeaderText="购卡数量">
                                <ItemTemplate>
                                    <asp:TextBox ID="txtLvYouNum" Style="text-align: center" runat="server" Text='<%# Bind("LvYouNum") %>'
                                        onblur='SumLvYou();'></asp:TextBox>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="单价">
                                <ItemTemplate>
                                    <asp:TextBox ID="txtLvYouPrice" Style="text-align: center" runat="server" MaxLength="6"
                                        Text='<%# Bind("LvYouPrice") %>' onblur='SumLvYou();' ReadOnly="true"></asp:TextBox>&nbsp;元&nbsp;
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="总充值金额">
                                <ItemTemplate>
                                    <asp:TextBox ID="txtLvYouChargeMoney" Style="text-align: center" runat="server"
                                        MaxLength="10" Text='<%# Bind("LvYouChargeMoney") %>' onblur='SumLvYou();'></asp:TextBox>&nbsp;元&nbsp;
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField>
                                <ItemTemplate>
                                    <asp:Button ID="btnLvYouDelete" CssClass="button1" runat="server" CommandName="delete"
                                        CommandArgument="<%#Container.DataItemIndex%>" Text='删除' CausesValidation="False" />
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                </div>
                <table border="0" width="95%">
                    <tr>
                        <td>
                            <div class="card">
                                专有账户</div>
                        </td>
                        <td width="50px" style="font-weight: bolder">
                        </td>
                        <td>
                        </td>
                    </tr>
                </table>
                <div class="kuang5">
                    <table border="0" width="95%">
                        <tr>
                            <td width="80px" align="right">
                                总充值金额:
                            </td>
                            <td>
                                <asp:TextBox ID="txtGCTotalChargeMoney" runat="server" CssClass="input" onblur='SumGroupCard()'></asp:TextBox>&nbsp;元&nbsp;
                            </td>
                        </tr>
                    </table>
                </div>
                <table border="0" width="95%">
                    <tr>
                        <td align="left" width="20%">
                            <div class="card">
                                读卡器</div>
                        </td>
                        <td width="50px" style="font-weight: bolder">
                            总计:
                        </td>
                        <td width="300px">
                            <asp:Label ID="labReaderMoney" runat="server" Text="0"></asp:Label>
                        </td>
                        <td>
                        </td>
                    </tr>
                </table>
                <div class="kuang5">
                    <table border="0" width="95%">
                        <tr>
                            <td width="80px" align="right">
                                读卡器数量:
                            </td>
                            <td width="300px">
                                <asp:TextBox ID="txtReadernum" runat="server" CssClass="input" onblur='SumReader()'></asp:TextBox>&nbsp;个&nbsp;
                            </td>
                            <td width="100px" align="right">
                                读卡器单价:
                            </td>
                            <td>
                                <asp:TextBox ID="txtReaderPrice" runat="server" CssClass="input" onblur='SumReader()'
                                    Text="120"></asp:TextBox>&nbsp;元&nbsp;
                            </td>
                        </tr>
                    </table>
                </div>
                <table border="0" width="95%">
                    <tr>
                        <td align="left" width="20%">
                            <div class="card">
                                园林年卡</div>
                        </td>
                        <td width="50px" style="font-weight: bolder">
                            总计:
                        </td>
                        <td width="300px">
                            <asp:Label ID="labParkMoney" runat="server" Text="0"></asp:Label>
                        </td>
                        <td>
                        </td>
                    </tr>
                </table>
                <div class="kuang5">
                    <table border="0" width="95%">
                        <tr>
                            <td width="80px" align="right">
                                开卡数量:
                            </td>
                            <td width="300px">
                                <asp:TextBox ID="txtParkOpennum" runat="server" CssClass="input" onblur='SumGardenCard()'></asp:TextBox>&nbsp;张&nbsp;
                            </td>
                            <td width="100px" align="right">
                                开卡单价:
                            </td>
                            <td>
                                <asp:TextBox ID="txtParkOpenPrice" runat="server" CssClass="input" onblur='SumGardenCard()'
                                    Text="120"></asp:TextBox>&nbsp;元&nbsp;
                            </td>
                        </tr>
                    </table>
                </div>
                <table border="0" width="95%">
                    <tr>
                        <td align="left" width="20%">
                            <div class="card">
                                休闲年卡</div>
                        </td>
                        <td width="50px" style="font-weight: bolder">
                            总计:
                        </td>
                        <td width="300px">
                            <asp:Label ID="labXXMoney" runat="server" Text="0"></asp:Label>
                        </td>
                        <td>
                        </td>
                    </tr>
                </table>
                <div class="kuang5">
                    <table border="0" width="95%">
                        <tr>
                            <td width="80px" align="right">
                                开卡数量:
                            </td>
                            <td width="300px">
                                <asp:TextBox ID="txtXXOpennum" runat="server" CssClass="input" onblur='SumRelaxCard()'></asp:TextBox>&nbsp;张&nbsp;
                            </td>
                            <td width="100px" align="right">
                                开卡单价:
                            </td>
                            <td>
                                <asp:TextBox ID="txtXXPrice" runat="server" CssClass="input" onblur='SumRelaxCard()'
                                    Text="180"></asp:TextBox>&nbsp;元&nbsp;
                            </td>
                        </tr>
                    </table>
                </div>
                <div class="card">
                    是否关联</div>
                <div class="kuang5">
                    <table>
                        <tr>
                            <td width="80px">
                                <asp:RadioButton ID="Relate" Visible="true" Checked="true" Text="关联" GroupName="IsRelate"
                                    TextAlign="Right" runat="server" />
                            </td>
                            <td width="80px">
                                <asp:RadioButton ID="unRelate" Visible="true" Checked="false" Text="不关联" GroupName="IsRelate"
                                    TextAlign="Right" runat="server" />
                            </td>
                        </tr>
                    </table>
                </div>
            </div>
            <div class="btns">
                <table width="100%" border="0" align="right" cellpadding="0" cellspacing="0">
                    <tr>
                        <%--<td width="50px">总计:</td>
                           <td><asp:Label runat="server" Text="0"></asp:Label></td>--%>
                        <td width="80%" align="right">
                            <asp:Button ID="btnStockIn" CssClass="button1" runat="server" Text="更换" OnClientClick="return submitStockInConfirm()" />
                            <asp:LinkButton runat="server" ID="btnStockInConfirm" OnClick="btnSubmit_Click" />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                        </td>
                    </tr>
                </table>
            </div>
        </ContentTemplate>
        <Triggers>
            <asp:PostBackTrigger ControlID="btnStockInConfirm" />
        </Triggers>
    </asp:UpdatePanel>
    </form>
</body>
</html>

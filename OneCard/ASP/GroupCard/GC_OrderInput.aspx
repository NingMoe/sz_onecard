<%@ Page Language="C#" AutoEventWireup="true" CodeFile="GC_OrderInput.aspx.cs" Inherits="ASP_GroupCard_SZ_OrderInput" %>

<%@ Register Src="../../CardReader.ascx" TagName="CardReader" TagPrefix="cr" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>订单录入</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />

    <script type="text/javascript" src="../../js/mootools.js"></script>

    <%--<script type="text/javascript" src="../../js/jquery-1.5.min.js"></script>--%>

    <script type="text/javascript">


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
                                '总计: ' + $('txtTotalMoney').value + '元'
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
            var sztTotal = ($('lblSztTotal').innerText) * 100;
            var lvyouTotal = ($('lblLvYouTotal').innerText) * 100;
            if ($('txtGCTotalChargeMoney').value == "") {
                var gcTotal = 0;
            }
            else {
                var gcTotal = parseFloat($('txtGCTotalChargeMoney').value) * 100;
            }
            var readerTotal = ($('labReaderMoney').innerText) * 100;
            var gardenCardTotal = ($('labParkMoney').innerText) * 100;
            var relaxCardTotal = ($('labXXMoney').innerText) * 100;

            $('txtTotalMoney').value = (cashGiftTotal + chargeCardTotal + sztTotal + gcTotal + readerTotal + gardenCardTotal + relaxCardTotal + lvyouTotal) / 100.0;
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

</head>
<body>
    <cr:CardReader ID="cardReader" runat="server" />
    <form id="form1" runat="server">
    <div class="tb">
        订单录入
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
                    订单号查询</div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td width="8%">
                                <div align="right">
                                    单位名称:</div>
                            </td>
                            <td colspan="2" width="36%">
                                <asp:TextBox ID="txtCompany" CssClass="input" MaxLength="100" runat="server" AutoPostBack="true"
                                    OnTextChanged="queryCompany"></asp:TextBox>
                                <asp:DropDownList ID="selCompany" CssClass="inputmid" Width="206" runat="server"
                                    AutoPostBack="true" OnSelectedIndexChanged="selCompany_Change">
                                </asp:DropDownList>
                            </td>
                            <td width="8%">
                                <div align="right">
                                    联系人:</div>
                            </td>
                            <td width="12%">
                                <asp:TextBox ID="txtContactName" CssClass="input" runat="server"></asp:TextBox>
                            </td>
                            <td width="8%">
                                <div align="right">
                                    订单状态:</div>
                            </td>
                            <td width="12%">
                                <asp:DropDownList ID="selOrderStatus" CssClass="input" runat="server">
                                    <asp:ListItem Text="---请选择---" Value=""></asp:ListItem>
                                    <asp:ListItem Text="00:修改中" Value="00"></asp:ListItem>
                                    <asp:ListItem Text="01:录入待审核" Value="01"></asp:ListItem>
                                    <asp:ListItem Text="02:财务审核通过" Value="02"></asp:ListItem>
                                    <asp:ListItem Text="03:完成分配" Value="03"></asp:ListItem>
                                    <asp:ListItem Text="04:制卡中" Value="04"></asp:ListItem>
                                    <asp:ListItem Text="05:制卡完成" Value="05"></asp:ListItem>
                                    <asp:ListItem Text="06:不关联确认完成" Value="06"></asp:ListItem>
                                    <asp:ListItem Text="07:领用完成" Value="07"></asp:ListItem>
                                    <asp:ListItem Text="08:确认完成" Value="08"></asp:ListItem>
                                </asp:DropDownList>
                            </td>
                            <td width="16%">
                                <asp:Button runat="server" CssClass="button1" ID="btnOrderSelect" Text="查询" OnClick="btnOrderQuery_Click" />
                            </td>
                        </tr>
                    </table>
                </div>
                <div class="card">
                    订单查询</div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td width="8%">
                                <div align="right">
                                    订单号:</div>
                            </td>
                            <td colspan="2" width="36%">
                                <asp:DropDownList ID="selOrderNo" CssClass="inputlong" runat="server" AutoPostBack="true"
                                    OnSelectedIndexChanged="btnQuery_Click" />
                            </td>
                            <td width="8%">
                                <div align="right">
                                    订单状态:</div>
                            </td>
                            <td width="12%">
                                <asp:Label ID="labOrderState" runat="server"></asp:Label>
                            </td>
                            <td width="8%">
                            </td>
                            <td width="12%" align="right">
                                <asp:Button runat="server" CssClass="button1" ID="btnModify" Enabled="false" Text="修改"
                                    OnClick="btnModify_Click" />&nbsp;&nbsp;
                            </td>
                            <td width="16%">
                                <asp:Button runat="server" CssClass="button1" ID="btnCancel" Enabled="false" Text="作废"
                                    OnClick="btnCancel_Click" />
                            </td>
                        </tr>
                    </table>
                </div>
                <table border="0" width="95%">
                    <tr>
                        <td align="left" width="50%">
                            <div class="card">
                                订单信息</div>
                        </td>
                        <td width="50%" style="font-weight: bolder">
                            <asp:TextBox ID="lblOrderNo" CssClass="labeltext" Visible="false" ReadOnly="true"
                                runat="server"></asp:TextBox>
                        </td>
                    </tr>
                </table>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25" 
                       >
                        <tr>
                            <td width="12%">
                                <div align="right">
                                    单位名称:</div>
                            </td>
                            <td colspan="3" width="45%">
                          <%--  <asp:HiddenField ID="hidOldGroupName" runat="server" />--%>
                                <asp:HiddenField ID="hidOrderNo" runat="server" />
                                <asp:HiddenField ID="hidCompanyName" runat="server" />
                                <asp:HiddenField ID="hidCompanyNo" runat="server" />
                                <asp:TextBox ID="txtGroup" CssClass="inputmid" MaxLength="100" runat="server" AutoPostBack="true"
                                    OnTextChanged="queryGroup"></asp:TextBox>
                                <asp:DropDownList ID="selGroup" CssClass="inputmid" Width="206" runat="server" AutoPostBack="true"
                                    OnSelectedIndexChanged="selGroup_Change">
                                </asp:DropDownList>
                                <span class="red" runat="server" id="spnGroup">*</span>
                            </td>
                            <td width="12%">
                                <div align="right" style="white-space: nowrap">
                                    单位证件类型:</div>
                            </td>
                            <td width="12%" style="white-space: nowrap">
                                <asp:DropDownList ID="selComPapertype" CssClass="input" runat="server" OnSelectedIndexChanged="ValidCompany_Change"
                                    AutoPostBack="true">
                                </asp:DropDownList>
                                <span class="red" runat="server" id="spnComPapertype">*</span>
                            </td>
                            <td width="12%">
                                <div align="right">
                                    单位证件号码:</div>
                            </td>
                            <td width="12%" style="white-space: nowrap">
                                <asp:TextBox ID="txtComPaperno" CssClass="inputmid" MaxLength="30" runat="server"
                                    OnTextChanged="ValidCompany_Change" AutoPostBack="true"></asp:TextBox><span class="red"
                                        runat="server" id="spnComPaperno">*</span>
                            </td>
                        </tr>
                        <tr>
                            <td width="12%">
                                <div align="right">
                                    单位证件信息:</div>
                            </td>
                            <td colspan="2" width="30%" id="tdFileUpload" runat="server">
                                <%--<asp:HiddenField ID="hidContainMsg" runat="server" Value="0" />--%>
                                <asp:FileUpload ID="FileUpload1" runat="server" CssClass="inputlong" />
                               <%-- <span class="red" runat="server" id="spnCompanyMsg">*</span>--%>
                            </td>
                            <td id="tdShowPicture" runat="server" width = "20%" height="50">
                            <img id="preview" runat="server" alt="图片"  src="../../Images/cardface.jpg" style="cursor:hand" height="50"  align="middle"  />
                            </td>
                            <td id="tdMsg" runat="server" width = "20%" 
                                style="border-width: 40px; padding: 0px;" >
                                <asp:Label ID="lblMsg" runat="server" Text="单位证件扫描件为空，请尽快补录！" ForeColor="Red" ></asp:Label>
                            </td>
                            <td width="10%">
                                <div align="right">
                                    证件有效期:</div>
                            </td>
                            <td width="10%" style="white-space: nowrap">
                                <asp:TextBox ID="txtEndDate" CssClass="input" runat="server" MaxLength="20"></asp:TextBox>
                                <span class="red" runat="server" id="spnCompanyEndDate">*</span>
                                <ajaxToolkit:CalendarExtender ID="CalendarExtender1" runat="server" TargetControlID="txtEndDate"
                                    Format="yyyyMMdd" />
                            </td>
                            <td width="10%">
                                <div align="right">
                                    法人证件号码:</div>
                            </td>
                            <td width="10%">
                                <asp:TextBox ID="txtHoldNo" CssClass="inputmid" runat="server" MaxLength="20"></asp:TextBox>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    客户经办人:</div>
                            </td>
                            <td style="white-space: nowrap">
                                <asp:TextBox ID="txtName" CssClass="inputmid" runat="server" MaxLength="16"></asp:TextBox><span
                                    class="red">*</span>
                            </td>
                            <td>
                                <div align="right">
                                    性 别:</div>
                            </td>
                            <td>
                                <asp:DropDownList ID="selCustsex" CssClass="input" runat="server">
                                </asp:DropDownList>
                            </td>
                            <td>
                                <div align="right">
                                    证件类型:</div>
                            </td>
                            <td style="white-space: nowrap">
                                <asp:DropDownList ID="selPapertype" CssClass="input" runat="server" Width="117">
                                </asp:DropDownList>
                                <span class="red">*</span>
                            </td>
                            <td>
                                <div align="right">
                                    证号号码:</div>
                            </td>
                            <td>
                                <asp:TextBox ID="txtIDCardNo" CssClass="inputmid" runat="server" MaxLength="20"></asp:TextBox><span
                                    class="red">*</span>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    出生日期:</div>
                            </td>
                            <td>
                                <asp:TextBox ID="txtCustbirth" CssClass="inputmid" runat="server" MaxLength="8" />
                                <ajaxToolkit:CalendarExtender ID="FCalendar" runat="server" TargetControlID="txtCustbirth"
                                    Format="yyyyMMdd" />
                            </td>
                            <td>
                                <div align="right">
                                    联系电话:</div>
                            </td>
                            <td>
                                <asp:TextBox ID="txtPhone" CssClass="input" runat="server" MaxLength="20"></asp:TextBox>
                            </td>
                            <td>
                                <div align="right">
                                    联系地址:</div>
                            </td>
                            <td >
                                <asp:TextBox ID="txtCustaddr" CssClass="inputlong" MaxLength="100" runat="server" Width="200"></asp:TextBox>
                            </td>
                            <td>
                                <div align="right">
                                    身份证有效期:</div>
                            </td>
                            <td width="10%" style="white-space: nowrap">
                                <asp:TextBox ID="txtPaperEndDate" CssClass="input" runat="server" MaxLength="8"></asp:TextBox>
                                <span class="red" runat="server" id="Span1">*</span>
                                <ajaxToolkit:CalendarExtender ID="CalendarExtender3" runat="server" TargetControlID="txtPaperEndDate"
                                    Format="yyyyMMdd" />
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    电子邮件:</div>
                            </td>
                            <td>
                                <asp:TextBox ID="txtEmail" CssClass="inputmid" MaxLength="40" runat="server"></asp:TextBox>
                            </td>
                            <td style="white-space: nowrap">
                                <div align="right">
                                    转出银行帐号:</div>
                            </td>
                            <td>
                                <asp:TextBox ID="txtOutbank" CssClass="input" MaxLength="100" runat="server"></asp:TextBox>
                            </td>
                            <td>
                                <div align="right">
                                    转出账户户名:</div>
                            </td>
                            <td>
                                <asp:TextBox ID="txtOutacct" CssClass="input" MaxLength="30" runat="server"></asp:TextBox>
                            </td>
                            <td>
                            </td>
                            <td>
                                <asp:Button ID="txtReadPaper" Text="读二代证" CssClass="button1" runat="server" OnClientClick="readIDCard('txtName', 'selCustsex', 'txtCustbirth', 'selPapertype', 'txtIDCardNo', 'txtCustaddr')" />
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    业务受理人:</div>
                            </td>
                            <td>
                                &nbsp;<asp:TextBox ID="txtOperator" CssClass="labeltext" runat="server" MaxLength="20"></asp:TextBox>
                            </td>
                            <td>
                                <div align="right">
                                   客户经理部门:</div>
                            </td>
                            <td>
                                <asp:DropDownList ID="selDept" CssClass="inputmid" runat="server" AutoPostBack="true"
                                    OnSelectedIndexChanged="selDept_Changed">
                                </asp:DropDownList>
                            </td>
                            <td>
                                <div align="right">
                                    客户经理:</div>
                            </td>
                            <td style="white-space: nowrap">
                                <asp:DropDownList ID="selStaff" CssClass="inputmid" runat="server">
                                </asp:DropDownList><span class="red">*</span>
                            </td>
                            <td>
                                <div align="right">
                                    购卡总金额:</div>
                            </td>
                            <td>
                                <asp:TextBox ID="txtTotalMoney" CssClass="labeltext" Width="100" runat="server" Text="0"
                                    ReadOnly="true"></asp:TextBox>元

                            </td>
                           
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    备注:</div>
                            </td>
                            <td colspan="3">
                                <asp:TextBox runat="server" TextMode="MultiLine" ID="txtRemark" CssClass="inputlong"
                                    Width="400px" Height="50px" MaxLength="400" />
                            </td>
                            <td >
                                <div align="right">
                                    安全值:</div>
                            </td>
                            <td>
                                <asp:TextBox ID="txtSecurityValue" runat="server" CssClass="input" ></asp:TextBox>
                                
                            </td>
                        </tr>
                        <tr>
                         <td width="12%">
                                <div align="right">
                                    经办人证件信息:</div>
                            </td>
                            <td colspan="2" width="30%" id="tdFileUpload2" runat="server">
                                <asp:FileUpload ID="FileUpload2" runat="server" CssClass="inputlong" />
                            </td>
                            <td id="tdShowPicture2" runat="server" width = "20%" height="50">
                            <img id="preview2" runat="server" alt="图片"  src="../../Images/cardface.jpg" style="cursor:hand" height="50"  align="middle"  />
                            </td>
                            <td id="tdMsg2" runat="server" width = "20%" 
                                style="border-width: 40px; padding: 0px;" >
                                <asp:Label ID="lblMsg2" runat="server" Text="客户经办人证件信息为空" ForeColor="Red" ></asp:Label>
                            </td>
                        </tr>
                    </table>
                </div>
                <div class="card">
                    订单类型</div>
                <div class="kuang5">
                    <table>
                        <tr>
                            <td width="80px">
                                <asp:RadioButton ID="CompanyOrder" Visible="true" Checked="true" Text="单位订单" GroupName="OrderType"
                                    TextAlign="Right" runat="server" AutoPostBack="true" OnCheckedChanged="OrderType_Changed" />
                            </td>
                            <td width="80px">
                                <asp:RadioButton ID="Personal" Visible="true" Checked="false" Text="个人订单" GroupName="OrderType"
                                    TextAlign="Right" runat="server" AutoPostBack="true" OnCheckedChanged="OrderType_Changed" />
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
                            <asp:TemplateField HeaderText="卡费是否开具增值税专票">
                                <ItemTemplate>
                                     <asp:CheckBox ID="chkTax" runat="server" Text="是"/>
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
                    期望领卡网点及日期</div>
                <div class="kuang5">
                    <table border="0" width="95%">
                        <tr>
                            <td width="80px" align="right">
                                领卡网点:
                            </td>
                            <td width="300px">
                                <asp:DropDownList ID="selGetDept" runat="server" CssClass="inputmidder">
                                </asp:DropDownList>
                            </td>
                            <td width="100px" align="right">
                                领卡日期:
                            </td>
                            <td>
                                <asp:TextBox ID="txtGetDate" runat="server" CssClass="input" MaxLength="8"></asp:TextBox>
                                <ajaxToolkit:CalendarExtender ID="FCalendar1" runat="server" TargetControlID="txtGetDate"
                                    Format="yyyyMMdd" />
                            </td>
                        </tr>
                    </table>
                </div>
                <table border="0" width="95%">
                    <tr>
                        <td align="left" width="20%">
                            <div class="card">
                                开票</div>
                        </td>
                        <td width="50px" style="font-weight: bolder">
                            总计:
                        </td>
                        <td width="300px">
                            <asp:Label ID="labInvoiceMoney" runat="server" Text="0"></asp:Label>
                        </td>
                        <td>
                            <asp:Button ID="btnInvoiceAdd" CssClass="button1" runat="server" Text="新增" OnClick="btnInvoiceAdd_Click" />
                        </td>
                    </tr>
                </table>
                <div class="kuang5">
                    <asp:GridView ID="gvInvoice" CssClass="tab2" HeaderStyle-CssClass="tabbt" FooterStyle-CssClass="tabcon"
                        AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel" PagerSettings-Mode="NumericFirstLast"
                        PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top" runat="server"
                        AutoGenerateColumns="False" OnRowDeleting="gvInvoice_RowDeleting" OnRowCommand="gvInvoice_RowCommand"
                        OnRowCreated="gvInvoice_RowCreated">
                        <Columns>
                            <asp:TemplateField HeaderText="发票类型">
                                <ItemTemplate>
                                    <%-- <asp:TextBox ID="txtInvoicetype" onblur='SumChargeCard();' Style="text-align: center"
                                        runat="server" Text='<%# Bind("Invoicetype") %>'></asp:TextBox>--%>
                                    <asp:DropDownList ID="selInvoicetype" CssClass="inputmid" runat="server">
                                    </asp:DropDownList>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <%--<asp:TemplateField HeaderText="发票数量">
                                <ItemTemplate>
                                    <asp:TextBox ID="txtInvoiceNum" Style="text-align: center" runat="server" Text='<%# Bind("InvoiceNum") %>'></asp:TextBox>
                                </ItemTemplate>
                            </asp:TemplateField>--%>
                            <asp:TemplateField HeaderText="发票金额">
                                <ItemTemplate>
                                    <asp:TextBox ID="txtInvoiceMoney" Style="text-align: center" runat="server" MaxLength="10"
                                        Text='<%# Bind("InvoiceMoney") %>' onblur='SumInvoiceMoney();'></asp:TextBox>&nbsp;元&nbsp;
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField>
                                <ItemTemplate>
                                    <asp:Button ID="btnInvoiceDelete" CssClass="button1" runat="server" CommandName="delete"
                                        CommandArgument="<%#Container.DataItemIndex%>" Text='删除' CausesValidation="False" />
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                </div>
                <div class="card">
                    付款方式</div>
                <div class="kuang5">
                    <table>
                        <tr>
                            <td>
                                <asp:CheckBoxList ID="chkListPayType" runat="server" RepeatDirection="Horizontal">
                                    <asp:ListItem Value="0">支/本票&nbsp;&nbsp;&nbsp;&nbsp;</asp:ListItem>
                                    <asp:ListItem Value="1">转帐&nbsp;&nbsp;&nbsp;&nbsp;</asp:ListItem>
                                    <asp:ListItem Value="2">现金&nbsp;&nbsp;&nbsp;&nbsp;</asp:ListItem>
                                    <asp:ListItem Value="3">刷卡&nbsp;&nbsp;&nbsp;&nbsp;</asp:ListItem>
                                    <asp:ListItem Value="4">呈批单</asp:ListItem>
                                </asp:CheckBoxList>
                            </td>
                        </tr>
                    </table>
                </div>
                <div class="card">
                    开票方式</div>
                <div class="kuang5">
                    <table>
                        <tr>
                            <td>
                                <asp:CheckBoxList ID="chkPrintType" runat="server" RepeatDirection="Horizontal">
                                    <asp:ListItem Value="0">纸质开票</asp:ListItem>
                                    <asp:ListItem Value="1">电子开票</asp:ListItem>
                                   
                                </asp:CheckBoxList>
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
                            <%--<asp:Button ID="btnStockIn" CssClass="button1" runat="server" Text="新增" OnClientClick="return submitCompany()" />--%>
                            <asp:Button ID="btnStockIn" CssClass="button1" runat="server" Text="新增" OnClientClick="return submitStockInConfirm()" />
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

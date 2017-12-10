<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PB_SaleReader.aspx.cs" Inherits="ASP_PersonalBusiness_PB_SaleReader" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>读卡器出售</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <script type="text/javascript" src="../../js/print.js"></script>
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="../../js/myext.js"></script>
    <script type="text/javascript" src="../../js/cardreaderhelper.js"></script>
    <script type="text/javascript" src="../../js/mootools.js"></script>
    <script type="text/javascript" language="javascript">
        function SelectRadioTag() {
            if ($get('hidSaleType').value == "1") {
                $get('radSingle').checked = true;
            }
            else {
                $get('radBatch').checked = true;
            }
            SelectRadio();
            return false;
        }
        function SelectRadio() {
            if ($get('radSingle').checked == true) {
                $get('hidSaleType').value = "1";
                $get('BatchReaderNo').style.display = "none";
                $get('BatchMoney').style.display = "none";
                $get('custInfoTitle').style.display = "block";
                $get('custInfo').style.display = "block";
            }
            else {
                $get('hidSaleType').value = "0";
                $get('BatchReaderNo').style.display = "block";
                $get('BatchMoney').style.display = "block";
                $get('custInfoTitle').style.display = "none";
                $get('custInfo').style.display = "none";
            }
            return false;
        }

        function Change() {
            var sFCard = $('txtReader').value;
            var sECard = $('txtEndReader').value;
            var sMoney = $('txtSaleMoney').value;
            var lCardSum = 0;
            var lCardMoney = 0;
            if (sFCard.test("^\\s*\\d{16}\\s*$") && sECard.test("\\s*^\\d{16}\\s*$")) {
                var lFCard = sFCard.toInt();
                var lECard = sECard.toInt();
                if (lECard - lFCard >= 0)
                    lCardSum = lECard - lFCard + 1;
            }

            if (sMoney.test("^\\d{1,10}(\\.\\d{0,2})?$")) {
                lCardMoney += sMoney.toFloat();
            }

            document.getElementById("txtReaderNum").value = lCardSum;
            document.getElementById("txtMoneySum").value = lCardSum * lCardMoney + " * 100 分";
        }

        function singleSubmitConfirm() {
            if (true) {
                MyExtConfirm('确认',
		        '出售读卡器' + $get('txtReader').value + '，<br>是否确认出售？'
		        , submitConfirmCallback);
            }

            return false;
        }
        function batchSubmitConfirm() {
            if (true) {
                MyExtConfirm('确认',
		        '批量出售读卡器' + $get('txtReader').value + '-' + $get('txtEndReader').value + '，<br>是否确认出售？'
		        , submitConfirmCallback);
            }

            return false;
        }
        function submitConfirmCallback(btn) {
            if (btn == 'yes') {
                $get('btnConfirm').click();
            }

            return false;
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
    <div class="tb">
        个人业务->读卡器出售</div>
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
    <asp:UpdatePanel ID="UpdatePanel1" runat="server" RenderMode="Inline">
        <ContentTemplate>
            <aspControls:PrintPingZheng ID="ptnPingZheng" runat="server" PrintArea="ptnPingZheng1" />
            <asp:BulletedList ID="bulMsgShow" runat="server">
            </asp:BulletedList>
            <script runat="server">public override void ErrorMsgShow() { ErrorMsgHelper(bulMsgShow); }</script>
            <asp:HiddenField ID="hidSaleType" runat="server" />
            <asp:HiddenField ID="hidTradeid" runat="server" />
            <asp:HiddenField ID="hidReaderno" runat="server" />
            <asp:HiddenField ID="hidEndReaderno" runat="server" />
            <asp:HiddenField ID="hidSaleMoney" runat="server" />
            <asp:HiddenField ID="hidReaderNum" runat="server" />
            <div class="con">
                <div class="card">
                    读卡器出售</div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="1" class="text20">
                        <tr>
                            <td width="12%" align="right">
                                <input type="radio" value="单个出售" name="Batchradio" id="radSingle" checked="checked"
                                    onclick="SelectRadio()" />单个出售
                            </td>
                            <td width="12%" align="left">
                                &nbsp;&nbsp;&nbsp;
                                <input type="radio" value="批量出售" name="Batchradio" id="radBatch" onclick="SelectRadio()" />批量出售
                            </td>
                            <td width="76%">
                            </td>
                        </tr>
                        <tr>
                            <td width="12%" align="right">
                                读卡器序列号:
                            </td>
                            <td width="12%">
                                <asp:TextBox ID="txtReader" CssClass="inputmid" runat="server" MaxLength="16" AutoPostBack="true"
                                    OnTextChanged="Reader_OnTextChanged" />
                            </td>
                            <td width="76%">
                                <table id="BatchReaderNo" style="display: none" width="100%" border="0" cellpadding="0"
                                    cellspacing="1" class="text20">
                                    <tr>
                                        <td align="left" width="20%">
                                            -<asp:TextBox ID="txtEndReader" CssClass="inputmid" runat="server" MaxLength="16" />
                                        </td>
                                        <td width="20%">
                                            <div align="right">
                                                出售数量:</div>
                                        </td>
                                        <td width="60%">
                                            <asp:TextBox ID="txtReaderNum" CssClass="labeltext" runat="server"></asp:TextBox>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                    </table>
                </div>
                <div class="pip" id="custInfoTitle" style="display: block">
                    用户信息</div>
                <div class="kuang5" id="custInfo" style="display: block">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td width="12%" align="right">
                                用户姓名:
                            </td>
                            <td width="12%">
                                <asp:TextBox ID="txtCustName" CssClass="input" runat="server" MaxLength="50" />
                            </td>
                            <td width="12%" align="right">
                                出生日期:
                            </td>
                            <td width="12%">
                                <asp:TextBox ID="txtCustBirth" CssClass="input" runat="server" MaxLength="8" />
                            </td>
                            <ajaxToolkit:CalendarExtender ID="FCalendar" runat="server" TargetControlID="txtCustBirth"
                                Format="yyyy-MM-dd" />
                            <td width="12%" align="right">
                                证件类型:
                            </td>
                            <td width="12%">
                                <asp:DropDownList ID="selPaperType" CssClass="input" runat="server">
                                </asp:DropDownList>
                            </td>
                            <td width="12%" align="right">
                                证件号码:
                            </td>
                            <td width="16%">
                                <asp:TextBox ID="txtPaperNo" CssClass="inputmid" runat="server" MaxLength="20" />
                            </td>
                        </tr>
                        <tr>
                            <td align="right">
                                用户性别:
                            </td>
                            <td>
                                <asp:DropDownList ID="selCustSex" CssClass="input" runat="server" />
                                <td align="right">
                                    联系电话:
                                </td>
                                <td>
                                    <asp:TextBox ID="txtCustPhone" CssClass="input" runat="server" MaxLength="20" />
                                </td>
                                <td align="right">
                                    邮政编码:
                                </td>
                                <td>
                                    <asp:TextBox ID="txtCustPost" CssClass="input" runat="server" MaxLength="6" />
                                </td>
                                <td align="right">
                                    联系地址:
                                </td>
                                <td>
                                    <asp:TextBox ID="txtCustAddr" CssClass="inputmid" runat="server" MaxLength="50" />
                                </td>
                        </tr>
                        <tr>
                            <td align="right">
                                电子邮件:
                            </td>
                            <td>
                                <asp:TextBox ID="txtEmail" CssClass="input" runat="server" MaxLength="30" />
                            </td>
                            <td align="right">
                                备注:
                            </td>
                            <td colspan="4">
                                <asp:TextBox ID="txtRemark" CssClass="inputlong" runat="server" MaxLength="50" />
                            </td>
                            <td>
                                <asp:Button ID="txtReadPaper" Text="读二代证" CssClass="button1" runat="server" OnClientClick="readIDCard('txtCustName', 'selCustSex', 'txtCustBirth', 'selPaperType', 'txtPaperNo', 'txtCustAddr')" />
                            </td>
                        </tr>
                    </table>
                </div>
                <div class="money">
                    费用信息</div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text20">
                        <tr>
                            <td width="12%" align="right">
                                销售单价:
                            </td>
                            <td width="12%">
                                <asp:TextBox ID="txtSaleMoney" CssClass="input" runat="server" MaxLength="4" Width="50px" />
                                <span class="red">*</span>100 分
                            </td>
                            <td width="76%">
                                <table id="BatchMoney" style="display: none" width="100%" border="0" cellpadding="0"
                                    cellspacing="0" class="text20">
                                    <tr>
                                        <td width="20%">
                                            <div align="right">
                                                总金额:</div>
                                        </td>
                                        <td width="20%">
                                            <asp:TextBox ID="txtMoneySum" CssClass="labeltext" runat="server" Text="0 * 100 分" />
                                        </td>
                                        <td width="20%" align="right">
                                            备注:
                                        </td>
                                        <td width="40%">
                                            <asp:TextBox ID="txtBatchRemark" CssClass="inputlong" runat="server" MaxLength="100" />
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                    </table>
                </div>
            </div>
            <div class="footall">
            </div>
            <div class="btns">
                <table width="200" align="right" border="0" cellpadding="0" cellspacing="0">
                    <tr>
                        <td>
                            <asp:Button ID="btnPrintPZ" runat="server" Text="打印凭证" CssClass="button1" Enabled="false"
                                OnClick="btnPrintPZ_Click" />
                        </td>
                        <td>
                            <asp:LinkButton runat="server" ID="btnConfirm" OnClick="btnConfirm_Click" />
                            <asp:Button ID="btnSubmit" Enabled="true" CssClass="button1" runat="server" Text="提交"
                                OnClick="btnSubmit_Click" />
                        </td>
                    </tr>
                </table>
                <asp:CheckBox ID="chkPingzheng" runat="server" Text="自动打印凭证" Checked="true" />
            </div>
            <div style="display: none" runat="server" id="printarea">
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
    </form>
</body>
</html>

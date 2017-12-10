<%@ Page Language="C#" AutoEventWireup="true" CodeFile="AS_SZTravelCardSale.aspx.cs"
    Inherits="ASP_AddtionalService_AS_SZTravelCardSale" %>

<%@ Register Src="../../CardReader.ascx" TagName="CardReader" TagPrefix="cr" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>旅游卡-售卡</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />

    <script type="text/javascript" src="../../js/print.js"></script>

    <script type="text/javascript" language="javascript">
        function saleCheck() {
            var ret = ReadCardInfoForCheck();
            if (!ret) {
                return false;
            }

            if (cardReader.CardInfo.cardNo != $get('txtCardno').value) {
                MyExtAlert("警告", "读卡器上卡片为:<br>"
            + '<span class="red">' + cardReader.CardInfo.cardNo + '</span>'
            + "<br>先前读出卡号为: <br>"
            + '<span class="red">' + $get('txtCardno').value + '</span>'
            + "<br>不一致。<br><br> 请重新点击读卡按钮后再充值！");
                return false;
            }

            if (!checkMaxBalance()) return false;

            MyExtConfirm('提示', '是否确认充值:' + $get('SupplyFee').innerHTML + '元?', SupplyCheckConfirm);

            //$get('linkbtnSale').click();
            return false;
        }

        function changemoneySupply(realmoney) {

            realmoney.value = realmoney.value.replace(/[^\d]/g, '');
            $get('SupplyFee').innerHTML = (parseFloat(realmoney.value)).toFixed(2);

            if ($get('SupplyFee').innerHTML == 'NaN') {
                $get('SupplyFee').innerHTML = '0.00';
            }

            var depositFee = parseFloat($get('hiddenDepositFee').value);
            var cardcostFee = parseFloat($get('hiddenCardcostFee').value);

            $get('TotalFee').innerHTML = (parseFloat(realmoney.value) + depositFee + cardcostFee).toFixed(2);
            if ($get('TotalFee').innerHTML == 'NaN') {
                $get('TotalFee').innerHTML = '0.00';
            }
        }
        function setChargeValue(chargeVal) {
            $get('SupplyMoney').value = chargeVal;
            changemoneySupply($get('SupplyMoney'));
            return false;
        }
    </script>

    <script type="text/javascript" language="javascript">
        function submitConfirm(checkednum) {

            if (true) {
                MyExtMsg('确认',
		         checkednum + '，请与顾客核实是否确认充值电子钱包。');
            }
            return false;
        }

        function focusSubmit() {
            if (event.keyCode == 13 && event.srcElement.type != "submit" && event.srcElement.type != "button") {
                event.returnValue = false;
                saleCheck();
            }
        }
    </script>

    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <cr:CardReader ID="cardReader" runat="server" />
    <form id="form1" runat="server">
    <div class="tb">
        附加业务->旅游卡-售卡
    </div>
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
            <aspControls:PrintPingZheng ID="ptnPingZheng" runat="server" PrintArea="ptnPingZheng1" />
            <asp:BulletedList ID="bulMsgShow" runat="server">
            </asp:BulletedList>

            <script runat="server">public override void ErrorMsgShow() { ErrorMsgHelper(bulMsgShow); }</script>

            <div class="con">
                <div class="card">
                    卡片信息</div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td width="10%">
                                <div align="right">
                                    用户卡号:</div>
                            </td>
                            <td width="13%">
                                <asp:TextBox ID="txtCardno" CssClass="labeltext" MaxLength="16" runat="server"></asp:TextBox>
                            </td>
                            <td width="9%">
                                <div align="right">
                                    卡序列号:</div>
                            </td>
                            <td width="13%">
                                <asp:TextBox ID="LabAsn" CssClass="labeltext" runat="server"></asp:TextBox>
                            </td>
                            <asp:HiddenField ID="hiddenAsn" runat="server" />
                            <td width="9%">
                                <div align="right">
                                    卡片类型:</div>
                            </td>
                            <td width="13%">
                                <asp:TextBox ID="LabCardtype" CssClass="labeltext" runat="server"></asp:TextBox>
                            </td>
                            <asp:HiddenField ID="hiddenLabCardtype" runat="server" />
                            <td width="9%">
                                <div align="right">
                                    卡片状态:</div>
                            </td>
                            <td width="9%">
                                <asp:TextBox ID="RESSTATE" CssClass="labeltext" runat="server"></asp:TextBox>
                            </td>
                            <td width="12%">
                                <asp:Button ID="btnReadCard" CssClass="button1" runat="server" Text="读卡" OnClientClick="return ReadCardInfo()"
                                    OnClick="btnReadCard_Click" />
                            </td>
                        </tr>
                        <asp:HiddenField ID="hidOtherFee" runat="server" />
                        <asp:HiddenField runat="server" ID="hidWarning" />
                        <tr>
                            <td>
                                <div align="right">
                                    启用日期:</div>
                            </td>
                            <td>
                                <asp:TextBox ID="sDate" CssClass="labeltext" Width="100" runat="server" Text=""></asp:TextBox>
                            </td>
                            <asp:HiddenField ID="hiddensDate" runat="server" />
                            <td>
                                <div align="right">
                                    结束日期:</div>
                            </td>
                            <td>
                                <asp:TextBox ID="eDate" CssClass="labeltext" runat="server" Text=""></asp:TextBox>
                            </td>
                            <asp:HiddenField ID="hiddeneDate" runat="server" />
                            <td>
                                <div align="right">
                                    卡内余额:</div>
                            </td>
                            <td>
                                <asp:TextBox ID="cMoney" CssClass="labeltext" runat="server" Text=""></asp:TextBox>
                            </td>
                            <asp:HiddenField ID="hiddencMoney" runat="server" />
                            <asp:HiddenField ID="hiddentradeno" runat="server" />
                            <asp:HiddenField ID="hidSupplyFee" runat="server" />
                            <asp:HiddenField ID="hidSupplyOtherFee" runat="server" />
                            <asp:HiddenField ID="hidSupplyMoney" runat="server" />
                            <asp:HiddenField runat="server" ID="hidCardReaderToken" />
                            <asp:LinkButton runat="server" ID="btnConfirm" OnClick="btnConfirm_Click" />
                            <asp:HiddenField ID="hidpdotype" runat="server" />
                            <asp:HiddenField ID="hidoutTradeid" runat="server" />
                            <asp:HiddenField runat="server" ID="hidCardnoForCheck" />
                            <asp:HiddenField ID="hidIsJiMing" runat="server" />
                            <td colspan="2" align="center">
                                <asp:Button ID="btnCheckRead" CssClass="button1" runat="server" Text="充值校验" OnClientClick="return readCardForCheck()" />
                            </td>
                            <td width="12%">
                                &nbsp;
                            </td>
                        </tr>
                    </table>
                    <asp:HiddenField runat="server" ID="hidAccRecv" />
                </div>
                <div class="pip" style="display: none">
                    用户信息</div>
                <div class="kuang5" style="display: none">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td width="10%">
                                <div align="right">
                                    用户姓名:</div>
                            </td>
                            <td width="13%">
                                <asp:TextBox ID="txtCusname" CssClass="input" MaxLength="25" runat="server"></asp:TextBox>
                            </td>
                            <td width="9%">
                                <div align="right">
                                    出生日期:</div>
                            </td>
                            <td width="13%">
                                <asp:TextBox ID="txtCustbirth" CssClass="input" runat="server" MaxLength="10" />
                                <ajaxToolkit:CalendarExtender ID="FCalendar" runat="server" TargetControlID="txtCustbirth"
                                    Format="yyyy-MM-dd" />
                            </td>
                            <td width="9%">
                                <div align="right">
                                    证件类型:</div>
                            </td>
                            <td width="13%">
                                <asp:DropDownList ID="selPapertype" CssClass="input" runat="server">
                                </asp:DropDownList>
                            </td>
                            <td width="9%">
                                <div align="right">
                                    证件号码:</div>
                            </td>
                            <td width="24%" colspan="3">
                                <asp:TextBox ID="txtCustpaperno" CssClass="input" MaxLength="20" runat="server"></asp:TextBox>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    用户性别:</div>
                            </td>
                            <td>
                                <asp:DropDownList ID="selCustsex" CssClass="input" runat="server">
                                </asp:DropDownList>
                            </td>
                            <td>
                                <div align="right">
                                    联系电话:</div>
                            </td>
                            <td>
                                <asp:TextBox ID="txtCustphone" CssClass="input" MaxLength="20" runat="server"></asp:TextBox>
                            </td>
                            <td>
                                <div align="right">
                                    邮政编码:</div>
                            </td>
                            <td>
                                <asp:TextBox ID="txtCustpost" CssClass="input" MaxLength="6" runat="server"></asp:TextBox>
                            </td>
                            <td>
                                <div align="right">
                                    联系地址:</div>
                            </td>
                            <td colspan="3">
                                <asp:TextBox ID="txtCustaddr" CssClass="input" MaxLength="50" runat="server"></asp:TextBox>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                电子邮件:
                            </td>
                            <td>
                                <asp:TextBox ID="txtEmail" CssClass="input" MaxLength="30" runat="server"></asp:TextBox>
                            </td>
                            <td valign="top">
                                <div align="right">
                                    备注 :</div>
                            </td>
                            <td colspan="4">
                                <asp:TextBox ID="txtRemark" CssClass="inputlong" MaxLength="50" runat="server"></asp:TextBox>
                            </td>
                            <td>
                                <asp:Button ID="txtReadPaper" Text="读二代证" CssClass="button1" runat="server" OnClientClick="readIDCardEx('txtCusname', 'selCustsex', 'txtCustbirth', 'selPapertype', 'txtCustpaperno', 'txtCustaddr')"
                                    OnClick="txtReadPaper_Click" />
                            </td>
                        </tr>
                    </table>
                </div>
            </div>
            <div class="basicinfo">
                <div class="money">
                    费用信息</div>
                <div class="kuang5">
                    <div style="height: 104px">
                        <table width="180" border="0" cellpadding="0" cellspacing="0" class="tab1">
                            <tr class="tabbt">
                                <td width="66">
                                    费用项目
                                </td>
                                <td width="94">
                                    费用金额(元)
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    押金
                                </td>
                                <asp:HiddenField ID="hiddenDepositFee" runat="server" />
                                <td>
                                    <asp:Label ID="DepositFee" runat="server" Text=""></asp:Label>
                                </td>
                            </tr>
                            <tr class="tabjg">
                                <td>
                                    手续费
                                </td>
                                <asp:HiddenField ID="hiddenCardcostFee" runat="server" />
                                <td>
                                    <asp:Label ID="CardcostFee" runat="server" Text=""></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    充值
                                </td>
                                <td>
                                    <asp:Label ID="SupplyFee" runat="server" Text=""></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <tr class="tabjg">
                                    <td>
                                        合计应收
                                    </td>
                                    <td>
                                        <asp:Label ID="TotalFee" runat="server" Text=""></asp:Label>
                                    </td>
                                </tr>
                        </table>
                    </div>
                </div>
            </div>
            <div class="pipinfo">
                <div class="info">
                    充值信息</div>
                <div class="kuang5">
                    <div class="bigkuang2">
                        <div class="left">
                            <img src="../../Images/show.JPG" id="Pic" width="126" height="74" /></div>
                        <div class="big2" style="height: 95px">
                            <table width="280" border="0" cellspacing="0" cellpadding="0" id="SupplyTable">
                                <tr>
                                    <td colspan="3" class="red">
                                        请输入充值金额
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                    </td>
                                    <td colspan="2">
                                        <span class="red">
                                            <asp:TextBox ID="SupplyMoney" CssClass="input" AutoPostBack="true" OnTextChanged="SupplyMoney_Changed"
                                                MaxLength="7" runat="server"></asp:TextBox>
                                        </span>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="3">
                                        <asp:LinkButton runat="server" ID="charge1" Text="充168元" OnClientClick="return setChargeValue(168);"></asp:LinkButton>
                                        <asp:LinkButton runat="server" ID="charge2" Text="充268元" OnClientClick="return setChargeValue(268);"></asp:LinkButton>
                                        <asp:LinkButton runat="server" ID="charge3" Text="充368元" OnClientClick="return setChargeValue(368);"></asp:LinkButton>
                                        <asp:LinkButton runat="server" ID="charge4" Text="充468元" OnClientClick="return setChargeValue(468);"></asp:LinkButton>
                                    </td>
                                </tr>
                                <tr style="height: 5px">
                                    <td colspan="3">
                                    </td>
                                </tr>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
            <div class="footall">
            </div>
            <div class="btns">
                <table width="200" border="0" align="right" cellpadding="0" cellspacing="0">
                    <tr>
                        <td>
                            <asp:Button ID="btnPrintPZ" runat="server" Text="打印凭证" CssClass="button1" Enabled="false"
                                OnClientClick="printdiv('ptnPingZheng1')" />
                        </td>
                        <td>
                            <%--<asp:LinkButton runat="server" ID="linkbtnSale" OnClick="btnSale_Click" />--%>
                            <asp:Button ID="btnSale" CssClass="button1" runat="server" Text="售卡充值" Enabled="false"
                                OnClientClick="return saleCheck()" />
                        </td>
                    </tr>
                </table>
                <asp:CheckBox ID="chkPingzheng" runat="server" Checked="true" Text="自动打印凭证" />
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
    </form>

    <script type="text/javascript">
        $get('btnReadCard').focus();
    </script>

</body>
</html>

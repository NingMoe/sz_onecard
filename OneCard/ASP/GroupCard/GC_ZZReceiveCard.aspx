﻿<%@ Page Language="C#" AutoEventWireup="true" CodeFile="GC_ZZReceiveCard.aspx.cs" Inherits="ASP_GroupCard_GC_ZZReceiveCard" %>

<%@ Register Src="../../CardReader.ascx" TagName="CardReader" TagPrefix="cr" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>转转卡领卡售卡</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <script type="text/javascript" src="../../js/print.js"></script>
    <script type="text/javascript" language="javascript">
        function saleSupplyCheck() {
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

            $get('linkbtnSupply').click();
            return false;
        }

        function changemoneySupply(realmoney) {

            realmoney.value = realmoney.value.replace(/[^\d]/g, '');
            $get('SupplyFee').innerHTML = (parseFloat(realmoney.value)).toFixed(2);

            if ($get('SupplyFee').innerHTML == 'NaN') {
                $get('SupplyFee').innerHTML = '0.00';
            }

            $get('TotalSupply').innerHTML = (parseFloat(realmoney.value)).toFixed(2);
            if ($get('TotalSupply').innerHTML == 'NaN') {
                $get('TotalSupply').innerHTML = '0.00';
            }
        }
        function setChargeValue(chargeVal) {
            $get('SupplyMoney').value = chargeVal;
            changemoneySupply($get('SupplyMoney'));
            return false;
        }
        function choosePintPingZheng() {
            var chkPingzheng = document.getElementById('chkPingzheng');
            var chkPingzhengRemin = document.getElementById('chkPingzhengRemin');
                if (chkPingzheng.checked == false && chkPingzhengRemin.checked == false) {
                    MyExtAlert("警告", "请选择打印方式后再打印！");
                }
                if (chkPingzheng.checked == true) {
                    printdiv('ptnPingZheng1');
                }
                if (chkPingzhengRemin.checked == true) {
                    printdiv('ptnPingZheng2');
                }            
        }
        function chkPingZheng() {
            var chkPingzheng = document.getElementById('chkPingzheng');
            var chkPingzhengRemin = document.getElementById('chkPingzhengRemin');
            if (chkPingzheng.checked == true)
             {
                 chkPingzhengRemin.checked = false;
            }
            
        }
        function chkPingZhengRemin() {
            var chkPingzheng = document.getElementById('chkPingzheng');
            var chkPingzhengRemin = document.getElementById('chkPingzhengRemin');
            if (chkPingzhengRemin.checked == true) {
                chkPingzheng.checked = false;
            }
        }
        
    </script>
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <cr:CardReader ID="cardReader" runat="server" />
    <form id="form1" runat="server">
    <div class="tb">
        订单管理->转转卡领卡售卡
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
        <contenttemplate>
            <aspControls:PrintShouJu ID="ptnShouJu" runat="server" PrintArea="ptnShouJu1" />
            <aspControls:PrintPingZheng ID="ptnPingZheng" runat="server" PrintArea="ptnPingZheng1" />
            <aspControls:PrintRMPingZheng ID="PrintRMPingZheng" runat="server" PrintArea="ptnPingZheng2" />
            <asp:BulletedList ID="bulMsgShow" runat="server">
            </asp:BulletedList>

            <script runat="server">public override void ErrorMsgShow() { ErrorMsgHelper(bulMsgShow); }</script>

            <div class="con">
                <div class="card">
                    卡片信息</div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text20">
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
                        <%--<asp:HiddenField ID="hidCardcostFee" runat=server />
    <asp:HiddenField ID="hidDepositFee" runat=server />--%>
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
                                <div align="right" style="display: none;">
                                    结束日期:</div>
                            </td>
                            <td>
                                <asp:TextBox ID="eDate" CssClass="labeltext" Visible="False" runat="server" Text=""></asp:TextBox>
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
                            <asp:HiddenField ID="hidFlagcost" runat="server" />
                            <asp:HiddenField runat="server" ID="hidCardnoForCheck" />
                            <asp:HiddenField ID="hidSaletype" runat="server" />
                            <asp:HiddenField ID="hidIsJiMing" runat="server" />
                            <td colspan="2">
                                &nbsp;
                            </td>
                            <td width="12%">
                                <asp:Button ID="btnbadCard" CssClass="button1" runat="server" Text="坏卡登记" OnClick="btnbadCard_Click"
                                    Visible="false" />
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
                                <asp:Button ID="txtReadPaper" Text="读二代证" CssClass="button1" runat="server" OnClientClick="readIDCardEx('txtCusname', 'selCustsex', 'txtCustbirth', 'selPapertype', 'txtCustpaperno', 'txtCustaddr')" />
                            </td>
                        </tr>
                    </table>
                </div>
            </div>
            <div class="basicinfo">
                <div class="money">
                    售卡费用信息</div>
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
                                    卡费
                                </td>
                                <asp:HiddenField ID="hiddenCardcostFee" runat="server" />
                                <td>
                                    <asp:Label ID="CardcostFee" runat="server" Text=""></asp:Label>
                                </td>
                                <%--<td><asp:TextBox ID="CardcostFee" Width="90px" style="TEXT-ALIGN:center" runat="server" AutoPostBack=true OnTextChanged="CardcostFee_Change" MaxLength=9 CssClass="textboxmoney"></asp:TextBox></td>--%>
                            </tr>
                            <tr>
                                <td>
                                    其他费用
                                </td>
                                <td>
                                    <asp:Label ID="OtherFee" runat="server" Text=""></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <tr class="tabjg">
                                    <td>
                                        合计应收
                                    </td>
                                    <td>
                                        <asp:Label ID="Total" runat="server" Text=""></asp:Label>
                                    </td>
                                </tr>
                        </table>
                    </div>
                </div>
            </div>
            <div class="pipinfo">
                <div class="info">
                    收款信息</div>
                <div class="kuang5">
                    <div class="bigkuang" style="height: 104px">
                        <div class="left">
                            <img src="../../Images/show-sale.JPG" width="164" height="96" /></div>
                        <div class="big2">
                            <table width="280" border="0" cellpadding="0" cellspacing="0" class="text25">
                                <tr>
                                    <td>
                                        <asp:CheckBox ID="Signtype" runat="server" />记名卡
                                    </td>
                                    <td>
                                        <asp:Label ID="DepType" runat="server" ForeColor="Red" Font-Bold="true" Text=""></asp:Label>
                                    </td>
                                    <td colspan="2">
                                        <asp:CheckBox ID="Costacp" runat="server" Visible="false" Text="不收取卡费" AutoPostBack="true"
                                            OnCheckedChanged="Costacp_CheckedChanged" />
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        本次实收:
                                    </td>
                                    <td colspan="3">
                                        <asp:TextBox ID="txtRealRecv" CssClass="inputshort" MaxLength="7" runat="server" Enabled="false"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td width="83">
                                        本次应找:
                                    </td>
                                    <td width="84">
                                        <div id="test">
                                            0.00</div>
                                    </td>
                                    <td colspan="2">
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        &nbsp;
                                    </td>
                                    <td>
                                        <asp:Button ID="btnPrintSKPZ" runat="server" Text="打印凭证" CssClass="button1" Enabled="false"
                                            OnClientClick="return choosePintPingZheng();" />
                                    </td>
                                    <td width="23">
                                        &nbsp;
                                    </td>
                                    <td width="90">
                                        <asp:Button ID="btnSale" CssClass="button1" runat="server" Text="售卡" Enabled="false"
                                            OnClick="btnSale_Click" />
                                        <asp:HiddenField ID="hidTradeIDZJG" runat="server" />
                                        <asp:HiddenField ID="hidCardIDZJG" runat="server" />
                                    </td>
                                </tr>
                            </table>
                        </div>
                        <div class="big2">
                            <table width="280" border="0" cellpadding="0" cellspacing="0" class="text25">
                                <tr>
                                    <td>
                                    </td>
                                    <td>
                                    </td>
                                    <td colspan="2">
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        取件码:
                                    </td>
                                    <td colspan="3">
                                        <asp:TextBox ID="txtFetchCode" CssClass="inputmid" MaxLength="14" runat="server"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td width="83">
                                        &nbsp;
                                    </td>
                                    <td width="84">
                                        <div id="test1">
                                            </div>
                                    </td>
                                    <td colspan="2">
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        &nbsp;
                                    </td>
                                    <td>
                                    </td>
                                    <td width="23">
                                        &nbsp;
                                    </td>
                                    <td width="90">
                                        &nbsp;
                                    </td>
                                </tr>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
            <div class="btns">
                <asp:CheckBox ID="chkPingzheng" runat="server" Text="针式打印凭证" OnClick="return chkPingZheng();"/>
                <asp:CheckBox ID="chkPingzhengRemin" runat="server"  Text="热敏打印凭证"  OnClick="return chkPingZhengRemin();"/>
            </div>
            
        </contenttemplate>
    </asp:UpdatePanel>
    </form>
</body>
</html>
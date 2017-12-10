<%@ Page Language="C#" AutoEventWireup="true" CodeFile="AS_SPTravelCardSale.aspx.cs"
    Inherits="ASP_AddtionalService_AS_SPTravelCardSale" %>

<%@ Register Src="../../CardReader.ascx" TagName="CardReader" TagPrefix="cr" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>世乒旅游-售卡</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <script type="text/javascript" src="../../js/print.js"></script>
    <script type="text/javascript" language="javascript">
        //金额选择
        function setGeneral() {
            var functionFee = 0;
            if ($get('chbGeneral').checked)
                functionFee = parseFloat($get('hiddenLineMoney').value);
            if ($get('chbXXGeneral').checked)
                functionFee = parseFloat(functionFee) + parseFloat($get('hiddenXXLineMoney').value);

            $get('FunctionFee').innerHTML = (functionFee).toFixed(2);
            $get('hidAccRecv').value = (parseFloat($get('CardcostFee').innerHTML) + parseFloat(functionFee)).toFixed(2);
            $get('txtRealRecv').value = parseFloat($get('CardcostFee').innerHTML) + parseFloat(functionFee);

            $get('txtChanges').innerHTML = (parseFloat($get('txtRealRecv').value) - parseFloat($get('FunctionFee').innerHTML) - parseFloat($get('CardcostFee').innerHTML)).toFixed(2);
            $get('TotalFee').innerHTML = (parseFloat($get('CardcostFee').innerHTML) + parseFloat(functionFee)).toFixed(2);
        }

    </script>
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <cr:CardReader ID="cardReader" runat="server" />
    <form id="form1" runat="server">
    <div class="tb">
        附加业务->世乒旅游-售卡
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
                            <asp:HiddenField ID="hidSupplyMoney" runat="server" />
                            <asp:HiddenField ID="hiddentradeno" runat="server" />
                            <asp:HiddenField ID="hiddenLineMoney" runat="server" />
                            <asp:HiddenField ID="hiddenXXLineMoney" runat="server" />
                            <asp:HiddenField runat="server" ID="hidCardReaderToken" />
                            <asp:LinkButton runat="server" ID="btnConfirm" OnClick="btnConfirm_Click" />
                            <asp:HiddenField runat="server" ID="hidCardnoForCheck" />
                            <asp:HiddenField ID="hidIsJiMing" runat="server" />
                            <asp:HiddenField ID="hiddenShiPingTag" runat="server" />
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
                                卡费
                            </td>
                            <asp:HiddenField ID="hiddenCardcostFee" runat="server" />
                            <td>
                                <asp:Label ID="CardcostFee" runat="server" Text=""></asp:Label>
                            </td>
                        </tr>
                        <tr class="tabjg">
                            <td>
                                功能费
                            </td>
                            <asp:HiddenField ID="hiddenFunctionFee" runat="server" />
                            <td>
                                <asp:Label ID="FunctionFee" runat="server" Text=""></asp:Label>
                            </td>
                        </tr>
                        <tr class="tabjg">
                            <td>
                            </td>
                            <td>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                &nbsp;
                            </td>
                            <td>
                                &nbsp;
                            </td>
                        </tr>
                        <tr class="tabjg">
                            <td>
                                &nbsp;
                            </td>
                            <td>
                                &nbsp;
                            </td>
                        </tr>
                        <tr>
                            <td>
                                &nbsp;
                            </td>
                            <td>
                                &nbsp;
                            </td>
                        </tr>
                        <tr class="tabjg">
                            <td>
                                合计应收
                            </td>
                            <td>
                                <asp:Label ID="TotalFee" runat="server" Text=""></asp:Label>
                            </td>
                    </table>
                </div>
            </div>
            <div class="pipinfo">
                <div class="info">
                    售卡信息</div>
                <div class="kuang5">
                    <div class="bigkuang">
                        <div class="left">
                            <img src="../../Images/show.JPG" id="Pic" /></div>
                        <div class="big" style="height: 175px">
                            <table width="200" border="0" cellspacing="0" cellpadding="0" id="SupplyTable">
                                <tr>
                                    <td colspan="2">
                                        &nbsp;
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="2">
                                        <label>
                                        </label>
                                    </td>
                                </tr>
                                <tr>
                                    <td width="50%" align="right">
                                        <label>
                                            本次实收:&nbsp;</label>
                                    </td>
                                    <td width="50%">
                                        <asp:TextBox ID="txtRealRecv" CssClass="inputshort" runat="server" MaxLength="9" />
                                    </td>
                                </tr>
                                <script type="text/javascript">
                                    function setChargeValue(chargeVal) {
                                        $get('hidAccRecv').value = chargeVal;
                                        changannualMoney($get('hidAccRecv'));
                                        realRecvChanging($get(''));
                                        return false;
                                    }
                                </script>
                                <tr>
                                    <td width="50%" align="center">
                                        <asp:CheckBox ID="chbGeneral" runat="server" GroupName="radio" Text="东线A" OnClick="return setGeneral();" />
                                    </td>
                                    <td width="50%">
                                        <asp:CheckBox ID="chbXXGeneral" runat="server" GroupName="radio" Text="西线B" OnClick="return setGeneral();" />
                                    </td>
                                </tr>
                                <tr>
                                    <td align="right">
                                        本次应找:&nbsp;
                                    </td>
                                    <td>
                                        <div id="txtChanges" runat="server">
                                            0.00</div>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="2" class="red">
                                        &nbsp;
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="2" class="red">
                                        &nbsp;
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
                            <asp:Button ID="btnSale" CssClass="button1" runat="server" Text="售卡" Enabled="false"
                               OnClick="btnSale_Click" />
                        </td>
                    </tr>
                </table>
                <asp:CheckBox ID="chkPingzheng" runat="server" Checked="true" Text="自动打印凭证" />
            </div>
            <div class="btns">
                <asp:Label ID="Label2" ForeColor="red" Font-Size="10" runat="server" Text="东线A：山塘街（品茶、游船、评弹）+品真茶楼（苏式点心套餐）+ 寒山寺+枫桥;"></asp:Label>
                <br />

                <br />
                <asp:Label ID="Label1" ForeColor="red" Font-Size="10" runat="server" Text="西线B：平江路+耦园+清语堂茶社（评弹、昆曲、小吃）+ 盘门+夜游护城河;"></asp:Label>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
    </form>
    <script type="text/javascript">
        $get('btnReadCard').focus();
    </script>
</body>
</html>

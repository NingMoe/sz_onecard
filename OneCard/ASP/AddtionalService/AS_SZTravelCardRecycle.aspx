<%@ Page Language="C#" AutoEventWireup="true" CodeFile="AS_SZTravelCardRecycle.aspx.cs"
    Inherits="ASP_AddtionalService_AS_SZTravelCardRecycle" %>

<%@ Register Src="../../CardReader.ascx" TagName="CardReader" TagPrefix="cr" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>旅游卡-回收</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />

    <script type="text/javascript" src="../../js/print.js"></script>

    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <cr:CardReader ID="cardReader" runat="server" />
    <form id="form1" runat="server">
    <div class="tb">
        附加业务->旅游卡-回收
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
                    <asp:HiddenField ID="hiddenread" runat="server" />
                    <asp:HiddenField ID="hiddentxtCardno" runat="server" />
                    <asp:HiddenField ID="hiddenAsn" runat="server" />
                    <asp:HiddenField ID="hiddenLabCardtype" runat="server" />
                    <asp:HiddenField ID="hiddensDate" runat="server" />
                    <asp:HiddenField ID="hiddeneDate" runat="server" />
                    <asp:HiddenField ID="hiddencMoney" runat="server" />
                     <asp:HiddenField ID="hidUnSupplyMoney" runat="server" />
                    <asp:HiddenField ID="hiddentradeno" runat="server" />
                    <asp:HiddenField ID="hidWarning" runat="server" />
                    <asp:LinkButton runat="server" ID="btnConfirm" OnClick="btnConfirm_Click" />
                    <asp:HiddenField ID="hiddenverify" runat="server" />
                    <asp:HiddenField ID="hiddenCheck" runat="server" />
                    <asp:HiddenField ID="hidCancelDepositFee" runat="server" />
                    <asp:HiddenField ID="hidCancelSupplyFee" runat="server" />
                    <asp:HiddenField ID="hidSERSTAKETAG" runat="server" />
                    <asp:HiddenField ID="hidDEPOSIT" runat="server" />
                    <asp:HiddenField ID="hidService" runat="server" />
                    <asp:HiddenField ID="hidoutTradeid" runat="server" />
                    <table width="98%" border="0" cellpadding="0" cellspacing="0" class="text20">
                        <tr>
                            <td width="10%">
                                <div align="right">
                                    用户卡号:</div>
                            </td>
                            <td width="13%">
                                <asp:TextBox ID="txtCardno" CssClass="labeltext" MaxLength="16" runat="server"></asp:TextBox>
                            </td>
                            <td width="10%">
                                <div align="right">
                                    卡序列号:</div>
                            </td>
                            <td width="13%">
                                <asp:TextBox ID="LabAsn" ReadOnly="true" CssClass="labeltext" runat="server"></asp:TextBox>
                            </td>
                            <td width="10%">
                                <div align="right">
                                    退卡类型:</div>
                            </td>
                            <td width="12%">
                                <asp:DropDownList ID="selReasonType" AutoPostBack="true" OnSelectedIndexChanged="selReasonType_SelectedIndexChanged"
                                    runat="server">
                                </asp:DropDownList>
                            </td>
                            <td width="13%">
                                <div align="right">
                                    <asp:Button ID="btnReadCard" CssClass="button1" runat="server" Text="读卡" OnClientClick="return ReadCardInfo()"
                                        OnClick="btnReadCard_Click" /></div>
                            </td>
                            <td width="10%">
                                &nbsp;
                            </td>
                        </tr>
                        <tr>
                            <td width="10%">
                                <div align="right">
                                    启用日期:</div>
                            </td>
                            <td width="13%">
                                <asp:TextBox ID="sDate" CssClass="labeltext" ReadOnly="true" runat="server" Text=""></asp:TextBox>
                            </td>
                            <td width="10%">
                                <div align="right">
                                    结束日期:</div>
                            </td>
                            <td width="13%">
                                <asp:TextBox ID="eDate" CssClass="labeltext" ReadOnly="true" runat="server" Text=""></asp:TextBox>
                            </td>
                            <td width="10%">
                                <div align="right">
                                    余额:</div>
                            </td>
                            <td width="12%">
                                <asp:TextBox ID="cMoney" CssClass="labeltext" ReadOnly="true" runat="server" Text=""></asp:TextBox>
                            </td>
                            <td width="13%">
                            </td>
                            <td width="10%">
                                &nbsp;
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    售卡时间:</div>
                            </td>
                            <td>
                                <asp:TextBox ID="sellTime" CssClass="labeltext" Width="100" runat="server" Text=""></asp:TextBox>
                            </td>
                            <td>
                                <div align="right">
                                    卡片状态:</div>
                            </td>
                            <td>
                                <asp:TextBox ID="RESSTATE" CssClass="labeltext" runat="server"></asp:TextBox>
                            </td>
                            <td>
                                <div align="right">
                                    押金:</div>
                            </td>
                            <td>
                                <asp:TextBox ID="txtDeposit" CssClass="labeltext" runat="server"></asp:TextBox>
                            </td>
                            <td>
                                <div align="right">
                                    <asp:Button ID="btnDBRead" CssClass="button1" Enabled="false" runat="server" Text="读数据库"
                                        OnClientClick="return warnCheck()" /></div>
                            </td>
                            <td>
                                &nbsp;
                            </td>
                        </tr>
                    </table>
                </div>
                <div class="pip" runat="server" id="divRFTitle" visible="false">
                    退款信息
                </div>
                <div class="kuang5" id="divRFInfo" runat="server" visible="false">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25" runat="server">
                        <tr>
                            <td width="10%">
                                <div align="right">
                                    用户姓名:</div>
                            </td>
                            <td width="15%">
                                <asp:TextBox ID="txtCusname" CssClass="input" MaxLength="25" runat="server"></asp:TextBox>
                                <span class="red">*</span>
                            </td>
                            <td width="10%">
                                <div align="right">
                                    证件类型:</div>
                            </td>
                            <td width="15%">
                                <asp:DropDownList ID="selPapertype" CssClass="input" runat="server">
                                </asp:DropDownList>
                            </td>
                            <td width="10%">
                                <div align="right">
                                    证件号码:</div>
                            </td>
                            <td width="15%">
                                <asp:TextBox ID="txtCustpaperno" CssClass="input" MaxLength="20" runat="server"></asp:TextBox>
                            </td>
                            <td width="10%">
                                <div align="right">
                                    联系电话:</div>
                            </td>
                            <td width="15%">
                                <asp:TextBox ID="txtCustphone" CssClass="input" MaxLength="20" runat="server"></asp:TextBox>
                                <span class="red">*</span>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                开户银行:
                            </td>
                            <td>
                                <asp:TextBox ID="txtBankname" CssClass="input" MaxLength="30" runat="server"></asp:TextBox>
                                <span class="red">*</span>
                            </td>
                            <td>
                                <div align="right">
                                分支行:
                            </td>
                            <td>
                                <asp:TextBox ID="txtBanknamesub" CssClass="input" MaxLength="30" runat="server"></asp:TextBox>
                            </td>
                            <td>
                                <div align="right">
                                银行账号:
                            </td>
                            <td colspan="3">
                                <asp:TextBox ID="txtBankAccno" CssClass="inputlong" MaxLength="30" runat="server"></asp:TextBox>
                                <span class="red">*</span>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    账户类型:</div>
                            </td>
                            <td>
                                <asp:DropDownList ID="selPurPoseType" runat="server">
                                </asp:DropDownList>
                                <span class="red">*</span>
                            </td>
                            <td valign="top">
                                <div align="right">
                                    备注 :</div>
                            </td>
                            <td colspan="3">
                                <asp:TextBox ID="txtRemark" CssClass="inputlong" MaxLength="50" runat="server"></asp:TextBox>
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
                                退押金
                            </td>
                            <td>
                                <asp:Label ID="CancelDepositFee" runat="server" Text=""></asp:Label>
                            </td>
                        </tr>
                        <tr class="tabjg">
                            <td>
                                退充值
                            </td>
                            <td>
                                <asp:Label ID="CancelSupplyFee" runat="server" Text=""></asp:Label>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                手续费
                            </td>
                            <td>
                                <asp:Label ID="ProcedureFee" runat="server" Text=""></asp:Label>
                            </td>
                        </tr>
                        <tr class="tabjg">
                            <td>
                                合计应收(退)
                            </td>
                            <td>
                                <asp:Label ID="Total" runat="server" Text=""></asp:Label>
                            </td>
                        </tr>
                    </table>
                </div>
            </div>
            <div class="pipinfo">
                <div class="info">
                    退卡信息</div>
                <div class="kuang5">
                    <div class="bigkuang2">
                        <div class="left" style="height: 104px">
                            <img src="../../Images/show-re.JPG" width="164" height="96" /></div>
                        <div class="big2" style="height: 100px">
                            <table width="200" border="0" cellspacing="0" cellpadding="0">
                                <tr>
                                    <td width="160" colspan="2">
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
                                    <td colspan="2" class="red">
                                        <div align="center">
                                            应收/退客户的金额</div>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="2">
                                        <div align="center">
                                            <asp:Label ID="ReturnSupply" runat="server" Text=""></asp:Label>
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="2">
                                        &nbsp;
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="2">
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
                            <asp:Button ID="btnReturnCard" CssClass="button1" runat="server" Text="回收" Enabled="false"
                                OnClick="btnReturnCard_Click" />
                        </td>
                    </tr>
                </table>
                <td>
                    <asp:CheckBox ID="chkPingzheng" runat="server" Checked="true" />自动打印凭证
                </td>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
    </form>
</body>
</html>

<%@ Page Language="C#" AutoEventWireup="true" CodeFile="AS_MonthlyCardOPEN.aspx.cs"
    Inherits="ASP_AddtionalService_AS_MonthlyCardOPEN" %>

<%@ Register Src="../../CardReader.ascx" TagName="CardReader" TagPrefix="cr" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>月票卡开通</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <script type="text/javascript" src="../../js/print.js"></script>
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <cr:CardReader ID="cardReader" runat="server" />
    <form id="form1" runat="server">
    <asp:Label runat="server" ID="labTitle" Visible="false" />
    <div class="tb">
        附加业务-><asp:Label runat="server" ID="labSubTitle"></asp:Label>
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
            <aspControls:PrintPingZheng ID="ptnPingZheng" runat="server" PrintArea="ptnPingZheng1" />
            <asp:BulletedList ID="bulMsgShow" runat="server">
            </asp:BulletedList>
            <script runat="server">public override void ErrorMsgShow() { ErrorMsgHelper(bulMsgShow); }</script>
            <div class="con">
                <div class="card">
                    [月票卡]卡片信息</div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text20">
                        <tr>
                            <td width="10%">
                                <div align="right">
                                    用户卡号:</div>
                            </td>
                            <td width="13%">
                                <asp:TextBox ID="txtCardNo" CssClass="labeltext" runat="server" />
                            </td>
                            <td width="9%">
                                <div align="right">
                                    卡片类型:</div>
                            </td>
                            <td width="13%">
                                <asp:Label ID="labCardType" CssClass="labeltext" runat="server" />
                            </td>
                            <td width="9%">
                                <div align="right">
                                    卡内余额:</div>
                            </td>
                            <td width="13%">
                                <asp:TextBox ID="txtCardBalance" CssClass="labeltext" runat="server" />
                            </td>
                            <td width="9%">
                                &nbsp;
                            </td>
                            <td width="24%">
                                <asp:Button ID="btnReadCard" Text="读卡" CssClass="button1" runat="server" OnClientClick="return ReadYearCardInfo()"
                                    OnClick="btnReadCard_Click" />
                            </td>
                            <asp:HiddenField runat="server" ID="hidReissue" />
                            <asp:HiddenField runat="server" ID="hidWarning" />
                            <asp:HiddenField runat="server" ID="hidTradeNo" />
                            <asp:HiddenField runat="server" ID="hidAccRecv" />
                            <asp:HiddenField runat="server" ID="hidTradeTypeCode" />
                            <asp:HiddenField runat="server" ID="hidOtherFee" Value="0" />
                            <asp:HiddenField runat="server" ID="hidCardPost" Value="0" />
                            <asp:HiddenField runat="server" ID="hidDeposit" Value="0" />
                            <asp:HiddenField runat="server" ID="hidMonthlyFlag" />
                            <asp:HiddenField runat="server" ID="hidPriType" />
                            <asp:HiddenField runat="server" ID="hidCardReaderToken" />
                            <asp:HiddenField runat="server" ID="hidCardReaderToken1" />
                            <asp:HiddenField runat="server" ID="hidAsn" />
                            <asp:HiddenField runat="server" ID="hidForPaperNo" />
                            <asp:HiddenField runat="server" ID="hidForPhone" />
                            <asp:HiddenField runat="server" ID="hidForAddr" />
                            <asp:HiddenField runat="server" ID="hiddenCheck" />
                            
                            <asp:HiddenField runat="server" ID="HidYPFlag" />
                            <asp:HiddenField runat="server" ID="HidPrivilege"/>
                            <asp:HiddenField runat="server" ID="HidAppRange" />
                            <asp:HiddenField runat="server" ID="HidYearInfo" />
                            <asp:HiddenField runat="server" ID="HidPriIndex1" />
                            <asp:HiddenField runat="server" ID="HidPriIndex2" />
                            <asp:HiddenField runat="server" ID="HidPriIndex3" />
                            <asp:HiddenField runat="server" ID="HidPriIndex4" />
                            <asp:HiddenField runat="server" ID="HidPriIndex5" />
                            <asp:HiddenField runat="server" ID="HidPriIndex6" />
                            <asp:HiddenField runat="server" ID="HidCRCCheck" />

                            <asp:HiddenField ID="hidLockBlackCardFlag" runat="server" />
                            <asp:LinkButton runat="server" ID="btnConfirm" OnClick="btnConfirm_Click" /></tr>
                        <tr>
                            <td>
                                <div align="right">
                                    启用日期:</div>
                            </td>
                            <td>
                                <asp:TextBox ID="txtStartDate" CssClass="labeltext" runat="server" />
                            </td>
                            <td>
                                <div align="right">
                                    结束日期:</div>
                            </td>
                            <td>
                                <asp:TextBox ID="txtEndDate" CssClass="labeltext" runat="server" />
                            </td>
                            <td>
                                <div align="right">
                                    卡片状态:</div>
                            </td>
                            <td>
                                <asp:TextBox ID="txtCardState" CssClass="labeltext" runat="server" />
                            </td>
                            <td>
                                &nbsp;
                            </td>
                            <td>
                                &nbsp;
                            </td>
                        </tr>
                    </table>
                </div>
                <div class="pip">
                    [月票卡]用户信息</div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td width="10%">
                                <div align="right">
                                    月票类型:</div>
                            </td>
                            <td width="13%">
                                <asp:DropDownList AutoPostBack="true" ID="selMonthlyCardType" CssClass="input" runat="server"
                                    OnSelectedIndexChanged="selMonthlyCardType_SelectedIndexChanged" />
                                <span class="red">*</span>
                            </td>
                            <td width="9%">
                                <div align="right">
                                    行政区划:</div>
                            </td>
                            <td colspan="5">
                                <asp:DropDownList ID="selMonthlyCardDistrict" CssClass="inputlong" runat="server" />
                                <span class="red">*</span>
                            </td>
                        </tr>
                        <tr>
                            <td width="10%">
                                <div align="right">
                                    用户姓名:</div>
                            </td>
                            <td width="13%">
                                <asp:TextBox ID="txtCustName" runat="server" CssClass="input" MaxLength="50" />
                            </td>
                            <td width="9%">
                                <div align="right">
                                    出生日期:</div>
                            </td>
                            <td width="13%">
                                <asp:TextBox ID="txtCustBirth" runat="server" CssClass="input" MaxLength="8" />
                                <ajaxToolkit:CalendarExtender ID="FCalendar" runat="server" Format="yyyyMMdd" TargetControlID="txtCustBirth" />
                            </td>
                            <td width="9%">
                                <div align="right">
                                    证件类型:</div>
                            </td>
                            <td width="13%">
                                <asp:DropDownList ID="selPaperType" runat="server" CssClass="input">
                                </asp:DropDownList>
                            </td>
                            <td width="9%">
                                <div align="right">
                                    证件号码:</div>
                            </td>
                            <td width="24%">
                                <asp:TextBox ID="txtPaperNo" runat="server" CssClass="inputmid" MaxLength="20" />
                            </td>
                        <tr>
                            <td>
                                <div align="right">
                                    用户性别:</div>
                            </td>
                            <td>
                                <asp:DropDownList ID="selCustSex" runat="server" CssClass="input">
                                </asp:DropDownList>
                                <span class="red">*</span> </td>
                            <td>
                                <div align="right">
                                    联系电话:</div>
                            </td>
                            <td>
                                <asp:TextBox ID="txtCustPhone" runat="server" CssClass="input" MaxLength="20" />
                            </td>
                            <td>
                                <div align="right">
                                    邮政编码:</div>
                            </td>
                            <td>
                                <asp:TextBox ID="txtCustPost" runat="server" CssClass="input" MaxLength="6" />
                            </td>
                            <td>
                                <div align="right">
                                    联系地址:</div>
                            </td>
                            <td>
                                <asp:TextBox ID="txtCustAddr" runat="server" CssClass="inputmid" MaxLength="50" />
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    电子邮件:</div>
                            </td>
                            <td>
                                <asp:TextBox ID="txtEmail" runat="server" CssClass="input" MaxLength="30" />
                            </td>
                            <td>
                                <div align="right">
                                    备注:</div>
                            </td>
                            <td colspan="4">
                                <asp:TextBox ID="txtRemark" runat="server" CssClass="inputlong" MaxLength="100" />
                            </td>
                            <td>
                                <asp:Button ID="txtReadPaper" runat="server" CssClass="button1" OnClientClick="readIDCard('txtCustName', 'selCustSex', 'txtCustBirth', 'selPaperType', 'txtPaperNo', 'txtCustAddr')" Text="读二代证" />
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
                                OnClientClick="printdiv('ptnPingZheng1')" />
                        </td>
                        <td>
                            <asp:Button ID="btnSubmit" Enabled="false" CssClass="button1" runat="server" Text="提交"
                                OnClick="btnSubmit_Click" />
                        </td>
                    </tr>
                </table>
                <asp:CheckBox ID="chkPingzheng" runat="server" Text="自动打印凭证" Checked="true" />
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
    </form>
</body>
</html>

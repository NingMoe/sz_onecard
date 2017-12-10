<%@ Page Language="C#" AutoEventWireup="true" CodeFile="AS_MonthlyCardClose.aspx.cs"
    Inherits="ASP_AddtionalService_AS_MonthlyCardClose" %>

<%@ Register Src="../../CardReader.ascx" TagName="CardReader" TagPrefix="cr" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>月票卡关闭</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />

    <script type="text/javascript" src="../../js/print.js"></script>

    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <cr:CardReader ID="cardReader" runat="server" />
    <form id="form1" runat="server">
    <asp:Label runat="server" ID="labTitle" Visible="false" />
    <div class="tb">
        附加业务->月票卡关闭</asp:Label>
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
                                <asp:Button ID="btnReadCard" Text="读卡" CssClass="button1" runat="server" OnClientClick="return ReadParkCardInfo()"
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
                            <asp:HiddenField runat="server" ID="hidCardReaderToken" />
                            <asp:HiddenField runat="server" ID="HiddenField1" />
                            <asp:HiddenField runat="server" ID="hidAsn" />
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
                                <asp:Label ID="labMonthlyCardType" CssClass="labeltext" runat="server" />
                                <asp:HiddenField runat="server" ID="hidMonthlyType" />
                            </td>
                            <td width="9%">
                                <div align="right">
                                    行政区划:</div>
                            </td>
                            <td colspan="5">
                                <asp:Label ID="labMonthlyCardDistrict" CssClass="labeltext" runat="server" />
                            </td>
                        </tr>
                        <tr>
                            <tr>
                                <td width="10%">
                                    <div align="right">
                                        用户姓名:</div>
                                </td>
                                <td width="13%">
                                    <asp:Label ID="labCustName" CssClass="labeltext" runat="server" />
                                </td>
                                <td width="9%">
                                    <div align="right">
                                        出生日期:</div>
                                </td>
                                <td width="13%">
                                    <asp:Label ID="labCustBirth" CssClass="labeltext" runat="server" />
                                </td>
                                <td width="9%">
                                    <div align="right">
                                        证件类型:</div>
                                </td>
                                <td width="13%">
                                    <asp:Label ID="labPaperType" CssClass="labeltext" runat="server" />
                                </td>
                                <td width="9%">
                                    <div align="right">
                                        证件号码:</div>
                                </td>
                                <td width="24%">
                                    <asp:Label ID="labPaperNo" CssClass="labeltext" runat="server" />
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <div align="right">
                                        用户性别:</div>
                                </td>
                                <td>
                                    <asp:Label ID="labCustSex" CssClass="labeltext" runat="server" />
                                </td>
                                <td>
                                    <div align="right">
                                        联系电话:</div>
                                </td>
                                <td>
                                    <asp:Label ID="labCustPhone" CssClass="labeltext" runat="server" />
                                </td>
                                <td>
                                    <div align="right">
                                        邮政编码:</div>
                                </td>
                                <td>
                                    <asp:Label ID="labCustPost" CssClass="labeltext" runat="server" />
                                </td>
                                <td>
                                    <div align="right">
                                        联系地址:</div>
                                </td>
                                <td>
                                    <asp:Label ID="labCustAddr" CssClass="labeltext" runat="server" />
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <div align="right">
                                        电子邮件:</div>
                                </td>
                                <td>
                                    <asp:Label ID="labEmail" CssClass="labeltext" runat="server" />
                                </td>
                                <td>
                                    <div align="right">
                                        备&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;注:</div>
                                </td>
                                <td colspan="4">
                                    <asp:Label ID="labRemark" CssClass="labeltext" runat="server" />
                                </td>
                                <td>
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
                <asp:CheckBox ID="chkPingzheng" runat="server"  Text="自动打印凭证"  Checked="true"/>

            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
    </form>
</body>
</html>

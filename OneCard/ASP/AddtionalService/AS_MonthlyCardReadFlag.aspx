<%@ Page Language="C#" AutoEventWireup="true" CodeFile="AS_MonthlyCardReadFlag.aspx.cs"
    Inherits="ASP_AddtionalService_AS_MonthlyCardReadFlag" %>

<%@ Register Src="../../CardReader.ascx" TagName="CardReader" TagPrefix="cr" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>卡内标识读取</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />

    <script type="text/javascript" src="../../js/print.js"></script>

    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <cr:CardReader ID="cardReader" runat="server" />
    <form id="form1" runat="server">
        <div class="tb">
            附加业务->月票卡内标识读取
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
                        卡片信息
                    </div>
                    <div class="kuang5">
                        <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text20">
                            <tr>
                                <td width="10%">
                                    <div align="right">
                                        用户卡号:
                                    </div>
                                </td>
                                <td width="13%">
                                    <asp:TextBox ID="txtCardNo" CssClass="labeltext" ReadOnly="true" runat="server" />
                                </td>
                                    <asp:HiddenField runat="server" ID="hidCardReaderToken1" />
                                <td width="9%"></td>
                                <td width="13%"></td>
                                <td width="9%"></td>
                                <td width="13%"></td>
                                <td width="9%">&nbsp;
                                </td>
                                <td width="24%">
                                    <asp:Button ID="btnReadCard" Text="读卡" CssClass="button1" runat="server" OnClick="btnReadCard_Click" />
                                    <asp:LinkButton runat="server" ID="btnGetToken" OnClick="btnGetToken_Click" />
                                </td>
                            </tr>
                        </table>
                    </div>
                    <div class="kuang5">
                        <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text20">
                            <tr>
                                <td width="10%">
                                    <div align="right">
                                        公交月票标识:
                                    </div>
                                </td>
                                <td colspan="5">
                                    <asp:TextBox ID="txtYPFlag" CssClass="labeltext" ReadOnly="true" runat="server" Width="500px" />
                                </td>
                                <td width="24%"></td>
                            </tr>
                            <tr>
                                <td width="10%">
                                    <div align="right">
                                        轻轨月票标识:
                                    </div>
                                </td>
                                <td colspan="5">
                                    <asp:TextBox ID="txtYPFlagEx" CssClass="labeltext" ReadOnly="true" runat="server" Width="500px" />
                                </td>
                                <td width="24%"></td>
                            </tr>
                            <tr>
                                <td width="10%">
                                    <div align="right">
                                        年审信息标识:
                                    </div>
                                </td>
                                <td colspan="5">
                                    <asp:TextBox ID="txtYearInfo" CssClass="labeltext" ReadOnly="true" runat="server" Width="500px" />
                                </td>
                                <td width="24%"></td>
                            </tr>
                            <tr>
                                <td width="10%">
                                    <div align="right">
                                        月票充值信息:
                                    </div>
                                </td>
                                <td colspan="5">
                                    <asp:TextBox ID="txtYPCharge" CssClass="labeltext" ReadOnly="true" runat="server" Width="500px" />
                                </td>
                                <td width="24%"></td>
                            </tr>
                            <tr>
                                <td width="10%">
                                    <div align="right">
                                        月票所有标识码:
                                    </div>
                                </td>
                                <td colspan="5">
                                    <asp:TextBox ID="txtYPChargeCode" CssClass="labeltext" ReadOnly="true" runat="server" Width="500px" />
                                </td>
                                <td width="24%"></td>
                            </tr>
                        </table>
                    </div>
                    <div class="kuang5">
                        <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                            <tr>
                                <td align="left">
                                    <font face="webdings">= </font>苏州通月票卡（原有的双界面卡开通月票功能的卡片,卡号一般以215002、或215006开头的卡片）
                                </td>
                            </tr>
                            <tr>

                                <td align="left">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                “公交月票标识”所对应的值， 代表可以在<font color="red"> 公交和轻轨</font>享受月票优惠政策；
                                </td>
                            </tr>
                            <tr>
                                <td align="left">
                                    <font face="webdings">= </font>市民卡月票卡（市民卡A卡、市民卡B卡、以及纯非接触式苏州通卡）
                                </td>
                            </tr>
                            <tr>

                                <td align="left">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                 “公交月票标识”所对应的值， 代表可以在<font color="red"> 公交</font>享受月票优惠政策；
                                </td>
                            </tr>
                            <tr>

                                <td align="left">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                 “轻轨月票标识”所对应的值， 代表可以在<font color="red"> 轻轨</font>享受月票优惠政策；
                                </td>
                            </tr>
                            <tr>
                                <td align="left">
                                    <font face="webdings">= </font>“公交月票标识”，“轻轨月票标识”读取的内容的相关说明：
                                </td>
                            </tr>
                            <tr>
                                <td align="left">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                 01/02/FF 或其他值 代表卡片 未开通月票功能；
                                </td>
                            </tr>
                            <tr>
                                <td align="left">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                 C4/C5/C6/C7/C8/C9/CA/CB/CC/CD/CE 代表卡片为 学生卡；
                                </td>
                            </tr>
                            <tr>
                                <td align="left">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                 D4/D5/D6/D7/D8/D9/DA/DB/DC/DD/DE 代表卡片为 老人卡；
                                </td>
                            </tr>
                            <tr>
                                <td align="left">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                 E4/E5/E6/E7/E8/E9/EA/EB/EC/ED/EE  代表卡片为 高龄卡；
                                </td>
                            </tr>
                            <tr>
                                <td align="left">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                  B4/B5/B6/B7/B8/B9/BA/BB/BC/BD/BE  代表卡片为 爱心卡；
                                </td>
                            </tr>
                            <tr>
                                <td align="left">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                  A6  代表卡片为 劳模卡；
                                </td>

                                <tr>
                                    <td align="left">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                  F4/F5/F6/F7/F8/F9/FA/FB/FC/FD/FE  代表卡片为 教育卡；
                                    </td>
                                </tr>
                            </tr>
                            <tr>
                                <td align="left">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                  A7  代表卡片为 献血卡；
                                </td>
                            </tr>
                        </table>
                    </div>
            </ContentTemplate>
        </asp:UpdatePanel>
    </form>
</body>
</html>

<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PB_CardToCardOutRetrade.aspx.cs" Inherits="ASP_PersonalBusiness_PB_CardToCardOutRetrade" %>

<%@ Register Src="../../CardReader.ascx" TagName="CardReader" TagPrefix="cr" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>卡卡转账圈提补写</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="../../js/print.js"></script>
    <script type="text/javascript" language="javascript">
        function UnloadCheck() {
            var ret = ReadCardInfoForCheck();
            if (!ret) {
                return false;
            }

            if (cardReader.CardInfo.cardNo != $get('txtCardno').value) {
                MyExtAlert("警告", "读卡器上卡片为:<br>"
            + '<span class="red">' + cardReader.CardInfo.cardNo + '</span>'
            + "<br>先前读出卡号为: <br>"
            + '<span class="red">' + $get('txtCardno').value + '</span>'
            + "<br>不一致。<br><br> 请重新点击读卡按钮后再圈提！");
                return false;
            }

            MyExtConfirm('提示', '确认是否圈提' + document.getElementById("txtDealMoney").innerHTML + '元', RecoverCheckConfirm);
            return false;
        }
        function readThisIDCard() {
            debugger;
            readIDCardEx("hidname", "hidpapernoId");
            $get("txtReMark").value = $get("hidname").value + "," + $get("hidpapernoId").value;
            return false;
        }
    </script>
</head>
<body>
    <cr:CardReader ID="cardReader" runat="server" />
    <form id="form1" runat="server">
    <div class="tb">
        个人业务->卡卡转账圈提补写
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
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text20">
                        <tr>
                            <td width="12%">
                                <div align="right">
                                    用户卡号:</div>
                            </td>
                            <td width="12%">
                                <asp:TextBox ID="txtCardno" CssClass="labeltext" MaxLength="16" runat="server"></asp:TextBox>
                            </td>
                            <td width="12%">
                                <div align="right">
                                    卡内余额:</div>
                            </td>
                            <td width="12%">
                                <asp:TextBox ID="cMoney" CssClass="labeltext" runat="server" Text=""></asp:TextBox>
                            </td>
                            <td width="12%">
                                <div align="right">
                                    卡片状态:</div>
                            </td>
                            <td width="12%">
                                <asp:TextBox ID="RESSTATE" CssClass="labeltext" ReadOnly="true" runat="server"></asp:TextBox>
                            </td>
                            <td width="12%" align="right">
                                <asp:Button ID="btnReadCard" CssClass="button1" runat="server" Text="读卡" OnClientClick="return ReadCardInfo()"
                                    OnClick="btnReadCard_Click" />
                            </td>
                            <td width="12%">
                                &nbsp;
                            </td>
                        </tr>
                        <asp:HiddenField ID="hiddenread" runat="server" />
                        <asp:HiddenField ID="hiddentxtCardno" runat="server" />
                        <asp:HiddenField ID="hiddenAsn" runat="server" />
                        <asp:HiddenField ID="hiddenLabCardtype" runat="server" />
                        <asp:HiddenField ID="hiddensDate" runat="server" />
                        <asp:HiddenField ID="hiddeneDate" runat="server" />
                        <asp:HiddenField ID="hiddencMoney" runat="server" />
                        <asp:HiddenField ID="hiddentradeno" runat="server" />
                        <asp:HiddenField ID="hiddenState" runat="server" />
                        <asp:HiddenField ID="hidWarning" runat="server" />
                        <asp:HiddenField runat="server" ID="hidSupplyMoney" />
                        <asp:HiddenField runat="server" ID="hiddenSupply" />
                        <asp:HiddenField runat="server" ID="hidTradeid" />
                        <asp:LinkButton runat="server" ID="btnConfirm" OnClick="btnConfirm_Click" />
                        <asp:HiddenField runat="server" ID="hidCardReaderToken" />
                        <asp:HiddenField ID="hidUnSupplyMoney" runat="server" />
                        <asp:HiddenField runat="server" ID="hidCardnoForCheck" />
                        <asp:HiddenField ID="hidname" runat="server" />
                        <asp:HiddenField ID="hidpapernoId" runat="server" />
                         <asp:HiddenField ID="hidisWriteSuccess" runat="server" Value="true" />
                    </table>
                </div>
                <div class="pip" style="display: none">
                    用户信息</div>
                <div class="kuang5" style="display: none">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text20">
                        <tr>
                            <td width="12%">
                                <div align="right">
                                    用户姓名:</div>
                            </td>
                            <td width="12%">
                                <asp:Label ID="CustName" runat="server" Text=""></asp:Label>
                            </td>
                            <td width="12%">
                                <div align="right">
                                    出生日期:</div>
                            </td>
                            <td width="12%">
                                <asp:Label ID="CustBirthday" runat="server" Text=""></asp:Label>
                            </td>
                            <td width="12%">
                                <div align="right">
                                    证件类型:</div>
                            </td>
                            <td width="12%">
                                <asp:Label ID="Papertype" runat="server" Text=""></asp:Label>
                            </td>
                            <td width="12%">
                                <div align="right">
                                    证件号码:</div>
                            </td>
                            <td width="12%">
                                <asp:Label ID="Paperno" runat="server" Text=""></asp:Label>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    用户性别:</div>
                            </td>
                            <td>
                                <asp:Label ID="Custsex" runat="server" Text=""></asp:Label>
                            </td>
                            <td>
                                <div align="right">
                                    联系电话:</div>
                            </td>
                            <td>
                                <asp:Label ID="Custphone" runat="server" Text=""></asp:Label>
                            </td>
                            <td>
                                <div align="right">
                                    邮政编码:</div>
                            </td>
                            <td>
                                <asp:Label ID="Custpost" runat="server" Text=""></asp:Label>
                            </td>
                            <td>
                                <div align="right">
                                    联系地址:</div>
                            </td>
                            <td>
                                <asp:Label ID="Custaddr" runat="server" Text=""></asp:Label>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                电子邮件:
                            </td>
                            <td>
                                <asp:Label ID="txtEmail" runat="server" Text=""></asp:Label>
                            </td>
                            <td valign="top">
                                <div align="right">
                                    备注 :</div>
                            </td>
                            <td colspan="5">
                                <asp:Label ID="Remark" runat="server" Text=""></asp:Label>
                            </td>
                        </tr>
                    </table>
                </div>
                <div class="info">
                    圈提金额</div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text20">
                        <tr>
                            <td style="width: 12%">
                                <div align="right">
                                    圈提金额:</div>
                            </td>
                            <td style="width: 12%">
                                <asp:Label ID="txtDealMoney" runat="server"></asp:Label>
                            </td>
                            <td style="width: 12%">
                                <div align="right">
                                    备注:</div>
                            </td>
                            <td style="width: 48%" colspan="4">
                                <asp:Label ID="txtReMark" runat="server"></asp:Label>
                            </td>
                            <td width="12%">
                                &nbsp;
                            </td>
                        </tr>
                        <tr>
                            <td width="12%">
                            </td>
                            <td width="12%">
                            </td>
                            <td width="12%">
                            </td>
                            <td width="12%">
                            </td>
                            <td width="12%">
                            </td>
                            <td width="12%">
                            </td>
                            <td width="12%">
                            </td>
                            <td width="12%">
                            </td>
                        </tr>
                    </table>
                </div>
                <div class="info">
                    确认提交</div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text20">
                        <tr>
                            <td width="12%">
                            </td>
                            <td width="12%">
                            </td>
                            <td width="12%">
                            </td>
                            <td width="12%">
                            </td>
                            <td width="12%">
                            </td>
                            <td width="12%">
                            </td>
                            <td width="12%">
                            </td>
                            <td width="12%">
                            </td>
                        </tr>
                        <tr>
                            <td align="right">
                                <asp:CheckBox ID="chkPingzheng" runat="server" Checked="false" />自动打印凭证
                            </td>
                            <td colspan="5">
                            </td>
                            <td align="right">
                                <asp:Button ID="btnPrintPZ" runat="server" Text="打印凭证" CssClass="button1" Enabled="false"
                                    OnClientClick="printdiv('ptnPingZheng1')" />
                            </td>
                            <td align="left">
                                &nbsp
                                <asp:Button ID="btnLoad" CssClass="button1" runat="server" Text="补圈提" Enabled="false"
                                    OnClick="btnLoad_Click" />
                            </td>
                        </tr>
                    </table>
                </div>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
    </form>
</body>
</html>


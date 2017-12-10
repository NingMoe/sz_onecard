<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PS_CodeChange.aspx.cs" Inherits="ASP_PartnerShip_PS_CodeChange" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>编码维护</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <script type="text/javascript" src="../../js/myext.js"></script>
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
    <div class="tb">
        合作伙伴->编码维护
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
            <asp:BulletedList ID="bulMsgShow" runat="server">
            </asp:BulletedList>
            <script runat="server">public override void ErrorMsgShow() { ErrorMsgHelper(bulMsgShow); }</script>
            <div class="con">
                <div class="card">
                    地区编码维护</div>
                <div class="kuang5">
                    <table width="97%" border="0" cellpadding="0" cellspacing="0" class="text20">
                        <tr>
                            <td width="5%">
                                <div align="right">
                                    地区:</div>
                            </td>
                            <td width="10%">
                                <asp:DropDownList ID="selRegion" AutoPostBack="true" runat="server" OnSelectedIndexChanged="selRegion_changed">
                                </asp:DropDownList>
                            </td>
                            <td width="5%">
                                <div align="right">
                                    编码:</div>
                            </td>
                            <td width="14%">
                                <asp:TextBox ID="txtRegionCode" style="text-transform:uppercase" runat="server" MaxLength="1" CssClass="input" /><font color="red">*</font>
                            </td>
                            <td width="5%">
                                <div align="right">
                                    名称:</div>
                            </td>
                            <td width="14%">
                                <asp:TextBox ID="txtRegionName" runat="server" MaxLength="40" CssClass="input" /><font color="red">*</font>
                            </td>
                            <td width="6%">
                                <div align="right">
                                    有效标志
                                </div>
                            </td>
                            <td width="12%">
                                <asp:DropDownList ID="selRegionUseTag" runat="server">
                                </asp:DropDownList><font color="red">*</font>
                            </td>
                            <td>
                                <div align="right">
                                    <asp:Button ID="btnRegionAdd" CssClass="button1" Text="新增" runat="server" OnClick="btnRegionAdd_Click" />&nbsp;&nbsp;
                                    <asp:Button ID="btnRegionModify" CssClass="button1" Text="修改" runat="server" OnClick="btnRegionModify_Click" />&nbsp;&nbsp;
                                    <asp:Button ID="btnRegionDelete" CssClass="button1" Text="删除" runat="server" OnClick="btnRegionDelete_Click" />&nbsp;&nbsp;
                                </div>
                            </td>
                        </tr>
                    </table>
                </div>
            </div>
            
            <div class="con" style="margin-top:30px">
                <div class="card">
                    POS投放模式编码维护</div>
                <div class="kuang5">
                    <table width="97%" border="0" cellpadding="0" cellspacing="0" class="text20">
                        <tr>
                            <td width="6%">
                                <div align="right">
                                    投放模式:</div>
                            </td>
                            <td width="10%">
                                <asp:DropDownList ID="selDeliveryMode" AutoPostBack="true" runat="server" OnSelectedIndexChanged="selDeliveryMode_changed">
                                </asp:DropDownList>
                            </td>
                            <td width="4%">
                                <div align="right">
                                    编码:</div>
                            </td>
                            <td width="14%">
                                <asp:TextBox ID="txtDeliveryModeCode"  runat="server" MaxLength="1" CssClass="input" /><font color="red">*</font>
                            </td>
                            <td width="4%">
                                <div align="right">
                                    名称:</div>
                            </td>
                            <td width="14%">
                                <asp:TextBox ID="txtDeliveryMode" runat="server" MaxLength="20" CssClass="input" /><font color="red">*</font>
                            </td>
                            <td width="6%">
                                <div align="right">
                                    有效标志
                                </div>
                            </td>
                            <td width="12%">
                                <asp:DropDownList ID="selDeliveryUseTAG" runat="server">
                                </asp:DropDownList><font color="red">*</font>
                            </td>
                            <td>
                                <div align="right">
                                    <asp:Button ID="btnDeliveryAdd" CssClass="button1" Text="新增" runat="server" OnClick="btnDeliveryAdd_Click" />&nbsp;&nbsp;
                                    <asp:Button ID="btnDeliveryModify" CssClass="button1" Text="修改" runat="server" OnClick="btnDeliveryModify_Click" />&nbsp;&nbsp;
                                    <asp:Button ID="btnDeliveryDelete" CssClass="button1" Text="删除" runat="server" OnClick="btnDeliveryDelete_Click" />&nbsp;&nbsp;
                                </div>
                            </td>
                        </tr>
                    </table>
                </div>
            </div>

            <div class="con" style="margin-top:30px">
                <div class="card">
                    应用行业编码维护</div>
                <div class="kuang5">
                    <table width="97%" border="0" cellpadding="0" cellspacing="0" class="text20">
                        <tr>
                            <td width="6%">
                                <div align="right">
                                    应用行业:</div>
                            </td>
                            <td width="10%">
                                <asp:DropDownList ID="selAppCalling" AutoPostBack="true" runat="server" OnSelectedIndexChanged="selAppCalling_changed">
                                </asp:DropDownList>
                            </td>
                            <td width="4%">
                                <div align="right">
                                    编码:</div>
                            </td>
                            <td width="14%">
                                <asp:TextBox ID="txtAppCallingCode" runat="server" MaxLength="1" CssClass="input" /><font color="red">*</font>
                            </td>
                            <td width="4%">
                                <div align="right">
                                    名称:</div>
                            </td>
                            <td width="14%">
                                <asp:TextBox ID="txtAppCalling" runat="server" MaxLength="20" CssClass="input" /><font color="red">*</font>
                            </td>
                            <td width="6%">
                                <div align="right">
                                    有效标志
                                </div>
                            </td>
                            <td width="12%">
                                <asp:DropDownList ID="selAppCallingUseTAG" runat="server">
                                </asp:DropDownList><font color="red">*</font>
                            </td>
                            <td>
                                <div align="right">
                                    <asp:Button ID="btnAppCallingAdd" CssClass="button1" Text="新增" runat="server" OnClick="btnAppCallingAdd_Click" />&nbsp;&nbsp;
                                    <asp:Button ID="btnAppCallingModify" CssClass="button1" Text="修改" runat="server" OnClick="btnAppCallingModify_Click" />&nbsp;&nbsp;
                                    <asp:Button ID="btnAppCallingDelete" CssClass="button1" Text="删除" runat="server" OnClick="btnAppCallingDelete_Click" />&nbsp;&nbsp;
                                </div>
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

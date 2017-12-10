<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PB_RefundInput.aspx.cs" Inherits="ASP_PersonalBusiness_PB_RefundInput" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>退款记录录入</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
    <div class="tb">
        个人业务->退款记录录入
    </div>
    <ajaxToolkit:ToolkitScriptManager EnableScriptGlobalization="true" EnableScriptLocalization="true"
        ID="ScriptManager1" runat="server" />
    <asp:UpdatePanel ID="UpdatePanel1" UpdateMode="Conditional" runat="server">
        <ContentTemplate>
            <asp:BulletedList ID="bulMsgShow" runat="server" />
            <script runat="server">public override void ErrorMsgShow() { ErrorMsgHelper(bulMsgShow); }</script>
            <div class="con">
                <div class="base">
                    退款记录录入</div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td>
                                <div align="right">
                                    充值ID:</div>
                            </td>
                            <td>
                                <asp:TextBox ID="SupplyId" CssClass="inputmid" MaxLength="18" runat="server"></asp:TextBox>
                            </td>
                            <td>
                                <div align="right">
                                    &nbsp;</div>
                            </td>
                            <td>
                                &nbsp;
                            </td>
                            <td>
                                <div align="center">
                                    <asp:Button ID="btnQuery" CssClass="button1" runat="server" Text="查询" OnClick="btnQuery_Click" /></div>
                            </td>
                        </tr>
                    </table>
                </div>
                <div class="jieguo">
                    退款记录</div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="2" class="text25">
                        <tr>
                            <td width="12%">
                                <div align="right">
                                    充值ID:</div>
                            </td>
                            <td width="15%">
                                <asp:Label ID="chargeID" runat="server" Text=""></asp:Label>
                            </td>
                            <td width="12%">
                                <div align="right">
                                    卡号:</div>
                            </td>
                            <td width="15%">
                                <asp:TextBox ID="txtCardno" CssClass="labeltext" ReadOnly="true" MaxLength="16" runat="server"></asp:TextBox>
                            </td>
                            <td width="12%">
                                <div align="right">
                                    退款金额:</div>
                            </td>
                            <td width="15%">
                                <asp:Label ID="BackMoney" runat="server" Text=""></asp:Label>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    充值日期:</div>
                            </td>
                            <td>
                                <asp:Label ID="labSuppyDate" runat="server" Text=""></asp:Label>
                            </td>
                            <td>
                                <div align="right">
                                    收款人账户类型:</div>
                            </td>
                            <td>
                                <asp:DropDownList ID="selPurPoseType" AutoPostBack="true" runat="server">
                                </asp:DropDownList>
                            </td>
                            <td>
                                <div align="right">
                                    返还比例:</div>
                            </td>
                            <td>
                                <asp:DropDownList ID="BackSlope" AutoPostBack="true" runat="server">
                                </asp:DropDownList>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    退款账户的银行账户:</div>
                            </td>
                            <td>
                                <asp:TextBox ID="BankAccNo" CssClass="inputmid" MaxLength="30" runat="server"></asp:TextBox>
                            </td>
                            <td>
                                <div align="right">
                                    退款账户的开户名:</div>
                            </td>
                            <td>
                                <asp:TextBox ID="txtCusname" CssClass="input" MaxLength="25" runat="server"></asp:TextBox>
                            </td>
                            <td>
                            </td>
                            <td>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    退款账户的开户行:</div>
                            </td>
                            <td colspan="5">
                                <asp:TextBox ID="txtBank" CssClass="inputmid" runat="server" AutoPostBack="true"
                                    OnTextChanged="txtBank_Changed"></asp:TextBox>
                                <asp:DropDownList ID="selBank" AutoPostBack="true" runat="server" CssClass="inputmidder">
                                </asp:DropDownList>
                        </tr>
                    </table>
                </div>
            </div>
            <div class="footall">
            </div>
            <div class="btns">
                <table width="95%" border="0" cellpadding="0" cellspacing="0">
                    <tr>
                        <td width="70%">
                            &nbsp;
                        </td>
                        <td align="right">
                            <asp:CheckBox ID="chkApprove" AutoPostBack="true" Text="可退" runat="server" OnCheckedChanged="chkApprove_CheckedChanged" />
                        </td>
                        <td align="right">
                            <asp:CheckBox ID="chkReject" AutoPostBack="true" Text="待查" runat="server" OnCheckedChanged="chkReject_CheckedChanged" />
                        </td>
                        <td align="right">
                            <asp:Button ID="btnSubmit" Enabled="false" CssClass="button1" runat="server" Text="提交"
                                OnClick="btnSubmit_Click" />
                        </td>
                    </tr>
                </table>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
    </form>
</body>
</html>

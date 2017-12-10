<%@ Page Language="C#" AutoEventWireup="true" EnableEventValidation="false" CodeFile="PN_TradeRecord.aspx.cs"
    Inherits="ASP_ProvisionNote_PN_TradeRecord" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>业务帐务录入</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="../../js/myext.js"></script>
    <script type="text/javascript" src="../../js/mootools.js"></script>
    <script type="text/javascript" src="../../js/jquery-1.5.min.js"></script>
</head>
<body>
    <form id="form1" runat="server">
    <div class="tb">
        业务帐务录入
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
            <asp:BulletedList ID="bulMsgShow" runat="server" />
            <script runat="server">public override void ErrorMsgShow() { ErrorMsgHelper(bulMsgShow); }</script>
            <asp:HiddenField ID="hidShowCheckQuery" runat="server" />
            <asp:HiddenField ID="hidRemind" runat="server" />
            <asp:HiddenField ID="hidApprove" runat="server" />
            <div class="con">
                <div class="jieguo">
                    详细信息</div>
                <div class="kuang5" runat="server" id="divInfo">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td>
                                <div align="right">
                                    交易时间:</div>
                            </td>
                            <td>
                                <asp:TextBox ID="txtTradeDate" CssClass="input" runat="server"></asp:TextBox>
                                <ajaxToolkit:CalendarExtender ID="CalendarExtender1" runat="server" TargetControlID="txtTradeDate"
                                    Format="yyyyMMdd" PopupPosition="TopLeft" />
                            </td>
                            <td>
                                <div align="right">
                                    交易类型:</div>
                            </td>
                            <td>
                                <asp:DropDownList ID="selTradeTypeCode" CssClass="inputmid" runat="server">
                                    <asp:ListItem Text="---请选择---" Value=""></asp:ListItem>
                                    <asp:ListItem Text="" Value=""></asp:ListItem>
                                    <asp:ListItem Text="" Value=""></asp:ListItem>
                                    <asp:ListItem Text="" Value=""></asp:ListItem>
                                </asp:DropDownList>
                            </td>
                            <td>
                                <div align="right">
                                    金额:</div>
                            </td>
                            <td colspan="2">
                                <asp:TextBox ID="txtMoney" CssClass="inputmid" runat="server"></asp:TextBox>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    对应部门:</div>
                            </td>
                            <td>
                                <asp:DropDownList ID="selInDept" CssClass="inputmid" runat="server">
                                </asp:DropDownList>
                            </td>
                            <td>
                                <div align="right">
                                    支付业务类型编码:</div>
                            </td>
                            <td>
                                <asp:DropDownList ID="selBFJTradeTypeCode" CssClass="inputmid" runat="server">
                                    <asp:ListItem Text="---请选择---" Value=""></asp:ListItem>
                                    <asp:ListItem Text="01:入金" Value="01"></asp:ListItem>
                                    <asp:ListItem Text="02:销户提现" Value="02"></asp:ListItem>
                                    <asp:ListItem Text="03:出金" Value="03"></asp:ListItem>
                                    <asp:ListItem Text="04:入金手续费" Value="04"></asp:ListItem>
                                    <asp:ListItem Text="05:出金手续费" Value="05"></asp:ListItem>
                                    <asp:ListItem Text="99:其他" Value="99"></asp:ListItem>
                                </asp:DropDownList>
                            </td>
                            <td>
                                <div align="right">
                                    是否现金:</div>
                            </td>
                            <td colspan="2">
                                <asp:DropDownList ID="DropDownList2" CssClass="inputmid" runat="server">
                                    <asp:ListItem Text="---请选择---" Value=""></asp:ListItem>
                                    <asp:ListItem Text="0:非现金" Value="0"></asp:ListItem>
                                    <asp:ListItem Text="1:现金" Value="1"></asp:ListItem>
                                </asp:DropDownList>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    备注:</div>
                            </td>
                            <td>
                                <asp:TextBox ID="txtRemark" CssClass="inputlong" runat="server"></asp:TextBox>
                            </td>
                            <td>
                                <div align="right">
                                    出入金类型:</div>
                            </td>
                            <td>
                                
                                <asp:DropDownList ID="DropDownList1" CssClass="inputmid" runat="server">
                                    <asp:ListItem Text="---请选择---" Value=""></asp:ListItem>
                                    <asp:ListItem Text="0:入金" Value="0"></asp:ListItem>
                                    <asp:ListItem Text="1:出金" Value="1"></asp:ListItem>
                                </asp:DropDownList>
                            </td>
                            <td colspan="2">
                            </td>
                        </tr>
                    </table>
                </div>
            </div>
            <div class="btns">
                <table width="200px" border="0" align="right" cellpadding="0" cellspacing="0">
                    <tr>
                        <td>
                            <asp:Button ID="Button1" Text="确认" CssClass="button1" runat="server" />
                        </td>
                    </tr>
                </table>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
    </form>
</body>
</html>

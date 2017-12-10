<%@ Page Language="C#" AutoEventWireup="true" CodeFile="SD_TestToBusCard.aspx.cs" Inherits="ASP_SpecialDeal_SD_TestToBusCard" EnableEventValidation="false"%>

<%@ Register Src="../../CardReader.ascx" TagName="CardReader" TagPrefix="cr" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>公交测试卡维护</title>
    <%--<link rel="stylesheet" type="text/css" href="../../css/frame.css" />--%>
    <script type="text/javascript" src="../../js/print.js"></script>
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    </script>
</head>
<body>
    <cr:CardReader ID="cardReader" runat="server" />
    <form id="form1" runat="server">
    <div class="tb">
        异常处理->公交测试卡维护
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
                    查询</div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td width="12%">
                                <div align="right">
                                    卡号:</div>
                            </td>
                            <td width="12%">
                                <asp:TextBox ID="txtCardNo" runat="server" CssClass="input" MaxLength="16"></asp:TextBox>
                            </td>
                            <td width="12%">
                            </td>
                            <td width="12%">
                            </td>
                            <td width="12%">
                            </td>
                            <td width="12%">
                            <asp:Button ID="Button2" runat="server" Text="查询" CssClass="button1" OnClick="btnQuery_Click" />
                            </td>
                            <td width="12%">
                                
                            </td>
                        </tr>
                    </table>
                </div>
                <div class="jieguo">
                    公交测试卡维护信息</div>
                <div class="kuang5">
                    <div id="gdtb" style="height: 280px; overflow: auto;">
                        <asp:GridView ID="gvResult" runat="server" CssClass="tab1" Width="100%" HeaderStyle-CssClass="tabbt"
                            AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel" AllowPaging="True"
                            PageSize="50" PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="Left"
                            PagerStyle-VerticalAlign="Top" AutoGenerateColumns="False" OnPageIndexChanging="gvResult_Page">
                            <Columns>
                                <asp:BoundField DataField="CARDNO" HeaderText="卡号" />
                                <asp:BoundField DataField="ASN" HeaderText="卡序列号" />
                                <asp:BoundField DataField="STAFFNAME" HeaderText="操作员工" />
                                <asp:BoundField DataField="DEPARTNAME" HeaderText="操作部门" />
                                <asp:BoundField DataField="OPERATETIME" HeaderText="操作时间" DataFormatString="{0:yyyy-MM-dd HH:mm:ss}"/>
                            </Columns>
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                        <td>
                                            卡号
                                        </td>
                                        <td>
                                            卡序列号
                                        </td>
                                        <td>
                                            操作员工
                                        </td>
                                        <td>
                                            操作部门
                                        </td>
                                        <td>
                                            操作时间
                                        </td>
                                    </tr>
                                </table>
                            </EmptyDataTemplate>
                        </asp:GridView>
                    </div>
                </div>
                <div class="pip">
                    公交测试卡维护</div>
                <div class="kuang5">
                    <asp:HiddenField ID="hidTradeId" runat="server" />
                    <asp:HiddenField ID="hidCheckState" runat="server" />
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td width="12%">
                                <div align="right">
                                    起讫卡号:</div>
                            </td>
                            <td width="24%">
                                <asp:TextBox ID="txtFromCardNo" CssClass="input" runat="server" MaxLength="16"></asp:TextBox>
                                -
                                <asp:TextBox ID="txtToCardNo" CssClass="input" runat="server" MaxLength="16"></asp:TextBox><span class="red">*</span>
                            </td>
                            <td width="12%">
                            </td>
                            <td width="12%">
                            </td>
                            <td align="right" width="12%">
                                
                            </td>
                            <td width="12%">
                                
                            </td>
                        </tr>
                        <tr>
                            <td colspan="4">
                            </td>
                            <td align="left">
                                <asp:Button ID="btnBlackAdd" Text="增 加" CssClass="button1" runat="server" OnClick="btnBusAdd_Click" />
                            </td>
                            <td align="left">
                                <asp:Button ID="btnBlackDelete" Text="删 除" CssClass="button1" runat="server" OnClick="btnBusDelete_Click" />
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

<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PB_Speloadinput.aspx.cs"
    Inherits="ASP_PersonalBusiness_PB_Speloadinput" EnableEventValidation="false" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>特殊圈存录入</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <script type="text/javascript" src="../../js/myext.js"></script>
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
    <div class="tb">
        个人业务->特殊圈存录入
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
                <div class="jieguo">
                    卡片信息</div>
                <div class="kuang5">
                    <div class="gdtb" style="height: 210px">
                        <asp:GridView ID="lvwSpeloadQuery" runat="server" Width="95%" CssClass="tab1" HeaderStyle-CssClass="tabbt"
                            AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel" AllowPaging="True"
                            PageSize="15" PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left"
                            PagerStyle-VerticalAlign="Top" OnPageIndexChanging="lvwSpeloadQuery_Page" AutoGenerateColumns="False"
                            OnSelectedIndexChanged="lvwSpeloadQuery_SelectedIndexChanged" OnRowCreated="lvwSpeloadQuery_RowCreated"
                            OnRowDataBound="lvwSpeloadQuery_RowDataBound">
                            <Columns>
                                <asp:BoundField DataField="TRADEID" Visible="false" HeaderText="交易序号" />
                                <asp:BoundField DataField="CARDNO" HeaderText="卡号" />
                                <asp:BoundField DataField="TRADEMONEY" HeaderText="交易金额" NullDisplayText="0" DataFormatString="{0:n}"
                                    HtmlEncode="false" />
                                <asp:BoundField DataField="TRADETIMES" HeaderText="交易笔数" />
                                <asp:BoundField DataFormatString="{0:yyyy-MM-dd}" DataField="TRADEDATE" HeaderText="交易日期" />
                                <asp:BoundField DataFormatString="{0:yyyy-MM-dd}" DataField="INPUTTIME" HeaderText="录入时间" />
                                <asp:BoundField DataField="REMARK" HeaderText="备注说明" />
                                <asp:BoundField DataField="STATECODE" HeaderText="状态" />
                            </Columns>
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                        <td>
                                            卡号
                                        </td>
                                        <td>
                                            交易金额
                                        </td>
                                        <td>
                                            交易笔数
                                        </td>
                                        <td>
                                            交易日期
                                        </td>
                                        <td>
                                            录入时间
                                        </td>
                                        <td>
                                            备注说明
                                        </td>
                                        <td>
                                            状态
                                        </td>
                                    </tr>
                                </table>
                            </EmptyDataTemplate>
                        </asp:GridView>
                        <asp:HiddenField ID="hiddenTradeid" runat="server" />
                        <asp:HiddenField ID="hidStateCode" runat="server" />
                    </div>
                </div>
                <div class="card">
                    轻轨交易补录记录</div>
                <div class="kuang5">
                    <div class="gdtb" style="height: 120px">
                        <asp:GridView ID="gvResult" runat="server" Width="80%" CssClass="tab2" HeaderStyle-CssClass="tabbt"
                            FooterStyle-CssClass="tabcon" AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel"
                            PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top"
                            AutoGenerateColumns="true" ShowFooter="false">
                        </asp:GridView>
                    </div>
                </div>
                <div class="card">
                    详细信息</div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td width="10%">
                                <div align="right">
                                    卡号:</div>
                            </td>
                            <td width="13%">
                                <asp:TextBox ID="txtCardno" CssClass="input" MaxLength="16" runat="server"></asp:TextBox>
                            </td>
                            <td width="9%">
                                <div align="right">
                                    金额:</div>
                            </td>
                            <td width="13%">
                                <asp:TextBox ID="Money" CssClass="input" MaxLength="7" runat="server"></asp:TextBox>
                            </td>
                            <td width="9%">
                                <div align="right">
                                    交易日期:</div>
                            </td>
                            <td width="13%">
                                <asp:TextBox ID="tradeDate" CssClass="input" runat="server" MaxLength="10" />
                                <ajaxToolkit:CalendarExtender ID="FCalendar" runat="server" TargetControlID="tradeDate"
                                    Format="yyyy-MM-dd" />
                            </td>
                            <td width="12%">
                                <div align="right">
                                    交易笔数:</div>
                            </td>
                            <td width="11%">
                                <asp:TextBox ID="tradeNum" CssClass="input" MaxLength="7" runat="server"></asp:TextBox>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    备注说明:</div>
                            </td>
                            <td colspan="7">
                                <asp:TextBox ID="txtRemark" CssClass="inputmax" MaxLength="50" runat="server"></asp:TextBox>
                            </td>
                        </tr>
                    </table>
                </div>
            </div>
            <div>
                <div class="footall">
                </div>
            </div>
            <div class="btns">
                <table width="250" border="0" align="right" cellpadding="0" cellspacing="0">
                    <tr>
                        <td>
                            <asp:Button ID="btnAdd" CssClass="button1" runat="server" Text="增加" OnClick="btnAdd_Click" />
                        </td>
                        <td>
                            <asp:Button ID="btnCancel" CssClass="button1" runat="server" Text="作废" OnClick="btnCancel_Click" />
                        </td>
                        <td>
                            <asp:Button ID="btnQuery" CssClass="button1" runat="server" Text="查询" OnClick="btnQuery_Click" />
                        </td>
                    </tr>
                </table>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
    </form>
</body>
</html>

<%@ Page Language="C#" AutoEventWireup="true" CodeFile="SD_LRTTradeMendAudit.aspx.cs"
    Inherits="ASP_SpecialDeal_SD_SubwayTradeMendAudit" EnableEventValidation="false" %>

<%@ Register Src="../../CardReader.ascx" TagName="CardReader" TagPrefix="cr" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>轻轨交易补录</title>
    <%--<link rel="stylesheet" type="text/css" href="../../css/frame.css" />--%>
    <script type="text/javascript" src="../../js/print.js"></script>
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <cr:CardReader ID="cardReader" runat="server" />
    <form id="form1" runat="server">
    <div class="tb">
        异常处理->轻轨交易补录审核
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
                    待审核轻轨交易补录信息</div>
                <div class="kuang5">
                    <div id="gdtb" style="height: 320px;">
                        <asp:GridView ID="gvResult" runat="server" CssClass="tab1" Width="100%" HeaderStyle-CssClass="tabbt"
                            AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel" AllowPaging="True"
                            PageSize="20" PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="Left"
                            PagerStyle-VerticalAlign="Top" AutoGenerateColumns="False" OnPageIndexChanging="gvResult_Page"
                            OnRowDataBound="gvResult_RowDataBound" OnSelectedIndexChanged="gvResult_SelectedIndexChanged"
                            OnRowCreated="gvResult_RowCreated">
                            <Columns>
                                <asp:BoundField DataField="TRADEID" HeaderText="业务流水号" />
                                <asp:BoundField DataField="CARDNO" HeaderText="卡号" />
                                <asp:BoundField DataField="TRADEDATE" HeaderText="交易日期" />
                                <asp:BoundField DataField="TRADETIME" HeaderText="交易时间" />
                                <asp:BoundField DataField="TRADEMONEY" HeaderText="交易金额" />
                                <asp:BoundField DataField="CARDTRADENO" HeaderText="交易序号" />
                                <asp:BoundField DataField="ERRORREASON" HeaderText="原因" />
                                <asp:BoundField DataField="DEALRESULT" HeaderText="处理结果" />
                                <asp:BoundField DataField="DEALSTAFFNO" HeaderText="处理员工" />
                                <asp:BoundField DataField="DEALDATE" HeaderText="处理日期" />
                                <asp:BoundField DataField="STAFFNAME" HeaderText="录入员工" />
                                <asp:BoundField DataField="RENEWTIME" HeaderText="录入时间" />
                                <asp:BoundField DataField="REMARK" HeaderText="备注" />
                            </Columns>
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                        <td>
                                            卡号
                                        </td>
                                        <td>
                                            交易日期
                                        </td>
                                        <td>
                                            交易时间
                                        </td>
                                        <td>
                                            交易金额
                                        </td>
                                        <td>
                                            交易序号
                                        </td>
                                        <td>
                                            原因
                                        </td>
                                        <td>
                                            处理结果
                                        </td>
                                        <td>
                                            处理员工
                                        </td>
                                        <td>
                                            处理日期
                                        </td>
                                        <td>
                                            录入员工
                                        </td>
                                        <td>
                                            录入时间
                                        </td>
                                        <td>
                                            备注
                                        </td>
                                    </tr>
                                </table>
                            </EmptyDataTemplate>
                        </asp:GridView>
                    </div>
                </div>
                <div class="pip">
                    轻轨交易补录</div>
                <div class="kuang5">
                    <asp:HiddenField ID="hidTradeId" runat="server" />
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td align="right" width="12%">
                                卡号:
                            </td>
                            <td width="12%">
                                <asp:Label runat="server" ID="labCardno" />
                            </td>
                            <td width="12%">
                                <div align="right">
                                    交易日期:</div>
                            </td>
                            <td width="12%">
                                <asp:Label ID="labTradeDate" runat="server"></asp:Label>
                            </td>
                            <td width="12%">
                                <div align="right">
                                    交易时间:</div>
                            </td>
                            <td width="12%">
                                <asp:Label ID="labTradeTime" runat="server"></asp:Label>
                            </td>
                            <td align="right" width="12%">
                                交易金额:
                            </td>
                            <td width="12%">
                                <asp:Label runat="server" ID="labMoney" />
                            </td>
                        </tr>
                        <tr>
                            <td align="right" width="12%">
                                处理结果:
                            </td>
                            <td width="12%">
                                <asp:Label runat="server" ID="labDealResult" />
                            </td>
                            <td align="right" width="12%">
                                处理员工:
                            </td>
                            <td width="12%">
                                <asp:Label runat="server" ID="labDealStaff" />
                            </td>
                            <td width="12%">
                                <div align="right">
                                    处理日期:</div>
                            </td>
                            <td width="12%">
                                <asp:Label ID="labDealDate" runat="server" />
                            </td>
                            <td align="right" width="12%">
                                录入员工:
                            </td>
                            <td width="12%">
                                <asp:Label runat="server" ID="labCreateStaff" />
                            </td>
                        </tr>
                        <tr>
                            <td align="right">
                                原因:
                            </td>
                            <td colspan="3">
                                <asp:Label runat="server" ID="labReason" />
                            </td>
                            <td align="right">
                                备注:
                            </td>
                            <td colspan="3">
                                <asp:Label runat="server" ID="labRemark" />
                            </td>
                        </tr>
                    </table>
                    <div class="linex">
                    </div>
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                           <td align="right" width="12%">
                                交易序号:
                            </td>
                            <td width="12%">
                                <asp:TextBox runat="server" ID="txtTradeNo" CssClass="input" MaxLength="4"/>
                            </td>
                            <td colspan="4" width="48%">
                            </td>
                            <td width="12%" align="right">
                                <asp:Button ID="btnPass" runat="server" Text="通过" CssClass="button1" Enabled="false"
                                    OnClick="btnPass_Click" />
                            </td>
                            <td width="12%" align="left">&nbsp
                                <asp:Button ID="btnCancel" runat="server" Text="作废" CssClass="button1" Enabled="false"
                                    OnClick="btnCancel_Click" />
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

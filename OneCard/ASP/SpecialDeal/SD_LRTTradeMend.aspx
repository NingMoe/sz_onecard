<%@ Page Language="C#" AutoEventWireup="true" CodeFile="SD_LRTTradeMend.aspx.cs"
    Inherits="ASP_SpecialDeal_SD_SubwayTradeMend" EnableEventValidation="false" %>

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
        异常处理->轻轨交易补录
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
                                <asp:TextBox ID="txtCardNum" runat="server" CssClass="input" MaxLength="16"></asp:TextBox>
                            </td>
                            <td width="12%">
                                <div align="right">
                                    审核状态:</div>
                            </td>
                            <td width="12%">
                                <div>
                                    <asp:DropDownList ID="selChkState" runat="server" CssClass="input">
                                    </asp:DropDownList>
                                </div>
                            </td>
                            <td width="12%">
                                <div align="right">
                                    交易起始日期:</div>
                            </td>
                            <td width="12%">
                                <ajaxToolkit:CalendarExtender ID="BeginCalendar" runat="server" TargetControlID="txtTradeStartDate"
                                    Format="yyyyMMdd" PopupPosition="BottomLeft" />
                                <asp:TextBox ID="txtTradeStartDate" runat="server" CssClass="input" MaxLength="8"></asp:TextBox>
                            </td>
                            <td width="12%">
                                <div align="right">
                                    交易结束日期:</div>
                            </td>
                            <td width="12%">
                                <asp:TextBox ID="txtTradeEndDate" runat="server" CssClass="input" MaxLength="8"></asp:TextBox>
                                <ajaxToolkit:CalendarExtender ID="CalendarExtender2" runat="server" TargetControlID="txtTradeEndDate"
                                    Format="yyyyMMdd" PopupPosition="BottomLeft" />
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    处理起始日期:</div>
                            </td>
                            <td>
                                <ajaxToolkit:CalendarExtender ID="CalendarExtender1" runat="server" TargetControlID="txtDealStartDate"
                                    Format="yyyyMMdd" PopupPosition="BottomLeft" />
                                <asp:TextBox ID="txtDealStartDate" runat="server" CssClass="input" MaxLength="8"></asp:TextBox>
                            </td>
                            <td>
                                <div align="right">
                                    处理结束日期:</div>
                            </td>
                            <td>
                                <asp:TextBox ID="txtDealEndDate" runat="server" CssClass="input" MaxLength="8"></asp:TextBox>
                                <ajaxToolkit:CalendarExtender ID="CalendarExtender3" runat="server" TargetControlID="txtDealEndDate"
                                    Format="yyyyMMdd" PopupPosition="BottomLeft" />
                            </td>
                            <td colspan="2"></td>
                            <td align="right">
                                <asp:Button ID="Button2" runat="server" Text="查询" CssClass="button1" OnClick="btnQuery_Click" />
                            </td>
                            <td>
                            </td>
                        </tr>
                        <tr>
                            <td>
                            </td>
                        </tr>
                    </table>
                </div>
                <div class="jieguo">
                    轻轨交易补录信息</div>
                <div class="kuang5">
                    <div id="gdtb" style="height: 250px;">
                        <asp:GridView ID="gvResult" runat="server" CssClass="tab1" Width="150%" HeaderStyle-CssClass="tabbt"
                            AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel" AllowPaging="True"
                            PageSize="20" PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="Left"
                            PagerStyle-VerticalAlign="Top" AutoGenerateColumns="False" OnPageIndexChanging="gvResult_Page"
                            OnRowDataBound="gvResult_RowDataBound" OnSelectedIndexChanged="gvResult_SelectedIndexChanged"
                            OnRowCreated="gvResult_RowCreated">
                            <Columns>
                                <asp:BoundField DataField="TRADEID" HeaderText="业务流水号" />
                                <asp:BoundField DataField="CARDNO" HeaderText="卡号" />
                                <asp:BoundField DataField="CHECKSTATECODE" HeaderText="审核状态" />
                                <asp:BoundField DataField="TRADEDATE" HeaderText="交易日期" />
                                <asp:BoundField DataField="TRADETIME" HeaderText="交易时间" />
                                <asp:BoundField DataField="TRADEMONEY" HeaderText="交易金额" />
                                <asp:BoundField DataField="CARDTRADENO" HeaderText="交易序号" />
                                <asp:BoundField DataField="ERRORREASON" HeaderText="原因" />
                                <asp:BoundField DataField="DEALRESULT" HeaderText="处理结果" />
                                <asp:BoundField DataField="DEALSTAFFNO" HeaderText="处理员工" />
                                <asp:BoundField DataField="DEALDATE" HeaderText="处理日期" />
                                <asp:BoundField DataField="RENEWSTAFF" HeaderText="录入员工" />
                                <asp:BoundField DataField="RENEWTIME" HeaderText="录入时间" />
                                <asp:BoundField DataField="CHECKSTAFF" HeaderText="审核员工" />
                                <asp:BoundField DataField="CHECKTIME" HeaderText="审核时间" />
                                <asp:BoundField DataField="REMARK" HeaderText="备注" />
                            </Columns>
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                        <td>
                                            卡号
                                        </td>
                                        <td>
                                            审核状态
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
                                            审核员工
                                        </td>
                                        <td>
                                            审核时间
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
                    <asp:HiddenField ID="hidCheckState" runat="server" />
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td align="right" width="12%">
                                卡号:
                            </td>
                            <td width="12%">
                                <asp:TextBox runat="server" ID="txtCardno" CssClass="input" MaxLength="16" /><span class="red">*</span>
                            </td>
                            <td width="12%">
                                <div align="right">
                                    交易日期:</div>
                            </td>
                            <td width="12%">
                                <ajaxToolkit:CalendarExtender ID="CalendarExtender4" runat="server" TargetControlID="TradeDate"
                                    Format="yyyyMMdd" PopupPosition="BottomLeft" />
                                <asp:TextBox ID="TradeDate" runat="server" CssClass="input" MaxLength="8"></asp:TextBox><span class="red">*</span>
                            </td>
                            <td width="12%">
                                <div align="right">
                                    交易时间:</div>
                            </td>
                            <td width="12%">
                                <asp:TextBox ID="TradeTime" runat="server" CssClass="input" MaxLength="6"></asp:TextBox>
                            </td>
                            <td align="right" width="12%">
                                交易金额:
                            </td>
                            <td width="12%">
                                <asp:TextBox runat="server" ID="txtMoney" CssClass="input" MaxLength="6" /><span class="red">*</span>
                            </td>
                        </tr>
                        <tr>
                            <td align="right" width="12%">
                                处理结果:
                            </td>
                            <td width="12%">
                                <asp:TextBox runat="server" ID="txtDealResult" CssClass="input" MaxLength="25"/>
                            </td>
                            <td align="right" width="12%">
                                处理员工姓名:
                            </td>
                            <td width="12%">
                                <asp:TextBox runat="server" ID="txtDealStaff" CssClass="input" MaxLength="10"/>
                            </td>
                            <td width="12%">
                                <div align="right">
                                    处理日期:</div>
                            </td>
                            <td width="12%">
                                <ajaxToolkit:CalendarExtender ID="CalendarExtender5" runat="server" TargetControlID="DealDate"
                                    Format="yyyyMMdd" PopupPosition="BottomLeft" />
                                <asp:TextBox ID="DealDate" runat="server" CssClass="input" MaxLength="8"></asp:TextBox>
                            </td>
                            <td align="right" width="12%">
                                录入员工:
                            </td>
                            <td width="12%">
                                <asp:Label runat="server" ID="labCreateStaffNo" />
                            </td>
                        </tr>
                        <tr>
                            <td align="right">
                                原因:
                            </td>
                            <td colspan="3">
                                <asp:TextBox runat="server" ID="txtReason" CssClass="inputlong" MaxLength="50" />
                            </td>
                            <td align="right">
                                备注:
                            </td>
                            <td colspan="3">
                                <asp:TextBox runat="server" ID="txtRemark" CssClass="inputlong" MaxLength="50" />
                            </td>
                        </tr>
                        <tr>
                            <td colspan="5">
                            </td>
                            <td align="left" colspan="3">
                                <asp:Button ID="btnBlackAdd" Text="增 加" CssClass="button1" runat="server" OnClick="btnBlackAdd_Click" />
                                <asp:Button ID="btnBlackModify" Text="修 改" CssClass="button1" runat="server" Enabled="false"
                                    OnClick="btnBlackModify_Click" />
                                <asp:Button ID="btnBlackDelete" Text="删 除" CssClass="button1" runat="server" Enabled="false"
                                    OnClick="btnBlackDelete_Click" />
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

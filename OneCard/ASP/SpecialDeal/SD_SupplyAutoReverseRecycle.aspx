<%@ Page Language="C#" AutoEventWireup="true" CodeFile="SD_SupplyAutoReverseRecycle.aspx.cs"
    Inherits="ASP_SpecialDeal_SD_SupplyAutoReverseRecycle" %>

<%@ Register Src="../../CardReader.ascx" TagName="CardReader" TagPrefix="cr" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>充值自动冲正台账回收</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <cr:CardReader ID="cardReader" runat="server" />
    <form id="form1" runat="server">
    <div class="tb">
        异常处理->充值自动冲正台账回收</div>
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
            <asp:BulletedList ID="bulMsgShow" runat="server" />

            <script runat="server">public override void ErrorMsgShow() { ErrorMsgHelper(bulMsgShow); }</script>

            <div class="con">
                <div class="card">
                    查询方式</div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td width="15%">
                                <div align="right">
                                    交易起始日期:</div>
                            </td>
                            <td width="15%">
                                <asp:TextBox ID="txtStartDate" runat="server" CssClass="input" MaxLength="10"></asp:TextBox>
                                <ajaxToolkit:CalendarExtender ID="BeginCalendar" runat="server" TargetControlID="txtStartDate"
                                    Format="yyyyMMdd" PopupPosition="BottomLeft" />
                            </td>
                            <td width="15%">
                                <div align="right">
                                    交易终止日期:</div>
                            </td>
                            <td width="15%">
                                <asp:TextBox ID="txtEndDate" runat="server" CssClass="input" MaxLength="10"></asp:TextBox>
                                <ajaxToolkit:CalendarExtender ID="CalendarExtender2" runat="server" TargetControlID="txtEndDate"
                                    Format="yyyyMMdd" PopupPosition="BottomLeft" />
                            </td>
                            <td width="15%">
                                <div align="right">
                                    IC卡号:</div>
                            </td>
                            <td width="15%">
                                <asp:TextBox ID="txtCardNo" runat="server" CssClass="input" MaxLength="16"></asp:TextBox>
                            </td>
                        </tr>
                        <tr>
                            <td align="right">
                                单元类型:
                            </td>
                            <td>
                                <asp:DropDownList ID="ddlBalType" CssClass="input" runat="server" OnSelectedIndexChanged="ddlBalType_SelectedIndexChanged"
                                    AutoPostBack="true">
                                    <asp:ListItem Text="0:在线充付代理商户" Value="0"></asp:ListItem>
                                    <asp:ListItem Text="1:其他" Value="1"></asp:ListItem>
                                </asp:DropDownList>
                            </td>
                            <td>
                                <div align="right">
                                    充值渠道:</div>
                            </td>
                            <td >
                                <asp:DropDownList ID="selSupplyWay" CssClass="inputmidder" runat="server">
                                </asp:DropDownList>
                            </td>
                            <td>
                            </td>
                            <td>
                                <asp:Button ID="btnQuery" runat="server" Text="查询" CssClass="button1" OnClick="btnQuery_Click" />
                            </td>
                        </tr>
                    </table>
                </div>
                <div class="jieguo">
                    充值异常信息</div>
                <div class="kuang5">
                    <!-- 列表框 -->
                    <div class="gdtb" style="height: 320px">
                        <asp:GridView ID="gvResult" runat="server" Width="130%" CssClass="tab1" HeaderStyle-CssClass="tabbt"
                            AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel" AllowPaging="True"
                            PageSize="8" PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left"
                            PagerStyle-VerticalAlign="Top" AutoGenerateColumns="False" OnPageIndexChanging="gvResult_Page"
                            OnRowDataBound="gvResult_RowDataBound">
                            <Columns>
                                <asp:TemplateField>
                                    <HeaderTemplate>
                                        <asp:CheckBox ID="CheckBox1" runat="server" AutoPostBack="true" OnCheckedChanged="CheckAll" />
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                        <asp:CheckBox ID="ItemCheckBox" runat="server" />
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField DataField="ID" HeaderText="记录流水号" />
                                <asp:BoundField DataField="CARDNO" HeaderText="IC卡号" />
                                <asp:BoundField DataField="TRADEDATE" HeaderText="交易日期" />
                                <asp:BoundField DataField="TRADETIME" HeaderText="交易时间" />
                                <asp:BoundField DataField="PREMONEY" HeaderText="交易前卡内金额" />
                                <asp:BoundField DataField="TRADEMONEY" HeaderText="交易金额" />
                                <asp:BoundField DataField="BALUNIT" HeaderText="充值渠道" />
                                <asp:BoundField DataField="ASN" HeaderText="卡片ASN号" />
                                <asp:BoundField DataField="CARDTRADENO" HeaderText="交易序列号" />
                                <asp:BoundField DataField="POSNO" HeaderText="POS编号" />
                                <asp:BoundField DataField="SAMNO" HeaderText="PSAM编号" />
                                <asp:BoundField DataField="TAC" HeaderText="TAC码" />
                                <asp:BoundField DataField="TRADESTATECODE" HeaderText="交易状态" />
                            </Columns>
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                        <td>
                                            <input type="checkbox" />
                                        </td>
                                        <td>
                                            IC卡号
                                        </td>
                                        <td>
                                            交易日期
                                        </td>
                                        <td>
                                            交易时间
                                        </td>
                                        <td>
                                            交易前卡内金额
                                        </td>
                                        <td>
                                            交易金额
                                        </td>
                                        <td>
                                            充值渠道
                                        </td>
                                        <td>
                                            卡片ASN号
                                        </td>
                                        <td>
                                            交易序列号
                                        </td>
                                        <td>
                                            POS编号
                                        </td>
                                        <td>
                                            PSAM编号
                                        </td>
                                        <td>
                                            TAC码
                                        </td>
                                        <td>
                                            交易状态
                                        </td>
                                    </tr>
                                </table>
                            </EmptyDataTemplate>
                        </asp:GridView>
                    </div>
                </div>
                <div class="card">
                    回收处理</div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td width="15%">
                                <div align="right">
                                    回收说明 :</div>
                            </td>
                            <td colspan="3" width="45%">
                                <div align="left">
                                    <asp:TextBox ID="txtRenewRemark" runat="server" CssClass="inputmax" MaxLength="150"></asp:TextBox>
                                </div>
                            </td>
                            <td width="15%">
                            </td>
                            <td width="15%">
                                <div align="left">
                                    <asp:Button ID="btnRecycle" runat="server" Text="回收" CssClass="button1" OnClick="btnRecycle_Click" /></div>
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

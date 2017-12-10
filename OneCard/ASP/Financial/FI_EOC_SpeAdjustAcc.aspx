<%@ Page Language="C#" AutoEventWireup="true" CodeFile="FI_EOC_SpeAdjustAcc.aspx.cs" Inherits="ASP_Financial_FI_EOC_SpeAdjustAcc"
    EnableEventValidation="false" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>沉淀资金特殊调账</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
        <div class="tb">
            管理报表->沉淀资金特殊调账
        </div>
        <ajaxtoolkit:toolkitscriptmanager runat="Server" enablescriptglobalization="true"
            enablescriptlocalization="true" id="ScriptManager2" />
        <asp:updatepanel id="UpdatePanel1" runat="server">
        <ContentTemplate>
            <asp:BulletedList ID="bulMsgShow" runat="server" />
            <script runat="server">public override void ErrorMsgShow() { ErrorMsgHelper(bulMsgShow); }</script>
            <div class="con">
                <div class="card">
                    查询
                </div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="4" class="text25">
                        <tr>
                            <td width="15%">
                                <div align="right">
                                    开始日期:</div>
                            </td>
                            <td width="15%">
                                <asp:TextBox runat="server" ID="txtFromDate" MaxLength="8" CssClass="input"></asp:TextBox>
                                <ajaxToolkit:CalendarExtender ID="CalendarExtender2" runat="server" TargetControlID="txtFromDate" Format="yyyyMMdd" />
                            </td>
                            <td width="15%">
                                <div align="right">
                                    结束日期:</div>
                            </td>
                            <td width="15%">
                                <asp:TextBox runat="server" ID="txtToDate" MaxLength="8" CssClass="input"></asp:TextBox>
                                <ajaxToolkit:CalendarExtender ID="CalendarExtender3" runat="server" TargetControlID="txtToDate" Format="yyyyMMdd" />
                            </td>
                            <td width="15%">
                                <div align="right">
                                    收支类别:</div>
                            </td>
                            <td width="25%">
                                <asp:DropDownList ID="ddlCategory" CssClass="input" runat="server">
                                    <asp:ListItem Text="--请选择--" Value=""></asp:ListItem>
                                    <asp:ListItem Text="收入" Value="沉淀资金收入"></asp:ListItem>
                                    <asp:ListItem Text="支出" Value="沉淀资金支出"></asp:ListItem>
                                </asp:DropDownList>
                            </td>
                        </tr>
                        <tr>
                        <td width="15%">
                                <div align="right">
                                    业务类型:</div>
                            </td>
                            <td width="25%">
                                <asp:DropDownList ID="selCallType" CssClass="input" runat="server" OnSelectedIndexChanged="selCallType_SelectedIndexChanged" AutoPostBack="true">
                                    <asp:ListItem Text="沉淀资金" Value="1"></asp:ListItem>
                                    <asp:ListItem Text="备付金" Value="2"></asp:ListItem>
                                </asp:DropDownList>
                            </td>
                            <asp:HiddenField ID="hidType" runat="server" />
                            <td colspan="3">
                            </td>
                            <td  align="left">
                                <asp:Button ID="Button1" runat="server" Text="查询" CssClass="button1" OnClick="btnQuery_Click" />
                            </td>
                        </tr>
                    </table>
                </div>
                <div class="jieguo">
                    沉淀资金特殊调账记录
                </div>
                <div class="kuang5">
                    <div class="gdtb" style="height: 300px">
                        <asp:GridView ID="gvResult" runat="server" CssClass="tab2" Width="98%" HeaderStyle-CssClass="tabbt"
                            FooterStyle-CssClass="tabcon" AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel"
                            PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="Left" PagerStyle-VerticalAlign="Top"
                            AutoGenerateColumns="False" OnSelectedIndexChanged="gvResult_SelectedIndexChanged"
                            OnRowDataBound="gvResult_RowDataBound" OnRowCreated="gvResult_RowCreated" EmptyDataText="没有数据记录!">
                            <PagerSettings Mode="NumericFirstLast" />
                            <Columns>
                                <asp:BoundField DataField="ID" HeaderText="ID"  Visible="false" />
                                <asp:BoundField DataField="STATTIME" HeaderText="日期" />
                                <asp:BoundField DataField="CATEGORY" HeaderText="收支类别" />
                                <asp:BoundField DataField="MONEY" HeaderText="金额" />
                                <asp:BoundField DataField="REMARK" HeaderText="备注" />
                            </Columns>
                            <PagerStyle HorizontalAlign="Left" VerticalAlign="Top" />
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                        <td>
                                            日期
                                        </td>
                                        <td>
                                            收支类别
                                        </td>
                                        <td>
                                            金额
                                        </td>
                                        <td>
                                            备注
                                        </td>
                                    </tr>
                                </table>
                            </EmptyDataTemplate>
                            <SelectedRowStyle CssClass="tabsel" />
                            <HeaderStyle CssClass="tabbt" />
                            <AlternatingRowStyle CssClass="tabjg" />
                        </asp:GridView>
                    </div>
                </div>
                <div class="card">
                    沉淀资金特殊调账</div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td width="15%">
                                <div align="right">
                                    日期:</div>
                            </td>
                            <td width="15%">
                                <asp:TextBox runat="server" ID="txtStatDate" MaxLength="8" CssClass="input"></asp:TextBox>
                                <span class="red" runat="server">*</span>
                                <ajaxToolkit:CalendarExtender ID="CalendarExtender1" runat="server"  PopupPosition="TopLeft" TargetControlID="txtStatDate" Format="yyyyMMdd" />
                            </td>
                            <td width="15%">
                                <div align="right">
                                    收支类别:</div>
                            </td>
                            <td width="15%">
                                <asp:DropDownList ID="selCategory" CssClass="input" runat="server">
                                    <asp:ListItem Text="--请选择--" Value=""></asp:ListItem>
                                    <asp:ListItem Text="收入" Value="沉淀资金收入"></asp:ListItem>
                                    <asp:ListItem Text="支出" Value="沉淀资金支出"></asp:ListItem>
                                </asp:DropDownList>
                                <span id="Span1" class="red" runat="server">*</span>
                            </td>
                            <td width="15%">
                                <div align="right">
                                    金额:</div>
                            </td>
                            <td width="25%">
                                <asp:TextBox runat="server" ID="txtMoney" MaxLength="12" CssClass="input"></asp:TextBox>
                                <span id="Span2" class="red" runat="server">*</span>
                            </td>
                        </tr>
                        <tr runat="server" id="btBFGList">
                            <td width="15%">
                                <div align="right">
                                    交易类型:</div>
                            </td>
                            <td width="15%">
                                <asp:DropDownList ID="selTradeType" CssClass="input" runat="server">
                                </asp:DropDownList>
                                <span id="Span3" class="red" runat="server">*</span>
                            </td>
                            <td width="15%">
                                <div align="right">
                                    支付业务类型编码:</div>
                            </td>
                            <td width="15%">
                                <asp:DropDownList ID="selBFJTradeTypeCode" CssClass="input" runat="server">
                                    <asp:ListItem Text="--请选择--" Value=""></asp:ListItem>
                                    <asp:ListItem Text="01:入金" Value="01"></asp:ListItem>
                                    <asp:ListItem Text="02:销户提现" Value="02"></asp:ListItem>
                                    <asp:ListItem Text="03:出金" Value="03"></asp:ListItem>
                                    <asp:ListItem Text="04:入金手续费" Value="04"></asp:ListItem>
                                    <asp:ListItem Text="05:出金手续费" Value="05"></asp:ListItem>
                                    <asp:ListItem Text="99:其他" Value="99"></asp:ListItem>
                                </asp:DropDownList>
                                <span id="Span4" class="red" runat="server">*</span>
                            </td>
                            <td width="15%">
                                <div align="right">
                                    是否现金:</div>
                            </td>
                            <td width="25%">
                                <asp:DropDownList ID="selISCash" CssClass="input" runat="server">
                                    <asp:ListItem Text="--请选择--" Value=""></asp:ListItem>
                                    <asp:ListItem Text="0:非现金" Value="0"></asp:ListItem>
                                    <asp:ListItem Text="1:现金" Value="1"></asp:ListItem>
                                </asp:DropDownList>
                                <span id="Span5" class="red" runat="server">*</span>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    备注:</div>
                            </td>
                            <td colspan="4">
                                <asp:TextBox runat="server" ID="txtRemark"  CssClass="inputlong" MaxLength="90"></asp:TextBox>
                                <span id="Span6" class="red" runat="server">*</span>
                            </td>
                            <td align="left" width="40%">
                                <asp:Button ID="btnAdd" runat="server" Text="增加" CssClass="button1" OnClick="btnAdd_Click" />
                                &nbsp;<asp:Button ID="btnDel" runat="server" Text="删除" Enabled="false" CssClass="button1" OnClick="btnDel_Click" />
                            </td>
                        </tr>
                    </table>
                </div>
            </div>
        </ContentTemplate>
    </asp:updatepanel>
    </form>
</body>
</html>

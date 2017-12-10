<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PS_Chargetype.aspx.cs" Inherits="ASP_PartnerShip_PS_Chargetype"
    EnableEventValidation="false" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>充值营销模式维护</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
    <div class="tb">
        合作伙伴->充值营销模式维护</div>
    <ajaxToolkit:ToolkitScriptManager runat="Server" EnableScriptGlobalization="true"
        EnableScriptLocalization="true" ID="ScriptManager2" />
    <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
            <asp:BulletedList ID="bulMsgShow" runat="server" />
            <script runat="server">public override void ErrorMsgShow() { ErrorMsgHelper(bulMsgShow); }</script>
            <div class="con">
                <div class="jieguo">
                    充值营销模式
                </div>
                <div class="kuang5">
                    <div class="gdtb" style="height: 300px">
                        <asp:GridView ID="gvResult" runat="server" CssClass="tab1" Width="98%" HeaderStyle-CssClass="tabbt"
                            AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel" PageSize="1000"
                            PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="Left" PagerStyle-VerticalAlign="Top"
                            AutoGenerateColumns="False" OnSelectedIndexChanged="gvResult_SelectedIndexChanged"
                            OnRowCreated="gvResult_RowCreated" EmptyDataText="没有数据记录!">
                            <PagerSettings Mode="NumericFirstLast" />
                            <Columns>
                                <asp:BoundField DataField="CHARGETYPECODE" HeaderText="充值营销模式编码" />
                                <asp:BoundField DataField="CHARGETYPENAME" HeaderText="充值营销模式名称" />
                                <asp:BoundField DataField="CHARGETYPESTATE" HeaderText="充值营销模式说明" />
                                <asp:BoundField DataField="STAFFNAME" HeaderText="更新员工" />
                                <asp:BoundField DataField="UPDATETIME" HeaderText="更新时间" />
                            </Columns>
                            <PagerStyle HorizontalAlign="Left" VerticalAlign="Top" />
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                        <td>
                                            充值营销模式编码
                                        </td>
                                        <td>
                                            充值营销模式名称
                                        </td>
                                        <td>
                                            充值营销模式说明
                                        </td>
                                        <td>
                                            更新员工
                                        </td>
                                        <td>
                                            更新时间
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
                    充值营销模式维护</div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td>
                                <div align="right">
                                    充值营销模式名称:</div>
                            </td>
                            <td>
                                <asp:TextBox ID="txtChargeTypeName" CssClass="input" runat="server" MaxLength="20">
                                </asp:TextBox><span class="red">*</span>
                            </td>
                            <td>
                                <div align="right">
                                    充值营销模式说明:</div>
                            </td>
                            <td>
                                <asp:TextBox ID="txtChargeTypeState" CssClass="inputmidder" runat="server" MaxLength="200">
                                </asp:TextBox>
                            </td>
                            <td align="right">
                                &nbsp;<asp:Button ID="btnAdd" runat="server" Text="增加" CssClass="button1" OnClick="btnAdd_Click" />
                                &nbsp;<asp:Button ID="btnDel" runat="server" Text="删除" Enabled="false" CssClass="button1"
                                    OnClick="btnDel_Click" />
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

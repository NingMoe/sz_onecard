<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PS_Chargetype_Dept.aspx.cs"
    Inherits="ASP_PartnerShip_PS_Chargetype_Dept" EnableEventValidation="false" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>部门与充值营销模式关系维护</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
    <div class="tb">
        合作伙伴->部门与充值营销模式关系维护</div>
    <ajaxToolkit:ToolkitScriptManager runat="Server" EnableScriptGlobalization="true"
        EnableScriptLocalization="true" ID="ScriptManager2" />
    <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
            <asp:BulletedList ID="bulMsgShow" runat="server" />
            <script runat="server">public override void ErrorMsgShow() { ErrorMsgHelper(bulMsgShow); }</script>
            <div class="con">
                <div class="card">
                    查询
                </div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="12text">
                        <tr>
                            <td width="15%">
                                <div align="right">
                                    充值营销模式:</div>
                            </td>
                            <td width="15%">
                                <asp:DropDownList ID="ddlChargeType" CssClass="inputmid" runat="server" />
                            </td>
                            <td width="15%">
                                <div align="right">
                                    部门:</div>
                            </td>
                            <td width="15%">
                                <asp:DropDownList ID="ddlDept" CssClass="inputmid" runat="server" />
                            </td>
                            <td width="40%" align="right">
                                <asp:Button ID="btnQuery" runat="server" Text="查询" CssClass="button1" OnClick="btnQuery_Click" />
                            </td>
                    </table>
                </div>
                <div class="jieguo">
                    部门与充值营销模式关系
                </div>
                <div class="kuang5">
                    <div class="gdtb" style="height: 300px">
                        <asp:GridView ID="gvResult" runat="server" CssClass="tab1" Width="98%" HeaderStyle-CssClass="tabbt"
                            AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel" PageSize="1000"
                            PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="Left" PagerStyle-VerticalAlign="Top"
                            AutoGenerateColumns="False" OnSelectedIndexChanged="gvResult_SelectedIndexChanged"
                            OnRowDataBound="gvResult_RowDataBound" OnRowCreated="gvResult_RowCreated" EmptyDataText="没有数据记录!">
                            <PagerSettings Mode="NumericFirstLast" />
                            <Columns>
                                <asp:BoundField DataField="CHARGETYPECODE" HeaderText="充值营销模式编码" />
                                <asp:BoundField DataField="CHARGETYPENAME" HeaderText="充值营销模式名称" />
                                <asp:BoundField DataField="DEPTNO" HeaderText="部门编码" />
                                <asp:BoundField DataField="DEPARTNAME" HeaderText="部门" />
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
                                            部门
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
                    部门与充值营销模式关系维护</div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td width="15%">
                                <div align="right">
                                    充值营销模式:</div>
                            </td>
                            <td width="15%">
                                <asp:DropDownList ID="selChargeType" CssClass="inputmid" runat="server">
                                </asp:DropDownList>
                            </td>
                            <td width="15%">
                                <div align="right">
                                    部门:</div>
                            </td>
                            <td width="15%">
                                <asp:DropDownList ID="selDept" CssClass="inputmid" runat="server">
                                </asp:DropDownList>
                            </td>
                            <td align="right" width="40%">
                                &nbsp;<asp:Button ID="btnAdd" runat="server" Text="增加" CssClass="button1" OnClick="btnAdd_Click" />
                                &nbsp;<asp:Button ID="btnDel" runat="server" Text="删除" Enabled="false" CssClass="button1" OnClick="btnDel_Click" />
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

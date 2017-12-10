<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PS_DeptBalRelation.aspx.cs"
    Inherits="ASP_PartnerShip_PS_DeptBalRelation" EnableEventValidation="false" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>结算单元网点关系维护</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
    <div class="tb">
        合作伙伴->结算单元网点关系维护</div>
    <ajaxToolkit:ToolkitScriptManager runat="Server" EnableScriptGlobalization="true"
        EnableScriptLocalization="true" ID="ScriptManager2" />
    <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
            <asp:BulletedList ID="bulMsgShow" runat="server" />

            <script runat="server">public override void ErrorMsgShow() { ErrorMsgHelper(bulMsgShow); }</script>

            <div class="con">
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="12text">
                        <tr>
                            <td>
                                <div align="right">
                                    结算单元:</div>
                            </td>
                            <td>
                                <asp:DropDownList ID="ddlBalUnit" CssClass="inputmidder" runat="server" />
                            </td>
                            <td>
                                <div align="right">
                                    网点名称:</div>
                            </td>
                            <td>
                                <asp:DropDownList ID="ddlInsideDept" CssClass="inputmid" runat="server" />
                            </td>
                            <td width="9%">
                                <asp:Button ID="btnQuery" runat="server" Text="查询" CssClass="button1" OnClick="btnQuery_Click" />
                            </td>
                    </table>
                </div>
                <div class="jieguo">
                    结算单元网点关系列表
                </div>
                <div class="kuang5">
                    <div class="gdtb" style="height: 300px">
                        <asp:GridView ID="lvwBalUnits" runat="server" CssClass="tab1" Width="98%" HeaderStyle-CssClass="tabbt"
                            AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel"
                            PageSize="1000" PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="Left"
                            PagerStyle-VerticalAlign="Top" AutoGenerateColumns="False" OnSelectedIndexChanged="lvwBalUnits_SelectedIndexChanged"
                            OnRowCreated="lvwBalUnits_RowCreated" EmptyDataText="没有数据记录!">
                            <PagerSettings Mode="NumericFirstLast" />
                            <Columns>
                                <asp:BoundField DataField="NUM" HeaderText="#" />
                                <asp:BoundField DataField="DBALUNITNO" HeaderText="结算单元编码" />
                                <asp:BoundField DataField="DBALUNIT" HeaderText="结算单元名称" />
                                <asp:BoundField DataField="DEPARTNO" HeaderText="网点编码" />
                                <asp:BoundField DataField="DEPARTNAME" HeaderText="网点名称" />
                            </Columns>
                            <PagerStyle HorizontalAlign="Left" VerticalAlign="Top" />
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                        <td>
                                            #
                                        </td>
                                        <td>
                                            结算单元编码
                                        </td>
                                        <td>
                                            结算单元名称
                                        </td>
                                        <td>
                                            网点编码
                                        </td>
                                        <td>
                                            网点名称
                                        </td>
                                        <td>
                                            网点类型
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
                    结算单元网点关系信息</div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td>
                                <div align="right">
                                    网点名称:</div>
                            </td>
                            <td>
                                <asp:DropDownList ID="selInsideDept" CssClass="inputmid" runat="server">
                                </asp:DropDownList>
                            </td>
                            <td>
                                <div align="right">
                                    结算单元:</div>
                            </td>
                            <td>
                                <asp:DropDownList ID="selBalUnit" CssClass="inputmidder" runat="server">
                                </asp:DropDownList>
                            </td>
                            <td align="right">
                                &nbsp;<asp:Button ID="btnAdd" runat="server" Text="增加" CssClass="button1" OnClick="btnAdd_Click" />
                                &nbsp;<asp:Button ID="btnDel" runat="server" Text="删除" CssClass="button1" OnClick="btnDel_Click" />
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

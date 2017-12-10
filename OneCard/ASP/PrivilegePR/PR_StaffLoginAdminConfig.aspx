<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PR_StaffLoginAdminConfig.aspx.cs"
    Inherits="ASP_PrivilegePR_PR_StaffLoginAdminConfig" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>系统设置-admin页面登陆限制</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <%--  <script type="text/javascript" src="../../js/myext.js"></script>--%>
</head>
<body>
    <form id="form1" runat="server">
    <div class="tb">
        系统设置->admin页面登陆限制
    </div>
    <ajaxToolkit:ToolkitScriptManager runat="Server" EnableScriptGlobalization="true"
        EnableScriptLocalization="true" ID="ScriptManager2" />
    <asp:UpdatePanel ID="UpdatePanel1" runat="server" RenderMode="Inline">
        <ContentTemplate>
            <asp:BulletedList ID="bulMsgShow" runat="server">
            </asp:BulletedList>

            <script runat="server">public override void ErrorMsgShow() { ErrorMsgHelper(bulMsgShow); }</script>

            <div class="con">
                <div class="pip">
                    admin页面登陆限制</div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td width="12%">
                                <div align="right">
                                    部门名称:</div>
                            </td>
                            <td width="23%">
                                <asp:DropDownList ID="selDepartName" CssClass="inputmid" runat="server" AutoPostBack="true"
                                    OnSelectedIndexChanged="selDepartName_SelectedIndexChanged">
                                </asp:DropDownList>
                            </td>
                            <td width="9%">
                                <div align="right">
                                    员工姓名:</div>
                            </td>
                            <td width="20%">
                                <asp:DropDownList ID="selStaffName" CssClass="inputmid" runat="server">
                                </asp:DropDownList>
                            </td>
                            <td width="9%">
                                <div align="right">
                                    当前状态:
                                </div>
                            </td>
                            <td>
                                <asp:DropDownList ID="selConfigtype" CssClass="input" runat="server">
                                    <asp:ListItem Text="0: 限制" Value="0"></asp:ListItem>
                                    <asp:ListItem Text="1: 不限制" Value="1"></asp:ListItem>
                                </asp:DropDownList>
                            </td>
                            <td width="15%">
                                <asp:Button runat="server" Text="查询" CssClass="button1" OnClick="btnQuery_Click" />
                            </td>
                        </tr>
                    </table>
                </div>
                <div class="kuang5">
                    <div id="gdtb" style="height: 320px">
                        <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                            <asp:GridView ID="gvResult" runat="server" Width="98%" CssClass="tab1" HeaderStyle-CssClass="tabbt"
                                FooterStyle-CssClass="tabcon" AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel"
                                PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top"
                                AutoGenerateColumns="false">
                                <Columns>
                                    <asp:TemplateField>
                                        <HeaderTemplate>
                                            <asp:CheckBox ID="chkCheckAll" runat="server" AutoPostBack="true" OnCheckedChanged="CheckAll" />
                                        </HeaderTemplate>
                                        <ItemTemplate>
                                            <asp:CheckBox ID="ItemCheckBox" runat="server" />
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:BoundField DataField="staffname" HeaderText="员工姓名" />
                                    <asp:BoundField DataField="departname" HeaderText="部门名称" />
                                </Columns>
                                <EmptyDataTemplate>
                                    <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                        <tr class="tabbt">
                                            <td>
                                                员工姓名
                                            </td>
                                            <td>
                                                部门名称
                                            </td>
                                        </tr>
                                    </table>
                                </EmptyDataTemplate>
                            </asp:GridView>
                        </table>
                    </div>
                </div>
            </div>
            <div class="btns">
                <table width="95%" border="0" cellpadding="0" cellspacing="0">
                    <tr>
                        <td width="70%">
                        </td>
                        <td width="15%" align="right">
                            <asp:Button ID="btnDel" Enabled="true" CssClass="button1" runat="server" Text="取消限制"
                                OnClick="btnDel_Click" />
                        </td>
                        <td width="15%" align="left">
                            &nbsp;&nbsp;
                            <asp:Button ID="btnAdd" Enabled="false" CssClass="button1" runat="server" Text="添加限制"
                                OnClick="btnAdd_Click" />
                        </td>
                    </tr>
                </table>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
    </form>
</body>
</html>

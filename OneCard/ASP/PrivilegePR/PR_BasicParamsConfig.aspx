<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PR_BasicParamsConfig.aspx.cs" Inherits="ASP_PrivilegePR_PR_BasicParamsConfig" EnableEventValidation="false" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>系统设置-基本参数配置</title>
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
        <ajaxToolkit:ToolkitScriptManager runat="Server" EnableScriptGlobalization="true"
            EnableScriptLocalization="true" ID="ScriptManager2" />
        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
            <ContentTemplate>
                <div class="tb">系统设置-&gt;基本参数配置</div>
                <!-- #include file="../../ErrorMsg.inc" -->
                <div class="basicinfohf">
                    <div class="base">部门配置</div>
                    <div class="kuang5">
                        <div class="gdtb" style="height: 350px">
                            <asp:GridView ID="lvwDepart" runat="server"
                                Width="100%"
                                CssClass="tab1"
                                AllowPaging="true"
                                PageSize="12"
                                HeaderStyle-CssClass="tabbt"
                                AlternatingRowStyle-CssClass="tabjg"
                                SelectedRowStyle-CssClass="tabsel"
                                PagerSettings-Mode="NumericFirstLast"
                                PagerStyle-HorizontalAlign="left"
                                PagerStyle-VerticalAlign="Top"
                                AutoGenerateColumns="False"
                                OnRowCreated="lvwDepart_RowCreated"
                                OnSelectedIndexChanged="lvwDepart_SelectedIndexChanged"
                                OnPageIndexChanging="lvwDepart_Page">
                                <Columns>
                                    <asp:BoundField HeaderText="部门编码" DataField="DEPARTNO" />
                                    <asp:BoundField HeaderText="部门名称" DataField="DEPARTNAME" />
                                    <asp:BoundField HeaderText="地区名称" DataField="REGIONNAME" />
                                </Columns>
                                <PagerSettings Mode="NumericFirstLast" />
                                <SelectedRowStyle CssClass="tabsel" />
                                <PagerStyle HorizontalAlign="Left" VerticalAlign="Top" />
                                <HeaderStyle CssClass="tabbt" />
                                <AlternatingRowStyle CssClass="tabjg" />
                                <EmptyDataTemplate>
                                    <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                        <tr class="tabbt">
                                            <td>部门编码</td>
                                            <td>部门名称</td>
                                            <td>地区名称</td>
                                        </tr>
                                    </table>
                                </EmptyDataTemplate>
                            </asp:GridView>
                        </div>
                    </div>
                    <div class="kuang5">
                        <table width="580" border="0" cellpadding="0" cellspacing="0" class="text25">
                            <tr>
                                <td style="height: 37px">
                                    <div align="right">部门编码:</div>
                                </td>
                                <td style="height: 37px">
                                    <asp:TextBox ID="txtDepartNO" runat="server" CssClass="inputmid" MaxLength="20" Width="96px"></asp:TextBox><span class="red">*</span></td>
                                <td style="height: 37px">
                                    <div align="right">部门名称:</div>
                                </td>
                                <td style="height: 37px">
                                    <asp:TextBox ID="txtDepartName" runat="server" CssClass="inputmid" MaxLength="40" Width="115px"></asp:TextBox><span class="red">*</span></td>

                            </tr>
                            <tr>
                                <td style="height: 37px">
                                    <div align="right">地区：</div>
                                </td>
                                <td style="height: 37px">
                                    <asp:DropDownList ID="selRegion" CssClass="input" runat="server">
                                    </asp:DropDownList><%--<span class="red">*</span>--%>
                                </td>
                                <td style="height: 37px">
                                    <div align="right">是否有效:</div>
                                </td>
                                <td style="height: 37px">
                                    <asp:DropDownList ID="selUseTag" CssClass="input" runat="server">
                                        <asp:ListItem Value="1" Text="有效" />
                                        <asp:ListItem Value="0" Text="无效" />
                                    </asp:DropDownList></td> 
                            </tr>
                            <tr>
                                <td colspan="4">
                                    <table width="300" border="0" align="right" cellpadding="0" cellspacing="0">
                                        <tr>

                                            <td>
                                                <asp:Button ID="btnDepartAdd" runat="server" Text="增加" CssClass="button1" OnClick="btnDepartAdd_Click" /></td>
                                            <td>
                                                <asp:Button ID="btnDepartModify" runat="server" Text="修改" CssClass="button1" OnClick="btnDepartModify_Click" /></td>
                                            <td>
                                                <asp:Button ID="btnDepartDelete" runat="server" Text="删除" CssClass="button1" OnClick="btnDepartDelete_Click" /></td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                        </table>
                    </div>
                </div>
                <div class="pipinfohf">
                    <div class="info">角色配置</div>
                    <div class="kuang5">
                        <div class="gdtb" style="height: 350px">
                            <asp:GridView ID="lvwRole" runat="server"
                                Width="100%"
                                CssClass="tab1"
                                AllowPaging="true"
                                PageSize="12"
                                HeaderStyle-CssClass="tabbt"
                                AlternatingRowStyle-CssClass="tabjg"
                                SelectedRowStyle-CssClass="tabsel"
                                PagerSettings-Mode="NumericFirstLast"
                                PagerStyle-HorizontalAlign="left"
                                PagerStyle-VerticalAlign="Top"
                                AutoGenerateColumns="False"
                                OnRowCreated="lvwRole_RowCreated"
                                OnSelectedIndexChanged="lvwRole_SelectedIndexChanged"
                                OnPageIndexChanging="lvwRole_Page">
                                <Columns>
                                    <asp:BoundField HeaderText="角色编码" DataField="ROLENO" />
                                    <asp:BoundField HeaderText="角色名称" DataField="ROLENAME" />
                                </Columns>
                                <PagerSettings Mode="NumericFirstLast" />
                                <SelectedRowStyle CssClass="tabsel" />
                                <PagerStyle HorizontalAlign="Left" VerticalAlign="Top" />
                                <HeaderStyle CssClass="tabbt" />
                                <AlternatingRowStyle CssClass="tabjg" />
                                <EmptyDataTemplate>
                                    <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                        <tr class="tabbt">
                                            <td>角色编码</td>
                                            <td>角色名称</td>
                                        </tr>
                                    </table>
                                </EmptyDataTemplate>
                            </asp:GridView>
                        </div>
                    </div>
                    <div class="kuang5">
                        <table width="380" border="0" cellpadding="0" cellspacing="0" class="text25">
                            <tr>
                                <td style="height: 37px">
                                    <div align="right">角色编码:</div>
                                </td>
                                <td style="height: 37px">
                                    <asp:TextBox ID="txtRoleNO" runat="server" CssClass="inputmid" MaxLength="20" Width="96px"></asp:TextBox><span class="red">*</span></td>
                                <td style="height: 37px">
                                    <div align="right">角色名称:</div>
                                </td>
                                <td style="height: 37px">
                                    <asp:TextBox ID="txtRoleName" runat="server" CssClass="inputmid" MaxLength="40" Width="115px"></asp:TextBox><span class="red">*</span></td>
                            </tr>
                            <tr>
                                <td colspan="4">
                                    <table width="300" border="0" align="right" cellpadding="0" cellspacing="0">
                                        <tr>
                                            <td>
                                                <asp:Button ID="btnRoleAdd" runat="server" Text="增加" CssClass="button1" OnClick="btnRoleAdd_Click" /></td>
                                            <td>
                                                <asp:Button ID="btnRoleModify" runat="server" Text="修改" CssClass="button1" OnClick="btnRoleModify_Click" /></td>
                                            <td>
                                                <asp:Button ID="btnRoleDelete" runat="server" Text="删除" CssClass="button1" OnClick="btnRoleDelete_Click" /></td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                        </table>
                    </div>
                </div>

                <div class="footall"></div>
            </ContentTemplate>
        </asp:UpdatePanel>
    </form>
</body>
</html>

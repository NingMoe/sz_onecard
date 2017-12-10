<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PR_QuickMenu.aspx.cs" Inherits="ASP_PrivilegePR_PR_QuickMenu" EnableEventValidation="false" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>系统设置-快捷菜单配置</title>
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
        <ajaxToolkit:ToolkitScriptManager runat="Server" EnableScriptGlobalization="true"
            EnableScriptLocalization="true" ID="ScriptManager2" />
        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
            <ContentTemplate>
                <div class="tb">系统设置-&gt;快捷菜单配置</div>
                <!-- #include file="../../ErrorMsg.inc" -->
                <div class="con">
                    <div class="kuang5">
                        <div class="gdtb" style="height: 300px">
                            <table width="800" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                <asp:GridView ID="lvwQuickMeno" runat="server"
                                    Width="100%"
                                    CssClass="tab1"
                                    HeaderStyle-CssClass="tabbt"
                                    AlternatingRowStyle-CssClass="tabjg"
                                    SelectedRowStyle-CssClass="tabsel"
                                    PagerSettings-Mode="NumericFirstLast"
                                    PagerStyle-HorizontalAlign="left"
                                    PagerStyle-VerticalAlign="Top"
                                    AutoGenerateColumns="False"
                                    OnRowCreated="lvwQuickMeno_RowCreated" 
                                    OnSelectedIndexChanged="lvwQuickMeno_SelectedIndexChanged">
                                    <Columns>
                                        <asp:BoundField HeaderText="菜单编码" DataField="MENUNO" />
                                        <asp:BoundField HeaderText="菜单名称" DataField="MENUNAME" />
                                        <asp:BoundField HeaderText="排序" DataField="SORT" />
                                    </Columns>
                                    <SelectedRowStyle CssClass="tabsel" />
                                    <HeaderStyle CssClass="tabbt" />
                                    <AlternatingRowStyle CssClass="tabjg" />
                                    <EmptyDataTemplate>
                                        <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                            <tr class="tabbt">
                                                <td>菜单编码</td>
                                                <td>菜单编码</td>
                                                <td>排序</td>
                                            </tr>
                                        </table>
                                    </EmptyDataTemplate>
                                </asp:GridView>
                            </table>
                        </div>
                    </div>
                    <div class="kuang5">
                        <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                            <tr>
                                <td width="12%">
                                    <div align="right">菜单:</div>
                                </td>
                                <td style="height: 37px">
                                    <aspControls:GroupDropDownList ID="selMenuList" CssClass="inputmid" runat="server"></aspControls:GroupDropDownList> 
                                    <span class="red">*</span></td>
                                <td width="9%">
                                    <div align="right">排序因子:</div>
                                </td>
                                <td style="height: 37px">
                                    <asp:TextBox ID="txtSort" runat="server" CssClass="inputmid" MaxLength="10" Width="96px"></asp:TextBox> 
                                    <span class="red">*</span> 快捷菜单将按排序因子从小到大排列 
                                    </td>
                            </tr>
                            <tr>
                                <td>
                                    <div align="right"></div>
                                </td>
                                <td>&nbsp;</td>
                                <td colspan="2">
                                    <table width="300" border="0" align="right" cellpadding="0" cellspacing="0">
                                        <tr>

                                            <td>
                                                <asp:Button ID="btnStaffAdd" runat="server" Text="增加" CssClass="button1" OnClick="btnAdd_Click" /></td>
                                            <td>
                                                <asp:Button ID="btnStaffModify" runat="server" Text="修改" CssClass="button1" OnClick="btnModify_Click" /></td>
                                            <td>
                                                <asp:Button ID="btnStaffDelete" runat="server" Text="删除" CssClass="button1" OnClick="btnDelete_Click" /></td>
                                        </tr>
                                    </table>
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

<%@ Page Language="C#" AutoEventWireup="true" CodeFile="RM_GetResourceExam.aspx.cs" Inherits="ASP_ResourceManage_RM_GetResourceExam" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>资源领用审批</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="../../js/myext.js"></script>
    
</head>
<body>
    <form id="form1" runat="server">
    <div class="tb">
        其他资源管理->资源领用审批
    </div>
     <ajaxToolkit:ToolkitScriptManager EnableScriptGlobalization="true" EnableScriptLocalization="true"
        ID="ScriptManager1" runat="server" />
    <asp:UpdatePanel ID="UpdatePanel1" UpdateMode="Conditional" runat="server">
        <ContentTemplate>
            <asp:BulletedList ID="bulMsgShow" runat="server" />
            <script runat="server">public override void ErrorMsgShow() { ErrorMsgHelper(bulMsgShow); }</script>
        <div class="con">
                <div class="base">
                    待审核领用单</div>
                <div class="kuang5">
                    <div id="gvResourceApply" style="height: 400px;overflow:auto; display: block">
                        <asp:GridView ID="gvResultResourceApply" runat="server" Width="95%" CssClass="tab1" HeaderStyle-CssClass="tabbt"
                            FooterStyle-CssClass="tabcon" AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel"
                            PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top"
                            AutoGenerateColumns="false"  OnRowDataBound="gvResultResourceApply_RowDataBound">
                            <Columns>
                                <asp:TemplateField>
                                    <HeaderTemplate>
                                      <asp:CheckBox ID="CheckBox1" runat="server"  AutoPostBack="true" OnCheckedChanged="CheckAll" />
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                      <asp:CheckBox ID="ItemCheckBox" runat="server"/>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField DataField="GETORDERID" HeaderText="领用单号" />
                                <asp:BoundField DataField="RESUOURCETYPE" HeaderText="资源类型" />
                                <asp:BoundField DataField="RESOURCENAME" HeaderText="资源名称" />
                                <asp:BoundField HeaderText="资源属性" />
                                <asp:BoundField DataField="APPLYGETNUM" HeaderText="申请领用数量" />
                                <asp:TemplateField HeaderText="同意领用数量">
                                    <ItemTemplate>
                                        <asp:TextBox ID="txtAgreeGetNum" style="text-align:center" Text='<%# Bind("APPLYGETNUM") %>' CssClass="input" runat="server"></asp:TextBox>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField DataField="USEWAY" HeaderText="用途" />
                                <asp:BoundField DataField="ORDERTIME" HeaderText="申请时间" />
                                <asp:BoundField DataField="STAFFNAME" HeaderText="申请员工" />
                                <asp:BoundField DataField="DEPARTNAME" HeaderText="申请部门" />
                                <asp:BoundField DataField="REMARK" HeaderText="备注" />
                                <asp:BoundField DataField="BATTRIBUTE1"  />
                                <asp:BoundField DataField="AATTRIBUTE1"  />
                                <asp:BoundField DataField="BATTRIBUTE2"  />
                                <asp:BoundField DataField="AATTRIBUTE2"  />
                                <asp:BoundField DataField="BATTRIBUTE3"  />
                                <asp:BoundField DataField="AATTRIBUTE3"  />
                                <asp:BoundField DataField="BATTRIBUTE4"  />
                                <asp:BoundField DataField="AATTRIBUTE4"  />
                                <asp:BoundField DataField="BATTRIBUTE5"  />
                                <asp:BoundField DataField="AATTRIBUTE5"  />
                                <asp:BoundField DataField="BATTRIBUTE6"  />
                                <asp:BoundField DataField="AATTRIBUTE6"  />
                            </Columns>
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                        <td>
                                            <input type="checkbox" />
                                        </td>
                                        <td>
                                            领用单号
                                        </td>
                                        <td>
                                            资源类型
                                        </td>
                                        <td>
                                            资源名称
                                        </td>
                                         <td>
                                            资源属性
                                        </td>
                                        <td>
                                            申请领用数量
                                        </td>
                                        <td>
                                            同意领用数量
                                        </td>
                                        <td>
                                            用途
                                        </td>
                                        <td>
                                            申请时间
                                        </td>
                                        <td>
                                            申请员工
                                        </td>
                                        <td>
                                            申请部门
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
            </div>
        <div class="btns">
                <table width="200" border="0" align="right" cellpadding="0" cellspacing="0">
                    <tr>
                        <td>
                           <%-- <asp:LinkButton runat="server" ID="btnConfirm" OnClick="btnPass_Click" />--%>
                            <asp:Button ID="btnPass" runat="server" Text="通过" CssClass="button1" Enabled="true"
                                OnClick="btnPass_Click" />
                        </td>
                        <td>
                            <asp:Button ID="btnCancel" runat="server" Text="作废" CssClass="button1" Enabled="true"
                                OnClick="btnCancel_Click" />
                        </td>
                    </tr>
                </table>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
    </form>
</body>
</html>

<%@ Page Language="C#" AutoEventWireup="true" CodeFile="RM_ResourceMaintain.aspx.cs"
    Inherits="ASP_ResourceManage_RM_ResourceMaintain" EnableEventValidation = "false"  %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>资源维护</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="../../js/myext.js"></script>
</head>
<body>
    <form id="form1" runat="server">
        <div class="tb">
            其他资源管理->资源维护 
   
        </div>
        <ajaxToolkit:ToolkitScriptManager EnableScriptGlobalization="true" EnableScriptLocalization="true"
            ID="ScriptManager1" runat="server" />
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
        <asp:UpdatePanel ID="UpdatePanel1" UpdateMode="Conditional" runat="server">
            <ContentTemplate>
                <asp:BulletedList ID="bulMsgShow" runat="server" />
                <script runat="server">public override void ErrorMsgShow() { ErrorMsgHelper(bulMsgShow); }</script>
                <div class="con">
                    <div class="card">
                        查询
                    </div>
                    <div class="kuang5">
                        <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                            <tr>
                                <td width="15%">
                                    <div align="right">
                                        资源类型:
                                    </div>
                                </td>
                                <td width="15%">
                                    <asp:DropDownList ID="ddlResourceType" runat="server" OnSelectedIndexChanged="ddlResourceType_SelectIndexChange"
                                        AutoPostBack="true">
                                    </asp:DropDownList>
                                </td>
                                <td width="15%">
                                    <div align="right">
                                        资源名称:
                                    </div>
                                </td>
                                <td width="15%">
                                    <asp:DropDownList ID="ddlResource" runat="server">
                                    </asp:DropDownList>
                                </td>
                                <td width="15%">
                                    <div align="right">
                                        维护单状态:
                                    </div>
                                </td>
                                <td width="15%">
                                    <asp:DropDownList ID="selExamState" CssClass="input" runat="server">
                                        <asp:ListItem Text="全部" Value="" Selected="True"></asp:ListItem>
                                        <asp:ListItem Text="0: 待审核" Value="0"></asp:ListItem>
                                        <asp:ListItem Text="1: 已通过" Value="1"></asp:ListItem>
                                        <asp:ListItem Text="2: 已作废" Value="2"></asp:ListItem>
                                    </asp:DropDownList>
                                </td>
                                <td align="right">
                                    <asp:Button ID="btnQuery" CssClass="button1" runat="server" Text="查询" OnClick="btnQuery_Click" />
                                </td>

                            </tr>
                            <tr>
                                <td width="15%">
                                    <div align="right">
                                        开始日期:
                                   
                                    </div>
                                </td>
                                <td width="15%">
                                    <asp:TextBox runat="server" ID="txtFromDate" MaxLength="8" CssClass="input"></asp:TextBox>
                                    <ajaxToolkit:CalendarExtender ID="FCalendar1" runat="server" TargetControlID="txtFromDate"
                                        Format="yyyyMMdd" />
                                </td>
                                <td width="15%">
                                    <div align="right">
                                        结束日期:
                                   
                                    </div>
                                </td>
                                <td width="15%">
                                    <asp:TextBox runat="server" ID="txtToDate" MaxLength="8" CssClass="input"></asp:TextBox>
                                    <ajaxToolkit:CalendarExtender ID="FCalendar2" runat="server" TargetControlID="txtToDate"
                                        Format="yyyyMMdd" />
                                </td>
                                <td width="15%">
                                    <div align="right">
                                        维护员工:
                                   
                                    </div>
                                </td>
                                <td width="15%">
                                    <asp:DropDownList ID="ddlStaffQuery" CssClass="input" runat="server"></asp:DropDownList>
                                </td>
                            </tr>
                            <tr>
                                <td width="15%">
                                    <div align="right">
                                        维护单号:
                                   
                                    </div>
                                </td>
                                <td colspan="5">
                                    <asp:TextBox runat="server" ID="txtMaintainOrderID" MaxLength="18" CssClass="input"></asp:TextBox>
                                </td>
                            </tr>
                        </table>
                    </div>
                    <div class="jieguo">
                        维护单信息
                    </div>
                    <div class="kuang5">
                        <div id="gvUseCard" style="height: 300px; overflow: auto; display: block">
                            <asp:GridView ID="gvResult" runat="server" Width="150%" CssClass="tab1" HeaderStyle-CssClass="tabbt"
                                FooterStyle-CssClass="tabcon" AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel"
                                PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top"
                                AutoGenerateColumns="false" OnRowDataBound="gvResult_RowDataBound">
                                <Columns>
                                    <asp:TemplateField>
                                        <HeaderTemplate>
                                            <asp:CheckBox ID="CheckBox1" runat="server" AutoPostBack="true" OnCheckedChanged="CheckAll" />
                                        </HeaderTemplate>
                                        <ItemTemplate>
                                            <asp:CheckBox ID="ItemCheckBox" runat="server" />
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:BoundField DataField="MAINTAINORDERID" HeaderText="维护单号" />
                                    <asp:BoundField DataField="ORDERSTATE" HeaderText="维护单状态" />
                                    <asp:BoundField DataField="RESUOURCETYPE" HeaderText="资源类型" />
                                    <asp:BoundField DataField="RESOURCENAME" HeaderText="资源名称" />
                                    <asp:BoundField DataField="MAINTAINREASON" HeaderText="申请原因" />
                                    <asp:BoundField DataField="FEEDBACK" HeaderText="反馈信息" />
                                    <asp:BoundField DataField="ORDERTIME" HeaderText="下单时间" />
                                    <asp:BoundField DataField="STAFFNAME" HeaderText="下单员工" />
                                    <asp:BoundField DataField="DEPARTNAME" HeaderText="下单部门" />
                                    <asp:BoundField DataField="TEL" HeaderText="联系电话" />
                                    <asp:BoundField DataField="REMARK" HeaderText="备注" />
                                    <asp:TemplateField HeaderText="维护员工">
                                        <ItemTemplate>
                                            <asp:DropDownList ID="ddlStaff" CssClass="input" runat="server"></asp:DropDownList>
                                            <asp:HiddenField ID="staffId" runat="server" Value='<%# Bind("MAINTAINSTAFF")%>' />
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="审核说明">
                                        <ItemTemplate>
                                            <asp:TextBox ID="txtCheckNote" Style="text-align: center" Text='<%# Bind("CHECKNOTE") %>'
                                                CssClass="input" runat="server"></asp:TextBox>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                </Columns>
                                <EmptyDataTemplate>
                                    <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                        <tr class="tabbt">
                                            <td>
                                                <input type="checkbox" />
                                            </td>
                                            <td>维护单号
                                        </td>
                                            <td>维护单状态
                                        </td>
                                            <td>资源类型
                                        </td>
                                            <td>资源名称
                                        </td>
                                            <td>申请原因
                                        </td>
                                            <td>反馈信息
                                        </td>
                                            <td>下单时间
                                        </td>
                                            <td>下单员工
                                        </td>
                                            <td>下单部门
                                        </td>
                                            <td>备注
                                        </td>
                                            <td>维护员工
                                        </td>
                                            <td>审核说明
                                        </td>
                                        </tr>
                                    </table>
                                </EmptyDataTemplate>
                            </asp:GridView>
                        </div>
                    </div>
                </div>
                <div class="footall">
                </div>
                <div class="btns">
                    <table width="300" border="0" align="right" cellpadding="0" cellspacing="0">
                        <tr>
                            <td>
                                <asp:Button ID="btnSubmit" runat="server" Text="通过" CssClass="button1" Enabled="true"
                                    OnClick="btnSubmit_Click" />
                                <asp:Button ID="Button1" runat="server" Text="作废" CssClass="button1" Enabled="true"
                                    OnClick="btnCancel_Click" />
                                <asp:Button ID="btnExport" CssClass="button1" runat="server" Text="导出" OnClick="btnExport_Click" />
                            </td>
                        </tr>
                    </table>
                </div>
                <div style="display: none" runat="server" id="printarea">
                </div>
            </ContentTemplate>
            <Triggers>
                  <asp:PostBackTrigger ControlID="btnExport" />
            </Triggers>
        </asp:UpdatePanel>
    </form>
</body>
</html>

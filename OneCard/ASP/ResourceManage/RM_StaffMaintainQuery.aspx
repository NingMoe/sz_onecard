<%@ Page Language="C#" AutoEventWireup="true" CodeFile="RM_StaffMaintainQuery.aspx.cs" Inherits="ASP_ResourceManage_RM_StaffMaintainQuery" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
<link href="../../css/card.css" rel="stylesheet" type="text/css" />

    <script type="text/javascript" src="../../js/myext.js"></script>

    <script type="text/javascript" src="../../js/RMHelper.js"></script>

    <script type="text/javascript" src="../../js/printorder.js"></script>

    <script src="../../js/jquery-1.5.min.js" type="text/javascript"></script>

    <script type="text/javascript" src="../../js/Window.js"></script>
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <div class="tb">
        资源管理->工单查询
    </div>
    <ajaxToolkit:ToolkitScriptManager runat="Server" EnableScriptGlobalization="true"
        EnableScriptLocalization="true" ID="ToolkitScriptManager1" />

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
                <div class="kuang5" style="text-align: left">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            
                            <td width="15%">
                                <div align="right">
                                    起始日期:</div>
                            </td>
                            <td width="15%">
                                <ajaxToolkit:CalendarExtender ID="BeginCalendar" runat="server" TargetControlID="txtStartDate"
                                    Format="yyyyMMdd" PopupPosition="BottomLeft" />
                                <asp:TextBox ID="txtStartDate" runat="server" CssClass="input" MaxLength="8"></asp:TextBox>
                            </td>
                            <td width="15%">
                                <div align="right">
                                    结束日期:</div>
                            </td>
                            <td width="15%">
                                <asp:TextBox ID="txtEndDate" runat="server" CssClass="input" MaxLength="8"></asp:TextBox>
                                <ajaxToolkit:CalendarExtender ID="CalendarExtender2" runat="server" TargetControlID="txtEndDate"
                                    Format="yyyyMMdd" PopupPosition="BottomLeft" />
                            </td>
                            <td width="15%">
                                <div align="right">
                                    维护网点:</div>
                            </td>
                            <td width="15%">
                                <asp:DropDownList ID="selDept" CssClass="inputmid" runat="server" >
                                </asp:DropDownList>
                            </td>
                        </tr>
                        <tr>
                            <td width="15%">
                                <div align="right">
                                    维护员工:</div>
                            </td>
                            <td width="15%">
                                <asp:DropDownList ID="selStaff" CssClass="inputmid" runat="server" >
                                </asp:DropDownList>
                            </td>
                            
                            <td width="15%">
                                <div align="right">
                                    维护状态:</div>
                            </td>
                            <td width="15%">
                            
                                <asp:DropDownList ID="ddlState" CssClass="inputmid" runat="server">
                                <asp:ListItem Text="---请选择---" Value=""></asp:ListItem>
                                <asp:ListItem Text="0:未确认" Value="0"></asp:ListItem>
                                <asp:ListItem Text="1:已确认" Value="1"></asp:ListItem>
                                </asp:DropDownList>
                            </td>
                           
                        </tr>
                        <tr>
                        <td width="15%" colspan='6' align="right">
                                <asp:Button ID="btnQuery" CssClass="button1" runat="server" Text="查询" OnClick="btnQuery_Click" />
                            </td>
                        </tr>
                    </table>
                </div>
                <table border="0" width="95%"   >
                    <tr>
                        <td align="left" >
                            <div class="jieguo">
                                工单列表</div>
                        </td>
                        <td align="right">
                            <asp:Button ID="btnExport" CssClass="button1" runat="server" Text="导出Excel" OnClick="btnExport_Click" />
                        </td>
                    </tr>
                </table>
                <div class="kuang5">
                    <div id="gvSupplyCard" style="height: 300px; overflow: auto; display: block">
                        <asp:GridView ID="gvResult" runat="server" Width="200%" CssClass="tab1" HeaderStyle-CssClass="tabbt"
                            FooterStyle-CssClass="tabcon" AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel"
                            PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top"
                            AutoGenerateColumns="false" PageSize="40" AllowPaging="true" OnPageIndexChanging="gvResult_Page">
                            <Columns>
                                <asp:BoundField DataField="SIGNINMAINTAINID" HeaderText="维护单号" />
                                <asp:BoundField DataField="MAINTAINDEPT" HeaderText="维护网点" />
                                <asp:BoundField DataField="RESOURCENAME" HeaderText="资源名称" />
                                <asp:BoundField DataField="SIGNINTIME" HeaderText="维护时间" />
                                <asp:BoundField DataField="STAFFNAME" HeaderText="维护员工" />
                                <asp:BoundField DataField="USETIME" HeaderText="维护时长" />
                                <asp:BoundField DataField="EXPLANATION" HeaderText="故障说明" />
                                <asp:BoundField DataField="ISFINISHED" HeaderText="完成情况" />
                                <asp:BoundField DataField="CONFIRMATION" HeaderText="确认说明" />
                                <asp:BoundField DataField="SATISFATION" HeaderText="满意度" />
                            </Columns>
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                        
                                        <td>
                                            维护单号
                                        </td>
                                        <td>
                                            维护网点
                                        </td>
                                        <td>
                                            资源名称
                                        </td>
                                        <td>
                                            维护时间
                                        </td>
                                        <td>
                                            维护员工
                                        </td>
                                        <td>
                                            维护时长
                                        </td>
                                        <td>
                                            故障说明
                                        </td>
                                        <td>
                                            完成情况
                                        </td>
                                        <td>
                                            确认说明
                                        </td>
                                        <td>
                                            满意度
                                        </td>
                                        
                                        
                                    </tr>
                                </table>
                            </EmptyDataTemplate>
                        </asp:GridView>
                    </div>
                </div>

            </div>
            
            

            
        </ContentTemplate>
        <Triggers>
            <asp:PostBackTrigger ControlID="btnExport" />
        </Triggers>
    </asp:UpdatePanel>
    </form>
</body>
</html>

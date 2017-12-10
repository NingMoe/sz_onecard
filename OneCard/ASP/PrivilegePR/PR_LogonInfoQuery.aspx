<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PR_LogonInfoQuery.aspx.cs" Inherits="ASP_PrivilegePR_PR_LogonInfoQuery" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>登录信息查询</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="../../js/myext.js"></script>
    <script type="text/javascript" src="../../js/mootools.js"></script>
    <script type="text/javascript" src="../../js/jquery-1.5.min.js"></script>
    <script type="text/javascript" src="../../js/Window.js"></script>

</head>
<body>
    <form id="form1" runat="server">
        <div class="tb">
            个人业务->登录信息查询
        </div>
        <ajaxToolkit:ToolkitScriptManager EnableScriptGlobalization="true" EnableScriptLocalization="true" ID="ScriptManager1" runat="server" />
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
                    <div class="base">查询</div>
                    <div class="kuang5">
                        <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                            <tr>
                                <td width="8%">
                                    <div align="right">员工号:</div>
                                </td>
                                <td width="14%">
                                    <asp:TextBox ID="txtStaffNo" CssClass="input" runat="server" MaxLength="6" />
                                </td>
                                <td width="12%">
                                    <div align="right">
                                        开始日期:
                                    </div>
                                </td>
                                <td width="12%">
                                    <asp:TextBox runat="server" ID="txtFromDate" MaxLength="8" CssClass="input"></asp:TextBox>
                                    <ajaxToolkit:CalendarExtender ID="CalendarExtender1" runat="server" TargetControlID="txtFromDate" Format="yyyyMMdd" />
                                </td>
                                <td width="12%">
                                    <div align="right">
                                        结束日期:
                                    </div>
                                </td>
                                <td width="12%">
                                    <asp:TextBox runat="server" ID="txtToDate" MaxLength="8" CssClass="input"></asp:TextBox>
                                    <ajaxToolkit:CalendarExtender ID="CalendarExtender2" runat="server" TargetControlID="txtToDate" Format="yyyyMMdd" />
                                </td>
                            </tr>
                            <tr>
                                <td colspan="8" align="right">
                                    <asp:Button ID="btnQuery" CssClass="button1" runat="server" Text="查询" OnClick="btnQuery_Click" />
                                </td>
                            </tr>
                        </table>
                    </div>
                    <div class="jieguo">日志记录</div>
                    <div class="kuang5">
                        <div class="gdtb" style="height: 300px; overflow: auto; display: block">
                            <asp:GridView ID="gvResult" CssClass="tab2" HeaderStyle-CssClass="tabbt" FooterStyle-CssClass="tabcon"
                                AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel" PagerSettings-Mode="NumericFirstLast"
                                PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top" runat="server"
                                AutoGenerateColumns="false" Width="100%"
                                AllowPaging="true" PageSize="20" OnPageIndexChanging="gvResult_Page">
                                <Columns>
                                    <asp:BoundField HeaderText="部门号" DataField="DEPARTNO" />
                                    <asp:BoundField HeaderText="员工号" DataField="STAFFNO" />
                                    <asp:BoundField HeaderText="操作员卡号" DataField="OPERCARDNO" />
                                    <asp:BoundField HeaderText="IP地址" DataField="IPADDR" />
                                    <asp:BoundField HeaderText="登录时间" DataField="LOGONTIME" />
                                </Columns>
                                <EmptyDataTemplate>
                                    <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                        <tr class="tabbt">
                                            <td>部门号</td>
                                            <td>员工号</td>
                                            <td>操作员卡号</td>
                                            <td>IP地址</td>
                                            <td>登录时间</td>
                                        </tr>
                                    </table>
                                </EmptyDataTemplate>
                            </asp:GridView>
                        </div>
                    </div>

                </div>
            </ContentTemplate>
        </asp:UpdatePanel>

    </form>
</body>
</html>

<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PN_QuerySync.aspx.cs" Inherits="ASP_ProvisionNote_PN_QuerySync" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>接口查询</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <script type="text/javascript" src="../../js/print.js"></script>
    <script type="text/javascript" src="../../js/myext.js"></script>
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
    <div class="tb">
        备付金管理->接口查询
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
    <asp:UpdatePanel ID="UpdatePanel2" runat="server">
        <ContentTemplate>
            <!-- #include file="../../ErrorMsg.inc" -->
            <div class="con">
                <div class="card">
                    查询</div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td>
                                <div align="right">
                                    开始日期:</div>
                            </td>
                            <td>
                                <asp:TextBox runat="server" ID="txtFromDate" MaxLength="8" CssClass="input"></asp:TextBox>
                                <ajaxToolkit:CalendarExtender ID="FCalendar1" runat="server" TargetControlID="txtFromDate"
                                    Format="yyyyMMdd" />
                            </td>
                            <td>
                                <div align="right">
                                    结束日期:</div>
                            </td>
                            <td>
                                <asp:TextBox runat="server" ID="txtToDate" MaxLength="8" CssClass="input"></asp:TextBox>
                                <ajaxToolkit:CalendarExtender ID="FCalendar2" runat="server" TargetControlID="txtToDate"
                                    Format="yyyyMMdd" />
                            </td>
                            <td>
                                <div align="right">
                                    同步状态:</div>
                            </td>
                            <td>
                                <asp:DropDownList ID="selFileCode" CssClass="inputmid" runat="server">
                                    <asp:ListItem Text="---请选择---" Value=""></asp:ListItem>
                                    <asp:ListItem Text="0:未同步" Value="0"></asp:ListItem>
                                    <asp:ListItem Text="1:同步成功" Value="1"></asp:ListItem>
                                    <asp:ListItem Text="2:同步失败" Value="2" Selected="True"></asp:ListItem>
                                </asp:DropDownList>
                            </td>
                            <td align="right">
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    同步发起方:</div>
                            </td>
                            <td>
                                <asp:DropDownList ID="selBank" CssClass="inputmid" runat="server">
                                </asp:DropDownList>
                            </td>
                            <td>
                                <div align="right">
                                    同步类型:</div>
                            </td>
                            <td>
                                <asp:DropDownList ID="selSyncTypeCode" CssClass="inputmid" runat="server">
                                    <asp:ListItem Text="---请选择---" Value=""></asp:ListItem>
                                    <asp:ListItem Text="0:上传" Value="2101"></asp:ListItem>
                                    <asp:ListItem Text="1:下载" Value="2102"></asp:ListItem>
                                </asp:DropDownList>
                            </td>
                            <td>
                            </td>
                            <td>
                                <asp:Button ID="Button1" CssClass="button1" runat="server" Text="查询" OnClick="btnQuery_Click" />
                            </td>
                        </tr>
                    </table>
                </div>
                <table border="0" width="95%">
                    <tr>
                        <td align="left">
                            <div class="jieguo">
                                查询结果</div>
                        </td>
                        <td align="right">
                            <asp:Button ID="btnExport" CssClass="button1" runat="server" Text="导出Excel" OnClick="btnExport_Click" />
                            <asp:Button ID="btnPrint" CssClass="button1" runat="server" Text="打印" OnClientClick="return printGridView('printarea');" />
                        </td>
                    </tr>
                </table>
                <div id="printarea" class="kuang5">
                    <div style="height: 380px;overflow:auto;">
                        <asp:GridView ID="gvResult" runat="server" Width="200%" CssClass="tab2" HeaderStyle-CssClass="tabbt"
                            FooterStyle-CssClass="tabcon" AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel"
                            PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top">
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                        <td width="8%">
                                            同步流水号
                                        </td>
                                        <td width="5%">
                                            同步类型
                                        </td>
                                        <td width="5%">
                                            同步状态
                                        </td>
                                        <td width="5%">
                                            文件类型
                                        </td>
                                        <td width="8%">
                                            同步发起方
                                        </td>
                                        <td width="15%">
                                            同步异常信息
                                        </td>
                                        <td width="8%">
                                            同步完成时间
                                        </td>
                                        <td width="5%">
                                            文件名
                                        </td>
                                        <td width="8%">
                                            文件处理结果
                                        </td>
                                        <td width="10%">
                                            文件处理完成时间
                                        </td>
                                        <td width="10%">
                                            文件处理异常信息
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

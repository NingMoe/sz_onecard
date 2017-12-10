<%@ Page Language="C#" AutoEventWireup="true" CodeFile="RM_QueryResourceList.aspx.cs"
    Inherits="ASP_ResourceManage_RM_QueryResourceList" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>资源库存明细</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="../../js/myext.js"></script>
</head>
<body>
    <form id="form1" runat="server">
    <div class="tb">
        其他资源管理->资源库存明细
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
                    查询</div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td width="15%">
                                <div align="right">
                                    资源类型:</div>
                            </td>
                            <td width="15%">
                                <asp:DropDownList ID="ddlResourceType" runat="server" OnSelectedIndexChanged="ddlResourceType_SelectIndexChange"
                                    AutoPostBack="true">
                                </asp:DropDownList>
                            </td>
                            <td width="15%">
                                <div align="right">
                                    资源名称:</div>
                            </td>
                            <td width="15%">
                                <asp:DropDownList ID="ddlResource" runat="server">
                                </asp:DropDownList>
                            </td>
                            <td width="15%">
                                <div align="right">
                                    网点:</div>
                            </td>
                            <td width="15%">
                                <asp:DropDownList ID="selDept" CssClass="input" runat="server">
                                </asp:DropDownList>
                            </td>
                            <td align="right">
                                <asp:Button ID="btnQuery" CssClass="button1" runat="server" Text="查询" OnClick="btnQuery_Click" />
                            </td>
                        </tr>
                    </table>
                </div>
                <div class="jieguo">
                    资源库存明细</div>
                <div class="kuang5">
                    <div id="gvUseCard" style="height: 350px; overflow: auto; display: block">
                        <asp:GridView ID="gvResult" runat="server" Width="100%" CssClass="tab1" HeaderStyle-CssClass="tabbt"
                            FooterStyle-CssClass="tabcon" AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel"
                            PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top"
                            AutoGenerateColumns="true" OnRowDataBound="gvResult_RowDataBound">
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
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
                                            网点
                                        </td>
                                        <td>
                                            营业员
                                        </td>
                                        <td>
                                            领用时间
                                        </td>
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

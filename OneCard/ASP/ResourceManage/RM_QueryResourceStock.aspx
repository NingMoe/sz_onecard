<%@ Page Language="C#" AutoEventWireup="true" CodeFile="RM_QueryResourceStock.aspx.cs"
    Inherits="ASP_ResourceManage_RM_QueryResourceStock" EnableEventValidation="false" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>库存查询</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <script src="../../js/jquery-1.5.min.js" type="text/javascript"></script>
    <script type="text/javascript" src="../../js/print.js"></script>
    <script type="text/javascript" src="../../js/myext.js"></script>
    <script type="text/javascript" src="../../js/RMHelper.js"></script>
    <script type="text/javascript" src="../../js/Window.js"></script>
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" language="javascript">
        function gvOnSelected() {
            ondisplay.style.display = "block";
            pipinfo2.style.width = "65%";
        }

        function gvUnSelected() {
            ondisplay.style.display = "none";
            pipinfo2.style.width = "99%";
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
    <div class="tb">
        其他资源管理->库存查询
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
                            <td colspan="4">
                                <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                                    <tr id="trUsecard" style="display: block;">
                                        <td width="25%">
                                            <div align="right">
                                                资源类型:</div>
                                        </td>
                                        <td width="25%">
                                            <asp:DropDownList ID="ddlResourceType" CssClass="inputmid" runat="server" OnSelectedIndexChanged="ddlResourceType_SelectIndexChange"
                                                AutoPostBack="true">
                                            </asp:DropDownList>
                                        </td>
                                        <td width="25%">
                                            <div align="right">
                                                资源名称:</div>
                                        </td>
                                        <td width="25%">
                                            <asp:DropDownList ID="ddlResource" CssClass="inputmid" runat="server">
                                            </asp:DropDownList>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                           <%-- <td>
                                <div align="right">
                                    资源状态:</div>
                            </td>
                            <td>
                                <asp:DropDownList ID="selSellType" CssClass="input" runat="server">
                                    <asp:ListItem Text="01: 出入库" Value="01"></asp:ListItem>
                                    <asp:ListItem Text="02: 下单" Value="02"></asp:ListItem>
                                </asp:DropDownList>
                            </td>--%>
                            <td align="right">
                                <asp:Button ID="btnQuery" CssClass="button1" runat="server" Text="查询" OnClick="btnQuery_Click" />
                            </td>
                            <td>
                            </td>
                        </tr>
                    </table>
                </div>
            </div>
            <div id="pipinfo2" class="pipinfo2" style="width: 65%">
                <div class="jieguo">
                    查询结果</div>
                <div class="kuang5">
                    <div id="usecardgv" style="height: 350px; display: block; overflow: auto">
                        <asp:GridView ID="gvResultUseCard1" runat="server" Width="95%" CssClass="tab1" HeaderStyle-CssClass="tabbt"
                            FooterStyle-CssClass="tabcon" AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel"
                            PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top"
                            AutoGenerateColumns="true" OnRowDataBound="gv_RowDataBound" OnSelectedIndexChanged="gvResultUseCard1_SelectedIndexChanged"
                            OnRowCreated="gvResultUseCard1_RowCreated" OnRowCommand="gvResultUseCard1_RowCommand">
                            <SelectedRowStyle CssClass="tabsel" />
                        </asp:GridView>
                        <asp:GridView ID="gvResultUseCard2" runat="server" Width="95%" CssClass="tab1" HeaderStyle-CssClass="tabbt"
                            FooterStyle-CssClass="tabcon" AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel"
                            PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top"
                            AutoGenerateColumns="true" OnRowDataBound="gv_RowDataBound">
                            <SelectedRowStyle CssClass="tabsel" />
                        </asp:GridView>
                    </div>
                </div>
            </div>
            <div id="ondisplay" class="basicinfo2" style="margin-left: 66.3%; overflow: auto">
                <div class="jieguo">
                    部门剩余数量</div>
                <div class="kuang5">
                    <div id="Div1" style="height: 350px; display: block; overflow: auto">
                        <asp:GridView ID="gvUser" runat="server" Width="95%" CssClass="tab1" HeaderStyle-CssClass="tabbt"
                            FooterStyle-CssClass="tabcon" AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel"
                            PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top"
                            AutoGenerateColumns="true">
                        </asp:GridView>
                    </div>
                </div>
            </div>
            <div id="RoleWindow" style="width: 670px; position: absolute; display: none; z-index: 999;">
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
    </form>
</body>
</html>

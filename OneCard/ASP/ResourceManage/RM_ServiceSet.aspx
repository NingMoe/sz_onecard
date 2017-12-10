<%@ Page Language="C#" AutoEventWireup="true" CodeFile="RM_ServiceSet.aspx.cs" Inherits="ASP_ResourceManage_RM_ServiceSet" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>服务参数配置</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="../../js/myext.js"></script>
</head>
<body>
    <form id="form1" runat="server">
    <div class="tb">
        其他资源管理->服务参数配置
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
                    服务参数配置</div>
                <div class="kuang5">
                    <table id="supplyUseCard" width="95%" border="0" cellpadding="0" cellspacing="0"
                        class="text25" style="display: block">
                        <tr>
                            <th style="width: 10%; text-align: right">
                                服务情况：
                            </th>
                            <td style="width: 50%">
                                &nbsp;&nbsp;&nbsp;<asp:Label ID="lblServiceStatus" runat="server" Text=""></asp:Label>
                            </td>
                            <td align="center">
                                <asp:Button ID="btnServiceRefresh" runat="server" CssClass="button1" Text="刷新" OnClick="btnServiceRefresh_Click" />
                            </td>
                        </tr>
                        <tr>
                            <th style="text-align: right">
                                轮询时间：
                            </th>
                            <td colspan="2">
                                &nbsp;&nbsp;&nbsp;
                                <asp:TextBox ID="txtRecycleTime" runat="server" CssClass="input">
                                </asp:TextBox>&nbsp;S
                            </td>
                        </tr>
                        <tr>
                            <th style="text-align: right">
                                启动/停止：
                            </th>
                            <td colspan="2">
                                &nbsp;&nbsp;&nbsp;
                                <asp:CheckBox ID="cbStart" runat="server" />
                            </td>
                        </tr>
                        <tr>
                            <th style="text-align: right">
                                私钥：
                            </th>
                            <td>
                                &nbsp;&nbsp;&nbsp;
                                <asp:FileUpload ID="FileUpload1" runat="server" CssClass="inputlong" />
                            </td>
                            <td>
                                &nbsp;</td>
                        </tr>
                    </table>
                </div>
            </div>
            <div class="footall">
            </div>
            <div class="btns">
                <table width="325" border="0" align="right" cellpadding="0" cellspacing="0">
                    <tr>
                        <td>
                            <asp:Button ID="btnServiceModify" runat="server" CssClass="button1"
                                Text="修改" OnClick="btnServiceModify_Click" />
                        </td>
                        <td>
                        </td>
                    </tr>
                </table>
            </div>
            <div style="display: none" runat="server" id="printarea">
            </div>
        </ContentTemplate>
        <Triggers>
            <asp:PostBackTrigger ControlID="btnServiceModify" />
        </Triggers>
    </asp:UpdatePanel>
    </form>
</body>
</html>

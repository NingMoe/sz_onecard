<%@ Page Language="C#" AutoEventWireup="true" CodeFile="RM_KeyMaintain.aspx.cs" Inherits="ASP_ResourceManage_RM_KeyMaintain"
    EnableEventValidation="false" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <%--<link rel="stylesheet" type="text/css" href="../../css/frame.css" />--%>
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="../../js/myext.js"></script>
    <script type="text/javascript" src="../../js/RMHelper.js"></script>
    <script type="text/javascript" src="../../js/printorder.js"></script>
    <script src="../../js/jquery-1.5.min.js" type="text/javascript"></script>
    <script type="text/javascript" src="../../js/Window.js"></script>
    <title>厂家公私钥维护</title>
    <style type="text/css">
        table.data
        {
            font-size: 90%;
            border-collapse: collapse;
            border: 0px solid black;
        }
        table.data th
        {
            background: #bddeff;
            width: 25em;
            text-align: left;
            padding-right: 8px;
            font-weight: normal;
            border: 1px solid black;
        }
        table.data td
        {
            background: #ffffff;
            vertical-align: middle;
            padding: 0px 2px 0px 2px;
            border: 1px solid black;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
    <div class="tb">
        卡片管理->厂家公私钥维护
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
                            <td width="12%">
                            </td>
                            <td width="12%">
                                &nbsp;
                            </td>
                            <td width="12%">
                            </td>
                            <td width="12%">
                            </td>
                            <td width="12%">
                            </td>
                            <td width="12%">
                            </td>
                            <td width="12%">
                            </td>
                            <td width="12%">
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    卡片厂商:</div>
                            </td>
                            <td>
                                <asp:DropDownList ID="ddlProducer" CssClass="input" runat="server">
                                </asp:DropDownList>
                            </td>
                            <td>
                            </td>
                            <%--<td width="15%" align="right">
                                <asp:Button ID="btnQuery" CssClass="button1" runat="server" Text="查询" OnClick="btnQuery_Click" />
                            </td>  --%>
                        </tr>
                        <tr>
                            <th style="text-align: right">
                                私钥：
                            </th>
                            <td colspan='2'>
                                <asp:FileUpload ID="FileUpload1" runat="server" CssClass="inputlong" />
                                <%--<asp:Button ID="btnUpload" CssClass="button1" runat="server" Text="导入" OnClick="btnUpload_Click" />--%>
                            </td>
                            <td>
                                <asp:Label ID="lblMessage" runat="server" Text=""></asp:Label>
                            </td>
                        </tr>
                        <tr>
                            <td width="50%" colspan='2' align="right">
                                <asp:Button ID="btnQuery" CssClass="button1" runat="server" Text="查询" OnClick="btnQuery_Click" />
                                <asp:Button ID="btnCreate" CssClass="button1" runat="server" Text="生成公私钥对" OnClick="btnCreate_Click"
                                    Width="90px" />
                            </td>
                        </tr>
                    </table>
                </div>
                <div class="jieguo">
                    查询结果</div>
                <div class="kuang5">
                    <div id="gvSupplyCard" style="height: 250px; overflow: auto; display: block">
                        <asp:GridView ID="gvResult" runat="server" Width="100%" CssClass="tab1" HeaderStyle-CssClass="tabbt"
                            FooterStyle-CssClass="tabcon" AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel"
                            PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top"
                            AutoGenerateColumns="false" OnRowCreated="gvResult_RowCreated" OnSelectedIndexChanged="gvResult_SelectedIndexChanged">
                            <Columns>
                                <asp:BoundField DataField="ID" HeaderText="公私钥对索引" />
                                <%--<asp:TemplateField>
                                <HeaderTemplate>
                                <asp:Label ID = "headerText" Text = "公钥"  runat="server"></asp:Label>
                                </HeaderTemplate>
                                    <ItemTemplate> 
                                        
                                        <asp:Button ID="btnPublicDownload" Enabled="true" Width="60px" CssClass="button1" runat="server"
                                            Text="下载" CommandArgument='<%# Container.DataItemIndex%>' OnClick = "btnPublicDownload_Click"/>
                                            <asp:HiddenField ID ="hidPublicKey"  runat="server" Value='<%#Eval("PUBLICKEY")%>' />
                                    </ItemTemplate> 
                                </asp:TemplateField>--%>
                                <asp:BoundField DataField="OPERATETIME" HeaderText="生成时间" />
                                <asp:BoundField DataField="PRODUCER" HeaderText="卡片厂商" />
                                <asp:TemplateField>
                                    <HeaderTemplate>
                                        <asp:Label ID="headerText2" Text="私钥" runat="server"></asp:Label>
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                        <asp:Button ID="btnPrivateDownload" Enabled="true" Width="60px" CssClass="button1"
                                            runat="server" Text="下载" CommandArgument='<%# Container.DataItemIndex%>' OnClick="btnPrivateDownload_Click" />
                                        <asp:HiddenField ID="hidPrivateKey" runat="server" Value='<%#Eval("PRIVATEKEY")%>' />
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                        <td>
                                            公私钥对索引
                                        </td>
                                        <td>
                                            生成时间
                                        </td>
                                        <td>
                                            卡片厂商
                                        </td>
                                        <td>
                                            私钥
                                        </td>
                                    </tr>
                                </table>
                            </EmptyDataTemplate>
                        </asp:GridView>
                    </div>
                </div>
                <div class="card">
                    公私钥信息</div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td width="12%">
                            </td>
                            <td width="12%">
                            </td>
                            <td width="12%">
                            </td>
                            <td width="12%">
                            </td>
                            <td width="12%">
                            </td>
                            <td width="12%">
                            </td>
                            <td width="12%">
                            </td>
                            <td width="12%">
                            </td>
                        </tr>
                        <tr id="supplyUseCard" style="display: block">
                            <td width="12%">
                                <div align="right">
                                    公私钥对索引:</div>
                            </td>
                            <td width="36%" colspan="3">
                                <asp:Label ID="Label1" runat="server" Text="">
                                </asp:Label>
                            </td>
                            <td width="12%">
                                <div align="right">
                                    卡片厂商:</div>
                            </td>
                            <td width="36%" colspan="3">
                                <asp:DropDownList ID="selProducer" CssClass="inputmid" runat="server">
                                </asp:DropDownList>
                                <span class="red">*</span>
                            </td>
                        </tr>
                        <tr>
                            <td colspan="7" align="right">
                                <asp:Button ID="btnModify" Text="修改" CssClass="button1" runat="server" OnClick="btnModify_Click" />
                            </td>
                        </tr>
                    </table>
                </div>
            </div>
        </ContentTemplate>
        <Triggers>
            <asp:PostBackTrigger ControlID="btnQuery" />
            <asp:PostBackTrigger ControlID="btnCreate" />
            <asp:PostBackTrigger ControlID="btnModify" />
        </Triggers>
    </asp:UpdatePanel>
    </form>
</body>
</html>

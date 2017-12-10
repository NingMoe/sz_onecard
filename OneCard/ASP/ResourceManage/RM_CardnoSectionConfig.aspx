<%@ Page Language="C#" AutoEventWireup="true" CodeFile="RM_CardnoSectionConfig.aspx.cs" Inherits="ASP_ResourceManage_RM_CardnoSectionConfig" EnableEventValidation="false"%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>下单号段配置</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <script type="text/javascript" src="../../js/print.js"></script>
    <script type="text/javascript" src="../../js/myext.js"></script>
    <script type="text/javascript" src="../../js/RMHelper.js"></script>
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
    <div class="tb">
        卡片管理->下单号段配置
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
                            <td width="24%">
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="text25">
                                    <tr>
                                        <td>
                                            <td width="50%">
                                                <div align="right">
                                                    卡片类型:</div>
                                            </td>
                                            <td width="50%">
                                                <asp:DropDownList ID="selCardType" CssClass="inputmid" runat="server">
                                                </asp:DropDownList>
                                            </td>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                            <td width="12%">
                            </td>
                            <td width="12%">
                            </td>
                            <td width="12%">
                            </td>
                            <td width="12%" align="right">
                                <asp:Button ID="btnQuery" CssClass="button1" runat="server" Text="查询" OnClick="btnQuery_Click" />
                            </td>
                            <td width="12%">
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
                    </tr>
                </table>
                <div class="kuang5">
                    <div id="gvUseCard" style="height: 250px; display: block; overflow: auto;" >
                        <asp:GridView ID="gvResult" runat="server" Width="95%" CssClass="tab1" HeaderStyle-CssClass="tabbt"
                            FooterStyle-CssClass="tabcon" AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel"
                            PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top"
                            AutoGenerateColumns="true" OnRowDataBound="gvResult_RowDataBound" 
                            OnSelectedIndexChanged="gvResult_SelectedIndexChanged" OnRowCreated="gvResult_RowCreated">
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                        <td>
                                            卡片类型
                                        </td>
                                        <td>
                                            起始号码
                                        </td>
                                        <td>
                                            结束号码
                                        </td>
                                    </tr>
                                </table>
                            </EmptyDataTemplate>
                        </asp:GridView>
                    </div>
                </div>
                <div class="card">
                    号段分配</div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td width="24%">
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="text25">
                                    <tr>
                                        <td>
                                            <td width="50%">
                                                <div align="right">
                                                    卡片类型:</div>
                                            </td>
                                            <td width="50%">
                                                <asp:DropDownList ID="InCardType" CssClass="inputmid" runat="server">
                                                </asp:DropDownList>
                                            </td>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                            <td width="12%">
                            </td>
                            <td width="12%">
                                <div align="right">
                                    8位号段:</div>
                            </td>
                            <td width="36%" colspan="3">
                                <asp:TextBox ID="txtFromCardNo" CssClass="input" runat="server" MaxLength="8"></asp:TextBox>
                                -
                                <asp:TextBox ID="txtToCardNo" CssClass="input" runat="server" MaxLength="8"></asp:TextBox><span class="red">*</span>
                            </td>
                        </tr>
                    </table>
                </div>
            </div>
            <div class="pipinfo2" style="width: 50%" visible="false" id="divCardnoUsed" runat="server">
                <div class="card">
                    已用卡号段</div>
                <div class="kuang5">
                    <div class="gdtb" style="height: 200px; overflow: auto">
                        <asp:GridView ID="gvCardnoUsed" runat="server" Width="95%" CssClass="tab1" HeaderStyle-CssClass="tabbt"
                            FooterStyle-CssClass="tabcon" AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel"
                            PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top"
                            AutoGenerateColumns="False" >
                            <Columns>
                                <asp:BoundField DataField="startcardno" HeaderText="起始卡号" />
                                <asp:BoundField DataField="endcardno" HeaderText="结束卡号" />
                                <asp:BoundField DataField="cardnum" HeaderText="数量" />
                            </Columns>
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                        <td>
                                            起始卡号
                                        </td>
                                        <td>
                                            结束卡号
                                        </td>
                                        <td>
                                            数量
                                        </td>
                                    </tr>
                                </table>
                            </EmptyDataTemplate>
                        </asp:GridView>
                    </div>
                </div>
            </div>
            <div class="basicinfo2" style="margin-left: 51.3%"  visible="false"  id="divCardnoAvailable" runat="server">
                <div class="card">
                    可用卡号段</div>
                <div class="kuang5">
                    <div class="gdtb" style="height: 200px; overflow: auto">
                        <asp:GridView ID="gvCardnoAvailable" runat="server" Width="95%" CssClass="tab1" HeaderStyle-CssClass="tabbt"
                            FooterStyle-CssClass="tabcon" AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel"
                            PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top"
                            AutoGenerateColumns="False" >
                            <Columns>
                                <asp:BoundField DataField="startcardno" HeaderText="起始卡号" />
                                <asp:BoundField DataField="endcardno" HeaderText="结束卡号" />
                                <asp:BoundField DataField="cardnum" HeaderText="数量" />
                            </Columns>
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                        <td>
                                            起始卡号
                                        </td>
                                        <td>
                                            结束卡号
                                        </td>
                                        <td>
                                            数量
                                        </td>
                                    </tr>
                                </table>
                            </EmptyDataTemplate>
                        </asp:GridView>
                    </div>
                </div>
            </div>
            <div class="btns">
                <table width="95%" border="0" cellpadding="0" cellspacing="0">
                    <tr>
                        <td width="12%">
                        </td>
                        <td width="12%">
                        </td>
                        <td width="12%">
                        </td>
                        <td width="12%">
                        </td>
                        <td width="48%" align="right">
                            <asp:Button ID="btnAdd" Enabled="true" CssClass="button1" runat="server" Text="添加"
                                OnClick="btnAdd_Click" />
                            &nbsp;&nbsp;
                            <asp:Button ID="btnModify" Enabled="true" CssClass="button1" runat="server" Text="修改"
                                OnClick="btnModify_Click" />
                            &nbsp;&nbsp;
                            <asp:Button ID="btnCancel" Enabled="true" CssClass="button1" runat="server" Text="删除"
                                OnClick="btnCancel_Click" />
                            &nbsp;&nbsp;
                            <asp:Button ID="btnDetail" Enabled="false" CssClass="button1" runat="server" Text="详细号段"
                                OnClick="btnDetail_Click" />
                             <asp:Button ID="btnAuto" Enabled="true" CssClass="button1" runat="server" Text="Auto"
                                OnClick="btnAuto_Click" />
                        </td>
                        <td width="12%">
                        </td>
                    </tr>
                </table>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
    </form>
</body>
</html>

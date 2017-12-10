<%@ Page Language="C#" AutoEventWireup="true" CodeFile="RM_WarnConfig.aspx.cs" Inherits="ASP_ResourceManage_RM_WarnConfig"  EnableEventValidation="false"%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>库存查询配置</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <script type="text/javascript" src="../../js/print.js"></script>
    <script type="text/javascript" src="../../js/myext.js"></script>
    <script type="text/javascript" src="../../js/RMHelper.js"></script>
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" language="javascript">
        function SelectUseCard() {
            $get('hidCardType').value = "usecard";

            //提交部分，显示存货补货，其他隐藏
            supplyUseCard.style.display = "block";
            supplyChargeCard.style.display = "none";
            //Gridview部分，显示充值卡，其他隐藏
            gvUseCard.style.display = "block";
            gvChargeCard.style.display = "none";

            usecard.className = "on";
            chargecard.className = null;

            return false;
        }
        function SelectChargeCard() {
            $get('hidCardType').value = "chargecard";

            //提交部分，显示充值卡，其他隐藏
            supplyUseCard.style.display = "none";
            supplyChargeCard.style.display = "block";
            //Gridview部分，显示充值卡，其他隐藏
            gvUseCard.style.display = "none";
            gvChargeCard.style.display = "block";

            usecard.className = null;
            chargecard.className = "on";

            return false;
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
    <div class="tb">
        卡片管理->库存查询配置
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
            <asp:HiddenField ID="hidCardType" runat="server" />
            <div style="height: 22px">
                <table>
                    <tr>
                        <td width="10%">
                        </td>
                        <td align="center">
                            <ul class="nav_list">
                                <li runat="server" id="liusecard" visible="true">
                                    <asp:LinkButton ID="usecard" Target="_top" CssClass="on" runat="server" onmouseover="mover(this);"
                                        onmouseout="mout();" OnClientClick="return SelectUseCard()"><span class="signA">用户卡</span></asp:LinkButton></li>
                                <li runat="server" id="lichargecard" visible="true">
                                    <asp:LinkButton ID="chargecard" Target="_top" runat="server" onmouseover="mover(this);"
                                        onmouseout="mout();" OnClientClick="return SelectChargeCard()"><span class="signB">充值卡</span></asp:LinkButton></li>
                            </ul>
                        </td>
                    </tr>
                </table>
            </div>
            <div class="con">
                <div class="card">
                    查询</div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td width="56%">
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="text25">
                                    <tr id="supplyUseCard" style="display: block;">
                                        <td width="25%">
                                            <div align="right">
                                                卡片类型:</div>
                                        </td>
                                        <td width="25%">
                                            <asp:DropDownList ID="selCardType" CssClass="inputmid" runat="server" AutoPostBack="true" OnSelectedIndexChanged="selCardType_change">
                                            </asp:DropDownList>
                                        </td>
                                        <td width="25%">
                                            <div align="right">
                                                卡面类型:</div>
                                        </td>
                                        <td width="25%">
                                            <asp:DropDownList ID="selCardFaceType" CssClass="inputmid" Width="200px" runat="server">
                                            </asp:DropDownList>
                                        </td>
                                    </tr>
                                    <tr id="supplyChargeCard" style="display: none;">
                                        <td width="25%">
                                            <div align="right">
                                                面值:</div>
                                        </td>
                                        <td width="75%" colspan="3">
                                            <asp:DropDownList ID="selCardMoney" CssClass="input" runat="server">
                                            </asp:DropDownList>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                            <td width="14%">
                                <div align="right">
                                    是否过滤:</div>
                            </td>
                            <td width="14%">
                                <asp:DropDownList ID="selWarnType" CssClass="input" runat="server">
                                    <asp:ListItem Text="0: 不过滤" Value="0"></asp:ListItem>
                                    <asp:ListItem Text="1: 过滤" Value="1"></asp:ListItem>
                                </asp:DropDownList>
                            </td>
                            <td width="14%" align="right">
                                <asp:Button ID="btnQuery" CssClass="button1" runat="server" Text="查询" OnClick="btnQuery_Click" />
                            </td>
                        </tr>
                    </table>
                </div>
                <div class="jieguo">
                    查询结果</div>
                <div class="kuang5">
                    <div id="gvUseCard" style="display: block">
                        <asp:GridView ID="gvResultUseCard" runat="server" Width="95%" CssClass="tab1" HeaderStyle-CssClass="tabbt"
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
                                <asp:BoundField DataField="卡片类型" HeaderText="卡片类型" />
                                <asp:BoundField DataField="卡面类型" HeaderText="卡面类型" />
                            </Columns>
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                        <td>
                                            卡片类型
                                        </td>
                                        <td>
                                            卡面类型
                                        </td>
                                    </tr>
                                </table>
                            </EmptyDataTemplate>
                        </asp:GridView>
                    </div>
                    <div id="gvChargeCard" style="display: none">
                        <asp:GridView ID="gvResultChargeCard" runat="server" Width="95%" CssClass="tab1"
                            HeaderStyle-CssClass="tabbt" FooterStyle-CssClass="tabcon" AlternatingRowStyle-CssClass="tabjg"
                            SelectedRowStyle-CssClass="tabsel" PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left"
                            PagerStyle-VerticalAlign="Top" AutoGenerateColumns="false">
                             <Columns>
                                <asp:TemplateField>
                                    <HeaderTemplate>
                                        <asp:CheckBox ID="CheckBox1" runat="server" AutoPostBack="true" OnCheckedChanged="CheckChargeCardAll" />
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                        <asp:CheckBox ID="ItemCheckBox" runat="server" />
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField DataField="面值" HeaderText="面值" />
                            </Columns>
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                        <td>
                                            面值
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
                        <td width="12%">
                        </td>
                        <td width="12%">
                        </td>
                        <td width="12%" align="right">
                            <asp:Button ID="btnAddWarn" Enabled="true" CssClass="button1" runat="server" Text="添加过滤"
                                OnClick="btnAddWarn_Click" />
                        </td>
                        <td width="12%" align="left">
                            &nbsp;&nbsp;
                            <asp:Button ID="btnCancelWarn" Enabled="false" CssClass="button1" runat="server"
                                Text="取消过滤" OnClick="btnCancelWarn_Click" />
                        </td>
                    </tr>
                </table>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
    </form>
</body>
</html>

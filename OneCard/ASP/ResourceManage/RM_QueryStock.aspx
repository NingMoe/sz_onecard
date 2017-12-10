<%@ Page Language="C#" AutoEventWireup="true" CodeFile="RM_QueryStock.aspx.cs" Inherits="ASP_ResourceManage_RM_QueryStock"
    EnableEventValidation="false" %>

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
        function SelectUseCard() {
            $get('hidCardType').value = "usecard";

            trUsecard.style.display = "block";
            trChargeCard.style.display = "none";
            usecardgv.style.display = "block";
            chargecardgv.style.display = "none";
            Div1.style.display = "block";
            Div2.style.display = "none";
            usecard.className = "on";
            chargecard.className = null;

            return false;
        }
        function SelectChargeCard() {
            $get('hidCardType').value = "chargecard";

            trUsecard.style.display = "none";
            trChargeCard.style.display = "block";
            usecardgv.style.display = "none";
            chargecardgv.style.display = "block";
            Div1.style.display = "none";
            Div2.style.display = "block";
            usecard.className = null;
            chargecard.className = "on";

            return false;
        }
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
        卡片管理->库存查询
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
            <asp:HiddenField ID="hidSellType" runat="server" />
            <div style="height: 22px">
                <table>
                    <tr>
                        <td width="10%">
                        </td>
                        <td align="center">
                            <ul class="nav_list">
                                <li runat="server" id="liSupplyStock" visible="true">
                                    <asp:LinkButton ID="usecard" Target="_top" CssClass="on" runat="server" onmouseover="mover(this);"
                                        onmouseout="mout();" OnClientClick="return SelectUseCard()"><span class="signA">用户卡</span></asp:LinkButton></li>
                                <li runat="server" id="liNewCard" visible="true">
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
                            <td colspan="4">
                                <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                                    <tr id="trUsecard" style="display: block;">
                                        <td width="25%">
                                            <div align="right">
                                                卡片类型:</div>
                                        </td>
                                        <td width="25%">
                                            <asp:DropDownList ID="selCardType" CssClass="inputmid" runat="server" OnSelectedIndexChanged="selCardType_SelectedIndexChanged"
                                                AutoPostBack="true">
                                            </asp:DropDownList>
                                        </td>
                                        <td width="25%">
                                            <div align="right">
                                                卡面类型:</div>
                                        </td>
                                        <td width="25%">
                                            <asp:DropDownList ID="selCardFaceType" CssClass="inputmid" runat="server">
                                            </asp:DropDownList>
                                        </td>
                                    </tr>
                                    <tr id="trChargeCard" style="display: none;">
                                        <td width="25%">
                                            <div align="right">
                                                面值:</div>
                                        </td>
                                        <td width="25%">
                                            <asp:DropDownList ID="selCardMoney" CssClass="input" runat="server">
                                            </asp:DropDownList>
                                        </td>
                                        <td width="50%">
                                        </td>
                                    </tr>
                                </table>
                            </td>
                            <td>
                                <div align="right">
                                    卡片状态:</div>
                            </td>
                            <td>
                                <asp:DropDownList ID="selSellType" CssClass="input" runat="server">
                                    <asp:ListItem Text="01: 出入库" Value="01"></asp:ListItem>
                                    <asp:ListItem Text="02: 下单" Value="02"></asp:ListItem>
                                </asp:DropDownList>
                            </td>
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
                <table border="0" width="95%">
                    <tr>
                        <td align="left">
                            <div class="jieguo">
                                查询结果</div>
                        </td>
                        <td align="right">
                            <asp:Button ID="btnExportResult" CssClass="button1" runat="server" Text="导出Excel" OnClick="btnExportResult_Click" />
                        </td>
                    </tr>
                </table>
                <div class="kuang5">
                    <div id="usecardgv" style="height: 350px; display: block; overflow: auto">
                        <asp:GridView ID="gvResultUseCard1" runat="server" Width="95%" CssClass="tab1" HeaderStyle-CssClass="tabbt"
                            FooterStyle-CssClass="tabcon" AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel"
                            PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top"
                            AutoGenerateColumns="false" OnRowDataBound="gv_RowDataBound" OnSelectedIndexChanged="gvResultUseCard1_SelectedIndexChanged"
                            OnRowCreated="gvResultUseCard1_RowCreated" OnRowCommand="gvResultUseCard1_RowCommand">
                            <Columns>
                                <asp:BoundField HeaderText="卡片状态" DataField="卡片状态" />
                                <asp:BoundField HeaderText="卡片类型" DataField="卡片类型" />
                                <asp:BoundField HeaderText="卡面类型" DataField="卡面类型" />
                                <asp:BoundField HeaderText="入库数量" DataField="入库数量" />
                                <asp:BoundField HeaderText="出库数量" DataField="出库数量" />
                                <asp:BoundField HeaderText="回收数量" DataField="回收数量" />
                                <asp:BoundField HeaderText="卡样编码" DataField="卡样编码" />
                                <asp:TemplateField>
                                    <HeaderTemplate>
                                        <asp:Label ID="Label1" runat="server" Text="下单"></asp:Label>
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                        <asp:LinkButton ID="LinkButton1" runat="server" CausesValidation="true" CommandName="applyOrder"
                                            Text="下单" CommandArgument='<%# Eval("卡面类型")+";"+Eval("卡样编码").ToString()%>'>
                                        </asp:LinkButton>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField>
                                    <HeaderTemplate>
                                        <asp:Label ID="Label2" runat="server" Text="查看卡样"></asp:Label>
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                        <asp:LinkButton ID="linkSurFaceCode" runat="server" CausesValidation="true" CommandName="surFaceCode"
                                            Text='<%# Eval("卡样编码").ToString()==""?"":"查看卡样" %>' CommandArgument='<%# Eval("卡面类型")%>'>
                                        </asp:LinkButton>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                            <SelectedRowStyle CssClass="tabsel" />
                        </asp:GridView>
                        <asp:GridView ID="gvResultUseCard2" runat="server" Width="95%" CssClass="tab1" HeaderStyle-CssClass="tabbt"
                            FooterStyle-CssClass="tabcon" AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel"
                            PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top"
                            AutoGenerateColumns="true" OnRowDataBound="gv_RowDataBound">
                            <SelectedRowStyle CssClass="tabsel" />
                        </asp:GridView>
                    </div>
                    <div id="chargecardgv" style="height: 350px; display: none; overflow: auto">
                        <asp:GridView ID="gvResultChargeCard1" runat="server" Width="95%" CssClass="tab1"
                            HeaderStyle-CssClass="tabbt" FooterStyle-CssClass="tabcon" AlternatingRowStyle-CssClass="tabjg"
                            SelectedRowStyle-CssClass="tabsel" PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left"
                            PagerStyle-VerticalAlign="Top" AutoGenerateColumns="false" OnRowDataBound="gv_RowDataBound"
                            OnSelectedIndexChanged="gvResultChargeCard1_SelectedIndexChanged" OnRowCreated="gvResultChargeCard1_RowCreated"
                            OnRowCommand="gvResultChargeCard1_RowCommand">
                            <Columns>
                                <asp:BoundField HeaderText="卡片状态" DataField="卡片状态" />
                                <asp:BoundField HeaderText="面值" DataField="面值" />
                                <asp:BoundField HeaderText="入库数量" DataField="入库数量" />
                                <asp:BoundField HeaderText="出库数量" DataField="出库数量" />
                                <asp:TemplateField>
                                    <HeaderTemplate>
                                        <asp:Label ID="Label1" runat="server" Text="下单"></asp:Label>
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                        <asp:LinkButton ID="LinkButton1" runat="server" CausesValidation="true" CommandName="applyOrder"
                                            Text="下单" CommandArgument='<%# Eval("面值")%>'>
                                        </asp:LinkButton>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                            <SelectedRowStyle CssClass="tabsel" />
                        </asp:GridView>
                        <asp:GridView ID="gvResultChargeCard2" runat="server" Width="95%" CssClass="tab1"
                            HeaderStyle-CssClass="tabbt" FooterStyle-CssClass="tabcon" AlternatingRowStyle-CssClass="tabjg"
                            SelectedRowStyle-CssClass="tabsel" PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left"
                            PagerStyle-VerticalAlign="Top" AutoGenerateColumns="true" OnRowDataBound="gv_RowDataBound">
                            <SelectedRowStyle CssClass="tabsel" />
                        </asp:GridView>
                    </div>
                </div>
            </div>
            <div id="ondisplay" class="basicinfo2" style="margin-left: 66.3%; overflow: auto">
                <table border="0" width="95%">
                    <tr>
                        <td align="left">
                            <div class="jieguo">
                                网点剩余数量</div>
                        </td>
                        <td align="right">
                            <asp:Button ID="btnExportLeft" CssClass="button1" runat="server" Text="导出Excel" OnClick="btnExportLeft_Click" />
                        </td>
                    </tr>
                </table>
                <div class="kuang5">
                    <div id="Div1" style="height: 350px; display: block; overflow: auto">
                        <asp:GridView ID="gvUser" runat="server" Width="95%" CssClass="tab1" HeaderStyle-CssClass="tabbt"
                            FooterStyle-CssClass="tabcon" AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel"
                            PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top"
                            AutoGenerateColumns="true" >
                        </asp:GridView>
                    </div>
                    <div id="Div2" style="height: 350px; display: none; overflow: auto">
                        <asp:GridView ID="gvCharge" runat="server" Width="95%" CssClass="tab1" HeaderStyle-CssClass="tabbt"
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
        <Triggers>
            <asp:PostBackTrigger ControlID="btnExportResult" />
            <asp:PostBackTrigger ControlID="btnExportLeft" />
        </Triggers>
    </asp:UpdatePanel>
    </form>
</body>
</html>

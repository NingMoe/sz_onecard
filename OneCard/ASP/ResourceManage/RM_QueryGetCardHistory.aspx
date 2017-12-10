<%@ Page Language="C#" AutoEventWireup="true" CodeFile="RM_QueryGetCardHistory.aspx.cs"
    Inherits="ASP_ResourceManage_RM_QueryGetCardHistory" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>领用历史查询</title>
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
        卡片管理->领用历史查询
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
                            <td width="12%">
                                <div align="right">
                                    起始日期:</div>
                            </td>
                            <td width="12%">
                                <ajaxToolkit:CalendarExtender ID="BeginCalendar" runat="server" TargetControlID="txtStartDate"
                                    Format="yyyyMMdd" PopupPosition="BottomLeft" />
                                <asp:TextBox ID="txtStartDate" runat="server" CssClass="input" MaxLength="8"></asp:TextBox>
                            </td>
                            <td width="12%">
                                <div align="right">
                                    结束日期:</div>
                            </td>
                            <td width="12%">
                                <asp:TextBox ID="txtEndDate" runat="server" CssClass="input" MaxLength="8"></asp:TextBox>
                                <ajaxToolkit:CalendarExtender ID="CalendarExtender2" runat="server" TargetControlID="txtEndDate"
                                    Format="yyyyMMdd" PopupPosition="BottomLeft" />
                            </td>
                            <td width="12%">
                                <div align="right">
                                    领用部门:</div>
                            </td>
                            <td width="12%">
                                <asp:DropDownList ID="selDepart" CssClass="input" runat="server" OnSelectedIndexChanged="selDepart_SelectedIndexChanged"
                                    AutoPostBack="true">
                                </asp:DropDownList>
                            </td>
                            <td width="12%">
                                <div align="right">
                                    领用员工:</div>
                            </td>
                            <td width="12%">
                                <asp:DropDownList ID="selStaff" CssClass="input" runat="server">
                                </asp:DropDownList>
                            </td>
                        </tr>
                        <tr>
                            <td colspan="6">
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="text25">
                                    <tr id="supplyUseCard" style="display: block;">
                                        <td width="16.7%">
                                            <div align="right">
                                                卡片类型:</div>
                                        </td>
                                        <td width="16.7%">
                                            <asp:DropDownList ID="selCardType" CssClass="input" runat="server" AutoPostBack="true" OnSelectedIndexChanged="selCardType_change">
                                            </asp:DropDownList>
                                        </td>
                                        <td width="16.7%">
                                            <div align="right">
                                                卡面类型:</div>
                                        </td>
                                        <td width="16.7%">
                                            <asp:DropDownList ID="selCardFaceType" CssClass="input" runat="server">
                                            </asp:DropDownList>
                                        </td>
                                        <td width="16.7%">
                                            <div align="right">
                                                卡号:</div>
                                        </td>
                                        <td width="16.7%">
                                            <asp:TextBox ID="txtCardno" runat="server" CssClass="input" MaxLength="16"></asp:TextBox>
                                        </td>
                                    </tr>
                                    <tr id="supplyChargeCard" style="display: none;">
                                        <td width="16.7%">
                                            <div align="right">
                                                面值:</div>
                                        </td>
                                        <td width="16.7%">
                                            <asp:DropDownList ID="selCardMoney" CssClass="input" runat="server">
                                            </asp:DropDownList>
                                        </td>
                                        <td width="16.7%">
                                            <div align="right">
                                                卡号:</div>
                                        </td>
                                        <td width="16.7%">
                                            <asp:TextBox ID="txtChargeCardno" runat="server" CssClass="input" MaxLength="14"></asp:TextBox>
                                        </td>
                                        <td width="16.7%">
                                        </td>
                                        <td width="16.7%">
                                        </td>
                                    </tr>
                                </table>
                            </td>
                            <td>
                            </td>
                            <td align="left">
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
                            AllowPaging="true" PageSize="100" OnPageIndexChanging="gvResultUseCard_Page"
                            OnRowDataBound="gvResult_RowDataBound">
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                        <td>
                                            卡片类型
                                        </td>
                                        <td>
                                            卡面类型
                                        </td>
                                        <td>
                                            起始卡号
                                        </td>
                                        <td>
                                            终止卡号
                                        </td>
                                        <td>
                                            领用部门
                                        </td>
                                        <td>
                                            领用员工
                                        </td>
                                        <td>
                                            领用时间
                                        </td>
                                        <td>
                                            领用数量
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
                            PagerStyle-VerticalAlign="Top" OnPageIndexChanging="gvResultChargeCard_Page"
                            AllowPaging="true" PageSize="100" OnRowDataBound="gvResult_RowDataBound">
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                        <td>
                                            面值
                                        </td>
                                        <td>
                                            起始卡号
                                        </td>
                                        <td>
                                            终止卡号
                                        </td>
                                        <td>
                                            领用部门
                                        </td>
                                        <td>
                                            领用员工
                                        </td>
                                        <td>
                                            领用时间
                                        </td>
                                        <td>
                                            领用数量
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

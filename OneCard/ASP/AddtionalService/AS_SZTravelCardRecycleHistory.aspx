<%@ Page Language="C#" AutoEventWireup="true" CodeFile="AS_SZTravelCardRecycleHistory.aspx.cs"
    Inherits="ASP_AddtionalService_AS_SZTravelCardRecycleHistory" enableEventValidation="false"%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>旅游卡-回收查询</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />

    <script type="text/javascript" src="../../js/print.js"></script>

    <script type="text/javascript" src="../../js/myext.js"></script>

    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
    <ajaxToolkit:ToolkitScriptManager runat="Server" EnableScriptGlobalization="true"
        EnableScriptLocalization="true" ID="ScriptManager2" />

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

    <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
            <div class="tb">
                附加业务->旅游卡-回收查询
            </div>
            <asp:BulletedList ID="bulMsgShow" runat="server" />

            <script runat="server">public override void ErrorMsgShow() { ErrorMsgHelper(bulMsgShow); }

            </script>

            <div class="con">
                <div class="base">
                    查询条件</div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td width="15%">
                                <div align="right">
                                    卡号:</div>
                            </td>
                            <td width="15%">
                                <asp:TextBox ID="txtcardNo" CssClass="inputmid" runat="server" MaxLength="16"></asp:TextBox>
                            </td>
                            <td width="15%">
                                <div align="right">
                                    原所属部门:</div>
                            </td>
                            <td width="15%">
                                <asp:DropDownList ID="selOriginalDept" CssClass="inputmid" runat="server" AutoPostBack="true"
                                    OnSelectedIndexChanged="selOriginalDepts_SelectedIndexChanged">
                                </asp:DropDownList>
                            </td>
                            <td width="15%">
                                <div align="right">
                                    原所属员工:</div>
                            </td>
                            <td width="25%">
                                <asp:DropDownList ID="selOriginalStaffs" CssClass="inputmid" runat="server">
                                </asp:DropDownList>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    现所属部门:</div>
                            </td>
                            <td>
                                <asp:DropDownList ID="selNowDept" CssClass="inputmid" runat="server" AutoPostBack="true"
                                    OnSelectedIndexChanged="selNowDept_SelectedIndexChanged">
                                </asp:DropDownList>
                            </td>
                            <td>
                                <div align="right">
                                    现所属员工:</div>
                            </td>
                            <td>
                                <asp:DropDownList ID="selNowStaffs" CssClass="inputmid" runat="server">
                                </asp:DropDownList>
                            </td>
                            <td>
                                <div align="right">
                                    操作员工:</div>
                            </td>
                            <td>
                                <asp:DropDownList ID="ddlOperater" CssClass="inputmid" runat="server">
                                </asp:DropDownList>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    开始日期:</div>
                            </td>
                            <td>
                                <asp:TextBox runat="server" ID="txtFromDate" MaxLength="8" CssClass="input"></asp:TextBox>
                                <ajaxToolkit:CalendarExtender ID="FCalendar2" runat="server" TargetControlID="txtFromDate"
                                    Format="yyyyMMdd" />
                            </td>
                            <td>
                                <div align="right">
                                    结束日期:</div>
                            </td>
                            <td>
                                <asp:TextBox runat="server" ID="txtToDate" MaxLength="8" CssClass="input"></asp:TextBox>
                                <ajaxToolkit:CalendarExtender ID="CalendarExtender1" runat="server" TargetControlID="txtToDate"
                                    Format="yyyyMMdd" />
                            </td>
                            <td>
                            </td>
                            <td>
                                <asp:Button ID="btnQuery" CssClass="button1" runat="server" Text="查询" OnClick="btnQuery_Click" />
                            </td>
                        </tr>
                    </table>
                </div>
                <div class="jieguo">
                    统计</div>
                <div class="kuang5">
                    <%--  <div class="gdtb" style="height:310px">
--%>
                    <div id="gvUseCard" style="height: 260px; overflow: auto; display: block">
                        <asp:GridView ID="gvResult" runat="server" Width="98%" CssClass="tab1" HeaderStyle-CssClass="tabbt"
                            FooterStyle-CssClass="tabcon" AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel"
                            PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top"
                            AutoGenerateColumns="False" AllowSorting="true" OnRowDataBound="gvResult_RowDataBound"
                            OnSelectedIndexChanged="gvResult_SelectedIndexChanged" OnRowCreated="gvResult_RowCreated"
                            ShowFooter="true">
                            <Columns>
                                <asp:BoundField HeaderText="原所属部门" DataField="DEPARTNAMEOLD" />
                                <asp:BoundField HeaderText="原所属员工" DataField="STAFFNAMEOLD" />
                                <asp:BoundField HeaderText="现所属部门" DataField="DEPARTNAMENOW" />
                                <asp:BoundField HeaderText="现所属员工" DataField="STAFFNAMENow" />
                                <asp:BoundField HeaderText="数量" DataField="NUM" />
                            </Columns>
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                        <td>
                                            原所属部门
                                        </td>
                                        <td>
                                            原所属员工
                                        </td>
                                        <td>
                                            现所属员工
                                        </td>
                                        <td>
                                            统计
                                        </td>
                                    </tr>
                                </table>
                            </EmptyDataTemplate>
                        </asp:GridView>
                        <%--        </div>
--%>
                    </div>
                </div>
                <%-- <div class="kuang5">--%>
                <%--  <div class="gdtb" style="height:310px">
--%>
                <div class="jieguo">
                    明细</div>
                <div class="kuang5">
                    <div id="Div1" style="height: 260px; overflow: auto; display: block">
                        <asp:GridView ID="gvResultDetail" runat="server" Width="98%" CssClass="tab1" HeaderStyle-CssClass="tabbt"
                            AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel" PageSize="10"
                            PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top"
                            AutoGenerateColumns="False" AllowSorting="true" AllowPaging="true" OnPageIndexChanging="gvDetail_Page">
                            <Columns>
                                <asp:BoundField HeaderText="卡号" DataField="CARDNO" />
                                <asp:BoundField HeaderText="原所属部门" DataField="DEPARTNAMEOLD" />
                                <asp:BoundField HeaderText="原所属员工" DataField="STAFFNAMEOLD" />
                                <asp:BoundField HeaderText="现所属部门" DataField="DEPARTNAMENOW" />
                                <asp:BoundField HeaderText="现所属员工" DataField="STAFFNAMENow" />
                                <asp:BoundField HeaderText="操作员工" DataField="OPERATESTAFF" />
                                <asp:BoundField HeaderText="操作时间" DataField="OPERATETIME" />
                            </Columns>
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                        <td>
                                            卡号
                                        </td>
                                        <td>
                                            原所属部门
                                        </td>
                                        <td>
                                            原所属员工
                                        </td>
                                        <td>
                                            现所属员工
                                        </td>
                                        <td>
                                            操作员工
                                        </td>
                                        <td>
                                            操作时间
                                        </td>
                                    </tr>
                                </table>
                            </EmptyDataTemplate>
                        </asp:GridView>
                        <%--        </div>
--%>
                    </div>
                </div>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
    </form>
</body>
</html>

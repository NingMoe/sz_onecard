<%@ Page Language="C#" AutoEventWireup="true" CodeFile="RM_ResourceUnderOrder.aspx.cs"
    Inherits="ASP_ResourceManage_RM_ResourceUnderOrder" EnableEventValidation="false" %>

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

    <title>资源下单</title>
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
        资源管理->资源下单
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

            <asp:HiddenField ID="hidCardType" runat="server" />
            <asp:HiddenField ID="hidApplyType" runat="server" />
            <div class="con">
                <div class="card">
                    查询
                </div>
                <div class="kuang5" style="text-align: left">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td width="12%">
                                <div align="right">
                                    需求单号:</div>
                            </td>
                            <td width="15%">
                                <asp:TextBox runat="server" ID="txtApplyOrderID" CssClass="inputmid" MaxLength="18"></asp:TextBox>
                            </td>
                            <td width="12%">
                                <div align="right">
                                    起始日期:</div>
                            </td>
                            <td width="15%">
                                <ajaxToolkit:CalendarExtender ID="BeginCalendar" runat="server" TargetControlID="txtStartDate"
                                    Format="yyyyMMdd" PopupPosition="BottomLeft" />
                                <asp:TextBox ID="txtStartDate" runat="server" CssClass="input" MaxLength="8"></asp:TextBox>
                            </td>
                            <td width="12%">
                                <div align="right">
                                    结束日期:</div>
                            </td>
                            <td width="15%">
                                <asp:TextBox ID="txtEndDate" runat="server" CssClass="input" MaxLength="8"></asp:TextBox>
                                <ajaxToolkit:CalendarExtender ID="CalendarExtender2" runat="server" TargetControlID="txtEndDate"
                                    Format="yyyyMMdd" PopupPosition="BottomLeft" />
                            </td>
                            <td align="center">
                            <asp:Button ID="btnQuery" CssClass="button1" runat="server" Text="查询" OnClick="btnQuery_Click" />
                            </td>
                        </tr>
                    </table>
                </div>
                <div class="jieguo">
                    查询结果</div>
                <div class="kuang5">
                    <div id="gvSupplyCard" style="height: 180px; overflow: auto; display: block">
                        <asp:GridView ID="gvResult" runat="server" Width="120%" CssClass="tab1" HeaderStyle-CssClass="tabbt"
                            FooterStyle-CssClass="tabcon" AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel"
                            PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top"
                            AutoGenerateColumns="true" PageSize="50" AllowPaging="true" OnPageIndexChanging="gvResult_Page"
                            OnRowDataBound="gvResult_RowDataBound" OnRowCreated="gvResult_RowCreated" OnSelectedIndexChanged="gvResult_SelectedIndexChanged">
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                        <td>
                                            需求单号
                                        </td>
                                        <td>
                                            资源类型
                                        </td>
                                        <td>
                                            资源名称
                                        </td>
                                        <td>
                                            属性
                                        </td>
                                        <td>
                                            申请下单数量
                                        </td>
                                        <td>
                                            要求到货日期
                                        </td>
                                        <td>
                                            订单要求
                                        </td>
                                        <td>
                                            下单时间
                                        </td>
                                        <td>
                                            下单员工
                                        </td>
                                        <td>
                                            已订购数量
                                        </td>
                                        <td>
                                            最近到货时间
                                        </td>
                                        <td>
                                            已到货数量
                                        </td>
                                        <td>
                                            备注
                                        </td>
                                    </tr>
                                </table>
                            </EmptyDataTemplate>
                        </asp:GridView>
                    </div>
                </div>
                <div class="card">
                    订购单信息填写</div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr id="applySupplyStock">
                            <td width="12%">
                                <div align="right">
                                    资源类型:</div>
                            </td>
                            <td width="36%" colspan="3">
                                <asp:Label ID="lbResourceType" runat="server" Text=""></asp:Label>
                            </td>
                            <td width="12%">
                                <div align="right">
                                    资源名称:</div>
                            </td>
                            <td width="36%" colspan="3">
                                <asp:Label ID="lbResourceName" runat="server" Text=""></asp:Label>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    下单数量:</div>
                            </td>
                            <td colspan="3">
                                <asp:TextBox ID="txtNum" CssClass="input" runat="server"></asp:TextBox><span
                                    class="red">*</span>
                            </td>
                            <td>
                                <div align="right">
                                    订单要求:</div>
                            </td>
                            <td colspan="3">
                                <asp:Label ID="lbRequireOrder" runat="server" Text=""></asp:Label>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    要求到货日期:</div>
                            </td>
                            <td colspan="3">
                                <asp:Label ID="lbRequireDate" runat="server" Text=""></asp:Label>
                            </td>
                            <td>
                                <div align="right">
                                    最近到货日期:</div>
                            </td>
                            <td colspan="3">
                                <asp:Label ID="lbRecentDate" runat="server" Text=""></asp:Label>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    <asp:Label ID="lbAttribute1" runat="server" Text=""></asp:Label></div>
                            </td>
                            <td colspan="3">
                                <asp:Label ID="lbValue1" runat="server" Text=""></asp:Label>
                            </td>
                            <td>
                                <div align="right">
                                    <asp:Label ID="lbAttribute2" runat="server" Text=""></asp:Label></div>
                            </td>
                            <td colspan="3">
                                <asp:Label ID="lbValue2" runat="server" Text=""></asp:Label>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    <asp:Label ID="lbAttribute3" runat="server" Text=""></asp:Label></div>
                            </td>
                            <td colspan="3">
                                <asp:Label ID="lbValue3" runat="server" Text=""></asp:Label>
                            </td>
                            <td>
                                <div align="right">
                                    <asp:Label ID="lbAttribute4" runat="server" Text=""></asp:Label></div>
                            </td>
                            <td colspan="3">
                                <asp:Label ID="lbValue4" runat="server" Text=""></asp:Label>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    <asp:Label ID="lbAttribute5" runat="server" Text=""></asp:Label></div>
                            </td>
                            <td colspan="3">
                                <asp:Label ID="lbValue5" runat="server" Text=""></asp:Label>
                            </td>
                            <td>
                                <div align="right">
                                    <asp:Label ID="lbAttribute6" runat="server" Text=""></asp:Label></div>
                            </td>
                            <td colspan="3">
                                <asp:Label ID="lbValue6" runat="server" Text=""></asp:Label>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    下单时间:</div>
                            </td>
                            <td colspan="3">
                                <asp:Label ID="lbOrderDate" runat="server" Text=""></asp:Label>
                            </td>
                            <td>
                                <div align="right">
                                    下单员工:</div>
                            </td>
                            <td colspan="3">
                                <asp:Label ID="lbStaffName" runat="server" Text=""></asp:Label>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    备注:</div>
                            </td>
                            <td colspan="3">
                                <asp:TextBox ID="txtRemark" CssClass="inputmid" runat="server"></asp:TextBox>
                            </td>
                            <td>
                                <div align="right">
                                    </div>
                            </td>
                            <td colspan="3">
                                
                            </td>
                        </tr>
                    </table>
                </div>
            </div>
            <div class="footall">
            </div>
            <div class="btns">
                <table width="300" border="0" align="right" cellpadding="0" cellspacing="0">
                    <tr>
                        <td>
                            <asp:Button ID="btnPrint" Text="打印需求单" CssClass="button1" runat="server" OnClick="btnPrint_Click"  Visible="false"/>
                        </td>
                        <td>
                        </td>
                        <td align="center">
                            <asp:Button ID="btnApply" Text="提  交" CssClass="button1" runat="server" OnClick="btnApply_Click" />
                        </td>
                    </tr>
                </table>
            </div>
            <div style="display: none" runat="server" id="printarea">
            </div>
            <div id="RoleWindow" style="width: 670px; position: absolute; display: none; z-index: 999;">
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
    </form>
</body>
</html>

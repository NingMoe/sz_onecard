<%@ Page Language="C#" AutoEventWireup="true" CodeFile="RM_ResourceApplyOrder.aspx.cs"
    Inherits="ASP_ResourceManage_RM_ResourceApplyOrder" %>

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

    <title>资源下单申请</title>
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
        资源管理->资源下单申请
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
                            <td width="15%">
                                <div align="right">
                                    需求单号:</div>
                            </td>
                            <td width="15%">
                                <asp:TextBox runat="server" ID="txtApplyOrderID" CssClass="inputmid" MaxLength="18"></asp:TextBox>
                            </td>
                            <td width="15%">
                                <div align="right">
                                    起始日期:</div>
                            </td>
                            <td width="15%">
                                <ajaxToolkit:CalendarExtender ID="BeginCalendar" runat="server" TargetControlID="txtStartDate"
                                    Format="yyyyMMdd" PopupPosition="BottomLeft" />
                                <asp:TextBox ID="txtStartDate" runat="server" CssClass="input" MaxLength="8"></asp:TextBox>
                            </td>
                            <td width="15%">
                                <div align="right">
                                    结束日期:</div>
                            </td>
                            <td width="15%">
                                <asp:TextBox ID="txtEndDate" runat="server" CssClass="input" MaxLength="8"></asp:TextBox>
                                <ajaxToolkit:CalendarExtender ID="CalendarExtender2" runat="server" TargetControlID="txtEndDate"
                                    Format="yyyyMMdd" PopupPosition="BottomLeft" />
                            </td>
                        </tr>
                        <tr>
                            <td width="15%">
                                <div align="right">
                                    资源类型:</div>
                            </td>
                            <td width="15%">
                                <asp:DropDownList ID="selResourceType" CssClass="inputmid" runat="server" 
                                AutoPostBack="true" OnSelectedIndexChanged="selResourceType_change">
                                </asp:DropDownList>
                            </td>
                            <td width="15%">
                                <div align="right">
                                    资源名称:</div>
                            </td>
                            <td width="15%">
                                <asp:DropDownList ID="selResourceName" CssClass="inputmid" runat="server">
                                </asp:DropDownList>
                            </td>
                            <td width="15%">
                            </td>
                            <td width="15%">
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
                            AutoGenerateColumns="false" PageSize="50" AllowPaging="true" OnPageIndexChanging="gvResult_Page"
                            OnRowDataBound="gvResult_RowDataBound">
                            <Columns>
                                <asp:TemplateField>
                                    <HeaderTemplate>
                                        <asp:CheckBox ID="CheckBox1" runat="server" AutoPostBack="true" OnCheckedChanged="CheckAll" />
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                        <asp:CheckBox ID="ItemCheckBox" runat="server" />
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField DataField="需求单号" HeaderText="需求单号" />
                                <asp:BoundField DataField="需求单状态" HeaderText="需求单状态" />
                                <asp:BoundField DataField="资源类型" HeaderText="资源类型" />
                                <asp:BoundField DataField="资源名称" HeaderText="资源名称" />
                                <asp:BoundField DataField="资源编码" HeaderText="资源编码" />
                                <asp:BoundField DataField="属性1" HeaderText="资源属性" />
                                <asp:BoundField DataField="属性值1" HeaderText="资源属性" />
                                <asp:BoundField DataField="属性2" HeaderText="资源属性" />
                                <asp:BoundField DataField="属性值2" HeaderText="资源属性" />
                                <asp:BoundField DataField="属性3" HeaderText="资源属性" />
                                <asp:BoundField DataField="属性值3" HeaderText="资源属性" />
                                <asp:BoundField DataField="属性4" HeaderText="资源属性" />
                                <asp:BoundField DataField="属性值4" HeaderText="资源属性" />
                                <asp:BoundField DataField="属性5" HeaderText="资源属性" />
                                <asp:BoundField DataField="属性值5" HeaderText="资源属性" />
                                <asp:BoundField DataField="属性6" HeaderText="资源属性" />
                                <asp:BoundField DataField="属性值6" HeaderText="资源属性" />
                                <asp:BoundField DataField="数量" HeaderText="数量" />
                                <asp:BoundField DataField="要求到货日期" HeaderText="要求到货日期" />
                                <asp:BoundField DataField="订单要求" HeaderText="订单要求" />
                                <asp:BoundField DataField="下单时间" HeaderText="下单时间" />
                                <asp:BoundField DataField="下单员工" HeaderText="下单员工" />
                                <asp:BoundField DataField="已订购数量" HeaderText="已订购数量" />
                                <asp:BoundField DataField="最近到货时间" HeaderText=" 最近到货时间" />
                                <asp:BoundField DataField="已到货数量" HeaderText="已到货数量" />
                                <asp:BoundField DataField="备注" HeaderText="备注" />
                            </Columns>
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                        <td>
                                            <input type="checkbox" />
                                        </td>
                                        <td>
                                            需求单号
                                        </td>
                                        <td>
                                            需求单状态
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
                                            下单数量
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
                    填写需求单</div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr id="applySupplyStock">
                            <td width="12%">
                                <div align="right">
                                    资源类型:</div>
                            </td>
                            <td width="36%" colspan="3">
                                <asp:DropDownList ID="InResourceType" CssClass="inputmid" Width="200px" runat="server"
                                    AutoPostBack="true" OnSelectedIndexChanged="InResourceType_change">
                                </asp:DropDownList>
                                <asp:Label Text="*" runat="server" ID="lb1" Font-Bold="True" ForeColor="Red"></asp:Label>
                            </td>
                            <td width="12%">
                                <div align="right">
                                    资源名称:</div>
                            </td>
                            <td width="36%" colspan="3">
                                <asp:DropDownList ID="InResourceName" CssClass="inputmid" Width="200px" runat="server"
                                    AutoPostBack="true" OnSelectedIndexChanged="InResourceName_change" Enabled="false">
                                </asp:DropDownList>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    下单数量:</div>
                            </td>
                            <td colspan="3">
                                <asp:TextBox ID="txtNum" CssClass="input" MaxLength="8" runat="server"></asp:TextBox>
                                <asp:Label Text="*" runat="server" ID="lb2" Font-Bold="True" ForeColor="Red"></asp:Label>
                            </td>
                            <td>
                                <div align="right">
                                    要求到货日期:</div>
                            </td>
                            <td colspan="3">
                                <asp:TextBox ID="txtDate" CssClass="input" runat="server" MaxLength="8" />
                                <ajaxToolkit:CalendarExtender ID="FCalendar" runat="server" TargetControlID="txtDate"
                                    Format="yyyyMMdd" />
                                <asp:Label Text="*" runat="server" ID="lb3" Font-Bold="True" ForeColor="Red"></asp:Label>
                            </td>
                        </tr>
                        <tr>
                                <div>
                                    <asp:Panel ID="divAttribute1" runat="server">
                                        <td align="right" width="12%">
                                            <asp:Label ID="lblAttribute1Name" runat="server" style="width:12% " />
                                            <asp:HiddenField ID="hideISNULL1" runat="server" />
                                        </td>
                                        <td colspan="3" width="36%">
                                            <asp:TextBox ID="txtAttribute1" runat="server" CssClass="input" ></asp:TextBox>
                                            <asp:Label Text="*" runat="server" ID="lbRed1" Font-Bold="True" ForeColor="Red" Visible="false"></asp:Label>
                                        </td>
                                    </asp:Panel>
                                </div>
                                <div>
                                    <asp:Panel ID="divAttribute2" runat="server">
                                        <td align="right" width="12%">
                                            <asp:Label ID="lblAttribute2Name" runat="server" style="width:12%" />
                                            <asp:HiddenField ID="hideISNULL2" runat="server" />
                                        </td>
                                        <td colspan="3" width="36%">
                                            <asp:TextBox ID="txtAttribute2" runat="server" CssClass="input" ></asp:TextBox>
                                            <asp:Label Text="*" runat="server" ID="lbRed2" Font-Bold="True" ForeColor="Red" Visible="false"></asp:Label>
                                        </td>
                                    </asp:Panel>
                                </div>
                            </tr>
                            <tr>
                                <div>
                                    <asp:Panel ID="divAttribute3" runat="server">
                                        <td align="right" width="12%">
                                            <asp:Label ID="lblAttribute3Name" runat="server" style="width:12%" />
                                            <asp:HiddenField ID="hideISNULL3" runat="server" />
                                        </td>
                                        <td colspan="3" width="36%">
                                            <asp:TextBox ID="txtAttribute3" runat="server" CssClass="input" ></asp:TextBox>
                                            <asp:Label Text="*" runat="server" ID="lbRed3" Font-Bold="True" ForeColor="Red" Visible="false"></asp:Label>
                                        </td>
                                    </asp:Panel>
                                </div>
                                <div>
                                    <asp:Panel ID="divAttribute4" runat="server">
                                        <td align="right" width="12%">
                                            <asp:Label ID="lblAttribute4Name" runat="server" style="width:12%" />
                                            <asp:HiddenField ID="hideISNULL4" runat="server" />
                                        </td>
                                        <td colspan="3" width="36%">
                                            <asp:TextBox ID="txtAttribute4" runat="server" CssClass="input" ></asp:TextBox>
                                            <asp:Label Text="*" runat="server" ID="lbRed4" Font-Bold="True" ForeColor="Red" Visible="false"></asp:Label>
                                        </td>
                                    </asp:Panel>
                                </div>
                            </tr>
                            <tr>
                                <div>
                                    <asp:Panel ID="divAttribute5" runat="server">
                                        <td align="right" width="12%">
                                            <asp:Label ID="lblAttribute5Name" runat="server" style="width:12%" />
                                            <asp:HiddenField ID="hideISNULL5" runat="server" />
                                        </td>
                                        <td colspan="3" width="36%">
                                            <asp:TextBox ID="txtAttribute5" runat="server" CssClass="input" ></asp:TextBox>
                                            <asp:Label Text="*" runat="server" ID="lbRed5" Font-Bold="True" ForeColor="Red" Visible="false"></asp:Label>
                                        </td>
                                    </asp:Panel>
                                </div>
                                <div>
                                    <asp:Panel ID="divAttribute6" runat="server">
                                        <td align="right" width="12%">
                                            <asp:Label ID="lblAttribute6Name" runat="server" style="width:12%" />
                                            <asp:HiddenField ID="hideISNULL6" runat="server" />
                                        </td>
                                        <td colspan="3" width="36%">
                                            <asp:TextBox ID="txtAttribute6" runat="server" CssClass="input" ></asp:TextBox>
                                            <asp:Label Text="*" runat="server" ID="lbRed6" Font-Bold="True" ForeColor="Red" Visible="false"></asp:Label>
                                        </td>
                                    </asp:Panel>
                                </div>
                            </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    订单要求:</div>
                            </td>
                            <td colspan="3">
                                <asp:TextBox ID="txtOrderMand" CssClass="inputlong" runat="server"></asp:TextBox>
                            </td>
                            <td>
                                <div align="right">
                                    备注:</div>
                            </td>
                            <td colspan="3">
                                <asp:TextBox ID="txtReMark" CssClass="inputlong" runat="server"></asp:TextBox>
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
                            <asp:Button ID="btnPrint" Text="打印需求单" CssClass="button1" runat="server" OnClick="btnPrint_Click" />
                        </td>
                        <td>
                        </td>
                        <td align="center">
                            <asp:Button ID="btnApply" Text="申 请" CssClass="button1" runat="server" OnClick="btnApply_Click" />
                        </td>
                    </tr>
                </table>
                <asp:CheckBox ID="chkOrder" runat="server" Checked="true" />自动打印需求单
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

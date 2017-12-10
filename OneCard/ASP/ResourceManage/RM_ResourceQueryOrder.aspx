<%@ Page Language="C#" AutoEventWireup="true" CodeFile="RM_ResourceQueryOrder.aspx.cs" Inherits="ASP_ResourceManage_RM_ResourceQueryOrder"
    EnableEventValidation="false" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>订购单查询</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="../../js/myext.js"></script>
    <script type="text/javascript" src="../../js/RMHelper.js"></script>
    <script type="text/javascript" src="../../js/printorder.js"></script>
    <script type="text/javascript" language="javascript">
    </script>
    
     <style type="text/css">

        table.data {font-size: 90%; border-collapse: collapse; border: 0px solid black;}
        table.data th {background: #bddeff; width: 25em; text-align: left; padding-right: 8px; font-weight: normal; border: 1px solid black;}
        table.data td {background: #ffffff; vertical-align:middle;padding: 0px 2px 0px 2px; border: 1px solid black;}

    </style>
    
</head>
<body>
    <form id="form1" runat="server">
    <div class="tb">
        资源管理->订购单查询
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
                    查询</div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
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
                            <td width="15%">
                                <div align="right">
                                    订购单状态:</div>
                            </td>
                            <td width="15%">
                                <asp:DropDownList ID="selExamState" CssClass="input" runat="server">
                                    <asp:ListItem Text="---请选择---" Value=""  Selected="True"></asp:ListItem>
                                    <asp:ListItem Text="0: 待审核" Value="0"></asp:ListItem>
                                    <asp:ListItem Text="1: 审核通过" Value="1"></asp:ListItem>
                                    <asp:ListItem Text="2: 审核作废" Value="2"></asp:ListItem>
                                    <asp:ListItem Text="3: 部分到货" Value="3"></asp:ListItem>
                                    <asp:ListItem Text="4: 全部到货" Value="4"></asp:ListItem>
                                    <asp:ListItem Text="5: 未全部到货" Value="5"></asp:ListItem>
                                </asp:DropDownList>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    订购单号:</div>
                            </td>
                            <td>
                                <asp:TextBox ID="txtOrderID" CssClass="inputmid" MaxLength="18" runat="server">
                                </asp:TextBox>
                            </td>
                            <td>
                                <div align="right">
                                    需求单号:</div>
                            </td>
                            <td>
                                <asp:TextBox ID="txtApplyOrderID" CssClass="inputmid" MaxLength="18" runat="server">
                                </asp:TextBox>
                            </td>
                            <td colspan="2">
                                <table id="queryCardFace" style="display: block;" border="0" cellpadding="0" cellspacing="0"
                                    class="text25" width="100%">
                                    <tr>
                                        <td width="50%">
                                            <div align="right">
                                                资源类型：</div>
                                        </td>
                                        <td width="50%">
                                            <asp:DropDownList ID="selResourceType" CssClass="inputmid" runat="server">
                                            </asp:DropDownList>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                            <td align="right">
                                <asp:Button ID="btnQuery" CssClass="button1" runat="server" Text="查询" OnClick="btnQuery_Click" />
                            </td>
                        </tr>
                    </table>
                </div>
                <div class="jieguo">
                    查询结果</div>
                <div class="kuang5">
                    <div id="gvUseCard" style="height: 150px; overflow: auto; display: block">
                        <asp:GridView ID="gvResult" runat="server" Width="180%" CssClass="tab1" HeaderStyle-CssClass="tabbt"
                            FooterStyle-CssClass="tabcon" AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel"
                            PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top"
                            AutoGenerateColumns="true" OnRowDataBound="gvResult_RowDataBound" PageSize="50"
                            OnPageIndexChanging="gvResult_Page" OnSelectedIndexChanged="gvResult_SelectedIndexChanged"
                            OnRowCreated="gvResult_RowCreated" AllowPaging="true">
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                        <td>
                                            订购单号
                                        </td>
                                        <td>
                                            需求单号
                                        </td>
                                        <td>
                                            订购单状态
                                        </td>
                                        <td>
                                            资源类型
                                        </td>
                                        <td>
                                            资源名称
                                        </td>
                                        <td>
                                            资源属性
                                        </td>
                                        <td>
                                            订购数量
                                        </td>
                                        <td>
                                            要求到货日期
                                        </td>
                                        <td>
                                            最近到货日期
                                        </td>
                                        <td>
                                            已到货数量
                                        </td>
                                        <td>
                                            下单时间
                                        </td>
                                        <td>
                                            下单员工
                                        </td>
                                        <td>
                                            审核时间
                                        </td>
                                        <td>
                                            审核员工
                                        </td>
                                        <td>
                                            备注
                                        </td>
                                    </tr>
                                </table>
                            </EmptyDataTemplate>
                        </asp:GridView>
                    </div>
                <div class="card">
                    订购单详细信息</div>
                <div class="kuang5">
                    <table id="supplyUseCard" width="95%" border="0" cellpadding="0" cellspacing="0"
                        class="text25" style="display: block">
                        <tr>
                            <td width="12%">
                                <div align="right">
                                    订购单号:</div>
                            </td>
                            <td width="12%">
                                <asp:Label ID="txtCardOrderID"  runat="server">
                                </asp:Label>
                            </td>
                            <td width="12%">
                                <div align="right">
                                    需求单号:</div>
                            </td>
                            <td width="12%">
                                <asp:Label ID="txtApplyCardOrderID"  runat="server">
                                </asp:Label>
                            </td>
                            <td width="12%">
                                <div align="right">
                                    订购单状态:</div>
                            </td>
                            <td width="12%">
                                <asp:Label ID="txtExamState"  runat="server"></asp:Label>
                            </td>
                            <td  width="12%">
                                <div align="right">
                                    资源类型:</div>
                            </td>
                            <td  width="12%">
                                <asp:Label ID="txtResourceType"  runat="server">
                                </asp:Label>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    资源名称:</div>
                            </td>
                            <td>
                                <asp:Label ID="txtResourceName"  runat="server">
                                </asp:Label>
                            </td>
                            <td>
                                <div align="right">
                                    订购数量:</div>
                            </td>
                            <td>
                                <asp:Label ID="txtCardSum"  Width="100" runat="server"></asp:Label>
                            </td>
                            <td>
                                <div align="right">
                                    要求到货日期:</div>
                            </td>
                            <td>
                                <asp:Label ID="txtRequireDate"  runat="server"></asp:Label>
                            </td>
                            <td>
                                <div align="right">
                                    最近到货日期:</div>
                            </td>
                            <td>
                                <asp:Label runat="server" ID="txtLatelyDate"  />
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    下单员工:</div>
                            </td>
                            <td>
                                <asp:Label ID="txtOrderStaff"  runat="server">
                                </asp:Label>
                            </td>
                            <td>
                                <div align="right">
                                    下单时间:</div>
                            </td>
                            <td>
                                <asp:Label ID="txtOrderTime" runat="server" ></asp:Label>
                            </td>
                            <td>
                                <div align="right">
                                    已到货数量:</div>
                            </td>
                            <td>
                                <asp:Label ID="txtAlreadyArriveNum"  runat="server">
                                </asp:Label>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    审核员工:</div>
                            </td>
                            <td>
                                <asp:Label ID="txtExamStaff"  runat="server">
                                </asp:Label>
                            </td>
                            <td>
                                <div align="right">
                                    审核时间:</div>
                            </td>
                            <td>
                                <asp:Label ID="txtExamTime"  runat="server">
                                </asp:Label>
                            </td>
                            <td>
                                <div align="right">
                                    备注:</div>
                            </td>
                            <td colspan="3">
                                <asp:Label ID="txtReMark"  runat="server">
                                </asp:Label>
                            </td>
                        </tr>
                    </table>
                </div>
            </div>
            <div class="footall">
            </div>
            <div class="btns">
                <table width="200" border="0" align="right" cellpadding="0" cellspacing="0">
                    <tr>
                        <td>
                            <asp:Button ID="btnPrint" runat="server" Text="打印订购单" CssClass="button1" Enabled="true"
                                OnClick="btnPrint_Click" />
                        </td>
                    </tr>
                </table>
            </div>
            <div style="display:none" runat="server" id="printarea"></div>
        </ContentTemplate>
    </asp:UpdatePanel>
    </form>
</body>
</html>

<%@ Page Language="C#" AutoEventWireup="true" CodeFile="GC_OrderDailyReport.aspx.cs"
    Inherits="ASP_GroupCard_GC_OrderDailyReport" EnableEventValidation="false" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>订单日报</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="../../js/printorder.js"></script>
    <script type="text/javascript" src="../../js/myext.js"></script>
    <script type="text/javascript" src="../../js/jquery-1.5.min.js"></script>
    <script type="text/javascript" src="../../js/Window.js"></script>
    <script type="text/javascript">

    </script>
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
        订单日报
    </div>
    <ajaxToolkit:ToolkitScriptManager EnableScriptGlobalization="true" EnableScriptLocalization="true"
        ID="ScriptManager1" runat="server" />
    <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
            <asp:BulletedList ID="bulMsgShow" runat="server" />
            <script runat="server">public override void ErrorMsgShow() { ErrorMsgHelper(bulMsgShow); }</script>
            <div class="con">
                <div class="base">
                    订单日报</div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td width="8%">
                                <div align="right">
                                    单位名称:</div>
                            </td>
                            <td width="44%" colspan='3'>
                                <asp:TextBox ID="txtGroupName" CssClass="inputmid" runat="server" AutoPostBack="true"
                                    OnTextChanged="txtGroupName_Changed"></asp:TextBox>
                                <asp:DropDownList ID="selCompany" CssClass="inputmid" Width="206" runat="server"
                                    AutoPostBack="true" OnSelectedIndexChanged="selCompany_Changed">
                                </asp:DropDownList>
                            </td>
                            <td width="10%">
                                <div align="right">
                                    联系人:</div>
                            </td>
                            <td width="12%">
                                <asp:TextBox ID="txtName" CssClass="inputmid" runat="server"></asp:TextBox>
                            </td>
                            <td width="12%">
                                <div align="right">
                                    录入员工:</div>
                            </td>
                            <td width="14%">
                                <asp:DropDownList ID="selInputStaff" CssClass="inputmid" runat="server">
                                </asp:DropDownList>
                            </td>
                        </tr>
                        <tr>
                            <td width="8%">
                                <div align="right">
                                    制卡部门:</div>
                            </td>
                            <td width="8%">
                                <asp:DropDownList ID="selMadeDepart" CssClass="inputmid" runat="server" AutoPostBack="true"
                                    OnSelectedIndexChanged="selMadeDepart_Changed">
                                </asp:DropDownList>
                            </td>
                            <td width="8%">
                                <div align="right">
                                    制卡员工:</div>
                            </td>
                            <td width="8%">
                                <asp:DropDownList ID="selMadeCardStaff" CssClass="inputmid" runat="server">
                                </asp:DropDownList>
                            </td>
                            <td width="8%">
                                <div align="right">
                                    开始日期:</div>
                            </td>
                            <td width="8%">
                                <asp:TextBox runat="server" ID="txtFromDate" MaxLength="8" CssClass="input"></asp:TextBox>
                                <ajaxToolkit:CalendarExtender ID="CalendarExtender1" runat="server" TargetControlID="txtFromDate"
                                    Format="yyyyMMdd" />
                            </td>
                            <td>
                                <div align="right">
                                    结束日期:</div>
                            </td>
                            <td>
                                <asp:TextBox runat="server" ID="txtToDate" MaxLength="8" CssClass="input"></asp:TextBox>
                                <ajaxToolkit:CalendarExtender ID="CalendarExtender2" runat="server" TargetControlID="txtToDate"
                                    Format="yyyyMMdd" />
                            </td>
                        </tr>
                        <tr>
                            <td width="8%">
                                <div align="right">
                                    订单号:</div>
                            </td>
                            <td width="8%">
                                <asp:TextBox ID="txtOrderNo" CssClass="inputmid" runat="server" MaxLength="20"></asp:TextBox>
                            </td>
                            <td width="8%">
                            <div align="right">
                                    客户经理部门:</div>
                            </td>
                            <td width="8%">
                              <asp:DropDownList ID="selManagerDept" CssClass="inputmid" runat="server" 
                                    AutoPostBack="true" OnSelectedIndexChanged="managerDept_Changed">
                                </asp:DropDownList>
                            </td>
                            <td width="8%">
                                <div align="right">
                                    客户经理:</div>
                            </td>
                            <td width="8%">
                                <asp:DropDownList ID="selManager" CssClass="inputmid" runat="server" >
                                </asp:DropDownList>
                            </td>
                            <td>
                                &nbsp;</td>
                            <td>
                                <asp:Button ID="btnQuery" runat="server" CssClass="button1" 
                                    OnClick="btnQuery_Click" Text="查询" />
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
                        <td align="right">
                            <asp:Button ID="btnExport" CssClass="button1" runat="server" Text="导出Excel" OnClick="btnExport_Click" />
                            <asp:Button ID="btnPrint" CssClass="button1" runat="server" Text="打印" OnClientClick="return printGridView('printarea');" />
                        </td>
                    </tr>
                </table>
                <div id="printarea" class="kuang5">
                    <div id="gdtbfix" class="gdtb" style="height: 300px; overflow: auto;">
                        <table id="printReport" width="95%">
                            <tr align="center">
                                <td style="font-size: 16px; font-weight: bold">
                                    订单日报
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <table width="300px" align="right">
                                        <tr align="right">
                                            <td>
                                                开始日期：<%=txtFromDate.Text%></td>
                                            <td>
                                                结束日期：<%=txtToDate.Text%></td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                        </table>
                        <asp:GridView ID="gvOrderList" CssClass="tab2" HeaderStyle-CssClass="tabbt" FooterStyle-CssClass="tabcon"
                            AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel" PagerSettings-Mode="NumericFirstLast"
                            PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top" runat="server"
                            AutoGenerateColumns="false" Width="95%" PageSize="10" AllowPaging="true" OnPageIndexChanging="gvOrderList_Page">
                            <Columns>
                                <asp:BoundField DataField="OPERATEDEPARTNO" HeaderText="部门" />
                                <asp:BoundField DataField="STAFF" HeaderText="营业员" />
                                <asp:BoundField DataField="ORDERNO" HeaderText="订单号" />
                                <asp:BoundField DataField="GROUPNAME" HeaderText="单位名称" />
                                <asp:BoundField DataField="INPUTSTAFF" HeaderText="经办人" />
                                <asp:BoundField DataField="CARDTYPE" HeaderText="卡片类型" />
                                <asp:BoundField DataField="ORDERCOUNT" HeaderText="订单要求数量" />
                                <asp:BoundField DataField="CARDNUM" HeaderText="已制卡数量" />
                                <asp:BoundField DataField="OPERATETIME" HeaderText="制卡日期" />
                                <asp:BoundField DataField="MONEY" HeaderText="金额" />
                            </Columns>
                            <%--<EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                        <td>
                                            部门
                                        </td>
                                        <td>
                                            营业员
                                        </td>
                                        <td>
                                            订单号
                                        </td>
                                        <td>
                                            单位名称
                                        </td>
                                        <td>
                                            经办人
                                        </td>
                                        <td>
                                            卡片类型
                                        </td>
                                        <td>
                                            订单要求数量
                                        </td>
                                        <td>
                                            已制卡数量
                                        </td>
                                        <td>
                                            制卡日期
                                        </td>
                                        <td>
                                            金额
                                        </td>
                                    </tr>
                                </table>
                            </EmptyDataTemplate>--%>
                        </asp:GridView>
                    </div>
                </div>
            </div>
        </ContentTemplate>
        <Triggers>
            <asp:PostBackTrigger ControlID="btnExport" />
        </Triggers>
    </asp:UpdatePanel>
    </form>
</body>
</html>

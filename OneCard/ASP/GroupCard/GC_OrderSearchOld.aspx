<%@ Page Language="C#" AutoEventWireup="true" CodeFile="GC_OrderSearchOld.aspx.cs" EnableEventValidation="false"
    Inherits="ASP_GroupCard_SZ_OrderSearchOld" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>订单查询(旧)</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="../../js/printorder.js"></script>
    <script type="text/javascript" src="../../js/myext.js"></script>
    <script type="text/javascript" src="../../js/jquery-1.5.min.js"></script>
    <script type="text/javascript" src="../../js/Window.js"></script>
    <script type="text/javascript">
        function Research() {
            $("#btnQuery").click();
        }
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
        订单查询(旧)
    </div>
    <ajaxToolkit:ToolkitScriptManager EnableScriptGlobalization="true" EnableScriptLocalization="true"
        ID="ScriptManager1" runat="server" />
    <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
            <asp:BulletedList ID="bulMsgShow" runat="server" />
            <script runat="server">public override void ErrorMsgShow() { ErrorMsgHelper(bulMsgShow); }</script>
            <div class="con">
                <div class="base">
                    订单查询</div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td width="6%">
                                <div align="right">
                                    单位名称:</div>
                            </td>
                            <td width="10%">
                                <asp:TextBox ID="txtGroupName" CssClass="inputmid" runat="server"></asp:TextBox>
                            </td>
                            <td width="8%">
                                <div align="right">
                                    联系人:</div>
                            </td>
                            <td style="width: 150px;">
                                <asp:TextBox ID="txtName" CssClass="input" runat="server"></asp:TextBox>
                            </td>
                        </tr>
                        <tr>
                            <td width="8%">
                                <div align="right">
                                    部门:</div>
                            </td>
                            <td width="5%">
                                <asp:DropDownList ID="selDept" CssClass="inputmid" runat="server" AutoPostBack="true"
                                    OnSelectedIndexChanged="selDept_Changed" Enabled="false">
                                </asp:DropDownList>
                            </td>
                            <td width="5%">
                                <div align="right">
                                    经办人:</div>
                            </td>
                            <td>
                                <asp:DropDownList ID="selStaff" CssClass="inputmid" runat="server" Enabled="false">
                                </asp:DropDownList>
                            </td>
                            <td>
                                <div align="right">
                                    金额:</div>
                            </td>
                            <td>
                                <asp:TextBox ID="txtTotalMoney" CssClass="input" runat="server"></asp:TextBox>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    开始日期:</div>
                            </td>
                            <td>
                                <asp:TextBox runat="server" ID="txtFromDate" MaxLength="8" CssClass="input"></asp:TextBox>
                                <ajaxToolkit:CalendarExtender ID="FCalendar1" runat="server" TargetControlID="txtFromDate"
                                    Format="yyyyMMdd" />
                            </td>
                            <td>
                                <div align="right">
                                    结束日期:</div>
                            </td>
                            <td>
                                <asp:TextBox runat="server" ID="txtToDate" MaxLength="8" CssClass="input"></asp:TextBox>
                                <ajaxToolkit:CalendarExtender ID="FCalendar2" runat="server" TargetControlID="txtToDate"
                                    Format="yyyyMMdd" />
                            </td>
                            <td width="10%">
                                <div align="right">
                                    审批状态:</div>
                            </td>
                            <td>
                                <asp:DropDownList ID="selApprovalStatus" CssClass="input" runat="server">
                                </asp:DropDownList>
                            </td>
                            <td>
                                &nbsp;&nbsp;<asp:Button runat="server" CssClass="button1" ID="btnQuery" Text="查询"
                                    OnClick="btnQuery_Click" />
                            </td>
                        </tr>
                    </table>
                </div>
                <table border="0" width="95%">
                    <tr>
                        <td align="left">
                            <div class="jieguo">
                                订单列表</div>
                        </td>
                        <td align="right">
                            <asp:Button ID="btnExport" CssClass="button1" runat="server" Text="导出Excel" OnClick="btnExport_Click" />
                        </td>
                    </tr>
                </table>
                <div class="kuang5">
                    <asp:GridView ID="gvOrderList" CssClass="tab2" HeaderStyle-CssClass="tabbt" FooterStyle-CssClass="tabcon"
                        AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel" PagerSettings-Mode="NumericFirstLast"
                        PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top" runat="server"
                        AutoGenerateColumns="false" OnRowDataBound="gvOrderList_RowDataBound" Width="100%">
                        <Columns>
                            <asp:TemplateField>
                                <ItemTemplate>
                                    <asp:Button ID="btnUpdate" Enabled="true" Width="45px" CssClass="button1" runat="server"
                                        Text="修改" />
                                    <asp:Button ID="btnPrint" Enabled="true" Width="45px" CssClass="button1" runat="server"
                                        Text="打印" />
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:BoundField DataField="orderno" HeaderText="订单号" />
                            <asp:BoundField DataField="groupname" HeaderText="单位名称" />
                            <asp:BoundField DataField="name" HeaderText="联系人" />
                            <asp:BoundField DataField="idcardno" HeaderText="身份证号码" />
                            <asp:BoundField DataField="phone" HeaderText="联系电话" />
                            <asp:BoundField DataField="totalmoney" HeaderText="购卡总金额(元)" />
                            <asp:BoundField DataField="transactor" HeaderText="经办人" />
                            <asp:BoundField DataField="inputtime" HeaderText="录入时间" />
                            <asp:BoundField DataField="result" HeaderText="审批状态" />
                            <asp:BoundField DataField="approver" HeaderText="审批人" />
                        </Columns>
                    </asp:GridView>
                </div>
                <div id="RoleWindow" style="width: 910px; position: absolute; display: none; z-index: 999;">
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

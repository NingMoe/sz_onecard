<%@ Page Language="C#" AutoEventWireup="true" CodeFile="GC_OrderReturn.aspx.cs" Inherits="ASP_GroupCard_GC_OrderReturn"
    EnableEventValidation="false" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>订单回退</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="../../js/printorder.js"></script>
    <script type="text/javascript" src="../../js/myext.js"></script>
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
        订单回退
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
                            <td width="8%">
                                <div align="right">
                                    单位名称:</div>
                            </td>
                            <td width="44%" colspan="3">
                                <asp:TextBox ID="txtGroupName" CssClass="inputmid" runat="server" AutoPostBack="true"
                                    OnTextChanged="queryGroupName" MaxLength="50"></asp:TextBox>
                                <asp:DropDownList ID="selCompany" CssClass="inputmid" Width="206" runat="server"
                                    AutoPostBack="true" OnSelectedIndexChanged="selCompany_Changed">
                                </asp:DropDownList>
                            </td>
                            <td width="10%">
                                <div align="right">
                                    联系人:</div>
                            </td>
                            <td width="12%">
                                <asp:TextBox ID="txtName" CssClass="input" runat="server" MaxLength="8"></asp:TextBox>
                            </td>
                            <td width="12%">
                                <div align="right">
                                    审核员工:</div>
                            </td>
                            <td width="14%">
                                <asp:DropDownList ID="ddlApprover" CssClass="inputmid" runat="server">
                                </asp:DropDownList>
                            </td>
                        </tr>
                        <tr>
                            <td width="8%">
                                <div align="right">
                                    金额:</div>
                            </td>
                            <td width="8%">
                                <asp:TextBox ID="txtTotalMoney" CssClass="input" runat="server"></asp:TextBox>
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
                            <td width="8%">
                                <div align="right">
                                    结束日期:</div>
                            </td>
                            <td width="8%">
                                <asp:TextBox runat="server" ID="txtToDate" MaxLength="8" CssClass="input"></asp:TextBox>
                                <ajaxToolkit:CalendarExtender ID="CalendarExtender2" runat="server" TargetControlID="txtToDate"
                                    Format="yyyyMMdd" />
                            </td>
                            <td width="8%">
                                <div align="right">
                                    订单状态:</div>
                            </td>
                            <td width="8%">
                                <asp:DropDownList ID="selApprovalStatus" CssClass="inputmid" runat="server">
                                <asp:ListItem Text="---请选择---" Value=""></asp:ListItem>
                                <asp:ListItem Text="01:录入待审核" Value="01"></asp:ListItem>
                                <asp:ListItem Text="02:财务审核通过" Value="02"></asp:ListItem>
                                <asp:ListItem Text="03:完成分配" Value="03"></asp:ListItem>
                                <asp:ListItem Text="04:制卡中" Value="04"></asp:ListItem>
                                <asp:ListItem Text="05:制卡完成" Value="05"></asp:ListItem>
                                <asp:ListItem Text="06:不关联确认完成" Value="06"></asp:ListItem>
                                </asp:DropDownList>
                            </td>
                        </tr>
                        <tr>
                            <td width="8%">
                                <div align="right">
                                    录入部门:</div>
                            </td>
                            <td width="8%">
                                <asp:DropDownList ID="selDept" CssClass="inputmid" runat="server" AutoPostBack="true"
                                    OnSelectedIndexChanged="selDept_Changed" Enabled="false">
                                </asp:DropDownList>
                            </td>
                            <td width="8%">
                                <div align="right">
                                    录入员工:</div>
                            </td>
                            <td width="8%">
                                <asp:DropDownList ID="selStaff" CssClass="inputmid" runat="server" Enabled="false">
                                </asp:DropDownList>
                            </td>
                            <td colspan="3">
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
                    </tr>
                </table>
                <div class="kuang5" style="overflow:auto;height:300px">
                    <asp:GridView ID="gvOrderList" CssClass="tab2" HeaderStyle-CssClass="tabbt" FooterStyle-CssClass="tabcon"
                        AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel" PagerSettings-Mode="NumericFirstLast"
                        PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top" runat="server"
                        AutoGenerateColumns="false" Width="150%" OnRowCreated="gvOrderList_RowCreated"
                            OnSelectedIndexChanged="gvOrderList_SelectedIndexChanged">
                        <Columns>
                            <asp:BoundField DataField="ORDERNO" HeaderText="订单号" />
                            <asp:BoundField DataField="GROUPNAME" HeaderText="单位名称" />
                            <asp:BoundField DataField="NAME" HeaderText="联系人" />
                            <asp:BoundField DataField="IDCARDNO" HeaderText="身份证号码" />
                            <asp:BoundField DataField="PHONE" HeaderText="联系电话" />
                            <asp:BoundField DataField="totalmoney" HeaderText="购卡总金额(元)" />
                            <asp:BoundField DataField="transactor" HeaderText="经办人" />
                            <asp:BoundField DataField="inputtime" HeaderText="录入时间" />
                            <asp:BoundField DataField="financeapproverno" HeaderText="审核员工" />
                            <asp:BoundField DataField="financeapprovertime" HeaderText="审核时间" />
                            <asp:BoundField DataField="orderstate" HeaderText="订单状态" />
                        </Columns>
                        <EmptyDataTemplate>
                            <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                <tr class="tabbt">
                                    <td>
                                        订单号
                                    </td>
                                    <td>
                                        单位名称
                                    </td>
                                    <td>
                                        联系人
                                    </td>
                                    <td>
                                        身份证号码
                                    </td>
                                    <td>
                                        联系电话
                                    </td>
                                    <td>
                                        购卡总金额(元)
                                    </td>
                                    <td>
                                        经办人
                                    </td>
                                    <td>
                                        录入时间
                                    </td>
                                    <td>
                                        审核员工
                                    </td>
                                    <td>
                                        审核时间
                                    </td>
                                    <td>
                                        订单状态
                                    </td>
                                </tr>
                            </table>
                        </EmptyDataTemplate>
                    </asp:GridView>
                </div>
                <%--<div id="RoleWindow" style="width: 910px; position: absolute; display: none; z-index: 999;">
                </div>--%>
            </div>
            <div class="con">
                <div class="jieguo">
                    详细信息</div>
                <div class="kuang5" runat="server" id="divInfo">
                </div>
            </div>
            <div class="btns">
                <table width="95%" border="0" cellpadding="0" cellspacing="0">
                    <tr>
                        <td width="80%">
                            &nbsp;
                        </td>
                        <td align="right">
                            <asp:Button ID="btnOrderReturn" CssClass="button1" Enabled="false" runat="server"
                                Text="回 退" OnClick="btnOrderReturn_Click" />
                        </td>
                    </tr>
                </table>
            </div>
        </ContentTemplate>
        <%--<Triggers>
            <asp:PostBackTrigger ControlID="btnExport" />
        </Triggers>--%>
    </asp:UpdatePanel>
    </form>
</body>
</html>

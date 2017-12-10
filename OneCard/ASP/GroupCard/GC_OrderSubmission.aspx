<%@ Page Language="C#" AutoEventWireup="true" EnableEventValidation="false" CodeFile="GC_OrderSubmission.aspx.cs"
    Inherits="ASP_GroupCard_GC_OrderSubmission" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>订单完成确认</title>
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
        订单完成确认
    </div>
    <ajaxToolkit:ToolkitScriptManager EnableScriptGlobalization="true" EnableScriptLocalization="true"
        ID="ScriptManager1" runat="server" />
    <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
            <asp:BulletedList ID="bulMsgShow" runat="server" />
            <script runat="server">public override void ErrorMsgShow() { ErrorMsgHelper(bulMsgShow); }</script>
            <asp:HiddenField ID="hidHasChargeCard" runat="server" />
            <div class="con">
                <div class="base">
                    订单完成确认</div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td width="8%">
                                <div align="right">
                                    单位名称:</div>
                            </td>
                            <td width="8%">
                                <asp:TextBox ID="txtCompany" CssClass="inputmid" runat="server" AutoPostBack="true"
                                    OnTextChanged="queryCompany"></asp:TextBox>
                            </td>
                            <td colspan="2">
                                <asp:DropDownList ID="selCompany" CssClass="inputmid" Width="206" AutoPostBack="true"
                                    OnSelectedIndexChanged="SelectedIndexChanged" runat="server">
                                </asp:DropDownList>
                            </td>
                            <td width="8%">
                                <div align="right">
                                    联系人:</div>
                            </td>
                            <td width="8%">
                                <asp:TextBox ID="txtName" CssClass="input" runat="server"></asp:TextBox>
                            </td>
                            <td width="8%">
                                <div align="right">
                                    部门:</div>
                            </td>
                            <td width="8%">
                                <asp:DropDownList ID="selDept" CssClass="inputmid" runat="server" AutoPostBack="true"
                                    OnSelectedIndexChanged="selDept_Changed">
                                </asp:DropDownList>
                            </td>
                        </tr>
                        <tr>
                            <td width="8%">
                                <div align="right">
                                    经办人:</div>
                            </td>
                            <td width="8%">
                                <asp:DropDownList ID="selStaff" CssClass="inputmid" runat="server">
                                </asp:DropDownList>
                            </td>
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
                        </tr>
                        <tr>
                            <td colspan="7">
                            </td>
                            <td>
                                <asp:Button runat="server" CssClass="button1" ID="btnQuery" Text="查询" OnClick="btnQuery_Click" />
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
                <div class="kuang5">
                    <div style="height: 200px; overflow: auto; display: block">
                        <asp:GridView ID="gvOrderList" CssClass="tab2" HeaderStyle-CssClass="tabbt" FooterStyle-CssClass="tabcon"
                            AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel" PagerSettings-Mode="NumericFirstLast"
                            PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top" runat="server"
                            AutoGenerateColumns="false" Width="100%" OnRowCreated="gvOrderList_RowCreated"
                            OnSelectedIndexChanged="gvOrderList_SelectedIndexChanged">
                            <Columns>
                                <asp:BoundField DataField="orderno" HeaderText="订单号" />
                                <asp:BoundField DataField="groupname" HeaderText="单位名称" />
                                <asp:BoundField DataField="name" HeaderText="联系人" />
                                <asp:BoundField DataField="idcardno" HeaderText="身份证号码" />
                                <asp:BoundField DataField="phone" HeaderText="联系电话" />
                                <asp:BoundField DataField="totalmoney" HeaderText="购卡总金额(元)" />
                                <asp:BoundField DataField="transactor" HeaderText="经办人" />
                                <asp:BoundField DataField="inputtime" HeaderText="录入时间" />
                                <asp:BoundField DataField="ORDERSTATE" HeaderText="订单状态" />
                            </Columns>
                        </asp:GridView>
                    </div>
                </div>
            </div>
            <%--<div class="con" runat="server" id="divSale" visible="false">
                <div class="base">
                    直销</div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td width="10%" align="right">
                                付款方式:
                            </td>
                            <td width="20%">
                                <asp:DropDownList CssClass="input" AutoPostBack="true" runat="server" ID="selPayMode"
                                    OnSelectedIndexChanged="selPayMode_SelectedIndexChanged">
                                    <asp:ListItem Value="" Text="---请选择---"></asp:ListItem>
                                    <asp:ListItem Value="1" Text="1:现金方式"></asp:ListItem>
                                    <asp:ListItem Value="0" Text="0:转账方式"></asp:ListItem>
                                    <asp:ListItem Value="2" Text="2:报销方式"></asp:ListItem>
                                </asp:DropDownList>
                                <span class="red">*</span>
                            </td>
                            <td width="10%" align="right">
                                到帐标记:
                            </td>
                            <td width="20%">
                                <asp:DropDownList CssClass="input" Enabled="false" AutoPostBack="true" runat="server"
                                    ID="selRecvTag" OnSelectedIndexChanged="selPayMode_SelectedIndexChanged">
                                    <asp:ListItem Value="" Text="---请选择---"></asp:ListItem>
                                    <asp:ListItem Value="1" Text="1:已到帐"></asp:ListItem>
                                    <asp:ListItem Value="0" Text="0:未到帐"></asp:ListItem>
                                </asp:DropDownList>
                                <span class="red">*</span>
                            </td>
                            </td>
                        </tr>
                        <tr>
                            <td width="10%" align="right">
                                到帐日期:
                            </td>
                            <td colspan="3">
                                <asp:TextBox Enabled="false" runat="server" ID="txtAccRecvDate" CssClass="input"></asp:TextBox>
                                <span class="red">*</span>(“转账或报销方式，已到帐”时必需)
                                <ajaxToolkit:CalendarExtender ID="FCalendar" runat="server" TargetControlID="txtAccRecvDate"
                                    Format="yyyyMMdd" />
                        </tr>
                        <tr>
                            <td width="10%" align="right">
                                备注:
                            </td>
                            <td colspan="4">
                                <asp:TextBox runat="server" ID="txtRemark" CssClass="inputmax" MaxLength="200"></asp:TextBox>
                            </td>
                        </tr>
                    </table>
                </div>
            </div>--%>
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
                        </td>
                        <td align="right">
                            <asp:Button ID="btnGetCard" CssClass="button1" Text="完成确认" runat="server" OnClick="btnGetCard_Click" />
                        </td>
                    </tr>
                </table>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
    </form>
</body>
</html>

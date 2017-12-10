<%@ Page Language="C#" AutoEventWireup="true" CodeFile="SD_SpeAdjustAccQuery.aspx.cs"
    Inherits="ASP_SpecialDeal_SD_SpeAdjustAccQuery" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>特殊调帐查询</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
    <div class="tb">
        异常处理->特殊调帐查询</div>
    <ajaxToolkit:ToolkitScriptManager runat="Server" EnableScriptGlobalization="true"
        EnableScriptLocalization="true" ID="ScriptManager2" />
    <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
            <asp:BulletedList ID="bulMsgShow" runat="server" />
            <script runat="server">public override void ErrorMsgShow() { ErrorMsgHelper(bulMsgShow); }</script>
            <div class="con">
                <div>
                    <div class="card">
                        调帐查询</div>
                    <div class="kuang5">
                        <table border="0" cellpadding="0" cellspacing="0" class="text25">
                            <tr>
                                <td>
                                    <div align="right">
                                        行业名称:</div>
                                </td>
                                <td width="30%">
                                    <asp:DropDownList ID="selCalling" CssClass="inputmidder" runat="server" AutoPostBack="true"
                                        OnSelectedIndexChanged="selCalling_SelectedIndexChanged" />
                                </td>
                                <td>
                                    单位名称:
                                </td>
                                <td>
                                    <asp:DropDownList ID="selCorp" CssClass="inputmidder" runat="server" AutoPostBack="true"
                                        OnSelectedIndexChanged="selCorp_SelectedIndexChanged" />
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <div align="right">
                                        <asp:Label runat="server" ID="labUnitName" Text="部门名称" />:</div>
                                </td>
                                <td width="30%">
                                    <asp:DropDownList ID="selDepart" CssClass="inputmidder" runat="server" OnSelectedIndexChanged="selDepart_SelectedIndexChanged" />
                                </td>
                                <td>
                                    <div align="right">
                                        结算单元:</div>
                                </td>
                                <td>
                                    <asp:DropDownList ID="selBalUint" CssClass="inputmidder" runat="server">
                                    </asp:DropDownList>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <div align="right">
                                        录入员工部门:</div>
                                </td>
                                <td>
                                    <div align="left">
                                        <asp:DropDownList ID="selInSideDept" runat="Server" CssClass="inputmidder" OnSelectedIndexChanged="selDept_Changed"
                                            AutoPostBack="true">
                                        </asp:DropDownList>
                                    </div>
                                </td>
                                <td>
                                    <div align="right">
                                        录入员工:</div>
                                </td>
                                <td>
                                    <div align="left">
                                        <asp:DropDownList ID="selInStaff" runat="Server" CssClass="input" Width="200px">
                                        </asp:DropDownList>
                                    </div>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <div align="right">
                                        录入日期:</div>
                                </td>
                                <td>
                                    <div>
                                        <asp:TextBox ID="txtInStartDate" runat="server" CssClass="input" MaxLength="8"></asp:TextBox>
                                        <ajaxToolkit:CalendarExtender ID="BeginCalendar" runat="server" TargetControlID="txtInStartDate"
                                            Format="yyyyMMdd" PopupPosition="BottomLeft" />
                                        -
                                        <asp:TextBox ID="txtInEndDate" runat="server" CssClass="input" MaxLength="8"></asp:TextBox>
                                        <ajaxToolkit:CalendarExtender ID="CalendarExtender1" runat="server" TargetControlID="txtInEndDate"
                                            Format="yyyyMMdd" PopupPosition="BottomLeft" />
                                    </div>
                                </td>
                                <td>
                                    <div align="right">
                                        IC卡号:</div>
                                </td>
                                <td colspan="2">
                                    <asp:TextBox ID="txtCardNo" runat="server" CssClass="input" MaxLength="16"></asp:TextBox>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <div align="right">
                                        审核状态:</div>
                                </td>
                                <td>
                                    <div>
                                        <asp:DropDownList ID="selChkState" runat="server" CssClass="input">
                                        </asp:DropDownList>
                                    </div>
                                </td>
                                <td>
                                    <div align="right">
                                        &nbsp;</div>
                                </td>
                                <td>
                                    <div>
                                        &nbsp;
                                    </div>
                                </td>
                            </tr>
                        </table>
                    </div>
                </div>
                <table border="0" width="95%">
                    <tr>
                        <td align="left">
                            <div class="jieguo">
                                调帐信息</div>
                        </td>
                        <td align="right">
                            <asp:Button ID="btnQuery" runat="server" Text="查询" CssClass="button1" OnClick="btnQuery_Click" />
                            <asp:Button ID="btnExport" CssClass="button1" runat="server" Text="导出Excel"
                                OnClick="btnExport_Click" />
                        </td>
                    </tr>
                </table>
                <div class="kuang5">
                    <div id="gdtb" style="height: 65%">
                        <asp:GridView ID="gvResult" runat="server" CssClass="tab1" Width="1600" HeaderStyle-CssClass="tabbt"
                            AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel" AllowPaging="True"
                            PageSize="200" PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="Left"
                            PagerStyle-VerticalAlign="Top" AutoGenerateColumns="true" OnPageIndexChanging="gvResult_Page"
                            OnRowDataBound="gvResult_RowDataBound" EmptyDataText="没有数据记录!" />
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

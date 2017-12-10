<%@ Page Language="C#" AutoEventWireup="true" CodeFile="RM_CardStatQuery.aspx.cs"
    Inherits="ASP_ResourceManage_RM_CardStatQuery" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>充值卡统计查询</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
    <ajaxToolkit:ToolkitScriptManager EnableScriptGlobalization="true" EnableScriptLocalization="true"
        ID="ScriptManager1" runat="server" />
    <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
            <div class="tb">
                卡片管理->充值卡统计查询
            </div>
            <asp:BulletedList ID="bulMsgShow" runat="server" />
            <script runat="server">public override void ErrorMsgShow() { ErrorMsgHelper(bulMsgShow); }</script>
            <div class="con">
                <div class="base">
                    查询条件</div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td align="right">
                                厂家：
                            </td>
                            <td>
                                <div align="left">
                                    <asp:DropDownList ID="selCardCorp" runat="server" CssClass="input">
                                    </asp:DropDownList>
                                </div>
                            </td>
                            <td align="right">
                                年份：
                            </td>
                            <td>
                                <div align="left">
                                    <asp:TextBox ID="txtYear" CssClass="input" runat="server" Text="13" MaxLength="2"></asp:TextBox>
                                </div>
                            </td>
                            <td align="right">
                                批次：
                            </td>
                            <td>
                                <div align="left">
                                    <asp:TextBox ID="txtCardBatch" CssClass="input" runat="server" MaxLength="2"></asp:TextBox>(01~99)
                                </div>
                            </td>
                            <td>
                                <div align="right">
                                    卡片状态:</div>
                            </td>
                            <td>
                                <asp:DropDownList ID="selCardState" CssClass="input" runat="server">
                                </asp:DropDownList>
                            </td>
                            <td>
                                <asp:Button ID="btnQuery" CssClass="button1" runat="server" Text="查询" OnClick="btnQuery_Click" />
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
                            <asp:Button ID="btnExport" CssClass="button1" runat="server" Text="导出Excel" 
                                onclick="btnExport_Click" />
                        </td>
                    </tr>
                </table>
                <div class="kuang5">
                    <div id="gdtb" style="height: 310px">
                        <asp:GridView ID="gvResult" runat="server" Width="98%" CssClass="tab1" HeaderStyle-CssClass="tabbt"
                            AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel" AllowPaging="True"
                            PageSize="10" PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left"
                            PagerStyle-VerticalAlign="Top" OnPageIndexChanging="gvResult_PageIndexChanging"
                            AutoGenerateColumns="true" OnRowDataBound="lvwQuery_RowDataBound" EmptyDataText="没有数据记录!">
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

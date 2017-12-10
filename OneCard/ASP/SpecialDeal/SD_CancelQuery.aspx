<%@ Page Language="C#" AutoEventWireup="true" CodeFile="SD_CancelQuery.aspx.cs" Inherits="ASP_SpecialDeal_SD_CancelQuery" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>作废交易查询</title>

    <script type="text/javascript" src="../../js/myext.js"></script>

    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
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

    <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
            <div class="tb">
                异常处理->作废交易查询
            </div>
            <asp:BulletedList ID="bulMsgShow" runat="server" />

            <script runat="server">public override void ErrorMsgShow() { ErrorMsgHelper(bulMsgShow); }</script>

            <div class="con">
                <div class="base">
                    查询条件</div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td align="right" width="12%">
                                结算单元名称:
                            </td>
                            <td width="45%">
                                <asp:TextBox runat="server" CssClass="input" ID="txtBalunitNo" MaxLength="8" 
                                    ontextchanged="txtBalunitNo_TextChanged" AutoPostBack="true"/>
                                <asp:DropDownList ID="selDeptName" runat="server" Width="170px"
                                    AutoPostBack="true" 
                                    onselectedindexchanged="selDeptName_SelectedIndexChanged">
                                </asp:DropDownList>
                            </td>
                            <td align="right" width="8%">
                                作废日期:
                            </td>
                            <td width="35%">
                                <asp:TextBox ID="txtCancelFromCardNo" CssClass="input" runat="server" MaxLength="16"></asp:TextBox>
                                <ajaxToolkit:CalendarExtender ID="CalendarExtender1" runat="server" TargetControlID="txtCancelFromCardNo"
                                    Format="yyyyMMdd" PopupPosition="BottomLeft" />
                                -
                                <asp:TextBox ID="txtCancelToCardNo" CssClass="input" runat="server" MaxLength="16"></asp:TextBox>
                                <ajaxToolkit:CalendarExtender ID="CalendarExtender2" runat="server" TargetControlID="txtCancelToCardNo"
                                    Format="yyyyMMdd" PopupPosition="BottomLeft" />
                            </td>

                        </tr>
                        <tr>
                            <td align="right">
                                卡号:
                            </td>
                            <td>
                                <asp:TextBox runat="server" CssClass="input" ID="txtCardNo" />
                            </td>
                            <td align="right">
                                交易日期:
                            </td>
                            <td>
                                <asp:TextBox ID="txtTradeFromCardNo" CssClass="input" runat="server" MaxLength="16"></asp:TextBox>
                                <ajaxToolkit:CalendarExtender ID="CalendarExtender3" runat="server" TargetControlID="txtTradeFromCardNo"
                                    Format="yyyyMMdd" PopupPosition="BottomLeft" />
                                -
                                <asp:TextBox ID="txtTradeToCardNo" CssClass="input" runat="server" MaxLength="16"></asp:TextBox>
                                <ajaxToolkit:CalendarExtender ID="CalendarExtender4" runat="server" TargetControlID="txtTradeToCardNo"
                                    Format="yyyyMMdd" PopupPosition="BottomLeft" />
                            </td>
                        </tr>
                        <tr>
                             <td align="right">
                                查询方式:
                            </td>
                            <td>
                                <asp:DropDownList ID="selQuery" CssClass="input" runat="server" OnSelectedIndexChanged="selQuery_SelectedIndexChanged"
                                    AutoPostBack="true">
                                    <asp:ListItem Text="0: 汇总" Value="0" />
                                    <asp:ListItem Text="1: 明细" Value="1" />
                                </asp:DropDownList>
                            </td>
                            <td align="right">
                            </td>
                            <td align="center">
                                <asp:Button ID="btnQuery" CssClass="button1" runat="server" Text="查询" OnClick="btnQuery_Click" />
                            </td>
                        </tr>
                    </table>
                </div>
                <div class="jieguo">
                    查询结果
                </div>
                <div class="kuang5">
                    <div class="gdtb" style="height: 65%">
                        <asp:GridView ID="gvTotalResult" runat="server" CssClass="tab2" Width="98%" HeaderStyle-CssClass="tabbt"
                            AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel" PagerSettings-Mode="NumericFirstLast"
                            PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top" AutoGenerateColumns="True"
                            ShowFooter="true" EmptyDataText="没有数据记录!" OnRowDataBound="gvTotalResult_RowDataBound">
                        </asp:GridView>
                        <asp:GridView ID="gvDetailResult" runat="server" Visible="false" CssClass="tab2"
                            AllowPaging="true" PageSize="100" Width="2000" HeaderStyle-CssClass="tabbt" AlternatingRowStyle-CssClass="tabjg"
                            SelectedRowStyle-CssClass="tabsel" PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left"
                            PagerStyle-VerticalAlign="Top" AutoGenerateColumns="True" EmptyDataText="没有数据记录!"
                            OnRowDataBound="gvDetailResult_RowDataBound" OnPageIndexChanging="gvDetailResult_Page">
                        </asp:GridView>
                    </div>
                </div>
        </ContentTemplate>
    </asp:UpdatePanel>
    </form>
</body>
</html>

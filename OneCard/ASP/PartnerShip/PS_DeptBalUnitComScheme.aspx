<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PS_DeptBalUnitComScheme.aspx.cs"
    Inherits="ASP_PartnerShip_PS_DeptBalUnitComScheme" EnableEventValidation="false" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>网点结算单元佣金方案关系维护</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />

    <script type="text/javascript" src="../../js/myext.js"></script>

</head>
<body>
    <form id="form1" runat="server">
    <div class="tb">
        合作伙伴->网点结算单元佣金方案关系维护</div>
    <ajaxToolkit:ToolkitScriptManager runat="Server" EnableScriptGlobalization="true"
        EnableScriptLocalization="true" ID="ScriptManager2" />

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
            <asp:BulletedList ID="bulMsgShow" runat="server" />

            <script runat="server">public override void ErrorMsgShow() { ErrorMsgHelper(bulMsgShow); }</script>

            <div class="con">
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td align="right">
                                单元类型:
                            </td>
                            <td>
                                <asp:DropDownList ID="ddlBalType" CssClass="input" runat="server" OnSelectedIndexChanged="ddlBalType_SelectedIndexChanged"
                                    AutoPostBack="true">
                                    <asp:ListItem Text="---请选择---" Value=""></asp:ListItem>
                                    <asp:ListItem Text="0:自营网点" Value="0"></asp:ListItem>
                                    <asp:ListItem Text="1:代理网点" Value="1"></asp:ListItem>
                                    <asp:ListItem Text="2:代理商户" Value="2"></asp:ListItem>
                                </asp:DropDownList>
                            </td>
                            <td>
                                <div align="right">
                                    结算单元:</div>
                            </td>
                            <td>
                                <asp:DropDownList ID="ddlBalUnit" CssClass="inputmidder" runat="server" />
                            </td>
                            <td>
                                <div align="right">
                                    佣金方案:</div>
                            </td>
                            <td>
                                <asp:DropDownList ID="ddlComScheme" CssClass="inputmid" runat="server" />
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    业务类型:</div>
                            </td>
                            <td>
                                <asp:DropDownList ID="ddlTradeTypeCode" CssClass="inputmid" runat="server" />
                            </td>
                            <td>
                                <div align="right">
                                    到期:</div>
                            </td>
                            <td>
                                <asp:DropDownList ID="selExpiration" CssClass="inputmid" runat="server" />
                            </td>
                            <td>
                                &nbsp;
                            </td>
                            <td width="9%" align="right">
                                <asp:Button ID="btnQuery" runat="server" Text="查询" CssClass="button1" OnClick="btnQuery_Click" />
                            </td>
                        </tr>
                    </table>
                </div>
                <div class="jieguo">
                    网点结算单元-佣金方案列表</div>
                <div class="kuang5">
                    <div class="gdtb" style="height: 260px">
                        <asp:GridView ID="lvwBalComSQuery" runat="server" Width="98%" CssClass="tab1" HeaderStyle-CssClass="tabbt"
                            AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel" AllowPaging="true"
                            PageSize="50" PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left"
                            OnPageIndexChanging="lvwBalComSQuery_Page" PagerStyle-VerticalAlign="Top" AutoGenerateColumns="False"
                            OnSelectedIndexChanged="lvwBalComSQuery_SelectedIndexChanged" OnRowCreated="lvwBalComSQuery_RowCreated">
                            <Columns>
                                <asp:BoundField DataField="BALUNIT" HeaderText="结算单元" />
                                <asp:BoundField DataField="TRADETYPE" HeaderText="业务类型" />
                                <asp:BoundField DataField="CANCELTRADE" HeaderText="返销类型" />
                                <asp:BoundField DataField="NAME" HeaderText="佣金方案" />
                                <asp:BoundField DataField="BEGINTIME" HeaderText="规则起始时间" DataFormatString="{0:yyyy-MM}"
                                    HtmlEncode="False" />
                                <asp:BoundField DataField="ENDTIME" HeaderText="规则终止时间" DataFormatString="{0:yyyy-MM}"
                                    HtmlEncode="False" />
                            </Columns>
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                        <td>
                                            结算单元
                                        </td>
                                        <td>
                                            业务类型
                                        </td>
                                        <td>
                                            返销类型
                                        </td>
                                        <td>
                                            佣金方案
                                        </td>
                                        <td>
                                            规则起始时间
                                        </td>
                                        <td>
                                            规则终止时间
                                        </td>
                                    </tr>
                                </table>
                            </EmptyDataTemplate>
                        </asp:GridView>
                    </div>
                </div>
                <div class="card">
                    网点结算单元-佣金方案信息</div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td>
                                <div align="right">
                                    结算单元:</div>
                            </td>
                            <td colspan="3">
                                <asp:TextBox ID="txtBalUnitName" CssClass="inputmid" runat="server" AutoPostBack="true"
                                    OnTextChanged="txtBalUnitName_Changed"></asp:TextBox>
                                <asp:DropDownList ID="selBalUnit" CssClass="inputmidder" runat="server">
                                </asp:DropDownList>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    业务类型:</div>
                            </td>
                            <td>
                                <asp:DropDownList ID="selTradeTypeCode" CssClass="inputmidder" runat="server">
                                </asp:DropDownList>
                            </td>
                            <td>
                                <div align="right">
                                    返销类型:</div>
                            </td>
                            <td>
                                <asp:DropDownList ID="selCancelCode" CssClass="inputmidder" runat="server">
                                </asp:DropDownList>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    佣金方案:</div>
                            </td>
                            <td>
                                <asp:DropDownList ID="selComScheme" CssClass="inputmidder" runat="server">
                                </asp:DropDownList>
                            </td>
                            <td>
                                <div align="right">
                                    方案起始年月:</div>
                            </td>
                            <td colspan="3">
                                <asp:TextBox ID="txtBeginTime" runat="server" CssClass="input" MaxLength="7"></asp:TextBox>
                                <ajaxToolkit:CalendarExtender ID="BeginCalendar" runat="server" TargetControlID="txtBeginTime"
                                    Format="yyyy-MM" PopupPosition="TopLeft" />
                                终止年月:
                                <asp:TextBox ID="txtEndTime" runat="server" CssClass="input" MaxLength="7"></asp:TextBox>
                                <ajaxToolkit:CalendarExtender ID="EndCalendar" runat="server" TargetControlID="txtEndTime"
                                    Format="yyyy-MM" PopupPosition="TopLeft" />
                                <asp:CheckBox ID="chkEndDate" runat="server" OnCheckedChanged="chkEndDate_CheckedChanged"
                                    AutoPostBack="true" />无限期
                            </td>
                        </tr>
                        <tr>
                            <td>
                                &nbsp;
                            </td>
                            <td>
                                &nbsp;
                            </td>
                            <td>
                                &nbsp;
                            </td>
                            <td align="right">
                                &nbsp;<asp:Button ID="btnAdd" runat="server" Text="增加" CssClass="button1" OnClick="btnAdd_Click" />
                                &nbsp;<asp:Button ID="btnDel" runat="server" Text="删除" CssClass="button1" OnClick="btnDel_Click" />
                                &nbsp;<asp:Button ID="btnModify" runat="server" Text="修改" CssClass="button1" OnClick="btnModify_Click" />
                            </td>
                        </tr>
                    </table>
                </div>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
    </form>
</body>
</html>

<%@ Page Language="C#" AutoEventWireup="true" CodeFile="FI_DBalunitAccTrade.aspx.cs"
    Inherits="ASP_Financial_FI_DBalunitAccTrade" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>网点预付款清单</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />

    <script type="text/javascript" src="../../js/print.js"></script>

    <script type="text/javascript" src="../../js/myext.js"></script>

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

    <asp:UpdatePanel ID="UpdatePanel1" UpdateMode="Conditional" runat="server">
        <ContentTemplate>
            <div class="tb">
                财务管理->网点预付款清单
            </div>
            <asp:HiddenField ID="hidNo" runat="server" Value="" />
            <asp:BulletedList ID="bulMsgShow" runat="server" />

            <script runat="server">public override void ErrorMsgShow() { ErrorMsgHelper(bulMsgShow); }</script>

            <div class="con">
                <div class="base">
                    查询条件</div>
                <div class="kuang5">
                    <table border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td width="8%">
                                <div align="right">
                                    营业厅:</div>
                            </td>
                            <td width="40%" align="left">
                                <asp:TextBox ID="txtBalUnitName" CssClass="inputmid" runat="server" AutoPostBack="true"
                                    OnTextChanged="txtBalUnitName_Changed"></asp:TextBox>
                                <asp:DropDownList ID="selBalUnit" CssClass="input" runat="server" Width="190px" AutoPostBack="true"
                                    OnSelectedIndexChanged="selBalUnit_Change">
                                </asp:DropDownList>
                            </td>
                            <td width="10%">
                                <div align="right">
                                    开始日期:</div>
                            </td>
                            <td width="10%">
                                <asp:TextBox runat="server" ID="txtFromDate" MaxLength="8" CssClass="input"></asp:TextBox>
                                <ajaxToolkit:CalendarExtender ID="FCalendar1" runat="server" TargetControlID="txtFromDate"
                                    Format="yyyyMMdd" />
                            </td>
                            <td width="10%">
                                <div align="right">
                                    结束日期:</div>
                            </td>
                            <td width="10%">
                                <asp:TextBox runat="server" ID="txtToDate" MaxLength="8" CssClass="input"></asp:TextBox>
                                <ajaxToolkit:CalendarExtender ID="FCalendar2" runat="server" TargetControlID="txtToDate"
                                    Format="yyyyMMdd" />
                            </td>
                            <td width="2%">
                            </td>
                            <td width="10%" align="left">
                                <asp:Button ID="btnQuery" CssClass="button1" runat="server" Text="查询" OnClick="btnQuery_Click" />
                            </td>
                        </tr>
                    </table>
                </div>
                <div class="base">
                    网点预付款余额
                </div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text20">
                        <tr>
                            <td style="width: 12%" align="right">
                                预付款余额:
                            </td>
                            <td style="width: 12%">
                                <asp:Label ID="labPrepay" runat="server" />元
                            </td>
                            <td style="width: 12%" align="right">
                                预付款预警值:
                            </td>
                            <td style="width: 12%">
                                <asp:Label ID="labPrepayWarnLine" runat="server" />元
                            </td>
                            <td style="width: 12%" align="right">
                                预付款最低值:
                            </td>
                            <td style="width: 12%" colspan="3">
                                <asp:Label ID="labPrepayLimitLine" runat="server" />元
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
                        </td>
                    </tr>
                </table>
                <div id="printarea" class="kuang5">
                    <div class="gdtb" style="height: 330px;">
                        <asp:GridView ID="gvResult" runat="server" CssClass="tab1" Width="98%" HeaderStyle-CssClass="tabbt"
                            AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel" PageSize="15"
                            AllowPaging="true" PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="Left"
                            PagerStyle-VerticalAlign="Top" AutoGenerateColumns="False" OnRowDataBound="gvResult_RowDataBound"
                            OnPageIndexChanging="gvResult_Page" EmptyDataText="没有数据记录!">
                            <PagerSettings Mode="NumericFirstLast" />
                            <Columns>
                                <asp:BoundField DataField="TRADEID" HeaderText="业务流水号" />
                                <asp:BoundField DataField="TRADETYPECODE" HeaderText="操作类型" />
                                <asp:BoundField DataField="DBALUNIT" HeaderText="营业厅" />
                                <asp:BoundField DataField="CURRENTMONEY" HeaderText="账户变动￥" />
                                <asp:BoundField DataField="PREMONEY" HeaderText="发生前￥" />
                                <asp:BoundField DataField="NEXTMONEY" HeaderText="发生后￥" />
                                <asp:BoundField DataField="STAFFNAME" HeaderText="操作员工" />
                                <asp:BoundField DataField="OPERATETIME" HeaderText="操作时间" />
                                <asp:BoundField DataField="CANCELTAG" HeaderText="回退标志" />
                                <asp:BoundField DataField="CARDNO" HeaderText="卡号" />
                                <asp:BoundField DataField="TRADETYPE" HeaderText="业务类型" />
                            </Columns>
                            <PagerStyle HorizontalAlign="Left" VerticalAlign="Top" />
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                        <td>
                                            业务流水号
                                        </td>
                                        <td>
                                            操作类型
                                        </td>
                                        <td>
                                            营业厅
                                        </td>
                                        <td>
                                            发生金额
                                        </td>
                                        <td>
                                            发生前余额
                                        </td>
                                        <td>
                                            发生后余额
                                        </td>
                                        <td>
                                            操作时间
                                        </td>
                                        <td>
                                            回退标志
                                        </td>
                                        <td>
                                            卡号
                                        </td>
                                        <td>
                                            业务类型
                                        </td>
                                    </tr>
                                </table>
                            </EmptyDataTemplate>
                            <SelectedRowStyle CssClass="tabsel" />
                            <HeaderStyle CssClass="tabbt" />
                            <AlternatingRowStyle CssClass="tabjg" />
                        </asp:GridView>
                    </div>
                </div>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
    </form>
</body>
</html>

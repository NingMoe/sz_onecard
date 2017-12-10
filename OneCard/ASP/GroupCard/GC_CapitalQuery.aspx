<%@ Page Language="C#" AutoEventWireup="true" CodeFile="GC_CapitalQuery.aspx.cs"
    EnableEventValidation="false" Inherits="ASP_GroupCard_GC_CapitalQuery" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="../../js/myext.js"></script>
    <script type="text/javascript" src="../../js/mootools.js"></script>
    <script type="text/javascript" src="../../js/jquery-1.5.min.js"></script>
    <script type="text/javascript" language="javascript">
        function SelectComOrder() {
            $get('hidOrderType').value = "comorder";
            searchComOrder.style.display = "block";
            searchPerOrder.style.display = "none";

            usecard.className = "on";
            chargecard.className = null;

            return false;
        }
        function SelectPerOrder() {
            $get('hidOrderType').value = "perorder";
            searchComOrder.style.display = "none";

            searchPerOrder.style.display = "block";

            usecard.className = null;
            chargecard.className = "on";

            return false;
        }
        function mout() {
            var cardname = $get('hidOrderType').value;
            var object = document.getElementById(cardname);

        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
    <div class="tb">
        订单管理->客户资金查询
    </div>
    <ajaxToolkit:ToolkitScriptManager runat="Server" EnableScriptGlobalization="true"
        EnableScriptLocalization="true" ID="ToolkitScriptManager1" />
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
    <asp:UpdatePanel ID="UpdatePanel2" runat="server">
        <ContentTemplate>
            <asp:BulletedList ID="bulMsgShow" runat="server" />
            <script runat="server">public override void ErrorMsgShow() { ErrorMsgHelper(bulMsgShow); }</script>
            <asp:HiddenField ID="hidOrderType" runat="server" />
            <div style="height: 22px">
                <table>
                    <tr>
                        <td width="10%">
                        </td>
                        <td align="center">
                            <ul class="nav_list">
                                <li runat="server" id="liSupplyStock" visible="true">
                                    <asp:LinkButton ID="usecard" Target="_top" CssClass="on" runat="server" onmouseout="mout();"
                                        OnClientClick="return SelectComOrder()"><span class="signA">单位订单</span></asp:LinkButton></li>
                                <li runat="server" id="liNewCard" visible="true">
                                    <asp:LinkButton ID="chargecard" Target="_top" runat="server" onmouseout="mout();"
                                        OnClientClick="return SelectPerOrder()"><span class="signB">个人订单</span></asp:LinkButton></li>
                            </ul>
                        </td>
                    </tr>
                </table>
            </div>
            <div class="con">
                <div class="card">
                    查询</div>
                <div class="kuang5" id="searchComOrder" style="display: block" runat="server">
                    <div>
                        <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                            <tr>
                                <td>
                                    <div align="right">
                                        单位名称:</div>
                                </td>
                                <td>
                                    <asp:TextBox ID="txtGroupName" CssClass="inputmid" runat="server"></asp:TextBox>
                                </td>
                                <td width="12%">
                                    <div align="right">
                                        单位证件类型:</div>
                                </td>
                                <td width="12%">
                                    <asp:DropDownList ID="selActerPapertype" CssClass="inputmid" runat="server">
                                    </asp:DropDownList>
                                </td>
                                <td width="12%">
                                    <div align="right">
                                        单位证件号码:</div>
                                </td>
                                <td align="left">
                                    <asp:TextBox ID="txtCompaperno" CssClass="inputmid" MaxLength="30" runat="server"></asp:TextBox>
                                </td>
                            </tr>
                            <tr>
                                <td width="12%">
                                    <div align="right">
                                        订单开始日期:</div>
                                </td>
                                <td width="12%">
                                    <asp:TextBox runat="server" ID="txtComFromDate" MaxLength="8" CssClass="inputmid"></asp:TextBox>
                                    <ajaxToolkit:CalendarExtender ID="FComFromDateCalendar" runat="server" TargetControlID="txtComFromDate"
                                        Format="yyyyMM" />
                                </td>
                                <td width="12%">
                                    <div align="right">
                                        订单结束日期:</div>
                                </td>
                                <td width="12%">
                                    <asp:TextBox runat="server" ID="txtComToDate" MaxLength="8" CssClass="inputmid"></asp:TextBox>
                                    <ajaxToolkit:CalendarExtender ID="FComToDateCalendar" runat="server" TargetControlID="txtComToDate"
                                        Format="yyyyMM" />
                                </td>
                            </tr>
                            <tr>
                                <td colspan="6" align="right">
                                    <asp:Button ID="btnComQuery" runat="server" Text="查询" CssClass="button1" OnClick="btnComQuery_Click" />
                                </td>
                            </tr>
                        </table>
                    </div>
                </div>
                <div class="kuang5" id="searchPerOrder" style="display: none" runat="server">
                    <div>
                        <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                            <tr>
                                <td>
                                    <div align="right">
                                        姓名:</div>
                                </td>
                                <td>
                                    <asp:TextBox ID="txtActername" CssClass="inputmid" MaxLength="25" runat="server"></asp:TextBox>
                                </td>
                                <td>
                                    <div align="right">
                                        证件类型:</div>
                                </td>
                                <td>
                                    <asp:DropDownList ID="selPapertype" CssClass="inputmid" runat="server">
                                    </asp:DropDownList>
                                </td>
                                <td>
                                    <div align="right">
                                        证件号码:</div>
                                </td>
                                <td>
                                    <asp:TextBox ID="txtActerPaperno" CssClass="inputmid" MaxLength="30" runat="server"></asp:TextBox>
                                </td>
                            </tr>
                            <tr>
                                <td width="12%">
                                    <div align="right">
                                        订单开始日期:</div>
                                </td>
                                <td width="12%">
                                    <asp:TextBox runat="server" ID="txtPerFromDate" MaxLength="8" CssClass="inputmid"></asp:TextBox>
                                    <ajaxToolkit:CalendarExtender ID="FPerFromDateCalendar" runat="server" TargetControlID="txtPerFromDate"
                                        Format="yyyyMM" />
                                </td>
                                <td width="12%">
                                    <div align="right">
                                        订单结束日期:</div>
                                </td>
                                <td width="12%">
                                    <asp:TextBox runat="server" ID="txtPerToDate" MaxLength="8" CssClass="inputmid"></asp:TextBox>
                                    <ajaxToolkit:CalendarExtender ID="FPerToDateCalendar" runat="server" TargetControlID="txtPerToDate"
                                        Format="yyyyMM" />
                                </td>
                            </tr>
                            <tr>
                                <td colspan="6" align="right">
                                    <asp:Button ID="btnPerQuery" runat="server" Text="查询" CssClass="button1" OnClick="btnPerQuery_Click" />
                                </td>
                            </tr>
                        </table>
                    </div>
                </div>
                <table border="0" width="95%">
                    <tr>
                        <td align="left">
                            <div class="jieguo">
                                查询结果</div>
                        </td>
                        <td align="right">
                            <asp:Button ID="btnExport" CssClass="button1" runat="server" Text="导出Excel" OnClick="btnExport_Click" />
                        </td>
                    </tr>
                </table>
                <div class="kuang5" runat="server" id="divExport">
                    <div style="height: 150px; display: block; overflow: auto" runat="server">
                        <asp:GridView ID="gvResult" runat="server" CssClass="tab1" Width="200%" HeaderStyle-CssClass="tabbt"
                            AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel" AllowPaging="True"
                            PageSize="20" PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="Left"
                            PagerStyle-VerticalAlign="Top" AutoGenerateColumns="False" OnRowCreated="gvResult_RowCreated"
                            OnRowDataBound="gvResult_RowDataBound" OnPageIndexChanging="gvResult_PageIndexChanging"
                            OnSelectedIndexChanged="gvResult_SelectedIndexChanged">
                            <Columns>
                                <asp:BoundField DataField="ORDERNO" HeaderText="订单号" />
                                <asp:BoundField DataField="GROUPNAME" HeaderText="单位名称" />
                                <asp:BoundField DataField="COMPANYPAPERTYPE" HeaderText="单位证件类型" />
                                <asp:BoundField DataField="COMPANYPAPERNO" HeaderText="单位证件号码" />
                                <asp:BoundField DataField="NAME" HeaderText="联系人" />
                                <asp:BoundField DataField="PAPERTYPE" HeaderText="证件类型" />
                                <asp:BoundField DataField="IDCARDNO" HeaderText="证件号码" />
                                <asp:BoundField DataField="PHONE" HeaderText="联系电话" />
                                <asp:BoundField DataField="totalmoney" HeaderText="购卡总金额(元)" />
                                <asp:BoundField DataField="transactor" HeaderText="经办人" />
                                <asp:BoundField DataField="inputtime" HeaderText="录入时间" />
                                <asp:BoundField DataField="orderstate" HeaderText="订单状态" />
                                <asp:BoundField HeaderText="付款方式" />
                                <asp:BoundField DataField="financeapproverno" HeaderText="审批人" />
                                <asp:BoundField DataField="financeapprovertime" HeaderText="审批时间" />
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
                                            订单状态
                                        </td>
                                        <td>
                                            付款方式
                                        </td>
                                        <td>
                                            审批人
                                        </td>
                                        <td>
                                            审批时间
                                        </td>
                                    </tr>
                                </table>
                            </EmptyDataTemplate>
                        </asp:GridView>
                    </div>
                </div>
                <table width="100%">
                    <tr>
                        <td width="50%">
                            <div style="width: 99%; background-color: #ddddff; border: 1px solid #aaaaff; margin-top: 5px;
                                margin-left: 5px;" >
                                <div class="base">
                                    资金来源</div>
                                <div class="kuang5">
                                    <div class="gdtb" style="height: 300px; overflow: auto;">
                                        <asp:GridView ID="gvSource" Width="140%" CssClass="tab1" HeaderStyle-CssClass="tabbt"
                                            FooterStyle-CssClass="tabcon" AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel"
                                            PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top"
                                            runat="server" AutoGenerateColumns="false">
                                            <Columns>
                                                <asp:BoundField DataField="账单号" HeaderText="账单号" />
                                                <asp:BoundField DataField="对方开户行" HeaderText="对方开户行" />
                                                <asp:BoundField DataField="对方户名" HeaderText="对方户名" />
                                                <asp:BoundField DataField="对方账号" HeaderText="对方账号" />
                                                <asp:BoundField DataField="到账银行" HeaderText="到账银行" />
                                                <asp:BoundField DataField="到账帐号" HeaderText="到账帐号" />
                                                <asp:BoundField DataField="金额" HeaderText="金额" />
                                            </Columns>
                                            <EmptyDataTemplate>
                                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                                    <tr class="tabbt">
                                                        <td>
                                                            账单号
                                                        </td>
                                                        <td>
                                                            对方开户行
                                                        </td>
                                                        <td>
                                                            对方户名
                                                        </td>
                                                        <td>
                                                            对方账号
                                                        </td>
                                                        <td>
                                                            到账银行
                                                        </td>
                                                        <td>
                                                            到账帐号
                                                        </td>
                                                        <td>
                                                            金额
                                                        </td>
                                                    </tr>
                                                </table>
                                            </EmptyDataTemplate>
                                        </asp:GridView>
                                    </div>
                                </div>
                            </div>
                        </td>
                        <td width="50%">
                            <div style="width: 98%; background-color: #ddddff; border: 1px solid #aaaaff; margin-top: 5px;
                                margin-left: 5px;" id="Div2">
                                <div class="jieguo">
                                    资金去向</div>
                                <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                                    <tr>
                                        <td width="8%">
                                            <div align="right">
                                                消费开始日期:</div>
                                        </td>
                                        <td width="8%">
                                            <asp:TextBox runat="server" ID="txtFromDate" MaxLength="8" CssClass="input"></asp:TextBox>
                                            <ajaxToolkit:CalendarExtender ID="CFromDate" runat="server" TargetControlID="txtFromDate"
                                                Format="yyyyMMdd" />
                                        </td>
                                        <td width="8%">
                                            <div align="right">
                                                消费结束日期:</div>
                                        </td>
                                        <td width="8%">
                                            <asp:TextBox runat="server" ID="txtToDate" MaxLength="8" CssClass="input"></asp:TextBox>
                                            <ajaxToolkit:CalendarExtender ID="CToDate" runat="server" TargetControlID="txtToDate"
                                                Format="yyyyMMdd" />
                                        </td>
                                        <td width="8%" align="right">
                                         <asp:Button ID="Button1" runat="server" Text="查询" CssClass="button1" OnClick="btnQuery_Click" />
                                         </td>

                                    </tr>
                                   
                                </table>
                                <div class="kuang5">
                                    <div class="gdtb" style="height: 270px; overflow: auto;">
                                        <asp:GridView ID="gvTarget" runat="server" Width="100%" CssClass="tab1" HeaderStyle-CssClass="tabbt"
                                            FooterStyle-CssClass="tabcon" AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel"
                                            PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top"
                                            AutoGenerateColumns="False">
                                            <Columns>
                                                <asp:BoundField DataField="商户名称" HeaderText="商户名称" />
                                                <asp:BoundField DataField="结算单元" HeaderText="结算单元" />
                                                <asp:BoundField DataField="金额" HeaderText="金额" />
                                            </Columns>
                                            <EmptyDataTemplate>
                                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                                    <tr class="tabbt">
                                                        <td>
                                                            商户名称
                                                        </td>
                                                        <td>
                                                            结算单元
                                                        </td>
                                                        <td>
                                                            金额
                                                        </td>
                                                    </tr>
                                                </table>
                                            </EmptyDataTemplate>
                                        </asp:GridView>
                                    </div>
                                </div>
                            </div>
                        </td>
                    </tr>
                </table>
            </div>
        </ContentTemplate>
        <Triggers>
            <asp:PostBackTrigger ControlID="btnExport" />
        </Triggers>
    </asp:UpdatePanel>
    </form>
</body>
</html>

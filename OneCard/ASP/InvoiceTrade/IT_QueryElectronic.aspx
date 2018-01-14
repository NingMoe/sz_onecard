<%@ Page Language="C#" AutoEventWireup="true" CodeFile="IT_QueryElectronic.aspx.cs" Inherits="ASP_InvoiceTrade_IT_QueryElectronic" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>电子发票查询</title>
    <script type="text/javascript" src="../../js/print.js"></script>
    <script type="text/javascript" src="../../js/myext.js"></script>
    <script type="text/javascript" src="../../js/currency.js"></script>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <link href="../../css/invoice.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="../../js/jquery-1.5.min.js"></script>
    <script type="text/javascript">
        function submitStockInConfirm() {

            MyExtConfirm('确认', '是否确认红冲', submitStockInConfirmCallback);
            return false;

        }

        function submitStockInConfirmCallback(btn) {
            if (btn == 'no') {
            }
            else {
                $get('btnStockInConfirm').click();
            }
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
    <div class="tb">
        发票 -> 电子发票查询</div>
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
            <!-- #include file="../../ErrorMsg.inc" -->
             <%--<aspControls:PrintHMXXPingZheng ID="ptnPingZheng" runat="server" PrintArea="ptnPingZheng1" />--%>
            <asp:HiddenField ID="hidPrinted" Value="false" runat="server" />
            <div class="con">
                <div class="card">
                    查询条件</div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td width="7%">
                                <div align="right">
                                   卡号：</div>
                            </td>
                            <td width="15%">
                                <asp:TextBox ID="txtBeginCardNo" CssClass="input" runat="server" MaxLength="19"></asp:TextBox>
                            </td>
                            <td width="7%">
                                <div align="right">
                                    发票号码：
                                </div>
                            </td>
                            <td width="15%">
                                <asp:TextBox ID="txtInvoiceNo" CssClass="input" runat="server" MaxLength="19"></asp:TextBox>
                            </td>
                            <td width="7%">
                                <div align="right">
                                    订单号:</div>
                            </td>
                            <td width="15%">
                                <asp:TextBox ID="txtOrderNo" CssClass="inputmid" runat="server" MaxLength="20"></asp:TextBox>

                            </td>
                            <td width="7%">
                                <div align="right">
                                    开票单位名称:</div>
                            </td>
                            <td width="15%">
                                <asp:TextBox ID="txtGroupName" CssClass="inputlong" runat="server" MaxLength="40"></asp:TextBox>
                            </td>
                        </tr>
                        <tr> 
                            <td>
                                <div align="right">
                                    开始日期：</div>
                            </td>
                            <td>
                                <asp:TextBox ID="txtBeginDate" CssClass="input" runat="server" MaxLength="10"></asp:TextBox>
                                <ajaxToolkit:CalendarExtender ID="BeginCalendar" runat="server" TargetControlID="txtBeginDate"
                                    Format="yyyyMMdd" />
                            </td>
                            <td>
                                <div align="right">
                                    结束日期：</div>
                            </td>
                            <td>
                                <asp:TextBox ID="txtEndDate" CssClass="input" runat="server" MaxLength="10"></asp:TextBox>
                                <ajaxToolkit:CalendarExtender ID="EndCalendar" runat="server" TargetControlID="txtEndDate"
                                    Format="yyyyMMdd" />
                            </td>
                            <td><div align="right">部门:</div></td>
                        <td>
                             <asp:DropDownList ID="selDept" CssClass="inputmid" runat="server" AutoPostBack="true" OnSelectedIndexChanged="selDept_Changed"></asp:DropDownList>
                        </td>
                        <td><div align="right">员工:</div></td>
                        <td>
                            <asp:DropDownList ID="selStaff" CssClass="inputmid" runat="server"></asp:DropDownList>
                        </td>
                            <td align="right" >
                                <asp:Button ID="btnQuery" CssClass="button1" OnClick="btnQuery_Click" Text="查询" runat="server" />
                            </td>
                        </tr>
                    </table>
                </div>
                <div class="card">
                    查询结果
                </div>
                <div class="kuang5">
                    <div class="gdtb" style="height: 220px; padding: 5px 0 0 0;">
                        <asp:GridView ID="lvwInvoice" runat="server" Width="100%"  CssClass="tab1" HeaderStyle-CssClass="tabbt"
                            AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel" AllowPaging="True"
                            PageSize="200" OnPageIndexChanging="lvwInvoice_Page" PagerSettings-Mode="NumericFirstLast"
                            PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top" AutoGenerateColumns="False"
                            OnSelectedIndexChanged="lvwInvoice_SelectedIndexChanged" OnRowCreated="lvwInvoice_RowCreated"
                            >
                            <Columns>

<%--                                <asp:BoundField DataField="TRADEID" HeaderText="交易流水号" />--%>
                                <asp:BoundField DataField="VOLUMENO" HeaderText="发票代码" />
                                <asp:BoundField DataField="INVOICENO" HeaderText="发票号码" />
                                
                                <asp:BoundField DataField="NAME"  HeaderText="订单号" />
                                <asp:BoundField DataField="PAYMAN" HeaderText="开票单位名称" />
                                <asp:BoundField DataField="TRADEFEE" HeaderText="交易金额" />
                                <asp:BoundField DataField="TRADETIME" HeaderText="开票日期" />
                                <asp:BoundField DataField="TRADESTAFF" HeaderText="开票人" />
                                

                            </Columns>
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                       <%-- <td>
                                            交易流水号
                                        </td>--%>
                                        <td>
                                            发票代码
                                        </td>
                                        <td>
                                            发票号码
                                        </td>
                                        <td>
                                            卡号(段)/订单
                                        </td>
                                        <td>
                                            开票单位名称
                                        </td>
                                        <td>
                                            交易金额
                                        </td>
                                        <td>
                                            操作员工
                                        </td>
                                        <td>
                                            操作时间
                                        </td>
                                        <%--<td>
                                            发票代码
                                        </td>
                                        <td>
                                            发票号码
                                        </td>--%>
                                        
                                    </tr>
                                </table>
                            </EmptyDataTemplate>
                        </asp:GridView>
                    </div>
                </div>
               
                 <div class="btns">
                <table width="100" border="0" align="right" cellpadding="0" cellspacing="0">
                    <tr>
                        <td width="70%" align="right">
                            <asp:Button ID="btnSubmit" runat="server" Text="红冲" CssClass="button1" OnClientClick="return submitStockInConfirm()" />
                            <asp:LinkButton runat="server" ID="btnStockInConfirm" OnClick="btnSubmit_Click" />
                            
                        </td>
                        <td width="30%" align="right">
                            <%--<asp:Button ID="btnDownload" runat="server" Text="下载发票PDF" Width="100px" CssClass="button1" OnClick="btnDownloadPdf_Click" />--%>
                            <asp:Label ID="labDownload" runat="server" Width="80px"></asp:Label>
                            
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

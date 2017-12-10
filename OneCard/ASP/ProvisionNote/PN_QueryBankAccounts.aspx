<%@ Page Language="C#" AutoEventWireup="true" EnableEventValidation="false" CodeFile="PN_QueryBankAccounts.aspx.cs"
    Inherits="ASP_ProvisionNote_PN_QueryBankAccounts" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>银行账务查询</title>
    <%--<link rel="stylesheet" type="text/css" href="../../css/frame.css" />--%>
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="../../js/myext.js"></script>
    <script type="text/javascript" src="../../js/mootools.js"></script>
    <script type="text/javascript" src="../../js/jquery-1.5.min.js"></script>
</head>
<body>
    <form id="form1" runat="server">
    <div class="tb">
        银行账务查询
    </div>
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
            <asp:BulletedList ID="bulMsgShow" runat="server" />
            <script runat="server">public override void ErrorMsgShow() { ErrorMsgHelper(bulMsgShow); }</script>
            <asp:HiddenField ID="hidShowCheckQuery" runat="server" />
            <asp:HiddenField ID="hidRemind" runat="server" />
            <asp:HiddenField ID="hidApprove" runat="server" />
            <div class="con">
                <div class="card">
                    查询</div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td>
                                <div align="right">
                                    银行列表:</div>
                            </td>
                            <td>
                                <asp:DropDownList ID="selBank" runat="server">
                                </asp:DropDownList>
                            </td>
                            <td>
                             <div align="right">
                                    日期:</div>
                        
                            </td>
                            <td>
                               <asp:TextBox runat="server" ID="txtFromDate" MaxLength="8" CssClass="input"></asp:TextBox>
                                <asp:Label ID="lbWh" runat="server" Text="-"></asp:Label>
                                <asp:TextBox runat="server" ID="txtToDate" MaxLength="8" CssClass="input"></asp:TextBox>
                                <ajaxToolkit:CalendarExtender ID="FromDateCalendar" runat="server" TargetControlID="txtFromDate"
                                    Format="yyyyMMdd" />
                                <ajaxToolkit:CalendarExtender ID="ToDateCalendar" runat="server" TargetControlID="txtToDate"
                                    Format="yyyyMMdd" />
                   
                            </td>
                            <td>
                                <div align="right">
                                </div>
                            </td>
                            <td>
                            </td>
                        </tr>
                        <tr>
                            <td>
                               <div align="right">
                                    对方开户名:</div>
                            </td>
                            <td>
                                <asp:TextBox runat="server" ID="txtOtherName" CssClass="input"></asp:TextBox>
                            </td>
                            <td>
                          <div align="right">
                                    银行金额:</div>
                            </td>
                            <td>
                           <asp:TextBox runat="server" ID="txtBankFromMoney" CssClass="input"></asp:TextBox>
                                -
                                <asp:TextBox runat="server" ID="txtBankToMoney" CssClass="input"></asp:TextBox>
                            </td>
                            <td colspan="1">
                            </td>
                            <td>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                   <div align="right">
                                    银行业务类型:</div>
                            </td>
                            <td>
                              <asp:DropDownList ID="selBankTradeType" CssClass="inputmid" runat="server">
                                </asp:DropDownList>
                            </td>
                            <td>
                               
                            </td>
                            <td>
                           
                            </td>
                            <td colspan="1">
                            </td>
                            <td>
                               <asp:Button runat="server" CssClass="button1" ID="btnQuery" Text="查询" OnClick="btnQuery_Click" />
                            </td>
                        </tr>

                    </table>
                </div>
                <asp:HiddenField ID="hidTypeValue" runat="server" />
                <asp:HiddenField ID="hidDate" runat="server" />
       
                <div style="width: 99%; background-color: #ddddff; border: 1px solid #aaaaff; margin-top: 5px;
                                    margin-left: 5px;" id="supplyUseCard">
                    <div class="base">
                        银行帐务</div>
                    <div class="kuang5">
                        <div class="gdtb" style="height: 300px; overflow: auto;">
                             <asp:GridView ID="gvBank" Width="95%" CssClass="tab1" HeaderStyle-CssClass="tabbt"  
                                                FooterStyle-CssClass="tabcon" AlternatingRowStyle-CssClass="tabjg"                                                            SelectedRowStyle-CssClass="tabsel"  PagerStyle-VerticalAlign="Top"
                                                PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left" 
                                                runat="server" AutoGenerateColumns="false"  AllowPaging="True"
                                                PageSize="40"                      
                                                OnRowCreated="gvBank_RowCreated" 
                                                OnPageIndexChanging="gvBank_PageIndexChanging"
                                                OnSelectedIndexChanged="gvBank_SelectedIndexChanged"
                                                OnRowDataBound="gvBank_RowDataBound"
                                                 >
                                                <Columns>
                                                    <asp:BoundField DataField="文件日期" HeaderText="文件日期" />
                                                    <asp:BoundField DataField="未匹配金额" HeaderText="未匹配金额" />
                                                    <asp:BoundField DataField="交易金额" HeaderText="交易金额" />
                                                    <asp:BoundField DataField="银行名称" HeaderText="银行名称" />
                                                    <asp:BoundField DataField="业务类型" HeaderText="业务类型" />
                                                    <asp:BoundField DataField="业务摘要" HeaderText="业务摘要" />
                                                    <asp:BoundField DataField="对方开户名" HeaderText="对方开户名" />
                                                    <asp:BoundField DataField="对方银行帐号" HeaderText="对方银行帐号" />
                                                    <asp:BoundField DataField="TRADEID" HeaderText="TRADEID" />
                                                </Columns>
                                                <EmptyDataTemplate>
                                                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                                        <tr class="tabbt">
                                           
                                                            <td>
                                                                文件日期
                                                            </td>
                                                            <td>
                                                                未匹配金额
                                                            </td>
                                                            <td>
                                                                交易金额
                                                            </td>
                                                            <td>
                                                                银行名称
                                                            </td>
                                                            <td>
                                                                业务类型
                                                            </td>
                                                            <td>
                                                                业务摘要
                                                            </td>
                                                            <td>
                                                                对方开户名
                                                            </td>
                                                            <td>
                                                                对方银行帐号
                                                            </td>
                                                            
                                                        </tr>
                                                    </table>
                                                </EmptyDataTemplate>
                                            </asp:GridView>
                        </div>
                    </div>
                </div>
                        
                <div style="width: 99%; background-color: #ddddff; border: 1px solid #aaaaff; margin-top: 5px;
                    margin-left: 5px;" id="Div1">
                    <div class="base">
                        匹配业务信息</div>
                    <div class="kuang5">
                        <div class="gdtb" style="height: 300px; overflow: auto;">
                            <asp:GridView ID="gvList" Width="100%" CssClass="tab1" HeaderStyle-CssClass="tabbt"
                                FooterStyle-CssClass="tabcon" AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel"
                                PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top"
                                runat="server" AutoGenerateColumns="false">
                                <Columns>
                                    <asp:TemplateField>
                                        <HeaderTemplate>
                                            <asp:CheckBox ID="chkAll" runat="server" AutoPostBack="true" OnCheckedChanged="chkList_CheckedChanged" />
                                        </HeaderTemplate>
                                        <ItemTemplate>
                                            <asp:CheckBox ID="chkList" runat="server" />
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:BoundField DataField="SYSTEMTRADEID" HeaderText="业务流水号" />
                                    <asp:BoundField DataField="匹配金额" HeaderText="匹配金额" />
                                    <asp:BoundField DataField="匹配日期" HeaderText="匹配日期" DataFormatString="{0:yyyyMMdd}" />
                                    <asp:BoundField DataField="匹配操作员工" HeaderText="匹配操作员工" />
                                    <asp:BoundField DataField="操作部门" HeaderText="操作部门" />
                                    <asp:BoundField DataField="业务金额" HeaderText="业务金额" />
                                    <asp:BoundField DataField="业务交易类型" HeaderText="业务交易类型" />
                                    <asp:BoundField DataField="业务交易对象" HeaderText="业务交易对象" />
                                    <asp:BoundField DataField="交易日期" HeaderText="交易日期" DataFormatString="{0:yyyyMMdd}"/>
                                    <asp:BoundField DataField="批次号" HeaderText="批次号"/>
                                </Columns>
                                <EmptyDataTemplate>
                                    <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                        <tr class="tabbt">
                                         
                                            <td>
                                                <input type="checkbox" />
                                            </td>
                                            <td>
                                                匹配金额
                                            </td>
                                            <td>
                                                匹配日期
                                            </td>
                                            <td>
                                                匹配操作员工
                                            </td>
                                            <td>
                                                操作部门
                                            </td>
                                            <td>
                                                业务金额
                                            </td>
                                            <td>
                                                业务交易类型
                                            </td>
                                            <td>
                                                业务交易对象
                                            </td>
                                           <td>
                                                交易日期
                                            </td>
                                           <td>
                                                批次号
                                            </td>
                                        </tr>
                                    </table>
                                </EmptyDataTemplate>
                            </asp:GridView>
                        </div>
                    </div>
                </div>
            </div>
            <div class="btns">
                <table width="200px" border="0" align="right" cellpadding="0" cellspacing="0">
                    <tr>
                        <td>
                            <asp:HiddenField ID="hidTrade" runat="server" />
                        </td>
                        <td>
                            <asp:Button ID="Button1" Text="取消匹配" CssClass="button1" runat="server" OnClick="btnCancel_Click" />
                        </td>
                    </tr>
                </table>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
    </form>
</body>
</html>

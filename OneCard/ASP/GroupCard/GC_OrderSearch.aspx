<%@ Page Language="C#" AutoEventWireup="true" CodeFile="GC_OrderSearch.aspx.cs" EnableEventValidation="false"
    Inherits="ASP_GroupCard_GC_OrderSearch" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>订单查询</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="../../js/printorder.js"></script>
    <script type="text/javascript" src="../../js/myext.js"></script>
    <script type="text/javascript" src="../../js/jquery-1.5.min.js"></script>
    <script type="text/javascript" src="../../js/Window.js"></script>
    <script type="text/javascript">
        function SelectAll(tempControl) {
            //将除头模板中的其它所有的CheckBox取反 

            var theBox = tempControl;
            xState = theBox.checked;

            elem = theBox.form.elements;
            for (i = 0; i < elem.length; i++)
                if (elem[i].type == "checkbox" && elem[i].id != theBox.id) {
                    if (elem[i].checked != xState)
                        elem[i].click();
                }
        }
        function Research() {
            $("#btnQuery").click();
        }
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
        订单查询
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
            border: 0px solid black;
        }
    </style>
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
                            <td width="10%" >
                                <asp:TextBox ID="txtGroupName" CssClass="inputmid" runat="server"></asp:TextBox>
                                <%--<asp:DropDownList ID="selCompany" CssClass="inputmid" Width="206" runat="server"
                                    AutoPostBack="true" OnSelectedIndexChanged="selCompany_Changed">
                                </asp:DropDownList>--%>
                            </td>
                            <td width="10%">
                                <div align="right">
                                    联系人:</div>
                            </td>
                            <td width="12%">
                                <asp:TextBox ID="txtName" CssClass="input" runat="server"></asp:TextBox>
                            </td>
                            <td width="12%">
                                <div align="right">
                                    审核员工:</div>
                            </td>
                            <td width="14%">
                                <asp:DropDownList ID="ddlApprover" CssClass="inputmid" runat="server">
                                </asp:DropDownList>
                            </td>
                            <td width="8%">
                                <div align="right">
                                    金额:</div>
                            </td>
                            <td width="12%">
                                <asp:TextBox ID="txtTotalMoney" CssClass="input" runat="server"></asp:TextBox>
                            </td>
                        </tr>
                        <tr>
                            
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
                                </asp:DropDownList>
                            </td>
                            <td width="8%">
                                <div align="right">
                                    订单类别:</div>
                            </td>
                            <td width="8%">
                                <asp:DropDownList ID="selType" CssClass="inputmid" runat="server">
                                <asp:ListItem Text="---请选择---" Value=""></asp:ListItem>
                                <asp:ListItem Text="利金卡" Value="1"></asp:ListItem>
                                <asp:ListItem Text="充值卡" Value="2"></asp:ListItem>
                                <asp:ListItem Text="市民卡B卡" Value="3"></asp:ListItem>
                                <asp:ListItem Text="专有账户" Value="4"></asp:ListItem>
                                <asp:ListItem Text="读卡器" Value="5"></asp:ListItem>
                                <asp:ListItem Text="园林年卡" Value="6"></asp:ListItem>
                                <asp:ListItem Text="休闲年卡" Value="7"></asp:ListItem>
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
                            <td width="8%">
                                <div align="right">
                                    制卡部门:</div>
                            </td>
                            <td width="8%">
                                <asp:DropDownList ID="selMakeDept" CssClass="inputmid" runat="server" AutoPostBack="true"
                                    OnSelectedIndexChanged="selMakeDept_Changed" >
                                </asp:DropDownList>
                            </td>
                            <td width="8%">
                                <div align="right">
                                    制卡员工:</div>
                            </td>
                            <td width="8%">
                                <asp:DropDownList ID="selMakeOperator" CssClass="inputmid" runat="server"  >
                                </asp:DropDownList>
                            </td>
                            
                        </tr>
                        <tr>
                            <td width="8%">
                                <div align="right">
                                    客户经理部门:</div>
                            </td>
                            <td width="8%">
                                <asp:DropDownList ID="selManagerDept" CssClass="inputmid" runat="server" 
                                    AutoPostBack="true" OnSelectedIndexChanged="managerDept_Changed">
                                </asp:DropDownList>
                            </td>
                            <td width="8%">
                                <div align="right">
                                    客户经理:</div>
                            </td>
                            <td width="8%">
                                <asp:DropDownList ID="selManager" CssClass="inputmid" runat="server">
                                </asp:DropDownList>
                            </td>
                            <td width="8%">
                                <div align="right">
                                    付款方式:</div>
                            </td>
                            <td width="8%">
                                <asp:DropDownList ID="payType" CssClass="inputmid" runat="server">
                                    <asp:ListItem Value="">---请选择---</asp:ListItem>
                                    <asp:ListItem Value="0">支/本票</asp:ListItem>
                                    <asp:ListItem Value="1">转账</asp:ListItem>
                                    <asp:ListItem Value="2">现金</asp:ListItem>
                                    <asp:ListItem Value="3">刷卡</asp:ListItem>
                                    <asp:ListItem Value="4">呈批单</asp:ListItem>
                                </asp:DropDownList>
                            </td>
                            <td width="8%">
                            </td>
                            <td width="8%">
                            </td>
                        </tr>
                        <tr>
                            <td colspan="8" align="right">
                                <asp:Button runat="server" CssClass="button1" ID="btnQuery" Text="查询" OnClick="btnQuery_Click" />
                            </td>
                        </tr>
                    </table>
                </div>
                <table border="0" width="95%"   >
                    <tr>
                        <td align="left" >
                            <div class="jieguo">
                                订单列表</div>
                        </td>
                        <td align="right">
                            <asp:Button ID="btnExport" CssClass="button1" runat="server" Text="导出Excel" OnClick="btnExport_Click" />
                        </td>
                    </tr>
                </table>
                <div class="kuang5">
                    <div class="gvUseCard" style="height: 300px; overflow: auto; display: block">
                        <asp:GridView ID="gvOrderList" CssClass="tab2" HeaderStyle-CssClass="tabbt" FooterStyle-CssClass="tabcon"
                            AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel" PagerSettings-Mode="NumericFirstLast"
                            PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top" runat="server"
                            AutoGenerateColumns="false" Width="150%" OnRowDataBound="gvOrderList_RowDataBound"
                            AllowPaging="true" PageSize="10" OnPageIndexChanging="gvOrderList_Page">
                            <Columns>
                                <asp:TemplateField>
                                    <ItemTemplate>
                                        <asp:Button ID="btnUpdate" Enabled="true" Width="45px" CssClass="button1" runat="server"
                                            Text="修改" />
                                        <asp:Button ID="btnPrint" Enabled="true" Width="45px" CssClass="button1" runat="server"
                                            Text="打印" />
                                        <asp:Button ID="btnDetail" Enabled="true" Width="45px" CssClass="button1" runat="server"
                                            Text="详情" CommandArgument='<%# Container.DataItemIndex%>' OnClick = "btnDetail_Click"/>
                                        <asp:Button ID="btnCheckInfo" Enabled="true" Width="60px" CssClass="button1" runat="server"
                                            Text="到账信息" CommandArgument='<%# Container.DataItemIndex%>' OnClick = "btnCheckInfo_Click"/>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField DataField="ORDERNO" HeaderText="订单号" />
                                <asp:BoundField DataField="GROUPNAME" HeaderText="单位名称" />
                                <asp:BoundField DataField="NAME" HeaderText="联系人" />
                                <asp:BoundField DataField="IDCARDNO" HeaderText="身份证号码" />
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
                    <div id="RoleWindow" style="width: 910px; position: absolute; display: none; z-index: 999;">
                    </div>
                </div>
                <div class="jieguo" id="divDetail" runat="server" >
                    详情</div>
                 <div class="kuang5" runat="server" id="divInfo" >
                 
                </div>
                <div  runat="server" id="divMakeCardWarn">
                 <table border="0" width="95%"   >
                    <tr>
                    <td width = "8%"></td>
                        <td align="left"  style="color:red">  
                                提示：订单未制卡！
                        </td>
                        </tr>
                    </table>
                        
                </div>
                <div  runat="server" id="divMakeCardWarn2">
                 <table border="0" width="95%"   >
                    <tr>
                    <td width = "8%"></td>
                        <td align="left"  style="color:red">  
                                提示：订单未完成领卡补关联！
                        </td>
                        </tr>
                    </table>
                        
                </div>
                <div class="kuang5" runat="server" id="divAll">
                <div  runat="server" id="divCash">
                <table border="0" width="95%"   >
                    <tr>
                    <td width = "2%"></td>
                        <td align="left" width="8%" style="margin-left:10px;">  
                                利金卡：
                        </td>
                        <td width="30%">
                            <asp:Button ID="btnCash" CssClass="button1" runat="server" Text="卡号段" OnClick="btnCash_Click" />
                        </td>
                        <asp:HiddenField ID = "hidCashOrderNo" runat="server" />
                    </tr>
                </table>
                </div>
                <div  runat="server" id="divSZT">
                <table border="0" width="95%"   >
                    <tr>
                    <td width = "2%"></td>
                        <td align="left" width="8%" style="margin-left:10px;">  
                                苏州通卡：
                        </td>
                        <td width="30%">
                            <asp:Button ID="btnSZT" CssClass="button1" runat="server" Text="卡号段" OnClick="btnSZT_Click" />
                        </td>
                        
                    </tr>
                </table>
                </div>
                 <div  runat="server" id="divCharge">
                <table border="0" width="95%"   >
                    <tr>
                    <td width = "2%"></td>
                        <td align="left" width="8%" style="margin-left:10px;">  
                                充值卡：
                        </td>
                        <td width="30%">
                            <asp:Button ID="btnCharge" CssClass="button1" runat="server" Text="卡号段" OnClick="btnCharge_Click" />
                        </td>
                       
                    </tr>
                </table>
                </div>
                 <div  runat="server" id="divReader">
                <table border="0" width="95%"   >
                    <tr>
                    <td width = "2%"></td>
                        <td align="left" width="8%" style="margin-left:10px;">  
                                读卡器：
                        </td>
                        <td width="30%">
                            <asp:Button ID="btnReader" CssClass="button1" runat="server" Text="卡号段" OnClick="btnReader_Click" />
                        </td>
                       
                    </tr>
                </table>
                </div>
                </div>
                <div class="kuang5" runat="server" id="divGridView" style="height: 200px; overflow: auto; display: block">
                <asp:GridView ID="GridView1" CssClass="tab2" HeaderStyle-CssClass="tabbt" FooterStyle-CssClass="tabcon"
                            AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel" PagerSettings-Mode="NumericFirstLast"
                            PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top" runat="server"
                            AutoGenerateColumns="true" Width="100%" EmptyDataText = "查无数据!" >
                            
                        </asp:GridView>
                        </div>
                
                <%--<div class="con">
                <div class="jieguo">
                    详细信息</div>
                <div class="kuang5" runat="server" id="printarea">
                </div>
                <asp:HiddenField ID="hidFinanceRemark" runat="server" />
            </div>--%>
                <%--<div class="btns">
                 <table width="95%" border="0"cellpadding="0" cellspacing="0">
                      <tr>
                        <td width="80%">&nbsp;</td>
                        <td align="right"><asp:Button ID="btnPrint"  CssClass="button1" Text="打印"  OnClientClick="return printOrderdiv('printarea');"
                                runat="server" /></td>
                        
                      </tr>
                  </table>
            </div>--%>
            <div  runat="server" id="divCheckInfoWarm">
                 <table border="0" width="95%"   >
                    <tr>
                    <td width = "8%"></td>
                        <td align="left"  style="color:red">  
                                提示：订单无到账信息！
                        </td>
                        </tr>
                    </table>
                        
                </div>
            <div id = "divCheckInfo" runat = "server">
            <div class="jieguo" id="div1" runat="server" >
                    到账信息</div>
                    <div class="kuang5" runat="server" id="div2" style="height: 200px; overflow: auto; display: block">
                <asp:GridView ID="GridView2" CssClass="tab2" HeaderStyle-CssClass="tabbt" FooterStyle-CssClass="tabcon"
                            AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel" PagerSettings-Mode="NumericFirstLast"
                            PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top" runat="server"
                            AutoGenerateColumns="true" Width="100%" EmptyDataText = "查无数据!" >
                            
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

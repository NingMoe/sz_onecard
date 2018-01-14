<%@ Page Language="C#" AutoEventWireup="true" CodeFile="IT_PrintOrder.aspx.cs" Inherits="ASP_InvoiceTrade_IT_PrintOrder" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>订单开票</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <script type="text/javascript" src="../../js/myext.js"></script>
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <link href="../../css/invoice.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="../../js/currency.js"></script>

    <script type="text/javascript" src="../../js/mootools.js"></script>
    <script type="text/javascript" src="../../js/jquery-1.5.min.js"></script>
    <script type="text/javascript">
        function SumInvoiceMoney() {
            var sum = 0.0;
            var el1 = document.getElementById('txtAmount1');
            var el2 = document.getElementById('txtAmount2');
            var el3 = document.getElementById('txtAmount3');
            var el4 = document.getElementById('txtAmount4');
            var el5 = document.getElementById('txtAmount5');
            if (el1.value)
                sum = sum + Number(el1.value);
            if (el2.value)
                sum = sum + Number(el2.value);
            if (el3.value)
                sum = sum + Number(el3.value);
            if (el4.value)
                sum = sum + Number(el4.value);
            if (el5.value)
                sum = sum + Number(el5.value);
            document.getElementById('labInvoiceMoney').innerText = (sum*100)/100.0;
//            $('labInvoiceMoney').innerText = sum / 100.0;
        }

        function Total() {
            sumCurrency3('txtAmount1', 'txtAmount2', 'txtAmount3', 'labInvoiceMoney');
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
    <div class="tb">
        发票 -> 订单开票</div>
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
           
            <asp:HiddenField ID="hidPrinted" Value="false" runat="server" />
            <div class="con">
                <div class="card">
                    查询条件</div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            
                            <td width="7%">
                                <div align="right">
                                    订单号:</div>
                            </td>
                            <td width="15%">
                                <asp:TextBox ID="txtOrderNo" CssClass="inputmid" runat="server" MaxLength="20"></asp:TextBox>

                            </td>
                            <td width="8%">
                                <div align="right">
                                    单位名称:</div>
                            </td>
                            <td width="10%" >
                                <asp:TextBox ID="txtGroupName" CssClass="inputmid" runat="server"></asp:TextBox>
                                
                            </td>
                            <td width="8%">
                                <div align="right">
                                    金额:</div>
                            </td>
                            <td width="12%">
                                <asp:TextBox ID="txtTotalMoney" CssClass="input" runat="server"></asp:TextBox>
                            </td>
                             <td width="8%">
                                <div align="right">
                                    订单状态:</div>
                            </td>
                            <td width="8%">
                                <asp:DropDownList ID="selApprovalStatus" CssClass="inputmid" runat="server">
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
                                    OnSelectedIndexChanged="selDept_Changed" >
                                </asp:DropDownList>
                            </td>
                            <td width="8%">
                                <div align="right">
                                    录入员工:</div>
                            </td>
                            <td width="8%">
                                <asp:DropDownList ID="selStaff" CssClass="inputmid" runat="server" >
                                </asp:DropDownList>
                            </td>
                            <td width="7%">
                                <div align="right">
                                    开始日期：</div>
                            </td>
                            <td width="15%">
                                <asp:TextBox ID="txtBeginDate" CssClass="input" runat="server" MaxLength="10"></asp:TextBox>
                                <ajaxToolkit:CalendarExtender ID="BeginCalendar" runat="server" TargetControlID="txtBeginDate"
                                    Format="yyyyMMdd" />
                            </td>
                            <td width="7%">
                                <div align="right">
                                    结束日期：</div>
                            </td>
                            <td width="15%">
                                <asp:TextBox ID="txtEndDate" CssClass="input" runat="server" MaxLength="10"></asp:TextBox>
                                <ajaxToolkit:CalendarExtender ID="EndCalendar" runat="server" TargetControlID="txtEndDate"
                                    Format="yyyyMMdd" />
                            </td>
                            <td align="right">
                            </td>
                            <td align="right" colspan="4">
                                <asp:Button ID="btnQuery" CssClass="button1" OnClick="btnQuery_Click" Text="查询" runat="server" />
                            </td>
                        </tr>
                    </table>
                </div>
                <div class="card">
                    查询结果
                </div>
                <div class="kuang5">
                    <div class="gdtb" style="height: 200px; padding: 5px 0 0 0;">
                        <asp:GridView ID="lvwInvoice" runat="server" Width="120%"  CssClass="tab1" HeaderStyle-CssClass="tabbt"
                            AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel" AllowPaging="True"
                            PageSize="200" OnPageIndexChanging="lvwInvoice_Page" PagerSettings-Mode="NumericFirstLast"
                            PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top" AutoGenerateColumns="False"
                            OnSelectedIndexChanged="lvwInvoice_SelectedIndexChanged" OnRowCreated="lvwInvoice_RowCreated"
                            >
                            <Columns>
                                <asp:BoundField DataField="ORDERNO"  HeaderText="订单号" />
                                <asp:BoundField DataField="ORDERSTATE" HeaderText="订单状态" />
                                <asp:BoundField DataField="GNAME" HeaderText="单位名称/个人" />
                                <asp:BoundField DataField="TOTALMONEY" HeaderText="订单总金额" />
                                <asp:BoundField DataField="CASHGIFTMONEY" HeaderText="礼金卡" />
                                 <asp:BoundField DataField="CHARGECARDMONEY" HeaderText="充值卡" />
                                 <asp:BoundField DataField="CUSTOMERACCMONEY" HeaderText="专有账户" />
                                 <asp:BoundField DataField="GARDENCARDMONEY" HeaderText="园林年卡" />
                                 <asp:BoundField DataField="RELAXCARDMONEY" HeaderText="休闲年卡" />
                                 <asp:BoundField DataField="SZTCARDMONEY" HeaderText="市民卡B卡" />
                                 <asp:BoundField DataField="READERMONEY" HeaderText="读卡器" />
                                <asp:BoundField DataField="INVOICETYPE" HeaderText="开票方式" />
                                <asp:BoundField DataField="TRANSACTOR" HeaderText="录入员工" />
                                <asp:BoundField DataField="INPUTTIME" HeaderText="录入时间" />

                            </Columns>
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                        
                                        <td>
                                            订单号
                                        </td>
                                        <td>
                                            订单状态
                                        </td>
                                        <td>
                                            单位名称/个人
                                        </td>
                                        <td>
                                            订单总金额
                                        </td>
                                        <td>
                                            礼金卡
                                        </td>
                                        <td>
                                            充值卡
                                        </td>
                                        <td>
                                            专有账户
                                        </td>
                                        <td>
                                            园林年卡
                                        </td>
                                        <td>
                                            休闲年卡
                                        </td>
                                        <td>
                                            市民卡B卡
                                        </td>
                                        <td>
                                            读卡器
                                        </td>
                                        <td>
                                            开票方式
                                        </td>
                                        <td>
                                            录入员工
                                        </td>
                                        <td>
                                            录入时间
                                        </td>
                                        
                                    </tr>
                                </table>
                            </EmptyDataTemplate>
                        </asp:GridView>
                    </div>
                    
                </div>
                <div id="detail" runat="server" >
                <div class="card">
                    订单明细
                </div>
                <div class="kuang5">
                <table border="0" width="95%">
                 <tr>
                 <td align="left" width="12%">
                     <asp:CheckBox ID="ckNoTaxFree" runat="server" Text="免税部分订单金额:" />
                 </td>
                 <td align="left" width="35%">
                     <asp:Label ID="labTaxFree" runat="server"></asp:Label>
                 </td>
                 
                 <td align="left" width="23%">
                   
                 </td>
                 <td align="left" width="40%">
                   
                 </td>
                 
                 </tr>
                 <tr>
                 <td align="left" width="12%" >
                    <asp:Label ID="Label1" runat="server" Text="免税部分明细:"></asp:Label>
                 </td>
                 
                 <td  align="left" width="35%">
                    <asp:Label ID="labFreeDetail" runat="server" ></asp:Label>
                 </td>
                  <td align="left" width="23%">
                   
                 </td>
                 <td align="left" width="40%">
                   
                 </td>
                 </tr>
                 <tr>
                 <td align="left" width="12%">
                     <asp:CheckBox ID="ckTax" runat="server" Text="含税部分订单金额:"/>
                 </td>
                  <td align="left" width="35%">
                     <asp:Label ID="labTax" runat="server"></asp:Label>
                  </td>  
                    
                   <td align="left" width="23%">
                   
                 </td>
                 <td align="left" width="40%">
                   
                 </td>
                 </tr>
                 <tr>
                  <td align="left" width="12%">
                    <asp:Label ID="Label3" runat="server" Text="含税部分明细:"></asp:Label>
                 </td>
                 
                 <td align="left" width="35%">
                    <asp:Label ID="labTaxDetail" runat="server" ></asp:Label>
                 </td>
                  <td align="left" width="23%">
                   
                 </td>
                 <td align="left" width="40%">
                   
                 </td>
                 </tr>
                 
                 
                 </table>
                 </div>
                <div class="kuang5">
                <table border="0" width="95%">
                 <tr>
                 <td align="left" width="12%">
                     <asp:Label ID="Label2" runat="server" Text="已经开票金额:"></asp:Label>
                 </td>
                  <td align="left" width="35%">
                     <asp:Label ID="labMoney" runat="server"></asp:Label>
                  </td>  
                     <td align="left" width="23%">
                   
                 </td>
                 <td align="left" width="40%">
                   
                 </td>
                 <asp:HiddenField ID="hidSZTMoney" runat="server" />
                 <asp:HiddenField ID="hidReaderMoney" runat="server" />
                 <asp:HiddenField ID="hidIsFree" runat="server" />
                 </tr>
                 <tr>
                 <td align="left" width="12%">
                     <asp:Label ID="Label4" runat="server" Text="允许开票金额:"></asp:Label>
                 </td>
                  <td align="left" width="35%">
                     <asp:Label ID="labAllowMoney" runat="server"></asp:Label>
                  </td>  
                     <td align="left" width="23%">
                   
                 </td>
                 <td align="left" width="40%">
                   
                 </td>
                 </tr>
                 <tr>
                 <td align="left" width="12%">
                     <asp:Label ID="Label5" runat="server" Text="专用发票金额:"></asp:Label>
                 </td>
                  <td align="left" width="35%">
                     <asp:Label ID="labSpecialInvoice" runat="server"></asp:Label>
                  </td>  
                     <td align="left" width="23%">
                   
                 </td>
                 <td align="left" width="40%">
                   
                 </td>
                 </tr>
                 
                </table>
                
               
                </div>
                </div>
                
            <table border="0" width="95%"  cellpadding="0" cellspacing="0" class="text25">
                    <tr>
                        <td align="left" width="10%">
                            <div class="card">
                                开票</div>
                        </td>
                        <td width="100px" style="font-weight: bolder">
                            开票总额:
                        </td>
                        <td width="300px"  align="left" >
                            <asp:Label ID="labInvoiceMoney" runat="server" Text="0"></asp:Label>
                        </td>
                        <td width="70%">
                         </td>
                         
                    </tr>
                </table>
                <div class="kuang5">
                <table width="100%" height="192" border="0" cellpadding="0" cellspacing="0" class="text25">
                                                                            <tr>
                                                                             <td width="20%" style="font-weight: bolder">
                                                                                    <div align="left" class="head">
                                                                                        商品名称</div>
                                                                                </td>

                                                                                <td width="20%" style="font-weight: bolder">
                                                                                    <div align="left" class="head">
                                                                                        项目名称</div>
                                                                                </td>

                                                                                <td width="20%" style="font-weight: bolder">
                                                                                    <div align="left" class="head">
                                                                                        项目内容</div>
                                                                                </td>
                                                                               
       
                                                                                 <td width="20%" style="font-weight: bolder">
                                                                                    <div align="left">
                                                                                        金额</div>
                                                                                </td>
                                                                                <td width="20%">
                                                                                  
                                                                                </td>
                                                                            </tr>
                                                                            <tr>
                                                                            <td>
                                                                                    <div align="left">
                                                                                        <asp:DropDownList ID="ddlType1" CssClass="inputmid" runat="server" AutoPostBack="true"  OnSelectedIndexChanged="ddlType1_Changed">
                                                                                        <asp:ListItem Text="---请选择---" Value=""></asp:ListItem>
                                                                                         <asp:ListItem Text="1:利金卡" Value="利金卡"></asp:ListItem>
                                                                                         <asp:ListItem Text="2:充值卡" Value="充值卡"></asp:ListItem>
                                                                                         <asp:ListItem Text="3:专有账户" Value="专有账户"></asp:ListItem>
                                                                                         <asp:ListItem Text="4:园林年卡" Value="园林年卡"></asp:ListItem>
                                                                                         <asp:ListItem Text="5:休闲年卡" Value="休闲年卡"></asp:ListItem>
                                                                                         <asp:ListItem Text="5:市民卡B卡卡费" Value="市民卡B卡卡费"></asp:ListItem>
                                                                                         <asp:ListItem Text="6:市民卡B卡充值" Value="市民卡B卡充值"></asp:ListItem>
                                                                                         <asp:ListItem Text="7:读卡器" Value="读卡器"></asp:ListItem>
                                                                                        </asp:DropDownList>
                                                                                    </div>
                                                                                </td>
                                                                                <td>
                                                                                <div align="left">
                                                                                 <asp:DropDownList ID="ddlProjName1" CssClass="inputmid" runat="server"  />
                                                                                 </div>
                                                                                </td>
                                                                                <td>
                                                                                    <div align="left">
                                                                                        <asp:DropDownList ID="selProj1" CssClass="inputmid" runat="server">
                                                                                        <asp:ListItem Text="---请选择---" Value=""></asp:ListItem>
                                                                                        <asp:ListItem Text="1:充值" Value="充值"></asp:ListItem>
                                                                                         <asp:ListItem Text="2:交通费" Value="交通费"></asp:ListItem>
                                                                                         <asp:ListItem Text="3:福利费" Value="福利费"></asp:ListItem>
                                                                                         <asp:ListItem Text="4:通讯费" Value="通讯费"></asp:ListItem>
                                                                                         <asp:ListItem Text="5:宣传费" Value="宣传费"></asp:ListItem>
                                                                                        </asp:DropDownList>
                                                                                    </div>
                                                                                </td>
                                                                                
                                                                                <td>
                                                                                    <div align="left">
                                                                                        <asp:TextBox ID="txtAmount1" CssClass="textbox80" runat="server" onblur='SumInvoiceMoney();'></asp:TextBox>
                                                                                    </div>
                                                                                    </td>
                                                                            </tr>
                                                                            <tr>
                                                                            <td>
                                                                                    <div align="left">
                                                                                        <asp:DropDownList ID="ddlType2" CssClass="inputmid" runat="server" AutoPostBack="true"  OnSelectedIndexChanged="ddlType2_Changed">
                                                                                        <asp:ListItem Text="---请选择---" Value=""></asp:ListItem>
                                                                                         <asp:ListItem Text="1:利金卡" Value="利金卡"></asp:ListItem>
                                                                                         <asp:ListItem Text="2:充值卡" Value="充值卡"></asp:ListItem>
                                                                                         <asp:ListItem Text="3:专有账户" Value="专有账户"></asp:ListItem>
                                                                                         <asp:ListItem Text="4:园林年卡" Value="园林年卡"></asp:ListItem>
                                                                                         <asp:ListItem Text="5:休闲年卡" Value="休闲年卡"></asp:ListItem>
                                                                                         <asp:ListItem Text="5:市民卡B卡卡费" Value="市民卡B卡卡费"></asp:ListItem>
                                                                                         <asp:ListItem Text="6:市民卡B卡充值" Value="市民卡B卡充值"></asp:ListItem>
                                                                                         <asp:ListItem Text="7:读卡器" Value="读卡器"></asp:ListItem>
                                                                                        </asp:DropDownList>
                                                                                    </div>
                                                                                </td>
                                                                                <td>
                                                                               <div align="left">
                                                                                 <asp:DropDownList ID="ddlProjName2" CssClass="inputmid" runat="server"  />
                                                                                 </div>
                                                                                 </td>
                                                                                <td>
                                                                                    <div align="left">
                                                                                        <asp:DropDownList ID="selProj2" CssClass="inputmid" runat="server">
                                                                                        <asp:ListItem Text="---请选择---" Value=""></asp:ListItem>
                                                                                       <asp:ListItem Text="1:充值" Value="充值"></asp:ListItem>
                                                                                         <asp:ListItem Text="2:交通费" Value="交通费"></asp:ListItem>
                                                                                         <asp:ListItem Text="3:福利费" Value="福利费"></asp:ListItem>
                                                                                         <asp:ListItem Text="4:通讯费" Value="通讯费"></asp:ListItem>
                                                                                         <asp:ListItem Text="5:宣传费" Value="宣传费"></asp:ListItem>
                                                                                        </asp:DropDownList>
                                                                                    </div>
                                                                                </td>
                                                                                
                                                                                <td>
                                                                                    <div align="left">
                                                                                        <asp:TextBox ID="txtAmount2" CssClass="textbox80" runat="server" onblur='SumInvoiceMoney();'></asp:TextBox>
                                                                                    </div>
                                                                                </td>
                                                                            </tr>
                                                                            <tr>
                                                                            <td>
                                                                                    <div align="left">
                                                                                        <asp:DropDownList ID="ddlType3" CssClass="inputmid" runat="server" AutoPostBack="true"  OnSelectedIndexChanged="ddlType3_Changed">
                                                                                        <asp:ListItem Text="---请选择---" Value=""></asp:ListItem>
                                                                                         <asp:ListItem Text="1:利金卡" Value="利金卡"></asp:ListItem>
                                                                                         <asp:ListItem Text="2:充值卡" Value="充值卡"></asp:ListItem>
                                                                                         <asp:ListItem Text="3:专有账户" Value="专有账户"></asp:ListItem>
                                                                                         <asp:ListItem Text="4:园林年卡" Value="园林年卡"></asp:ListItem>
                                                                                         <asp:ListItem Text="5:休闲年卡" Value="休闲年卡"></asp:ListItem>
                                                                                         <asp:ListItem Text="5:市民卡B卡卡费" Value="市民卡B卡卡费"></asp:ListItem>
                                                                                         <asp:ListItem Text="6:市民卡B卡充值" Value="市民卡B卡充值"></asp:ListItem>
                                                                                         <asp:ListItem Text="7:读卡器" Value="读卡器"></asp:ListItem>
                                                                                        </asp:DropDownList>
                                                                                    </div>
                                                                                </td>
                                                                                 <td>
                                                                               <div align="left">
                                                                                 <asp:DropDownList ID="ddlProjName3" CssClass="inputmid" runat="server"  />
                                                                                 </div>
                                                                                 </td>
                                                                                <td>
                                                                                    <div align="left">
                                                                                        <asp:DropDownList ID="selProj3" CssClass="inputmid" runat="server">
                                                                                        <asp:ListItem Text="---请选择---" Value=""></asp:ListItem>
                                                                                        <asp:ListItem Text="1:充值" Value="充值"></asp:ListItem>
                                                                                         <asp:ListItem Text="2:交通费" Value="交通费"></asp:ListItem>
                                                                                         <asp:ListItem Text="3:福利费" Value="福利费"></asp:ListItem>
                                                                                         <asp:ListItem Text="4:通讯费" Value="通讯费"></asp:ListItem>
                                                                                         <asp:ListItem Text="5:宣传费" Value="宣传费"></asp:ListItem>
                                                                                        </asp:DropDownList>
                                                                                    </div>
                                                                                </td>
                                                                               
                                                                                <td>
                                                                                    <div align="left">
                                                                                        <asp:TextBox ID="txtAmount3" CssClass="textbox80" runat="server" onblur='SumInvoiceMoney();'></asp:TextBox>
                                                                                    </div>
                                                                                </td>
                                                                            </tr>
                                                                            <tr>
                                                                            <td>
                                                                                    <div align="left">
                                                                                        <asp:DropDownList ID="ddlType4" CssClass="inputmid" runat="server" AutoPostBack="true"  OnSelectedIndexChanged="ddlType4_Changed">
                                                                                        <asp:ListItem Text="---请选择---" Value=""></asp:ListItem>
                                                                                         <asp:ListItem Text="1:利金卡" Value="利金卡"></asp:ListItem>
                                                                                         <asp:ListItem Text="2:充值卡" Value="充值卡"></asp:ListItem>
                                                                                         <asp:ListItem Text="3:专有账户" Value="专有账户"></asp:ListItem>
                                                                                         <asp:ListItem Text="4:园林年卡" Value="园林年卡"></asp:ListItem>
                                                                                         <asp:ListItem Text="5:休闲年卡" Value="休闲年卡"></asp:ListItem>
                                                                                         <asp:ListItem Text="5:市民卡B卡卡费" Value="市民卡B卡卡费"></asp:ListItem>
                                                                                         <asp:ListItem Text="6:市民卡B卡充值" Value="市民卡B卡充值"></asp:ListItem>
                                                                                         <asp:ListItem Text="7:读卡器" Value="读卡器"></asp:ListItem>
                                                                                        </asp:DropDownList>
                                                                                    </div>
                                                                                </td>
                                                                                  <td>
                                                                               <div align="left">
                                                                                 <asp:DropDownList ID="ddlProjName4" CssClass="inputmid" runat="server"  />
                                                                                 </div>
                                                                                 </td>
                                                                                <td>
                                                                                    <div align="left">
                                                                                        <asp:DropDownList ID="selProj4" CssClass="inputmid" runat="server">
                                                                                        <asp:ListItem Text="---请选择---" Value=""></asp:ListItem>
                                                                                        <asp:ListItem Text="1:充值" Value="充值"></asp:ListItem>
                                                                                         <asp:ListItem Text="2:交通费" Value="交通费"></asp:ListItem>
                                                                                         <asp:ListItem Text="3:福利费" Value="福利费"></asp:ListItem>
                                                                                         <asp:ListItem Text="4:通讯费" Value="通讯费"></asp:ListItem>
                                                                                         <asp:ListItem Text="5:宣传费" Value="宣传费"></asp:ListItem>
                                                                                        </asp:DropDownList>
                                                                                    </div>
                                                                                </td>
                                                                               
                                                                                <td>
                                                                                    <div align="left">
                                                                                        <asp:TextBox ID="txtAmount4" CssClass="textbox80" runat="server" onblur='SumInvoiceMoney();'></asp:TextBox>
                                                                                    </div>
                                                                                </td>
                                                                            </tr>
                                                                            <tr>
                                                                            <td>
                                                                                    <div align="left">
                                                                                        <asp:DropDownList ID="ddlType5" CssClass="inputmid" runat="server" AutoPostBack="true"  OnSelectedIndexChanged="ddlType5_Changed">
                                                                                        <asp:ListItem Text="---请选择---" Value=""></asp:ListItem>
                                                                                         <asp:ListItem Text="1:利金卡" Value="利金卡"></asp:ListItem>
                                                                                         <asp:ListItem Text="2:充值卡" Value="充值卡"></asp:ListItem>
                                                                                         <asp:ListItem Text="3:专有账户" Value="专有账户"></asp:ListItem>
                                                                                         <asp:ListItem Text="4:园林年卡" Value="园林年卡"></asp:ListItem>
                                                                                         <asp:ListItem Text="5:休闲年卡" Value="休闲年卡"></asp:ListItem>
                                                                                         <asp:ListItem Text="5:市民卡B卡卡费" Value="市民卡B卡卡费"></asp:ListItem>
                                                                                         <asp:ListItem Text="6:市民卡B卡充值" Value="市民卡B卡充值"></asp:ListItem>
                                                                                         <asp:ListItem Text="7:读卡器" Value="读卡器"></asp:ListItem>
                                                                                        </asp:DropDownList>
                                                                                    </div>
                                                                                </td>
                                                                                <td>
                                                                               <div align="left">
                                                                                 <asp:DropDownList ID="ddlProjName5" CssClass="inputmid" runat="server"  />
                                                                                 </div>
                                                                                 </td>
                                                                                <td>
                                                                                    <div align="left">
                                                                                        <asp:DropDownList ID="selProj5" CssClass="inputmid" runat="server">
                                                                                        <asp:ListItem Text="---请选择---" Value=""></asp:ListItem>
                                                                                       <asp:ListItem Text="1:充值" Value="充值"></asp:ListItem>
                                                                                         <asp:ListItem Text="2:交通费" Value="交通费"></asp:ListItem>
                                                                                         <asp:ListItem Text="3:福利费" Value="福利费"></asp:ListItem>
                                                                                         <asp:ListItem Text="4:通讯费" Value="通讯费"></asp:ListItem>
                                                                                         <asp:ListItem Text="5:宣传费" Value="宣传费"></asp:ListItem>
                                                                                        </asp:DropDownList>
                                                                                    </div>
                                                                                </td>
                                                                               
                                                                                <td>
                                                                                    <div align="left">
                                                                                        <asp:TextBox ID="txtAmount5" CssClass="textbox80" runat="server" onblur='SumInvoiceMoney();'></asp:TextBox>
                                                                                    </div>
                                                                                </td>
                                                                            </tr>

                                                                           
                                                                               
                                                                        </table>
                    
                </div>
                <div class="card">
                    购买方纳税人识别号</div>
                <div class="kuang5">
                    <table>
                        <tr>
                            <td width="8%">
                                <div align="left">
                                    纳税人识别号：</div>
                            </td>
                            <td width="90%" align="left" colspan="8">
                                <asp:TextBox ID="txtGMF" CssClass="inputlong" runat="server"></asp:TextBox>
                               <span class="red" runat="server" id="spnGroup">*</span> 
                            </td>
                            
                        </tr>
                    </table>
                </div>
                <div class="card">
                    邮箱</div>
                <div class="kuang5">
                    <table>
                        <tr>
                            <td width="8%">
                                <div align="left">
                                    邮箱地址：</div>
                            </td>
                            <td width="90%" align="left" colspan="8">
                                <asp:TextBox ID="txtEmail" CssClass="inputlong" runat="server"></asp:TextBox>
                                
                            </td>
                            
                        </tr>
                    </table>
                </div>
                <div class="card">
                    附注</div>
                <div class="kuang5">
                    <table>
                        <tr>
                            <td width="8%">
                                <div align="left">
                                    附注：</div>
                            </td>
                            <td width="90%" align="left" colspan="8">
                                <asp:TextBox ID="txtRemark" CssClass="inputlong" runat="server"></asp:TextBox>
                                
                            </td>
                            
                        </tr>
                    </table>
                </div>
                 <div class="btns">
                <table width="100" border="0" align="right" cellpadding="0" cellspacing="0">
                    <tr>
                        <td>
                            <asp:Button ID="btnSubmit" runat="server" Text="开票" CssClass="button1" OnClick="btnSubmit_Click" />      
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


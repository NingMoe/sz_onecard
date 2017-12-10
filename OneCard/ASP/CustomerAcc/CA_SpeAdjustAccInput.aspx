<%@ Page Language="C#" AutoEventWireup="true" CodeFile="CA_SpeAdjustAccInput.aspx.cs" Inherits="ASP_CustomerAcc_CA_SpeAdjustAccInput" EnableEventValidation="false" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
    <title>特殊调帐录入</title>
	<link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <link  href="../../css/Cust_AS.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
       <table border="0" cellpadding="0" cellspacing="0" width="100%">
        <td class="cust_left"></td>
        <td class="cust_mid">专有账户>特殊调帐录入</td>
        <td class="cust_right"></td>
        </table>
        <ajaxToolkit:ToolkitScriptManager runat="Server" EnableScriptGlobalization="true"
            EnableScriptLocalization="true" ID="ScriptManager2" />
        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
         <ContentTemplate>
         
         <asp:BulletedList ID="bulMsgShow" runat="server"/>
         <script runat="server" >public override void ErrorMsgShow() { ErrorMsgHelper(bulMsgShow); }</script>
         
         <div class="cust_tabbox">
	        <table border="0" cellpadding="0" cellspacing="0" width="100%">
    	        <td class="cust_top1_l"><div class="cust_p6"></div></td>
                <td class="cust_top1_m"><span style="line-height:22px; margin-left:5px; color:#333;">查询条件</span></td>
                <td class="cust_top1_r"></td>
            </table>
            <div class="cust_line1"></div>
            <div class="cust_line2"></div>
            <table width="100%" border="0" cellpadding="0" cellspacing="0" class="cust_form">
                <tr>
                <th>行业名称：</th>
                  <td>
                        <asp:DropDownList ID="selCalling" CssClass="inputmidder" runat="server" AutoPostBack="true"  OnSelectedIndexChanged="selCalling_SelectedIndexChanged" >
                        </asp:DropDownList>
                  </td>
                   <th>IC卡号：</th>
                   <td>
                     <asp:TextBox ID="txtCardNo" runat="server" CssClass="input" MaxLength="16" ></asp:TextBox>
                   </td>
                </tr>
                <tr>
                  <th>单位名称：</th>
                  <td><asp:DropDownList ID="selCorp" CssClass="inputmidder" runat="server" AutoPostBack="true" OnSelectedIndexChanged="selCorp_SelectedIndexChanged" >
                        </asp:DropDownList>
                  </td>
                  <th>交易日期：</th>
                   <td><asp:TextBox ID="txtTradeDate" runat="server" CssClass="input" MaxLength="10" ></asp:TextBox>
                        <ajaxToolkit:CalendarExtender ID="CalendarExtender2" 
                              runat="server" TargetControlID="txtTradeDate" Format="yyyy-MM-dd"  PopupPosition="BottomLeft" />
                   </td>
                   </tr>
                   <tr>
                  <th>部门名称：</th>
                  <td>
                        <asp:DropDownList ID="selDepart" CssClass="inputmidder" runat="server">
                        </asp:DropDownList>
                  </td>
                  <td>&nbsp;</td>
                  <td><div class="cust_bton1"><asp:LinkButton ID="btnQuery" runat="server" Text="查询"  OnClick="btnQuery_Click" /></div></td>
                </tr>
           </table>
        </div>
        <div class="cust_tabbox">
            <table border="0" cellpadding="0" cellspacing="0" width="100%">
            	<td class="cust_top1_l"><div class="cust_p5"></div></td>
        		<td class="cust_top1_m"><span style="line-height:22px; margin-left:5px; color:#333;">交易信息</span></td>
        		<td class="cust_top1_r"></td>  
            </table>
            <div class="cust_line1"></div>
        	<div class="cust_line2"></div>
        	<table border="0" cellpadding="0" cellspacing="0" width="100%">
    	        <tr>
    	            <td>
    	                <div id="gdtb" style=" height:200px;">
                          <asp:GridView ID="lvwConsumeInfo" runat="server"
                                CssClass="tab1"
                                Width ="100%"
                                HeaderStyle-CssClass="tabbt"
                                AlternatingRowStyle-CssClass="tabjg"
                                SelectedRowStyle-CssClass="tabsel"
                                AllowPaging="True"
                                PageSize="6"
                                PagerSettings-Mode="NumericFirstLast"
                                PagerStyle-HorizontalAlign="Left"
                                PagerStyle-VerticalAlign="Top"
                                AutoGenerateColumns="False"
                                OnPageIndexChanging="lvwConsumeInfo_Page"
                                OnRowDataBound="lvwConsumeInfo_RowDataBound"
                                OnSelectedIndexChanged="lvwConsumeInfo_SelectedIndexChanged"
                                OnRowCreated="lvwConsumeInfo_RowCreated">
                                <Columns>
                                      <asp:BoundField DataField="ICCARD_NO"       HeaderText="IC卡号"/>   
                                      <asp:BoundField DataField="ACCT_TYPE_NAME"       HeaderText="账户类型"/>    
                                      <asp:BoundField DataField="CALLING"  HeaderText="行业"/>                 
                                      <asp:BoundField DataField="CORP"     HeaderText="单位"/>            
                                      <asp:BoundField DataField="DEPART"   HeaderText="部门"/>                         
                                      <asp:BoundField DataField="TRADE_DATE"    HeaderText="交易时间"/>                           
                                      <asp:BoundField DataField="TRADE_CHARGE"   HeaderText="交易金额"/> 
                                      <asp:BoundField DataField="ORDER_NO"  HeaderText="消费流水号"/>
                                      <asp:BoundField DataField="ID"           HeaderText="ID"/>
                               </Columns>   
                               <EmptyDataTemplate>
                                  <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                     <tr class="tabbt">
                                          <td>IC卡号</td>
                                          <td>账户类型</td>
                                          <td>行业</td>
                                          <td>单位</td>
                                          <td>部门</td>
                                          <td>交易时间</td>
                                          <td>交易金额</td>
                                          <td>消费流水号</td>
                                       </tr>
                                  </table>
                               </EmptyDataTemplate>
                              </asp:GridView>
                        </div>
    	            </td>
    	        </tr>
    	    </table>
        </div>
        <div class="cust_tabbox">
            <table border="0" cellpadding="0" cellspacing="0" width="100%">
            	<td class="cust_top1_l"><div class="cust_p5"></div></td>
        		<td class="cust_top1_m"><span style="line-height:22px; margin-left:5px; color:#333;">调帐信息</span></td>
        		<td class="cust_top1_r"></td>  
            </table>
            <div class="cust_line1"></div>
        	<div class="cust_line2"></div>
        	<table width="100%" border="0" cellpadding="0" cellspacing="0" class="cust_form">
              <tr>
                <th width="10%" >行业名称：</th>
                <td>
                   <asp:Label ID="labCalling" runat="server"  ></asp:Label>
                </td>
                <th width="10%">单位名称：</th>
                <td>
                 <asp:Label ID="labCorp" runat="server"   ></asp:Label>
                </td>
                <th>部门名称：</th>
                <td>
                  <asp:Label ID="labDepart" runat="server"  ></asp:Label>
                </td>
              </tr>
              <tr>
                <th>IC卡号：</th>
                <td>
                    <%--<asp:Label ID="labCardNo" runat="server" ></asp:Label>--%>
                    <asp:TextBox ID="txtCardNoExt" runat="server" CssClass="input" MaxLength="16" ></asp:TextBox>
                </td>
                <th>账户类型：</th>
                <td><asp:Label ID="lblAcctType" runat="server" ></asp:Label></td>
                <th>交易日期：</th>
                <td><asp:Label ID="labTradeDate" runat="server" ></asp:Label></td>
              </tr>
              <tr>
                <th>交易金额：</th>
                <td> 
                    <asp:Label ID="labTradeMoney" runat="server"   ></asp:Label>
                    <asp:HiddenField ID="hidTradeMoneyExt" runat="server" />
                </td>
                <th>账户姓名：</th>
                <td><asp:TextBox ID="txtCardUser" runat="server" CssClass="input" MaxLength="50" ></asp:TextBox></td>
                <th>退款金额：</th>
                <td><asp:TextBox ID="txtRefundment" runat="server" CssClass="input" MaxLength="10" ></asp:TextBox></td>
              </tr>
              <tr>
                <th>应退还商户佣金：</th>
                <td>
                   <asp:TextBox ID="txtBrokerage" runat="server" CssClass="input" MaxLength="10" ></asp:TextBox>
                </td>
                 <th>调账原因：</th>
                <td><asp:DropDownList ID="selAdjReason" runat="server" CssClass="inputmid"></asp:DropDownList></td>
                <th>账户电话：</th>
                <td><asp:TextBox ID="txtUserPhone" runat="server" CssClass="input" MaxLength="40" ></asp:TextBox></td>
              </tr>
              <tr>
                <th>交易说明：</th>
                <td colspan=5><asp:TextBox ID="txtRemark" runat="server" CssClass="input" MaxLength="100" ></asp:TextBox></td>
              </tr>
            </table>
        </div>
        <div class="cust_tabbox">
            <div class="cust_bottom_bton">
            <asp:LinkButton ID="btnInput" runat="server" Text="录入" OnClientClick="return confirm('确认录入?');"  OnClick="btnInput_Click" />
            </div>
        </div>
         
       </ContentTemplate>
     </asp:UpdatePanel>
         
     
    </form>
</body>
</html>
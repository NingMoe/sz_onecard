<%@ Page Language="C#" AutoEventWireup="true" CodeFile="CA_SpeAdjustAccCheck.aspx.cs" Inherits="ASP_CustomerAcc_CA_SpeAdjustAccCheck" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
    <title>特殊调帐审核</title>
	<link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <link  href="../../css/Cust_AS.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
    <table border="0" cellpadding="0" cellspacing="0" width="100%">
        <td class="cust_left"></td>
        <td class="cust_mid">专有账户>特殊调帐审核</td>
        <td class="cust_right"></td>
        </table>
     <ajaxToolkit:ToolkitScriptManager runat="Server" EnableScriptGlobalization="true"
            EnableScriptLocalization="true" ID="ScriptManager2" />
        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
          <ContentTemplate>
         
         <asp:BulletedList ID="bulMsgShow" runat="server"/>
         <script runat="server" >public override void ErrorMsgShow(){ErrorMsgHelper(bulMsgShow);}</script>
         <div class="cust_tabbox">
            <table border="0" cellpadding="0" cellspacing="0" width="100%">
            	<td class="cust_top1_l"><div class="cust_p5"></div></td>
        		<td class="cust_top1_m"><span style="line-height:22px; margin-left:5px; color:#333;">待审核调帐信息</span></td>
        		<td class="cust_top1_r"></td>  
            </table>
            <div class="cust_line1"></div>
        	<div class="cust_line2"></div>
        	<table border="0" cellpadding="0" cellspacing="0" width="100%">
    	        <tr>
    	            <td>
    	                <div id="gdtb" class="clearCheck" style="height:400px">
                            <asp:GridView ID="gvResult" runat="server"
                                CssClass="tab1"
                                Width ="1500"
                                HeaderStyle-CssClass="tabbt"
                                AlternatingRowStyle-CssClass="tabjg"
                                SelectedRowStyle-CssClass="tabsel"
                                AllowPaging="True"
                                PageSize="10"
                                PagerSettings-Mode="NumericFirstLast"
                                PagerStyle-HorizontalAlign="Left"
                                PagerStyle-VerticalAlign="Top"
                                AutoGenerateColumns="False" 
                                OnPageIndexChanging="gvResult_Page"
                                OnRowDataBound="gvResult_RowDataBound"
                                >
                                <Columns>
                                      <asp:TemplateField>
                                        <HeaderTemplate>
                                          <asp:CheckBox ID="CheckBox1" runat="server"  AutoPostBack="true" OnCheckedChanged="CheckAll" />
                                        </HeaderTemplate>
                                        <ItemTemplate>
                                          <asp:CheckBox ID="ItemCheckBox" runat="server"/>
                                        </ItemTemplate>
                                      </asp:TemplateField>
                                      <asp:BoundField DataField="ICCARD_NO"       HeaderText="IC卡号"/>  
                                      <asp:BoundField DataField="ACCT_TYPE_NAME"  HeaderText="账户类型"/>  
                                      <asp:BoundField DataField="REFUNDMENT"   HeaderText="退款金额"/> 
                                      <asp:BoundField DataField="BROKERAGE"    HeaderText="应退还商户佣金"/> 
                                      <asp:BoundField DataField="REASONCODE"   HeaderText="调账原因"/>  
                                      <asp:BoundField DataField="STAFFNAME"    HeaderText="录入员工"/>  
                                      <asp:BoundField DataField="OPERATETIME"  HeaderText="录入时间"/>   
                                      <asp:BoundField DataField="CALLINGNAME"  HeaderText="行业"/>                 
                                      <asp:BoundField DataField="CORPNAME"     HeaderText="单位"/>            
                                      <asp:BoundField DataField="DEPARTNAME"   HeaderText="部门"/>   
                                      <asp:BoundField DataField="TRADETIME"    HeaderText="交易时间"/>                               
                                      <asp:BoundField DataField="TRADEMONEY"   HeaderText="交易金额"/> 
                                      <asp:BoundField DataField="TRADEID"      HeaderText="TRADEID"/>  
                                      <asp:BoundField DataField="CUSTNAME"     HeaderText="账户姓名"/> 
                                      <asp:BoundField DataField="CUSTPHONE"    HeaderText="账户电话"/> 
                               </Columns>   
                               <EmptyDataTemplate>
                                  <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                     <tr class="tabbt">
                                          <td><input type="checkbox" /></td>
                                          <td>IC卡号</td>
                                          <td>退款金额</td>
                                          <td>应退还商户佣金</td>
                                          <td>调账原因</td>
                                          <td>录入员工</td>
                                          <td>录入时间</td>
                                          <td>行业</td>
                                          <td>单位</td>
                                          <td>部门</td>
                                          <td>交易时间</td>
                                          <td>交易金额</td>
                                          <td>账户姓名</td>
                                          <td>账户电话</td>
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
              <div class="cust_bottom_bton"><asp:LinkButton ID="btnPass" runat="server" Text="通过"  OnClientClick="return confirm('确认通过?');"    OnClick="btnPass_Click" /></div>
              <div class="cust_bottom_bton"><asp:LinkButton ID="btnCancel" runat="server" Text="作废" OnClientClick="return confirm('确认作废?');"  OnClick="btnCancel_Click" /></div>
         </div>
    
         </ContentTemplate>
       </asp:UpdatePanel>

    
 
    </form>
</body>
</html>

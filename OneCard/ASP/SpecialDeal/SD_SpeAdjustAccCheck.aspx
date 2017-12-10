<%@ Page Language="C#" AutoEventWireup="true" CodeFile="SD_SpeAdjustAccCheck.aspx.cs" Inherits="ASP_SpecialDeal_SD_SpeAdjustAccCheck" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <title>特殊调帐审核</title>
	<link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
   
</head>
<body>
    <form id="form1" runat="server">
    <div class="tb">异常处理->特殊调帐审核</div>
     <ajaxToolkit:ToolkitScriptManager runat="Server" EnableScriptGlobalization="true"
            EnableScriptLocalization="true" ID="ScriptManager2" />
        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
          <ContentTemplate>
         
         <asp:BulletedList ID="bulMsgShow" runat="server"/>
         <script runat="server" >public override void ErrorMsgShow(){ErrorMsgHelper(bulMsgShow);}</script>
         
          
         <div class="con">
          <div class="jieguo">待审核调帐信息</div>
          <div class="kuang5">
            <div id="gdtb" style="height:400px">
             
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
                    
                          <asp:BoundField DataField="CARDNO"       HeaderText="IC卡号"/>  
                          <asp:BoundField DataField="REFUNDMENT"   HeaderText="退款金额"/> 
                          <asp:BoundField DataField="REBROKERAGE"   HeaderText="应退还商户佣金"/> 
                          <asp:BoundField DataField="REASONCODE"   HeaderText="调账原因"/>  
                          <asp:BoundField DataField="STAFFNAME"    HeaderText="录入员工"/>  
                          <asp:BoundField DataField="OPERATETIME"  HeaderText="录入时间"/>   
                          <asp:BoundField DataField="CALLINGNAME"  HeaderText="行业"/>                 
                          <asp:BoundField DataField="CORPNAME"     HeaderText="单位"/>            
                          <asp:BoundField DataField="DEPARTNAME"   HeaderText="部门"/>   
                          <asp:BoundField DataField="TRADEDATE"    HeaderText="交易日期"/>  
                          <asp:BoundField DataField="TRADETIME"    HeaderText="交易时间"/> 
                          <asp:BoundField DataField="PREMONEY"     HeaderText="交易前卡内余额"/>                                   
                          <asp:BoundField DataField="TRADEMONEY"   HeaderText="交易金额"/> 
                          <asp:BoundField DataField="TRADEID"      HeaderText="TRADEID"/>  
                          <asp:BoundField DataField="CUSTNAME"     HeaderText="持卡人"/> 
                          <asp:BoundField DataField="CUSTPHONE"    HeaderText="持卡人电话"/> 
                          
                          
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
                              <td>交易日期</td>
                              <td>交易时间</td>
                              <td>交易前卡内余额</td>
                              <td>交易金额</td>
                              <td>持卡人</td>
                              <td>持卡人电话</td>
                           
                         </tr>
                      </table>
                   </EmptyDataTemplate>
                  </asp:GridView>
              
            </div>
          </div>
         
          
          </div>
        <div class="btns">
          <table width="200" border="0" align="right" cellpadding="0" cellspacing="0">
            <tr>
            <td><asp:Button ID="btnPass" runat="server" Text="通过" CssClass="button1" OnClick="btnPass_Click" /></td>
              <td><asp:Button ID="btnCancel" runat="server" Text="作废" CssClass="button1" OnClick="btnCancel_Click" /></td>
            </tr>
          </table>

        </div>
        
         
         </ContentTemplate>
       </asp:UpdatePanel>

    
 
    </form>
</body>
</html>

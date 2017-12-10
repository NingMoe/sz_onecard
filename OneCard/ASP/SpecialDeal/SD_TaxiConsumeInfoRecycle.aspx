<%@ Page Language="C#" AutoEventWireup="true" CodeFile="SD_TaxiConsumeInfoRecycle.aspx.cs" Inherits="ASP_SpecialDeal_SD_TaxiConsumeInfoRecycle" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <title>出租补录回收</title>
	<link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" /> 
</head>
<body>
    <form id="form1" runat="server">
      <div class="tb">异常处理->出租补录信息回收</div>
      
      <ajaxToolkit:ToolkitScriptManager runat="Server" EnableScriptGlobalization="true"
            EnableScriptLocalization="true" ID="ScriptManager2" />
       <asp:UpdatePanel ID="UpdatePanel1" runat="server">
         <ContentTemplate>
         
        <asp:BulletedList ID="bulMsgShow" runat="server"/>
         <script runat="server" >public override void ErrorMsgShow(){ErrorMsgHelper(bulMsgShow);}</script>
         
      
      <div class="con">
          <div class="jieguo">出租车补录信息</div>
          <div class="kuang5">
            <div id="gdtb" style="height:350px">
              
              <asp:GridView ID="gvResult" runat="server"
                Width = "200%"
                CssClass="tab1"
                HeaderStyle-CssClass="tabbt"
                AlternatingRowStyle-CssClass="tabjg"
                SelectedRowStyle-CssClass="tabsel"
                AllowPaging="True"
                PageSize="100"
                PagerSettings-Mode="NumericFirstLast"
                PagerStyle-HorizontalAlign="left"
                PagerStyle-VerticalAlign="Top"
                AutoGenerateColumns="False"
                OnPageIndexChanging="gvResult_Page"
                OnRowDataBound="gvResult_RowDataBound"
                >
                   <Columns>
                        <asp:BoundField DataField="TRADEID"      HeaderText="TRADEID"/>  

                          <asp:TemplateField>
                            <HeaderTemplate>
                              <asp:CheckBox ID="CheckBox1" runat="server"  AutoPostBack="true" OnCheckedChanged="CheckAll" />
                            </HeaderTemplate>
                            <ItemTemplate>
                              <asp:CheckBox ID="ItemCheckBox" runat="server"/>
                            </ItemTemplate>
                          </asp:TemplateField>
                          <asp:BoundField DataField="CARDNO"       HeaderText="IC卡号"/>    
                          <asp:BoundField DataField="CORPNAME"     HeaderText="单位"/>            
                          <asp:BoundField DataField="DEPARTNAME"   HeaderText="部门"/>  
                          <asp:BoundField DataField="CALLINGSTAFFNO"      HeaderText="司机工号"/>  
                          <asp:BoundField DataField="TAXIDRINAME"      HeaderText="司机姓名"/>           
                          <asp:BoundField DataField="TRADEDATE"    HeaderText="交易日期"/>             
                          <asp:BoundField DataField="TRADETIME"    HeaderText="交易时间" Visible ="false"/>             
                          <asp:BoundField DataField="PREMONEY"     HeaderText="交易前￥"/>                 
                          <asp:BoundField DataField="TRADEMONEY"   HeaderText="交易￥"/> 
                          <asp:BoundField DataField="ASN"          HeaderText="卡片ASN号" />
                          <asp:BoundField DataField="CARDTRADENO"  HeaderText="卡片交易号"/>
                          <asp:BoundField DataField="POSTRADENO"   HeaderText="终端交易号"/>          
                          <asp:BoundField DataField="SAMNO"        HeaderText="PSAM编号"/>     
                          <asp:BoundField DataField="TAC"          HeaderText="TAC码"/>  
                          <asp:BoundField DataField="STAFFNO"      HeaderText="补录员工编号"/>  
                          <asp:BoundField DataField="APPSTAFF"     HeaderText="补录员工姓名"/>  
                          <asp:BoundField DataField="OPERATETIME"      HeaderText="补录时间" DataFormatString="{0:yyyy-MM-dd}" HtmlEncode="false"/>  
                          <asp:BoundField DataField="DEALSTATECODE" HeaderText="支付方式"/>  
                          
                          
                    </Columns>           
                    <EmptyDataTemplate>
                        <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                          <tr class="tabbt">
                            <td><input type="checkbox" /></td>
                              <td>IC卡号</td>
                              <td>单位</td>
                              <td>部门</td>
                              <td>司机工号</td>
                              <td>交易日期</td>
              
                              <td>交易前￥</td>
                              <td>交易￥</td>
                              <td>卡片ASN号</td>
                              <td>卡片交易号</td>
                              <td>终端交易号</td>
                              <td>PSAM编号</td>
                              <td>TAC码</td>
                              <td>补录员工编号</td>
                              <td>补录员工姓名</td>
                              <td>补录时间</td> 
                              <td>支付方式</td>          
                           </tr>
                          </table>
                    </EmptyDataTemplate>
                </asp:GridView>
             
            </div>
          </div>
          <div class="card">回收处理</div>
          
          
         <div class="kuang5">  
           <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
            <tr>
              <td width="12%"><div align="center">回收说明 :</div></td>
              <td width="70%"><div align="justify">
                <asp:TextBox ID="txtRenewRemark" runat="server" CssClass="inputmax" MaxLength="150" ></asp:TextBox>
              </div></td>
              <td><div align="left"><asp:Button ID="btnRecycle" runat="server" Text="回收" CssClass="button1" OnClick="btnRecycle_Click" /></div></td>
              <td>&nbsp;</td>
              <td><div align="left"><asp:Button ID="btnCancel" runat="server" Text="作废" CssClass="button1" OnClick="btnCancel_Click" /></div></td>
            </tr>
           </table>
         </div>
        </div>

    
      </ContentTemplate>
     </asp:UpdatePanel>
    
    
    
    
    
    
    </form>
</body>
</html>

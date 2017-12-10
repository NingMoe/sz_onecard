<%@ Page Language="C#" AutoEventWireup="true" CodeFile="TS_ConsumeAppendQry.aspx.cs" Inherits="ASP_TaxiService_TS_ConsumeAppendQry" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <title>消费补录查询</title>
	<link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
      <div class="tb">司机卡->消费补录查询</div>
      
        <ajaxToolkit:ToolkitScriptManager runat="Server" EnableScriptGlobalization="true"
            EnableScriptLocalization="true" ID="ScriptManager2" />
        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
         <ContentTemplate>
         <asp:BulletedList ID="bulMsgShow" runat="server"/>
         <script runat="server" >public override void ErrorMsgShow(){ErrorMsgHelper(bulMsgShow);}</script>
      
      
      
         <div class="con">
          <div class="base">查询方式</div>
          <div class="kuang5">
         <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
          <tr>
            <td style="width: 7%"><div align="right">司机工号:</div></td>
            <td>
               <asp:TextBox  runat="server" ID="txtStaffNoExt" MaxLength="6" Width="100px" CssClass="input"/>
            </td>
          
            <td width="7%"><div align="right">补录日期:</div></td>
            <td>
              <asp:TextBox ID="txtBeginDate" runat="server" CssClass="input" MaxLength="8"  Width="100px"/> 
                <ajaxToolkit:CalendarExtender ID="CalendarExtender1" 
                        runat="server" TargetControlID="txtBeginDate" Format="yyyyMMdd" />
            -
              <asp:TextBox ID="txtEndDate" runat="server" CssClass="input" MaxLength="8"  Width="100px"/>
                <ajaxToolkit:CalendarExtender ID="CalendarExtender2" 
                        runat="server" TargetControlID="txtEndDate" Format="yyyyMMdd" />
            </td>
                 </tr>
          <tr>
         <td width="7%"><div align="right">部门:</div></td>
                        <td>
                            <asp:DropDownList ID="selDept" CssClass="inputmid" runat="server" AutoPostBack="true" OnSelectedIndexChanged="selDept_Changed"></asp:DropDownList>
                        </td>
                        <td width="7%"><div align="right">员工:</div></td>
                        <td>
                            <asp:DropDownList ID="selStaff" CssClass="inputmid" runat="server"></asp:DropDownList>
                        </td>
            <td><asp:Button ID="btnQuery" runat="server" Text="查询" CssClass="button1" OnClick="btnQuery_Click" /></td>
     
          </tr>
        </table>

         </div>

         <div class="jieguo">
            <table border="0" width="95%">
                <tr>
                    <td align="left"><div class="Condition">出租车补录信息</div></td>
                    <td align="right">
                        <asp:Button ID="btnExport" CssClass="button1" runat="server" Text="导出" OnClick="btnExport_Click" />
                    </td>
                    <td>&nbsp;</td>
                </tr>
            </table>   
          </div> 
          
          <div class="kuang5">              
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
                           <asp:TemplateField>
                            <HeaderTemplate>#</HeaderTemplate>
                            <ItemTemplate>
                              <%#Container.DataItemIndex + 1%>
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
                              <td>#</td>
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
        
        </ContentTemplate>
          <Triggers>
           <asp:PostBackTrigger ControlID = "btnExport" />
          </Triggers>
       </asp:UpdatePanel>
  
    </form>
</body>
</html>

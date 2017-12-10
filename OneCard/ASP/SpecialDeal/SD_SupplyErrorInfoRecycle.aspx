<%@ Page Language="C#" AutoEventWireup="true" CodeFile="SD_SupplyErrorInfoRecycle.aspx.cs" Inherits="ASP_SpecialDeal_SD_SupplyErrorInfoRecycle" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <title>充值异常回收</title>
	<link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
   
   
</head>
<body>
    <form id="form1" runat="server">
    
       <div class="tb">异常处理->充值异常记录回收</div>
       <ajaxToolkit:ToolkitScriptManager runat="Server" EnableScriptGlobalization="true"
            EnableScriptLocalization="true" ID="ScriptManager2" />
       <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
         
         <asp:BulletedList ID="bulMsgShow" runat="server"/>
         <script runat="server" >public override void ErrorMsgShow(){ErrorMsgHelper(bulMsgShow);}</script>
         
         <div class="con">
         <div class="card">查询方式</div>
         <div class="kuang5">
           <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
               <tr>
                   <td> <div align="right">处理日期:</div></td>
                   <td>
                       <asp:TextBox ID="txtDealDate" runat="server" CssClass="input" MaxLength="7"></asp:TextBox>
                       <asp:HiddenField ID="hidDealDate" runat="server" />
                        <ajaxToolkit:CalendarExtender ID="CalendarExtender1" 
                          runat="server" TargetControlID="txtDealDate" Format="yyyy-MM"  PopupPosition="BottomLeft" />
                       年-月<span class="red"> * </span>
                   </td>
                   <td><div align="right">错误原因:</div></td>
                   <td>
                       <asp:DropDownList ID="selErrorReasonCode" CssClass="inputmid" runat="server">
                       </asp:DropDownList>
                   </td>
                   
                   
               </tr>
               <tr>
               <td><div align="right">行业名称:</div></td>
               <td>
                    <asp:DropDownList ID="selCalling" CssClass="inputmidder" runat="server" AutoPostBack="true" OnSelectedIndexChanged="selCalling_SelectedIndexChanged">
                    </asp:DropDownList>
               </td>
               <td><div align="right">交易起始日期:</div></td>
               <td>
                   <asp:TextBox ID="txtStartDate" runat="server" CssClass="input" MaxLength="10" ></asp:TextBox>
                   <ajaxToolkit:CalendarExtender ID="BeginCalendar" 
                          runat="server" TargetControlID="txtStartDate" Format="yyyy-MM-dd"  PopupPosition="BottomLeft" />
               </td>
               <td ><div align="right">交易终止日期:</div></td>
               <td >
                  <asp:TextBox ID="txtEndDate" runat="server" CssClass="input" MaxLength="10"></asp:TextBox>
                   <ajaxToolkit:CalendarExtender ID="CalendarExtender2" 
                          runat="server" TargetControlID="txtEndDate" Format="yyyy-MM-dd"  PopupPosition="BottomLeft" />
               </td>
               </tr>
               <tr>
               <td><div align="right">单位名称:</div></td>
               <td>
                    <asp:DropDownList ID="selCorp" CssClass="inputmidder" runat="server" AutoPostBack="true" 
                           OnSelectedIndexChanged="selCorp_SelectedIndexChanged" >
                    </asp:DropDownList>
                </td>
                <td> <div align="right">PSAM编号:</div></td>
                   <td>
                      <asp:TextBox ID="txtPasmNo" runat="server" CssClass="input" MaxLength="12" ></asp:TextBox>
                   </td>
               <td><div align="right">POS编号:</div></td>
               <td><asp:TextBox ID="txtPosNo" runat="server" CssClass="input" MaxLength="6" ></asp:TextBox> </td>
             </tr>
             <tr>
               <td><div align="right">部门名称:</div></td>
               <td>
                    <asp:DropDownList ID="selDepart" CssClass="inputmidder" runat="server">
                    </asp:DropDownList>
               </td>
               <td><div align="right">IC卡号:</div></td>
               <td><asp:TextBox ID="txtCardNo" runat="server" CssClass="input" MaxLength="16"></asp:TextBox></td>
               <td></td>
               <td><asp:Button ID="btnQuery" runat="server" Text="查询" CssClass="button1" OnClick="btnQuery_Click"  /></td>
           </tr>
          
           </table>
         </div>
          <div class="jieguo">充值异常信息</div>
          <div class="kuang5">
          
            <!-- 列表框 -->
            <div class="gdtb" style="height:250px">
               <asp:GridView ID="gvResult" runat="server"
                Width = "200%"
                CssClass="tab1"
                HeaderStyle-CssClass="tabbt"
                AlternatingRowStyle-CssClass="tabjg"
                SelectedRowStyle-CssClass="tabsel"
                AllowPaging="True"
                PageSize="8"
                PagerSettings-Mode="NumericFirstLast"
                PagerStyle-HorizontalAlign="left"
                PagerStyle-VerticalAlign="Top"
                AutoGenerateColumns="False" 
                OnPageIndexChanging="gvResult_Page"
                OnRowDataBound="gvResult_RowDataBound"
                >
                   <Columns>
                          <asp:TemplateField>
                            <HeaderTemplate>
                              <asp:CheckBox ID="CheckBox1" runat="server"  AutoPostBack="true" OnCheckedChanged="CheckAll"  />
                            </HeaderTemplate>
                            <ItemTemplate>
                              <asp:CheckBox ID="ItemCheckBox" runat="server"/>
                            </ItemTemplate>
                          </asp:TemplateField>
                          <asp:BoundField DataField="CARDNO"       HeaderText="IC卡号"/>      
                          <asp:BoundField DataField="CALLINGNAME"  HeaderText="行业"/>                 
                          <asp:BoundField DataField="CORPNAME"     HeaderText="单位"/>            
                          <asp:BoundField DataField="DEPARTNAME"   HeaderText="部门"/>             
                          <asp:BoundField DataField="TRADEDATE"    HeaderText="交易日期"/>             
                          <asp:BoundField DataField="TRADETIME"    HeaderText="交易时间"/>             
                          <asp:BoundField DataField="PREMONEY"     HeaderText="交易前卡内金额"/>                 
                          <asp:BoundField DataField="TRADEMONEY"   HeaderText="交易金额"/> 
                          <asp:BoundField DataField="ERRORREASON"  HeaderText="错误原因" />
                          <asp:BoundField DataField="ASN"          HeaderText="卡片ASN号" />
                          <asp:BoundField DataField="CARDTRADENO"  HeaderText="卡片交易序列号"/>
                          <asp:BoundField DataField="POSNO"        HeaderText="POS编号"/>          
                          <asp:BoundField DataField="SAMNO"        HeaderText="PSAM编号"/>     
                          <asp:BoundField DataField="TAC"          HeaderText="TAC码"/>  
                          <asp:BoundField DataField="ID"           HeaderText="ID"/>  
                    </Columns>           
                    <EmptyDataTemplate>
                        <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                          <tr class="tabbt">
                            <td><input type="checkbox" /></td>
                            <td>IC卡号</td>
                            <td>行业</td>
                            <td>单位</td>
                            <td>部门</td>
                            <td>交易日期</td>
                            <td>交易时间</td>
                            <td>交易前卡内金额</td>
                            <td>交易金额</td>
                            <td>错误原因</td>
                            <td>卡片ASN号</td>
                            <td>卡片交易序列号</td>
                            <td>POS编号</td>
                            <td>PSAM编号</td>
                            <td>TAC码</td>                 
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
              <td><div align="left"><asp:Button ID="btnRecycle" runat="server" Text="回收" CssClass="button1" OnClick="btnRecycle_Click"  /></div></td>
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

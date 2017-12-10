<%@ Page Language="C#" AutoEventWireup="true" CodeFile="TS_ConsumeInfoQuery.aspx.cs" Inherits="ASP_TaxiService_TS_ConsumeInfoQuery" %>
<%@ Register Src="../../CardReader.ascx" TagName="CardReader" TagPrefix="cr" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <title>消费信息查询</title>

	<link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    
</head>
<body>
	<cr:CardReader id="cardReader" Runat="server"/>    

    <form id="form1" runat="server">
      <div class="tb">司机卡->消费信息查询</div>
      
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
            <td style="width: 10%"><div align="right">司机工号:</div></td>
            <td> 
               <asp:TextBox  runat="server" ID="txtStaffNoExt" MaxLength="6" Width="100px" CssClass="input"></asp:TextBox>
            </td>
            
            <td width="12%"><div align="right">交易起始日期:</div></td>
            <td>
              <asp:TextBox ID="txtBeginDate" runat="server" CssClass="input" MaxLength="8"  Width="100px"></asp:TextBox> 
                <ajaxToolkit:CalendarExtender ID="BeginCalendar" 
                        runat="server" TargetControlID="txtBeginDate" Format="yyyyMMdd" />
            </td>
            
            <td width="12%"><div align="right">交易终止日期:</div></td>
            
            <td>
              <asp:TextBox ID="txtEndDate" runat="server" CssClass="input" MaxLength="8"  Width="100px"></asp:TextBox> 
                <ajaxToolkit:CalendarExtender ID="CalendarExtender1" 
                        runat="server" TargetControlID="txtEndDate" Format="yyyyMMdd" />
            </td>
            
            <td width="12%">
              <asp:Button ID="btnReadCard" runat="server" Text="读卡" CssClass="button1" 
                        OnClientClick="return readDriverInfo('txtStaffNoExt')" OnClick="btnReadCard_Click"/>

            </td>
            <td width="10%"><asp:Button ID="btnQuery" runat="server" Text="查询" CssClass="button1" OnClick="btnQuery_Click" /></td>
          </tr>
        </table>

         </div>
          <div class="jieguo">
            <table border="0" width="95%">
                <tr>
                    <td align="left"><div class="Condition">正常交易信息</div></td>
                    <td align="right">
                        <asp:Button ID="btnExport" CssClass="button1" runat="server" Text="导出" OnClick="btnSave_Click" />
                    </td>
                    <td>&nbsp;</td>
                </tr>
            </table>   
          </div> 
          <div class="kuang5">
          <div class="gdtb" style="height:420px">
             <asp:GridView ID="gvResult" runat="server"
                    CssClass="tab1"
                    Width ="98%"
                    HeaderStyle-CssClass="tabbt"
                    AlternatingRowStyle-CssClass="tabjg"
                    SelectedRowStyle-CssClass="tabsel"
                    AllowPaging="True"
                    PageSize="100"
                    PagerSettings-Mode="NumericFirstLast"
                    PagerStyle-HorizontalAlign="Left"
                    PagerStyle-VerticalAlign="Top"
                    OnPageIndexChanging="gvResult_Page"
                    OnRowDataBound ="gvResult_RowDataBound"
                    AutoGenerateColumns="False">
                    <Columns>
                          <asp:BoundField DataField="CALLINGSTAFFNO"  HeaderText="司机工号" />       
                          <asp:BoundField DataField="TRADEDATE"  HeaderText="交易日期" />       
                          <asp:BoundField DataField="TRADETIME"  HeaderText="交易时间" />           
                          <asp:BoundField DataField="TRADEMONEY" HeaderText="交易金额"/>  
                          <asp:BoundField DataField="PREMONEY"   HeaderText="交易前余额"/>           
                          <asp:BoundField DataField="CARDNO"     HeaderText="消费卡号"/>       
                          <asp:BoundField DataField="SAMNO"      HeaderText="PSAM编号"/>  
                          <asp:BoundField DataField="PSAMVERNO"  HeaderText="PSAM卡版本号"/>  
                                     
                   </Columns>   
                   
                   <EmptyDataTemplate>
                      <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                         <tr class="tabbt">
                            <td>司机工号</td>
                            <td>交易日期</td>
                            <td>交易时间</td>
                            <td>交易金额</td>
                            <td>交易前余额</td>
                            <td>消费卡序列号</td>
                            <td>PSAM编号</td>
                            <td>PSAM卡版本号</td>
                         </tr>
                      </table>
                   </EmptyDataTemplate>
                  </asp:GridView>
          </div>
          
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


<%@ Page Language="C#" AutoEventWireup="true" CodeFile="TS_ConsumeInfoStat.aspx.cs" Inherits="ASP_TaxiService_TS_ConsumeInfoStat" %>
<%@ Register Src="../../CardReader.ascx" TagName="CardReader" TagPrefix="cr" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
    <title>消费信息统计</title>
	<link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    
</head>
<body>
	<cr:CardReader id="cardReader" Runat="server"/>    

    <form id="form1" runat="server">
      <div class="tb">司机卡->消费信息统计</div>
      
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
            <td width="12%" colspan="2">
               <asp:TextBox  runat="server" ID="txtStaffNoExt" MaxLength="6" Width="100px" CssClass="input"/><span class="red">*</span>
            </td>
          
            <td width="12%"><div align="right">交易起始日期:</div></td>
            <td>
              <asp:TextBox ID="txtBeginDate" runat="server" CssClass="input" MaxLength="8"  Width="100px"/> <span class="red">*</span>
                <ajaxToolkit:CalendarExtender ID="CalendarExtender1" 
                        runat="server" TargetControlID="txtBeginDate" Format="yyyyMMdd" />
            </td>
            
            <td width="12%"><div align="right">交易终止日期:</div></td>
            <td>
              <asp:TextBox ID="txtEndDate" runat="server" CssClass="input" MaxLength="8"  Width="100px"/> <span class="red">*</span>
                <ajaxToolkit:CalendarExtender ID="CalendarExtender2" 
                        runat="server" TargetControlID="txtEndDate" Format="yyyyMMdd" />
            </td>
            
            <td width="13%">
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
                    <td align="left"><div class="Condition">查询结果</div></td>
                    <td align="right">
                        <asp:Button ID="btnExport" CssClass="button1" runat="server" Text="导出" OnClick="btnSave_Click" />
                    </td>
                    <td>&nbsp;</td>
                </tr>
            </table>   
          </div> 
          
          <div class="kuang5">
          <div class="gdtb" style="height:420px">
          
             <asp:GridView ID="lvwTaxiTradeStatInfo" runat="server"
                    CssClass="tab1"
                    Width ="98%"
                    HeaderStyle-CssClass="tabbt"
                    AlternatingRowStyle-CssClass="tabjg"
                    SelectedRowStyle-CssClass="tabsel"
                    AllowPaging="false"
                    PagerSettings-Mode="NumericFirstLast"
                    PagerStyle-HorizontalAlign="Left"
                    PagerStyle-VerticalAlign="Top"
                    AutoGenerateColumns="true"
                    OnRowDataBound="gvResult_RowDataBound"
                    ShowFooter="true"
                    EmptyDataText="没有数据记录!" />
          
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

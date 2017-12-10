<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PB_ReadRecord.aspx.cs" Inherits="ASP_PersonalBusiness_PB_ReadRecord" %>
<%@ Register Src="../../CardReader.ascx" TagName="CardReader" TagPrefix="cr" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
<title>卡内记录读取</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />

    <link href="../../css/card.css" rel="stylesheet" type="text/css" />

</head>
<body>
	<cr:CardReader id="cardReader" Runat="server" />    
	    
    <form id="form1" runat="server">

		<asp:HiddenField runat="server" ID="hidTradeno" />
		<asp:HiddenField runat="server" ID="hidTradeMoney" />
		<asp:HiddenField runat="server" ID="hidTradeType" />
		<asp:HiddenField runat="server" ID="hidTradeTerm" />
		<asp:HiddenField runat="server" ID="hidTradeDate" />
		<asp:HiddenField runat="server" ID="hidTradeTime" />
		
        <asp:HiddenField runat="server" ID="hiddenAsn" />
        <asp:HiddenField runat="server" ID="hiddenLabCardtype" />
        <asp:HiddenField runat="server" ID="hiddensDate" />
        <asp:HiddenField runat="server" ID="hiddeneDate" />
        <asp:HiddenField runat="server" ID="hiddencMoney" />
        <asp:HiddenField runat="server" ID="hiddentradeno" />

    <div class="tb">
个人业务->卡内记录读取

</div>
<ajaxToolkit:ToolkitScriptManager runat="Server" EnableScriptGlobalization="true"
            EnableScriptLocalization="true" ID="ScriptManager2" />
          <script type="text/javascript" language="javascript">
                var swpmIntance = Sys.WebForms.PageRequestManager.getInstance();
                swpmIntance.add_initializeRequest(BeginRequestHandler);
                swpmIntance.add_pageLoading(EndRequestHandler);
				function BeginRequestHandler(sender, args){
				try {MyExtShow('请等待', '正在提交后台处理中...'); } catch(ex){}
				}
				function EndRequestHandler(sender, args) {
				try {MyExtHide(); } catch(ex){}
				}
          </script> 

        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
            <ContentTemplate>
<asp:BulletedList ID="bulMsgShow" runat="server">
</asp:BulletedList>
<script runat="server" >public override void ErrorMsgShow(){ErrorMsgHelper(bulMsgShow);}</script>  
<div class="con">
  <div class="base">卡信息查询</div>
  <div class="kuang5">
 <table width="95%" border="0" cellpadding="0" cellspacing="0" class="12text">
  <tr>
    <td width="9%"><div align="right">卡号:</div></td>
    <td width="12%"><asp:TextBox ID="txtCardno" CssClass="labeltext" maxlength="16" runat="server"></asp:TextBox></td>
    <td width="12%"><div align="right">卡内余额:</div></td>
    <td width="11%"><asp:TextBox ID="cMoney" CssClass="labeltext"  width=100 runat="server" Text=""></asp:TextBox></td>
    <td width="9%"><div align="right">&nbsp;</div></td>
    <td width="10%">&nbsp;</td>
    <td width="9%"><div align="right">&nbsp;</div></td>
    <td width="12%">&nbsp;</td>
    <td width="16%"><asp:Button ID="btnReadCard" CssClass="button1" runat="server" Text="读卡" OnClientClick="return readCardRecord()" OnClick="btnReadCard_Click" /></td>
    </tr>
  <tr>
    <td><div align="right">&nbsp;</div></td>
    <td>

    </td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
</table>
  </div>
  
  <div class="base">查询</div>
  <div class="kuang5">
 <table width="95%" border="0" cellpadding="0" cellspacing="0" class="12text">
  <tr>
    <td width="9%"><div align="right">卡号:</div></td>
    <td width="12%"><asp:TextBox ID="Cardno" CssClass="input" maxlength="16" runat="server"></asp:TextBox></td>
    <td width="12%"><div align="right">&nbsp;</div></td>
    <td width="11%">&nbsp;</td>
    <td width="9%"><div align="right">&nbsp;</div></td>
    <td width="10%">&nbsp;</td>
    <td width="9%"><div align="right">&nbsp;</div></td>
    <td width="12%">&nbsp;</td>
    <td width="16%"><asp:Button ID="btnQuery" CssClass="button1" runat="server" Text="查询" OnClick="btnQuery_Click" /></td>
    </tr>
  <tr>
    <td><div align="right">&nbsp;</div></td>
    <td>

    </td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
</table>
  </div>
  
  <div class="jieguo">交易记录信息
    
  </div>
  <div class="kuang5">
  <div class="gdtb" style="height:260px">
  
  <asp:GridView ID="lvwQuery" runat="server"
                    Width = "95%"
                    CssClass="tab1"
                    HeaderStyle-CssClass="tabbt"
                    AlternatingRowStyle-CssClass="tabjg"
                    SelectedRowStyle-CssClass="tabsel"
                    PageSize="10"
                    PagerSettings-Mode="NumericFirstLast"
                    PagerStyle-HorizontalAlign="left"
                    PagerStyle-VerticalAlign="Top"
                    EmptyDataText="没有数据记录!"
                    AutoGenerateColumns="true" 
                    OnRowDataBound="lvwQuery_RowDataBound">
    </asp:GridView>
  </div>
  
</div>
<div class="btns">
     <table width="100" border="0" align="right" cellpadding="0" cellspacing="0">
  <tr>
    <td width="102"><asp:Button ID="btnSave" CssClass="button1" runat="server" Text="保存" Enabled=false OnClick="btnSave_Click" /></td>
  </tr>
</table>

     </div>
     </ContentTemplate>          
        </asp:UpdatePanel>
    </form>
</body>
</html>

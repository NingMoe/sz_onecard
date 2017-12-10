<%@ Page Language="C#" AutoEventWireup="true" CodeFile="CG_CashGiftRecycle.aspx.cs" Inherits="ASP_CashGift_CG_CashGiftRecycle" %>
<%@ Register Src="../../CardReader.ascx" TagName="CardReader" TagPrefix="cr" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <title>利金卡回收</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
     <script type="text/javascript" src="../../js/print.js"></script>
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript">
    
    function assignGiftFunc(cardNoId, cardInfo)
    {
        assignValue('txtCardNo', cardInfo.cardNo);
        assignValue('hidAsn', cardInfo.appSn);
        assignValue('txtStartDate', cardInfo.appStartDate);
        assignValue('txtEndDate', cardInfo.appEndDate);
        assignValue('txtCardBalance', (cardInfo.balance/100).toFixed(2));
        assignValue('txtWallet2', (cardInfo.wallet2/100).toFixed(2));
        assignValue('hidTradeNo', cardInfo.tradeNo);	    
   }
       
    </script>
</head>
<body>
	<cr:CardReader id="cardReader" runat="server"/>    
	
    
    <form id="form1" runat="server">
       <div class="tb">利金卡->回收</div>
        <ajaxToolkit:ToolkitScriptManager EnableScriptGlobalization="true" 
            EnableScriptLocalization="true" ID="ScriptManager1" runat="server"/>
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
          <asp:UpdatePanel ID="UpdatePanel1" runat="server" RenderMode="Inline" >
            <ContentTemplate>
            
    <aspControls:PrintShouJu ID="ptnShouJu" runat="server" PrintArea="ptnShouJu1" />


    <asp:BulletedList ID="bulMsgShow" runat="server">
    </asp:BulletedList>
    <script runat="server" >public override void ErrorMsgShow(){ErrorMsgHelper(bulMsgShow);}</script>          

  <div class="con">
  <div class="card">[利金卡]卡片信息</div>
  <div class="kuang5">
 <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text20">
  <tr>
    <td width="10%" align="right">用户卡号:</td>
    <td width="13%"><asp:TextBox ID="txtCardNo" CssClass="labeltext" runat="server" /></td>
    <td width="9%" align="right">卡片类型:</td>
    <td width="13%"><asp:Label ID="labCardType" CssClass="labeltext" runat="server" /></td>
    <td width="9%" align="right">卡片状态:</td>
    <td width="13%"><asp:TextBox ID="txtCardState" CssClass="labeltext" runat="server" /></td>
    <td width="9%">&nbsp;</td>
    <td width="24%"><asp:Button ID="btnReadCard" Text="读卡" CssClass="button1" runat="server" 
        OnClientClick="return ReadCashGiftInfo(assignGiftFunc)" OnClick="btnReadCard_Click"/></td>

  
  <asp:HiddenField runat="server" ID="hidWarning" />
  <asp:HiddenField runat="server" ID="hidAsn" />
  <asp:HiddenField runat="server" ID="hidTradeNo" />

  <asp:LinkButton runat="server" ID="btnConfirm" OnClick="btnConfirm_Click"/></tr>
  <tr>
    <td align="right">卡启用日期:</td>
    <td><asp:TextBox ID="txtStartDate" CssClass="labeltext" runat="server" /></td>
    <td align="right">卡结束日期:</td>
    <td><asp:TextBox ID="txtEndDate" CssClass="labeltext" runat="server" /></td>
    <td align="right">卡钱包1:</td>
    <td><asp:TextBox ID="txtCardBalance" CssClass="labeltext" runat="server" /></td>
    <td align="right">卡钱包2:</td>
    <td><asp:TextBox ID="txtWallet2" CssClass="labeltext" runat="server" /></td>
  </tr>
  <tr>
    <td align="right">库启用日期:</td>
    <td><asp:Label ID="labDbStartDAte"  runat="server" /></td>
    <td align="right">库结束日期:</td>
    <td><asp:Label ID="labDbEndDate"  runat="server" /></td>
    <td align="right">库内余额:</td>
    <td><asp:Label ID="labDbMoney" runat="server" /></td>
    <td align="right">售卡金额:</td>
    <td><asp:Label ID="labDbSaleMoney" runat="server" /></td>
  </tr></table>

 </div>
  <div class="pip">用户信息</div>
  <div class="kuang5">
 <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
  <tr>
    <td width="10%"><div align="right">用户姓名:</div></td>
    <td width="13%"><asp:Label ID="txtCustName"  runat="server" /></td>
    <td width="12%"><div align="right">出生日期:</div></td>
    <td width="13%"><asp:Label ID="txtCustBirth"  runat="server" /></td>
    <td width="12%"><div align="right">证件类型:</div></td>
    <td width="13%">
    <asp:Label ID="selPaperType"  runat="server"/>
    </td>
    <td width="12%"><div align="right">证件号码:</div></td>
    <td width="13%">
    <asp:Label ID="txtPaperNo" runat="server" />
     </td>
    </tr>
  <tr>
    <td><div align="right">用户性别:</div></td>
    <td>
        <asp:Label ID="selCustSex" runat="server"/>
    </td>
    <td><div align="right">联系电话:</div></td>
    <td>
         <asp:Label ID="txtCustPhone" runat="server" />
    </td>
    <td><div align="right">邮政编码:</div></td>
    <td>
        <asp:Label ID="txtCustPost" runat="server" />
    </td>
    <td><div align="right">联系地址:</div></td>
    <td>
        <asp:Label ID="txtCustAddr" runat="server" />
    </td>
    </tr>
  <tr>
    <td><div align="right">电子邮件:</div></td>
    <td>
        <asp:Label ID="txtEmail"  runat="server"  />
    </td>
    <td><div align="right">备注:</div></td>
    <td colspan="4">
        <asp:Label ID="txtRemark"  runat="server"  />
    </td>
    <td>
    &nbsp;
    </td>
  </tr>
</table>

 </div> </div>

 <div class="footall"></div>
<div class="btns">
     <table width="200" align="right" border="0"cellpadding="0" cellspacing="0">
  <tr>
    <td>&nbsp;</td>
    <td ><asp:Button ID="btnSubmit" Enabled="false" CssClass="button1" runat="server" Text="提交" 
        OnClick="btnSubmit_Click"/></td>
  </tr>
</table>

</div>  
    
                </ContentTemplate>
        </asp:UpdatePanel>
    </form>
</body>
</html>

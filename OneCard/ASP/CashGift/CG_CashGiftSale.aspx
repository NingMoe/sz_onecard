<%@ Page Language="C#" AutoEventWireup="true" CodeFile="CG_CashGiftSale.aspx.cs" Inherits="ASP_CashGift_CashGiftSale" %>
<%@ Register Src="../../CardReader.ascx" TagName="CardReader" TagPrefix="cr" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <title>利金卡售卡</title>
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
       <div class="tb">利金卡->售卡</div>
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
  <asp:HiddenField runat="server" ID="hidSeqNo" /> 
  <asp:HiddenField runat="server" ID="hidCardnoForCheck" /> 

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
</table>

 </div>
  <div class="pip">[利金卡]用户信息</div>
  <div class="kuang5">
 <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
  <tr>
    <td width="10%" align="right">用户姓名:</td>
    <td width="13%"><asp:TextBox ID="txtCustName" CssClass="input" runat="server" MaxLength="50" /></td>
    <td width="9%" align="right">出生日期:</td>
    <td width="13%"><asp:TextBox ID="txtCustBirth" CssClass="input" runat="server" MaxLength="8" /></td>
        <ajaxToolkit:CalendarExtender ID="FCalendar" runat="server" TargetControlID="txtCustBirth"
            Format="yyyyMMdd" />
    <td width="9%" align="right">证件类型:</td>
    <td width="13%">
    <asp:DropDownList ID="selPaperType" CssClass="input" runat="server">
    </asp:DropDownList>
    </td>
    <td width="9%" align="right">证件号码:</td>
    <td width="24%">
    <asp:TextBox ID="txtPaperNo" CssClass="inputmid" runat="server" MaxLength="20" />
     </td>
    </tr>
  <tr>
    <td align="right">用户性别:</td>
    <td>
        <asp:DropDownList ID="selCustSex" CssClass="input" runat="server"/>
    <td align="right">联系电话:</td>
    <td>
         <asp:TextBox ID="txtCustPhone" CssClass="input" runat="server" MaxLength="20" />
    </td>
    <td align="right">邮政编码:</td>
    <td>
        <asp:TextBox ID="txtCustPost" CssClass="input" runat="server" MaxLength="6" />
    </td>
    <td align="right">联系地址:</td>
    <td>
        <asp:TextBox ID="txtCustAddr" CssClass="inputmid" runat="server" MaxLength="50" />
    </td>
    </tr>
  <tr>
    <td align="right">电子邮件:</td>
    <td>
        <asp:TextBox ID="txtEmail" CssClass="input" runat="server" MaxLength="30"/>
    </td>
    <td align="right">备注:</td>
    <td colspan="4">
        <asp:TextBox ID="txtRemark" CssClass="inputlong" runat="server" MaxLength="100"/>
    </td>  
    <td>
    <asp:Button ID="txtReadPaper" Text="读二代证" CssClass="button1" runat="server"
         OnClientClick="readIDCard('txtCustName', 'selCustSex', 'txtCustBirth', 'selPaperType', 'txtPaperNo', 'txtCustAddr')"/>

    </td>
  </tr>
</table>

 </div>
 <div class="money">费用信息</div>
 <div class="kuang5">
 <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text20">
  <tr>
    <td width="10%" align="right">售卡金额:</td>
    <td width="13%"><asp:TextBox ID="txtSaleMoney" CssClass="input" runat="server" MaxLength="6" Width="50px" />元<span class="red">*</span></td>
    <td width="9%" align="right">&nbsp;</td>
    <td width="13%">&nbsp;
    </td>
    <td width="9%" align="right">&nbsp;</td>
    <td width="13%">&nbsp;</td>
    <td width="9%">&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
</table>
 </div>
 </div>

 <div class="footall"></div>
<div class="btns">
     <table width="200" align="right" border="0"cellpadding="0" cellspacing="0">
  <tr>
    <td><asp:Button ID="btnPrintSJ" runat="server" Text="打印收据" 
        CssClass="button1" Enabled="false" OnClientClick="printdiv('ptnShouJu1')"/></td>
    <td ><asp:Button ID="btnSubmit" Enabled="false" CssClass="button1" runat="server" Text="提交" 
        OnClick="btnSubmit_Click" OnClientClick="return CardAndReadCardForCheck()"/></td>
  </tr>
</table>
<asp:CheckBox ID="chkShouju" runat="server" Text="自动打印收据"  Checked="true"/>

</div>  
    
                </ContentTemplate>
        </asp:UpdatePanel>
    </form>
</body>
</html>

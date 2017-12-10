<%@ Page Language="C#" AutoEventWireup="true" CodeFile="SD_SpeAdjustAcc.aspx.cs" Inherits="ASP_SpecialDeal_SD_SpeAdjustAcc" %>
<%@ Register Src="../../CardReader.ascx" TagName="CardReader" TagPrefix="cr" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <title>特殊调帐</title>

    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="../../js/print.js"></script>
     <script type="text/javascript">

         function assignGiftFunc(cardNoId, cardInfo) {
             assignValue('hiddenCardno', cardInfo.cardNo);
             assignValue('hiddenAsn', cardInfo.appSn);
             assignValue('hiddensDate', cardInfo.appStartDate);
             assignValue('hiddeneDate', cardInfo.appEndDate);
             assignValue('hiddencMoney', cardInfo.balance);
             assignValue('hiddenWallet2', (cardInfo.wallet2 / 100).toFixed(2));
             assignValue('hiddentradeno', cardInfo.tradeNo);
         }

         function readCashCard() {
             return ReadCashGiftInfo(assignGiftFunc);
         }
       
    </script>
    
</head>
<body>
    <cr:CardReader id="cardReader" Runat="server"/>  
    <form id="form1" runat="server">
    <div class="tb">异常处理->特殊调帐</div>
   
     <ajaxToolkit:ToolkitScriptManager runat="Server" EnableScriptGlobalization="true"
            EnableScriptLocalization="true" ID="ScriptManager2" />
        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
          <ContentTemplate>
         
         <aspControls:PrintPingZheng ID="ptnPingZheng" runat="server" PrintArea="ptnPingZheng1"  />
     
          
         <asp:BulletedList ID="bulMsgShow" runat="server"/>
         <script runat="server" >public override void ErrorMsgShow(){ErrorMsgHelper(bulMsgShow);}</script>
         
         <div class="con">
	        <div class="card">卡片信息</div>
           <div class="kuang5">
           <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
            <tr>
               <td width="12%"> <div align="right">用户卡号:</div></td>
               <td width="20%">
                <asp:TextBox ID="txtCardno" CssClass="labeltext" maxlength="16" runat="server"></asp:TextBox>
               </td>
               <td width="15%"><div align="right">当前卡内余额:</div></td>
               <td width="29%"><asp:TextBox ID="txtCurrMoney" CssClass="labeltext" maxlength="16" runat="server">
                  </asp:TextBox>
               </td>
               <td width="24%">
               <asp:Button ID="btnReadCard" CssClass="button1" runat="server" Text="读卡" 
                  OnClientClick="return ReadCardInfo()" OnClick="btnReadCard_Click" />
               <asp:HiddenField ID="hiddenCardno" runat="server" />
                <asp:HiddenField ID="hiddenAsn" runat="server"/>
                <asp:HiddenField ID="hiddensDate" runat="server" />
                <asp:HiddenField ID="hiddeneDate" runat="server" />
                <asp:HiddenField ID="hiddencMoney" runat="server" />
                <asp:HiddenField ID="hiddentradeno" runat="server" />
                <asp:HiddenField ID="hiddenLabCardtype" runat="server" />
                <asp:HiddenField ID="hiddenWallet2" runat="server" />
                
                <asp:HiddenField ID="hidCustName" runat="server" />
                <asp:HiddenField ID="hidPaperNo" runat="server" />
                <asp:HiddenField ID="hidPaperType" runat="server" />
                <asp:HiddenField ID="hidIsJiMing" runat="server" />

 
                <asp:HiddenField ID="hidAdjustMoney" runat="server" />
                <asp:HiddenField ID="hidWarning" runat="server" />
                
                <asp:HiddenField ID="hidSupplyMoney" runat="server" />
                
                <asp:HiddenField runat="server" ID="hidCardReaderToken" /> 
                
                <asp:LinkButton runat="server" ID="btnConfirm" OnClick="btnConfirm_Click"/>
                <asp:HiddenField runat="server" ID="hidCardnoForCheck" />
               
               </td>
            </tr>
           </table>
         </div>
         <div class="card">利金卡调帐</div>
         <div class="kuang5">
           <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
             <tr>
               <td width="12%"> <div align="right">利金卡卡号:</div></td>
               <td width="20%">
                <asp:TextBox ID="txtCashGiftCardno" CssClass="input" maxlength="16" runat="server"></asp:TextBox>
               </td>
               <td>&nbsp;</td>
               <td>&nbsp;</td>
               <td width="24%">
               <asp:Button ID="Button1" CssClass="button1" runat="server" Text="查询" OnClick="btnQuery_Click" />
              </tr>
           </table>
         </div>

         <div class="card">调帐总帐</div>
         <div class="kuang5">
           <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
             <tr>
               <td width="12%"><div align="right">调帐总额:</div></td>
               <td width="88%">
                 <asp:TextBox ID="txtAdjustMoney" CssClass="labeltext" maxlength="16" runat="server"></asp:TextBox>
               </td>
              </tr>
           </table>
         </div>
          <div class="jieguo">调帐明细</div>
          <div class="kuang5">
            <div id="gdtb" style="height:250px">
            
            
               <asp:GridView ID="gvResult" runat="server"
                    CssClass="tab1"
                    Width ="100%"
                    HeaderStyle-CssClass="tabbt"
                    AlternatingRowStyle-CssClass="tabjg"
                    SelectedRowStyle-CssClass="tabsel"
                    AllowPaging="True"
                    PageSize="100"
                    PagerSettings-Mode="NumericFirstLast"
                    PagerStyle-HorizontalAlign="Left"
                    PagerStyle-VerticalAlign="Top"
                    AutoGenerateColumns="true"
                    OnPageIndexChanging="gvResult_Page"
                    OnRowDataBound="gvResult_RowDataBound"
                    EmptyDataText="没有数据记录!"                  
                    />
            </div>
          </div>


        </div>
        <div class="btns">
          <table width="300" border="0" align="right" cellpadding="0" cellspacing="0">
            <tr>
              <td>
              <asp:Button ID="btnPrintPZ" runat="server" Text="打印凭证"
                CssClass="button1" Enabled="false"  OnClientClick="printdiv('ptnPingZheng1')" /></td>
              <td><asp:Button ID="btnAdjustAcc" runat="server" Text="调账" CssClass="button1" 
              OnClick="btnAdjustAcc_Click" /></td>
              <td><asp:Button ID="btnAdjustSale" runat="server" Text="调账售卡" CssClass="button1" Enabled="false"
               OnClientClick="return readCashCard()" OnClick="btnAdjustSale_Click" /></td>
            </tr>
          </table>
          <td><asp:CheckBox ID="chkPingzheng" runat="server" Checked="true" />自动打印凭证</td>
        </div>
        
         </ContentTemplate>
       </asp:UpdatePanel>
    </form>
</body>
</html>


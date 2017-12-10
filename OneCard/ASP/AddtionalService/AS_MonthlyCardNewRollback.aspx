<%@ Page Language="C#" AutoEventWireup="true" CodeFile="AS_MonthlyCardNewRollback.aspx.cs" Inherits="ASP_AddtionalService_AS_MonthlyCardNewRollback" %>
<%@ Register Src="../../CardReader.ascx" TagName="CardReader" TagPrefix="cr" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
    <title>月售/补返销</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
       <script type="text/javascript" src="../../js/print.js"></script>
  <link href="../../css/card.css" rel="stylesheet" type="text/css" />

</head>
<body>
	<cr:CardReader id="cardReader" Runat="server"/>    

    <form id="form1" runat="server">
        <div class="tb">
            附加业务->售卡/补卡返销

        </div>
        <ajaxToolkit:ToolkitScriptManager EnableScriptGlobalization="true" EnableScriptLocalization="true" ID="ScriptManager1" runat="server"/>
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
        <asp:UpdatePanel ID="UpdatePanel1" runat="server" >
            <ContentTemplate>
            
    <aspControls:PrintPingZheng ID="ptnPingZheng" runat="server" PrintArea="ptnPingZheng1" />
            
    <asp:BulletedList ID="bulMsgShow" runat="server">
    </asp:BulletedList>
    <script runat="server" >public override void ErrorMsgShow(){ErrorMsgHelper(bulMsgShow);}</script>          

  <div class="con">
  <div class="card">交易信息</div>
  <div class="kuang5">
 <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text20">
  <tr>
    <td width="10%"><div align="right">用户卡号:</div></td>
    <td width="13%"><asp:TextBox ID="txtCardNo" CssClass="labeltext" runat="server" /></td>
    <td width="9%"><div align="right">交易类型:</div></td>
    <td width="13%"><asp:Label ID="labTradeType" CssClass="labeltext" runat="server" /></td>
    <td width="9%"><div align="right">交易时间:</div></td>
    <td width="17%"><asp:Label ID="labTradeTime" CssClass="labeltext" runat="server" /></td>
    <td width="1%">&nbsp;</td>
    <td width="24%"><asp:Button ID="btnReadCard" Text="读卡" CssClass="button1" runat="server" 
        OnClientClick="return ReadParkCardInfo()" OnClick="btnReadCard_Click"/></td>

  <asp:HiddenField runat="server" ID="hidWarning" />
  <asp:HiddenField runat="server" ID="hidTradeNo" />
   <asp:HiddenField runat="server" ID="hidAsn" />
   <asp:HiddenField runat="server" ID="hidSeqNo" />
   <asp:HiddenField runat="server" ID="txtCardBalance" />
  <asp:HiddenField runat="server" ID="hidCardReaderToken" /> 
<asp:HiddenField runat="server" ID="hidAccRecv" />
   
  <asp:LinkButton runat="server" ID="btnConfirm" OnClick="btnConfirm_Click"/></tr>
  <tr>
    <td align="right">用户姓名:</td>
    <td><asp:Label ID="txtCustName"  runat="server" /></td>
    <td align="right">证件类型:</td>
    <td><asp:Label ID="selPaperType"  runat="server"/></td>
    <td align="right">证件号码:</td>
    <td><asp:Label ID="txtPaperNo" runat="server" /></td>
  </tr>
  <tr>
    <td><div align="right">应退费用:</div></td>
    <td colspan="7"><asp:Label ID="labFee" CssClass="labeltext" runat="server" /></td>
  </tr>
</table>

 </div>
 </div>

 <div class="footall"></div>
<div class="btns">
     <table width="200" align="right" border="0"cellpadding="0" cellspacing="0">
  <tr>
    <td><asp:Button ID="btnPrintPZ" runat="server" Text="打印凭证" 
        CssClass="button1" Enabled="false" OnClientClick="printdiv('ptnPingZheng1')" /></td>
    <td ><asp:Button ID="btnSubmit" Enabled="false" CssClass="button1" runat="server" Text="提交" 
        OnClick="btnSubmit_Click"/></td>
  </tr>
</table>
<asp:CheckBox ID="chkPingzheng" runat="server"  Text="自动打印凭证"  Checked="true"/>

</div> 
    
                </ContentTemplate>
        </asp:UpdatePanel>
    </form>
</body>
</html>


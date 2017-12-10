<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PB_CardStart.aspx.cs" Inherits="ASP_PersonalBusiness_PB_CardStart" %>
<%@ Register Src="../../CardReader.ascx" TagName="CardReader" TagPrefix="cr" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
<title>卡片启用</title>
        <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
         <script type="text/javascript" src="../../js/print.js"></script>
         <link href="../../css/card.css" rel="stylesheet" type="text/css" />
         <script type="text/javascript">
             function cs_submmit() {
                 $get('hidWarning').value = 'submit';
                 $get('btnConfirm').click();
                 return false;
             }
         
         </script>
</head>
<body>
	<cr:CardReader id="cardReader" Runat="server"/>    

    <form id="form1" runat="server">
<div class="tb">
个人业务->卡片启用
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
            <aspControls:PrintPingZheng ID="ptnPingZheng" runat="server" PrintArea="ptnPingZheng1" />
<asp:BulletedList ID="bulMsgShow" runat="server">
</asp:BulletedList>
<script runat="server" >public override void ErrorMsgShow(){ErrorMsgHelper(bulMsgShow);}</script>  
  
  <asp:HiddenField runat="server" ID="hidWarning" />
  <asp:LinkButton runat="server" ID="btnConfirm" OnClick="btnConfirm_Click"/>
  <asp:HiddenField ID="hidAccRecv" runat=server />
  <div class="con">
  <div class="lock">卡片信息</div>
  <div class="kuang5">
    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text20">
   <tr>
     <td width="11%"><div align="right">用户卡号:</div></td>
     <td width="13%"><asp:TextBox ID="txtCardno" CssClass="labeltext" runat="server"></asp:Textbox></td>
     <td width="9%"><div align="right">卡序列号:</div></td>
     <td width="13%"><asp:TextBox ID="LabAsn" CssClass="labeltext" runat="server"></asp:TextBox>
       <asp:HiddenField ID="hiddenAsn" runat="server" />
     </td>
     <td width="9%"><div align="right">卡片类型:</div></td>
     <td width="13%"><asp:TextBox ID="LabCardtype" CssClass="labeltext" runat="server"></asp:TextBox></td>
     <asp:HiddenField ID="hiddenCardtypecode" runat=server />
     <asp:HiddenField ID="hiddenread" runat=server />
     <td width="9%"><div align="right">卡片状态:</div></td>
     <td width="9%"><asp:TextBox ID="RESSTATE" CssClass="labeltext" runat="server"></asp:TextBox></td>
     <td width="12%"><asp:Button ID="btnReadCard" CssClass="button1" runat="server" Text="读卡" OnClientClick="return ReadCardInfo()" OnClick="btnReadCard_Click" /></td>
   </tr>
   <tr>
     <td><div align="right">启用日期:</div></td>
     <td><asp:TextBox ID="sDate" CssClass="labeltext" runat="server" Text=""></asp:TextBox>
     <asp:HiddenField ID="hiddensDate" runat="server" />
     </td>
     <td><div align="right" style="display: none">结束日期:</div></td>
     <td><asp:TextBox ID="eDate" CssClass="labeltext" Visible="False" runat="server" Text=""></asp:TextBox>
      <asp:HiddenField ID="hiddeneDate" runat=server />
     </td>
     <td><div align="right">卡内余额:</div></td>
     <td><asp:TextBox ID="accMoney" CssClass="labeltext" runat="server" Text=""></asp:TextBox>
     <asp:HiddenField ID="hiddencMoney" runat=server />
     </td>
     <td>&nbsp;</td>
     <td colspan="2">&nbsp;</td>
   </tr>
   <tr>
    <td><div align="right">开通功能:</div></td>
    <td colspan="8">
        <aspControls:OpenFunc ID ="openFunc" runat="server" />
    </td>
    </tr>
 </table>
  </div>
  <div class="pip">用户信息</div>
  <div class="kuang5">
 <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text20">
  <tr>
    <td width="11%"><div align="right">用户姓名:</div></td>
    <td width="13%"><asp:Label ID="CustName" runat="server" Text=""></asp:Label></td>
    <td width="9%"><div align="right">出生日期:</div></td>
    <td width="13%"><asp:Label ID="CustBirthday" runat="server" Text=""></asp:Label></td>
    <td width="9%"><div align="right">证件类型:</div></td>
    <td width="13%"><asp:Label ID="Papertype" runat="server" Text=""></asp:Label></td>
    <td width="9%"><div align="right">证件号码:</div></td>
    <td width="23%" colspan="3"><asp:Label ID="Paperno" runat="server" Text=""></asp:Label></td>
    </tr>
  <tr>
    <td><div align="right">用户性别:</div></td>
    <td><asp:Label ID="Custsex" runat="server" Text=""></asp:Label></td>
    <td><div align="right">联系电话:</div></td>
    <td><asp:Label ID="Custphone" runat="server" Text=""></asp:Label></td>
    <td><div align="right">邮政编码:</div></td>
    <td><asp:Label ID="Custpost" runat="server" Text=""></asp:Label></td>
    <td><div align="right">联系地址:</div></td>
    <td colspan="3"><asp:Label ID="Custaddr" runat="server" Text=""></asp:Label></td>
    </tr> 
  <tr>
    <td><div align="right">电子邮件:</td>
    <td><asp:Label ID="txtEmail" runat="server" Text=""></asp:Label></td> 
    <td valign="top"><div align="right">备注　　:</div></td>
    <td colspan="5"><asp:Label ID="Remark" runat="server" Text=""></asp:Label></td>
    </tr>
</table>

 </div>
</div>
 <div class="footall"></div>
<div class="btns">
     <table width="200" border="0" align="right" cellpadding="0" cellspacing="0">
  <tr>
    <td><asp:Button ID="btnPrintPZ" runat="server" Text="打印凭证" CssClass="button1" Enabled="false"  OnClientClick="printdiv('ptnPingZheng1')"/></td>
    <td><asp:Button ID="btnUnlock" CssClass="button1" Enabled=false runat="server" Text="启用" OnClientClick="return cs_submmit();"/></td>
    <asp:HiddenField ID="hiddenverify" runat=server />
    <asp:HiddenField ID="hiddenCheck" runat=server />
    <asp:HiddenField runat="server" ID="hidCardReaderToken" />
  </tr>
</table>
  <td><asp:CheckBox ID="chkPingzheng" runat="server" Checked="true" />自动打印凭证</td>
  <td><span class="red">请正确放置卡片，并确认该卡片为需要启用</span></td>
  </div>
              </ContentTemplate>          
        </asp:UpdatePanel>
    </form>
</body>
</html>

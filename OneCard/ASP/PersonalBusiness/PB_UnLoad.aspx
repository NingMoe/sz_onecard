<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PB_UnLoad.aspx.cs" Inherits="ASP_PersonalBusiness_PB_UnLoad" %>
<%@ Register Src="../../CardReader.ascx" TagName="CardReader" TagPrefix="cr" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
<title>圈提</title>
        <link rel="stylesheet" type="text/css" href="../../css/frame.css" />

         <link href="../../css/card.css" rel="stylesheet" type="text/css" />
</head>
<body>
	<cr:CardReader id="cardReader" Runat="server" />    

    <form id="form1" runat="server">
    <div class="tb">
个人业务->圈提
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
<div class="card">卡片信息</div>
  <div class="kuang5">
 <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text20">
  <tr>
    <td width="11%"><div align="right">用户卡号:</div></td>
    <td width="14%"><asp:TextBox ID="txtCardno" CssClass="labeltext" maxlength="16" runat="server"></asp:TextBox></td>
    <td width="11%"><div align="right">卡内余额:</div></td>
    <td width="14%"><asp:TextBox ID="cMoney" CssClass="labeltext" runat="server" Text=""></asp:TextBox></td>
    <td width="11%"><div align="right">卡片状态:</div></td>
    <td width="8%"><asp:TextBox ID="RESSTATE" CssClass="labeltext" ReadOnly=true runat="server"></asp:TextBox></td>
    <td width="11%">&nbsp;</td>
    <td width="10%"><asp:Button ID="btnReadCard" CssClass="button1" runat="server" Text="读卡" 
        OnClientClick="return ReadCardInfoEx()" OnClick="btnReadCard_Click" /></td>
    <td width="23%">&nbsp;</td>
  </tr>
  <asp:HiddenField ID="hiddenread" runat=server />
  <asp:HiddenField ID="hiddentxtCardno" runat=server />
  <asp:HiddenField ID="hiddenAsn" runat=server />
  <asp:HiddenField ID="hiddenLabCardtype" runat=server />
  <asp:HiddenField ID="hiddensDate" runat=server />
  <asp:HiddenField ID="hiddeneDate" runat=server />
  <asp:HiddenField ID="hiddencMoney" runat=server />
  <asp:HiddenField ID="hiddentradeno" runat=server />
  <asp:HiddenField ID="hiddenState" runat=server />
  <asp:HiddenField ID="hidWarning" runat=server />
  <asp:HiddenField ID="hidUnSupplyMoney" runat="server" />
  <asp:LinkButton runat="server" ID="btnConfirm" OnClick="btnConfirm_Click"/>
  <asp:HiddenField runat="server" ID="hidCardReaderToken" />
</table>

 </div>
  <div class="pip">用户信息</div>
  <div class="kuang5">
 <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text20">
  <tr>
    <td width="11%"><div align="right">用户姓名:</div></td>
    <td width="14%"><asp:Label ID="CustName" runat="server" Text=""></asp:Label></td>
    <td width="11%"><div align="right">出生日期:</div></td>
    <td width="14%"><asp:Label ID="CustBirthday" runat="server" Text=""></asp:Label></td>
    <td width="11%"><div align="right">证件类型:</div></td>
    <td width="8%"><asp:Label ID="Papertype" runat="server" Text=""></asp:Label></td>
    <td width="8%"><div align="right">证件号码:</div></td>
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
<div class="btns">
     <table width="200" border="0" align="right" cellpadding="0" cellspacing="0">
  <tr>
    <td><asp:Button ID="btnLoad" CssClass="button1" runat="server" Text="圈提" Enabled=false OnClick="btnLoad_Click" /></td>
  </tr>
</table>

</div>
</ContentTemplate>          
        </asp:UpdatePanel>
    </form>
</body>
</html>

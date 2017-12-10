<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PB_BadCard.aspx.cs" Inherits="ASP_PersonalBusiness_PB_BadCard" %>
<%@ Register Src="../../CardReader.ascx" TagName="CardReader" TagPrefix="cr" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
<title>坏卡登记</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />

    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
</head>
<body>
<cr:CardReader id="cardReader" Runat="server"/> 
    <form id="form1" runat="server">
    <div class="tb">
个人业务->坏卡登记
</div>
<ajaxToolkit:ToolkitScriptManager runat="Server" EnableScriptGlobalization="true"
            EnableScriptLocalization="true" ID="ScriptManager2" />
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
    <td width="11%"><div align="right">坏卡卡号:</div></td>
    <td width="14%"><asp:TextBox ID="txtCardno" CssClass="input" maxlength="16" runat="server"></asp:TextBox></td>
    <td width="11%"><div align="right">&nbsp;</div></td>
    <td width="14%">&nbsp;</td>
    <td width="11%"><div align="right">&nbsp;</div></td>
    <td width="8%">&nbsp;</td>
    <td width="10%">&nbsp;</td>
    <td width="11%"><asp:Button ID="btnReadCard" CssClass="button1" runat="server" Text="读卡" OnClientClick="return readCardNo()"/></td>
    <td width="23%"><div align="right"><asp:Button ID="btnBadCard" CssClass="button1" runat="server" Text="坏卡登记" OnClick="btnBadCard_Click" /></td>
  </tr>
</table>

 </div>

     </div>
     </ContentTemplate>          
        </asp:UpdatePanel>
    </form>
</body>
</html>

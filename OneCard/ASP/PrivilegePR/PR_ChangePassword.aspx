<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PR_ChangePassword.aspx.cs" Inherits="ASP_PrivilegePR_PR_ChangePassword" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <title>系统设置-修改密码</title>
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
    <ajaxToolkit:ToolkitScriptManager runat="Server" EnableScriptGlobalization="true"
    EnableScriptLocalization="true" ID="ScriptManager2" />
    <asp:UpdatePanel ID="UpdatePanel1" runat="server">
    <ContentTemplate>
    <div class="tb">系统设置-&gt;修改密码</div>
    <!-- #include file="../../ErrorMsg.inc" --> 
<div class="footall"></div>
<div class="con">
 <div class="pip">修改密码</div>
 <div class="kuang5">
   <table width="95%" border="0" cellpadding="0" cellspacing="0" class="12text">
     <tr>
       <td><div align="right">原密码:</div></td>
       <td><asp:TextBox ID="txtOPwd" CssClass="inputmid" TextMode="password" maxlength="20" runat="server"></asp:TextBox></td>
       <td><div align="right">新密码:</div></td>
       <td><asp:TextBox ID="txtNPwd" CssClass="inputmid" TextMode="password" maxlength="20" runat="server"></asp:TextBox></td>
       <td><div align="right">新密码确认:</div></td>
       <td><asp:TextBox ID="txtANPwd" CssClass="inputmid" TextMode="password" maxlength="20" runat="server"></asp:TextBox></td>
     </tr>
   </table>
 </div>
  </div>
<div class="btns">
  <table width="100" border="0" align="right" cellpadding="0" cellspacing="0">
    <tr>
      <td>
      <asp:Button ID="btnChangePassword" CssClass="button1" runat="server" Text="修改" OnClick="btnChangePassword_Click" />
      </td>
    </tr>
  </table>
  <label></label>
  <label></label>
</div>
</ContentTemplate>
</asp:UpdatePanel>
    </form>
</body>
</html>

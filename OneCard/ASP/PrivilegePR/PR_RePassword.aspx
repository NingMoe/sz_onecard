<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PR_RePassword.aspx.cs" Inherits="ASP_PrivilegePR_PR_RePassword" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <title>系统设置-密码重置</title>
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
    <ajaxToolkit:ToolkitScriptManager runat="Server" EnableScriptGlobalization="true"
    EnableScriptLocalization="true" ID="ScriptManager2" />
    <asp:UpdatePanel ID="UpdatePanel1" runat="server">
    <ContentTemplate>
    <div class="tb">系统设置-&gt;密码重置</div>
    <!-- #include file="../../ErrorMsg.inc" --> 
    <div class="footall"></div>
<div class="con">
 <div class="pip">密码重置</div>
 <div class="kuang5">
   <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
     <tr>
       <td width="12%"><div align="right">部门名称:</div></td>
       <td width="30%"><asp:DropDownList ID="selDEPARTNO" CssClass="inputmid" runat="server" AutoPostBack="true" OnSelectedIndexChanged="selDEPARTNO_SelectedIndexChanged"> </asp:DropDownList>
       </td>
       <td width="9%"><div align="right">员工姓名:</div></td>
       <td width="20%"><asp:DropDownList ID="selSTAFFNO" CssClass="inputmid" runat="server" ></asp:DropDownList>
        
       </td>
       <td width="9%">&nbsp;</td>
       <td width="27%">&nbsp;</td>
     </tr>
   </table>
 </div>
  </div>
<div class="btns">
  <table width="100" border="0" align="right" cellpadding="0" cellspacing="0">
    <tr>
      <td> <asp:Button ID="btnRePassword" CssClass="button1" runat="server" Text="重置" OnClick="btnRePassword_Click" />
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

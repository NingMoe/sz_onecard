<%@ Page Language="C#" AutoEventWireup="true" CodeFile="IT_VoidRollback.aspx.cs" Inherits="ASP_InvoiceTrade_IT_VoidRollback" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
	<link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <title>发票作废返销</title>
</head>
<body>
    <form id="form1" runat="server">
    
        <div class="tb">发票 ->作废返销</div>

        <ajaxToolkit:ToolkitScriptManager runat="Server" EnableScriptGlobalization="true"
            EnableScriptLocalization="true" ID="ScriptManager2" />
        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
            <ContentTemplate>
            <!-- #include file="../../ErrorMsg.inc" --> 
           
            <div class="con">
                <div class="pip">发票作废返销</div>
                <div class="kuang5">
                   <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                     <tr>
                       <td width="12%"><div align="right">发票号:</div></td>
                       <td width="20%">
                            <asp:TextBox ID="txtNo" CssClass="input" runat="server" MaxLength="8"></asp:TextBox>
                       </td>
                       <td width="12%"><div align="right">发票卷号:</div></td>
                       <td width="20%">
                            <asp:TextBox ID="txtVolumeno" CssClass="input" runat="server" MaxLength="12"></asp:TextBox>
                       </td>
                       <td width="26%">
                            <asp:Button ID="InvoiceVoidRollback" CssClass="button1" runat="server" Text="作废返销" OnClick="InvoiceVoidRollback_Click"/>
                       </td>
                      </tr>
                   </table>
                </div>
            </div> 
            </ContentTemplate>
        </asp:UpdatePanel>
    </form>
</body>
</html>

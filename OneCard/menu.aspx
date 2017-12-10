<%@ Page Language="C#" AutoEventWireup="true" CodeFile="menu.aspx.cs" Inherits="menu" %>
<%@ Register Src="CardReaderImpl.ascx" TagName="CardReader" TagPrefix="cri" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
	<LINK REL="stylesheet" TYPE="text/css" HREF="js/ext/resources/css/ext-all.css" />
	<LINK REL="stylesheet" TYPE="text/css" HREF="js/ThemeXP/theme.css"/>
	<LINK REL="stylesheet" TYPE="text/css" HREF="css/frame.css" />
	
    <script language="javascript">
        function Logout()
        {
                if (confirm("您真的要退出吗？"))
                {
                        return true;
                }
                else
                {
                        return false;
                }
        }
    </script>
    
    <style type="text/css">
    <!--
        .gdtb {
	        overflow: auto;
	        width: 100%;
	        height: 100%;
        }
    -->
    </style>
    
</head>
<body>
<cri:CardReader id="cardReader" Runat="server"/>   

<div id="menu"></div>

<form id="form1" runat="server">
      <ajaxToolkit:ToolkitScriptManager runat="Server" EnableScriptGlobalization="true"
            EnableScriptLocalization="true" ID="ScriptManager2" />
       <asp:UpdatePanel ID="UpdatePanel1" runat="server">
         <ContentTemplate>
         <asp:HiddenField runat="server" ID="hidWarning" />
                <asp:HiddenField runat="server" ID="hidMenuStream" />
               <asp:HiddenField ID="hidCardReaderToken" runat="server" />
               <asp:LinkButton runat="server" ID="btnConfirm" OnClick="btnConfirm_Click"/>

               </ContentTemplate>
      </asp:UpdatePanel>
      </form>
      
     <SCRIPT LANGUAGE="JavaScript" SRC="js/ext/ext-base.js"> </SCRIPT>
    <SCRIPT LANGUAGE="JavaScript" SRC="js/ext/ext-all.js"></SCRIPT>
    <SCRIPT LANGUAGE="JavaScript" SRC="js/ext/JSCookTree.js"></SCRIPT>
    <SCRIPT LANGUAGE="JavaScript" SRC="js/ThemeXP/theme.js"></SCRIPT>
    <SCRIPT LANGUAGE="JavaScript" SRC="js/frame.js"></SCRIPT>
    
      <SCRIPT FOR=window EVENT=onload  LANGUAGE="JavaScript">
        new   Function(document.getElementById('hidMenuStream').value)();    
    </SCRIPT>
    
    
    
</body>
</html>


    
    
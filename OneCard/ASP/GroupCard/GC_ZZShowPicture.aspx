<%@ Page Language="C#" AutoEventWireup="true" CodeFile="GC_ZZShowPicture.aspx.cs" Inherits="ASP_GroupCard_GC_ZZShowPicture" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>查看照片</title>

    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    
    <script type="text/javascript" src="../../js/printorder.js"></script>
    <script type="text/javascript" src="../../js/myext.js"></script>
    
     <script src="../../js/jquery-1.5.min.js" type="text/javascript"></script>
 
    
    <style type="text/css">
        html, body
        {
            overflow: auto;
            height: auto;
            background: #ffffff;
        }
    </style>
    <script type="text/javascript">
        function closeDiv() {
            parent.Research();
            parent.CloseWindow('RoleWindow');
            return false;
        }
        $(document).ready(function () {
            var height = $("body").outerHeight();
            height = parseInt(height) +5;
            var object = parent.document.getElementById("RoleWindow");
            $(object).css("height", height);
        });
    </script>
    
    <style type="text/css">

        table.data {font-size: 90%; border-collapse: collapse; border: 0px solid black;}
        table.data th {background: #bddeff; width: 25em; text-align: left; padding-right: 8px; font-weight: normal; border: 1px solid black;}
        table.data td {background: #ffffff; vertical-align:middle;padding: 0px 2px 0px 2px; border: 1px solid black;}

    </style>
    
</head>
<body>
    <form id="form1" runat="server">
        <ajaxToolkit:ToolkitScriptManager EnableScriptGlobalization="true" EnableScriptLocalization="true" ID="ScriptManager1" runat="server"/>
        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
           <ContentTemplate>
                <div class="con">
                        <table>
                                <tr>
                                    <td><img src="../../Images/cardface.jpg" alt="照片"  id="Img" runat="server" height="200" style="cursor:hand" /></td>
                                </tr>
                                <tr>
                                <td align="right"><asp:Button ID="btnClose" CssClass="button1" runat="server" Text="关闭" OnClientClick="parent.CloseWindow('RoleWindow'); return false;" /></td>
                                </tr>
                         </table>
                </div>
                
           </ContentTemplate>         
        </asp:UpdatePanel>

    </form>
</body>
</html>

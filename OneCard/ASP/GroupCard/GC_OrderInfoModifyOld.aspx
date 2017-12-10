<%@ Page Language="C#" AutoEventWireup="true" CodeFile="GC_OrderInfoModifyOld.aspx.cs" EnableEventValidation="false" Inherits="ASP_GroupCard_SZ_OrderInfoModifyOld" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
    <title>资料修改</title>

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
            height = parseInt(height) + 20;
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
        <div class="tb">
            资料修改
        </div>
        <ajaxToolkit:ToolkitScriptManager EnableScriptGlobalization="true" EnableScriptLocalization="true" ID="ScriptManager1" runat="server"/>
        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
           <ContentTemplate>
                <div class="con">
                  <div class="jieguo">详细信息</div>
                    <div class="kuang5">
                        <table>
                                <tr>
                                    <td>联系人:</td>
                                    <td>
                                        <asp:TextBox ID="txtContactName" CssClass="inputmid" runat="server"></asp:TextBox></td>
                                    <td>身份证号:</td>
                                    <td>
                                        <asp:TextBox ID="txtIdNo" CssClass="inputmid" runat="server"></asp:TextBox></td>
                                    <td>联系电话:</td>
                                    <td>
                                        <asp:TextBox ID="txtPhone" CssClass="inputmid" runat="server"></asp:TextBox></td>
                                    <td><asp:Button ID="btnUpdate" runat="server" CssClass="button1" Text="修改" OnClick="btnUpdate_Click" /></td>
                                    <td align="right"><asp:Button ID="btnClose" CssClass="button1" runat="server" Text="关闭" OnClientClick="parent.CloseWindow('RoleWindow'); return false;" /></td>
                                </tr>
                         </table>
                    </div>
                </div>
                
           </ContentTemplate>         
        </asp:UpdatePanel>

    </form>
</body>
</html>

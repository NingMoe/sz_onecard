<%@ Page Language="C#" AutoEventWireup="true" CodeFile="LogonAdmin.aspx.cs" Inherits="LogonAdmin" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
    <title>苏州通业务运营支撑系统2.0</title>
    <link href="css/login1.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
    <div id="logo"></div>
    <div id="login">
        <div id="kuang">
            <div class="fgx">用户登录【管理版】</div>
            <table width="230" border="0" align="center" cellpadding="0" cellspacing="0">
                <tr>
                    <td width="67">用户名:</td>
                    <td style="width: 163px">
                        <asp:TextBox CssClass = "input" ID = "UserName" MaxLength = "6" runat ="server"></asp:TextBox>
                    </td>
                </tr>
                <tr>
                    <td>密　码:</td>
                    <td style="width: 163px">
                        <asp:TextBox CssClass = "input" ID = "UserPass" MaxLength = "20" runat ="server" TextMode=Password ></asp:TextBox>
                    </td>
                </tr>
                <tr>
                    <td>IP:</td>
                    <td style="width: 163px">
                        <asp:TextBox CssClass = "input" ID = "txtIP"   MaxLength = "200" runat ="server"></asp:TextBox>
                    </td>
                </tr>
                <tr visible =false>
                    <td style="width: 163px" visible =false>
                        <asp:TextBox CssClass = "input" ID = "txtOperCardno"  MaxLength = "20"  visible =false runat ="server"></asp:TextBox>
                    </td>
                </tr>
                <tr>
                    <td>&nbsp;</td>
                    <td style="width: 163px">                    
                        <asp:Button ID="LogonBtn" Text="登 录" runat="server"  CssClass="btn" OnClick="LogonBtn_Click" />
                    </td>
                </tr>
            </table>
            <!--控制此div的display属性设置可见不可见-->
            <div class="red" id="ErrorMsg">
                &nbsp;<asp:Label ID="Msg" runat="server" Height="18px"></asp:Label></div>
        </div>
    </div>
    <div id="jz"></div>
    </form>
</body>
</html>

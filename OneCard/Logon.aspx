<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Logon.aspx.cs" Inherits="Logon" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <title>苏州通业务运营支撑系统2.0</title>
    <link href="css/login1.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <script type="text/javascript" src="js/cardreader.js"></script>

    <form id="form1" runat="server">
    <div id="logo"></div>
    <div id="login">
        <div id="kuang">
            <div class="fgx">用户登录</div>
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
                    <td>卡　号:</td>
                    <td style="width: 163px">
                        <asp:TextBox CssClass = "input" ID = "txtOperCardno"  MaxLength = "20" runat ="server"></asp:TextBox>
                    </td>
                </tr>
                <tr>
                    <td>IP:</td>
                    <td style="width: 163px">
                        <asp:TextBox CssClass = "input" ID = "txtIP"   MaxLength = "200" runat ="server"></asp:TextBox>
                    </td>
                </tr>
                <tr>
                    <td>&nbsp;</td>
                    <td style="width: 163px">                    
                        <asp:Button ID="LogonBtn" Text="登 录" runat="server"  CssClass="btn" 
                            OnClientClick="return readLogonCardNo('txtOperCardno')" OnClick="LogonBtn_Click" />
                     <%--<asp:Button ID="btnPrintTest" Text="测试打印" runat="server"  CssClass="btn" 
                            OnClientClick="printTest()"/> --%></td>
          </tr>
            </table>
                                  
            <!--控制此div的display属性设置可见不可见-->
            <div class="red" id="ErrorMsg">
                &nbsp;<asp:Label ID="Msg" runat="server" Height="18px"></asp:Label></div>
        </div>
    </div>
    <div id="jz"></div>
    </form>
<%--    
    <div id="PrintArea" style="display:none">
<div class="juedui" style="left:240px;top:25px;" >2008</div>
<div class="juedui" style="left:285px; top:25px;" >09</div>
<div class="juedui" style="left:315px; top:25px;" >01</div>

<div class="juedui" style="left:605px;top:20px;" >2008</div>
<div class="juedui" style="left:655px;top:20px;" >09</div>
<div class="juedui" style="left:680px;top:20px;" >01</div>

<div class="juedui" style="left:140px; top:55px;" >1234567890123456</div>
<div class="juedui" style="left:140px; top:76px;" >测试打印</div>
<div class="juedui" style="left:165px; top:97px;" >测试</div>
<div class="juedui" style="left:165px; top:119px;" >0</div>
<div class="juedui" style="left:165px; top:140px;" >1</div>

<div class="juedui" style="left:280px; top:55px;" >111</div>
<div class="juedui" style="left:280px; top:76px;" >2222</div>
<div class="juedui" style="left:280px; top:97px;" >3333</div>
<div class="juedui" style="left:280px; top:119px;" >44</div>
<div class="juedui" style="left:324px; top:140px;" >55</div>
<div class="juedui" style="left:324px; top:190px;" >零</div>
<div class="juedui" style="left:200px; top:255px;" >联创测试</div>


<div class="juedui" style="left:440px; top:55px;" >测试</div>
<div class="juedui" style="left:440px; top:76px;" >测试</div>
<div class="juedui" style="left:420px; top:97px;" >测试</div>
<div class="juedui" style="left:440px; top:119px;" >测试</div>
<div class="juedui" style="left:370px; top:140px;" >测试</div>
<div class="juedui" style="left:440px; top:140px;" >测试</div>

<div class="juedui" style="left:652px; top:45px;" >测试</div>
<div class="juedui" style="left:652px; top:67px;" >测试</div>
<div class="juedui" style="left:652px; top:88px;" >测试</div>
<div class="juedui" style="left:652px; top:110px;" >测试</div>
<div class="juedui" style="left:652px; top:131px;" >测试</div>
<div class="juedui" style="left:652px; top:153px;" >测试</div>
<div class="juedui" style="left:652px; top:175px;" >测试</div>
<div class="juedui" style="left:652px; top:196px;" >测试</div>
<div class="juedui" style="left:690px; top:218px;" >测试</div>
<div class="juedui" style="left:690px; top:239px;" >测试</div>
</div>
--%> 
</body>
</html>

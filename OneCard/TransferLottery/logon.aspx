<%@ Page Language="C#" AutoEventWireup="true" CodeFile="logon.aspx.cs" Inherits="TransferLottery_logon" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>苏州市公共交通换乘抽奖系统--登录</title>
    <meta name="keywords" content="" />
    <meta name="description" content="" />
    <link href="base.css" rel="stylesheet" />
    <link rel="stylesheet" type="text/css" href="prize.css">
    <style type="text/css">
        <!--
        .STYLE1
        {
            font-size: 14px;
            color: #333;
        }
        -->
    </style>
    <script type="text/javascript">
        function keyLogin() {
            if (event.keyCode == 13)   
                document.getElementById("btnLogin").click();   
        }
    </script>
</head>
<body style="background-color: #f5f5f5;" onkeydown="keyLogin();">
    <form id="form1" runat="server">
        <div class="head1" style="background-color: #fff; border-bottom: 2px solid #008dd4;">
            <h1 class="logo">
                <a href="" title="苏州市社会保障·市民卡官方网站">苏州市社会保障·市民卡官方网站</a>
            </h1>
        </div>

        <div class="prize-login">

            <div class="bd">
                <table width="85%" border="0" height="176">
                    <tr>
                        <td rowspan="4" width="50%">&nbsp; </td>
                    </tr>
                    <tr>
                        <td width="20%" height="34">
                            <div align="right"><span class="STYLE1">用户名</span></div>
                        </td>
                        <td width="30%">
                            <div align="right">
                                <asp:TextBox CssClass="input" ID="UserName" MaxLength="6" runat="server"></asp:TextBox>
                            </div>
                        </td>
                    </tr>
                    <tr>
                        <td height="32">
                            <div align="right"><span class="STYLE1">密 &nbsp;&nbsp;&nbsp;码</span></div>
                        </td>
                        <td>
                            <div align="right">
                                <asp:TextBox CssClass="input" ID="UserPass" MaxLength="20" runat="server" TextMode="Password"></asp:TextBox>
                            </div>
                        </td>
                    </tr>
                    <tr>
                        <td height="52" colspan="2">
                            <div align="right">
                                <asp:Label ID="Msg" runat="server" Height="18px"></asp:Label>
                                <input  id="btnLogin" onclick="__doPostBack('LogonBtn', '');" type="button" class="bbt" onMouseOver="this.style.backgroundPosition='left -32px'" onMouseOut="this.style.backgroundPosition='left top'" />	           			    
                                <asp:LinkButton ID="LogonBtn" runat="server" CssClass="hide" OnClick="LogonBtn_Click"></asp:LinkButton>
                            </div>
                        </td>
                    </tr>
                </table>
            </div>
        </div>

        <div class="wrap footer">
            <p>主办单位： 苏州市交通局&nbsp;&nbsp;&nbsp;&nbsp;</p>
        </div>
    </form>
</body>
</html>


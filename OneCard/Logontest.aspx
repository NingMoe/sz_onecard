<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Logontest.aspx.cs" Inherits="Logontest" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
    <title>苏州通业务运营支撑系统2.0</title>
    <link href="css/login1.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="js/myext.js"></script>
    <script type="text/javascript" src="js/mootools.js"></script>
    <script type="text/javascript" src="js/jquery-1.5.min.js"></script>
</head>
<body>
    <script type="text/javascript" src="js/cardreader.js">

       
    </script>
       
  <script type="text/javascript" >
    
      function showWarning() {
          MyExtConfirm2('提示', '用户旧密码格式不符合新规则(密码设置至少包含字母、数据、符号三种中的两种)，请及时修改! 例如：szcic12!!', submitStockInConfirmCallback);

      }
      function submitStockInConfirmCallback(btn) {

          document.getElementById('btnRedirect').click();
          }
      
  </script>

    <form id="form1" runat="server">
    <div id="logo"></div>
    <ajaxToolkit:ToolkitScriptManager EnableScriptGlobalization="true" EnableScriptLocalization="true"
        ID="ToolkitScriptManager1" runat="server" />
         <asp:UpdatePanel ID="UpdatePanel1" UpdateMode="Conditional" runat="server">
        <ContentTemplate>
    <div id="login">
        <div id="kuang">
            <div class="fgx">用户登录</div>
            <table width="230" border="0" align="center" cellpadding="0" cellspacing="0">
                <tr>
                    <td width="67">用户名:</td>
                    <td style="width: 163px">
                        <asp:TextBox CssClass = "input" ID = "UserName" MaxLength = "6" runat ="server"  Text="090001" ></asp:TextBox>
                    </td>
                </tr>
                <tr>
                    <td>密　码:</td>
                    <td style="width: 163px">
                        <asp:TextBox CssClass = "input" ID = "UserPass" MaxLength = "20" runat ="server" Text="szcic1234"  ></asp:TextBox>
                    </td>
                </tr>
                <tr>
                    <td>卡　号:</td>
                    <td style="width: 163px">
                        <asp:TextBox CssClass = "input" ID = "txtOperCardno" MaxLength = "16" runat ="server" Text="2150080322000201"  ></asp:TextBox>
                    </td>
                </tr>
                 <tr>
                    <td>城  市:</td>
                    <td style="width: 163px">
                        <asp:DropDownList CssClass="input" ID="selCity" runat="server">
                        <asp:ListItem Value="" Text="---请选择---" />
                        <asp:ListItem Value="suzhou" Text="苏州" />
                        <asp:ListItem Value="changzhou" Text="常州" />
                        <asp:ListItem Value="erdos" Text="鄂尔多斯" />
                        </asp:DropDownList>
                    </td>
                </tr>               <tr>
                    <td>&nbsp;</td>
                    <td style="width: 163px">                    
                        <asp:Button ID="LogonBtn" Text="登 录" runat="server"  CssClass="btn" 
                             OnClick="LogonBtn_Click"/>
                            <div style="display: none">
                            <asp:Button ID ="btnWarnin" runat="server"   OnClick="btnWarning_Click" />
                            <asp:Button ID ="btnRedirect" runat="server"   OnClick="btnRedirect_Click" />
                            </div>
                            
                    </td>
                </tr>
            </table>
            <!--控制此div的display属性设置可见不可见-->
            <div class="red" id="ErrorMsg">
                &nbsp;<asp:Label ID="Msg" runat="server" Height="18px"></asp:Label></div>
        </div>
    </div>
    <div id="jz"></div>
    </ContentTemplate>
    </asp:UpdatePanel>
    </form>
</body>
</html>

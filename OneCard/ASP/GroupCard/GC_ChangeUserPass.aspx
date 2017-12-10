<%@ Page Language="C#" AutoEventWireup="true" CodeFile="GC_ChangeUserPass.aspx.cs" Inherits="ASP_GroupCard_GC_ChangeUserPass" %>
<%@ Register Src="../../CardReader.ascx" TagName="CardReader" TagPrefix="cr" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
<title>修改用户密码</title>
        <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
        
         <link href="../../css/card.css" rel="stylesheet" type="text/css" />
         
  <script language="javascript">
  <!--
  function OpenPort()
  {     
        if(!MSComm1.PortOpen)
        {
            var  WshShell;
            var  keyValue;
        
            try{
                WshShell  =  new  ActiveXObject("WScript.Shell");
            }catch(ex)
            {
                alert("请调整IE的ActiveX安全级别");
                return false;
            }
            
            try
            {
                  
                 keyValue  =  WshShell.RegRead("HKEY_LOCAL_MACHINE\\SOFTWARE\\OneCard\\ComPort");

                if(keyValue == '' || keyValue.charCodeAt(0) < 49 || keyValue.charCodeAt(0) > 57)
                {
                    alert("请在【系统管理->本地参数管理】页面里，配置ComPort端口！"); 
                    return false;
                }
                
            }
            catch(ex)
            {
                alert("请在【系统管理->本地参数管理】页面里，配置ComPort端口！"); 
                return false;
            }
        
        
            try{
                MSComm1.CommPort = keyValue;
                MSComm1.PortOpen = true;
            }catch(ex)
            {
                alert("小键盘端口无法打开，请在【系统管理->本地参数管理】页面里，配置ComPort端口！");
                return false;
            }
            return true;
        }else{
            $get("hidPwdNum").value = '0';
            $get("txtOPwd").focus();
            return true;
        }
  }
  
  function ClosePort()
  {     
        if(MSComm1.PortOpen)
        {
            MSComm1.PortOpen = false;
        }
  }
  
  -->
  </script>
  
  <script ID="clientEventHandlersJS" language="javascript">   
  <!--
  function MSComm1_OnComm(){
        var fldWeight;
        var strInput;
        
        if($get("hidPwdNum").value == '0')
        {
            fldWeight = $get("txtOPwd");
        }else if($get("hidPwdNum").value == '1')
        {
            fldWeight = $get("txtNPwd");
        }else if($get("hidPwdNum").value == '2')
        {
            fldWeight = $get("txtANPwd");
        }
        
        strInput = MSComm1.Input;
        if(strInput.charCodeAt(0) == 13)
        {
            if($get("hidPwdNum").value == '0')
            {
//                alert("旧密码输入完毕，请输入新密码");
                $get("hidPwdNum").value = '1';
                fldWeight = $get("txtNPwd");
            }else if($get("hidPwdNum").value == '1')
            {
//                alert("请再输一遍新密码");
                $get("hidPwdNum").value = '2';
                fldWeight = $get("txtANPwd");
            }else if($get("hidPwdNum").value == '2')
            {
//                alert("全部密码输入完毕");
                fldWeight = $get("btnChangeUserPass");
                ClosePort();
            }
            
        }else if(strInput.charCodeAt(0) == 8)
        {
            fldWeight.value = "";
        }else{
            fldWeight.value = fldWeight.value + strInput; 
        }
        fldWeight.focus();
        return true;
  }
  -->
  </script>
 <script language="javascript" FOR="MSComm1" EVENT="OnComm">
  MSComm1_OnComm();
 </script>
         
</head>
<body>
  <object classid="clsid:648A5600-2C6E-101B-82B6-000000000014" id="MSComm1" 
   codebase="MSCOMM32.OCX" type="application/x-oleobject"   width='0' height='0'>  
  <PARAM NAME="InputLen" VALUE="0">
  <param name="Rthreshold" value="1">
  <PARAM   NAME="Settings"   VALUE="1200,N,8,1">
  </object>  
  <cr:CardReader id="cardReader" Runat="server"/>    

    <form id="form1" runat="server">
<div class="tb">
企服卡->修改用户密码
</div>
          <ajaxToolkit:ToolkitScriptManager runat="Server" EnableScriptGlobalization="true"
            EnableScriptLocalization="true" ID="ScriptManager2" />
        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
            <ContentTemplate>
            <asp:HiddenField ID="hidPwdNum" Value="0" runat=server />
<asp:BulletedList ID="bulMsgShow" runat="server">
</asp:BulletedList>
<script runat="server" >public override void ErrorMsgShow(){ErrorMsgHelper(bulMsgShow);}</script>  
<div class="con">
<div class="card">卡片信息</div>
  <div class="kuang5">
 <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text20">
  <tr>
    <td width="9%"><div align="right">用户卡号:</div></td>
    <td width="14%"><asp:TextBox ID="txtCardno" CssClass="labeltext" runat="server"></asp:Textbox></td>
    <asp:HiddenField ID="hiddenread" runat=server />
    <td width="10%"><asp:Button ID="btnChangeUserPassCardread" CssClass="button1" runat="server" 
        Text="读卡" OnClientClick="return readCardNo();" OnClick="btnChangeUserPassCardread_Click" /></td>
    <td width="11%">&nbsp;</td>
    <td width="18%">&nbsp;</td>
    <td width="12%">&nbsp;</td>
    <td width="11%">&nbsp;</td>
  </tr>
</table>

 </div>
  <div class="pip">用户信息</div>
  <div class="kuang5">
 <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text20">
  <tr>
    <td width="11%"><div align="right">用户姓名:</div></td>
    <td width="14%"><asp:Label ID="CustName" runat="server" ></asp:Label></td>
    <td width="11%"><div align="right">出生日期:</div></td>
    <td width="14%"><asp:Label ID="CustBirthday" runat="server" Text=""></asp:Label></td>
    <td width="11%"><div align="right">证件类型:</div></td>
    <td width="8%"><asp:Label ID="Papertype" runat="server" Text=""></asp:Label></td>
    <td width="8%"><div align="right">证件号码:</div></td>
    <td width="23%" colspan="3"><asp:Label ID="Paperno" runat="server" Text=""></asp:Label></td>
    </tr>
  <tr>
    <td><div align="right">用户性别:</div></td>
    <td><asp:Label ID="Custsex" runat="server" Text=""></asp:Label></td>
    <td><div align="right">联系电话:</div></td>
    <td><asp:Label ID="Custphone" runat="server" Text=""></asp:Label></td>
    <td><div align="right">邮政编码:</div></td>
    <td><asp:Label ID="Custpost" runat="server" Text=""></asp:Label></td>
    <td><div align="right">联系地址:</div></td>
    <td colspan="3"><asp:Label ID="Custaddr" runat="server" Text=""></asp:Label></td>
    </tr>
  <tr>
    <td><div align="right">电子邮件:</td>
    <td><asp:Label ID="txtEmail" runat="server" Text=""></asp:Label></td> 
    <td><div align="right">集团客户:</div></td>
    <td><asp:Label ID="Corpname" runat="server" Text=""></asp:Label></td>
    <td><div align="right"></div></td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td colspan="3">&nbsp;</td>
  </tr>
</table>

 </div>
  <div class="card">修改密码</div>
  <div class="kuang5">
    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
      <tr>
        <td width="15%"><asp:Button ID="btnPassInput" runat="server" Text="小键盘输入密码" Width="100px" OnClientClick="return OpenPort()" CssClass="button1"  /></td>
        <td><div align="right">原密码:</div></td>
        <td><asp:TextBox ID="txtOPwd" CssClass="inputmid" TextMode="Password" maxlength="6" runat="server"></asp:TextBox></td>
        <td><div align="right">新密码:</div></td>
        <td><asp:TextBox ID="txtNPwd" CssClass="inputmid" TextMode="Password" maxlength="6" runat="server"></asp:TextBox></td>
        <td><div align="right">新密码确认:</div></td>
        <td><asp:TextBox ID="txtANPwd" CssClass="inputmid" TextMode="Password" maxlength="6" runat="server"></asp:TextBox></td>
      </tr>
    </table>
  </div>
  </div>
<div class="btns">
     <table width="200" border="0" align="right" cellpadding="0" cellspacing="0">
  <tr>
    <td><asp:Button ID="btnChangeUserPass" CssClass="button1" runat="server" Text="修改" Enabled=false OnClick="btnChangeUserPass_Click" /></td>  </tr>
</table>

</div>
            </ContentTemplate>
        </asp:UpdatePanel>
     </form>
</body>
</html>

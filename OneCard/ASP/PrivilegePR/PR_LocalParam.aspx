<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PR_LocalParam.aspx.cs" Inherits="ASP_PrivilegePR_PR_LocalParam" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
<title>系统设置-本地参数配置</title>
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    
    <script  language="JScript"> 
    <!--
    function readInfo()
    { 
        try{
            var  WshShell  =  new  ActiveXObject("WScript.Shell");
        }catch(ex)
        {
            alert("请调整IE的ActiveX安全级别");
            return false;
        }
        
        try
        {
              
             keyValue  =  WshShell.RegRead("HKEY_LOCAL_MACHINE\\SOFTWARE\\OneCard\\ComPort");
             
             document.getElementById("txtComPort").value = keyValue;
            
        }
        catch(ex)
        {
            document.getElementById("txtComPort").value = ''; 
        }
        
        return true;
     }
     
    function writeInfo()
    { 
    
        var tmp = document.getElementById("txtComPort").value;
        if(tmp == '' || tmp.charCodeAt(0) < 49 || tmp.charCodeAt(0) > 57)
            return true;
        else
        {
            try{
                var  WshShell  =  new  ActiveXObject("WScript.Shell");
            }catch(ex)
            {
                alert("请调整IE的ActiveX安全级别");
                return false;
            }
            
            try
            {
                 
                 keyValue  =  WshShell.RegRead("HKEY_LOCAL_MACHINE\\SOFTWARE\\OneCard\\ComPort");          
            }
            catch(ex)
            {
                 
            }finally
            {
                WshShell.RegWrite("HKEY_LOCAL_MACHINE\\SOFTWARE\\OneCard\\ComPort",document.getElementById("txtComPort").value);
                $get("hidWriteFlag").value = 'true';
            }
            
            return true;
        }
        
     }
     
     -->
    </script> 
    
    <SCRIPT FOR=window EVENT=onload  LANGUAGE="JavaScript">
    readInfo();
    </SCRIPT>	
    
</head>
<body>
    <form id="form1" runat="server">
    <ajaxToolkit:ToolkitScriptManager runat="Server" EnableScriptGlobalization="true"
    EnableScriptLocalization="true" ID="ScriptManager2" />
    <asp:UpdatePanel ID="UpdatePanel1" runat="server">
    <ContentTemplate>
    <asp:HiddenField ID="hidWriteFlag" Value="false" runat=server />
    <div class="tb">系统设置-&gt;本地参数配置</div>
    <!-- #include file="../../ErrorMsg.inc" --> 
<div class="con">
 <div class="pip">本地参数配置</div>
  <div class="kuang5">
   <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
     <tr>
       <td width="20%"><div align="right">小键盘用Com端口号:</div></td>
       <td width="16%"><asp:TextBox  ID="txtComPort" CssClass="inputmid"  MaxLength="1" runat="server"/><span class="red">*</span>
       </td>
       <td>
           &nbsp;
           <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ControlToValidate="txtComPort" ErrorMessage="必填"></asp:RequiredFieldValidator>
           <asp:RegularExpressionValidator ID="RegularExpressionValidator1" runat="server" ErrorMessage="必须是[1-9]的数字" ControlToValidate="txtComPort" Display="Dynamic" ValidationExpression="^[1-9]\d*$"></asp:RegularExpressionValidator>
       </td>
       <td>&nbsp;</td>
       <td colspan="4">
           <table width="300" border="0" align="right" cellpadding="0" cellspacing="0">
             <tr>
               <td><asp:Button ID="btnLocalParamAdd" runat="server" Text="写入" CssClass="button1" OnClientClick="return writeInfo()" OnClick="btnLocalParam_Click"  /></td>
             </tr>
           </table>
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

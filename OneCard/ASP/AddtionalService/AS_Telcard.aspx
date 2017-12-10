<%@ Page Language="C#" AutoEventWireup="true" CodeFile="AS_Telcard.aspx.cs" Inherits="ASP_AddtionalService_telcard" %>
<%@ Register Src="../../CardReader.ascx" TagName="CardReader" TagPrefix="cr" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
<title>电话卡</title>
	<link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
     
</head>
<body>
	<cr:CardReader id="cardReader" Runat="server"/>    

    <form id="form1" runat="server">
     <div class="tb">附加业务->电话卡</div>
     
      <ajaxToolkit:ToolkitScriptManager runat="Server" EnableScriptGlobalization="true"
            EnableScriptLocalization="true" ID="ScriptManager2" />
          <script type="text/javascript" language="javascript">
                var swpmIntance = Sys.WebForms.PageRequestManager.getInstance();
                swpmIntance.add_initializeRequest(BeginRequestHandler);
                swpmIntance.add_pageLoading(EndRequestHandler);
								function BeginRequestHandler(sender, args){
    							try {MyExtShow('请等待', '正在提交后台处理中...'); } catch(ex){}
								}
								function EndRequestHandler(sender, args) {
    							try {MyExtHide(); } catch(ex){}
								}
          </script>        
       <asp:UpdatePanel ID="UpdatePanel1" runat="server">
         <ContentTemplate>
         <!-- #include file="../../ErrorMsg.inc" -->  
     
         <div class="con">
          <div class="card">读取卡片信息</div>
          <div class="kuang5">
            <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
              <tr>
                <td width = "9%"><div align="right">读取内容:</div></td>
                <td width = "50%"><asp:TextBox ID="CardInfo" runat="server" Width="400" CssClass="labeltext"></asp:TextBox></td>
                <td><div align="right">&nbsp;</div></td>
                <td>&nbsp;</td>
                <td><div align="right">&nbsp;</div></td>
                <td>&nbsp;</td>
              </tr>
            </table>
            <div class="btns">
              <table width="200" border="0" align="right" cellpadding="0" cellspacing="0">
               <tr>
                <td>&nbsp;</td>
                <td><asp:Button ID="btnReadCard" runat="server" Text="读卡" CssClass="button1" OnClick="btnReadCard_Click" OnClientClick="readTelCard('CardInfo')" /></td>
               </tr>
             </table>
           </div>
          </div>
        </div>
   
        <div class="con">
          <div class="card">写入卡片信息</div>
          <div class="kuang5">
            <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25" id="TABLE1">
              <tr>
                <td width = "9%"><div align="right">类型:</div></td>
                <td width = "18%"><asp:DropDownList ID="CardType" runat="server" CssClass="input"></asp:DropDownList></td>
                <td><div align="right">卡号:</div></td>
                <td width = "15%" ><asp:TextBox ID="txtCardNo" CssClass="input" runat="server" MaxLength="35" ></asp:TextBox></td>
                <td><div align="right">密码:</div></td>
                <td width = "43%"><asp:TextBox ID="txtPasswd" CssClass="input" runat="server" MaxLength="35" ></asp:TextBox></td>
              </tr>
            </table>
            
            <div class="btns">
              <table width="200" border="0" align="right" cellpadding="0" cellspacing="0">
               <tr>
               <asp:HiddenField ID="strName" runat="server" />
               <asp:HiddenField ID="hidCardReaderToken" runat="server" />
               <asp:HiddenField ID="hidWarning" runat=server />
               <asp:LinkButton runat="server" ID="btnConfirm" OnClick="btnConfirm_Click"/>
                <td>&nbsp;</td>
                <td><asp:Button ID="btnWriteCard" runat="server" Text="写卡" Enabled="false" CssClass="button1" OnClick="btnWriteCard_Click" />
                      
                </td>
               </tr>
             </table>
           </div>
          </div>
        </div>
        
    
         </ContentTemplate>
      </asp:UpdatePanel>
    
    </form>
</body>
</html>

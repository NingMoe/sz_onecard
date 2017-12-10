<%@ Page Language="C#" AutoEventWireup="true" CodeFile="AS_ChangeTimes.aspx.cs" Inherits="ASP_AddtionalService_AS_ChangeTimes" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
    <title>年卡改次数</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
  <script language="javascript">
    function realRecvChanging(realRecv)
    {
        realRecv.value = realRecv.value.replace(/[^\d]/g, '');
    }
  </script>
</head>
<body>
    <form id="form1" runat="server">
        <div class="tb">
            附加业务->园林/休闲年卡修改次数

        </div>
        <ajaxToolkit:ToolkitScriptManager ID="ScriptManager1" runat="server"/>
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
       <asp:UpdatePanel ID="UpdatePanel1" runat="server" >
            <ContentTemplate>
    <asp:BulletedList ID="bulMsgShow" runat="server">
    </asp:BulletedList>
    <script runat="server" >public override void ErrorMsgShow(){ErrorMsgHelper(bulMsgShow);}</script>          

  <div class="con">
  <div class="card">剩余次数更新</div>
  <div class="kuang5">
 <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text20">
  <tr>
    <td width="15%"><div align="right">用户卡号:</div></td>
    <td width="13%"><asp:TextBox ID="txtCardNo" CssClass="inputmid" runat="server" /></td>
    <td width="15%"><div align="right">&nbsp;</div></td>
    <td width="13%">&nbsp;</td>
    <td width="15%">&nbsp;</td>
     <td width="13%">&nbsp;</td>
    <td width="13%" align="right"><asp:Button ID="btnReadCard" Text="查询" CssClass="button1" runat="server" 
        OnClick="btnReadCard_Click"/></td>
  </tr>
  <tr>
    <td><div align="right">园林库内次数:</div></td>
    <td><asp:Label ID="labGardenTimes" CssClass="labeltext" runat="server" Enabled="false" /></td>
    <td><div align="right">休闲库内次数:</div></td>
    <td><asp:Label ID="labRelaxTimes" CssClass="labeltext" runat="server" Enabled="false" /></td>
    <td><div align="right">吴江旅游库内次数:</div></td>
    <td><asp:Label ID="labWujlvyouTimes" CssClass="labeltext" runat="server" Enabled="false" /></td>
      <td width="13%">&nbsp;</td>
  </tr>
  <tr>
    <td><div align="right">园林新次数:</div></td>
    <td><asp:Textbox ID="txtGardenTimes" CssClass="labeltext" runat="server" Enabled="false" /></td>
    <td><div align="right">休闲新次数:</div></td>
    <td><asp:Textbox ID="txtRelaxTimes" CssClass="labeltext" runat="server" Enabled="false" /></td>
    <td><div align="right">吴江旅游新次数:</div></td>
    <td><asp:Textbox ID="txtWujlvyouTimes" CssClass="labeltext" runat="server" Enabled="false" /></td>
      <td width="13%">&nbsp;</td>
  </tr>
  </table>
 </div>
</div>
 <div class="footall"></div>
<div class="btns">
     <table width="95%" border="0"cellpadding="0" cellspacing="0">
  <tr>
    <td width="70%">&nbsp;</td>
    <td align="right"><asp:Button ID="btnSubmit" Enabled="false" CssClass="button1" runat="server" Text="提交" OnClick="btnSubmit_Click"/></td>
  </tr>
</table>

</div>  
    
                </ContentTemplate>
        </asp:UpdatePanel>
    </form>
</body>
</html>


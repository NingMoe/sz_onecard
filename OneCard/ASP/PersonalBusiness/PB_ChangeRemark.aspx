<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PB_ChangeRemark.aspx.cs" Inherits="ASP_PersonalBusiness_PB_ChangeRemark" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
<title>批量修改客户信息</title>
        <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
        <script type="text/javascript" src="../../js/myext.js"></script>
         <link href="../../css/card.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
    <div class="tb">
个人业务->批量修改客户信息

</div>
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
<asp:BulletedList ID="bulMsgShow" runat="server">
</asp:BulletedList>
<script runat="server" >public override void ErrorMsgShow(){ErrorMsgHelper(bulMsgShow);}</script>  
<div class="con">
<div class="card">起讫卡号</div>
  <div class="kuang5">
 <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text20">
  <tr>
    <td width="10%"><div align="right">起讫卡号:</div></td>
    <td width="48%"><asp:TextBox ID="txtFromCardNo" CssClass="inputmid" runat="server" MaxLength="16"></asp:TextBox>
-
  <asp:TextBox ID="txtToCardNo" CssClass="inputmid" runat="server" MaxLength="16"></asp:TextBox></td>
    <td width="42%">&nbsp;</td>
</table>
 </div>
  <div class="pip">客户信息</div>
  <div class="kuang5">
 <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text20">
  <tr>
    <td width="10%"><div align="right">备注信息:</div></td>
    <td width="48%"><asp:TextBox ID="txtRemark" CssClass="inputmidder" runat="server"></asp:TextBox></td>
    <td width="42%">&nbsp;</td>
    </tr>
</table>
 </div>
<div class="btns">
     <table width="200" border="0" align="right" cellpadding="0" cellspacing="0">
  <tr>
    <td><asp:Button ID="btnRefund" CssClass="button1" runat="server" Text="提交" OnClick="btnSubmit_Click" /></td>
  </tr>
</table>

</div>
        </ContentTemplate>          
        </asp:UpdatePanel>
    </form>
</body>
</html>

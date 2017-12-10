<%@ Page Language="C#" AutoEventWireup="true" CodeFile="GC_AccPassResetBg.aspx.cs" Inherits="ASP_GroupCard_GC_AccPassResetBg" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
<title>(后台)密码重置</title>
        <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
        <script type="text/javascript" src="../../js/myext.js"></script>
         <link href="../../css/card.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
<div class="tb">
企服卡->(后台)密码重置
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
  <div class="base">卡片查询</div>
  <div class="kuang5">
 <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
  <tr>
    <td width="10%" ><div align="right">卡号:</div></td>
    <td width="30%" >
<asp:TextBox ID="txtCardno" CssClass="input" runat="server" MaxLength="16" ></asp:TextBox>
    </td>
    <asp:HiddenField ID="hiddenread" runat=server />
    <td align="right"><asp:Button ID="btnQuery" CssClass="button1" runat="server" Text="读数据库" 
    OnClick="btnQuery_Click"/></td>
  </tr>
</table>

 </div>
  <div class="card">卡片信息</div>
 <div class="kuang5">
 <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
  <tr>
    <td width="12%"><div align="right">库内余额:</div></td>
    <td width="25%"><asp:Label ID="labOldBalance" runat="server"></asp:Label>
    <td width="9%"><div align="right">卡片状态:</div></td>
    <td width="17%"><asp:Label ID="labOldState" runat="server"></asp:Label></td>
    <td width="13%"><div align="right">
        用户姓名:</div></td>
    <td width="24%"><asp:Label ID="labOldName" runat="server"></asp:Label></td>
  </tr>
  <tr>
    <td><div align="right">
        集团客户:</div></td>
    <td><asp:Label ID="labOldCorp" runat="server"></asp:Label></td>
    <td><div align="right">用户性别:</div></td>
    <td><asp:Label ID="labOldSex" runat="server"></asp:Label></td>
    <td><div align="right">证件类型:</div></td>
    <td><asp:Label ID="labOldPaperType" runat="server"></asp:Label></td>
  </tr>
  <tr>
    <td><div align="right">证件号码:</div></td>
    <td><asp:Label ID="labOldPaperNo" runat="server"></asp:Label></td>
    <td><div align="right">出生日期:</div></td>
    <td><asp:Label ID="labOldBirth" runat="server"></asp:Label></td>
    <td><div align="right">邮政编码:</div></td>
    <td><asp:Label ID="labOldPost" runat="server"></asp:Label></td>
  </tr>
  <tr>
    <td><div align="right">联系电话:</div></td>
    <td><asp:Label ID="labOldPhone" runat="server"></asp:Label></td>
    <td><div align="right">电子邮件:</td>
    <td><asp:Label ID="txtEmail" runat="server" Text=""></asp:Label></td> 
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td><div align="right">联系地址:</div></td>
    <td colspan="5"><asp:Label ID="labOldAddr" runat="server"></asp:Label></td>
    </tr>
</table>

 </div>

</div>
<div>
  <div class="footall"></div>
</div>

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

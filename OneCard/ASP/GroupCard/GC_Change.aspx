<%@ Page Language="C#" AutoEventWireup="true" CodeFile="GC_Change.aspx.cs" Inherits="ASP_GroupCard_GC_Change" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <title>企服卡换卡</title>

    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    
    <script language="javascript">
        
    </script>
</head>
<body>
    <form id="form1" runat="server">
<div class="tb">
企服卡->换卡
</div>
        <ajaxToolkit:ToolkitScriptManager EnableScriptGlobalization="true" EnableScriptLocalization="true" ID="ScriptManager1" runat="server"/>
        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
            <ContentTemplate>

    <asp:BulletedList ID="bulMsgShow" runat="server"/>
    <script runat="server" >public override void ErrorMsgShow(){ErrorMsgHelper(bulMsgShow);}</script>


<div class="con">
  <div class="base">新旧卡信息</div>
  <div class="kuang5">
 <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
  <tr>
    <td width="10%" ><div align="right">旧卡卡号:</td>
    <td width="30%" >
<asp:TextBox ID="txtOldCardNo" CssClass="inputmid" runat="server" MaxLength="16"/>   
    <span class="red">*</span>
    </td>
    <td width="10%"><div align="right">新卡卡号:</td>
    <td width="30%">
<asp:TextBox ID="txtNewCardNo" CssClass="inputmid" runat="server" MaxLength="16"/>   
   <span class="red">*</span> </td>
    <td align="right"><asp:Button ID="btnQuery" CssClass="button1" runat="server" Text="查询" OnClick="btnQuery_Click"/></td>
  </tr>
</table>

  <asp:HiddenField runat="server" ID="hidForPaperNo" />
  <asp:HiddenField runat="server" ID="hidForPhone" />
  <asp:HiddenField runat="server" ID="hidForAddr" />
 </div>
  <div class="card">旧卡信息</div>
 <div class="kuang5">
 <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
  <tr>
    <td width="12%" align="right">
        卡号:</td>
    <td width="25%">
        <asp:Label ID="labOldCardNo" runat="server"/></td>
    <td width="9%"><div align="right">余额:</td>
    <td width="17%"><asp:Label ID="labOldBalance" runat="server"/></td>
    <td width="13%"><div align="right">卡片状态:</td>
    <td width="24%"><asp:Label ID="labOldState" runat="server"/></td>
  </tr>
  <tr>
    <td align="right">
        用户姓名:</td>
    <td><b><asp:Label ID="labOldName" runat="server"/></b></td>
    <td align="right">
        集团客户:</td>
    <td><asp:Label ID="labOldCorp" runat="server"/></td>
    <td align="right">用户性别:</td>
    <td><asp:Label ID="labOldSex" runat="server"/></td>
  </tr>
  <tr>
    <td align="right">证件类型:</td>
    <td><asp:Label ID="labOldPaperType" runat="server"/></td>
    <td align="right">证件号码:</td>
    <td><asp:Label ID="labOldPaperNo" runat="server"/></td>
    <td align="right">出生日期:</td>
    <td><asp:Label ID="labOldBirth" runat="server"/></td>
  </tr>
  <tr>
    <td align="right">邮政编码:</td>
    <td><asp:Label ID="labOldPost" runat="server"/></td>
    <td align="right">联系电话:</td>
    <td><asp:Label ID="labOldPhone" runat="server"/></td>
    <td align="right">电子邮件:</td>
    <td><asp:Label ID="labEmail" runat="server"/></td>
  </tr>
  <tr>
    <td align="right">联系地址:</td>
    <td><asp:Label ID="labOldAddr" runat="server"/></td>
    <td align="right">备注:</td>
    <td colspan="3"><asp:Label ID="labRemark" runat="server"/></td>
    </tr>
</table>

 </div>
   <div class="card">新卡信息</div>
  <div class="kuang5">
    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
      <tr>
        <td width="12%"><div align="right">卡号:</td>
        <td width="25%"><asp:Label ID="labNewCardNo" runat="server"/></td>
        <td width="9%"><div align="right">余额:</td>
        <td width="17%"><asp:Label ID="labNewBalance" runat="server"/></td>
        <td width="13%"><div align="right">卡片状态:</td>
        <td width="24%"><asp:Label ID="labNewState" runat="server"/></td>
      </tr>
      <tr>
        <td align="right">
            用户姓名:</td>
        <td><b><asp:TextBox CssClass="inputmid" MaxLength="50" ID="labNewName" runat="server"/></b></td>
        <td align="right">
            集团客户:</td>
        <td><asp:Label ID="labNewCorp" runat="server"/></td>
        <td align="right">用户性别:</td>
        <td><asp:DropDownList ID="selCustSex" runat="server"/></td>
      </tr>
      <tr>
        <td align="right">证件类型:</td>
        <td><asp:DropDownList ID="selPaperType" CssClass="input" runat="server"/></td>
        <td align="right">证件号码:</td>
        <td><asp:TextBox CssClass="inputmid" MaxLength="20" ID="labNewPaperNo" runat="server"/></td>
        <td align="right">出生日期:</td>
        <td><asp:TextBox CssClass="inputmid" ID="labNewBirth" runat="server" MaxLength="8" /></td>
        <ajaxToolkit:CalendarExtender ID="FCalendar" runat="server" TargetControlID="labNewBirth"
            Format="yyyyMMdd" />
      </tr>
      <tr>
        <td align="right">邮政编码:</td>
        <td><asp:TextBox CssClass="inputmid" MaxLength="6" ID="labNewPost" runat="server"/></td>
        <td align="right">联系电话:</td>
        <td><asp:TextBox CssClass="inputmid" MaxLength="20" ID="labNewPhone" runat="server"/></td>
        <td align="right">电子邮件:</td>
        <td><asp:TextBox ID="txtEmail" CssClass="inputmid" runat="server" MaxLength="30"/></td>
      </tr>
      <tr>
        <td align="right">联系地址:</td>
        <td><asp:TextBox CssClass="inputmid" MaxLength="50" ID="labNewAddr" runat="server"/></td>
        <td align="right">备注:</td>
        <td colspan="3"><asp:TextBox ID="txtRemark" CssClass="inputlong" runat="server" MaxLength="100"/></td>
      </tr>
    </table>
  </div>
</div>

  <div class="footall"></div>

<div class="btns">
     <table width="200" align="right" border="0"cellpadding="0" cellspacing="0">
  <tr>
    <td>&nbsp;</td>
    <td align="middle"><asp:Button ID="btnSubmit" Enabled="false" CssClass="button1" runat="server" Text="提交" 
        OnClick="btnSubmit_Click"/></td>
  </tr>
</table>
<asp:CheckBox ID="chkReplace" runat="server"  Text="使用旧卡信息替换新卡信息" 
     Checked="false" AutoPostBack="true" OnCheckedChanged="chkReplace_CheckedChanged"/>

</div>  
   </ContentTemplate>
        </asp:UpdatePanel>
  </form>
</body>
</html>

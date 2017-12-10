<%@ Page Language="C#" AutoEventWireup="true" CodeFile="UC_BatchDistribution.aspx.cs" Inherits="ASP_UserCard_UC_BatchDistribution" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <title>批量分配</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    
    <script type="text/javascript" src="../../js/mootools.js"></script>

    <script type="text/javascript">
        
    </script>
</head>
<body>
    <form id="form1" runat="server">
<div class="tb">
卡片管理->用户卡（取消）批量分配
</div>
        <ajaxToolkit:ToolkitScriptManager EnableScriptGlobalization="true" EnableScriptLocalization="true" ID="ScriptManager1" runat="server"/>
        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
            <ContentTemplate>

    <asp:BulletedList ID="bulMsgShow" runat="server"/>
    <script runat="server" >public override void ErrorMsgShow(){ErrorMsgHelper(bulMsgShow);}</script>

<div class="con">
  <div class="base">卡（取消）批量分配</div>
  <div class="kuang5">
 <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
  <tr>
    <td width="10%"><div align="right">操作类型:</div></td>
    <td>
    <asp:DropDownList ID="selCardState" CssClass="input" runat="server" AutoPostBack="true" OnSelectedIndexChanged="selCardState_SelectedIndexChanged"></asp:DropDownList>
    </td>
    <td width="10%"><div align="right">起讫卡号:</div></td>
    <td><asp:TextBox ID="txtFromCardNo" CssClass="inputmid" runat="server" MaxLength="16"></asp:TextBox>
    -
    <asp:TextBox ID="txtToCardNo" CssClass="inputmid" runat="server" MaxLength="16"></asp:TextBox>
<span class="red">*</span></td>
  </tr>
  <tr>
    <td width="10%"><div align="right">分配类型:</div></td>
    <td  colspan="4">
    (仅限批量分配) &nbsp;&nbsp;
        <asp:RadioButton ID="rbStaff"  GroupName="radio1" runat="server" Text="员工" Checked="True"/>
        <asp:DropDownList ID="selStaffNo" runat="server" CssClass="inputmid" >
        </asp:DropDownList>
        &nbsp;&nbsp;
        <asp:RadioButton ID="rbBank" GroupName="radio1"  runat="server" Text="银行" />        
        <asp:DropDownList ID="selBankNo" runat="server" CssClass="inputmidder" >
        </asp:DropDownList>
    </td>
  </tr>
</table>

 </div>
</div>
<div class="btns">
     <table width="95%" border="0"cellpadding="0" cellspacing="0">
  <tr>
    <td width="70%">&nbsp;</td>
    <td align="right"><asp:Button ID="btnSubmit" CssClass="button1" runat="server" Text="提交" OnClick="btnSubmit_Click"/></td>
  </tr>
</table>

</div>
            </ContentTemplate>
        </asp:UpdatePanel>
    </form>
</body>
</html>

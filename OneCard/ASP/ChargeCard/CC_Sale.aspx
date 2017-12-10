<%@ Page Language="C#" AutoEventWireup="true" CodeFile="CC_Sale.aspx.cs" Inherits="ASP_ChargeCard_CC_Sale" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
    <title>充值卡售卡</title>

    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
        <div class="tb">
            充值卡->售卡
        </div>
        <ajaxToolkit:ToolkitScriptManager EnableScriptGlobalization="true" EnableScriptLocalization="true" ID="ScriptManager1" runat="server"/>
       <asp:UpdatePanel ID="UpdatePanel1" runat="server" >
            <ContentTemplate>
    <asp:BulletedList ID="bulMsgShow" runat="server"/>
    <script runat="server" >public override void ErrorMsgShow(){ErrorMsgHelper(bulMsgShow);}</script>          


 <div class="con">
  <div class="base"></div>
  <div class="kuang5">
    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
      <tr>
        <td width="10%" align="right">起始卡号:</td>
        <td width="20%"><asp:TextBox runat="server" ID="txtFromCardNo" MaxLength="14" CssClass="inputmid"/><span class="red">*</span>
        </td>
        <td width="10%" align="right">终止卡号:</td>
        <td width="20%"><asp:TextBox runat="server" ID="txtToCardNo" MaxLength="14" CssClass="inputmid"/><span class="red">*</span>
        <td width="10%" align="right">
            卡片类型:
        </td>
         <td width="20%" >
            <asp:Label runat="server" ID="labCardType"/>
        </td>
        <td align="right">
            <asp:Button ID="btnQuery" Enabled="true" CssClass="button1" runat="server" Text="查询" OnClick="btnQuery_Click"/>
        </td>
      </tr>
      <tr>
        <td width="10%" align="right">卡片数量:</td>
        <td width="20%"><asp:Label runat="server" ID="labQuantity"/></td>
        <td width="10%" align="right">总面值:</td>
        <td width="20%"><asp:Label runat="server" ID="labTotalValue"/></td>
        <td colspan="3">&nbsp;</td>
      </tr>
        <tr>
            <td align="right" width="10%">
                备注:</td>
            <td colspan="6">
                <asp:TextBox runat="server" ID="txtRemark" MaxLength="100" 
                    CssClass="inputmax"></asp:TextBox></td>
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

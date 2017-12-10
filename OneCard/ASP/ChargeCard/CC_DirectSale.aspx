<%@ Page Language="C#" AutoEventWireup="true" CodeFile="CC_DirectSale.aspx.cs" Inherits="ASP_ChargeCard_CC_DirectSale" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <title>充值卡直销</title>

    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
        <div class="tb">
            充值卡->直销
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
        <td width="20%"><asp:TextBox runat="server" ID="txtFromCardNo" MaxLength="14" CssClass="inputmid"> </asp:TextBox><span class="red">*</span>
        </td>
        <td width="10%" align="right">终止卡号:</td>
        <td width="20%"><asp:TextBox runat="server" ID="txtToCardNo" MaxLength="14" CssClass="inputmid"></asp:TextBox><span class="red">*</span>
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
        <td width="20%"><asp:Label runat="server" ID="labQuantity"></asp:Label></td>
        <td width="10%" align="right">总面值:</td>
        <td width="20%"><asp:Label runat="server" ID="labTotalValue"></asp:Label></td>
        <td colspan="3">&nbsp;</td>
      </tr>
      <tr>
        <td width="10%" align="right">付款方式:</td>
        <td width="20%">
                <asp:DropDownList CssClass="input" AutoPostBack="true" runat="server" ID="selPayMode" OnSelectedIndexChanged="selPayMode_SelectedIndexChanged">
                    <asp:ListItem Value="" Text="---请选择---"></asp:ListItem>
                    <asp:ListItem Value="1" Text="1:现金方式"></asp:ListItem>
                    <asp:ListItem Value="0" Text="0:转账方式"></asp:ListItem>
                    <asp:ListItem Value="2" Text="2:报销方式"></asp:ListItem>
                </asp:DropDownList>
                    
                <span class="red">*</span>

        </td>
        <td width="10%" align="right">到帐标记:</td>
        <td width="20%">
                <asp:DropDownList CssClass="input" Enabled="false" AutoPostBack="true" runat="server" ID="selRecvTag" OnSelectedIndexChanged="selPayMode_SelectedIndexChanged">
                    <asp:ListItem Value="" Text="---请选择---"></asp:ListItem>
                    <asp:ListItem Value="1" Text="1:已到帐"></asp:ListItem>
                    <asp:ListItem Value="0" Text="0:未到帐"></asp:ListItem>
                </asp:DropDownList>
                <span class="red">*</span>

        </td>
        <td colspan="3">&nbsp;</td>
      </tr>
      <tr>
        <td width="10%" align="right">到帐日期:</td>
        <td colspan="5"><asp:TextBox Enabled="false" runat="server" ID="txtAccRecvDate" CssClass="input"></asp:TextBox>
     <span class="red">*</span>(“转账或报销方式，已到帐”时必需)
      <ajaxToolkit:CalendarExtender ID="FCalendar" runat="server" TargetControlID="txtAccRecvDate"
            Format="yyyyMMdd" />
      </tr>
      <tr>
        <td width="10%" align="right">客户姓名:</td>
        <td colspan="6"><asp:TextBox runat="server" ID="txtCustName" CssClass="inputmax" MaxLength="50"></asp:TextBox>
        <span class="red">*</span>
        </td>
      </tr>
      <tr>
        <td width="10%" align="right">备注:</td>
        <td colspan="6"><asp:TextBox runat="server" ID="txtRemark" CssClass="inputmax" MaxLength="200"></asp:TextBox></td>
      </tr>

    </table>
  </div>
  </div>
  <div class="footall"></div>
  
<div class="btns">
    &nbsp;<table width="95%" border="0"cellpadding="0" cellspacing="0">
  <tr>
    <td width="70%">&nbsp;注：1) 直销只能选择具有相同面值的充值卡号段。<br />
&nbsp;&nbsp;&nbsp; &nbsp;2) 直销选择的充值卡必须已经激活。</td>
    <td align="right">&nbsp;</td>
    <td align="right">&nbsp;</td>
    <td align="right"><asp:Button ID="btnSubmit" Enabled="false" CssClass="button1" runat="server" Text="提交" OnClick="btnSubmit_Click"/></td>
  </tr>
</table>

</div>
            </ContentTemplate>
        </asp:UpdatePanel>
    </form>
</body>
</html>

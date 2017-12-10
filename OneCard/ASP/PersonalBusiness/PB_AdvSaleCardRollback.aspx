<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PB_AdvSaleCardRollback.aspx.cs" Inherits="ASP_PersonalBusiness_PB_AdvSaleCardRollback" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>高级售卡返销</title>

    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />   
</head>
<body>
    <form id="form1" runat="server">
<div class="tb">
个人业务->高级售卡返销

</div>
        <ajaxToolkit:ToolkitScriptManager EnableScriptGlobalization="true" EnableScriptLocalization="true" ID="ScriptManager1" runat="server"/>
        <asp:UpdatePanel ID="UpdatePanel1" UpdateMode="Conditional" runat="server">
            <ContentTemplate>

    <asp:BulletedList ID="bulMsgShow" runat="server"/>
    <script runat="server" >public override void ErrorMsgShow(){ErrorMsgHelper(bulMsgShow);}</script>
<div class="con">
<div class="base"></div>
  <div class="kuang5">
 <table width="95%" border="0" cellpadding="0" cellspacing="0" class="12text">
  <tr>
    <td width="10%"><div align="right">起讫卡号:</div></td>
    <td width="48%"><asp:TextBox ID="txtFromCardNo" CssClass="inputmid" runat="server" MaxLength="16" Width="120"/>
-
  <asp:TextBox ID="txtToCardNo" CssClass="inputmid" runat="server" MaxLength="16" Width="120"/></td>
    <td width="42%"><asp:Button ID="btnQuery" CssClass="button1" runat="server" Text="加入到列表" OnClick="btnQuery_Click" /></td>
    </tr>
</table>
  </div>
  <div class="base"></div>
  <div class="kuang5">
 <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
  <tr>
    <td width="10%"><div align="right">导入文件:</div></td>
    <td width="48%">
    <asp:FileUpload ID="FileUpload1" runat="server" CssClass="inputlong" />
    </td>
    <td width="42%">
    <asp:Button ID="btnUpload" CssClass="button1" runat="server" Text="加入到列表" OnClick="btnUpload_Click"/>
    </td>
  </tr>
</table>

 </div>
  <div class="jieguo">卡号列表</div>
  <div class="kuang5">
<div class="gdtb" style="height:310px">
         <asp:GridView ID="gvResult" runat="server"
        Width = "98%"
        CssClass="tab1"
        HeaderStyle-CssClass="tabbt"
        AlternatingRowStyle-CssClass="tabjg"
        SelectedRowStyle-CssClass="tabsel"
        AllowPaging="false"
        PagerSettings-Mode="NumericFirstLast"
        PagerStyle-HorizontalAlign="left"
        PagerStyle-VerticalAlign="Top"
        AutoGenerateColumns="true"
        EmptyDataText="没有数据记录!" >
        </asp:GridView>
  </div>
  </div>
</div>
<div class="btns">
     <table width="200" align="right"  border="0"cellpadding="0" cellspacing="0">
  <tr>
    <td><asp:Button ID="btnClear" CssClass="button1" runat="server" Text="清除列表" OnClick="btnClear_Click"/></td>
    <td><asp:Button ID="btnSubmit" Enabled="false" CssClass="button1" runat="server" Text="提交" OnClick="btnSubmit_Click"/></td>
  </tr>
</table>

</div>

            </ContentTemplate>
    <Triggers>
    <asp:PostBackTrigger ControlID="btnUpload" />
    </Triggers>            
        </asp:UpdatePanel>

    </form>
</body>
</html>

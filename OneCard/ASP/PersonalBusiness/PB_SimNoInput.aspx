<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PB_SimNoInput.aspx.cs" Inherits="ASP_PersonalBusiness_PB_SimNoInput" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <title>SIM串号录入</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />    
</head>
<body>
    <form id="form1" runat="server">
<div class="tb">
个人业务->SIM串号

</div>
        <ajaxToolkit:ToolkitScriptManager EnableScriptGlobalization="true" EnableScriptLocalization="true" ID="ScriptManager1" runat="server"/>
        <asp:UpdatePanel ID="UpdatePanel1" UpdateMode="Conditional" runat="server" RenderMode="inline">
            <ContentTemplate>
    <asp:BulletedList ID="bulMsgShow" runat="server"/>
    <script runat="server" >public override void ErrorMsgShow(){ErrorMsgHelper(bulMsgShow);}</script>


<div class="con">
  <div class="base">SIM串号</div>
  <div class="kuang5">
 <table width="100%" border="0" cellpadding="0" cellspacing="0" class="text25">
  <tr>
    <td style="width:8%" align="right">导入文件:</td>
    <td style="width:40%"> <asp:FileUpload ID="FileUpload1" runat="server" CssClass="inputlong" />
    <asp:Button ID="btnUpload" CssClass="button1" runat="server" Text="导入" OnClick="btnUpload_Click"/></td>
    <td align="right">IC卡号:</td>
    <td><asp:TextBox runat="server" ID="txtCardNo" CssClass="input" MaxLength="16" /></td>
    <td align="right">SIM串号:</td>
    <td><asp:TextBox runat="server" ID="txtSimNo" CssClass="inputmid" MaxLength="20" /></td>
    <td><asp:Button runat="server" ID="btnQuery" CssClass="button1" Text="查询" OnClick="btnQuery_Click" /></td>
  </tr>
</table>

 </div>
  <div class="jieguo">串号信息</div>
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
        EmptyDataText="没有数据记录!"
        OnPageIndexChanging="gvResult_Page">
        </asp:GridView>
</div>
  </div>
</div>
<div class="btns">
     <table width="95%" border="0"cellpadding="0" cellspacing="0">
  <tr>
    <td width="70%">&nbsp;</td>
    <td align="right"><asp:Button ID="btnSubmit" Visible="false" CssClass="button1" runat="server" Text="提交" OnClick="btnSubmit_Click"/></td>
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

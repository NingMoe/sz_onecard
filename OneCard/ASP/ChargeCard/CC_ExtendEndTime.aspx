<%@ Page Language="C#" AutoEventWireup="true" CodeFile="CC_ExtendEndTime.aspx.cs" Inherits="ASP_ChargeCard_CC_ExtendEndTime" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
    <title>充值卡延期</title>

     <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
   <link href="../../css/card.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
        <ajaxToolkit:ToolkitScriptManager EnableScriptGlobalization="true" EnableScriptLocalization="true" ID="ScriptManager1" runat="server"/>
        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
            <ContentTemplate>
        <div class="tb">
        充值卡->充值卡延期
        </div>

    <asp:BulletedList ID="bulMsgShow" runat="server"/>
    <script runat="server" >public override void ErrorMsgShow(){ErrorMsgHelper(bulMsgShow);}</script>

        <div class="con">
          <div class="base">查询条件</div>
          <div class="kuang5">
         <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
          <tr>
            <td><div align="right">卡号范围:</div></td>
            <td colspan="5"><asp:TextBox ID="txtFromCardNo" CssClass="input" runat="server" MaxLength="16"></asp:TextBox>
              -
              <asp:TextBox ID="txtToCardNo" CssClass="input" runat="server"  MaxLength="16"></asp:TextBox>
                <div align="right"></div></td>
            <td><asp:Button ID="btnQuery" CssClass="button1" runat="server" Text="查询" OnClick="btnQuery_Click"/></td>
          </tr>
        </table>

         </div>
          <div class="jieguo">查询结果
          </div>
  <div class="kuang5">
        <div id="gdtb" style="height:310px">
         <asp:GridView ID="gvResult" runat="server"
        Width = "98%"
        CssClass="tab1"
        HeaderStyle-CssClass="tabbt"
        AlternatingRowStyle-CssClass="tabjg"
        SelectedRowStyle-CssClass="tabsel"
        AllowPaging="True"
        PageSize="10"
        PagerSettings-Mode=NumericFirstLast
        PagerStyle-HorizontalAlign=left
        PagerStyle-VerticalAlign=Top
        OnPageIndexChanging="gvResult_PageIndexChanging"
        AutoGenerateColumns="true"
        OnRowDataBound="lvwQuery_RowDataBound"
        EmptyDataText="没有数据记录!"
        >        
        </asp:GridView>
        </div>
  </div>       
  </div>
  <div class="btns">
    &nbsp;<table width="95%" border="0"cellpadding="0" cellspacing="0">
  <tr>
    <td width="70%">&nbsp;<br />
&nbsp;&nbsp;&nbsp; &nbsp;</td>
    <td align="right">&nbsp;</td>
    <td align="right">&nbsp;</td>
    <td align="right"><asp:Button ID="btnSubmit" Enabled="true" CssClass="button1" runat="server" Text="提交" OnClientClick="return confirm('确认提交?');" OnClick="btnSubmit_OnClick"/></td>
  </tr>
</table>

</div>
</ContentTemplate>
</asp:UpdatePanel>
    </form>
</body>
</html>

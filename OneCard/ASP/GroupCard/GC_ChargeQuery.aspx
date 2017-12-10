<%@ Page Language="C#" AutoEventWireup="true" CodeFile="GC_ChargeQuery.aspx.cs" Inherits="ASP_GroupCard_GC_ChargeQuery" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
    <title>企服卡查询</title>

     <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
   <link href="../../css/card.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
        <ajaxToolkit:ToolkitScriptManager EnableScriptGlobalization="true" EnableScriptLocalization="true" ID="ScriptManager1" runat="server"/>
        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
            <ContentTemplate>
        <div class="tb">
        企服卡->企服卡查询
        </div>

    <asp:BulletedList ID="bulMsgShow" runat="server"/>
    <script runat="server" >public override void ErrorMsgShow(){ErrorMsgHelper(bulMsgShow);}</script>

        <div class="con">
          <div class="base">查询条件</div>
          <div class="kuang5">
         <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
          <tr>
            <td><div align="right">查询类型:</div></td>
            <td>
                <asp:DropDownList runat="server" ID="selQueryType" CssClass="inputmid">
                    <asp:ListItem Text="以卡号查后台充值历史" Value="CardAccHis"></asp:ListItem>
                    <asp:ListItem Text="以卡号查前台充值历史" Value="CardLoadHis"></asp:ListItem>
                    <asp:ListItem Text="以卡号查换卡历史" Value="ChangeHis"></asp:ListItem>
                    <asp:ListItem Text="以集团号查询充值历史" Value="GroupIdHis"></asp:ListItem>
                    <asp:ListItem Text="以集团名查询充值历史" Value="GroupNameHis"></asp:ListItem>
                    <asp:ListItem Text="以集团名查询卡号信息" Value="GetCardNoByCust"></asp:ListItem>
                    <asp:ListItem Text="以卡号查询集团信息" Value="GetCustByCardNo"></asp:ListItem>
                </asp:DropDownList>
            </td>
            <td><div align="right">查询条件:</div></td>
            <td colspan="3"><asp:TextBox runat="server" ID="txtVar1" MaxLength="16" CssClass="inputmid"></asp:TextBox>
            </td>
            <td align="right"><asp:Button ID="btnQuery" CssClass="button1" runat="server" Text="查询" OnClick="btnQuery_Click"/></td>
          </tr>
        </table>

         </div>
          <div class="jieguo">查询结果
          </div>
             <div class="kuang5">
              <div class="gdtb" style="height:310px">

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
                    AutoGenerateColumns="true"
                    OnRowDataBound="gvResult_RowDataBound" 
                    ShowFooter="true"
                    OnPageIndexChanging="gvResult_Page">

                 </asp:GridView>
             </div>
           </div>       
         </div>
       </ContentTemplate>
      </asp:UpdatePanel>
    </form>
</body>
</html>

<%@ Page Language="C#" AutoEventWireup="true" CodeFile="CC_SaleRollback.aspx.cs" Inherits="ASP_ChargeCard_CC_SaleRollback" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <title>充值卡售卡返销</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
<div class="tb">
充值卡->售卡返销
</div>
        <ajaxToolkit:ToolkitScriptManager EnableScriptGlobalization="true" EnableScriptLocalization="true" ID="ScriptManager1" runat="server"/>
        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
            <ContentTemplate>

    <asp:BulletedList ID="bulMsgShow" runat="server"/>
    <script runat="server" >public override void ErrorMsgShow(){ErrorMsgHelper(bulMsgShow);}</script>

<div class="con">
  <div class="base">查询条件</div>
  <div class="kuang5">
    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
      <tr>
        <td width="10%" align="right">充值卡号:</td>
        <td width="30%">
         <asp:TextBox runat="server" ID="txtFromCardNo" MaxLength="14" CssClass="input"></asp:TextBox>
         <%--- <asp:TextBox runat="server" ID="txtToCardNo" MaxLength="14" CssClass="input"></asp:TextBox>--%>
        </td>
        <td width="10%" align="right">出售日期:</td>
        <td width="35%">
         <asp:TextBox runat="server" ID="txtFromSaleDate" MaxLength="8" CssClass="input"></asp:TextBox>
      <ajaxToolkit:CalendarExtender ID="FCalendar1" runat="server" TargetControlID="txtFromSaleDate"
             Format="yyyyMMdd" />
        - <asp:TextBox runat="server" ID="txtToSaleDate" MaxLength="8" CssClass="input"></asp:TextBox>
      <ajaxToolkit:CalendarExtender ID="FCalendar2" runat="server" TargetControlID="txtToSaleDate"
            Format="yyyyMMdd" />
        </td>
        <td align="right">
            <asp:Button ID="btnQuery" Enabled="true" CssClass="button1" runat="server" Text="查询" OnClick="btnQuery_Click"/>
        </td>
      </tr>
    </table>
  </div>

  <div class="jieguo">售卡信息</div>
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
        AutoGenerateColumns="False"
        OnPageIndexChanging="gvResult_Page">
           <Columns>
             <asp:TemplateField ItemStyle-Width="5%">
                <HeaderTemplate>
                  选择
                </HeaderTemplate>
                <ItemTemplate>
                   <input name="radioBatchNo" type="radio" value='<%# Eval("TRADEID") %>' />
                </ItemTemplate>
            </asp:TemplateField>
               <asp:BoundField ItemStyle-Width="15%" HeaderText="批次号" DataField="TRADEID"/>
               <asp:BoundField ItemStyle-Width="30%" HeaderText="充值卡号" DataField="CARDNO"/>
                <asp:BoundField ItemStyle-Width="5%" HeaderText="数量" DataField="AMOUNT"/>
                <asp:BoundField ItemStyle-Width="5%" HeaderText="面值" DataField="MONEY"  DataFormatString="{0:n}" HtmlEncode="False"/>
                <asp:BoundField ItemStyle-Width="5%" HeaderText="总面值" DataField="TOTAL"  DataFormatString="{0:n}" HtmlEncode="False"/>
                <asp:BoundField ItemStyle-Width="20%" HeaderText="出售时间" DataField="OPERATETIME" DataFormatString="{0:yyyy-MM-dd HH:mm:ss}" HtmlEncode="False"/>
                <asp:BoundField  HeaderText="备注" DataField="REMARK"/>
            </Columns>           
            <EmptyDataTemplate>
                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                  <tr class="tabbt">
                    <td width="5%">选择</td>
                    <td width="15%">批次号</td>
                    <td width="30%">充值卡号</td>
                    <td width="5%">数量</td>
                    <td width="5%">面值</td>
                     <td width="5%">总面值</td>
                   <td width="20%">出售时间</td>
                   <td>备注</td>
                  </tr>
                  </table>
            </EmptyDataTemplate>
        </asp:GridView>
  </div>
  </div>
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

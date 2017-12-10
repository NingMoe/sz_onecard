<%@ Page Language="C#" AutoEventWireup="true" CodeFile="CC_DSAccRecv.aspx.cs" Inherits="ASP_ChargeCard_CC_DSAccRecv" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
        <title>直销到账</title>

    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
        <div class="tb">
            充值卡->直销到帐
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
        <td width="10%" align="right">到帐标记:</td>
        <td width="20%">
            <asp:RadioButton runat="server" ID="radRecvd" GroupName="AccRecv" Text="已到帐"/>
            <asp:RadioButton runat="server" ID="radNotRecvd" Checked="true" GroupName="AccRecv" Text="未到帐"/>
        </td>
        <td width="10%" align="right">客户姓名:</td>
        <td width="20%"><asp:TextBox runat="server" ID="txtCustName" CssClass="input" MaxLength="50"></asp:TextBox>
        </td>
        <td align="right">
            <asp:Button ID="btnQuery" Enabled="true" CssClass="button1" runat="server" Text="查询" OnClick="btnQuery_Click"/>
        </td>
      </tr>
    </table>
  </div>
   
  <div class="card"></div>
    <div class="kuang5">
<%--<div id="gdtb" style="height:310px">--%>
         <asp:GridView ID="gvResult" runat="server"
        Width = "98%"
        CssClass="tab1"
        HeaderStyle-CssClass="tabbt"
        AlternatingRowStyle-CssClass="tabjg"
        SelectedRowStyle-CssClass="tabsel"
        AllowPaging="True"
        PageSize="100"
        PagerSettings-Mode=NumericFirstLast
        PagerStyle-HorizontalAlign=left
        PagerStyle-VerticalAlign=Top
        AutoGenerateColumns="False"
        OnPageIndexChanging="gvResult_Page">
           <Columns>
             <asp:TemplateField ItemStyle-Width="5%">
                <HeaderTemplate>
                  已到帐
                </HeaderTemplate>
                <ItemTemplate>
                  <asp:CheckBox ID="ItemCheckBox" runat="server"/>
                </ItemTemplate>
            </asp:TemplateField>
             <asp:TemplateField ItemStyle-Width="10%">
                <HeaderTemplate>
                  到帐日期
                </HeaderTemplate>
                <ItemTemplate>
                  <asp:TextBox ID="txtRecvDate" runat="server" CssClass="input" MaxLength="8"></asp:TextBox>
       <ajaxToolkit:CalendarExtender ID="FCalendar" runat="server" TargetControlID="txtRecvDate"
            Format="yyyyMMdd" />
               </ItemTemplate>
            </asp:TemplateField>              
               <asp:BoundField ItemStyle-Width="7%" HeaderText="付款方式" DataField="PAYTYPE"/>
               <asp:BoundField ItemStyle-Width="10%" HeaderText="批次号" DataField="TRADEID"/>
               <asp:BoundField ItemStyle-Width="20%" HeaderText="号段" DataField="CardNoRange"/>
                <asp:BoundField ItemStyle-Width="15%" HeaderText="客户姓名" DataField="CUSTNAME"/>
                <asp:BoundField ItemStyle-Width="5%" HeaderText="面值" DataField="CARDVALUE"  DataFormatString="{0:n}" HtmlEncode="False"/>
                <asp:BoundField ItemStyle-Width="3%" HeaderText="数量" DataField="AMOUNT"/>
                <asp:BoundField ItemStyle-Width="5%" HeaderText="总面值" DataField="TOTALMONEY"  DataFormatString="{0:n}" HtmlEncode="False"/>
            </Columns>           
            <EmptyDataTemplate>
                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                  <tr class="tabbt">
                    <td width="5%">已到帐</td>
                    <td width="10%">到帐日期</td>
                    <td width="7%">付款方式</td>
                    <td width="10%">批次号</td>
                    <td width="20%">号段</td>
                    <td width="15%">客户姓名</td>
                    <td width="5%">面值</td>
                    <td width="3%">数量</td>
                    <td width="5%">总面值</td>
                  </tr>
                  </table>
            </EmptyDataTemplate>
        </asp:GridView>
  <%--</div>--%>
  </div> 
  
 </div>
  <div class="footall"></div>
  
<div class="btns">
     <table width="95%" border="0"cellpadding="0" cellspacing="0">
  <tr>
    <td width="70%">&nbsp;</td>
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

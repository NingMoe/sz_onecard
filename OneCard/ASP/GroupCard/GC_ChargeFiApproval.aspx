<%@ Page Language="C#" AutoEventWireup="true" CodeFile="GC_ChargeFiApproval.aspx.cs" Inherits="ASP_GroupCard_GC_ChargeFiApproval" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
    <title>企服卡充值财审</title>

    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    

    <script language="javascript">
        
    </script>
    
</head>
<body>
    <form id="form1" runat="server">
<div class="tb">
企服卡->充值财务审核
</div>
        <ajaxToolkit:ToolkitScriptManager EnableScriptGlobalization="true" EnableScriptLocalization="true" ID="ScriptManager1" runat="server"/>
        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
            <ContentTemplate>
    <asp:BulletedList ID="bulMsgShow" runat="server"/>
    <script runat="server" >public override void ErrorMsgShow(){ErrorMsgHelper(bulMsgShow);}</script>

<div class="con">
  <div class="jieguo">充值信息</div>
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
        AutoGenerateColumns="False"
        OnPageIndexChanging="gvResult_Page">
           <Columns>
             <asp:TemplateField>
                <HeaderTemplate>
                  <asp:CheckBox ID="CheckBox1" runat="server"  AutoPostBack="true" OnCheckedChanged="CheckAll" />
                </HeaderTemplate>
                <ItemTemplate>
                  <asp:CheckBox ID="ItemCheckBox" runat="server"/>
                </ItemTemplate>
            </asp:TemplateField>
               <asp:BoundField HeaderText="批次号" DataField="ID"/>
                <asp:BoundField HeaderText="集团客户" DataField="CORPNAME"/>
                <asp:BoundField HeaderText="卡片数量" DataField="AMOUNT"/>
                <asp:BoundField HeaderText="充值总额" DataField="SUPPLYMONEY"  DataFormatString="{0:n}" HtmlEncode="False"/>
                <asp:BoundField HeaderText="充值时间" DataField="SUPPLYTIME" DataFormatString="{0:yyyy-MM-dd}" HtmlEncode="False"/>
                <asp:BoundField HeaderText="充值员工" DataField="SUPPLYSTAFFNAME"/>
                <asp:BoundField HeaderText="审批时间" DataField="CHECKTIME" DataFormatString="{0:yyyy-MM-dd}" HtmlEncode="False"/>
                <asp:BoundField HeaderText="审批员工" DataField="STAFFNAME"/>
            </Columns>           
            <EmptyDataTemplate>
                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                  <tr class="tabbt">
                    <td><input type="checkbox" /></td>
                    <td>批次号</td>
                    <td>集团客户</td>
                    <td>卡片数量</td>
                    <td>充值总额</td>
                    <td>充值时间</td>
                    <td>充值员工</td>
                    <td>审批时间</td>
                    <td>审批员工</td>
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
    <td align="right"><asp:CheckBox ID="chkApprove" AutoPostBack="true" Text="通过" runat="server" OnCheckedChanged="chkApprove_CheckedChanged" /></td>
    <td align="right"><asp:CheckBox ID="chkReject" AutoPostBack="true" Text="作废" runat="server" OnCheckedChanged="chkReject_CheckedChanged"  /></td>
    <td align="right"><asp:Button ID="btnSubmit" Enabled="false" CssClass="button1" runat="server" Text="提交" OnClick="btnSubmit_Click"/></td>
  </tr>
</table>
</div>

            </ContentTemplate>         
        </asp:UpdatePanel>

    </form>
</body>
</html>


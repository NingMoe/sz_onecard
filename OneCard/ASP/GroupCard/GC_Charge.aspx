<%@ Page Language="C#" AutoEventWireup="true" CodeFile="GC_Charge.aspx.cs" Inherits="ASP_GroupCard_GC_Charge" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
    <title>企服卡充值</title>

    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />    
</head>
<body>
    <form id="form1" runat="server">
<div class="tb">
企服卡->批量充值
</div>
        <ajaxToolkit:ToolkitScriptManager EnableScriptGlobalization="true" EnableScriptLocalization="true" ID="ScriptManager1" runat="server"/>
        <asp:UpdatePanel ID="UpdatePanel1" UpdateMode="Conditional" runat="server">
            <ContentTemplate>
    <asp:BulletedList ID="bulMsgShow" runat="server"/>
    <script runat="server" >public override void ErrorMsgShow(){ErrorMsgHelper(bulMsgShow);}</script>


<div class="con">
  <div class="base">批量充值</div>
  <div class="kuang5">
 <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
  <tr>
    <td><div align="right">导入文件:</div></td>
    <td>
    <asp:FileUpload ID="FileUpload1" runat="server" CssClass="inputlong" />
    <asp:Button ID="btnUpload" CssClass="button1" runat="server" Text="导入" OnClick="btnUpload_Click"/>
    </td>
    <td><div align="right">集团客户:</div></td>
    <td ><asp:DropDownList ID="selCorp" CssClass="inputmidder" runat="server">
                                    </asp:DropDownList>
    </td>
  </tr>
</table>

 </div>
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
        PageSize="100"
        PagerSettings-Mode=NumericFirstLast
        PagerStyle-HorizontalAlign=left
        PagerStyle-VerticalAlign=Top
        AutoGenerateColumns="False"
        OnPageIndexChanging="gvResult_Page">
           <Columns>
               <asp:BoundField HeaderText="卡号" DataField="CardNo"/>
                <asp:BoundField HeaderText="充值金额" DataField="ChargeAmount" NullDisplayText="0" DataFormatString="{0:n}" HtmlEncode="false"/>
           </Columns>           
            <EmptyDataTemplate>
                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                  <tr class="tabbt">
                    <td>卡号</td>
                    <td>充值金额</td>
                  </tr>
                  </table>
            </EmptyDataTemplate>
        </asp:GridView>
</div>
  </div>
<div class="base">汇总</div>
   <div class="kuang5">
   
 <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
  
  <tr>
    <td width="10%"><div align="right">卡片数量:</div></td>
    <td width="10%"><asp:Label ID="labAmount" runat="server"></asp:Label></td>
    <td width="10%"><div align="right">充值总额:</div></td>
    <td width="10%"><asp:Label ID="labChargeTotal" runat="server"></asp:Label></td>
    <td width="60%" colspan="6">&nbsp;</td>
  </tr>
</table>
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
    <Triggers>
    <asp:PostBackTrigger ControlID="btnUpload" />
    </Triggers>            
        </asp:UpdatePanel>

    </form>
</body>
</html>

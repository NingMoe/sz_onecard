<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PB_Refund.aspx.cs" Inherits="ASP_PersonalBusiness_PB_Refund" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
<title>预付款退款</title>
        <link rel="stylesheet" type="text/css" href="../../css/frame.css" />

         <link href="../../css/card.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
    <div class="tb">
个人业务->预付款退款
</div>
<ajaxToolkit:ToolkitScriptManager runat="Server" EnableScriptGlobalization="true"
            EnableScriptLocalization="true" ID="ScriptManager2" />
          <script type="text/javascript" language="javascript">
                var swpmIntance = Sys.WebForms.PageRequestManager.getInstance();
                swpmIntance.add_initializeRequest(BeginRequestHandler);
                swpmIntance.add_pageLoading(EndRequestHandler);
								function BeginRequestHandler(sender, args){
    							try {MyExtShow('请等待', '正在提交后台处理中...'); } catch(ex){}
								}
								function EndRequestHandler(sender, args) {
    							try {MyExtHide(); } catch(ex){}
								}
          </script>
        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
            <ContentTemplate>
<asp:BulletedList ID="bulMsgShow" runat="server">
</asp:BulletedList>
<script runat="server" >public override void ErrorMsgShow(){ErrorMsgHelper(bulMsgShow);}</script>  
<div class="con">
<div class="card">充值记录</div>
  <div class="kuang5">
 <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text20">
  <tr>
    <td width="11%"><div align="right">充值记录ID:</div></td>
    <td width="14%"><asp:TextBox ID="SupplyId" CssClass="input" Width=140 maxlength="18" runat="server"></asp:TextBox></td>
    <td width="11%"><div align="right">&nbsp;</div></td>
    <td width="14%">&nbsp;</td>
    <td width="11%"><div align="right">&nbsp;</div></td>
    <td width="8%">&nbsp;</td>
    <td width="10%">&nbsp;</td>
    <td width="11%"><div align="right"><asp:Button ID="btnQuery" CssClass="button1" runat="server" Text="查询" OnClick="btnQuery_Click" /></td>
    <td width="23%">&nbsp;</td>
    <asp:HiddenField ID="hidBalunitno" runat="server" />
  </tr>
</table>

 </div>
  <div class="pip">退款信息</div>
  <div class="kuang5">
 <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text20">
  <tr>
    <td width="15%"><div align="right">卡号:</div></td>
    <td width="15%"><asp:TextBox ID="txtCardno" CssClass="labeltext" ReadOnly=true maxlength="16" runat="server"></asp:TextBox></td>
    <td width="15%"><div align="right">退款金额:</div></td>
    <td width="15%"><asp:Label ID="BackMoney" runat="server" Text=""></asp:Label></td>
    <td width="15%"><div align="right">充值ID:</div></td>
    <td width="20%"><asp:Label ID="chargeID" runat="server" Text=""></asp:Label></td>
    </tr>
    <tr>
    <td><div align="right">代理商户:</div></td>
    <td><asp:DropDownList ID="selDeptBalunit" runat="server"></asp:DropDownList></td>
    <td><div align="right"></div></td>
    <td></td>
    <td><div align="right"></div></td>
    <td></td>
    </tr>
</table>
 </div>
<div class="btns">
     <table width="200" border="0" align="right" cellpadding="0" cellspacing="0">
  <tr>
    <td><asp:Button ID="btnRefund" CssClass="button1" runat="server" Text="退款" Enabled=false OnClick="btnRefund_Click" /></td>
  </tr>
</table>

</div>
        </ContentTemplate>          
        </asp:UpdatePanel>
    </form>
</body>
</html>

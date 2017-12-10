<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PS_BankInfoChange.aspx.cs" Inherits="ASP_PartnerShip_PS_BankInfoChange" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
    <title>银行编码维护</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <script type="text/javascript" src="../../js/myext.js"></script>
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
    <div class="tb">
    合作伙伴->银行编码维护    </div>
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
<div class="card">银行编码查询</div>
  <div class="kuang5">
 <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text20">
  <tr>
    <td width="11%"><div align="right">银行编码:</div></td>
    <td width="14%"><asp:DropDownList ID="selFinBank" AutoPostBack=true OnSelectedIndexChanged="selFinBank_changed" runat="server"></asp:DropDownList></td>
    <td width="11%"><div align="right">分行编码:</div></td>
    <td width="23%"><asp:DropDownList ID="selFinBranch" AutoPostBack=true runat="server"></asp:DropDownList></td>
    <td width="11%"><div align="right">&nbsp;</div></td>
    <td width="8%">&nbsp;</td>
    <td width="11%">&nbsp;</td>
    <td width="14%">&nbsp;</td>
  </tr>
</table>

 </div>
  <div class="pip">银行编码维护</div>
  <div class="kuang5">
 <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text20">
  <tr>
    <td width="11%"><div align="right">银行编码:</div></td>
    <td width="14%"><asp:TextBox ID="txtBankcode" CssClass="input" maxlength="4" runat="server"></asp:TextBox></td>
    <td width="11%"><div align="right">银行名称:</div></td>
    <td width="23%"><asp:TextBox ID="txtBank" CssClass="inputlong" maxlength="200" runat="server"></asp:TextBox></td>
    <td width="11%"><div align="right">&nbsp;</div></td>
    <td width="8%">&nbsp;</td>
    <td width="11%">&nbsp;</td>
    <td width="14%">&nbsp;</td>
    </tr>
  <%--<tr>
    <td><div align="right">返还比例:</div></td>
    <td><asp:DropDownList ID="BackSlope" AutoPostBack=true OnSelectedIndexChanged="BackSlope_SelectedIndexChanged" runat="server"></asp:DropDownList></td>
    <td><div align="right">用户姓名:</div></td>
    <td><asp:TextBox ID="txtCusname" CssClass="input" maxlength="25" runat="server"></asp:TextBox></td>
    <td><div align="right">&nbsp;</div></td>
    <td>&nbsp;</td>
    <td><div align="right">&nbsp;</div></td>
    <td colspan="3">&nbsp;</td>
    </tr>--%>
<%--  <tr>
    <td><div align="right">&nbsp;</div></td>
    <td>&nbsp;</td>
    <td><div align="right"></div></td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td colspan="3">&nbsp;</td>
  </tr>--%>
</table>
 </div>
<div class="btns">
     <table width="200" border="0" align="right" cellpadding="0" cellspacing="0">
  <tr>
    <td><asp:Button ID="btnAdd" CssClass="button1" runat="server" Text="新增" OnClick="btnAdd_Click" /></td>
  </tr>
</table>

</div>
        </ContentTemplate>          
        </asp:UpdatePanel>
    </form>
</body>
</html>

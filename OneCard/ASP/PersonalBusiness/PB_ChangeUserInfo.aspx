<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PB_ChangeUserInfo.aspx.cs"
    Inherits="ASP_PersonalBusiness_PB_ChangeUserInfo" %>

<%@ Register Src="../../CardReader.ascx" TagName="CardReader" TagPrefix="cr" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>修改资料</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <cr:CardReader ID="cardReader" runat="server" />
    <form id="form1" runat="server">
    <div class="tb">
        个人业务->修改资料
    </div>
    <ajaxToolkit:ToolkitScriptManager runat="Server" EnableScriptGlobalization="true"
        EnableScriptLocalization="true" ID="ScriptManager2" />
    <script type="text/javascript" language="javascript">
        var swpmIntance = Sys.WebForms.PageRequestManager.getInstance();
        swpmIntance.add_initializeRequest(BeginRequestHandler);
        swpmIntance.add_pageLoading(EndRequestHandler);
        function BeginRequestHandler(sender, args) {
            try { MyExtShow('请等待', '正在提交后台处理中...'); } catch (ex) { }
        }
        function EndRequestHandler(sender, args) {
            try { MyExtHide(); } catch (ex) { }
        }
    </script>
    <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <contenttemplate>
<asp:BulletedList ID="bulMsgShow" runat="server">
</asp:BulletedList>
<script runat="server" >public override void ErrorMsgShow() { ErrorMsgHelper(bulMsgShow); }</script>  
<div class="con">
  <div class="card">卡片信息</div> 
  <div class="kuang5">
  
  <asp:HiddenField runat="server" ID="hidForPaperNo" />
  <asp:HiddenField runat="server" ID="hidForPhone" />
  <asp:HiddenField runat="server" ID="hidForAddr" />
 <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text20">
  <tr>
    <td width="12%"><div align="right">用户卡号:</div></td>
    <td width="12%"><asp:TextBox ID="txtCardno" CssClass="input" maxlength="16" runat="server"></asp:TextBox></td>
    <td width="12%"><div align="right">卡序列号:</div></td>
    <td width="12%"><asp:TextBox ID="LabAsn" CssClass="labeltext" runat="server"></asp:TextBox></td>
    <asp:HiddenField ID="hiddenAsn" runat="server" />
    <td width="12%"><div align="right">卡片类型:</div></td>
    <td width="12%"><asp:TextBox ID="LabCardtype" CssClass="labeltext" runat="server"></asp:TextBox></td>
    <asp:HiddenField ID="hiddenLabCardtype" runat="server" />
    <td width="12%"><div align="right">卡片状态:</div></td>
    <td width="10%"><asp:TextBox ID="RESSTATE" CssClass="labeltext" runat="server"></asp:TextBox></td>
    <asp:HiddenField ID="hiddenread" runat="server" />  
    <td width="6%"><asp:Button ID="btnReadCard" CssClass="button1" runat="server" Text="读卡" 
        OnClientClick="return ReadCardInfo();" OnClick="btnReadCard_Click" /></td>
  </tr>
  <tr>
    <td><div align="right">启用日期:</div></td>
    <td><asp:TextBox ID="sDate" CssClass="labeltext" runat="server" Text=""></asp:TextBox></td>
    <asp:HiddenField ID="hiddensDate" runat="server" />
    <td><div align="right" style="display: none">结束日期:</div></td>
    <td><asp:TextBox ID="eDate" CssClass="labeltext" Visible="False" runat="server" Text=""></asp:TextBox></td>
    <asp:HiddenField ID="hiddeneDate" runat="server" />
    <td><div align="right">卡内余额:</div></td>
    <td><asp:TextBox ID="cMoney" CssClass="labeltext" runat="server" Text=""></asp:TextBox></td>
    <asp:HiddenField ID="hiddencMoney" runat="server" />
    <td>&nbsp;</td>
 <td>&nbsp;</td>
        <td width="6%"><asp:Button ID="btnChangeUserInfoDBread" CssClass="button1" runat="server" Text="读数据库" 
            OnClick="btnChangeUserInfoDBread_Click" /></td>

  </tr>
  <tr>
    <td><div align="right">开通功能:</div></td>
    <td colspan="8">
        <aspControls:OpenFunc ID ="openFunc" runat="server" />
    </td>
    </tr>
</table>

 </div>

   <div class="pip">修改信息</div>
 <div class="kuang5">
  <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
  <tr>
    <td width="10%"><div align="right">用户姓名:</div></td>
    <td width="140"><asp:TextBox ID="txtCusname" CssClass="input" maxlength="25" runat="server"></asp:TextBox></td>
    <td width="9%"><div align="right">出生日期:</div></td>
    <td> <asp:TextBox ID="txtCustbirth" CssClass="input" runat="server" maxlength="10"/>
    <ajaxToolkit:CalendarExtender ID="FCalendar" runat="server" TargetControlID="txtCustbirth" Format="yyyy-MM-dd" /></td>
    <td width="9%"><div align="right">证件类型:</div></td>
    <td><asp:DropDownList ID="selPapertype" CssClass="input" runat="server"></asp:DropDownList></td>
    <td width="9%"><div align="right">证件号码:</div></td>
    <td><asp:TextBox ID="txtCustpaperno" CssClass="input" maxlength="20" runat="server"></asp:TextBox></td>
    
    </tr>
  <tr>
    <td><div align="right">用户性别:</div></td>
    <td><asp:DropDownList ID="selCustsex" CssClass="input" runat="server"></asp:DropDownList></td>
    <td><div align="right">联系电话:</div></td>
    <td><asp:TextBox ID="txtCustphone" CssClass="input" maxlength="20" runat="server"></asp:TextBox></td>
    <td><div align="right">邮政编码:</div></td>
    <td><asp:TextBox ID="txtCustpost" CssClass="input" maxlength="6" runat="server"></asp:TextBox></td>
    <td><div align="right">联系地址:</div></td>
    <td><asp:TextBox ID="txtCustaddr" CssClass="input" maxlength="50" runat="server"></asp:TextBox></td>
    
  </tr>
  <tr>
    <td><div align="right">电子邮件:</td>
    <td><asp:TextBox ID="txtEmail" CssClass="input" maxlength="30" runat="server"></asp:TextBox></td>    
    <td valign="top"><div align="right">备注　　:</div></td>
    <td colspan="4"><asp:TextBox ID="txtRemark" CssClass="inputlong" maxlength="50" runat="server"></asp:TextBox></td>
    <td><asp:Button ID="txtReadPaper" Text="读二代证" CssClass="button1" runat="server" 
    OnClientClick="readIDCardEx('txtCusname', 'selCustsex', 'txtCustbirth', 'selPapertype', 'txtCustpaperno', 'txtCustaddr')" /></td>
  </tr>
</table>
 </div>


 
</div>
<div>
  <div class="footall"></div>
</div>

<div class="btns">
     <table width="100" border="0" align="right" cellpadding="0" cellspacing="0">
  <tr>
    <%--<td><asp:Button ID="btnPrint" CssClass="button1" runat="server" Text="打印" OnClick="btnPrint" /></td>--%>
    <td><asp:Button ID="btnChangeUserInfo" CssClass="button1" runat="server" Text="修改" OnClick="btnChangeUserInfo_Click" /></td>
  </tr>
</table>
</div>
            </contenttemplate>
    </asp:UpdatePanel>
    </form>
</body>
</html>

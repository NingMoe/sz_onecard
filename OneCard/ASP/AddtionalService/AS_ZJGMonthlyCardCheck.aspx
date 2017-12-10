<%@ Page Language="C#" AutoEventWireup="true" CodeFile="AS_ZJGMonthlyCardCheck.aspx.cs" Inherits="ASP_AddtionalService_AS_ZJGMonthlyCardCheck" %>
<%@ Register Src="../../CardReader.ascx" TagName="CardReader" TagPrefix="cr" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
    <title>张家港-公交月票审核</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="../../js/print.js"></script>
  <script language="javascript">
    function realRecvChanging(realRecv)
    {
        realRecv.value = realRecv.value.replace(/[^\d]/g, '');
    }
  </script>
</head>
<body>
  
    <form id="form1" runat="server">
    <cr:CardReader id="cardReader" Runat="server"/>  
        <div class="tb">
            附加业务->张家港-公交月票审核

        </div>
        <ajaxToolkit:ToolkitScriptManager ID="ScriptManager1" runat="server"/>
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
       <asp:UpdatePanel ID="UpdatePanel1" runat="server" >
            <ContentTemplate>
             <aspControls:PrintPingZheng ID="ptnPingZheng" runat="server" PrintArea="ptnPingZheng1" />
    <asp:BulletedList ID="bulMsgShow" runat="server">
    </asp:BulletedList>
    <script runat="server" >public override void ErrorMsgShow(){ErrorMsgHelper(bulMsgShow);}</script>          
    <asp:HiddenField runat="server" ID="hidWarning" />
  <asp:LinkButton runat="server" ID="btnConfirm" OnClick="btnConfirm_Click"/>
  <asp:HiddenField ID="hidAccRecv" runat=server />



  <asp:HiddenField runat="server" ID="hidReissue" />
  
    
    
  <asp:HiddenField runat="server" ID="hidAsn" />
  <asp:HiddenField runat="server" ID="hidNewCardType" />
  <asp:HiddenField runat="server" ID="txtStartDate" />
  <asp:HiddenField runat="server" ID="txtEndDate" />
  <asp:HiddenField runat="server" ID="txtCardBalance" />
     <asp:HiddenField runat="server" ID="hidTradeNo" />
     <asp:HiddenField runat="server" ID="hidZJGMonthlyFlag" />
     <asp:HiddenField runat="server" ID="hidAppType" />
  <div class="con">
    <div class="card">卡片信息</div>
  <div class="kuang5">
 <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text20">
  <tr>
    <td width="9%"><div align="right">用户卡号:</div></td>
    <td width="13%"><asp:TextBox ID="txtCardno" CssClass="labeltext" maxlength="16" runat="server"></asp:TextBox></td>
    <td width="9%"><div align="right">卡序列号:</div></td>
    <td width="13%"><asp:TextBox ID="LabAsn" CssClass="labeltext" runat="server"></asp:TextBox></td>
    
    <td width="9%"><div align="right">卡片类型:</div></td>
    <td width="13%"><asp:TextBox ID="LabCardtype" CssClass="labeltext"  width=100 runat="server"></asp:TextBox></td>
    
    <td width="9%"><div align="right">卡片状态:</div></td>
    <td width="10%"><asp:TextBox ID="RESSTATE" CssClass="labeltext" runat="server"></asp:TextBox></td>
    
    <td width="12%"><asp:Button ID="btnReadCard" CssClass="button1" runat="server" Text="读卡" 
        OnClientClick="return ReadZJGMonthlyCardInfo()" OnClick="btnReadCard_Click" /></td>
  </tr>
  <tr>
    <td><div align="right">启用日期:</div></td>
    <td><asp:TextBox ID="sDate" CssClass="labeltext"  width=100 runat="server" Text=""></asp:TextBox></td>
   
    <td><div align="right">结束日期:</div></td>
    <td><asp:TextBox ID="eDate" CssClass="labeltext"  width=100 runat="server" Text=""></asp:TextBox></td>
    
    <td><div align="right">卡内余额:</div></td>
    <td><asp:TextBox ID="cMoney" CssClass="labeltext"  width=100 runat="server" Text=""></asp:TextBox></td>
 
    
    <td><div align="right">售卡时间:</div></td>
    <td><asp:TextBox ID="sellTime" CssClass="labeltext"  width=100 runat="server" Text=""></asp:TextBox></td>
  </tr>
  <tr>
    <td><div align="right">开通功能:</div></td>
    <td colspan="3">
        <aspControls:OpenFunc ID ="openFunc" runat="server" />
    </td>
    <td align="right">库内有效期:</td>
     <td><asp:TextBox ID="cEndDate" CssClass="labeltext"  width="100" runat="server" Text=""></asp:TextBox></td>
     <td align="right">卡内标识:</td>
     <td><asp:TextBox ID="txtZJGEndDate" CssClass="labeltext"  width="100" runat="server" Text=""></asp:TextBox></td>
   </tr>
</table>

 </div>
  <div class="pip">用户信息</div>
  <div class="kuang5">
 <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text20">
  <tr>
    <td width="9%"><div align="right">用户姓名:</div></td>
    <td width="13%"><asp:Label ID="CustName" runat="server" Text=""></asp:Label></td>
    <td width="9%"><div align="right">出生日期:</div></td>
    <td width="13%"><asp:Label ID="CustBirthday" runat="server" Text=""></asp:Label></td>
    <td width="9%"><div align="right">证件类型:</div></td>
    <td width="13%"><asp:Label ID="Papertype" runat="server" Text=""></asp:Label></td>
    <td width="9%"><div align="right">证件号码:</div></td>
    <td width="25%" colspan="3"><asp:Label ID="Paperno" runat="server" Text=""></asp:Label></td>
    </tr>
  <tr>
    <td><div align="right">用户性别:</div></td>
    <td><asp:Label ID="Custsex" runat="server" Text=""></asp:Label></td>
    <td><div align="right">联系电话:</div></td>
    <td><asp:Label ID="Custphone" runat="server" Text=""></asp:Label></td>
    <td><div align="right">邮政编码:</div></td>
    <td><asp:Label ID="Custpost" runat="server" Text=""></asp:Label></td>
    <td><div align="right">联系地址:</div></td>
    <td colspan="3"><asp:Label ID="Custaddr" runat="server" Text=""></asp:Label></td>
    </tr> 
  <tr>
    <td><div align="right">电子邮件:</td>
    <td><asp:Label ID="txtEmail" runat="server" Text=""></asp:Label></td>    
    <td valign="top"><div align="right">备注　　:</div></td>
    <td colspan="5"><asp:Label ID="Remark" runat="server" Text=""></asp:Label></td>
    </tr>
</table>

 </div>
</div>
 <div class="footall"></div>

<div class="btns">
     <table width="200" border="0" align="right" cellpadding="0" cellspacing="0">
  <tr>
    <td><asp:Button ID="btnPrintPZ" runat="server" Text="打印凭证" CssClass="button1" Enabled="false"  OnClientClick="printdiv('ptnPingZheng1')"/></td>

    <td><asp:Button ID="btnSubmit" Enabled="false" CssClass="button1" runat="server" Text="审核" OnClick="btnSubmit_Click"/></td>
    <asp:HiddenField ID="hiddenverify" runat=server />
    <asp:HiddenField ID="hiddenCheck" runat=server />
    <asp:HiddenField runat="server" ID="hidCardReaderToken" />
  </tr>
</table>
  <td><asp:CheckBox ID="chkPingzheng" runat="server" Checked="true" />自动打印凭证</td>
  <td><span class="red">请正确放置卡片，并确认该卡片为需要审核卡片</span></td>
  </div>

 
    
                </ContentTemplate>
        </asp:UpdatePanel>
    </form>
</body>
</html>


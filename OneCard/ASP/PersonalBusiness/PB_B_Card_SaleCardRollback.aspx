<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PB_B_Card_SaleCardRollback.aspx.cs" Inherits="ASP_PersonalBusiness_PB_B_Card_SaleCardRollback" %>
<%@ Register Src="../../CardReader.ascx" TagName="CardReader" TagPrefix="cr" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
<title>吴江B卡售卡返销</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
 
    <script type="text/javascript" src="../../js/print.js"></script>
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
</head>
<body>
	<cr:CardReader id="cardReader" Runat="server" />    

    <form id="form1" runat="server">
    <div class="tb">
个人业务->吴江B卡售卡返销
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
            <aspControls:PrintPingZheng ID="ptnPingZheng" runat="server" PrintArea="ptnPingZheng1" />
<asp:BulletedList ID="bulMsgShow" runat="server">
</asp:BulletedList>
<script runat="server" >public override void ErrorMsgShow(){ErrorMsgHelper(bulMsgShow);}</script>  
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
    <td width="13%"><asp:TextBox ID="LabCardtype" CssClass="labeltext" runat="server"></asp:TextBox></td>
    <td width="9%"><div align="right">卡片状态:</div></td>
    <td width="9%"><asp:TextBox ID="RESSTATE" CssClass="labeltext" runat="server"></asp:TextBox></td>
    <td width="25%"><asp:Button ID="btnReadCard" CssClass="button1" runat="server" Text="读卡" 
        OnClientClick="return ReadCardInfo()" OnClick="btnReadCard_Click" /></td>
  </tr>
  <tr>
    <td><div align="right">卡内余额:</div></td>
    <td><asp:TextBox ID="cMoney" CssClass="labeltext" runat="server" Text=""></asp:TextBox></td>
    <td><div align="right">售卡员工:</div></td>
    <td><asp:Label ID="SaleStaff" runat="server" Text=""></asp:Label></td>
    <td><div align="right">售卡时间:</div></td>
    <td><asp:Label ID="SaleDate" runat="server" Text=""></asp:Label></td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td><div align="right">开通功能:</div></td>
    <td colspan="8">
        <aspControls:OpenFunc ID ="openFunc" runat="server" />
    </td>
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
<asp:HiddenField ID="hiddentxtCardno" runat=server />
<asp:HiddenField ID="hiddenAsn" runat=server />
<asp:HiddenField ID="hiddenLabCardtype" runat=server />
<asp:HiddenField ID="hiddensDate" runat=server />
<asp:HiddenField ID="hiddeneDate" runat=server />
<asp:HiddenField ID="hiddencMoney" runat=server />
<asp:HiddenField ID="hiddentradeno" runat=server />
<asp:HiddenField ID="hidWarning" runat=server />
<asp:LinkButton runat="server" ID="btnConfirm" OnClick="btnConfirm_Click"/>
<asp:HiddenField ID="hiddenDepositFee" runat=server />
<asp:HiddenField ID="hiddenCardcostFee" runat=server />
<asp:HiddenField ID="hidProcedureFee" runat=server />
<asp:HiddenField ID="hidOtherFee" runat=server />
<asp:HiddenField runat="server" ID="hidCardReaderToken" />
 </div>
</div>
 <div class="basicinfo">
 <div class="money">费用信息</div>
 <div class="kuang5">
     <table width="180" border="0" cellpadding="0" cellspacing="0" class="tab1">
  <tr class="tabbt">
    <td width="66">费用项目</td>
    <td width="94">费用金额(元)</td>
    </tr>
  <tr>
    <td>押金</td>
    <td><asp:Label ID="DepositFee" runat="server" Text=""></asp:Label></td>
    </tr>
  <tr class="tabjg">
    <td>卡费</td>
    <td><asp:Label ID="CardcostFee" runat="server" Text=""></asp:Label></td>
    </tr>
  <tr>
    <td>手续费</td>
    <td><asp:Label ID="ProcedureFee" runat="server" Text=""></asp:Label></td>
  </tr>
  <tr class="tabjg">
    <td>其他费用</td>
    <td><asp:Label ID="OtherFee" runat="server" Text=""></asp:Label></td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr class="tabjg">
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr class="tabjg">
    <td>合计应收</td>
    <td><asp:Label ID="Total" runat="server" Text=""></asp:Label></td>
  </tr>
</table>
 </div>
 </div>
 <div class="pipinfo">
 <div class="info">返销信息</div>
 <div class="kuang5">
 <div class="bigkuang">
 <div class="left">
 <img src="../../Images/show-change.JPG" /></div>
  <div class="big">
    <table width="200" border="0" cellpadding="0" cellspacing="0" class="text25">
      <tr>
       <td width="160" colspan="2">&nbsp;</td>
       </tr>
     
     <tr>
       <td colspan="2">
         <label></label></td>
      </tr>
     <tr>
       <td colspan="2" class="red"><div align="center">应收/退客户的金额</div></td>
      </tr>
     <tr>
       <td colspan="2"><div align="center"><asp:Label ID="ReturnSupply" runat="server" Text=""></asp:Label>
       </div></td>
      </tr>
     <tr>
       <td colspan="2">&nbsp;</td>
     </tr>
     <tr>
       <td colspan="2">&nbsp;</td>
     </tr>
    </table>
  </div>
  </div>
 </div>
</div>
 <div class="footall"></div>
<div class="btns">
     <table width="200" border="0" align="right" cellpadding="0" cellspacing="0">
  <tr>
    <td><asp:Button ID="btnPrintPZ" runat="server" Text="打印凭证" CssClass="button1" Enabled="false"  OnClientClick="printdiv('ptnPingZheng1')"/></td>
    <td><asp:Button ID="btnRollback" CssClass="button1" runat="server" Text="售卡返销" Enabled=false OnClick="btnRollback_Click" /></td>

  </tr>
</table>
<td><asp:CheckBox ID="chkPingzheng" runat="server" Checked="true" />自动打印凭证</td>
</div>
</ContentTemplate>          
        </asp:UpdatePanel>
    </form>
</body>
</html>


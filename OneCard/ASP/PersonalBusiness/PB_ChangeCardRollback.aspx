<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PB_ChangeCardRollback.aspx.cs"
    Inherits="ASP_PersonalBusiness_PB_ChangeCardRollback" %>

<%@ Register Src="../../CardReader.ascx" TagName="CardReader" TagPrefix="cr" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>换卡返销</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <script type="text/javascript" src="../../js/print.js"></script>
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <cr:CardReader ID="cardReader" runat="server" />
    <form id="form1" runat="server">
    <div class="tb">
        个人业务->换卡返销
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
            <aspControls:PrintPingZheng ID="ptnPingZheng" runat="server" PrintArea="ptnPingZheng1" />
<asp:BulletedList ID="bulMsgShow" runat="server">
</asp:BulletedList>
<script runat="server" >public override void ErrorMsgShow() { ErrorMsgHelper(bulMsgShow); }</script>  
<div class="con">
  <div class="card">旧卡信息</div>
  <div class="kuang5">
 <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text20">
  <tr>
    <td width="11%"><div align="right">旧卡卡号　:</div></td>
    <td width="11%"><asp:TextBox ID="txtOCardno" CssClass="input" maxlength="16" runat="server"></asp:TextBox></td>
    <td width="11%"><div align="right">旧卡押金:</div></td>
    <td width="11%"><asp:TextBox ID="ODeposit" CssClass="labeltext" runat="server"></asp:TextBox></td>
    <td width="11%"><div align="right">换卡类型:</div></td>
    <td width="20%"><asp:TextBox ID="ReasonType" CssClass="labeltext" runat="server"></asp:TextBox></td>
    <td width="11%"><asp:Button ID="btnReadCard" CssClass="button1" runat="server" Text="读卡" 
        OnClientClick="return ReadCardInfoEx('txtOCardno')" OnClick="btnReadCard_Click" /></td>
    <td width="14%"><asp:Button ID="btnDBRead" CssClass="button1" runat="server" Text="读数据库" OnClick="btnDBRead_Click" /></td>
  </tr>
  <tr>
    <td><div align="right">服务开始日:</div></td>
    <td><asp:TextBox ID="OsDate" CssClass="labeltext" runat="server" Text=""></asp:TextBox></td>
    <td><div align="right">旧卡余额:</div></td>
    <td><asp:TextBox ID="OldcMoney" CssClass="labeltext" runat="server" Text=""></asp:TextBox></td>
    <td><div align="right">&nbsp;</div></td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
</table>

 </div>
  <div class="card">新卡信息</div>
  <div class="kuang5">
 <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text20">
   <tr>
     <td width="11%"><div align="right">新卡卡号　:</div></td>
     <td width="11%"><asp:TextBox ID="txtNCardno" CssClass="labeltext"  maxlength="16" runat="server"></asp:TextBox></td>
     <td width="11%"><div align="right">新卡押金:</div></td>
     <td width="11%"><asp:TextBox ID="NDeposit" CssClass="labeltext" runat="server"></asp:TextBox></td>
     <td width="11%"><div align="right">新卡类型:</div></td>
     <td width="20%"><asp:TextBox ID="LabCardtype" CssClass="labeltext" runat="server"></asp:TextBox></td>
     <td width="11%">&nbsp;</td>
     <td width="14%"><asp:Button ID="btnReadNCard" CssClass="button1" Enabled="false" runat="server" Text="读新卡" 
        OnClientClick="return ReadCardInfo('txtNCardno')" OnClick="btnReadNCard_Click" /></td>
   </tr>
   <tr>
     <td><div align="right">服务开始日:</div></td>
     <td><asp:TextBox ID="NsDate" CssClass="labeltext" runat="server" Text=""></asp:TextBox></td>
     <td><div align="right">新卡余额:</div></td>
     <td><asp:TextBox ID="NewcMoney" CssClass="labeltext" runat="server" Text=""></asp:TextBox></td>
     <td>&nbsp;</td>
     <td>&nbsp;</td>
     <td>&nbsp;</td>
     <td>&nbsp;</td>
   </tr>
    <asp:HiddenField ID="hiddenread" runat="server" />
    <asp:HiddenField ID="hiddentxtCardno" runat="server" />
    <asp:HiddenField ID="hiddenAsn" runat="server" />
    <asp:HiddenField ID="hiddenLabCardtype" runat="server" />
    <asp:HiddenField ID="hiddensDate" runat="server" />
    <asp:HiddenField ID="hiddeneDate" runat="server" />
    <asp:HiddenField ID="hiddencMoney" runat="server" />
    <asp:HiddenField ID="hidSupplyMoney" runat="server" />
    <asp:HiddenField ID="hiddentradeno" runat="server" />
    <asp:HiddenField ID="hidWarning" runat="server" />
    <asp:LinkButton runat="server" ID="btnConfirm" OnClick="btnConfirm_Click"/>
    <asp:HiddenField ID="hiddenDepositFee" runat="server" />
    <asp:HiddenField ID="hiddenCardcostFee" runat="server" />
    <asp:HiddenField ID="hidProcedureFee" runat="server" />
    <asp:HiddenField ID="hidOtherFee" runat="server" />
    <asp:HiddenField ID="hiddenTradeid" runat="server" />
    <asp:HiddenField ID="hiddenREASONCODE" runat="server" />
    <asp:HiddenField ID="hiddenCardstate" runat="server" />
    <asp:HiddenField ID="hiddenSerstaketag" runat="server" />
    <asp:HiddenField ID="hiddenChangeCardno" runat="server" />
    <asp:HiddenField runat="server" ID="hidCardReaderToken" />
    <asp:HiddenField runat="server" ID="hidCustname" />
    <asp:HiddenField runat="server" ID="hidPaperno" />
    <asp:HiddenField runat="server" ID="hidPapertype" />
 </table>
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
 <div class="info">换卡信息</div>
 <div class="kuang5">
 <div class="bigkuang">
 <div class="left">
 <img src="../../Images/show-change.JPG" /></div>
  <div class="big">
  <table width="200" border="0" cellspacing="0" cellpadding="0">
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
       <td colspan="2"><div align="center"><asp:Label ID="ReturnSupply" runat="server" Text=""></asp:Label></div></td>
      </tr>
      <tr>
        <td colspan="2" class="red"></td>
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
                        <td>
                            <asp:Button ID="btnPrintPZ" runat="server" Text="打印凭证" CssClass="button1" Enabled="false"
                                OnClientClick="printdiv('ptnPingZheng1')" />
                        </td>
                        <td>
                            <asp:Button ID="btnRollback" CssClass="button1" runat="server" Text="换卡返销" Enabled="false"
                                OnClick="btnRollback_Click" />
                        </td>
                        <asp:HiddenField ID="hidTradeIDZJG" runat="server" />
                        <asp:HiddenField ID="hidOldCardIDZJG" runat="server" />
                        <asp:HiddenField ID="hidNewCardIDZJG" runat="server" />
  </tr>
</table>
<asp:CheckBox ID="chkPingzheng" runat="server" Checked="true" />自动打印凭证
</div>
</contenttemplate>
    </asp:UpdatePanel>
    </form>
</body>
</html>

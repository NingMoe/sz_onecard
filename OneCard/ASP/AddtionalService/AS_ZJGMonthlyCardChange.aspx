<%@ Page Language="C#" AutoEventWireup="true" CodeFile="AS_ZJGMonthlyCardChange.aspx.cs" Inherits="ASP_AddtionalService_AS_ZJGMonthlyCardChange" %>
<%@ Register Src="../../CardReader.ascx" TagName="CardReader" TagPrefix="cr" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
    <title>月换</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
     <script type="text/javascript" src="../../js/print.js"></script>
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />

</head>
<body>
	<cr:CardReader id="cardReader" Runat="server"/>    

    <form id="form1" runat="server">
        <div class="tb">
            附加业务->张家港月票卡换卡
        </div>
        <ajaxToolkit:ToolkitScriptManager EnableScriptGlobalization="true" EnableScriptLocalization="true" ID="ScriptManager1" runat="server"/>
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
    <aspControls:PrintShouJu ID="ptnShouJu" runat="server" PrintArea="ptnShouJu1" />
            
    <asp:BulletedList ID="bulMsgShow" runat="server">
    </asp:BulletedList>
    <script runat="server" >public override void ErrorMsgShow(){ErrorMsgHelper(bulMsgShow);}</script>          

  <div class="con">
  <div class="card">旧卡信息</div>
  <div class="kuang5">
 <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text20">
  <tr>
    <td width="10%"><div align="right">旧卡卡号:</div></td>
    <td width="13%"><asp:TextBox ID="txtOldCardNo" CssClass="labeltext" runat="server" MaxLength="16"/></td>
    <td width="10%"><div align="right">换卡类型:</div></td>
    <td width="13%"><asp:DropDownList ID="selReasonType" AutoPostBack="true" CssClass="inputmid"  runat="server" OnSelectedIndexChanged="selReasonType_SelectedIndexChanged" /></td>
    <td width="10%"><div align="right">旧卡押金:</div></td>
    <td width="13%"><asp:TextBox ID="txtOldCardDeposit" CssClass="labeltext" runat="server" /></td>
    <td width="9%">&nbsp;</td>
    <td width="22%">&nbsp;</td>
    
<asp:HiddenField runat="server" ID="hidAsn" />          
<asp:HiddenField runat="server" ID="txtStartDate" />    
<asp:HiddenField runat="server" ID="txtEndDate" />
<asp:HiddenField runat="server" ID="txtCardBalance" /> 
<asp:HiddenField runat="server" ID="hidSupplyMoney" />    
<asp:HiddenField runat="server" ID="hidTradeNo" />    
<asp:HiddenField runat="server" ID="hiddenCheck" />    
<asp:HiddenField runat="server" ID="hiddenCheckStff" /> 
<asp:HiddenField runat="server" ID="hiddenCheckDept" />   

  <asp:HiddenField runat="server" ID="hidWarning" />
  <asp:HiddenField runat="server" ID="hidAccRecv" />
  <asp:HiddenField runat="server" ID="hidTradeTypeCode" />
  <asp:HiddenField runat="server" ID="hidOtherFee"  Value="0"/>
  <asp:HiddenField runat="server" ID="hidCardPost"  Value="0"/>
  <asp:HiddenField runat="server" ID="hidDeposit"   Value="0"/>

  <asp:HiddenField runat="server" ID="hidNewCardType" />
  <asp:HiddenField runat="server" ID="hidMonthlyType" />
  <asp:HiddenField runat="server" ID="hidStartTime" />
  <asp:HiddenField runat="server" ID="hidServiceMoney" />
  <asp:HiddenField runat="server" ID="hidSERSTAKETAG" />
  <asp:HiddenField runat="server" ID="hidLockFlag" />
  <asp:HiddenField runat="server" ID="hidCardReaderToken" />  
  <asp:HiddenField runat="server" ID="hidZJGMonthlyFlag" />
  <asp:LinkButton runat="server" ID="btnConfirm" OnClick="btnConfirm_Click"/></tr>
  <tr>
    <td><div align="right">折旧开始:</div></td>
    <td><asp:TextBox ID="txtOldStartDate" CssClass="labeltext" runat="server" /></td>
    <td><div align="right">旧卡余额:</div></td>
    <td><asp:TextBox ID="txtOldCardBalance" CssClass="labeltext" runat="server" /></td>
    <td><div align="right">旧卡状态:</div></td>
    <td><asp:TextBox ID="txtOldCardState" CssClass="labeltext" runat="server" /></td>
    <td><asp:Button ID="btnReadCard" Text="读旧卡" CssClass="button1" runat="server" 
        OnClientClick="return ReadZJGMonthlyCardInfo('txtOldCardNo')" OnClick="btnReadCard_Click"/></td>
    <td><asp:Button ID="btnReadDb" Enabled="false" Text="读数据库" CssClass="button1" runat="server"
    	  OnClientClick="return warnCheck()"/></td>
  </tr>
</table>

 </div>
  <div class="pip">新卡信息</div>
  <div class="kuang5">
 <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
  <tr>
    <td width="10%"><div align="right">新卡卡号:</div></td>
    <td width="13%"><asp:TextBox ID="txtNewCardNo" MaxLength="16" CssClass="labeltext" runat="server" /></td>
    <td width="9%"><div align="right">新卡类型:</div></td>
    <td width="13%"><asp:TextBox ID="txtNewcChangeType" CssClass="labeltext" runat="server"  /></td>
    <td width="9%"><div align="right">新卡押金:</div></td>
    <td width="13%"><asp:TextBox ID="txtNewCardDeposit" CssClass="labeltext" runat="server"/>
    </td>
    <td width="9%">&nbsp;</td>
    <td width="24%">
    &nbsp;
     </td>
    </tr>
  <tr>
    <td><div align="right">启用日期:</div></td>
    <td><asp:TextBox ID="txtNewStartDate" CssClass="labeltext" runat="server" /></td>
    <td><div align="right">新卡余额:</div></td>
    <td><asp:TextBox ID="txtNewCardBalance" CssClass="labeltext" runat="server" /></td>
    <td><div align="right">新卡状态:</div></td>
    <td><asp:TextBox ID="txtNewCardState" CssClass="labeltext" runat="server" /></td>
    <td><asp:Button ID="btnReadNewCard" Text="读新卡" CssClass="button1" runat="server"  Enabled="false"
        OnClientClick="return ReadParkCardInfo('txtNewCardNo')" OnClick="btnReadNewCard_Click"/></td>
    <td>&nbsp;</td>
  </tr>
</table>
 </div>

  <div class="pip">用户信息</div>
  <div class="kuang5">
 <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
   <tr>
    <td width="10%"><div align="right">月票类型:</div></td>
    <td width="13%">
        <asp:TextBox runat="server" ID="labMonthlyCardType" CssClass="labeltext"/>
    </td>
     <td width="9%"><div align="right">客户性别:</div></td>
    <td width="13%">
         <asp:DropDownList ID="selCustSex" CssClass="input" runat="server">
        </asp:DropDownList><span class="red">*</span>  </td>
    <td width="9%"><div align="right">&nbsp;</div></td>
    <td  colspan="3">
        &nbsp; </td>
 </tr>
  <tr>
    <td align="right">用户姓名:</td>
    <td><asp:Label ID="txtCustName"  runat="server" /></td>
    <td align="right">证件类型:</td>
    <td><asp:Label ID="selPaperType"  runat="server"/></td>
    <td align="right">证件号码:</td>
    <td><asp:Label ID="txtPaperNo" runat="server" /></td>
  </tr>
 </table>
 </div></div>
 <div class="basicinfo">
 <div class="money">费用信息</div>
 <div class="kuang5">
   <asp:GridView ID="gvResult" runat="server"
        Width = "100%"
        CssClass="tab1"
        HeaderStyle-CssClass="tabbt"
        AlternatingRowStyle-CssClass="tabjg"
        SelectedRowStyle-CssClass="tabsel"
        AutoGenerateColumns="False"
       >
           <Columns>
               <asp:BoundField ItemStyle-Width="50%" HeaderText="费用项目" DataField="FEETYPENAME"/>
                <asp:BoundField ItemStyle-Width="50%" HeaderText="费用金额" DataField="BASEFEE"/>
           </Columns>           
    </asp:GridView>
 </div>
 </div>
 <div class="pipinfo">
 <div class="info">收款信息</div>
 <div class="kuang5">
 <div class="bigkuang">
 <div class="left">
 <img src="../../Images/show-sale.JPG" /></div>
  <div class="big">
  <table width="150" border="0" cellpadding="0" cellspacing="0" class="text25">
      <tr>
        <td colspan="2">&nbsp;</td>
        </tr>
      
      <tr>
        <td width="50%" align="right"><label>本次实收:&nbsp;</label></td>
        <td width="50%"><asp:TextBox ID="txtRealRecv" CssClass="inputshort" runat="server" MaxLength="9"/></td>
      </tr>
      <tr>
        <td align="right">本次应找:&nbsp;</td>
        <td><div id="txtChanges">0.00</div></td>
      </tr>
      <tr>
        <td colspan="2" class="red">&nbsp;</td>
      </tr>
      <tr>
        <td colspan="2" class="red">&nbsp;</td>
      </tr>
    </table>
  </div>
  </div>
 </div>
</div>


 <div class="footall"></div>
<div class="btns">
     <table width="300" align="right" border="0"cellpadding="0" cellspacing="0">
  <tr>
    <td><asp:Button ID="btnPrintPZ" runat="server" Text="打印凭证" 
        CssClass="button1" Enabled="false" OnClientClick="printdiv('ptnPingZheng1')" /></td>
    <td><asp:Button ID="btnPrintSJ" runat="server" Text="打印收据" 
        CssClass="button1" Enabled="false" OnClientClick="printdiv('ptnShouJu1')"/></td>
    <td ><asp:Button ID="btnSubmit" Enabled="false" CssClass="button1" runat="server" Text="提交" 
        OnClick="btnSubmit_Click"/></td>
  </tr>
</table>
<asp:CheckBox ID="chkPingzheng" runat="server"  Text="自动打印凭证"  Checked="true"/>
<asp:CheckBox ID="chkShouju" runat="server" Text="自动打印收据"/>

</div>  
                </ContentTemplate>
        </asp:UpdatePanel>
    </form>
</body>
</html>

<%@ Page Language="C#" AutoEventWireup="true" CodeFile="AS_GardenCardNew.aspx.cs" Inherits="ASP_AddtionalService_AS_GardenCardNew" EnableEventValidation="false" ValidateRequest="false"%>
<%@ Register Src="../../CardReader.ascx" TagName="CardReader" TagPrefix="cr" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
    <title>园林开通</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <script type="text/javascript" src="../../js/print.js"></script>
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <script language="javascript" type="text/javascript">
        function showPic() {
            document.getElementById('BtnShowPic').click();
            return false;
        }

        function clearPic() {
            document.getElementById("hfPic").value = "";
            return true;
        }

        //金额选择
        function setGeneral() {
            $get('hidAccRecv').value = '120.00';
            $get('annualFee').innerHTML = '120.00';
            $get('txtRealRecv').value = '120';
            $get('txtChanges').innerHTML = (parseFloat($get('txtRealRecv').value) - parseFloat($get('hidAccRecv').value)).toFixed(2);
            $get('Total').innerHTML = (parseFloat($get('DepositFee').innerHTML) + parseFloat($get('ProcedureFee').innerHTML) + parseFloat($get('annualFee').innerHTML)).toFixed(2);
        }

        function setXXGeneral() {
            $get('hidAccRecv').value = '60.00';
            $get('annualFee').innerHTML = '60.00';
            $get('txtRealRecv').value = '60';
            $get('txtChanges').innerHTML = (parseFloat($get('txtRealRecv').value) - parseFloat($get('hidAccRecv').value)).toFixed(2);
            $get('Total').innerHTML = (parseFloat($get('DepositFee').innerHTML) + parseFloat($get('ProcedureFee').innerHTML) + parseFloat($get('annualFee').innerHTML)).toFixed(2);
        }

        function showImg(value) {
            var obj = window.document.getElementById("preview_size_fake");
            obj.src = value;
         }

    </script>
</head>
<body>
	<cr:CardReader id="cardReader" Runat="server"/>    

    <form id="form1" runat="server">
        <div class="tb">
            附加业务->园林年卡-开通
        </div>
        <ajaxToolkit:ToolkitScriptManager EnableScriptGlobalization="true" EnableScriptLocalization="true" ID="ScriptManager1" runat="server" />
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
    <td width="10%"><div align="right">用户卡号:</div></td>
    <td width="13%"><asp:TextBox ID="txtCardNo" CssClass="labeltext" runat="server" /></td>
    <td width="9%"><div align="right">卡片类型:</div></td>
    <td width="13%"><asp:Label ID="labCardType" CssClass="labeltext" runat="server" /></td>
    <td width="9%"><div align="right">卡内余额:</div></td>
    <td width="13%"><asp:TextBox ID="txtCardBalance" CssClass="labeltext" runat="server" /></td>
    <td width="9%">&nbsp;</td>
    <td width="24%"><asp:Button ID="btnReadCard" Text="读卡" CssClass="button1" runat="server" 
        OnClientClick="return clearPic() && readParkInfo();" OnClick="btnReadCard_Click"/></td>
  <asp:HiddenField runat="server" ID="hidCardReaderToken" /> 
  
  <asp:HiddenField runat="server" ID="hidWarning" />
  <asp:HiddenField runat="server" ID="hidAsn" />
  <asp:HiddenField runat="server" ID="hidTradeNo" />
  <asp:HiddenField runat="server" ID="hidAccRecv" />
  <asp:HiddenField runat="server" ID="hidParkInfo" />
  <asp:HiddenField runat="server" ID="hidForPaperNo" />
  <asp:HiddenField runat="server" ID="hidForPhone" />
  <asp:HiddenField runat="server" ID="hidForAddr" />
   <asp:HiddenField ID="hfPic" runat="server" />
  <asp:HiddenField ID="hidLockBlackCardFlag" runat="server" />
  <asp:HiddenField ID="hiddenDepositFee" runat="server" />
   <asp:HiddenField ID="hidProcedureFee" runat="server" />
   <asp:HiddenField ID="hiddenAnnualFee" runat="server" />
   
  <asp:LinkButton runat="server" ID="btnConfirm" OnClick="btnConfirm_Click"/>
  </tr>
  <tr>
    <td><div align="right">启用日期:</div></td>
    <td><asp:TextBox ID="txtStartDate" CssClass="labeltext" runat="server" /></td>
    <td><div align="right">园林到期:</div></td>
    <td><asp:Label ID="labGardenEndDate" CssClass="labeltext" runat="server" /></td>
    <td><div align="right">卡内次数:</div></td>
    <td><asp:Label ID="labUsableTimes" CssClass="labeltext" runat="server" /></td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
</table>

 </div>
  <div class="pip">用户信息</div>
  <div class="kuang5">
 <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
  <tr>
    <td width="10%"><div align="right">用户姓名:</div></td>
    <td width="13%"><asp:TextBox ID="txtCustName" CssClass="input" runat="server" MaxLength="50" /><span class="red">*</span></td>
    <td width="9%"><div align="right">出生日期:</div></td>
    <td width="13%"><asp:TextBox ID="txtCustBirth" CssClass="input" runat="server" MaxLength="8" /></td>
        <ajaxToolkit:CalendarExtender ID="FCalendar" runat="server" TargetControlID="txtCustBirth"
            Format="yyyyMMdd" />
    <td width="9%"><div align="right">证件类型:</div></td>
    <td width="13%" style="white-space: nowrap">
    <asp:DropDownList ID="selPaperType" CssClass="input" runat="server">
    </asp:DropDownList>
    <span class="red">*</span>
    </td>
    <td width="9%"><div align="right">证件号码:</div></td>
    <td width="24%" style="white-space: nowrap">
    <asp:TextBox ID="txtPaperNo" CssClass="inputmid" runat="server" MaxLength="20" /><span class="red">*</span>
     </td>
     <td width="12%" rowspan="3">
         <img src="~/Images/nom.jpg" runat="server" alt="" Width="60" Height="65" id="preview_size_fake"/>
     </td>
    </tr>
  <tr>
    <td><div align="right">用户性别:</div></td>
    <td>
        <asp:DropDownList ID="selCustSex" CssClass="input" runat="server">
        </asp:DropDownList>
    </td>
    <td><div align="right">联系电话:</div></td>
    <td>
         <asp:TextBox ID="txtCustPhone" CssClass="input" runat="server" MaxLength="20" />
    </td>
    <td><div align="right">邮政编码:</div></td>
    <td>
        <asp:TextBox ID="txtCustPost" CssClass="input" runat="server" MaxLength="6" />
    </td>
    <td><div align="right">联系地址:</div></td>
    <td>
        <asp:TextBox ID="txtCustAddr" CssClass="inputmid" runat="server" MaxLength="50" />
    </td>
    </tr>
  <tr>
    <td><div align="right">电子邮件:</div></td>
    <td>
        <asp:TextBox ID="txtEmail" CssClass="input" runat="server" MaxLength="30"/>
    </td>
    <td><div align="right">备注:</div></td>
    <td colspan="4">
        <asp:TextBox ID="txtRemark" CssClass="inputlong" runat="server" MaxLength="100"/>
    </td>  
    <td>
    <asp:Button ID="txtReadPaper" Text="读二代证" CssClass="button1" runat="server"
     OnClientClick="clearPic();readIDCard('txtCustName', 'selCustSex', 'txtCustBirth', 'selPaperType', 'txtPaperNo', 'txtCustAddr', 'hfPic');showPic();"/>
    &nbsp;<asp:Button ID="txtSearch" Text="查询" CssClass="button1" runat="server" 
            onclick="txtSearch_Click" />
            <asp:LinkButton ID="BtnShowPic"  runat="server" OnClick="BtnShowPic_Click" />

    </td>
    
  </tr>
  <tr>
  <td><div align="right">照片导入:</div></td>
    
    <td colspan="3"  id="tdFileUpload" runat="server">
      <asp:FileUpload ID="FileUpload1" runat="server" CssClass="inputlong" onchange="showImg(this.value)"/>
     </td>
     <td colspan="6" id="tdMsg" runat="server"  align="right" >
    <asp:Label ID="lblMsg" runat="server" Text="系统不存在照片，请尽快补录！" ForeColor="Red" ></asp:Label>
    </td>
  </tr>
  
  
</table>
 </div></div>
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
    <td>手续费</td>
    <td><asp:Label ID="ProcedureFee" runat="server" Text=""></asp:Label></td>
    </tr>
  <tr>
    <td>年费</td>
    <td><asp:Label ID="annualFee" runat="server" Text=""></asp:Label></td>
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
 <div class="info">收款信息</div>
 <div class="kuang5">
 <div class="bigkuang">
 <div class="left">
 <img src="../../Images/show-sale.JPG" /></div>
  <div class="big">
  <table width="170" border="0" cellpadding="0" cellspacing="0" class="text25">
      <tr>
        <td width="50%" align="right"><label>本次实收:&nbsp;</label></td>
        <td width="50%"><asp:TextBox ID="txtRealRecv" CssClass="inputshort" runat="server" MaxLength="9"/></td>
      </tr>
     <script type="text/javascript">
               function setChargeValue(chargeVal) {
                   $get('hidAccRecv').value=chargeVal;
                   changannualMoney($get('hidAccRecv'));
                   realRecvChanging($get(''));
                   return false;
               }
     </script>
      <tr>
        <td width="53%" align="left"><asp:RadioButton ID="radioGeneral" runat="server" GroupName="radio" Text="普通120元" onClick="return setGeneral();"/></td>
        <td width="47%" align="right"><asp:RadioButton ID="radioXXGeneral" runat="server" GroupName="radio" Text="低保60元" onClick="return setXXGeneral();"/></td>
      </tr>
      <tr>
        <td align="right">本次应找:&nbsp;</td>
        <td><div id="txtChanges" runat="server">0.00</div></td>
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
    <td><asp:Button ID="btnUpload" runat="server" Text="上传照片" 
        CssClass="button1" Enabled="false" OnClick="btnUpload_Click"/></td>
    <td ><asp:Button ID="btnSubmit" Enabled="false" CssClass="button1" runat="server" Text="提交" 
        OnClick="btnSubmit_Click"/></td>
  </tr>
</table>
<asp:CheckBox ID="chkPingzheng" runat="server"  Text="自动打印凭证"  Checked="true"/>
</div>  
    
    
       
                </ContentTemplate>
                       
        <Triggers>
        <asp:PostBackTrigger ControlID="btnUpload" />
        <asp:PostBackTrigger ControlID="BtnShowPic" />
        </Triggers>
        
        </asp:UpdatePanel>
    </form>
</body>
</html>

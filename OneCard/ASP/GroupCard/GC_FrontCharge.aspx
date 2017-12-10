<%@ Page Language="C#" AutoEventWireup="true" CodeFile="GC_FrontCharge.aspx.cs" Inherits="ASP_GroupCard_GC_FrontCharge" %>
<%@ Register Src="../../CardReader.ascx" TagName="CardReader" TagPrefix="cr" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
<title>前台充值</title>
<link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    
     <script type="text/javascript" src="../../js/print.js"></script>
     <link href="../../css/card.css" rel="stylesheet" type="text/css" />
     
  <script language="javascript">
  <!--
  function OpenPort()
  {     
        if(!MSComm1.PortOpen)
        {
            var  WshShell;
            var  keyValue;
        
            try{
                WshShell  =  new  ActiveXObject("WScript.Shell");
            }catch(ex)
            {
                alert("请调整IE的ActiveX安全级别");
                return false;
            }
            
            try
            {
                  
                 keyValue  =  WshShell.RegRead("HKEY_LOCAL_MACHINE\\SOFTWARE\\OneCard\\ComPort");

                if(keyValue == '' || keyValue.charCodeAt(0) < 49 || keyValue.charCodeAt(0) > 57)
                {
                    alert("请在【系统管理->本地参数管理】页面里，配置ComPort端口！"); 
                    return false;
                }
                
            }
            catch(ex)
            {
                alert("请在【系统管理->本地参数管理】页面里，配置ComPort端口！"); 
                return false;
            }
        
        
            try{
                MSComm1.CommPort = keyValue;
                MSComm1.PortOpen = true;
            }catch(ex)
            {
                alert("小键盘端口无法打开，请在【系统管理->本地参数管理】页面里，配置ComPort端口！");
                return false;
            }
            
        }
  }
  
  function ClosePort()
  {     
        if(MSComm1.PortOpen)
        {
            MSComm1.PortOpen = false;
        }
  }
  
  -->
  </script>
  
  <script ID="clientEventHandlersJS" language="javascript">   
  <!--
  function MSComm1_OnComm(){
        var fldWeight = $get("PassWD");
        var strInput;
        strInput = MSComm1.Input;
        if(strInput.charCodeAt(0) == 13)
        {
            ClosePort();
            alert("密码输入完毕");
        }else if(strInput.charCodeAt(0) == 8)
        {
            fldWeight.value = "";
        }else{
            fldWeight.value = fldWeight.value + strInput; 
        }
        fldWeight.focus();
        return false;
  }
  -->
  </script>
 <script language="javascript" FOR="MSComm1" EVENT="OnComm">
  MSComm1_OnComm();
 </script>
     
</head>
<body>
  <object classid="clsid:648A5600-2C6E-101B-82B6-000000000014" id="MSComm1" 
     codebase="MSCOMM32.OCX" type="application/x-oleobject"    width='0' height='0'>  
  <PARAM NAME="InputLen" VALUE="0">
  <param name="Rthreshold" value="1">
  <PARAM   NAME="Settings"   VALUE="1200,N,8,1">
  </object>   
  <cr:CardReader id="cardReader" Runat="server"/>    
    <form id="form1" runat="server">
<div class="tb">
企服卡->前台充值
</div>
          <ajaxToolkit:ToolkitScriptManager runat="Server" EnableScriptGlobalization="true"
            AsyncPostBackTimeout="600" EnableScriptLocalization="true" ID="ScriptManager2" />
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
            <ContentTemplate>
            <aspControls:PrintPingZheng ID="ptnPingZheng" runat="server" PrintArea="ptnPingZheng1" />
<asp:BulletedList ID="bulMsgShow" runat="server">
</asp:BulletedList>
<script runat="server" >public override void ErrorMsgShow(){ErrorMsgHelper(bulMsgShow);}</script>  
<div class="con">
  <div class="pip">输入密码</div>
  <div class="kuang5">
 <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text20">  
  <tr>
    <td width="11%"><div align="right">输入密码:</div></td>
    <td width="14%"><asp:TextBox ID="PassWD" CssClass="inputmid" TextMode=password maxlength="6" runat=server></asp:TextBox></td>
    <td width="40%"><asp:Label ID="ChangePw"  Visible=false ForeColor=red runat="server" Text="*该卡未修改过初始密码,请协助用户修改密码"></asp:Label></td>
    <td width="15%"><asp:Button ID="btnPassInput" runat="server" Text="小键盘输入密码" Width="100px" OnClientClick="return OpenPort()" CssClass="button1"  /></td>
    <td width="10%"></td>
  </tr>
</table>

 </div>
    </div>
<div class="con">
  <div class="card">卡片信息</div>
  <div class="kuang5">
 <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text20">
  <tr>
    <td width="11%"><div align="right">用户卡号:</div></td>
    <td width="14%"><asp:TextBox ID="txtCardno" CssClass="labeltext" maxlength="16" runat="server"></asp:TextBox></td>
    <asp:HiddenField ID="hiddentxtCardno" runat=server />
    <asp:HiddenField ID="hiddenAsn" runat="server" />
    <td width="11%"><div align="right">当前卡内余额:</div></td>
    <td width="14%"><asp:TextBox ID="cMoney" ReadOnly=true CssClass="labeltext" width=100 runat="server" Text=""></asp:TextBox></td>
    <asp:HiddenField ID="hiddenLabCardtype" runat="server" />
    <asp:HiddenField ID="hiddencMoney" runat=server />
    <asp:HiddenField ID="hiddensDate" runat="server" />
    <asp:HiddenField ID="hiddeneDate" runat=server />
    <asp:HiddenField ID="hiddenCorpNo" runat=server />
    <asp:HiddenField ID="hidIsJiMing" runat=server />
    <asp:HiddenField runat="server" ID="hidCardReaderToken" />
    <asp:HiddenField runat="server" ID="hidCardnoForCheck" /> 
    <td width="11%"><div align="right">卡片状态:</div></td>
    <td width="14%"><asp:TextBox ID="RESSTATE" CssClass="labeltext" width=100 runat="server"></asp:TextBox></td>
    <td width="25%">&nbsp;</td>
  </tr>
  <tr>
    <td><div align="right">可充金额:</div></td>
    <td><asp:TextBox ID="allowMoney" CssClass="labeltext" width=100 ReadOnly=true runat="server" Text=""></asp:TextBox></td>
    <td><div align="right">本次充值金额:</div></td>
    <td><asp:TextBox ID="Money" CssClass="input" MaxLength=8 runat="server"></asp:TextBox></td>
    <td>&nbsp;</td>
    
    <td>&nbsp;</td>
    <asp:HiddenField ID="hiddentradeno" runat=server />
    <asp:HiddenField ID="hiddenread" runat=server />
    <asp:HiddenField ID="hidWarning" runat=server />
    <asp:HiddenField runat="server" ID="hidSupplyMoney" />
    <asp:LinkButton runat="server" ID="btnConfirm" OnClick="btnConfirm_Click"/>
    <td><asp:Button ID="btnReadCard" CssClass="button1" runat="server" Text="读卡" 
        OnClientClick="return ReadCardInfo()" OnClick="btnReadCard_Click" /></td>
  </tr>
</table>

 </div>
  <div class="pip">用户信息</div>
  <div class="kuang5">
 <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text20">
  <tr>
    <td width="11%"><div align="right">用户姓名:</div></td>
    <td width="14%"><asp:Label ID="CustName" runat="server" Text=""></asp:Label></td>
    <td width="11%"><div align="right">出生日期:</div></td>
    <td width="14%"><asp:Label ID="CustBirthday" runat="server" Text=""></asp:Label></td>
    <td width="11%"><div align="right">证件类型:</div></td>
    <td width="14%"><asp:Label ID="Papertype" runat="server" Text=""></asp:Label></td>
    <td width="11%"><div align="right">证件号码:</div></td>
    <td width="14%" colspan="3"><asp:Label ID="Paperno" runat="server" Text=""></asp:Label></td>
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
    <td><div align="right">集团客户:</div></td>
    <td><asp:Label ID="CorpName" runat="server" Text=""></asp:Label></td>
    <td><div align="right"></div></td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td colspan="3">&nbsp;</td>
  </tr>
</table>

 </div>
</div>
<div class="con">
<div class="jieguo">充值历史</div>
 <div class="kuang5">
 <div class="gdtb" style="height:140">
 
 <asp:GridView ID="lvwSELFSUPPLYQuery" runat="server"
                    Width = "1000"
                    CssClass="tab1"
                    HeaderStyle-CssClass="tabbt"
                    AlternatingRowStyle-CssClass="tabjg"
                    SelectedRowStyle-CssClass="tabsel"
                    AllowPaging="True"
                    PageSize="10"
                    PagerSettings-Mode="NumericFirstLast"
                    PagerStyle-HorizontalAlign="left"
                    PagerStyle-VerticalAlign="Top"
                    AutoGenerateColumns="False">
                    <Columns>
                      <asp:BoundField DataField="DBPREMONEY"    HeaderText="允许充值金额" NullDisplayText="0" DataFormatString="{0:n}" HtmlEncode="false" />
                      <asp:BoundField DataField="TRADEMONEY"    HeaderText="充值金额" NullDisplayText="0" DataFormatString="{0:n}" HtmlEncode="false" />
                      <asp:BoundField DataField="PREMONEY"      HeaderText="卡内前金额" NullDisplayText="0" DataFormatString="{0:n}" HtmlEncode="false" />
                      <asp:BoundField DataField="CARDTRADENO"   HeaderText="卡交易号"/>
                      <asp:BoundField DataField="STAFFNAME"     HeaderText="充值员工"/>
                    </Columns>
               
                   <EmptyDataTemplate>
                   <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                     <tr class="tabbt">
                    <td>允许充值金额</td>
                    <td>充值金额</td>
                    <td>卡内前金额</td>
                    <td>卡交易号</td>
                    <td>充值员工</td>
                    </tr>
                   </table>
                  </EmptyDataTemplate>
                </asp:GridView>
                               
</div>
</div>

<div class="btns">
     <table width="200" border="0" align="right" cellpadding="0" cellspacing="0">
  <tr>
    <td><asp:Button ID="btnPrintPZ" runat="server" Text="打印凭证" CssClass="button1" Enabled="false"  OnClientClick="printdiv('ptnPingZheng1')"/></td>
    <td><asp:Button ID="btnSupply" CssClass="button1" Enabled=false runat="server" Text="充值" 
     OnClientClick="return checkMaxBalanceText('Money')" OnClick="btnSupply_Click" /></td>
  </tr>
</table>
<asp:CheckBox ID="chkPingzheng" runat="server" Checked="true" />自动打印凭证
</div>

            </ContentTemplate>          
        </asp:UpdatePanel>
    </form>
</body>
</html>

<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PB_Speload.aspx.cs" Inherits="ASP_PersonalBusiness_PB_Speload" EnableEventValidation="false"%>
<%@ Register Src="../../CardReader.ascx" TagName="CardReader" TagPrefix="cr" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
<title>特殊圈存</title>
        <link rel="stylesheet" type="text/css" href="../../css/frame.css" />

         <script type="text/javascript" src="../../js/print.js"></script>
         <link href="../../css/card.css" rel="stylesheet" type="text/css" />
</head>
<body>
			<cr:CardReader id="cardReader" Runat="server"/>    

    <form id="form1" runat="server">
    
    <div class="tb">
个人业务->特殊圈存
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
    <td width="10%"><div align="right">用户卡号:</div></td>
    <td width="13%"><asp:TextBox ID="txtCardno" CssClass="labeltext" maxlength="16" runat="server"></asp:TextBox></td>
    <td width="10%"><div align="right">卡序列号:</div></td>
    <td width="13%"><asp:TextBox ID="LabAsn" CssClass="labeltext" runat="server"></asp:TextBox></td>
    <td width="10%"><div align="right">卡片类型:</div></td>
    <td width="13%"><asp:TextBox ID="LabCardtype" CssClass="labeltext" runat="server"></asp:TextBox></td>
    <td width="10%">&nbsp;</td>
    <td width="11%">&nbsp;</td>
    <td width="10%">&nbsp;</td>
  </tr>
  <tr>
    <td><div align="right">启用日期:</div></td>
    <td><asp:TextBox ID="sDate" CssClass="labeltext" runat="server" Text=""></asp:TextBox></td>
    <td><div align="right">卡内余额:</div></td>
    <td><asp:TextBox ID="cMoney" CssClass="labeltext" runat="server"></asp:TextBox></td>
    <td><div align="right">卡片状态:</div></td>
    <td><asp:TextBox ID="RESSTATE" CssClass="labeltext" runat="server" Text=""></asp:TextBox></td>
    <td>&nbsp;</td>
    <asp:HiddenField ID="hiddenTradeid" runat=server />
    <asp:HiddenField ID="hiddentxtCardno" runat=server />
    <asp:HiddenField ID="hiddenAsn" runat="server" />
    <asp:HiddenField ID="hiddenLabCardtype" runat="server" />
    <asp:HiddenField ID="hiddensDate" runat="server" />
    <asp:HiddenField ID="hiddeneDate" runat="server" />
    <asp:HiddenField ID="hiddencMoney" runat=server />
    <asp:HiddenField ID="hiddentradeno" runat=server />
    <asp:HiddenField ID="hiddenread" runat=server />
    <asp:HiddenField ID="hidWarning" runat=server />
    <asp:HiddenField ID="hidIsJiMing" runat="server" />
    <asp:HiddenField runat="server" ID="hidSupplyMoney" />
    <asp:LinkButton runat="server" ID="btnConfirm" OnClick="btnConfirm_Click"/>
    <asp:HiddenField runat="server" ID="hidCardReaderToken" />
    <asp:HiddenField runat="server" ID="hidCardnoForCheck" /> 
    <td colspan="2"><asp:Button ID="btnReadCard" CssClass="button1" runat="server" Text="读卡" 
        OnClientClick="return ReadCardInfo()" OnClick="btnReadCard_Click" /></td>
  </tr>
</table>

 </div>

   <div class="pip" style="display: none">用户信息</div>
   <div class="kuang5" style="display: none">
     <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text20">
       <tr>
         <td width="10%"><div align="right">用户姓名:</div></td>
         <td width="13%"><asp:Label ID="CustName" runat="server" Text=""></asp:Label></td>
         <td width="10%"><div align="right">出生日期:</div></td>
         <td width="13%"><asp:Label ID="CustBirthday" runat="server" Text=""></asp:Label></td>
         <td width="10%"><div align="right">证件类型:</div></td>
         <td width="13%"><asp:Label ID="Papertype" runat="server" Text=""></asp:Label></td>
         <td width="8%"><div align="right">证件号码:</div></td>
         <td width="23%" colspan="3"><asp:Label ID="Paperno" runat="server" Text=""></asp:Label></td>
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
   <div class="jieguo">查询结果</div>
  <div class="kuang5">
    <div class="gdtb" style="height:130px">
      
      <asp:GridView ID="lvwSpeloadQuery" runat="server"
                    Width = 95%
                    CssClass="tab1"
                    HeaderStyle-CssClass="tabbt"
                    AlternatingRowStyle-CssClass="tabjg"
                    SelectedRowStyle-CssClass="tabsel"
                    AllowPaging="True"
                    PageSize="3"
                    PagerSettings-Mode="NumericFirstLast"
                    PagerStyle-HorizontalAlign="left"
                    PagerStyle-VerticalAlign="Top"
                    OnPageIndexChanging="lvwSpeloadQuery_Page"
                    AutoGenerateColumns="False"
                    OnSelectedIndexChanged="lvwSpeloadQuery_SelectedIndexChanged"
                    OnRowCreated="lvwSpeloadQuery_RowCreated">
                    <Columns>
                    <asp:BoundField DataField="TRADEID" Visible=false HeaderText="交易序号"/>
                      <asp:BoundField DataField="CARDNO"       HeaderText="卡号"/>
                      <asp:BoundField DataField="TRADEMONEY"      HeaderText="交易金额" NullDisplayText="0" DataFormatString="{0:n}" HtmlEncode="false" />
                      <asp:BoundField DataField="TRADETIMES"       HeaderText="交易笔数"/>
                      <asp:BoundField  DataFormatString="{0:yyyy-MM-dd}" DataField="TRADEDATE" HeaderText="交易日期" />
                      <asp:BoundField  DataFormatString="{0:yyyy-MM-dd}" DataField="INPUTTIME" HeaderText="录入时间" />
                      <asp:BoundField DataField="INPUTSTAFF"       HeaderText="录入员工"/>
                      <asp:BoundField DataField="REMARK"       HeaderText="备注说明" />    
                    </Columns>     
               
                   <EmptyDataTemplate>
                   <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                     <tr class="tabbt">
                        <td>卡号</td>
                          <td>交易金额</td>
                          <td>交易笔数</td>
                          <td>交易日期</td>
                          <td>录入时间</td>
                          <td>录入员工</td>
                          <td>备注说明</td>
                    </tr>
                   </table>
                  </EmptyDataTemplate>
    </asp:GridView>
        
    </div>
  </div>
    <div class="card">详细信息</div>
    <div class="kuang5">
 <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text20">
 <tr>
    <td width="10%"><div align="right">用户卡号:</div></td>
    <td width="13%"><asp:Label ID="CardNo" runat="server" Text=""></asp:Label></td>
    <td width="10%"><div align="right">圈存金额:</div></td>
    <td width="13%"><asp:Label ID="labSpeload" runat="server" Text=""></asp:Label></td>
    <td width="10%"><div align="right">录入员工:</div></td>
    <td width="13%"><asp:Label ID="labStaff" runat="server" Text=""></asp:Label></td>
    <td width="10%"><div align="right">录入时间:</div></td>
    <td width="20%"><asp:Label ID="labInputtime" runat="server" Text=""></asp:Label></td>
    <td width="1%">&nbsp;</td>
  </tr>
  <tr>
    <td width="12%"><div align="right">备注说明:</div></td>
    <td width="11%"><asp:Label ID="labRemark" runat="server" Text=""></asp:Label></td>
  </tr>
</table>

 </div>
</div>
  
<div>
  <div class="footall"></div>
</div>

<div class="btns">
     <table width="200" border="0" align="right" cellpadding="0" cellspacing="0">
  <tr>
  <td><asp:Button ID="btnPrintPZ" runat="server" Text="打印凭证" CssClass="button1" Enabled="false"  OnClientClick="printdiv('ptnPingZheng1')" /></td>
    <td><asp:Button ID="btnSpsload" CssClass="button1" runat="server" Text="圈存" Enabled=false 
        OnClick="btnSpsload_Click" /></td>
  </tr>
</table>
<td><asp:CheckBox ID="chkPingzheng" runat="server" Checked="true" />自动打印凭证</td>
</div>
</ContentTemplate>          
        </asp:UpdatePanel>
    </form>
</body>
</html>

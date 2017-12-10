<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PB_Recover.aspx.cs" Inherits="ASP_PersonalBusiness_PB_Recover" EnableEventValidation="false" %>
<%@ Register Src="../../CardReader.ascx" TagName="CardReader" TagPrefix="cr" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
<title>抹帐</title>
<link rel="stylesheet" type="text/css" href="../../css/frame.css" />

     <link href="../../css/card.css" rel="stylesheet" type="text/css" />
</head>
<body>
	<cr:CardReader id="cardReader" Runat="server" />    

    <form id="form1" runat="server">
<div class="tb">
个人业务->抹帐
</div>
<ajaxToolkit:ToolkitScriptManager runat="Server" EnableScriptGlobalization="true"
            EnableScriptLocalization="true" ID="ToolkitScriptManager1" />
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
  <div class="card">卡片信息</div>
  <div class="kuang5">
 <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text20">
  <tr>
    <td width="11%"><div align="right">用户卡号:</div></td>
    <td width="13%"><asp:TextBox ID="txtCardno" CssClass="labeltext" maxlength="16" runat="server"></asp:TextBox></td>
    <td width="9%"><div align="right">卡序列号:</div></td>
    <td width="13%"><asp:TextBox ID="LabAsn" CssClass="labeltext" runat="server"></asp:TextBox></td>
    <td width="9%"><div align="right">卡片类型:</div></td>
    <td width="13%"><asp:TextBox ID="LabCardtype" CssClass="labeltext" runat="server"></asp:TextBox></td>
    <td width="9%"><div align="right">卡片状态:</div></td>
    <td width="9%"><asp:TextBox ID="RESSTATE" CssClass="labeltext" runat="server"></asp:TextBox></td>
    <td width="11%"><asp:Button ID="btnReadCard" CssClass="button1" runat="server" Text="读卡" 
        OnClientClick="return ReadCardInfo()" OnClick="btnReadCard_Click" /></td>
  </tr>
  <tr>
    <td><div align="right">启用日期:</div></td>
    <td><asp:TextBox ID="sDate" CssClass="labeltext" runat="server" Text=""></asp:TextBox></td>
    <td><div align="right" style="display: none">结束日期:</div></td>
    <td><asp:TextBox ID="eDate" CssClass="labeltext" Visible="False" runat="server" Text=""></asp:TextBox></td>
    <td><div align="right">卡内余额:</div></td>
    <td><asp:TextBox ID="cMoney" CssClass="labeltext" runat="server" Text=""></asp:TextBox></td>
    <td>&nbsp;</td>
    <td colspan="2">&nbsp;</td>
  </tr>
  <tr>
    <td><div align="right">开通功能:</div></td>
    <td colspan="8">
        <aspControls:OpenFunc ID ="openFunc" runat="server" />
    </td>
    </tr>
</table>

 </div>
  <div class="pip" style="display: none">用户信息</div>
  <div class="kuang5" style="display: none">
 <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text20">
  <tr>
  <asp:HiddenField ID="hiddentxtCardno" runat=server />
  <asp:HiddenField ID="hiddenread" runat=server />
  <asp:HiddenField ID="hiddenAsn" runat=server />
  <asp:HiddenField ID="hiddensDate" runat=server />
  <asp:HiddenField ID="hiddeneDate" runat=server />
  <asp:HiddenField ID="hiddenLabCardtype" runat=server />
  <asp:HiddenField ID="hiddencMoney" runat=server />
  <asp:HiddenField ID="hiddentradeno" runat=server />
  <asp:HiddenField ID="hiddenSupplyid" runat=server />
  <asp:HiddenField ID="hidUnSupplyMoney" runat="server" />
  <asp:HiddenField ID="hidWarning" runat=server />
  <asp:HiddenField ID="hidPREMONEY" runat="server" />
  <asp:HiddenField ID="hidCardtradeno" runat="server" />
  <asp:HiddenField ID="hidNextCardtradeno" runat="server" />
  <asp:LinkButton runat="server" ID="btnConfirm" OnClick="btnConfirm_Click"/>
  <asp:HiddenField runat="server" ID="hidCardReaderToken" />
  <asp:HiddenField ID="hidDBMoney" runat="server" />
  <asp:HiddenField ID="hidCANCELTAG" runat="server" />
    <td width="11%"><div align="right">用户姓名:</div></td>
    <td width="13%"><asp:Label ID="CustName" runat="server" Text=""></asp:Label></td>
    <td width="9%"><div align="right">出生日期:</div></td>
    <td width="13%"><asp:Label ID="CustBirthday" runat="server" Text=""></asp:Label></td>
    <td width="9%"><div align="right">证件类型:</div></td>
    <td width="13%"><asp:Label ID="Papertype" runat="server" Text=""></asp:Label></td>
    <td width="9%"><div align="right">证件号码:</div></td>
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
</div>
<div class="con"><table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
  <tr>
    <td width="19%"> <div class="Condition">充值查询</div></td>
    <td width="22%">起始日期:<asp:Label ID="beginDate" runat=server></asp:Label></td>
    <td width="17%">终止日期:<asp:Label ID="endDate" runat=server></asp:Label></td>
    <td width="42%"><asp:Button ID="btnQuery" CssClass="button1" runat="server" Text="查询" Enabled=false OnClick="btnQuery_Click" /></td>
  </tr>
</table>
</div>
<div class="pipinfo2">
<div class="history">充值历史</div>
 <div class="kuang5">
    <div style="height:171px">
    <asp:GridView ID="lvwSupplyQuery" runat="server"
                    Width = 95%
                    CssClass="tab1"
                    HeaderStyle-CssClass="tabbt"
                    AlternatingRowStyle-CssClass="tabjg"
                    SelectedRowStyle-CssClass="tabsel"
                    AllowPaging="True"
                    PageSize="5"
                    PagerSettings-Mode="NumericFirstLast"
                    PagerStyle-HorizontalAlign="left"
                    PagerStyle-VerticalAlign="Top"
                    OnPageIndexChanging="lvwSupplyQuery_Page"
                    AutoGenerateColumns="False"
                    OnRowDataBound ="lvwSupplyQuery_RowDataBound">
                    <Columns>
                      <asp:BoundField DataField="ID"       HeaderText="序号"/>
                      <asp:BoundField DataField="TRADETYPE"       HeaderText="交易类型"/>
                      <asp:BoundField DataField="SUPPLYMONEY"      HeaderText="交易金额" NullDisplayText="0" DataFormatString="{0:n}" HtmlEncode="false" />
                      <asp:BoundField DataField="PREMONEY"        HeaderText="交易前金额" NullDisplayText="0" DataFormatString="{0:n}" HtmlEncode="false"/>
                      <asp:BoundField  DataFormatString="{0:yyyy-MM-dd}" DataField="OPERATETIME" HeaderText="交易日期" />
                      <asp:BoundField DataField="STAFFNAME"       HeaderText="充值员工" /> 
                      <asp:BoundField DataField="Cardtradeno"       HeaderText="充值前卡交易序号" />
                      <asp:BoundField DataField="NextCardtradeno"       HeaderText="充值后卡交易序号" /> 
                      <asp:BoundField DataField="CANCELTAG"       HeaderText="后退标志" />    
                    </Columns>     
               
                   <EmptyDataTemplate>
                   <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                     <tr class="tabbt">
                        <td>序号</td>
                        <td>交易类型</td>
                        <td>交易金额</td>
                        <td>交易前金额</td>
                        <td>交易时间</td>
                    </tr>
                   </table>
                  </EmptyDataTemplate>
    </asp:GridView>
   </div>          
</div>

<%-- <div class="base">最后交易信息</div>
    <div class="kuang5">
    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="tab1">
  <tr class="tabbt">
    <td>交易号</td>
    <td>交易类型</td>
    <td>交易金额</td>
    <td>交易日期</td>
    <td>交易时间</td>
    <td>交易终端</td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
</table>
</div>--%> 
</div>
<div class="basicinfo2">
  <div class="info">抹帐信息</div>
   <div class="kuang5">
<div class="bigtable" style="height:171px">
  <table border="0" cellpadding="0" cellspacing="0" class="text25">
    <tr>
      <td><div align="right">充值金额:</div></td>
      <td><asp:Label ID="SupplyMoney" runat=server Text=""></asp:Label></td>
    </tr>
    <tr>
      <td><div align="right">充值员工:</div></td>
      <td><asp:Label ID="StaffName" runat=server Text=""></asp:Label></td>
    </tr>
    <tr>
      <td><div align="right">充值日期:</div></td>
      <td><asp:Label ID="SupplyDate" runat=server Text=""></asp:Label></td>
    </tr>

    <tr>
      <td colspan="2"><span class="red">抹帐金额:</span></td>
      </tr>
    <tr>
      <td colspan="2"><asp:Label ID="reCoverMoney" Text="" runat=server></asp:Label></td>
      </tr>
  </table>
</div>
 </div>
</div>
<div>
  <div class="footall"></div>
</div>

<div class="btns">
     <table width="100" border="0" align="right" cellpadding="0" cellspacing="0">
  <tr>
    <td><asp:Button ID="btnRecover" CssClass="button1" runat="server" Text="抹帐" Enabled=false OnClick="btnRecover_Click" /></td>
  </tr>
</table>

</div>
    
    </ContentTemplate>          
        </asp:UpdatePanel>
        </form>
</body>
</html>

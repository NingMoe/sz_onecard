<%@ Page Language="C#" AutoEventWireup="true" CodeFile="AS_MonthCardRetrade.aspx.cs" Inherits="ASP_AddtionalService_AS_MonthCardRetrade" EnableEventValidation="false" %>
<%@ Register Src="../../CardReader.ascx" TagName="CardReader" TagPrefix="cr" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
<title>月票补写卡</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />

    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
</head>
<body>
	<cr:CardReader id="cardReader" Runat="server" />    

    <form id="form1" runat="server">
    <div class="tb">
附加业务->月票-补写卡
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
<asp:BulletedList ID="bulMsgShow" runat="server">
</asp:BulletedList>
<script runat="server" >public override void ErrorMsgShow(){ErrorMsgHelper(bulMsgShow);}</script>  
<div class="con">
  <div class="base">卡信息查询</div>
  <div class="kuang5">
 <table width="95%" border="0" cellpadding="0" cellspacing="0" class="12text">
  <tr>
    <td width="9%"><div align="right">卡号:</div></td>
    <td width="12%"><asp:TextBox ID="txtCardno" CssClass="labeltext" maxlength="16" runat="server"></asp:TextBox></td>
    <td width="12%"><div align="right">启用日期:</div></td>
    <td width="11%"><asp:TextBox ID="sDate" CssClass="labeltext" runat="server" Text=""></asp:TextBox></td>
    <td width="9%"><div align="right">卡类型:</div></td>
    <td width="10%"><asp:TextBox ID="LabCardtype" CssClass="labeltext" runat="server"></asp:TextBox></td>
    <td width="12%"><div align="right">卡内余额:</div></td>
    <td width="10%"><asp:TextBox ID="cMoney" CssClass="labeltext" runat="server" Text=""></asp:TextBox></td>
    <td width="16%"><asp:Button ID="btnReadCard" CssClass="button1" runat="server" Text="读卡" 
    OnClientClick="return ReadCardInfoForRe()" OnClick="btnReadCard_Click" /></td>
    </tr>
  <tr>
    <td><div align="right">&nbsp;</div></td>
    <td>

    </td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
</table>
<asp:HiddenField runat="server" ID="hidWriteCardFailInfo" /> 
<asp:HiddenField ID="hiddenTradeNum" runat="server" />
<asp:HiddenField ID="hiddenread" runat=server />
<asp:HiddenField ID="hiddentxtCardno" runat=server />
<asp:HiddenField ID="hiddenAsn" runat=server />
<asp:HiddenField ID="hiddenLabCardtype" runat=server />
<asp:HiddenField ID="hiddensDate" runat=server />
<asp:HiddenField ID="hiddeneDate" runat=server />
<asp:HiddenField ID="hiddencMoney" runat=server />
<asp:HiddenField ID="hidSupplyMoney" runat="server" />
<asp:HiddenField ID="hiddentradeno" runat=server />
<asp:HiddenField ID="hidWarning" runat=server />
<asp:LinkButton runat="server" ID="btnConfirm" OnClick="btnConfirm_Click"/>
<asp:HiddenField ID="hidCardtradeno" runat="server" />
<asp:HiddenField ID="hiddenTRADETYPECODE" runat=server />
<asp:HiddenField ID="hiddenOPERATETIME" runat=server />
<asp:HiddenField ID="hiddenID" runat=server />
<asp:HiddenField ID="hiddenlOldMoney" runat=server />
<asp:HiddenField runat="server" ID="hidCardReaderToken1" />
<asp:HiddenField ID="hidStaffNo" runat="server" />
<asp:HiddenField ID="hidCarNo" runat="server" />
<asp:HiddenField ID="hidState" runat="server" />
<asp:HiddenField runat="server" ID="hidMonthlyFlag" />
<asp:HiddenField runat="server" ID="hidMonthlyUpgrade" />
  <asp:HiddenField runat="server" ID="hidMonthlyYearCheck" />
<asp:HiddenField runat="server" ID="hidMonthlyFlagYearCheck" />
<asp:HiddenField runat="server" ID="hidCardReaderToken" />
<asp:HiddenField runat="server" ID="hidMonthlyFlagChange" />
  <asp:HiddenField ID="hidOPERATENO" runat="server" />
  <asp:HiddenField ID="hidParkInfo" runat="server" />
  <asp:HiddenField ID="hidwriteCardScript" runat="server" />
   <asp:HiddenField ID="hidZJGMonthlyFlag" runat="server" />
   <asp:HiddenField runat="server" ID="hidCardnoForCheck" /> 
   <asp:HiddenField ID="hidUnSupplyMoney" runat="server" />
   <asp:HiddenField ID="hiddenShiPingTag" runat="server" />
   <asp:HiddenField ID="hidChargeMoney" runat="server" />
<asp:HiddenField runat="server" ID="HidYPFlag" />
 <asp:HiddenField runat="server" ID="HidPrivilege"/>
 <asp:HiddenField runat="server" ID="HidAppRange" />
 <asp:HiddenField runat="server" ID="HidYearInfo" />
 <asp:HiddenField runat="server" ID="HidPriIndex1" />
 <asp:HiddenField runat="server" ID="HidPriIndex2" />
 <asp:HiddenField runat="server" ID="HidPriIndex3" />
 <asp:HiddenField runat="server" ID="HidPriIndex4" />
 <asp:HiddenField runat="server" ID="HidPriIndex5" />
 <asp:HiddenField runat="server" ID="HidPriIndex6" />
 <asp:HiddenField runat="server" ID="HidCRCCheck" />
  </div>
  <div class="jieguo">查询信息</div>
  <div class="kuang5">
  <div class="gdtb" style="height:310px">
  
  <asp:GridView ID="lvwQuery" runat="server"
                    Width = 200%
                    CssClass="tab1"
                    HeaderStyle-CssClass="tabbt"
                    AlternatingRowStyle-CssClass="tabjg"
                    SelectedRowStyle-CssClass="tabsel"
                    AllowPaging="True"
                    PageSize="13"
                    PagerSettings-Mode="NumericFirstLast"
                    PagerStyle-HorizontalAlign="left"
                    PagerStyle-VerticalAlign="Top"
                    OnPageIndexChanging="lvwQuery_Page"
                    AutoGenerateColumns="False"
                    OnRowDataBound ="lvwQuery_RowDataBound">
                    <Columns>
                      <asp:BoundField DataField="TRADEID"       HeaderText="业务流水号"/>
                      <asp:BoundField DataField="TRADETYPE"       HeaderText="业务类型"/>
                      <asp:BoundField DataField="OPERATETIME" HeaderText="交易日期" />
                      <asp:BoundField DataField="strCardNo"       HeaderText="卡号"/>
                      <asp:BoundField DataField="lMoney"       HeaderText="发生金额" NullDisplayText="0" DataFormatString="{0:n}" HtmlEncode="false"/>
                      <asp:BoundField DataField="lOldMoney"       HeaderText="卡片原余额" NullDisplayText="0" DataFormatString="{0:n}" HtmlEncode="false"/>
                      <asp:BoundField DataField="strTermno"       HeaderText="终端号"/>
                      <asp:BoundField DataField="strEndDateNum"       HeaderText="年卡终止日期次数"/>
                      <asp:BoundField DataField="strFlag"       HeaderText="月票卡类型"/>
                      <asp:BoundField DataField="STAFFNAME"       HeaderText="操作员工" />
                      <asp:BoundField DataField="TRADETYPECODE"       HeaderText="业务类型编码" />
                      <asp:BoundField DataField="Cardtradeno" HeaderText="联机交易序号" />
                      <asp:BoundField DataField="writeCardScript" HeaderText="写卡函数" />
                      <asp:BoundField DataField="rsrv1"       HeaderText="备注1" />
                      <asp:BoundField DataField="rsrv2"       HeaderText="备注2" />
                       
                    </Columns>     
               
                   <EmptyDataTemplate>
                   <table width=2300 border="0" cellpadding="0" cellspacing="0" class="tab1">
                     <tr class="tabbt">
                        <td>业务流水号</td>
                        <td>业务类型</td>
                        <td>交易日期</td>
                        <td>卡号</td>
                        <td>发生金额</td>
                        <td>卡片原余额</td>
                        <td>终端号</td>
                        <td>年卡终止日期次数</td>
                        <td>月票卡类型</td>
                        <td>操作员工</td>
                    </tr>
                   </table>
                  </EmptyDataTemplate>
    </asp:GridView>
   </div>          
</div>

  </div>

<div class="btns">
     <table width="100" border="0" align="right" cellpadding="0" cellspacing="0">
  <tr>
    <td width="102"><asp:Button ID="Subcommit" CssClass="button1" Enabled=false runat=server Text="提交" OnClick="Subcommit_Click" /></td>
  </tr>
</table>

     </div>
     </ContentTemplate>          
        </asp:UpdatePanel>
    </form>
</body>
</html>


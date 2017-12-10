<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PB_TransitBalance.aspx.cs" Inherits="ASP_PersonalBusiness_PB_TransitBalance" %>
<%@ Register Src="../../CardReader.ascx" TagName="CardReader" TagPrefix="cr" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
<title>转值</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />

    <script type="text/javascript" src="../../js/print.js"></script>
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
</head>
<body>
	<cr:CardReader id="cardReader" Runat="server" />    
    <form id="form1" runat="server">
<div class="tb">
个人业务->转值
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
  <div class="card">新卡信息</div>
  <div class="kuang5">
    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text20">
   <tr>
     <td width="10%"><div align="right">新卡卡号:</div></td>
     <td width="13%"><asp:TextBox ID="txtCardno" CssClass="labeltext" runat="server"></asp:TextBox></td>
     <td width="9%"><div align="right">卡序列号:</div></td>
     <td width="13%"><asp:TextBox ID="LabAsn" CssClass="labeltext" runat="server"></asp:TextBox></td>
     <td width="9%"><div align="right">卡片类型:</div></td>
     <td width="13%"><asp:TextBox ID="LabCardtype" CssClass="labeltext" runat="server"></asp:TextBox></td>
     <td width="9%">&nbsp;</td>
     <td width="24%"><asp:Button ID="btnReadCard" CssClass="button1" runat="server" Text="读新卡" 
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
   <div class="card">旧卡信息</div>
  <div class="kuang5">
    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text20">
   <tr>
     <td width="10%"><div align="right">旧卡卡号:</div></td>
     <td width="13%"><asp:Label ID="txtOCardno" runat="server"></asp:Label></td>
     <td width="9%"><div align="right">换卡类型:</div></td>
     <td width="13%"><asp:Label ID="Reasontype" runat="server"></asp:Label></td>
     <td width="9%"><div align="right">换卡员工:</div></td>
     <td width="13%"><asp:Label ID="ChangeStaff" runat="server"></asp:Label></td>
     <td width="9%"><div align="right">换卡时间:</div></td>
     <td width="10%"><asp:Label ID="ChangeTime" runat="server"></asp:Label></td>
     <td width="7%">&nbsp;</td>
     <td width="7%">&nbsp;</td>
   </tr>
 </table>
 <asp:HiddenField ID="newCardNo" runat="server" />
   <asp:HiddenField ID="hiddenread" runat="server" />
   <asp:HiddenField ID="hiddenAsn" runat="server" />
   <asp:HiddenField ID="hiddenLabCardtype" runat="server" />
   <asp:HiddenField ID="hiddensDate" runat="server" />
   <asp:HiddenField ID="hiddeneDate" runat="server" />
   <asp:HiddenField ID="hiddencMoney" runat="server" />
   <asp:HiddenField ID="hiddentradeno" runat="server" />
   <asp:HiddenField ID="hidWarning" runat="server" />
   <asp:HiddenField ID="hidSupplyMoney" runat="server" />
   <asp:HiddenField ID="hidCustname" runat="server" />
   <asp:HiddenField ID="hidPaperno" runat="server" />
   <asp:HiddenField ID="hidPapertype" runat="server" />
   <asp:HiddenField ID="hidcardInMoney" runat="server" />
   <asp:LinkButton runat="server" ID="btnConfirm" OnClick="btnConfirm_Click"/>
   <asp:HiddenField ID="ChangeRecord" runat="server" />
   <asp:HiddenField runat="server" ID="hidCardReaderToken" />
    <asp:HiddenField runat="server" ID="hidCardnoForCheck" /> 
 </div>
  <div class="pip">未转值信息</div>
  <div class="kuang5">
   <div style="height:110px; overflow:auto">   
  <asp:GridView ID="lvwTransitQuery" runat="server"
            Width = "95%"
            CssClass="tab1"
            HeaderStyle-CssClass="tabbt"
            AlternatingRowStyle-CssClass="tabjg"
            SelectedRowStyle-CssClass="tabsel"
            AllowPaging="True"
            PageSize="5"
            PagerSettings-Mode="NumericFirstLast"
            PagerStyle-HorizontalAlign="left"
            PagerStyle-VerticalAlign="Top"
            OnPageIndexChanging="lvwTransitQuery_Page"
            AutoGenerateColumns="False"
            OnRowDataBound = "lvwTransitQuery_RowDataBound"
            >
            <Columns>
              <asp:BoundField DataField="OLDCARDNO"       HeaderText="旧卡卡号"/>
              <asp:BoundField DataField="CARDNO"       HeaderText="新卡卡号"/>  
              <asp:BoundField  DataFormatString="{0:yyyy-MM-dd}" DataField="OPERATETIME" HeaderText="换卡时间" />
              <asp:BoundField DataField="CARDACCMONEY"      HeaderText="未转值余额" NullDisplayText="0" DataFormatString="{0:n}" HtmlEncode="false" />
              <asp:BoundField DataField="TFLAG"       HeaderText="标志位"/>
              <asp:BoundField DataField="TRADEID"       HeaderText="TRADEID" />
      
            </Columns>     
       
           <EmptyDataTemplate>
           <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
             <tr class="tabbt">
                <td>旧卡卡号</td>
                <td>新卡卡号</td>
                <td>换卡时间</td>
                <td>未转值余额</td>
            </tr>
           </table>
          </EmptyDataTemplate>
    </asp:GridView>
  </div>
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
    <td>合计应收(退)</td>
    <td><asp:Label ID="Total" runat="server" Text=""></asp:Label></td>
  </tr>
</table>
 </div>
 </div>
 <div class="pipinfo">
 <div class="info">转值信息</div>
 <div class="kuang5">
 <div style="height:104px">
 <div class="left">
 <img src="../../Images/show.JPG" width="177" height="104" /></div>
  <div class="big">
  <table width="200" border="0" cellspacing="0" cellpadding="0">    
     <tr>
       <td width="320" colspan="2" class="red"><div align="center">当前转入新卡的余额为</div></td>
      </tr>
     <tr>
       <td colspan="2"><div align="center"><asp:Label ID="TransitBalance" runat="server" Text=""></asp:Label></div></td>
      </tr>
   </table>
  </div>
  </div>
 </div>
</div>
 <div class="footall"></div>
  <div class="footall"></div>
<div class="btns">
     <table width="200" border="0" align="right" cellpadding="0" cellspacing="0">
  <tr>
    <td><asp:Button ID="btnPrintPZ" runat="server" Text="打印凭证" CssClass="button1" Enabled="false"  OnClientClick="printdiv('ptnPingZheng1')" /></td>
    <td><asp:Button ID="Transit" CssClass="button1" runat="server" Text="转值" OnClick="Transit_Click" /></td>
  </tr>
</table>
<td><asp:CheckBox ID="chkPingzheng" runat="server" Checked="true" />自动打印凭证</td>
</div>
        </ContentTemplate>          
        </asp:UpdatePanel>
    </form>
</body>
</html>

<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PB_TransitBalance_Loss.aspx.cs" Inherits="ASP_PersonalBusiness_PB_TransitBalance_Loss" %>
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
个人业务->挂失卡转值

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
    <table width="98%" border="0" cellpadding="0" cellspacing="0" class="text20">
   <tr>
     <td width="9%" align="right"><div align="right">新卡卡号:</div></td>
     <td width="13%"><asp:TextBox ID="txtCardno" CssClass="labeltext" runat="server"></asp:TextBox></td>
     <td width="9%" align="right"><div align="right">卡片类型:</div></td>
     <td width="13%"><asp:TextBox ID="LabCardtype" CssClass="labeltext" runat="server"></asp:TextBox></td>
     <td width="9%"align="right"><div align="right">启用日期:</div></td>
     <td width="13%"><asp:TextBox ID="sDate" CssClass="labeltext" runat="server" Text=""></asp:TextBox></td>
     <td width="9%"align="right"><div align="right">卡内余额:</div></td>
     <td width="13%"><asp:TextBox ID="cMoney" CssClass="labeltext" runat="server" Text=""></asp:TextBox>
                <asp:TextBox ID="LabAsn" CssClass="labeltext" runat="server" Visible="false"></asp:TextBox></td>
     <td width="11%"  align="right"><asp:Button ID="btnReadCard" CssClass="button1" runat="server" Text="读新卡"  OnClientClick="return ReadCardInfo()" OnClick="btnReadCard_Click" /></td>
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
   <asp:LinkButton  ID="btnConfirm" runat="server" OnClick="btnConfirm_Click"/>
   <asp:HiddenField ID="ChangeRecord" runat="server" />
   <asp:HiddenField ID="hidCardReaderToken" runat="server"/>
   <asp:HiddenField ID="HiddenLossCardMoney" runat="server"/>
   <asp:HiddenField ID="HiddenTransitMoney" runat="server" />
   <asp:HiddenField runat="server" ID="hidoutTradeid" />
 </div>
 
 <div class="pip">用户信息</div>
  <div class="kuang5">
 <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text20">
  <tr>
    <td width="10%"><div align="right">用户姓名:</div></td>
    <td width="13%"><asp:Label ID="CustName" runat="server" Text=""></asp:Label></td>
    <td width="9%"><div align="right">出生日期:</div></td>
    <td width="13%"><asp:Label ID="CustBirthday" runat="server" Text=""></asp:Label></td>
    <td width="9%"><div align="right">证件类型:</div></td>
    <td width="13%"><asp:Label ID="Papertype" runat="server" Text=""></asp:Label></td>
    <td width="9%"><div align="right">证件号码:</div></td>
    <td width="24%" colspan="3"><asp:Label ID="Paperno" runat="server" Text=""></asp:Label></td>
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
 
 
 <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
     <tr>
        <td width="100" align="center"><div class="card">挂失卡信息</div></td>
        <td width="*" align="right">&nbsp;</td>
        <td width="60"><div align="right">查询条件:</div></td>
        <td width="460" align="right">
            <asp:DropDownList runat="server" ID="selQueryType">
                <asp:ListItem Selected="True" Text="01:卡号" Value="01"></asp:ListItem>
                <asp:ListItem Text="02:证件" Value="02"></asp:ListItem>
            </asp:DropDownList>
            <asp:TextBox ID="txtCondition" CssClass="inputlong" runat="server" MaxLength="20" Text=""/>
            <asp:Button ID="btnQuery" Text="查询" CssClass="button1" runat="server" OnClick="btnQuery_Click"/>
        </td>
    </tr>
   </table>
       
   
   
 <div class="kuang5">
   <div class="tab1" style="height:80px;overflow-y: scroll;" >
   <asp:GridView ID="gvLossOldCardInfo" runat="server"
        Width = "98%"
        CssClass="tab1"
        HeaderStyle-CssClass="tabbt"
        AlternatingRowStyle-CssClass="tabjg"
        SelectedRowStyle-CssClass="tabsel"
        AutoGenerateColumns="false"
        AutoGenerateSelectButton="True" 
        OnSelectedIndexChanged="gvLossOldCardInfo_SelectedIndexChanged" 
       >
           <Columns>
               <asp:BoundField ItemStyle-Width="15%" HeaderText="卡号" DataField="CARDNO"/>
               <asp:BoundField ItemStyle-Width="10%" HeaderText="挂失时间" DataField="LOSSDATE"/>
               <asp:BoundField ItemStyle-Width="15%" HeaderText="卡余额" DataField="CARDACCMONEY"/>
               <asp:BoundField ItemStyle-Width="15%" HeaderText="卡类型" DataField="CARDTYPENAME"/>
               <asp:BoundField ItemStyle-Width="10%" HeaderText="姓名" DataField="CUSTNAME"/>
               <asp:BoundField ItemStyle-Width="20%" HeaderText="证件号码" DataField="PAPERNO"/>
               <asp:BoundField ItemStyle-Width="10%" HeaderText="联系电话" DataField="CUSTPHONE"/>
            </Columns>   
            
            <EmptyDataTemplate>
                <table width="90%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                  <tr class="tabbt">
                  <td  width="10%">卡号</td>
                  <td width="10%">挂失日期</td>
                    <td width="10%">卡余额</td>
                    <td width="10%">卡类型</td>
                    <td width="10%">姓名</td>
                    <td width="10%">证件号码</td>
                    <td width="10%">联系电话</td>
                    </tr>
                  </table>
            </EmptyDataTemplate>
            
               
    </asp:GridView>
    
    
   
    
    </div>
 </div>
 


  <div class="pip">未转值信息</div>
  <div class="kuang5">
  <div style="height:60px;overflow-y: scroll;" >
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
     <table width="170" border="0" cellpadding="0" cellspacing="0" class="tab1">
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
 <div style="height:83px">
 <div class="left">
 <img src="../../Images/show.JPG" width="170" height="83" alt="" /></div>
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
    <td style="height: 21px"><asp:Button ID="btnPrintPZ" runat="server" Text="打印凭证" CssClass="button1" Enabled="false"  OnClientClick="printdiv('ptnPingZheng1')" /></td>
    <td style="height: 21px"><asp:Button ID="Transit" CssClass="button1" runat="server" Text="转值" OnClick="Transit_Click" /></td>
  </tr>
</table>
<td><asp:CheckBox ID="chkPingzheng" runat="server" Checked="true" />自动打印凭证</td>
</div>
        </ContentTemplate>          
        </asp:UpdatePanel>
    </form>
</body>
</html>

<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PB_B_Card_Query.aspx.cs" Inherits="ASP_PersonalBusiness_PB_B_Card_Query" %>
<%@ Register Src="../../CardReader.ascx" TagName="CardReader" TagPrefix="cr" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
<title>吴江B卡查询</title>
        <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
         <link href="../../css/card.css" rel="stylesheet" type="text/css" />
        <script type="text/javascript" src="../../js/print.js"></script>
     
</head>
<body>
	<cr:CardReader id="cardReader" Runat="server"/>    

    <form id="form1" runat="server">
<div class="tb">
个人业务->吴江B卡查询
</div>
<ajaxToolkit:ToolkitScriptManager runat="Server" EnableScriptGlobalization="true"
            AsyncPostBackTimeout="600" EnableScriptLocalization="true" ID="ScriptManager2" />
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
        <asp:UpdatePanel ID="UpdatePanel1" runat="server" RenderMode="inline">
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
    <td width="14%"><asp:TextBox ID="txtCardno" CssClass="input" maxlength="16" runat="server"></asp:TextBox></td>
    <td width="11%"><div align="right">余额:</div></td>
    <td width="14%"><asp:TextBox ID="cMoney" CssClass="labeltext" runat="server"></asp:TextBox></td>
    <td width="11%"><div align="right">卡片类型:</div></td>
    <td width="16%"><asp:TextBox ID="LabCardtype" CssClass="labeltext" runat="server"></asp:TextBox></td>

    <td width="23%"><asp:Button ID="btnReadCard" CssClass="button1" runat="server" Text="读卡" 
        OnClientClick="return ReadCardInfo()" OnClick="btnReadCard_Click" /></td>
  </tr>
  <tr>
    <td width="11%"><div align="right">启用日期:</div></td>
    <td width="14%"><asp:TextBox ID="sDate" CssClass="labeltext" runat="server" Text=""></asp:TextBox></td>
    <td width="11%"><div align="right" style="display: none">结束日期:</div></td>
    <td width="14%"><asp:TextBox ID="eDate" CssClass="labeltext" runat="server" Visible="False" Text=""></asp:TextBox></td>
    <td width="11%"><div align="right">卡片状态:</div></td>
    <td width="16%"><asp:TextBox ID="RESSTATE" CssClass="labeltext" runat="server" Text=""></asp:TextBox></td>

  </tr>
  <tr>
    <td style="height: 24px"><div align="right">首次消费时间:</div></td>
    <td style="height: 24px"><asp:Label ID="fConsumeTime" runat=server></asp:Label></td>
    <td style="height: 24px"><div align="right">首次充值时间:</div></td>
    <td style="height: 24px"><asp:Label ID="fSupplyTime" runat=server></asp:Label></td>
    <td style="height: 24px"><div align="right">总消费金额:</div></td>
    <td style="height: 24px"><asp:Label ID="tConsumeMoney" runat=server></asp:Label></td>

    <td style="height: 24px"><asp:Button ID="btnDBread" CssClass="button1" runat="server" Text="读数据库" OnClick="btnDBread_Click" /></td>
  </tr>
  <tr>
    <td><div align="right">最后消费时间:</div></td>
    <td><asp:Label ID="lConsumeTime" runat=server></asp:Label></td>
    <td><div align="right">最后充值时间:</div></td>
    <td><asp:Label ID="lSupplyTime" runat=server></asp:Label></td>
    <td><div align="right">总充值金额:</div></td>
    <td><asp:Label ID="tSupplyMoney" runat=server></asp:Label></td>

  </tr>
  <tr>
  <td><div align="right">售卡时间:</div></td>
  <td><asp:TextBox ID="txtSellTime" CssClass="labeltext" ReadOnly="true" runat="server" Text=""></asp:TextBox></td>
  <td><div align="right">卡押金:</div></td>
  <td><asp:TextBox ID="txtDeposit" CssClass="labeltext" ReadOnly="true" runat="server" Text=""></asp:TextBox></td>
  <td><div align="right">卡费:</div></td>
  <td><asp:TextBox ID="txtCardCost" CssClass="labeltext" ReadOnly="true" runat="server" Text=""></asp:TextBox></td>
  </tr>
  <asp:HiddenField ID="hiddenread" runat=server />
   <asp:HiddenField ID="hiddentxtCardno" runat=server />
   <asp:HiddenField ID="hiddentxtNCardno" runat=server />
   <asp:HiddenField ID="hiddenASn" runat=server />
   <asp:HiddenField ID="hiddenLabCardtype" runat=server />
   <asp:HiddenField ID="hiddensDate" runat=server />
   <asp:HiddenField ID="hiddeneDate" runat=server />
   <asp:HiddenField ID="hiddencMoney" runat=server />
   <asp:HiddenField ID="hiddentradeno" runat=server />
   <asp:HiddenField ID="hidTradeno" runat="server" />
   <asp:HiddenField ID="hidTradeMoney" runat="server" />
   <asp:HiddenField ID="hidTradeType" runat="server" />
   <asp:HiddenField ID="hidTradeTerm" runat="server" />
   <asp:HiddenField ID="hidTradeDate" runat="server" />
   <asp:HiddenField ID="hidTradeTime" runat="server" />
   <asp:HiddenField ID="hidread" runat="server" />
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
    <td width="11%"><div align="right">用户姓名:</div></td>
    <td width="14%"><asp:Label ID="CustName" runat="server" Text=""></asp:Label></td>
    <td width="11%"><div align="right">出生日期:</div></td>
    <td width="14%"><asp:Label ID="CustBirthday" runat="server" Text=""></asp:Label></td>
    <td width="11%"><div align="right">证件类型:</div></td>
    <td width="8%"><asp:Label ID="Papertype" runat="server" Text=""></asp:Label></td>
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
    <td valign="top"><div align="right">备注:</div></td>
    <td colspan="5"><asp:Label ID="Remark" runat="server" Text=""></asp:Label></td>
    </tr>
</table>

 </div>
</div>
<div class="con"><table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
  <tr>
    <td width="16%"> <div class="Condition">查询条件</div></td>
    <td width="24%">起始日期:
      <asp:TextBox ID="beginDate" CssClass="input" runat="server" maxlength="10"/>
    <ajaxToolkit:CalendarExtender ID="FCalendar" runat="server" TargetControlID="beginDate" Format="yyyyMMdd" /></td>
    <td width="24%">终止日期:
      <asp:TextBox ID="endDate" CssClass="input" runat="server" maxlength="10"/>
    <ajaxToolkit:CalendarExtender ID="CalendarExtender1" runat="server" TargetControlID="endDate" Format="yyyyMMdd" /></td>
    <td width="18%">
    <asp:DropDownList ID="selType" runat="server" CssClass="inputmid">
        <asp:ListItem Value="" Text="--选择查询类型--"></asp:ListItem>
        <asp:ListItem Value="QueryConsumeInfo" Text="查询库内消费信息"></asp:ListItem>
        <asp:ListItem Value="QueryChargeInfo" Text="查询库内充值信息"></asp:ListItem>
        <asp:ListItem Value="QueryCustBiz" Text="查询客户业务"></asp:ListItem>
        <asp:ListItem Value="SaveTempRecords" Text="查询卡内交易"></asp:ListItem>
        <asp:ListItem Value="QueryChangeCardHistory" Text="查询换卡历史"></asp:ListItem>
        <asp:ListItem Value="QueryReturnCardHistory" Text="查询退卡销户历史"></asp:ListItem>
    </asp:DropDownList></td>
    <td width="18%">&nbsp;</td>
  </tr>
</table>
</div>
<div class="con">
<div class="jieguo">
   <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
  <tr>
    <td width="16%"> <div class="Condition">查询结果</div></td>
    <td width="24%">&nbsp;</td>
    <td width="24%">&nbsp;</td>
    <td width="18%"><asp:Button ID="btnQuery" CssClass="button1" runat="server" Text="查询" 
    OnClick="btnQuery_Click" />
    &nbsp;
    <input type="submit" value="打印" onclick="return printGridView('printarea');" class="button1" />   
    </td>
  </tr>
</table>  
</div>
  <div id="printarea" class="kuang5">

 <asp:GridView ID="lvwQuery" runat="server"
                    Width = "95%"
                    CssClass="tab1"
                    HeaderStyle-CssClass="tabbt"
                    AlternatingRowStyle-CssClass="tabjg"
                    SelectedRowStyle-CssClass="tabsel"
                    PagerSettings-Mode="NumericFirstLast"
                    PageSize="200"
                    AllowPaging="True"
                    OnPageIndexChanging="lvwQuery_Page"
                    PagerStyle-HorizontalAlign="left"
                    PagerStyle-VerticalAlign="Top"
                    AutoGenerateColumns="true"
                    OnRowDataBound="lvwQuery_RowDataBound"
                    EmptyDataText="没有数据记录!" >
    </asp:GridView>
 </div>       
</div>
        </ContentTemplate>          
        </asp:UpdatePanel>
    </form>
</body>
</html>

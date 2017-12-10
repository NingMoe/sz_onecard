<%@ Page Language="C#" AutoEventWireup="true" CodeFile="AS_GardenCardAppend.aspx.cs" Inherits="ASP_AddtionalService_AS_GardenCardAppend" %>
<%@ Register Src="../../CardReader.ascx" TagName="CardReader" TagPrefix="cr" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <title>园林补写卡</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
     <script type="text/javascript" src="../../js/print.js"></script>
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
</head>
<body>
	<cr:CardReader id="cardReader" Runat="server"/>    

    <form id="form1" runat="server">
        <div class="tb">
            附加业务->园林年卡-查询/补写卡
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
 
        <asp:BulletedList ID="bulMsgShow" runat="server">
        </asp:BulletedList>
        <script runat="server" >public override void ErrorMsgShow(){ErrorMsgHelper(bulMsgShow);}</script>          

  <div class="con">
  <div class="card">卡片信息</div>
  <div class="kuang5">
 <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text20">
  <tr>
    <td width="10%"><div align="right">用户卡号:</div></td>
    <td width="13%"><asp:TextBox ID="txtCardNo" CssClass="input" runat="server" /></td>
    <td width="9%"><div align="right">园林到期:</div></td>
    <td width="13%"><asp:TextBox ID="labGardenEndDate" CssClass="labeltext" runat="server" /></td>
    <td width="9%"><div align="right">卡内次数:</div></td>
    <td width="13%"><asp:TextBox ID="labUsableTimes" CssClass="labeltext" runat="server" /></td>
    <td width="9%"><asp:Button ID="btnReadCard" Text="读卡" CssClass="button1" runat="server" 
        OnClientClick="return readParkInfo()" OnClick="btnReadCard_Click"/></td>
    <td width="24%">&nbsp;<asp:Button ID="btnReadDb" Text="读数据库" CssClass="button1" runat="server" 
        OnClick="btnReadDb_Click"/></td>
  
  <asp:HiddenField runat="server" ID="hidWarning" />
  <asp:HiddenField runat="server" ID="hidAsn" />
  <asp:HiddenField runat="server" ID="hidTradeNo" />
  <asp:HiddenField runat="server" ID="hidAccRecv" />
  <asp:HiddenField runat="server" ID="hidParkInfo" Value="FFFFFFFF01FF"/>
   <asp:HiddenField runat="server" ID="hidCardReaderToken" />  
  <asp:LinkButton runat="server" ID="btnConfirm" OnClick="btnConfirm_Click"/>
  </tr>
  <tr>
    <td><div align="right">开卡次数:</div></td>
    <td><asp:Label ID="labDbOpenTimes"  runat="server" /></td>
    <td><div align="right">库有效期:</div></td>
    <td><asp:Label ID="labDbExpDate"  runat="server" /></td>
    <td><div align="right">库内次数:</div></td>
    <td><asp:Label ID="labDbUsableTimes"  runat="server" /></td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td><div align="right">开通员工:</div></td>
    <td><asp:Label ID="labUpdateStaff"  runat="server" /></td>
    <td><div align="right">开通时间:</div></td>
    <td colspan="2"><asp:Label ID="labUpdateTime"  runat="server" /></td>
    <td>&nbsp;</td>
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
    <td width="13%"><asp:Label ID="txtCustName"  runat="server" /></td>
    <td width="9%"><div align="right">出生日期:</div></td>
    <td width="13%"><asp:Label ID="txtCustBirth"  runat="server" /></td>
    <td width="9%"><div align="right">证件类型:</div></td>
    <td width="13%">
    <asp:Label ID="selPaperType"  runat="server"/>
    </td>
    <td width="9%"><div align="right">证件号码:</div></td>
    <td width="24%">
    <asp:Label ID="txtPaperNo" runat="server" />
     </td>
    </tr>
  <tr>
    <td><div align="right">用户性别:</div></td>
    <td>
        <asp:Label ID="selCustSex" runat="server"/>
    </td>
    <td><div align="right">联系电话:</div></td>
    <td>
         <asp:Label ID="txtCustPhone" runat="server" />
    </td>
    <td><div align="right">邮政编码:</div></td>
    <td>
        <asp:Label ID="txtCustPost" runat="server" />
    </td>
    <td><div align="right">联系地址:</div></td>
    <td>
        <asp:Label ID="txtCustAddr" runat="server" />
    </td>
    </tr>
  <tr>
    <td><div align="right">电子邮件:</div></td>
    <td>
        <asp:Label ID="txtEmail"  runat="server"  />
    </td>
    <td><div align="right">备注:</div></td>
    <td colspan="4">
        <asp:Label ID="txtRemark"  runat="server"  />
    </td>
    <td>
    &nbsp;
    </td>
  </tr>
</table>

 </div>

<table width="100%" border="0" cellpadding="0" cellspacing="0" class="text25">
  <tr>
    <td width="12%"><div class="Condition">查询结果</div></td>
    <td width="11%"><div align="right">交易起始日期:</div></td>
    <td width="13%">
    <asp:TextBox runat="server" ID="txtFromDate" MaxLength="8" CssClass="input"/>
        <ajaxToolkit:CalendarExtender ID="FCalendar" runat="server" TargetControlID="txtFromDate"
            Format="yyyyMMdd" />
    </td>
    <td width="11%"><div align="right">交易终止日期:</div></td>
    <td width="13%">
    <asp:TextBox runat="server" ID="txtToDate" MaxLength="8"  CssClass="input"/>
    <ajaxToolkit:CalendarExtender ID="CalendarExtender1" runat="server" TargetControlID="txtToDate"
        Format="yyyyMMdd" />

    </td>
    <td width="9%"><div align="right">数据类型:</div></td>
    <td width="13%">
    <asp:DropDownList ID="selType" runat="server"  CssClass="input">
        <asp:ListItem Text="0:正常数据" Value="0"/>
        <asp:ListItem Text="1:异常数据" Value="1"/>
    </asp:DropDownList>
    </td>
    <td width="5%">&nbsp;</td>
    <td><asp:Button ID="btnQuery" CssClass="button1" runat="server" Text="查询" OnClick="btnQuery_Click"/></td>
  </tr>
</table>
<div class="kuang5">
<div class="gdtb" style="height:220px">
         <asp:GridView ID="gvResult" runat="server"
        Width = "98%"
        CssClass="tab1"
        HeaderStyle-CssClass="tabbt"
        AlternatingRowStyle-CssClass="tabjg"
        SelectedRowStyle-CssClass="tabsel"
        AllowPaging="True"
        PageSize="10"
        PagerSettings-Mode="NumericFirstLast"
        PagerStyle-HorizontalAlign="left"
        PagerStyle-VerticalAlign="Top"
        AutoGenerateColumns="False"
        OnRowDataBound="gvResult_RowDataBound"
        OnPageIndexChanging="gvResult_Page">
           <Columns>
               <asp:BoundField ItemStyle-Width="10%" HeaderText="POS号" DataField="POSNO"/>
               <asp:BoundField ItemStyle-Width="15%" HeaderText="SAM号" DataField="SAMNO"/>
                <asp:BoundField ItemStyle-Width="15%" HeaderText="交易日期" DataField="TRADEDATE"/>
                <asp:BoundField ItemStyle-Width="15%" HeaderText="交易时间" DataField="TRADETIME"/>
                <asp:BoundField ItemStyle-Width="15%" HeaderText="单位" DataField="CORP"/>
                <asp:BoundField ItemStyle-Width="10%" HeaderText="结算日期" DataField="DEALTIME"  DataFormatString="{0:yyyy-MM-dd}" HtmlEncode="False"/>
            </Columns>           
            <EmptyDataTemplate>
                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                  <tr class="tabbt">
                    <td width="10%">POS号</td>
                    <td width="15%">SAM号</td>
                    <td width="15%">交易日期</td>
                    <td width="15%">交易时间</td>
                    <td width="15%">单位</td>
                    <td width="10%">结算日期</td>
                  </tr>
                  </table>
            </EmptyDataTemplate>
        </asp:GridView>

  </div> 
</div>
</div>

 <div class="footall"></div>
<div class="btns">
     <table width="200" align="right" border="0"cellpadding="0" cellspacing="0">
  <tr>
    <td><asp:Button ID="btnPrintPZ" runat="server" Text="打印凭证" 
        CssClass="button1" Enabled="false" OnClientClick="printdiv('ptnPingZheng1')" /></td>
    <td ><asp:Button ID="btnSubmit" Enabled="false" CssClass="button1" runat="server" Text="提交" 
        OnClick="btnSubmit_Click"/></td>
  </tr>
</table>
<asp:CheckBox ID="chkPingzheng" runat="server"  Text="自动打印凭证" Checked="true" />

</div>  

        </ContentTemplate>
        </asp:UpdatePanel>
    </form>
</body>
</html>

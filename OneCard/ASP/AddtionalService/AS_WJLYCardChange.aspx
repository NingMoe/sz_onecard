<%@ Page Language="C#" AutoEventWireup="true" CodeFile="AS_WJLYCardChange.aspx.cs" Inherits="ASP_AddtionalService_AS_WJLYCardChange" EnableEventValidation="false"  %>
<%@ Register Src="../../CardReader.ascx" TagName="CardReader" TagPrefix="cr" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
     <title>吴江旅游年卡-补换卡</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
      <script type="text/javascript" src="../../js/print.js"></script>
   <link href="../../css/card.css" rel="stylesheet" type="text/css" />
</head>
<body>
	<cr:CardReader id="cardReader" Runat="server"/>    

    <form id="form1" runat="server">
        <div class="tb">
            附加业务->吴江旅游年卡-补换卡
        </div>
        <ajaxToolkit:ToolkitScriptManager EnableScriptGlobalization="true" EnableScriptLocalization="true" ID="ScriptManager1" runat="server"/>
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
           <asp:UpdatePanel ID="UpdatePanel1" runat="server" >
            <ContentTemplate>
       <aspControls:PrintPingZheng ID="ptnPingZheng" runat="server" PrintArea="ptnPingZheng1" />
   
    <asp:BulletedList ID="bulMsgShow" runat="server">
    </asp:BulletedList>
    <script runat="server" >public override void ErrorMsgShow(){ErrorMsgHelper(bulMsgShow);}</script>          
  

 <div class="pipinfo2">
 <div class="card">新卡信息</div>
 <div class="kuang5">
 <table width="100%" border="0" cellpadding="0" cellspacing="0" class="text20">
  <tr>
    <td width="10%"><div align="right">新卡卡号:</div></td>
    <td width="20%"><asp:TextBox ID="txtCardNo" CssClass="labeltext" runat="server" /></td>
    <td width="10%"><div align="right">卡内余额:</div></td>
    <td width="20%"><asp:TextBox ID="txtCardBalance" CssClass="labeltext" runat="server" /></td>
    <td width="10%">&nbsp;</td>
    <td width="20%">&nbsp;</td>
    <td width="10%"><asp:Button ID="btnReadCard" Text="读新卡" CssClass="button1" runat="server" 
        OnClientClick="return ReadWJLvyouCardInfo()" OnClick="btnReadCard_Click"/></td>
  
  <asp:HiddenField runat="server" ID="hidReadCardOK" />
  <asp:HiddenField runat="server" ID="hidWarning" />
  <asp:HiddenField runat="server" ID="hidAsn" />
  <asp:HiddenField runat="server" ID="hidTradeNo" />
  <asp:HiddenField runat="server" ID="hidAccRecv" />
  <asp:HiddenField runat="server" ID="hidEndDate" />
  <asp:HiddenField runat="server" ID="hidUsabelTimes" />
  <asp:HiddenField runat="server" ID="hidParkInfo" />
  <asp:HiddenField runat="server" ID="hidCardReaderToken" /> 
    <asp:HiddenField runat="server" ID="hidForPaperNo" />
  <asp:HiddenField runat="server" ID="hidForPhone" />
  <asp:HiddenField runat="server" ID="hidForAddr" />
  <asp:LinkButton runat="server" ID="btnConfirm" OnClick="btnConfirm_Click"/>
  </tr>
  <tr>
    <td><div align="right">卡片类型:</div></td>
    <td><asp:Label ID="labCardType" CssClass="labeltext" runat="server" /></td>
    <td><div align="right">启用日期:</div></td>
    <td><asp:TextBox ID="txtStartDate" CssClass="labeltext" runat="server" /></td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
</table>
 </div>
 <div class="card">旧卡信息</div>
 <div class="kuang5">
   <table width="100%" border="0" cellpadding="0" cellspacing="0" class="text25">
     <tr>
    <td width="10%"><div align="right">查询条件:</div></td>
    <td width="70%" colspan="5">
    <asp:DropDownList runat="server" ID="selQueryType">
        <asp:ListItem Selected="True" Text="01:卡号" Value="01"></asp:ListItem>
        <asp:ListItem Text="02:证件" Value="02"></asp:ListItem>
        <asp:ListItem Text="03:姓名" Value="03"></asp:ListItem>
        <asp:ListItem Text="04:电话" Value="04"></asp:ListItem>
    </asp:DropDownList>
    <asp:TextBox ID="txtCondition" CssClass="inputlong" runat="server"
     MaxLength="40" AutoPostBack="true" ontextchanged="btnQuery_Click"/>
    </td>
     <td width="10%"> <asp:Button ID="btnQuery" Text="查询" CssClass="button1" runat="server" OnClick="btnQuery_Click"/></td>
    </tr>
   </table>
   <div class="gdtb" style="height:108px">
   <asp:GridView ID="gvOldCardInfo" runat="server"
        Width = "98%"
        CssClass="tab1"
        HeaderStyle-CssClass="tabbt"
        AlternatingRowStyle-CssClass="tabjg"
        SelectedRowStyle-CssClass="tabsel"
        AutoGenerateColumns="False"
        OnSelectedIndexChanged="gvOldCardInfo_SelectedIndexChanged"
        OnRowCreated="gvOldCardInfo_RowCreated"
        OnRowDataBound="gvOldCardInfo_RowDataBound"
       >
           <Columns>

               <asp:BoundField ItemStyle-Width="10%" HeaderText="卡号" DataField="CARDNO"/>
               <asp:BoundField ItemStyle-Width="10%" HeaderText="结束日期" DataField="ENDDATE"/>
               <asp:BoundField ItemStyle-Width="10%" HeaderText="总次数" DataField="TOTALTIMES"/>
               <asp:BoundField ItemStyle-Width="10%" HeaderText="剩余次数" DataField="SPARETIMES"/>
               <asp:BoundField ItemStyle-Width="10%" HeaderText="姓名" DataField="CUSTNAME"/>
               <asp:BoundField ItemStyle-Width="10%" HeaderText="证件号码" DataField="PAPERNO"/>
               <asp:BoundField ItemStyle-Width="10%" HeaderText="联系电话" DataField="CUSTPHONE"/>
            </Columns>   
            <EmptyDataTemplate>
                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                  <tr class="tabbt">
                  <td width="10%">卡号</td>
                    <td width="10%">结束日期</td>
                    <td width="10%">总次数</td>
                    <td width="10%">剩余次数</td>
                    <td width="10%">姓名</td>
                    <td width="10%">证件号码</td>
                    <td width="10%">联系电话</td>
                  </tr>
                  </table>
            </EmptyDataTemplate>
                    
    </asp:GridView>
    </div>
 </div>
</div>
 <div class="basicinfo2">
 <div class="money">费用信息</div>
 <div class="kuang5">
 <div style="height:218px">
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
 </div>
 

 <div class="footall"></div>
 <div class="con">
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
    <td width="13%">
    <asp:DropDownList ID="selPaperType" CssClass="input" runat="server">
    </asp:DropDownList><span class="red">*</span>
    </td>
    <td width="9%"><div align="right">证件号码:</div></td>
    <td width="24%">
    <asp:TextBox ID="txtPaperNo" CssClass="inputmid" runat="server" MaxLength="20" /><span class="red">*</span>
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
         OnClientClick="readIDCard('txtCustName', 'selCustSex', 'txtCustBirth', 'selPaperType', 'txtPaperNo', 'txtCustAddr')"/>

    </td>
  </tr>
</table>

 </div>
</div>
<div class="btns">
     <table width="200" align="right" border="0"cellpadding="0" cellspacing="0">
  <tr>
    <td><asp:Button ID="btnPrintPZ" runat="server" Text="打印凭证" 
        CssClass="button1" Enabled="false" OnClientClick="printdiv('ptnPingZheng1')" /></td>
    <td ><asp:Button ID="btnSubmit" Enabled="false" CssClass="button1" runat="server" Text="提交" 
        OnClick="btnSubmit_Click"/></td>
  </tr>
</table>
<asp:CheckBox ID="chkPingzheng" runat="server"  Text="自动打印凭证"  Checked="true"/>

</div>  

          </ContentTemplate>
        </asp:UpdatePanel>
    </form>
</body>
</html>

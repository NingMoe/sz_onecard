<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PB_RollbackPermit.aspx.cs" Inherits="ASP_PersonalBusiness_PB_RollbackPermit" EnableEventValidation="false" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
<title>返销授权</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <script type="text/javascript" src="../../js/myext.js"></script>
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />

</head>
<body>
<form id="form1" runat="server">
<div class="tb">个人业务->返销授权</div>
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
 <div class="card">查询方式</div>
 <div class="kuang5">
   <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
     <tr>
       <td width="6%"><div align="right">卡号:</div></td>
       <td width="17%"><asp:TextBox ID="txtCardno" CssClass="input" maxlength="16" runat="server"></asp:TextBox></td>
       <td width="8%"><div align="right">操作日期:</div></td>
       <td width="13%"><asp:TextBox ID="OperateTime" CssClass="input" runat="server" maxlength="10"/>
       <ajaxToolkit:CalendarExtender ID="FCalendar" runat="server" TargetControlID="OperateTime" Format="yyyy-MM-dd" /></td>
       <td width="14%"><div align="right">充值类型:</div></td>
       <td width="14%"><asp:DropDownList ID="selTRADETYPE" CssClass="input" runat="server"></asp:DropDownList></td>
       <td width="14%"><div align="right">授权状态:</div></td>
       <td width="14%"><asp:DropDownList ID="selCancelTag" CssClass="input" runat="server"></asp:DropDownList></td>
     </tr>
     <tr>
       <td><div align="right">部门:</div></td>
       <td><asp:DropDownList CssClass="inputmid" ID="selDept" runat="server" AutoPostBack="true" OnSelectedIndexChanged="selDept_Changed"></asp:DropDownList></td>
       <td><div align="right">员工:</div></td>
       <td><asp:DropDownList CssClass="inputmid" ID="selStaff" runat="server"></asp:DropDownList></td>
       <td><div align="right">&nbsp;</div></td>
       <td>&nbsp;</td>
       <td>&nbsp;</td>
       <td><asp:Button ID="btnQuery" CssClass="button1" runat="server" Text="查询" OnClick="btnQuery_Click" /></td>
     </tr>
   </table>
 </div>
 <asp:HiddenField ID="hiddenTRADEID" runat="server" />
  <div class="jieguo">台帐信息</div>
  <div class="kuang5">
  <div class="gdtb" style="height:135px">
 <%-- <table width="646" border="0" cellpadding="0" cellspacing="0" class="tab1">--%>
    <asp:GridView ID="lvwSupply" runat="server"
                    Width = 95%
                    CssClass="tab1"
                    HeaderStyle-CssClass="tabbt"
                    AlternatingRowStyle-CssClass="tabjg"
                    SelectedRowStyle-CssClass="tabsel"
                    AllowPaging="True"
                    PageSize="4"
                    PagerSettings-Mode="NumericFirstLast"
                    PagerStyle-HorizontalAlign="left"
                    PagerStyle-VerticalAlign="Top"
                    AutoGenerateColumns="False"
                    OnPageIndexChanging="lvwSupply_Page"
                    OnSelectedIndexChanged="lvwSupply_SelectedIndexChanged"
                    OnRowCreated="lvwSupply_RowCreated">
                    <Columns>
                      <asp:BoundField DataField="ID"       HeaderText="充值业务流水号"/>
                      <asp:BoundField DataField="CARDNO"       HeaderText="卡号"/>
                      <asp:BoundField DataField="SUPPLYMONEY"       HeaderText="充值金额" NullDisplayText="0" DataFormatString="{0:n}" HtmlEncode="false"/>
                      <asp:BoundField DataField="XFCARDNO"       HeaderText="充值卡号"/>
                      <asp:BoundField DataField="STAFFNO" HeaderText="操作员工" />
                      <asp:BoundField DataField="OPERATETIME"       HeaderText="操作时间"/>
                      <asp:BoundField DataField="CANCELTAG"       HeaderText="授权状态"/>
                      <asp:BoundField DataField="CANCELSTAFF" HeaderText="授权员工" />
                      <asp:BoundField DataField="CANCELTIME"       HeaderText="授权时间"/>
                      
                    </Columns>     
               
                   <EmptyDataTemplate>
                   <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                     <tr class="tabbt">
                        <td>充值业务流水号</td>
                        <td>卡号</td>
                        <td>充值金额</td>
                        <td>充值卡号</td>
                        <td>操作员工</td>
                        <td>操作时间</td>
                        <td>授权状态</td>
                        <td>授权员工</td>
                        <td>授权时间</td>
                   </table>
                  </EmptyDataTemplate>
    </asp:GridView>
    
  <%--</table>--%>
</div>
   </div>

  <div class="jieguo">补写卡信息</div>
  <div class="kuang5">
  <div class="gdtb" style="height:135px">
  <%--<table width="646" border="0" cellpadding="0" cellspacing="0" class="tab1">--%>
  
  <asp:GridView ID="lvwRetrade" runat="server"
                    Width = 95%
                    CssClass="tab1"
                    HeaderStyle-CssClass="tabbt"
                    AlternatingRowStyle-CssClass="tabjg"
                    SelectedRowStyle-CssClass="tabsel"
                    AllowPaging="True"
                    PageSize="4"
                    PagerSettings-Mode="NumericFirstLast"
                    PagerStyle-HorizontalAlign="left"
                    PagerStyle-VerticalAlign="Top"
                    OnPageIndexChanging="lvwRetrade_Page"
                    AutoGenerateColumns="False">
                    <Columns>
                      <asp:BoundField DataField="TRADEID"       HeaderText="补写业务流水号"/>
                      <asp:BoundField DataField="CARDNO"       HeaderText="卡号"/>
                      
                      <asp:BoundField DataField="STAFFNO" HeaderText="操作员工" />
                      <asp:BoundField DataField="OPERATETIME"       HeaderText="操作时间"/>
                    </Columns>     
               
                   <EmptyDataTemplate>
                   <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                     <tr class="tabbt">
                        <td>补写业务流水号</td>
                        <td>卡号</td>
                        <td>操作员工</td>
                        <td>操作时间</td>
                   </table>
                  </EmptyDataTemplate>
    </asp:GridView>
    
  <%--</table>--%>
</div></div>
</div>
<div class="btns">
  <table width="100" border="0" align="right" cellpadding="0" cellspacing="0">
  <tr>
    <td><asp:Button ID="btnPermit" CssClass="button1" runat="server" Text="允许返销" Enabled="false" OnClick="btnPermit_Click" /></td>
   </tr>
  </table>
</div>
</ContentTemplate>
</asp:UpdatePanel>
</form>
</body>
</html>

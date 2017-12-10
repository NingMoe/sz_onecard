<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PB_TradefeeRollback.aspx.cs" Inherits="ASP_PersonalBusiness_PB_TradefeeRollback"  EnableEventValidation="false"%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
<title>返销台帐信息</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <script type="text/javascript" src="../../js/myext.js"></script>
    <script type="text/javascript" src="../../js/print.js"></script>
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
    <div class="tb">
个人业务->返销台帐信息</div>
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
  <div class="jieguo">返销台帐信息</div>
  <div class="kuang5"><div id="gdtb" style="height:300px">
  <%--<table width="646" border="0" cellpadding="0" cellspacing="0" class="tab1">--%>
  
    <asp:GridView ID="lvwQuery" runat="server"
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
                    OnPageIndexChanging="lvwQuery_Page"
                    AutoGenerateColumns="False"
                    OnSelectedIndexChanged="lvwQuery_SelectedIndexChanged"
                    OnRowCreated="lvwQuery_RowCreated">
                    <Columns>
                    <asp:BoundField DataField="TRADEID" Visible=false HeaderText="充值业务流水号"/>
                      <asp:BoundField DataField="CARDNO"       HeaderText="卡号"/>
                      <asp:BoundField DataField="TRADEMONEY"      HeaderText="充值金额" NullDisplayText="0" DataFormatString="{0:n}" HtmlEncode="false" />
                      <asp:BoundField DataField="OPERATESTAFF"       HeaderText="操作员工" />
                      <asp:BoundField DataField="OPERATETIME"       HeaderText="操作时间" />
                    </Columns>     
               
                   <EmptyDataTemplate>
                   <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                     <tr class="tabbt">
                     <td>充值业务流水号</td>
                        <td>卡号</td>
                        <td>充值金额</td>
                        <td>操作员工</td>
                        <td>操作时间</td>
                    </tr>
                   </table>
                  </EmptyDataTemplate>
    </asp:GridView>
    
  <%--</table>--%>
  <asp:HiddenField ID="hiddenTradeid" runat="server" />
  <asp:HiddenField ID="hidCardno" runat="server" />
</div></div>
  </div>
<div class="btns">
  <table width="100" border="0" align="right" cellpadding="0" cellspacing="0">
    <tr>
      <td><asp:Button ID="btnRollback" CssClass="button1" runat="server" Text="确认返销" OnClick="btnRollback_Click" /></td>
    </tr>
  </table>
  <label></label>
</div>
</ContentTemplate>          
        </asp:UpdatePanel>
    </form>
</body>
</html>

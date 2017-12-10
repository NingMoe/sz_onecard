<%@ Page Language="C#" AutoEventWireup="true" CodeFile="GC_DepchgFee.aspx.cs" Inherits="ASP_GroupCard_GC_DepchgFee" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
<title>卡押金转卡费</title>
        <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
        <script type="text/javascript" src="../../js/myext.js"></script>
         <link href="../../css/card.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
    <div class="tb">
企服卡->卡押金转卡费
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
    <td width="10%"><div align="right">起讫卡号:</div></td>
    <td width="48%"><asp:TextBox ID="txtFromCardNo" CssClass="inputmid" runat="server" MaxLength="16"></asp:TextBox>
-
  <asp:TextBox ID="txtToCardNo" CssClass="inputmid" runat="server" MaxLength="16"></asp:TextBox></td>
    <td width="42%"><asp:Button ID="btnQuery" CssClass="button1" runat="server" Text="查询" OnClick="btnQuery_Click" /></td>
    </tr>
</table>
  </div>
  <div class="jieguo">卡信息
    
  </div>
  <div class="kuang5">
  <div class="gdtb" style="height:330px">
  <asp:GridView ID="lvwQuery" runat="server"
                    Width = 98%
                    CssClass="tab1"
                    HeaderStyle-CssClass="tabbt"
                    AlternatingRowStyle-CssClass="tabjg"
                    SelectedRowStyle-CssClass="tabsel"
                    AllowPaging="True"
                    PageSize="10"
                    PagerSettings-Mode="NumericFirstLast"
                    PagerStyle-HorizontalAlign="left"
                    PagerStyle-VerticalAlign="Top"
                    OnPageIndexChanging="lvwQuery_Page"
                    AutoGenerateColumns="False">
                    <Columns>
                      <asp:BoundField DataField="CARDNO"       HeaderText="卡号"/>
                      <asp:BoundField DataField="ASN"       HeaderText="卡序列号"/>
                      <asp:BoundField DataField="DEPOSIT"      HeaderText="卡押金" NullDisplayText="0" DataFormatString="{0:n}" HtmlEncode="false" />
                      <asp:BoundField DataField="CARDCOST"      HeaderText="卡费" NullDisplayText="0" DataFormatString="{0:n}" HtmlEncode="false" />
                      <asp:BoundField  DataFormatString="{0:yyyy-MM-dd}" DataField="SELLTIME" HeaderText="售卡时间" />
                      <asp:BoundField DataField="STAFFNAME"       HeaderText="售卡员工" />    
                    </Columns>
                    <EmptyDataTemplate>  
                    <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                    <tr class="tabbt">
                        <td>卡号</td>
                        <td>卡序列号</td>
                        <td>卡押金</td>
                        <td>卡费</td>
                        <td>售卡时间</td>
                        <td>售卡员工</td>
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
    <td width="102"><asp:Button ID="btnDepChgFee" CssClass="button1" Enabled=false runat="server" Text="押金转卡费" OnClick="btnDepChgFee_Click" /></td>
  </tr>
</table>

</div>
</ContentTemplate>          
        </asp:UpdatePanel>
    </form>
</body>
</html>

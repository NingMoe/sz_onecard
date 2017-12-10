<%@ Page Language="C#" AutoEventWireup="true" CodeFile="UC_DepositChange.aspx.cs" Inherits="ASP_UserCard_UC_DepositChange" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
<title>修改卡押金</title>
        <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
        <script type="text/javascript" src="../../js/myext.js"></script>
         <link href="../../css/card.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
    <div class="tb">
用户卡->修改卡押金
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
    <tr>
    <td align="right">卡押金:</td>
    <td><asp:TextBox ID="txtCardprice" runat="server" CssClass="inputmid" MaxLength="7"></asp:TextBox>
        <span class="red">*</span> 100 分</td></td>
    <td width="102"><asp:Button ID="btnChange" CssClass="button1" Enabled="false" runat="server" Text="修改卡押金" OnClick="btnChange_Click" /></td>
  </tr>
</table>
  </div>
  <div class="jieguo">卡信息
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

</ContentTemplate>          
        </asp:UpdatePanel>
    </form>
</body>
</html>

<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PB_ChangeDbBalance.aspx.cs" Inherits="ASP_PersonalBusiness_PB_ChangeDbBalance" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>修改库内卡余额</title>

    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <script type="text/javascript" src="../../js/myext.js"></script>
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />   
</head>
<body>
    <form id="form1" runat="server">
<div class="tb">
个人业务->修改库内卡余额
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
        <asp:UpdatePanel ID="UpdatePanel1" UpdateMode="Conditional" runat="server">
            <ContentTemplate>

    <asp:BulletedList ID="bulMsgShow" runat="server"/>
    <script runat="server" >public override void ErrorMsgShow(){ErrorMsgHelper(bulMsgShow);}</script>
<div class="con">
<div class="base"></div>
  <div class="kuang5">
 <table width="95%" border="0" cellpadding="0" cellspacing="0" class="12text">
  <tr>
    <td width="10%"><div align="right">用户卡号:</div></td>
    <td width="20%"><asp:TextBox ID="txtCardNo" CssClass="inputmid" runat="server" MaxLength="16" Width="120"></asp:TextBox><span class="red">*</span>
  <td width="10%" align="right">卡片余额:</td>
  <td><asp:Label runat="server" ID="labCardAcc" Text="0.00"/>元</td>
    <td width="32%"><asp:Button ID="btnQuery" CssClass="button1" runat="server" Text="查询" OnClick="btnQuery_Click" /></td>
    </tr>
</table>
  </div>
  <div class="jieguo">最近消费信息</div>
  <div class="kuang5">
<div class="gdtb" style="height:100px">
         <asp:GridView ID="gvResult" runat="server"
        Width = "98%"
        CssClass="tab1"
        HeaderStyle-CssClass="tabbt"
        AlternatingRowStyle-CssClass="tabjg"
        SelectedRowStyle-CssClass="tabsel"
        AllowPaging="false"
        PagerSettings-Mode="NumericFirstLast"
        PagerStyle-HorizontalAlign="left"
        PagerStyle-VerticalAlign="Top"
        AutoGenerateColumns="true"
        OnRowDataBound="gvResult_RowDataBound"
        EmptyDataText="没有数据记录!" >
        </asp:GridView>
  </div>
  </div>
  <div class="jieguo">最近充值信息</div>
  <div class="kuang5">
<div class="gdtb" style="height:100px">
         <asp:GridView ID="gvCharge" runat="server"
        Width = "98%"
        CssClass="tab1"
        HeaderStyle-CssClass="tabbt"
        AlternatingRowStyle-CssClass="tabjg"
        SelectedRowStyle-CssClass="tabsel"
        AllowPaging="false"
        PagerSettings-Mode="NumericFirstLast"
        PagerStyle-HorizontalAlign="left"
        PagerStyle-VerticalAlign="Top"
        AutoGenerateColumns="true"
        OnRowDataBound="gvResult_RowDataBound"
        EmptyDataText="没有数据记录!" >
        </asp:GridView>
  </div>
  </div>
</div>
<div class="btns">
     <table width="400" align="right"  border="0"cellpadding="0" cellspacing="0">
  <tr>
    <asp:Panel runat="server" ID="palDeduction" Visible="false">
    <td align="right">新金额:</td>
    <td><asp:TextBox runat="server" ID="txtNewBalance" CssClass="input" Text="0" Width-="50" />元</td>
    </asp:Panel>
    <td>&nbsp;</td>
    <td><asp:Button ID="btnSubmit" Enabled="false" CssClass="button1" runat="server" Text="提交" OnClick="btnSubmit_Click"/></td>
  </tr>
</table>
<span class="red">提示: 修改差额(新金额-老金额)不允许超过200元。</span>

</div>

            </ContentTemplate>         
        </asp:UpdatePanel>

    </form>
</body>
</html>

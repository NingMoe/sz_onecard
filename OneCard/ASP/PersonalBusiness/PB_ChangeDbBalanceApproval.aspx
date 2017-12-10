<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PB_ChangeDbBalanceApproval.aspx.cs" Inherits="ASP_PersonalBusiness_PB_ChangeDbBalanceApproval" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>修改库内卡余额财务审核</title>

    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <script type="text/javascript" src="../../js/myext.js"></script>
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />   
</head>
<body>
    <form id="form1" runat="server">
<div class="tb">
个人业务->修改库内卡余额财务审核
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
  <div class="jieguo">修改库内卡余额信息</div>
  <div class="kuang5">
  <div class="gdtb" style="height:310px">
         <asp:GridView ID="gvResult" runat="server"
        Width = "98%"
        CssClass="tab1"
        HeaderStyle-CssClass="tabbt"
        AlternatingRowStyle-CssClass="tabjg"
        SelectedRowStyle-CssClass="tabsel"
        AllowPaging="false"
        PagerSettings-Mode=NumericFirstLast
        PagerStyle-HorizontalAlign=left
        PagerStyle-VerticalAlign=Top
        OnRowDataBound="gvResult_RowDataBound"
        AutoGenerateColumns="False">
           <Columns>
             <asp:TemplateField>
                <HeaderTemplate>
                  <asp:CheckBox ID="CheckBox1" runat="server"  AutoPostBack="true" OnCheckedChanged="CheckAll" />
                </HeaderTemplate>
                <ItemTemplate>
                  <asp:CheckBox ID="ItemCheckBox" runat="server"/>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:BoundField HeaderText="批次号" DataField="TRADEID"/>
            <asp:BoundField HeaderText="卡号" DataField="CARDNO"/>
             <asp:TemplateField>
                <HeaderTemplate>客户姓名<span class="red">*</span></HeaderTemplate>
                <ItemTemplate>
                 <asp:TextBox runat="server" ID="txtCustName" CssClass="input" Width="80" MaxLength="120" />
                </ItemTemplate>
            </asp:TemplateField>               
              <asp:TemplateField>
                <HeaderTemplate>联系方式<span class="red">*</span></HeaderTemplate>
                <ItemTemplate>
                 <asp:TextBox runat="server" ID="txtCustContact" CssClass="input" Width="280" MaxLength="240" />
                </ItemTemplate>
            </asp:TemplateField>                <asp:BoundField HeaderText="修改前￥" DataField="PREBALANCE"   DataFormatString="{0:n}" HtmlEncode="False"/>
                <asp:BoundField HeaderText="修改后￥" DataField="NEWBALANCE"  DataFormatString="{0:n}" HtmlEncode="False"/>
                <asp:BoundField HeaderText="修改人" DataField="SUBMITSTAFF"/>
                <asp:BoundField HeaderText="修改时间" DataField="SUBMITTIME" DataFormatString="{0:yyyy-MM-dd}" HtmlEncode="False"/>
            </Columns>           
            <EmptyDataTemplate>
                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                  <tr class="tabbt">
                    <td><input type="checkbox" /></td>
                     <td>卡号</td>
                    <td>客户姓名</td>
                    <td>联系方式</td>
                    <td>修改前￥</td>
                    <td>修改后￥</td>
                    <td>修改人</td>
                    <td>修改时间</td>
                  </tr>
                  </table>
            </EmptyDataTemplate>
        </asp:GridView>
  </div>
  </div>
</div>

<div class="btns">
<table width="95%" border="0"cellpadding="0" cellspacing="0">
  <tr>
    <td width="70%">&nbsp;</td>
    <td align="right"><asp:CheckBox ID="chkApprove" AutoPostBack="true" Text="通过" runat="server" OnCheckedChanged="chkApprove_CheckedChanged" /></td>
    <td align="right"><asp:CheckBox ID="chkReject" AutoPostBack="true" Text="作废" runat="server" OnCheckedChanged="chkReject_CheckedChanged"  /></td>
    <td align="right"><asp:Button ID="btnSubmit" Enabled="false" CssClass="button1" runat="server" Text="提交" OnClick="btnSubmit_Click"/></td>
  </tr>
</table>
</div>

            </ContentTemplate>         
        </asp:UpdatePanel>

    </form>
</body>
</html>


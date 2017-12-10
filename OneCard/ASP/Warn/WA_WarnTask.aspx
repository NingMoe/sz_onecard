<%@ Page Language="C#" AutoEventWireup="true" CodeFile="WA_WarnTask.aspx.cs" Inherits="ASP_Warn_WA_WarnTask" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
     <title>监控任务</title>
    <script type="text/javascript" src="../../js/myext.js"></script>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
   <link href="../../css/card.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
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
        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
            <ContentTemplate>
        <div class="tb">
        账务监控->监控任务
        </div>

    <asp:BulletedList ID="bulMsgShow" runat="server"/>
    <script runat="server" >public override void ErrorMsgShow(){ErrorMsgHelper(bulMsgShow);}</script>

        <div class="con">
          <div class="base">条件</div>
          <div class="kuang5">
               <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                   <tr>
                        <td><div align="right">起始日期:</div></td>
                        <td>
                            <asp:TextBox runat="server" ID="txtFromDate" MaxLength="8" CssClass="input"></asp:TextBox>(yyyyMMdd)
                        </td>
                        <td><div align="right">结束日期:</div></td>
                        <td>
                            <asp:TextBox runat="server" ID="txtToDate" MaxLength="8" CssClass="input"></asp:TextBox>(yyyyMMdd)
                        </td>
                        <td>&nbsp;</td>
                        <td>&nbsp; </td>
                        <td>&nbsp;</td>
                        <td align="right">
                            <asp:Button ID="Button1" CssClass="button1" runat="server" Text="查询" OnClick="btnQuery_Click"/>
                        </td>
                        <td align="right"><asp:Button ID="btnCreate" CssClass="button1" runat="server" Text="生成新任务" OnClick="btnCreate_Click"/></td>
                   </tr>
               </table>

         </div>
          <div class="jieguo">查询结果
          </div>
  <div class="kuang5">
  <div class="gdtb" style="height:260px">

         <asp:GridView ID="gvResult" runat="server"
        Width = "1500"
        CssClass="tab1"
        HeaderStyle-CssClass="tabbt"
        AlternatingRowStyle-CssClass="tabjg"
        SelectedRowStyle-CssClass="tabsel"
        AllowPaging="False"
        PagerSettings-Mode="NumericFirstLast"
        PagerStyle-HorizontalAlign="left"
        PagerStyle-VerticalAlign="Top"
        AutoGenerateColumns="True"
        EmptyDataText="没有数据记录!">
        </asp:GridView>
        </div>
  </div> 
   <div class="footall"></div>
  
<div class="btns">
     <table width="95%" border="0"cellpadding="0" cellspacing="0">
  <tr>
    <td width="70%">&nbsp;</td>
    <td align="right"><asp:DropDownList ID="selSubmitType" runat="server" CssClass="inputmid">
        <asp:ListItem Text="动态账务监控" Value="0" />
        <asp:ListItem Text="静态账户监控" Value="1" />
    </asp:DropDownList></td>
    <td align="right"><asp:Button ID="btnSubmit" CssClass="button1" runat="server" Text="运行" OnClick="btnSubmit_Click"/></td>
  </tr>
</table>

</div>
        
</ContentTemplate>
</asp:UpdatePanel>
    </form>
</body>
</html>

<%@ Page Language="C#" AutoEventWireup="true" CodeFile="FI_JiangYin_CloseReport.aspx.cs" Inherits="ASP_FI_JiangYin_CloseReport" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
     <title>江阴结算情况</title>
     <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
     <script type="text/javascript" src="../../js/print.js"></script>
     <script type="text/javascript" src="../../js/myext.js"></script>
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
        <asp:UpdatePanel ID="UpdatePanel1" UpdateMode="Conditional"  runat="server">
            <ContentTemplate>
        <div class="tb">
        财务管理->江阴结算情况

        </div>

        <asp:HiddenField ID="hidNo" runat="server" Value="" />
        
    <asp:BulletedList ID="bulMsgShow" runat="server"/>
    <script runat="server" >public override void ErrorMsgShow(){ErrorMsgHelper(bulMsgShow);}</script>

        <div class="con">
          <div class="base">查询条件</div>
          <div class="kuang5">
         <table border="0" cellpadding="0" cellspacing="0" class="text25">
          <tr>
            <td width="100"><div align="right">开始日期:</div></td>
            <td width="100">
<asp:TextBox runat="server" ID="txtFromDate" MaxLength="8" CssClass="input"></asp:TextBox>
      <ajaxToolkit:CalendarExtender ID="FCalendar1" runat="server" TargetControlID="txtFromDate"
             Format="yyyyMMdd" />
            </td>
            <td width="100"><div align="right">结束日期:</div></td>
            <td width="100"><asp:TextBox runat="server" ID="txtToDate" MaxLength="8" CssClass="input"></asp:TextBox>
      <ajaxToolkit:CalendarExtender ID="FCalendar2" runat="server" TargetControlID="txtToDate"
            Format="yyyyMMdd" />
            </td>
            
            <td width="150" align="center"><asp:Button ID="btnQuery" CssClass="button1" runat="server" Text="查询" OnClick="btnQuery_Click"/></td>
          </tr>
        </table>

         </div>
         
         <table border="0" width="95%">
            <tr>
                <td align="left"><div class="jieguo">处理文件信息</div></td>
                <td align="right">
                    <asp:Button ID="btnExport" CssClass="button1fix" runat="server" Text="导出表格" OnClick="btnExport_Click" />
                    <asp:Button ID="btnPrint" CssClass="button1" runat="server" Text="打印" OnClientClick="return printGridView('printarea');" />
                </td>
            </tr>
        </table>

             <div id="printarea" class="kuang5">
              <div class="gdtbfix" style="height:380px;">
                 <asp:GridView ID="gvResult" runat="server"
                    Width = "95%"
                    CssClass="tab2"
                    HeaderStyle-CssClass="tabbt"
                    FooterStyle-CssClass="tabcon"
                    AlternatingRowStyle-CssClass="tabjg"
                    SelectedRowStyle-CssClass="tabsel"
                    PagerSettings-Mode="NumericFirstLast"
                    PagerStyle-HorizontalAlign="left"
                    PagerStyle-VerticalAlign="Top"
                    AutoGenerateColumns="true"
                    OnRowDataBound="gvResult_RowDataBound" 
                    ShowFooter="true">
                 </asp:GridView>
             </div>
             
           </div> 
          
           
         </div>
         
   </ContentTemplate>
      <Triggers>
        <asp:PostBackTrigger ControlID="btnExport" />
      </Triggers>
  </asp:UpdatePanel>

    </form>
</body>
</html>
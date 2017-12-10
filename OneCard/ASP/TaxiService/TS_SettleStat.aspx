<%@ Page Language="C#" AutoEventWireup="true" CodeFile="TS_SettleStat.aspx.cs" Inherits="ASP_TaxiService_TS_SettleStat" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <title>结算统计</title>
    <script type="text/javascript" src="../../js/myext.js"></script>
    <script type="text/javascript" src="../../js/myext.js"></script>
	<link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
     <div class="tb">司机卡->结算统计</div>
    
       <ajaxToolkit:ToolkitScriptManager runat="Server" EnableScriptGlobalization="true" AsyncPostBackTimeout="600"
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
         <asp:BulletedList ID="bulMsgShow" runat="server"/>
         <script runat="server" >public override void ErrorMsgShow(){ErrorMsgHelper(bulMsgShow);}</script>
        
         
       <div class="con">
        <div class="base">查询方式</div>
          <div class="kuang5">
         <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">

          <tr>
           <td><div align="right">单位:</div></td>
           <td>
            <asp:DropDownList ID="selCorp" AutoPostBack="true" OnSelectedIndexChanged="selCorp_SelectedIndexChanged" CssClass="inputmidder" runat="server"/>
           </td>
           <td><div align="right">员工:</div></td>
           <td>
            <asp:DropDownList ID="selStaffno" CssClass="inputmid" runat="server"/>
           </td>
            <td><div align="right">结算日期: </div></td>
            <td>
              <asp:TextBox ID="txtBeginDate" runat="server" CssClass="input" MaxLength="8"  Width="100px"/> <span class="red">*</span>
                <ajaxToolkit:CalendarExtender ID="CalendarExtender1" 
                        runat="server" TargetControlID="txtBeginDate" Format="yyyyMMdd" />
              -<asp:TextBox ID="txtEndDate" runat="server" CssClass="input" MaxLength="8"  Width="100px"/> <span class="red">*</span>
                <ajaxToolkit:CalendarExtender ID="CalendarExtender2" 
                        runat="server" TargetControlID="txtEndDate" Format="yyyyMMdd" />
               
             </td>
            <td>&nbsp;<asp:Button ID="btnQuery" runat="server" Text="查询" CssClass="button1" OnClick="btnQuery_Click" /></td>
          </tr>
        </table>

         </div>
         
         <div class="jieguo">
            <table border="0" width="95%">
                <tr>
                    <td align="left"><div class="Condition">查询结果</div></td>
                    <td align="right">
                        <asp:Button ID="btnExport" CssClass="button1" runat="server" Text="导出" OnClick="btnExport_Click" />
                    </td>
                    <td>&nbsp;</td>
                </tr>
            </table>   
          </div>      
          <div class="kuang5">         
          <div id="gdtbfix" style="height:420px;">
           <asp:GridView ID="gvResult" runat="server"
                    CssClass="tab1"
                    Width ="98%"
                    HeaderStyle-CssClass="tabbt"
                    AlternatingRowStyle-CssClass="tabjg"
                    SelectedRowStyle-CssClass="tabsel"
                    PagerSettings-Mode="NumericFirstLast"
                    PagerStyle-HorizontalAlign="Left"
                    PagerStyle-VerticalAlign="Top"
                    AutoGenerateColumns="true"
                    OnRowDataBound="gvResult_RowDataBound"
                    EmptyDataText="没有数据记录!" />
          </div>
          </div>
        </div>
         </ContentTemplate>
          <Triggers>
           <asp:PostBackTrigger ControlID = "btnExport" />
          </Triggers>
          
       </asp:UpdatePanel>
    </form>
</body>
</html>

<%@ Page Language="C#" AutoEventWireup="true" CodeFile="FI_CG_RenewReport.aspx.cs" Inherits="ASP_Financial_FI_CG_RenewReport" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>利金卡回收统计</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
     <script type="text/javascript" src="../../js/print.js"></script>
     <script type="text/javascript" src="../../js/myext.js"></script>
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
    
        <div class="tb">
		    财务管理->利金卡回收统计
	    </div>
	
	    <ajaxToolkit:ToolkitScriptManager runat="Server" EnableScriptGlobalization="true" 
	    AsyncPostBackTimeout="600"  EnableScriptLocalization="true" ID="ToolkitScriptManager1" />
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
        <asp:UpdatePanel ID="UpdatePanel2" runat="server">  
            <ContentTemplate>  
               
            <!-- #include file="../../ErrorMsg.inc" -->  
	        <div class="con">

	           <div class="card">查询</div>
               <div class="kuang5">
               <table border="0" cellpadding="0" cellspacing="0" class="text25">
                   <tr>
                   <td width="18%"> <div align="right">查询日期:</div></td>
                   <td width="58%">
                        <asp:TextBox runat="server" ID="txtDate" MaxLength="6" CssClass="input"></asp:TextBox>
                        <%--<ajaxToolkit:CalendarExtender ID="CalendarExtender1" runat="server" TargetControlID="txtDate" Format="yyyyMM" />--%>
                   </td>
                   <td width="24%">
                        <asp:Button ID="btnQuery" CssClass="button1" runat="server" Text="查询" OnClick="btnQuery_Click" />
                   </td>
                </tr>
               </table>
               
             </div>
             
             <asp:HiddenField ID="hidNo" runat="server" Value="" />
             
             <table border="0" width="95%">
                <tr>
                    <td align="left"><div class="jieguo">查询结果</div></td>
                    <td align="right">
                        <asp:Button ID="btnExport" CssClass="button1" runat="server" Text="导出" OnClick="btnExport_Click" />
                        <asp:Button ID="btnPrint" CssClass="button1" runat="server" Text="打印" OnClientClick="return printGridView('printarea');" />
                    </td>
                </tr>
            </table>
            
              <div id="printarea" class="kuang5">
                <div id="gdtbfix" style="height:360px;">
                
                    <table id="printReport" width ="80%">
                        <tr align="center">
                            <td style ="font-size:16px;font-weight:bold">利金卡回收统计</td>
                        </tr>
                        <tr>
                            <td>
                                <table width="300px" align="left">
                                    <%--<tr align="left">
                                        <td>凭证号：<%=hidNo.Value%></td>
                                    </tr>--%>
                                </table>
                            
                                <table width="300px" align="right">
                                    <%--<tr align="right">
                                        <td>开始日期：<%=txtFromDate.Text%></td>
                                        <td>结束日期：<%=txtToDate.Text%></td>
                                    </tr>--%>
                                </table>
                            </td>
                        </tr>
                    </table>
                
                    <asp:GridView ID="gvResult" runat="server"
                            Width = "80%"
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
                            ShowFooter="true" >
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
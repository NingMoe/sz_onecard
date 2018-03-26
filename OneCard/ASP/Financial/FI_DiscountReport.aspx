<%@ Page Language="C#" AutoEventWireup="true" CodeFile="FI_DiscountReport.aspx.cs" Inherits="ASP_Financial_FI_DiscountReport" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>优惠商户对账报表</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
     <script type="text/javascript" src="../../js/print.js"></script>
     <script type="text/javascript" src="../../js/myext.js"></script>
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
    
        <div class="tb">
		    财务管理->优惠商户对账报表
	    </div>
	
	    <ajaxToolkit:ToolkitScriptManager runat="Server" EnableScriptGlobalization="true" EnableScriptLocalization="true" ID="ToolkitScriptManager1" />
	    <script type="text/javascript" language="javascript">
	        var swpmIntance = Sys.WebForms.PageRequestManager.getInstance();
	        swpmIntance.add_initializeRequest(BeginRequestHandler);
	        swpmIntance.add_pageLoading(EndRequestHandler);
	        function BeginRequestHandler(sender, args) {
	            try { MyExtShow('请等待', '正在提交后台处理中...'); } catch (ex) { }
	        }
	        function EndRequestHandler(sender, args) {
	            try { MyExtHide(); } catch (ex) { }
	        }
          </script>
        <asp:UpdatePanel ID="UpdatePanel2" runat="server">  
            <ContentTemplate>  
               
            <!-- #include file="../../ErrorMsg.inc" -->  
            <asp:HiddenField ID="hidBeginDate" runat="server" Value="" />
            <asp:HiddenField ID="hidEndDate" runat="server" Value="" />
	        <div class="con">

	           <div class="card">查询</div>
               <div class="kuang5">
               <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
               <tr>
                    <td align="right">
                        行业名称:
                    </td>
                    <td>
                        <asp:DropDownList ID="selCalling" CssClass="inputmidder" runat="server" AutoPostBack="true"
                            OnSelectedIndexChanged="selCalling_SelectedIndexChanged">
                        </asp:DropDownList>
                    </td>
                    <td align="right">
                        单位名称:
                    </td>
                    <td>
                        <asp:DropDownList ID="selCorp" CssClass="inputmidder" runat="server" AutoPostBack="true"
                            OnSelectedIndexChanged="selCorp_SelectedIndexChanged">
                        </asp:DropDownList>
                    </td>
                </tr>
                   <tr>
                    <td align="right">
                        部门名称:
                    </td>
                    <td>
                        <asp:DropDownList ID="selDepart" CssClass="inputmidder" runat="server" AutoPostBack="true"
                            OnSelectedIndexChanged="selDepart_SelectedIndexChanged">
                        </asp:DropDownList>
                    </td>
                    <td align="right">
                        结算单元:
                    </td>
                    <td>
                        <asp:DropDownList ID="selBalUint" CssClass="inputmidder" runat="server">
                        </asp:DropDownList>
                    </td>
                </tr>
                <tr>
                    
                    <td><div align="right">开始日期:</div></td>
                        <td>
                            <asp:TextBox runat="server" ID="txtBeginDate" MaxLength="8" CssClass="input"></asp:TextBox>
                            <ajaxToolkit:CalendarExtender ID="FCalendar1" runat="server" TargetControlID="txtBeginDate" Format="yyyyMMdd" />
                        </td>
                        <td><div align="right">结束日期:</div></td>
                        <td>
                            <asp:TextBox runat="server" ID="txtEndDate" MaxLength="8" CssClass="input"></asp:TextBox>
                            <ajaxToolkit:CalendarExtender ID="FCalendar2" runat="server" TargetControlID="txtEndDate" Format="yyyyMMdd" />
                       
                    
                </tr>
                <tr>
                <td align="right">
                        账户类型:
                    </td>
                 <td>
                <asp:DropDownList ID="selType" CssClass="input" runat="server">
                                    <asp:ListItem Text="---请选择---" Value=""></asp:ListItem>
                                    <asp:ListItem Text="0000:电子钱包" Value="0000"></asp:ListItem>
                                    <asp:ListItem Text="0001:专有账户" Value="0001"></asp:ListItem>
                                    <asp:ListItem Text="9000:补助账户" Value="9000"></asp:ListItem>
                                    
                                </asp:DropDownList>
                   </td>
                   <td colspan="3" align="right">
                       
                               
                                <asp:Button ID="btnQuery" runat="server" Text="查询" CssClass="button1" OnClick="btnQuery_Click" />
                           
                    </td>
                </tr>
               </table>
               
             </div>
                
             
             <asp:HiddenField ID="hidNo" runat="server" Value="" />
	
            <table border="0" width="95%">
                <tr>
                    <td align="left"><div class="jieguo">查询结果</div></td>
                    <td align="right">
                        <asp:Button ID="btnExport" CssClass="button1" runat="server" Text="导出Excel" OnClick="btnExport_Click" />
                        <asp:Button ID="btnPrint" CssClass="button1" runat="server" Text="打印" OnClientClick="return printGridView('printarea');" />
                    </td>
                </tr>
            </table>
            
              <div id="printarea" class="kuang5">
                <div id="gdtbfix" style="height:380px">
                    <table id="printReport" width ="80%">
                        <tr align="center">
                            <td style ="font-size:16px;font-weight:bold">优惠商户对账</td>
                        </tr>
                        <tr>
                            <td>
                               <%-- <table width="300px" align="left">
                                    <tr align="left">
                                        <td>凭证号：<%=hidNo.Value%></td>
                                    </tr>
                                </table>--%>
                            
                                <table width="300px" align="right">
                                    <tr align="right">
                                        <td>开始日期：<%=txtBeginDate.Text%></td>
                                        <td>结束日期：<%=txtEndDate.Text%></td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                    </table>
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
    <div>
    
    </div>

</body>
</html>

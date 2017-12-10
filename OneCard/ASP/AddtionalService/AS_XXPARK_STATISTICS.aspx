<%@ Page Language="C#" AutoEventWireup="true" CodeFile="AS_XXPARK_STATISTICS.aspx.cs" Inherits="AS_XXPARK_STATISTICS" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>园林休闲开卡表</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
     <script type="text/javascript" src="../../js/print.js"></script>
     <script type="text/javascript" src="../../js/myext.js"></script>
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <style>
        .tab2 .tabbt TD
        {
            border-right-width: 1px;
            border-bottom-width: 1px;
            border-right-style: solid;
            border-bottom-style: solid;
            border-right-color: #888888;
            border-bottom-color: #888888;
            border-left-width: 1px;
            border-top-width: 1px;
            border-left-style: solid;
            border-top-style: solid;
            border-left-color: #888888;
            border-top-color: #888888;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
    
        <div class="tb">
		    管理报表->园林休闲开卡表
	    </div>
          <ajaxToolkit:ToolkitScriptManager runat="Server" EnableScriptGlobalization="true"
            AsyncPostBackTimeout="600"
            EnableScriptLocalization="true" ID="ScriptManager2" />
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
	        <div class="con">

           <div class="card">查询</div>
           <div class="kuang5">
               <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                   <tr>
                        <td><div align="right">查询年份:</div></td>
                        <td>
                            <asp:TextBox runat="server" ID="txtStatMonth" MaxLength="4" CssClass="input"></asp:TextBox>
                            <ajaxToolkit:CalendarExtender ID="FCalendar1" runat="server" TargetControlID="txtStatMonth" Format="yyyy" />
                        </td>
                        <td align="center">
                            <asp:Button ID="Button1" CssClass="button1" runat="server" Text="查询" OnClick="btnQuery_Click"/>
                        </td>
                   </tr>
               </table>
               
             </div>
	
            <table border="0" width="95%">
                <tr>
                    <td align="left"><div class="jieguo">查询结果</div></td>
                    <td align="right">
                        <asp:Button ID="btnExport" CssClass="button1" runat="server" Text="导出Excel" OnClick="btnExport_Click" />
                        <asp:Button ID="btnPrint" CssClass="button1" runat="server" Text="打印" OnClientClick="return printGridView('printarea');"/>
                    </td>
                </tr>
            </table>
            
              <div id="printarea" class="kuang5">
                <div id="gdtbfix" style="height:360px">
                    <table id="printReport" width ="95%">
                        <tr align="center">
                            <td style ="font-size:16px;font-weight:bold">园林休闲开卡表</td>
                        </tr>
                        <tr>
                            <td>
                                <table width="300px" align="left">
                                    <tr align="left">
                                        <td></td>
                                    </tr>
                                </table>
                            
                                <table width="300px" align="right">
                                    <tr align="right">
                                        <td>查询年份：<%=txtStatMonth.Text%></td>
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
                            AutoGenerateColumns="false"
                            ShowFooter="false">
                    <Columns>
                        <asp:BoundField DataField="CARDTYPENAME" HeaderText="项目" />
                        <asp:BoundField DataField="MONTH_01" HeaderText="1月" />
                        <asp:BoundField DataField="MONTH_02" HeaderText="2月" />
                        <asp:BoundField DataField="MONTH_03" HeaderText="3月" />
                        <asp:BoundField DataField="MONTH_04" HeaderText="4月" />
                        <asp:BoundField DataField="MONTH_05" HeaderText="5月" />
                        <asp:BoundField DataField="MONTH_06" HeaderText="6月" />
                        <asp:BoundField DataField="MONTH_07" HeaderText="7月" />
                        <asp:BoundField DataField="MONTH_08" HeaderText="8月" />
                        <asp:BoundField DataField="MONTH_09" HeaderText="9月" />
                        <asp:BoundField DataField="MONTH_10" HeaderText="10月" />
                        <asp:BoundField DataField="MONTH_11" HeaderText="11月" />
                        <asp:BoundField DataField="MONTH_12" HeaderText="12月" />
                        <asp:BoundField DataField="YEAR_SUM" HeaderText="当年合计" />
                        <asp:BoundField DataField="ALL_SUM" HeaderText="开通总量" />
                    </Columns>
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

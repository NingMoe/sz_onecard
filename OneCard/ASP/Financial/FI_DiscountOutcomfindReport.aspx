<%@ Page Language="C#" AutoEventWireup="true" CodeFile="FI_DiscountOutcomfindReport.aspx.cs" Inherits="ASP_Financial_FI_DiscountOutcomfindReport" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>优惠商户转账报表</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
     <script type="text/javascript" src="../../js/print.js"></script>
     <script type="text/javascript" src="../../js/myext.js"></script>
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
</head>
 <style type="text/css">
        .Hide
        {
            display: none;
        }
    </style>
<script language="javascript" type="text/javascript">
    function PrintInfo(ID) {
        //清除隐藏域
        var controls = document.getElementsByTagName('th');
        for (var i = 0; i < controls.length; i++) {
            if (controls[i].className == 'Hide') {
                controls[i].innerHTML = "";
                controls[i].removeNode();
                --i;
            }
        }
        controls = document.getElementsByTagName('td');
        for (var i = 0; i < controls.length; i++) {
            if (controls[i].className == 'Hide') {
                controls[i].innerHTML = "";
                controls[i].removeNode();
                --i;
            }
        }
        var flag = printGridViewDAILY_REPORT(ID);
        //刷新页面
        document.getElementById("btnQuery").click();
        return flag;
    }
    </script>
<body>
    <form id="form1" runat="server">
    
        <div class="tb">
		    财务管理->优惠商户转账报表
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
                        </td>
                    
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
             <div class="base">
                    凭证信息</div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                           
                            <td >
                                <div align="right">
                                    凭证类别:</div>
                            </td>
                            <td >
                                <asp:DropDownList ID="dropSignType" CssClass="input" runat="server">
                                    <asp:ListItem Text="付" Value="5" Selected="true"></asp:ListItem>
                                </asp:DropDownList>
                            </td>
                           <td>
                                <div align="right">
                                    项目大类编码:</div>
                            </td>
                            <td>
                                <asp:DropDownList ID="dropcItemClass" CssClass="input" runat="server">
                                    <asp:ListItem Text="01:现金流量" Value="01" Selected="true"></asp:ListItem>
                                </asp:DropDownList>
                            </td>                            <td>
                                <div align="right">
                                    项目编码:</div>
                            </td>
                            <td>
                                <asp:DropDownList ID="dropcItemId" CssClass="input" runat="server">
                                    <asp:ListItem Text="YJR:充值、押金" Value="YJR" Selected="true"></asp:ListItem>
                                </asp:DropDownList>
                            </td>
                            <td >
                                <div align="right">
                                </div>
                            </td>
                            <td>
                                &nbsp;
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    供应商编码:</div>
                            </td>
                            <td>
                                <asp:DropDownList ID="dropcSupId" runat="server" CssClass="input">
                                    <asp:ListItem Selected="true" Text="GRCZ:充值" Value="GRCZ"></asp:ListItem>
                                </asp:DropDownList>
                            </td>
                            <td>
                                <div align="right">
                                    贷方科目编码:</div>
                            </td>
                            <td>
                                <asp:DropDownList ID="dropcCodeD" CssClass="input" runat="server">
                                    <asp:ListItem Text="10020203" Value="10020203" Selected="true"></asp:ListItem>
                                </asp:DropDownList>
                                &nbsp;
                            </td>
                            <td>
                                <div align="right">
                                    借方科目编码:</div>
                            </td>
                            <td>
                                <asp:DropDownList ID="dropcCodeJ" CssClass="input" runat="server">
                                    <asp:ListItem Text="220201" Value="220201" Selected="true"></asp:ListItem>
                                </asp:DropDownList>
                                &nbsp;
                            </td>
                            <td >
                                <div align="right">
                                </div>
                            </td>
                            <td>
                                &nbsp;
                                <asp:Button ID="btnExportSql" runat="server" CssClass="button1fix" OnClick="btnExportSql_Click"
                                    Text="导出财务凭证" Width="100px" />
                            </td>
                        </tr>
                    </table>
                </div>
             
             <asp:HiddenField ID="hidNo" runat="server" Value="" />
	
            <table border="0" width="95%">
                <tr>
                    <td align="left"><div class="jieguo">查询结果</div></td>
                    <td align="right">
                        <asp:Button ID="btnExport" CssClass="button1" runat="server" Text="导出表格" OnClick="btnExport_Click" />
                        <asp:Button ID="btnExportXML" CssClass="button1fix" runat="server" Text="导出转账表格"
                                OnClick="btnExportXML_Click" />
                        <asp:Button ID="btnPrint" CssClass="button1" runat="server" Text="打印" OnClientClick="return printGridView('printarea');" />
                    </td>
                </tr>
            </table>
            
              <div id="printarea" class="kuang5">
                <div id="gdtbfix" style="height:380px">
                    <table id="printReport" width ="80%">
                        <tr align="center">
                            <td style ="font-size:16px;font-weight:bold">优惠商户转账</td>
                        </tr>
                        <tr>
                            <td>
                                <%--<table width="300px" align="left">
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
                 <asp:PostBackTrigger ControlID="btnExportSql" />
                 <asp:PostBackTrigger ControlID="btnExportXML" />
              </Triggers>
        </asp:UpdatePanel>
        
    </form>
    <div>
    
    </div>

</body>
</html>

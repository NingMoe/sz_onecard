<%@ Page Language="C#" AutoEventWireup="true" CodeFile="HYDROPOWER_CHARGE_QUERY.aspx.cs" Inherits="ASP_Financial_HYDROPOWER_CHARGE_QUERY" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
    <title>公共事业代缴查询</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
     <script type="text/javascript" src="../../js/print.js"></script>
     <script type="text/javascript" src="../../js/myext.js"></script>
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="../../js/cardreaderhelper.js"></script>
</head>
<body>
    <form id="form1" runat="server">
    
        <div class="tb">
		    附加业务->公共事业代缴查询
	    </div>
	
	    <ajaxToolkit:ToolkitScriptManager runat="Server" EnableScriptGlobalization="true" EnableScriptLocalization="true" ID="ToolkitScriptManager1" />
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
               <aspControls:PrintPingZheng ID="ptnPingZheng" runat="server" PrintArea="ptnPingZheng1" />
            <!-- #include file="../../ErrorMsg.inc" -->  
	        <div class="con">

	           <div class="card">查询</div>
               <div class="kuang5">
               <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                   <tr>
                        <td><div align="right">开始日期:</div></td>
                        <td>
                            <asp:TextBox runat="server" ID="txtFromDate" Width="150px" MaxLength="8" CssClass="input"></asp:TextBox>
                            <ajaxToolkit:CalendarExtender ID="CalendarExtender1" runat="server" TargetControlID="txtFromDate" Format="yyyyMMdd" />
                        </td>
                        <td><div align="right">结束日期:</div></td>
                        <td>
                            <asp:TextBox runat="server" ID="txtToDate" Width="150px" MaxLength="8" CssClass="input"></asp:TextBox>
                            <ajaxToolkit:CalendarExtender ID="CalendarExtender2" runat="server" TargetControlID="txtToDate" Format="yyyyMMdd" />
                        </td>
                        <td><div align="right">缴费类别:</div></td>
                        <td><asp:DropDownList ID="selItemCode" CssClass="inputmid" runat="server"></asp:DropDownList></td>
                   </tr>
                   <tr>
                        <td style="width:100px;"><div align="right">缴费方式:</div></td>
                        <td>
                            <asp:DropDownList ID="selChargeType" CssClass="inputmid" runat="server"></asp:DropDownList>
                        </td>
                        
                        <td><div align="right">用户编号:</div></td>
                        <td>
                            <asp:TextBox runat="server" ID="txtCustomer_No"></asp:TextBox>
                        </td>
                        <td><div align="right">缴费状态:</div></td>
                        <td>
                            <asp:DropDownList ID="selChargeStatus" CssClass="inputmid" runat="server"></asp:DropDownList>
                        </td>
                        <td></td>
                   </tr>
                   
                   <tr>
                        <td><div align="right">操作部门:</div></td>
                        <td>
                             <asp:DropDownList ID="selDept" CssClass="inputmid" runat="server" AutoPostBack="true" OnSelectedIndexChanged="selDept_OnSelectedIndexChanged"></asp:DropDownList>
                        </td>
                        <td><div align="right">操作员工:</div></td>
                        <td>
                            <asp:DropDownList ID="selStaff" CssClass="inputmid" runat="server"></asp:DropDownList>
                        </td>
                        <td></td>
                   </tr>

               </table>
               
             </div>

            <table border="0" width="95%">
                <tr>
                    <td align="left"><div class="jieguo">查询结果</div></td>
                    <td align="right">
                        <asp:Button ID="btnQuery" CssClass="button1" runat="server" Text="查询" OnClick="btnQuery_Click"/>
                        <asp:Button ID="btnExport" CssClass="button1" runat="server" Text="导出Excel" OnClick="btnExport_Click" />
                        <asp:Button ID="btnPrint" CssClass="button1" runat="server" Text="打印" OnClientClick="return printGridView('printarea');" />
                        <asp:Button ID="btnPrintPZ" CssClass="button1" runat="server" Text="补打印凭证" OnClick="btnPrintPZ_OnClick" />
                        <div style="width: 1px; height: 1px;">
                            <asp:CheckBox ID="chkPingzheng" runat="server" Checked="True" OnClick=""/>
                        </div>
                    </td>
                </tr>
            </table>
            
              <div id="printarea" class="kuang5">
                <div id="gdtbfix" style="height:360px;">
                
                    <table id="printReport" width ="95%">
                        <tr align="center">
                            <td style ="font-size:16px;font-weight:bold">公共事业缴费记录</td>
                        </tr>
                        <tr>
                            <td>
                                <table width="300px" align="right">
                                    <tr align="right">
                                        <td>开始日期：<%=txtFromDate.Text%></td>
                                        <td>结束日期：<%=txtToDate.Text%></td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                    </table>
                
                    <asp:GridView ID="gvResult" 
                        runat="server" 
                        Width="95%" 
                        CssClass="tab1" 
                        HeaderStyle-CssClass="tabbt"    
                        AlternatingRowStyle-CssClass="tabjg" 
                        FooterStyle-CssClass="tabcon"
                        SelectedRowStyle-CssClass="tabsel" 
                        AllowPaging="false"  
                        PagerSettings-Mode="NumericFirstLast" 
                        PagerStyle-HorizontalAlign="left" 
                        PagerStyle-VerticalAlign="Top"
                        AutoGenerateColumns="False" 
                        ShowFooter="true" 
                        OnRowDataBound="gvResult_OnRowDataBound"
                        OnSelectedIndexChanged="gvResult_OnSelectedIndexChanged"
                        OnRowCreated="gvResult_OnRowCreated">
                            <Columns>
                                <asp:BoundField DataField="SEQNO" HeaderText="交易流水号" />
                                <asp:BoundField DataField="CARDNO" HeaderText="卡号" />
                                <asp:BoundField DataField="CHARGE_TYPE_DISPLAY" HeaderText="缴费方式" />
                                <asp:BoundField DataField="CHARGE_ITEM_TYPE_DISPLAY" HeaderText="缴费项目" />
                                <asp:BoundField DataField="CUSTOMER_NO" HeaderText="用户号" />
                                <asp:BoundField DataField="CUSTOMER_NAME" HeaderText="用户姓名" />
                                <asp:BoundField DataField="BILL_MONTH" HeaderText="账单月份" />
                                <asp:BoundField DataField="CONTRACT_NO" HeaderText="合同号" />
                                <asp:BoundField DataField="REAL_AMOUNT" HeaderText="缴费金额:元" NullDisplayText="0" DataFormatString="{0:n}"
                                    HtmlEncode="false" />
                                <asp:BoundField DataField="CHARGE_STATUS_DISPLAY" HeaderText="缴费状态" />
                                <asp:BoundField DataField="REQUEST_TIME" HeaderText="缴费时间" />
                                <asp:BoundField DataField="OPERATESTAFFNO" HeaderText="操作人员" />
                            </Columns>
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                        <td>
                                            卡号
                                        </td>
                                        <td>
                                            缴费方式
                                        </td>
                                        <td>
                                            缴费项目
                                        </td>
                                        <td>
                                            用户号
                                        </td>
                                        <td>
                                            用户姓名
                                        </td>
                                        <td>
                                            账单月份
                                        </td>
                                        <td>
                                            合同号
                                        </td>
                                        <td>
                                            缴费金额:元
                                        </td>
                                        <td>
                                            缴费状态
                                        </td>
                                        <td>
                                            缴费时间
                                        </td>
                                        <td>
                                            操作人员
                                        </td>
                                    </tr>
                                </table>
                            </EmptyDataTemplate>
                        </asp:GridView>
                </div>
              </div>
            </div>
                <asp:HiddenField runat="server" ID="hidSelectSeqNo"/>
            </ContentTemplate>
            <Triggers>
                <asp:PostBackTrigger ControlID="btnExport" />
            </Triggers>
        </asp:UpdatePanel>
        
    </form>
</body>
</html>
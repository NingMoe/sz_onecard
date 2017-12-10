<%@ Page Language="C#" AutoEventWireup="true" CodeFile="IT_QueryCw.aspx.cs" Inherits="ASP_InvoiceTrade_IT_QueryCw" EnableEventValidation="false" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
     <script type="text/javascript" src="../../js/print.js"></script>
    <script type="text/javascript" src="../../js/myext.js"></script>
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <title>发票查询</title>

    <script type="text/javascript">
    <!--
    function printFaPiao()
    {
        printdiv('printfapiao');
    }
       //-->
    </script>
</head>
<body> 
    <form id="form1" runat="server">
    
    <div class="tb">
		发票 -> 查询
	</div>
	
	<ajaxToolkit:ToolkitScriptManager runat="Server" EnableScriptGlobalization="true" EnableScriptLocalization="true" ID="ToolkitScriptManager2" />
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
        <asp:UpdatePanel ID="UpdatePanel1" runat="server" RenderMode="inline">  
            <ContentTemplate>  
	
	<!-- #include file="../../ErrorMsg.inc" --> 
	<aspControls:PrintFaPiao ID="ptnFaPiao" runat="server" PrintArea="printfapiao" />
	<div class="con">
	
		<div class="card">
            财务发票查询
		</div>
  
		<div class="kuang5">
		
		    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                <tr>
                    <td width="5%"><div align="right">发票号段:</div></td>
                    <td width="15%">
                            <asp:TextBox ID="txtBeginNo" CssClass="input" runat="server" MaxLength="8"></asp:TextBox>
                         -
                            <asp:TextBox ID="txtEndNo" CssClass="input" runat="server" MaxLength="8"></asp:TextBox>
                    </td>
                    <td width="15%" align="left" colspan="2">状&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;态:&nbsp;&nbsp;<asp:DropDownList ID="selState" CssClass="input" runat="server"></asp:DropDownList></td>
            
                    <td align="left" colspan="2" width="15%">营业网点：
                    <asp:DropDownList ID="selDept"  runat="server"  CssClass="inputmid"  AutoPostBack="true" OnSelectedIndexChanged="selDept_Changed"></asp:DropDownList>
                        <br />归&nbsp;&nbsp;属&nbsp;人：
                         <asp:DropDownList ID="selStaff" CssClass="inputmid"  runat="server"></asp:DropDownList>
                    </td>
                </tr>
                <tr>
                    <td><div align="right">开票日期:</div></td>
                    <td>
                        <asp:TextBox ID="txtBeginDate" CssClass="input" runat="server" MaxLength="10"></asp:TextBox>
                        <ajaxToolkit:CalendarExtender ID="BeginCalendar" runat="server" TargetControlID="txtBeginDate" Format="yyyy-MM-dd" />
                         -
                        <asp:TextBox ID="txtEndDate" CssClass="input" runat="server" MaxLength="10"></asp:TextBox>
                        <ajaxToolkit:CalendarExtender ID="EndCalendar" runat="server" TargetControlID="txtEndDate" Format="yyyy-MM-dd" />
                    </td>
                    
                    <td colspan="2" align="left">发票代码：<asp:TextBox ID="txtVolumnNo" CssClass="input"  runat="server" MaxLength="12"/></td>
                    <td colspan="2" align="left">
                    开&nbsp;&nbsp;票&nbsp;人：&nbsp;<asp:TextBox ID="txtDrawer" CssClass="input" runat="server" MaxLength="10"></asp:TextBox>
                        &nbsp;<asp:Button ID="btnQuery" CssClass="button1" Text="查询" OnClick="btnQuery_Click" runat="server" />
                    </td>
                </tr>
            </table>		
			
            <div class="gdtb" style="height:240px;padding:5px 0 0 0;">
                <asp:GridView ID="lvwInvoice" runat="server"
                    Width = "1480"
                    CssClass="tab1"
                    HeaderStyle-CssClass="tabbt"
                    AlternatingRowStyle-CssClass="tabjg"
                    SelectedRowStyle-CssClass="tabsel"
                    AllowPaging="True"
                    PageSize="200"
                    OnPageIndexChanging="lvwInvoice_Page"
                    PagerSettings-Mode="NumericFirstLast"
                    PagerStyle-HorizontalAlign="left"
                    PagerStyle-VerticalAlign="Top"
                    AutoGenerateColumns="False"
                    OnSelectedIndexChanged="lvwInvoice_SelectedIndexChanged"
                    OnRowCreated="lvwInvoice_RowCreated"
                    OnRowDataBound="lvwInvoice_RowDataBound">
                    <Columns>
                          <asp:TemplateField>
                            <HeaderTemplate>#</HeaderTemplate>
                            <ItemTemplate>
                              <%#Container.DataItemIndex + 1%>
                            </ItemTemplate>
                          </asp:TemplateField>
                           <asp:BoundField DataField="VOLUMENO"   HeaderText="发票代码"/>
                        <asp:BoundField DataField="INVOICENO"   HeaderText="发票号"/>
                        <asp:BoundField DataField="AMOUNT"    HeaderText="开票金额"/>
                        <asp:BoundField DataField="DRAWER"  HeaderText="开票人"/>
                        <asp:BoundField DataField="DRAWDATE"  HeaderText="开票日期"/>
                        <asp:BoundField DataField="PAYER"  HeaderText="付款方"/>
                        <asp:BoundField DataField="TAXNO"  HeaderText="纳税人识别号"/>
                        <asp:BoundField DataField="STATE"    HeaderText="使用状态"/>
                        <asp:BoundField DataField="ALLOTSTATE"    HeaderText="库存状态"/>
                         <asp:BoundField DataField="ALLOTDEPT"    HeaderText="归属部门"/>
                        <asp:BoundField DataField="ALLOTSTAFF"    HeaderText="归属员工"/>
                        <asp:BoundField DataField="ALLOTDATE"    HeaderText="归属时间"/>
                       
                        <asp:BoundField DataField="TRADEID"   HeaderText="记录流水号"/>
                        <asp:BoundField DataField="VOIDSTAFF"   HeaderText="作废员工"/>
                        <asp:BoundField DataField="VOIDDATE"   HeaderText="作废时间"/>
                        <asp:BoundField DataField="RSRV3"  HeaderText="验证码"/>
                    </Columns>           
                    <EmptyDataTemplate>
                        <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
	                        <tr class="tabbt">
                              <td>#</td>
                                 <td>发票代码</td>
                                <td>发票号</td>
                                <td>开票金额</td>
                                <td>开票人</td>
                                <td>开票日期</td>
                                <td>付款方</td>
                                <td>纳税人识别号</td>
                                <td>使用状态</td>
                                <td>库存状态</td>
                                 <td>归属部门</td>
                                  <td>归属员工</td>
                                <td>归属时间</td>
                                
                                 <td>记录流水号</td>
                                  <td>作废员工</td>
                                   <td>作废时间</td>
                           </tr>
                        </table>
                    </EmptyDataTemplate>
                </asp:GridView>
            </div>
            
            <div style="padding:5px 0 0 0">
                <table width="95%" border="0" cellpadding="0" cellspacing="0" class="tab1">
	                <tr>
                     <td width="8%"><div align="right">发票总数：</div></td>
                        <td width="7%">
                            <asp:Label ID="labInvoiceTotal" runat="server"></asp:Label>
                        </td>
                        <td width="10%"><div align="right">有效开票数：</div></td>
                        <td width="7%">
                            <asp:Label ID="labValidCnt" runat="server"></asp:Label>
                        </td>
                        <td width="10%"><div align="right">有效开票金额：</div></td>
                        <td width="7%">
                            <asp:Label ID="labAmount" runat="server"></asp:Label>
                        </td>
                        <td width="10%"><div align="right">作废数：</div></td>
                        <td width="7%">
                            <asp:Label ID="labVoidedCnt" runat="server"></asp:Label>
                        </td>
                        <td width="10%"><div align="right">被红冲数：</div></td>
                        <td width="7%">
                            <asp:Label ID="labReversedCnt" runat="server"></asp:Label>
                        </td>
                        <td width="10%"><div align="right">红冲数：</div></td>
                        <td width="7%">
                            <asp:Label ID="labReverseCnt" runat="server"></asp:Label>
                        </td>
                    </tr>
                </table>
            </div>
			
		</div>
		
		<div class="card">
		    发票明细 
		    <asp:Label ID="labNo2" runat="server"></asp:Label>
		    <asp:Label ID="labDrawer" runat="server"></asp:Label>
		</div>
		
		<div class="kuang5">
		    <table width="100%" border="0" cellpadding="0" cellspacing="0">
		        <tr>
		            <td width="65%" valign="top">
		                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                            <tr class="tabbt">
                                <td>项目</td>
                                <td>金额</td>
                                <td>附注</td>
                            </tr>
                            <tr>
                                <td><asp:Label ID="labProj1" runat="server"></asp:Label></td>
                                <td><asp:Label ID="labFee1" runat="server"></asp:Label></td>
                                <td rowspan="5"><asp:Label ID="labNote" runat="server"></asp:Label></td>
                            </tr>
                            <tr>
                                <td><asp:Label ID="labProj2" runat="server"></asp:Label></td>
                                <td><asp:Label ID="labFee2" runat="server"></asp:Label></td>
                            </tr>
                            <tr>
                                <td><asp:Label ID="labProj3" runat="server"></asp:Label></td>
                                <td><asp:Label ID="labFee3" runat="server"></asp:Label></td>
                            </tr>
							<tr>
                                <td><asp:Label ID="labProj4" runat="server"></asp:Label></td>
                                <td><asp:Label ID="labFee4" runat="server"></asp:Label></td>
                            </tr>
							<tr>
                                <td><asp:Label ID="labProj5" runat="server"></asp:Label></td>
                                <td><asp:Label ID="labFee5" runat="server"></asp:Label></td>
                            </tr>
                        </table>
		            </td>
		            <td width="35%">
		                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">  
                            <tr class="tabjg">
                                <td width="40%">领用状态：</td>
                                <td width="60%"><asp:Label ID="labAllotState" runat="server"></asp:Label></td>
                            </tr>
                            <tr>
                                <td>领用时间：</td>
                                <td><asp:Label ID="labAllotDate" runat="server"></asp:Label></td>
                            </tr>
                            <tr class="tabjg">
                                <td>领用部门：</td>
                                <td><asp:Label ID="labDept" runat="server"></asp:Label></td>
                            </tr>
                            <tr>
                                <td>领用员工：</td>
                                <td><asp:Label ID="labAllotStaff" runat="server"></asp:Label></td>
                            </tr>
                            <tr class="tabjg">
                                <td>作废员工：</td>
                                <td><asp:Label ID="labVoidStaff" runat="server"></asp:Label></td>
                            </tr>
                            <tr>
                                <td>作废时间：</td>
                                <td><asp:Label ID="labVoidDate" runat="server"></asp:Label></td>
                            </tr>
                        </table>
		            </td>
		        </tr>
		    </table>
		</div>
		
    </div>
            <div class="btns">
              发票代码:<span class="red"><asp:Label runat="server" ID="labVolumnNo"/></span>
           
            </div>    

    	        </ContentTemplate>  
        </asp:UpdatePanel>  
     
    </form>
             
</body>
</html>

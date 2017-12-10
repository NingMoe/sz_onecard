<%@ Page Language="C#" AutoEventWireup="true" CodeFile="EM_BalanceRelation.aspx.cs" Inherits="ASP_EquipmentManagement_EM_BalanceRelation" EnableEventValidation="false" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <script type="text/javascript" src="../../js/myext.js"></script>
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <title>设备结算关系</title>
</head>
<body> 
    <form id="form1" runat="server">
    
    <div class="tb">
		设备管理->设备结算单元建立
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
        <asp:UpdatePanel ID="UpdatePanel1" runat="server">  
            <ContentTemplate>  
	
<asp:BulletedList ID="bulMsgShow" runat="server"/>
<script runat="server" >public override void ErrorMsgShow(){ErrorMsgHelper(bulMsgShow);}</script>
	
	<div class="con">
	
		<div class="card">
            设备结算关系查询
		</div>
  
		<div class="kuang5">
  
			<table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
				<tr>
					<td style="text-align:right;">POS来源:</td>
					<td><asp:DropDownList ID="selSource1" CssClass="inputmid" runat="server"></asp:DropDownList>
                    </td>	
					<td style="text-align:right;">POS编号:</td>
					<td><asp:TextBox ID="txtPosNo1" CssClass="inputmid" runat="server" MaxLength="6"></asp:TextBox>
                    </td>
					<td style="text-align:right;">PSAM号:</td>
					<td><asp:TextBox ID="txtPsamNo1" CssClass="inputmid" runat="server" MaxLength="12"></asp:TextBox>
					</td>
                </tr>
                <tr>
                    <td style="text-align:right;">行业:</td>
                    <td colspan="3" ><asp:DropDownList ID="selCalling1" CssClass="inputmidder" runat="server" AutoPostBack="true" OnSelectedIndexChanged="selCalling1_SelectedIndexChanged"></asp:DropDownList>
                    </td>
                    <td style="text-align:right;">起始日期:</td>
                    <td><asp:TextBox ID="txtStartDate" CssClass="inputmid" runat="server"></asp:TextBox>
                        <ajaxToolkit:CalendarExtender ID="BeginCalendar" runat="server" TargetControlID="txtStartDate" Format="yyyy-MM-dd"/>
                    </td>
                    </tr>
                    <tr>
                    <td style="text-align:right;">单位:</td>
                    <td colspan="3">
                        <asp:DropDownList ID="selCorp1" CssClass="inputmidder" runat="server" AutoPostBack="true" OnSelectedIndexChanged="selCorp1_SelectedIndexChanged"></asp:DropDownList>
                    </td>
                    <td style="text-align:right;">终止日期:</td>
                    <td>
                        <asp:TextBox ID="txtEndDate" CssClass="inputmid" runat="server"></asp:TextBox>
                        <ajaxToolkit:CalendarExtender ID="EndCalendar" runat="server" TargetControlID="txtEndDate" Format="yyyy-MM-dd" />
                    </td>
                    			
				</tr>
				<tr>
                    <td style="text-align:right;">部门:</td>
                    <td colspan="3">
                        <asp:DropDownList ID="selDept1" CssClass="inputmidder" runat="server"></asp:DropDownList>
                    </td>
                    <td>&nbsp;</td>
                    <td>
					    <asp:Button ID="btnQuery" CssClass="button1" runat="server" OnClick="btnQuery_Click" Text="查询" />
					</td>
				</tr>
			</table>
				
			<div class="kuang5">
				<div class="gdtb" style="height:170px">
				
				    <asp:GridView ID="lvwRelation" runat="server"
                            Width = "1800"
                            CssClass="tab1"
                            HeaderStyle-CssClass="tabbt"
                            AlternatingRowStyle-CssClass="tabjg"
                            SelectedRowStyle-CssClass="tabsel"
                            PagerSettings-Mode="NumericFirstLast"
                            PagerStyle-HorizontalAlign="left"
                            PagerStyle-VerticalAlign="Top"
                            AutoGenerateColumns="False"
                            AllowPaging="true"
        		            PageSize="50"
                            OnPageIndexChanging="lvwRelation_Page"
                            OnSelectedIndexChanged="lvwRelation_SelectedIndexChanged"
                            OnRowCreated="lvwRelation_RowCreated">
                        <Columns>
                            <asp:BoundField DataField="CALLING"   HeaderText="行业"/>
                            <asp:BoundField DataField="CORP"    HeaderText="单位"/>
                            <asp:BoundField DataField="DEPT"    HeaderText="部门"/>
                            <asp:BoundField DataField="POSNO"    HeaderText="POS编号"/>
                            <asp:BoundField DataField="PSAMNO"    HeaderText="PSAM号"/>
                            <asp:BoundField DataField="BALANCEUNIT"    HeaderText="结算单元"/>
                            <asp:BoundField DataField="MANAGER"    HeaderText="商户经理"/>
                            <asp:TemplateField HeaderText="POS来源">
                                <ItemTemplate>
                                    <asp:Label ID="labPosSource" Text='<%# Eval("USETYPECODE").ToString() == "1" ? "本公司提供" : (Eval("USETYPECODE").ToString() == "0"?"商户自有":"") %>' runat="server"></asp:Label>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="是否支持联机消费">
                                <ItemTemplate>
                                    <asp:Label ID="labIsLimit" Text='<%# Eval("tlsamno").ToString() == "" ? "不支持" : (Eval("USETYPECODE").ToString() != ""?"支持":"") %>' runat="server"></asp:Label>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:BoundField DataField="BUILDTIME"  HeaderText="建立时间"/>
                            
                            <asp:BoundField DataField="NOTE"  HeaderText="备注"/>
                        </Columns>           
                        <EmptyDataTemplate>
                            <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
				                <tr class="tabbt">
                                    <td>行业</td>
                                    <td>单位</td>
                                    <td>部门</td>
                                    <td>POS编号</td>
                                    <td>PSAM号</td>
                                    <td>结算单元</td>
                                    <td>商户经理</td>          
                                    <td>POS来源</td>  
                                    <td>是否支持联机消费</td>        
		                            <td>建立时间</td>
		                            <td>备注</td>
                                </tr>
                            </table>
                        </EmptyDataTemplate>
                    </asp:GridView>
				</div>
			</div>
			
		</div>
		
		<div class="card">
		    设备结算关系处理
		</div>
		
		<div class="kuang5">
  
			<table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
				<tr>
					<td align="right">POS来源:</td>
					<td><asp:DropDownList ID="selSource2" CssClass="inputmid" runat="server" AutoPostBack="true" OnSelectedIndexChanged="selSource2_SelectedIndexChanged"></asp:DropDownList>
                    </td>	
					<td align="right">POS编号:</td>
					<td><asp:TextBox ID="txtPosNo2" CssClass="inputmid" runat="server" MaxLength="6"></asp:TextBox>
					</td>
				</tr>
				<tr>
					<td align="right">行业:</td>
					<td><asp:DropDownList ID="selCalling2" CssClass="inputmidder" runat="server" AutoPostBack="true" OnSelectedIndexChanged="selCalling2_SelectedIndexChanged"></asp:DropDownList>
				    </td>
					<td align="right">PSAM号:</td>
					<td><asp:TextBox ID="txtPsamNo2" CssClass="inputmid" runat="server" MaxLength="12"></asp:TextBox>
                    </td>
                </tr>
                <tr>
					<td align="right">单位:</td>
					<td><asp:DropDownList ID="selCorp2" CssClass="inputmidder" runat="server" AutoPostBack="true" OnSelectedIndexChanged="selCorp2_SelectedIndexChanged"></asp:DropDownList>
                    </td>
                    <td align="right">PSAM共用:
                    </td>
                    <td><asp:DropDownList ID="selPsamJointUse" runat="server" CssClass="inputmid" AutoPostBack="true" OnSelectedIndexChanged="selPsamJointUse_SelectedIndexChanged">
                        <asp:ListItem Text="普通商户" Value="0" />
                        <asp:ListItem Text="中石化商户" Value="1" />
                        <%--<asp:ListItem Text="0001:加油站购物" Value="0001" />--%>
                    </asp:DropDownList>
                    </td>
				</tr>
				<tr>
					<td align="right">部门:</td>
                    <td><asp:DropDownList ID="selDept2" CssClass="inputmidder" runat="server" AutoPostBack="true" OnSelectedIndexChanged="selDept2_SelectedIndexChanged"></asp:DropDownList>
		            </td>
					<td align="right">商户经理:</td>
					<td><asp:DropDownList ID="selManager" CssClass="inputmid" runat="server"></asp:DropDownList>
					</td>
				</tr>
				<tr>
		            <td align="right">结算单元:</td>
                    <td><asp:DropDownList ID="selBalanceUnit" CssClass="inputmidder" runat="server"></asp:DropDownList>
	                </td>	
				<td align="right">备注:</td>
                    <td><asp:TextBox ID="txtNote" CssClass="inputlong" runat="server"></asp:TextBox>
                    </td>
                </tr>
                <tr>
                <td align="right">是否支持联机消费:</td>
                    <td>
                        <asp:CheckBox ID="chkIsLimit" runat="server" />
	                </td>
                </tr>
                
                <asp:Panel  runat="server" ID="palSelUnit" Visible="false">
                    <tr>
                    <td align="right">非油品结算单元:</td>
                    <td><asp:DropDownList ID="selUnit" CssClass="inputmidder" runat="server"></asp:DropDownList>
	                </td>	
                    </tr>
				</asp:Panel>
			</table>
		</div>
		
		<div class="btns">
            <table width="100%" border="0" cellpadding="0" cellspacing="0">
                <tr>   
                    <td align="right">
                        <asp:Button ID="btnBuild" CssClass="button1" runat="server" OnClick="btnBuild_Click" Text="建立" />
                        <asp:Button ID="btnChange" CssClass="button1" runat="server" OnClick="btnChange_Click" Text="更换" />
                        <asp:Button ID="btnCancel" CssClass="button1" runat="server" OnClick="btnCancel_Click" Text="终止" />
                    </td>
                </tr>
            </table>
        </div>

   </div>
    
    	        </ContentTemplate>  
        </asp:UpdatePanel>  
     
    </form>
             
</body>
</html>

<%@ Page Language="C#" AutoEventWireup="true" CodeFile="EM_PsamQuery.aspx.cs" Inherits="ASP_EquipmentManagement_EM_PsamQuery" EnableEventValidation="false" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <title>PSAM卡库存查询</title>
</head>
<body>
    <form id="form1" runat="server">
    
	    <div class="tb">
		    设备管理->PSAM卡库存查询
	    </div>
	
	    <ajaxToolkit:ToolkitScriptManager runat="Server" EnableScriptGlobalization="true" EnableScriptLocalization="true" ID="ToolkitScriptManager1" />
        <asp:UpdatePanel ID="UpdatePanel2" runat="server">  
            <ContentTemplate>  
               
            <!-- #include file="../../ErrorMsg.inc" -->  
	        <div class="con">
	
		        <div class="card">
                    PSAM卡库存查询
		        </div>
        		
		        <div class="kuang5">
          
			        <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
				        <tr>
				        <td><div align="right">行业:</div></td>
					        <td><asp:DropDownList ID="selCalling2" CssClass="inputmidder" runat="server" AutoPostBack="true" OnSelectedIndexChanged="selCalling2_SelectedIndexChanged"></asp:DropDownList>
					        </td>
					        <td><div align="right">PSAM卡号:</div></td>
					        <td><asp:TextBox ID="txtPsamNo" CssClass="inputmid" runat="server" MaxLength="12"></asp:TextBox>
					        </td>
				        </tr>
				        <tr>
					        <td><div align="right">单位:</div></td>
					        <td><asp:DropDownList ID="selCorp2" CssClass="inputmidder" runat="server" AutoPostBack="true" OnSelectedIndexChanged="selCorp2_SelectedIndexChanged"></asp:DropDownList>
                            </td>
                            <td><div align="right">状态:</div></td>
					        <td><asp:DropDownList ID="selPsamState" CssClass="inputmid" runat="server"></asp:DropDownList>
					        </td>
					    </tr>
					    <tr>
                            <td style="text-align: right;">部门:</td>
                            <td><asp:DropDownList ID="selDept2" CssClass="inputmidder" runat="server"></asp:DropDownList>
                            </td>
					        <td>&nbsp;</td>
					        <td><asp:Button  ID="btnPsamQuery" CssClass="button1" runat="server" Text="查询" OnClick="btnPsamQuery_Click" /></td>
				        </tr>
			        </table>
        				
			        <div class="kuang5">
				        <div class="gdtb" style="height:395px">
				            <asp:GridView ID="lvwPsam" runat="server"
                                    Width = "1700"
                                    CssClass="tab1"
                                    HeaderStyle-CssClass="tabbt"
                                    AlternatingRowStyle-CssClass="tabjg"
                                    SelectedRowStyle-CssClass="tabsel"
                                    AllowPaging="true"
                                    OnPageIndexChanging="lvwPsam_Page"
                                    PageSize="14"
                                    PagerSettings-Mode="NumericFirstLast"
                                    PagerStyle-HorizontalAlign="left"
                                    PagerStyle-VerticalAlign="Top"
                                    AutoGenerateColumns="False"
                                    OnRowDataBound="lvwPsam_RowDataBound">
                                <Columns>
                                    <asp:BoundField DataField="PSAMNO"   HeaderText="PSAM卡号"/>
                                    <asp:BoundField DataField="RESSTATE" HeaderText="库存状态" />
                                    <asp:BoundField DataField="CALLING" HeaderText="行业" />
                                    <asp:BoundField DataField="CORP" HeaderText="单位" />
                                    <asp:BoundField DataField="DEPT"  HeaderText="部门"/>
                                    <asp:BoundField DataField="INSTIME" HeaderText="入库时间" />
                                    <asp:BoundField DataField="OUTTIME" HeaderText="出库时间" />
                                    <asp:BoundField DataField="REINTIME"  HeaderText="归还时间"/>
                                    <asp:BoundField DataField="DESTROYTIME" HeaderText="作废时间" />
                                    <asp:BoundField DataField="ASSIGNEDSTAFF"  HeaderText="所属员工"/>
                                    <asp:BoundField DataField="COSTYPE"    HeaderText="COS类型"/>
                                    <asp:BoundField DataField="CARDTYPE" HeaderText="卡片类型" />
                                    <asp:BoundField DataField="CARDPRICE" HeaderText="卡片价格" />
                                    <%--<asp:TemplateField HeaderText="卡片价格(元)">
                                        <ItemTemplate>
                                            <asp:Label ID="labPsamPrice" Text='<%# (int)Eval("CARDPRICE")*1.0/100 %>' runat="server"></asp:Label>
                                        </ItemTemplate>
                                    </asp:TemplateField> --%>
                                    <asp:BoundField DataField="CARDMANU" HeaderText="卡片厂商" />
                                </Columns>           
                                <EmptyDataTemplate>
                                    <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
				                        <tr class="tabbt">							
						                    <td>PSAM卡号</td>
						                    <td>库存状态</td>
						                    <td>行业</td>
						                    <td>单位</td>
						                    <td>部门</td>
						                    <td>入库时间</td>
						                    <td>出库时间</td>
						                    <td>归还时间</td>
						                    <td>作废时间</td>
						                    <td>所属员工</td>
						                    <td>COS类型</td>
						                    <td>卡片类型</td>
						                    <td>设备价格(元)</td>
						                    <td>卡片厂商</td>
						                </tr>
                                    </table>
                                </EmptyDataTemplate>
                            </asp:GridView>
					        
				        </div>
			        </div>
        			
		        </div>
        		
           </div>
	        
	        </ContentTemplate>  
        </asp:UpdatePanel>  
     
    </form>
             
</body>
</html>
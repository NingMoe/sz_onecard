<%@ Page Language="C#" AutoEventWireup="true" CodeFile="EM_PosQuery.aspx.cs" Inherits="ASP_EquipmentManagement_EM_PosQuery" EnableEventValidation="false" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <title>POS库存查询</title>
</head>
<body>
    <form id="form1" runat="server">
    
	    <div class="tb">
		    设备管理->设备库存查询
	    </div>
	
	    <ajaxToolkit:ToolkitScriptManager runat="Server" EnableScriptGlobalization="true" EnableScriptLocalization="true" ID="ToolkitScriptManager1" />
        <asp:UpdatePanel ID="UpdatePanel2" runat="server">  
            <ContentTemplate>  
               
            <!-- #include file="../../ErrorMsg.inc" -->  
	        <div class="con">
	
		        <div class="card">
                    POS库存查询
		        </div>
          
		        <div class="kuang5">
          
			        <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
				        <tr>
				        <td><div align="right">行业:</div></td>
					        <td>
						        <asp:DropDownList ID="selCalling1" CssClass="inputmidder" runat="server" AutoPostBack="true" OnSelectedIndexChanged="selCalling1_SelectedIndexChanged"></asp:DropDownList>
					        </td>
					        <td><div align="right">POS编号:</div></td>
					        <td>
                                <asp:TextBox ID="txtPosNo" CssClass="inputmid" MaxLength="6" runat="server"></asp:TextBox>
					        </td>
					        <td>&nbsp;</td>
					        </tr>
					        <tr>
					        <td><div align="right">单位:</div></td>
					        <td>
                                <asp:DropDownList ID="selCorp1" CssClass="inputmidder" runat="server" AutoPostBack="true" OnSelectedIndexChanged="selCorp1_SelectedIndexChanged"></asp:DropDownList>
                            </td>
					        <td><div align="right">状态:</div></td>
					        <td>
						        <asp:DropDownList ID="selPosState" CssClass="inputmid" runat="server"></asp:DropDownList>
					        </td>
					       <td>&nbsp;</td>
				        </tr>
				        <tr>
					        
					        
                            <td style="text-align: right;">部门:</td>
                            <td>
						        <asp:DropDownList ID="selDept1" CssClass="inputmidder" runat="server"></asp:DropDownList>
                            </td>
                             <td><div align="right">POS来源:</div></td>
					        <td><asp:DropDownList ID="selSource" CssClass="inputmid" runat="server"></asp:DropDownList></td>
					        <td><div align="center"><asp:Button ID="btnPosQuery" CssClass="button1" runat="server" Text="查询" OnClick="btnPosQuery_Click"/></div></td>
					        
				        </tr>
			        </table>
        				
			        <div class="kuang5">
				        <div class="gdtb" style="height:395px">
				            <asp:GridView ID="lvwPos" runat="server"
                                    Width = "1900"
                                    CssClass="tab1"
                                    HeaderStyle-CssClass="tabbt"
                                    AlternatingRowStyle-CssClass="tabjg"
                                    SelectedRowStyle-CssClass="tabsel"
                                    AllowPaging="true"
                                    PageSize="14"
                                    PagerSettings-Mode="NumericFirstLast"
                                    PagerStyle-HorizontalAlign="left"
                                    PagerStyle-VerticalAlign="Top"
                                    AutoGenerateColumns="False"
                                    OnPageIndexChanging="lvwPos_Page"
                                    OnRowDataBound="lvwPos_RowDataBound">
                                <Columns>
                                    <asp:BoundField DataField="POSNO"   HeaderText="POS编号"/>      
                                    <asp:TemplateField HeaderText="POS来源">
                                        <ItemTemplate>
                                            <asp:Label ID="labPosSource" Text='<%# Eval("POSSOURCE").ToString() == "1" ? "本公司提供" : "商户自有" %>' runat="server"></asp:Label>
                                        </ItemTemplate>
                                    </asp:TemplateField>      
                                    <asp:BoundField DataField="RESSTATE" HeaderText="库存状态" />
                                    <asp:BoundField DataField="CALLING" HeaderText="行业" />
                                    <asp:BoundField DataField="CORP" HeaderText="单位" />
                                    <asp:BoundField DataField="DEPT"  HeaderText="部门"/>
                                    <asp:BoundField DataField="INSTIME" HeaderText="入库时间" />
                                    <asp:BoundField DataField="OUTTIME" HeaderText="出库时间" />
                                    <asp:BoundField DataField="REINTIME" HeaderText="归还时间" />
                                    <asp:BoundField DataField="DESTROYTIME"  HeaderText="作废时间"/>
                                    <asp:BoundField DataField="ASSIGNEDSTAFF"  HeaderText="所属员工"/>
                                    <asp:BoundField DataField="POSMODE"    HeaderText="POS型号"/> 
                                    <asp:BoundField DataField="TOUCHTYPE" HeaderText="接触类型" />
                                    <asp:BoundField DataField="LAYTYPE" HeaderText="放置类型" />
                                    <asp:BoundField DataField="COMMTYPE" HeaderText="通信类型" />
                                    <asp:BoundField DataField="EQUPRICE" HeaderText="价格" />
                                    <%--<asp:TemplateField HeaderText="价格(元)">
                                        <ItemTemplate>
                                            <asp:Label ID="labPosPrice" Text='<%# ((int)Eval("EQUPRICE"))*1.0/100 %>' runat="server"></asp:Label>
                                        </ItemTemplate>
                                    </asp:TemplateField>--%>
                                    <asp:BoundField DataField="HARDWARENUM" HeaderText="硬件序列号" />
                                </Columns>           
                                <EmptyDataTemplate>
                                    <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
				                        <tr class="tabbt">
						                    <td>POS编号</td> 
							                <td>POS来源</td>
						                    <td>库存状态</td>
						                    <td>行业</td>
						                    <td>单位</td>
						                    <td>部门</td>
						                    <td>入库时间</td>
						                    <td>出库时间</td>
						                    <td>归还时间</td>
						                    <td>作废时间</td>
						                    <td>所属员工</td>
						                    <td>POS型号</td>
						                    <td>接触类型</td>
						                    <td>放置类型</td>
						                    <td>通信类型</td>
						                    <td>价格(元)</td>
							                <td>硬件序列号</td>
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
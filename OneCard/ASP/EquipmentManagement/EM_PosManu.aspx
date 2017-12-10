<%@ Page Language="C#" AutoEventWireup="true" CodeFile="EM_PosManu.aspx.cs" Inherits="ASP_EquipmentManagement_EM_PosManu" EnableEventValidation="false" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <title>POS厂商维护</title>
</head>
<body>
    <form id="form1" runat="server">
    
	    <div class="tb">
		    设备管理->POS厂商维护
	    </div>
	
	    <ajaxToolkit:ToolkitScriptManager runat="Server" EnableScriptGlobalization="true" EnableScriptLocalization="true" ID="ToolkitScriptManager1" />
        <asp:UpdatePanel ID="UpdatePanel2" runat="server">  
            <ContentTemplate>  
               
            <!-- #include file="../../ErrorMsg.inc" -->  
	        <div class="con">
        	
		        <div class="card">
			        POS厂商维护
		        </div>
        		
		        <div class="kuang5">
			        <div class="gdtb" style="height:305px">
			        
			            <asp:GridView ID="lvwPosManu" runat="server"
                                Width = "1100"
                                CssClass="tab1"
                                HeaderStyle-CssClass="tabbt"
                                AlternatingRowStyle-CssClass="tabjg"
                                SelectedRowStyle-CssClass="tabsel"
                                AllowPaging="true"
                                PageSize="10"
                                OnPageIndexChanging="lvwPosManu_Page"
                                PagerSettings-Mode="NumericFirstLast"
                                PagerStyle-HorizontalAlign="left"
                                PagerStyle-VerticalAlign="Top"
                                AutoGenerateColumns="False"                                
                                OnSelectedIndexChanged="lvwPosManu_SelectedIndexChanged"
                                OnRowCreated="lvwPosManu_RowCreated">
                            <Columns>
                                <asp:BoundField DataField="POSMANUCODE"   HeaderText="厂商编码"/>
                                <asp:BoundField DataField="POSMANUNAME"    HeaderText="厂商名称"/>
                                <asp:BoundField DataField="PHONE"  HeaderText="厂商电话"/>
                                <asp:BoundField DataField="FAX"  HeaderText="厂商传真"/>
                                <asp:BoundField DataField="ZIPCODE"  HeaderText="厂商邮编"/>
                                <asp:BoundField DataField="EMAIL"  HeaderText="厂商EMAIL"/>
                                <asp:BoundField DataField="ADDRESS"  HeaderText="厂商地址"/>
                                <asp:TemplateField HeaderText="有效标志">
                                    <ItemTemplate>
                                        <asp:Label ID="labUseTag" Text='<%# Eval("USETAG").ToString() == "1" ? "有效" : "无效" %>' runat="server"></asp:Label>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>           
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
				                    <tr class="tabbt">
				                        <td>厂商编码</td>
				                        <td>厂商名称</td>
					                    <td>厂商电话</td>
					                    <td>厂商传真</td>
					                    <td>厂商邮编</td>
					                    <td>厂商EMAIL</td>
					                    <td>厂商地址</td>
					                    <td>有效标志</td>
				                    </tr>
                                </table>
                            </EmptyDataTemplate>
                        </asp:GridView>

			        </div>
		        </div>
        	
		        <div class="kuang5">
			        <table border="0" cellpadding="0" cellspacing="0" class="text25">
				        <tr>
				            <td width="80"><div align="right">编码:</div></td>
				            <td>
				                <asp:TextBox ID="txtCode" CssClass="input" MaxLength="2" runat="server"></asp:TextBox>
				            </td>
				            <td width="100"><div align="right">厂商:</div></td>
				            <td>
				                <asp:TextBox ID="txtName" CssClass="input" MaxLength="50" runat="server"></asp:TextBox>
				            </td>
				            <td width="100"><div align="right">电话:</div></td>
				            <td>
				                <asp:TextBox ID="txtPhone" CssClass="input" MaxLength="20" runat="server"></asp:TextBox>
				            </td>
					        <td width="200">&nbsp;</td>
				        </tr>
				        <tr>
				            <td><div align="right">传真:</div></td>
				            <td>
				                <asp:TextBox ID="txtFax" CssClass="input" MaxLength="20" runat="server"></asp:TextBox>
				            </td>
				            <td><div align="right">邮编:</div></td>
				            <td>
				                <asp:TextBox ID="txtZip" CssClass="input" MaxLength="6" runat="server"></asp:TextBox>
				            </td>
				            <td><div align="right">MAIL:</div></td>
				            <td>
				                <asp:TextBox ID="txtMail" CssClass="inputlong" MaxLength="30" runat="server"></asp:TextBox>
				            </td>
					        <td>&nbsp;</td>
				        </tr>
				        <tr>
				            <td><div align="right">地址:</div></td>
				            <td colspan="6">
				                <asp:TextBox ID="txtAddress" CssClass="inputlong" MaxLength="50" runat="server"></asp:TextBox>
				            </td>
				        </tr>
				        <tr>
				            <td><div align="right">有效标志:</div></td>
				            <td colspan="6">
						        <asp:DropDownList ID="selUseTag" CssClass="input" runat="server"></asp:DropDownList>
					        </td>
				        </tr>
				        <tr>
				            <td colspan="7">
						        <table width="30%" border="0" align="right" cellpadding="0" cellspacing="0">
							        <tr>
						                <td>
						                    <asp:Button ID="btnAdd" CssClass="button1" Text="增加" OnClick="btnAdd_Click" runat="server" />
						                </td>
						                <td>
						                    <asp:Button ID="btnModify" CssClass="button1" Text="修改" OnClick="btnModify_Click" runat="server" />
						                </td>
							        </tr>
						        </table>
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

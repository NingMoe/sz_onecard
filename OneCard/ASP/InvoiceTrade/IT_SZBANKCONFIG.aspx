<%@ Page Language="C#" AutoEventWireup="true" CodeFile="IT_SZBANKCONFIG.aspx.cs" Inherits="ASP_InvoiceTrade_IT_SZBANKCONFIG" EnableEventValidation="false" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <title>苏信开户行配置</title>
</head>
<body>
    <form id="form1" runat="server">
    
	    <div class="tb">
		    发票->苏信开户行配置
	    </div>
	
	    <ajaxToolkit:ToolkitScriptManager runat="Server" EnableScriptGlobalization="true" EnableScriptLocalization="true" ID="ToolkitScriptManager1" />
        <asp:UpdatePanel ID="UpdatePanel2" runat="server">  
            <ContentTemplate>  
               
            <!-- #include file="../../ErrorMsg.inc" -->  
	        <div class="con">
        	
		        <div class="card">
			        苏信开户行配置
		        </div>
        		
		        <div class="kuang5">
			        <div class="gdtb" style="height:305px">
			        
			            <asp:GridView ID="lvwCosType" runat="server"
                                Width = "1000"
                                CssClass="tab1"
                                HeaderStyle-CssClass="tabbt"
                                AlternatingRowStyle-CssClass="tabjg"
                                SelectedRowStyle-CssClass="tabsel"
                                AllowPaging="true"
                                PageSize="10"
                                OnPageIndexChanging="lvwCosType_Page"
                                PagerSettings-Mode="NumericFirstLast"
                                PagerStyle-HorizontalAlign="left"
                                PagerStyle-VerticalAlign="Top"
                                AutoGenerateColumns="False"                                
                                OnSelectedIndexChanged="lvwCosType_SelectedIndexChanged"
                                OnRowCreated="lvwCosType_RowCreated">
                            <Columns>
                                <asp:BoundField DataField="BANKNAME"   HeaderText="开户行名称"/>
                                <asp:BoundField DataField="BANKCODE"    HeaderText="开户行帐号"/>
                                <asp:BoundField DataField="PayeeName"    HeaderText="收款方名称"/>
                                  <asp:TemplateField HeaderText="是否默认">
                                    <ItemTemplate>
                                        <asp:Label ID="labIsDefault" Text='<%# Eval("IsDefault").ToString() == "1" ? "是" : "否" %>' runat="server"></asp:Label>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="有效标志">
                                    <ItemTemplate>
                                        <asp:Label ID="labUseTag" Text='<%# Eval("USETAG").ToString() == "1" ? "有效" : "无效" %>' runat="server"></asp:Label>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>           
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
				                    <tr class="tabbt">
				                        <td>开户行名称</td>
				                        <td>开户行帐号</td>
                                        <td>收款方名称</td>
					                    <td>是否默认</td>
					                    <td>有效标志</td>
				                    </tr>
                                </table>
                            </EmptyDataTemplate>
                        </asp:GridView>

			        </div>
		        </div>
        	
		        <div class="kuang5">
			        <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
				        <tr>
				            <td width="15%"><div align="right">开户行名称:</div></td>
				            <td width="85%">
				                <asp:TextBox ID="txtBankName" CssClass="inputlong" runat="server"></asp:TextBox>
				            </td>
				        </tr>
				        <tr>
				            <td><div align="right">开户行帐号:</div></td>
				            <td>
				                <asp:TextBox ID="txtBankCode" CssClass="inputlong"  runat="server"></asp:TextBox>
				            </td>
				        </tr>
                        <tr>
				            <td><div align="right">收款方名称:</div></td>
				            <td>
				                <asp:TextBox ID="txtPayeeName" CssClass="inputlong"  runat="server"></asp:TextBox>
				            </td>
				        </tr>
				        <tr>
				            <td><div align="right">是否默认:</div></td>
				            <td>
				                <asp:CheckBox ID="cbxIsDefault" runat="server" />
				            </td>
				        </tr>
				        <tr>
				            <td><div align="right">有效标志:</div></td>
				            <td>
						        <asp:DropDownList ID="selUseTag" CssClass="input" runat="server"></asp:DropDownList>
					        </td>
				        </tr>
                        <tr>
				            <td><div align="right"><font color="red">（*）注:</font></div></td>
				            <td>
						        <font color="red">开户行名称唯一，不能修改</font>
					        </td>
				        </tr>
				        <tr>
				            <td colspan="2">
						        <table width="30%" border="0" align="right" cellpadding="0" cellspacing="0">
							        <tr>
						                <td>
						                    <asp:Button ID="btnAdd" CssClass="button1" Text="增加" OnClick="btnAdd_Click" runat="server" />
						                </td>
                                        <td>
						                    <asp:Button ID="btnModify" CssClass="button1" Text="修改" OnClick="btnModify_Click" runat="server" />
						                </td>
						                <td>
						                    <asp:Button ID="btnDelete" CssClass="button1" Text="删除" OnClick="btnDelete_Click" runat="server" />
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

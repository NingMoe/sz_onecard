<%@ Page Language="C#" AutoEventWireup="true" CodeFile="EM_CardManu.aspx.cs" Inherits="ASP_EquipmentManagement_EM_CardManu" EnableEventValidation="false" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <title>卡厂商信息维护</title>
</head>
<body>
    <form id="form1" runat="server">
    
        <div class="tb">设备管理->卡厂商信息维护</div>

        <ajaxToolkit:ToolkitScriptManager runat="Server" EnableScriptGlobalization="true"
            EnableScriptLocalization="true" ID="ScriptManager2" />
        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
            <ContentTemplate>
            <!-- #include file="../../ErrorMsg.inc" --> 
           
        <div class="con">

            <div class="base">
                卡厂商信息维护
            </div>
    
            <div class="kuang5">
                <div class="gdtb" style="height:305px">
			        <asp:GridView ID="lvwCardManu" runat="server"
                            Width = "1000"
                            CssClass="tab1"
                            HeaderStyle-CssClass="tabbt"
                            AlternatingRowStyle-CssClass="tabjg"
                            SelectedRowStyle-CssClass="tabsel"
                            AllowPaging="True"
                            PageSize="10"
                            OnPageIndexChanging="lvwCardManu_Page"
                            PagerSettings-Mode="NumericFirstLast"
                            PagerStyle-HorizontalAlign="left"
                            PagerStyle-VerticalAlign="Top"
                            AutoGenerateColumns="False"
                            OnSelectedIndexChanged="lvwCardManu_SelectedIndexChanged"
                            OnRowCreated="lvwCardManu_RowCreated">
                            <Columns>
                                <asp:BoundField DataField="MANUCODE"   HeaderText="厂商编码"/>
                                <asp:BoundField DataField="MANUNAME"    HeaderText="厂商名称"/>
                                <asp:BoundField DataField="MANUNOTE"  HeaderText="厂商说明"/>
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
                                <td>厂商说明</td>
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
				        <td width="15%"><div align="right">厂商编码:</div></td>
				        <td width="85%">
				            <asp:TextBox ID="txtCardManuCode" CssClass="input" runat="server" MaxLength="2"></asp:TextBox>
				        </td>
				    </tr>
				    <tr>
					    <td><div align="right">厂商名称:</div></td>
					    <td>
					        <asp:TextBox ID="txtCardManuName" CssClass="inputlong" runat="server" MaxLength="50"></asp:TextBox>
					    </td>
				    </tr>
				    <tr>
				        <td><div align="right">厂商说明:</div></td>
				        <td>
						    <asp:TextBox ID="txtCardManuNote" CssClass="inputlong" runat="server" MaxLength="150"></asp:TextBox>
					    </td>
				    </tr>
				    <tr>
				        <td><div align="right">有效标志:</div></td>
				        <td>
				            <asp:DropDownList ID="selUseTag" CssClass="input" runat="server"></asp:DropDownList>
					    </td>
				    </tr>
				    <tr>
				        <td colspan="2">
						    <table width="30%" border="0" align="right" cellpadding="0" cellspacing="0">
							    <tr>
						            <td>
						                <asp:Button ID="btnAdd" CssClass="button1" Text="增加" runat="server" OnClick="btnAdd_Click" />
						            </td>
						            <td>
						                <asp:Button ID="btnModify" CssClass="button1" Text="修改" runat="server" OnClick="btnModify_Click" />
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
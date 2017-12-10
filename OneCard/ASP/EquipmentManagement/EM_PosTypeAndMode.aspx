<%@ Page Language="C#" AutoEventWireup="true" CodeFile="EM_PosTypeAndMode.aspx.cs" Inherits="ASP_EquipmentManagement_EM_PosTypeAndMode" EnableEventValidation="false" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <title>设备类型及型号维护</title>
</head>
<body>
    <form id="form1" runat="server">
    
    <div class="tb">
	    设备管理->设备类型及型号维护
	</div>
	
	<asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
    <asp:UpdatePanel ID="UpdatePanel1" runat="server" >
    <ContentTemplate>
         
    <!-- #include file="../../ErrorMsg.inc" -->     
	<div class="con">
	
		<div class="card">
			设备类型及型号维护
		</div>
		
		<div class="kuang5">
			<table width="95%" border="0" cellpadding="0" cellspacing="0" class="12text">
			  <tr>
			    <td width="13%"><div align="right">查询对象:</div></td>
			    <td width="19%">
					<asp:DropDownList ID="selTable" CssClass="input" runat="server"></asp:DropDownList>
					<asp:HiddenField ID="hidTable" Value="" runat="server" />
				</td>
			    <td width="9%">&nbsp;</td>
			    <td width="45%">&nbsp;</td>
			    <td width="14%">
			        <asp:Button ID="btnQuery" CssClass="button1" Text="查询" runat="server" OnClick="btnQuery_Click"/>
			    </td>
			    </tr>
			</table>
		</div>
	
		<div class="kuang5">
			<div class="gdtb" style="height:290px">
                        			
			    <asp:GridView ID="lvwEquipTypeAndMode" runat="server"
                        Width = "1000"
                        CssClass="tab1"
                        HeaderStyle-CssClass="tabbt"
                        AlternatingRowStyle-CssClass="tabjg"
                        SelectedRowStyle-CssClass="tabsel"
                        AllowPaging="True"
                        PageSize="9"
                        OnPageIndexChanging="lvwEquipTypeAndMode_Page"
                        PagerSettings-Mode="NumericFirstLast"
                        PagerStyle-HorizontalAlign="left"
                        PagerStyle-VerticalAlign="Top"
                        AutoGenerateColumns="False"
                        OnSelectedIndexChanged="lvwEquipTypeAndMode_SelectedIndexChanged"
                        OnRowCreated="lvwEquipTypeAndMode_RowCreated">
                        
                    <Columns>
                            <asp:BoundField DataField="CODE"   HeaderText="编码"/>
                            <asp:BoundField DataField="NAME"    HeaderText="名称"/>
                            <asp:BoundField DataField="NOTE"  HeaderText="说明"/>
                            <asp:TemplateField HeaderText="有效标志">
                                <ItemTemplate>
                                    <asp:Label ID="labUseTag" Text='<%# Eval("USETAG").ToString() == "1" ? "有效" : "无效" %>' runat="server"></asp:Label>
                                </ItemTemplate>
                            </asp:TemplateField>
                    </Columns>           
                    <EmptyDataTemplate>
                        <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                            <tr class="tabbt">
                                <td>编码</td>
				                <td>名称</td>
					            <td>说明</td>
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
				    <td width="15%"><div align="right">编码:</div></td>
				    <td width="85%">
				        <asp:TextBox ID="txtCode" CssClass="input" MaxLength="2" runat="server"></asp:TextBox>
				    </td>
				</tr>
				<tr>
				    <td><div align="right">名称:</div></td>
				    <td>
				        <asp:TextBox ID="txtName" CssClass="inputlong" MaxLength="20" runat="server"></asp:TextBox>
				    </td>
				</tr>
				<tr>
				    <td><div align="right">说明:</div></td>
				    <td>
						<asp:TextBox ID="txtNote" CssClass="inputlong" MaxLength="150" runat="server"></asp:TextBox>
						<%--<textarea id="txtNote" cols="60" rows="3" runat="server" />--%>
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
						<table width="300" border="0" align="right" cellpadding="0" cellspacing="0">
							<tr>
						        <td>
						            <asp:Button ID="btnAdd" CssClass="button1" Text="增加" runat="server" OnClick="btnAdd_Click" />
						        </td>
						        <td>
						            <asp:Button ID="btnModify" CssClass="button1" Text="修改" runat="server"  OnClick="btnModify_Click"/>
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

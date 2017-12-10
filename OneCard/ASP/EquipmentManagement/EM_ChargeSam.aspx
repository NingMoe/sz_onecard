<%@ Page Language="C#" AutoEventWireup="true" CodeFile="EM_ChargeSam.aspx.cs" Inherits="ASP_EquipmentManagement_EM_ChargeSam" EnableEventValidation="false" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <title>充值SAM卡维护</title>
</head>
<body>
    <form id="form1" runat="server">
    
	    <div class="tb">
		    设备管理->充值SAM卡维护
	    </div>
	
	    <ajaxToolkit:ToolkitScriptManager runat="Server" EnableScriptGlobalization="true" EnableScriptLocalization="true" ID="ToolkitScriptManager1" />
        <asp:UpdatePanel ID="UpdatePanel2" runat="server">  
            <ContentTemplate>  
               
            <!-- #include file="../../ErrorMsg.inc" -->  
	        <div class="con">
        	
		        <div class="card">
			        充值SAM卡维护
		        </div>
        		<div class="kuang5">
  
			<table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
				<tr>
				<td width="10%"><div align="right">SAM卡号:</div></td>
				<td><asp:TextBox ID="txtSam" runat="server"></asp:TextBox></td>
				<td></td>
				<td></td>
				<td><asp:Button ID="btnQuery" CssClass="button1" runat="server" OnClick="btnQuery_Click" Text="查询" /></td>
				</tr>
			</table>
		        <div class="kuang5">
			        <div class="gdtb" style="height:260px">
			        
			            <asp:GridView ID="lvwChargeSam" runat="server"
                                Width = "1100"
                                CssClass="tab1"
                                HeaderStyle-CssClass="tabbt"
                                AlternatingRowStyle-CssClass="tabjg"
                                SelectedRowStyle-CssClass="tabsel"
                                AllowPaging="true"
                                PageSize="9"
                                OnPageIndexChanging="lvwChargeSam_Page"
                                PagerSettings-Mode="NumericFirstLast"
                                PagerStyle-HorizontalAlign="left"
                                PagerStyle-VerticalAlign="Top"
                                AutoGenerateColumns="False"                                
                                OnSelectedIndexChanged="lvwChargeSam_SelectedIndexChanged"
                                OnRowCreated="lvwChargeSam_RowCreated">
                            <Columns>
                                <asp:BoundField DataField="SAMNO"   HeaderText="充值SAM卡号"/>
                                <asp:BoundField DataField="VERSION"    HeaderText="版本号"/>
                                <asp:BoundField DataField="CALLING"  HeaderText="行业"/>
                                <asp:BoundField DataField="CORP"  HeaderText="单位"/>
                                <asp:TemplateField HeaderText="有效标志">
                                    <ItemTemplate>
                                        <asp:Label ID="labUseTag" Text='<%# Eval("USETAG").ToString() == "1" ? "有效" : "无效" %>' runat="server"></asp:Label>
                                    </ItemTemplate>
                                </asp:TemplateField>   
                                <asp:BoundField DataField="NOTE"  HeaderText="备注"/>
                                <asp:BoundField DataField="UPDATESTAFF"  HeaderText="更新员工"/>
                                <asp:BoundField DataField="UPDATETIME"  HeaderText="更新时间"/>
                            </Columns>           
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
				                    <tr class="tabbt">
				                        <td>充值SAM卡号</td>
				                        <td>版本号</td>
					                    <td>行业</td>
					                    <td>单位</td>
					                    <td>有效标志</td>
					                    <td>备注</td>
					                    <td>更新员工</td>
					                    <td>更新时间</td>
				                    </tr>
                                </table>
                            </EmptyDataTemplate>
                        </asp:GridView>

			        </div>
		        </div>
        	
		        <div class="kuang5">
			        <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
				        <tr>
				            <td width="15%"><div align="right">充值SAM卡号:</div></td>
				            <td width="85%">
				                <asp:TextBox ID="txtSamNo" CssClass="input" MaxLength="12" runat="server"></asp:TextBox>
				            </td>
				        </tr>
				        <tr>
				            <td><div align="right">版本号:</div></td>
				            <td>
				                <asp:TextBox ID="txtVersion" CssClass="input" MaxLength="1" runat="server"></asp:TextBox>
				            </td>
				        </tr>
				        <tr>
				            <td><div align="right">行业:</div></td>
				            <td>
				                <asp:DropDownList ID="selCalling" CssClass="inputmid" runat="server" AutoPostBack="true" OnSelectedIndexChanged="selCalling_Change"></asp:DropDownList>
				            </td>
				        </tr>
				        <tr>
				            <td><div align="right">单位:</div></td>
				            <td>
				                <asp:DropDownList ID="selCorp" CssClass="inputmid" runat="server"></asp:DropDownList>
				            </td>
				        </tr>
				        <tr>
				            <td><div align="right">有效标志:</div></td>
				            <td>
						        <asp:DropDownList ID="selUseTag" CssClass="input" runat="server"></asp:DropDownList>
					        </td>
				        </tr>
				        <tr>
				            <td><div align="right">备注:</div></td>
				            <td>
				                <asp:TextBox ID="txtNote" CssClass="inputlong" MaxLength="20" runat="server"></asp:TextBox>
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

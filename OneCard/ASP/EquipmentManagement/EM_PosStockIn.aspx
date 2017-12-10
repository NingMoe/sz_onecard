<%@ Page Language="C#" AutoEventWireup="true" CodeFile="EM_PosStockIn.aspx.cs" Inherits="ASP_EquipmentManagement_EM_PosStockIn" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
	<link rel="stylesheet" type="text/css" href="../../css/frame.css" />	  
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <title>POS入库</title> 
</head>
<body>
    <form id="form1" runat="server">
    
        <div class="tb">设备管理->POS入库</div>

        <ajaxToolkit:ToolkitScriptManager runat="Server" EnableScriptGlobalization="true"
            EnableScriptLocalization="true" ID="ScriptManager2" />
        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
            <ContentTemplate>
            <!-- #include file="../../ErrorMsg.inc" --> 
           
        <div class="con">

            <div class="base">
                POS入库
            </div>

            <div class="kuang5">
                <table border="0" cellpadding="0" cellspacing="0" class="text25"> 
                    <tr>
                        <td width="100" align="right">POS编号:</td>
                        <td>
                            <asp:TextBox ID="txtEquipNo" CssClass="inputmid" runat="server" MaxLength="6"></asp:TextBox>
                        </td>
			            <td width="10"><span class="red">*</span></td>
                        <td width="80" align="right">POS厂商:</td>
                        <td>
                            <asp:DropDownList ID="selEquipManu" CssClass="inputmid" runat="server"></asp:DropDownList>
                        </td>
			            <td width="10"><span class="red">*</span></td>
                        <td width="100" align="right">POS来源:</td>
                        <td>
                            <asp:DropDownList ID="selEquipSource" CssClass="inputmid" runat="server"></asp:DropDownList>
                        </td>
                        <td width="30"><span class="red">*</span></td>
                        <td width="120">&nbsp;</td>
                    </tr>
                    <tr>
                        <td align="right">POS型号:</td>
                        <td>
                            <asp:DropDownList ID="selEquipMode" CssClass="inputmid" runat="server"></asp:DropDownList>
                        </td>
			            <td><span class="red">*</span></td>
                        <td align="right">接触类型:</td>
                        <td>
                            <asp:DropDownList ID="selTouchType" CssClass="inputmid" runat="server"></asp:DropDownList>
                            <!--(选择其他设备时，接触类型表示其他设备的类型)-->
                        </td>
			            <td width="10"><span class="red">*</span></td>
                        <td align="right">放置类型:</td>
                        <td>
                            <asp:DropDownList ID="selLayType" CssClass="inputmid" runat="server"></asp:DropDownList>
                        </td>
                        <td><span class="red">*</span></td>
                        <td>&nbsp;</td>
                    </tr>
                    <tr>
                        <td align="right">硬件序列号:</td>
                        <td>
                            <asp:TextBox ID="txtHardwareNum" CssClass="inputmid" runat="server" MaxLength="50"></asp:TextBox>
                        </td>
			            <td><span class="red">*</span></td>
			            <td align="right">POS价格:</td>
                        <td>
                            <asp:TextBox ID="txtEquipPrice" CssClass="inputmid" runat="server" MaxLength="10"></asp:TextBox>
                        </td>
			            <td><span class="red">*</span></td>
                        <td align="right">通信类型:</td>
                        <td>
                            <asp:DropDownList ID="selCommType" CssClass="inputmid" runat="server"></asp:DropDownList>
                        </td>
                        <td><span class="red">*</span></td>
                        <td>&nbsp;</td>
                    </tr>
                </table>  
                <table width="90%" border="0" cellpadding="0" cellspacing="0" class="text25">
                    <tr>
					    <td align="right">
					        <asp:Button ID="Button2" CssClass="button1" runat="server" Text="POS入库" OnClick="btnPos_Click"/>
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
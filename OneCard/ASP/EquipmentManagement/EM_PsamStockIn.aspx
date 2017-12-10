<%@ Page Language="C#" AutoEventWireup="true" CodeFile="EM_PsamStockIn.aspx.cs" Inherits="ASP_EquipmentManagement_EM_PsamStockIn" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
	<link rel="stylesheet" type="text/css" href="../../css/frame.css" />	  
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <script language="JavaScript" src="../../js/mootools.js"></script>
    <script language="javascript">
    function Change()
    {
        var sFCard = $get('txtFromCardNo').value;
        var sECard = $get('txtToCardNo').value;
        var lCardSum = 0;
        if(sFCard.test("^\\s*.{2}\\d{10}\\s*$") && sECard.test("\\s*^.{2}\\d{10}\\s*$"))//sECard.test("\\s*^\\d{16}\\s*$"))
        {
            var lFCard = sFCard.substring(2).toInt();
            var lECard = sECard.substring(2).toInt();
            if(lECard - lFCard >= 0)
                lCardSum = lECard - lFCard + 1;
        }
       
        $('txtCardSum').value = lCardSum;
    }
    </script>
    <title>PSAM卡入库</title> 
</head>
<body>
    <form id="form1" runat="server">
    
        <div class="tb">设备管理->PSAM卡入库</div>

        <ajaxToolkit:ToolkitScriptManager runat="Server" EnableScriptGlobalization="true"
            EnableScriptLocalization="true" ID="ScriptManager2" />
        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
            <ContentTemplate>
            <!-- #include file="../../ErrorMsg.inc" --> 
           
        <div class="con">

            <div class="base">
                PSAM卡入库
            </div>
    
            <div class="kuang5">
    
                <table border="0" cellpadding="0" cellspacing="0" class="text25">
                    <tr>
                        <td align="right" width="100">卡片类型:</td>
                        <td>
                            <asp:TextBox ID="txtCardType" CssClass="input" MaxLength="2" runat="server"></asp:TextBox>
                            <%--<asp:DropDownList ID="selCardType" CssClass="input" runat="server"></asp:DropDownList> --%>
                        </td>
			            <td width="10">&nbsp;</td>
                        <td align="right" width="80">卡片厂商:</td>
                        <td>
                            <asp:DropDownList ID="selManu" CssClass="input" runat="server"></asp:DropDownList>
                        </td>
			            <td width="10"><span class="red">*</span></td>
                        <td align="right" width="100">起讫卡号:</td>
                        <td>
                            <asp:TextBox ID="txtFromCardNo" CssClass="inputmid" runat="server" MaxLength="12"></asp:TextBox>
                        </td>
                        <td align="center" width="30">-</td>
                        <td>
                            <asp:TextBox ID="txtToCardNo" CssClass="inputmid" runat="server" MaxLength="12"></asp:TextBox>                            
                        </td>
			            <td width="10"><span class="red">*</span></td>
                    </tr>  
                    <tr>
                        <td align="right">COS类型:</td>
                        <td>
                            <asp:DropDownList ID="selCosType" CssClass="input" runat="server"></asp:DropDownList>
                        </td>
			            <td><span class="red">*</span></td>
			            <td align="right">卡片单价:</td>
                        <td>
                            <asp:TextBox ID="txtCardPrice" CssClass="input" runat="server" MaxLength="10"></asp:TextBox>
                        </td>
			            <td><span class="red">*</span></td>
                        <td align="right">有效期:</td>
                        <td>                           
                            <asp:TextBox runat="server" ID="txtFromDate" CssClass="inputmid"  MaxLength="8"/>
                            <ajaxToolkit:CalendarExtender ID="FCalendar" runat="server" TargetControlID="txtFromDate"
                                Format="yyyy-MM-dd" />
                        </td>
                        <td align="center">-</td>
                        <td>                          
                            <asp:TextBox runat="server" ID="txtToDate" CssClass="inputmid"  MaxLength="8"/>
                            <ajaxToolkit:CalendarExtender ID="ECalendar" runat="server" TargetControlID="txtToDate"
                                Format="yyyy-MM-dd" />
                        </td> 
			            <td><span class="red">*</span></td>			
                     </tr>
                     <tr>  
			            <td align="right">应用版本:</td>
                        <td>
				            <asp:TextBox ID="txtAppVersion" CssClass="input" runat="server" MaxLength="2"></asp:TextBox>
                        </td>
			            <td><span class="red">*</span></td>
			            <td>&nbsp;</td>
                        <td>&nbsp;</td>
                        <td>&nbsp;</td>
                        <td align="right">入库数量:</td>
                        <td>
                            <asp:TextBox ID="txtCardSum" CssClass="labeltext" runat="server" Text="0"></asp:TextBox>
                        </td>
                        <td>&nbsp;</td>
                        <td>&nbsp;</td>
			            <td>&nbsp;</td>
                     </tr>
                </table>
                <table width="90%" border="0" cellpadding="0" cellspacing="0" class="text25">
                    <tr>
					    <td align="right">
					        <asp:Button ID="Button1" CssClass="button1" runat="server" Text="PSAM入库" OnClick="btnPsam_Click"/>
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
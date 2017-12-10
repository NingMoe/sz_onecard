<%@ Page Language="C#" AutoEventWireup="true" CodeFile="IT_VoidCw.aspx.cs" Inherits="ASP_InvoiceTrade_IT_VoidCw" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <link href="../../css/invoice.css" rel="stylesheet" type="text/css" />
      <script type="text/javascript" src="../../js/myext.js"></script>
<script type="text/javascript" src="../../js/cardreaderhelper.js"></script>

    <title>作废</title>
</head>
<body>
    <form id="form1" runat="server">
    
        <div class="tb">发票 -> 作废</div>

        <ajaxToolkit:ToolkitScriptManager runat="Server" EnableScriptGlobalization="true"
            EnableScriptLocalization="true" ID="ScriptManager2" />
        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
            <ContentTemplate>
            <!-- #include file="../../ErrorMsg.inc" -->
            
            <aspControls:PrintFaPiao ID="ptnFaPiao" runat="server" PrintArea="printfapiao" />
            
            <div class="con">
                <div class="pip">作废</div>
                <div class="kuang5">
			        <table width="95%" border="0" cellpadding="0" cellspacing="0" class="12text">
			          <tr>
			            <td align="right">发票代码:</td>
			            <td><asp:TextBox ID="txtVolumn" CssClass="inputmid" MaxLength="12" runat="server" />
			            <asp:HiddenField runat="server" ID="hidVolumn" />
			            </td>
			            <td><div align="right">作废发票号:</div></td>
			            <td>
					        <asp:TextBox ID="reverseInvoiceId" CssClass="inputmid" MaxLength="8" runat="server"></asp:TextBox>
				        </td>
                         <td>作废原因：
                         <asp:DropDownList ID="ddlReason"  CssClass="input" runat="server">
                         <asp:ListItem Value="有效开票">有效开票</asp:ListItem>
                         <asp:ListItem Value="出库未分配">出库未分配</asp:ListItem>
                         <asp:ListItem Value="领用未使用">领用未使用</asp:ListItem>
                         <asp:ListItem Value="破损">破损</asp:ListItem>
                         <asp:ListItem Value="缺页">缺页</asp:ListItem>
                         <asp:ListItem Value="其他">其他</asp:ListItem>
                         </asp:DropDownList></td>
                        <td><asp:Button ID="btnNext" CssClass="button1" OnClick="Next_Click" Text="下一步" runat="server"/></td>
			            <td>
                        

                             <asp:LinkButton runat="server" ID="btnConfirm" OnClick="InvoiceVoid_Click" />
                            <asp:Button ID="btnVoid" CssClass="button1" runat="server" Text="发票作废" Visible=false OnClientClick="return FapiaoCheck()"/>
                            <asp:Button ID="btnNew" CssClass="button1" runat="server" Text="新发票" Visible=false OnClick="New_Click"/>
			            </td>
                        
                        
                         
			            </tr>
			        </table>
		        </div>
		        <asp:HiddenField ID="hidInvoiceNo" runat="server" />
                <asp:HiddenField ID="hidVolumeNo" runat="server" />
		        <asp:HiddenField ID="hidNo" runat="server" />
		        <asp:HiddenField ID="hidReaded" runat="server" Value="false" />
		        <asp:HiddenField ID="hidPrinted" runat="server" Value="false" />
		        
                 <div class="kuang5" runat="server" id="divRead">

                    <table width="806" border="0" cellpadding="0" cellspacing="0">
                      <tr>
                        <td height="78">&nbsp;</td>
                        <td colspan="6">
                        <table width="100%" height="79" border="0" cellpadding="0" cellspacing="0">
                          <tr>
                            <td width="9%" class="head">付款方：</td>
                            <td colspan="3">
                                <asp:TextBox ID="txtPayer" CssClass="labeltextlong"  ReadOnly="true" runat="server"></asp:TextBox>
                            </td>
                            <%--<td width="20%" rowspan="2" class="cgl">存　根　联</td>--%>
                            <td width="13%" class="head"><div align="right">发票代码：</div></td>
                            <td width="23%">
                            <asp:TextBox ID="txtCode" ReadOnly=true CssClass="textbox100" runat="server"></asp:TextBox>
                            </td>
                          </tr>
                          <tr>
                            <td class="head">收款方：</td>
                            <td colspan="3">
                                <asp:TextBox ID="txtPayee" CssClass="labeltextlong" ReadOnly="true" runat="server"></asp:TextBox>
                            </td>
                            <td class="head"><div align="right">号码：</div></td>
                            <td>#### - ####</td>
                          </tr>
                          <tr>
                            <td colspan="2" class="head">纳税人识别号：</td>
                            <td width="27%" class="head">
                                <asp:TextBox ID="txtTaxPayerId" CssClass="labeltext" ReadOnly="true" runat="server"></asp:TextBox>
                            </td>
                            <td>&nbsp;</td>
                            <td class="head"><div align="right">发票号码：</div></td>
                            <td>
                                <asp:TextBox ID="txtInvoiceId" CssClass="textbox100" ReadOnly="true" runat="server"></asp:TextBox>
                            </td>
                          </tr>
                        </table></td>
                        <td>&nbsp;</td>
                      </tr>
                      <tr>
                        <td height="243">&nbsp;</td>
                        <td colspan="6"><table width="679" height="240" border="0" cellpadding="0" cellspacing="0" class="line">
                          <tr>
                            <td height="193" colspan="4" valign="top">
                            <table width="100%" height="193" border="0" cellpadding="0" cellspacing="0" class="line2">
                              <tr>
                                <td width="69%" valign="top"><table width="100%" height="192" border="0" cellpadding="0" cellspacing="0" class="line3">
                                  <tr>
                                    <td width="60%"><div align="center" class="head">项目</div></td>
                                    <td><div align="center" class="head">金额</div></td>
                                  </tr>
                                  <tr>
                                    <td><div align="center">
                                        <asp:TextBox ID="txtProj1" CssClass="labeltextlong" ReadOnly="true" runat="server"></asp:TextBox>
                                        </div>
                                    </td>
                                    <td><div align="center">
                                        <asp:TextBox ID="txtAmount1" CssClass="labeltext" ReadOnly="true" runat="server"></asp:TextBox>
                                    </div>
                                    </td>
                                  </tr>
                                  <tr>
                                    <td><div align="center">
                                        <asp:TextBox ID="txtProj2" CssClass="labeltextlong" ReadOnly="true" runat="server"></asp:TextBox>
                                        </div>
                                    </td>
                                    <td><div align="center">
                                        <asp:TextBox ID="txtAmount2" CssClass="labeltext" ReadOnly="true" runat="server"></asp:TextBox>
                                    </div>
                                    </td>
                                  </tr>
                                  <tr>
                                    <td><div align="center">
                                        <asp:TextBox ID="txtProj3" CssClass="labeltextlong" ReadOnly="true" runat="server"></asp:TextBox>
                                        </div>
                                    </td>
                                    <td><div align="center">
                                        <asp:TextBox ID="txtAmount3" CssClass="labeltext" ReadOnly="true" runat="server"></asp:TextBox>
                                    </div>
                                    </td>
                                  </tr>
                                  <tr>
                                    <td><div align="center">
                                        <asp:TextBox ID="txtProj4" CssClass="labeltextlong" ReadOnly="true" runat="server"></asp:TextBox>
                                        </div>
                                    </td>
                                    <td><div align="center">
                                        <asp:TextBox ID="txtAmount4" CssClass="labeltext" ReadOnly="true" runat="server"></asp:TextBox>
                                    </div>
                                    </td>
                                  </tr>
                                  <tr>
                                    <td><div align="center">
                                        <asp:TextBox ID="txtProj5" CssClass="labeltextlong" ReadOnly="true" runat="server"></asp:TextBox>
                                        </div>
                                    </td>
                                    <td><div align="center">
                                        <asp:TextBox ID="txtAmount5" CssClass="labeltext" ReadOnly="true" runat="server"></asp:TextBox>
                                    </div>
                                    </td>
                                  </tr>
                                </table></td>
                                <td width="31%" valign="top"><table width="195" height="192" border="0" align="center" cellpadding="0" cellspacing="0">
                                  <tr>
                                    <td class="head">附注</td>
                                  </tr>
                                  <tr>
                                    <td>
                                        <asp:TextBox ID="txtNote" Height="140" Columns="20" ReadOnly="true" TextMode="MultiLine" runat="server"></asp:TextBox>
                                    </td>
                                  </tr>
                                </table></td>
                              </tr>
                            </table></td>
                            </tr>
                          <tr>
                            <td width="18%"> 　<span class="head">合计（大写）：</span></td>
                            <td width="51%">
                                <asp:TextBox ID="txtTotal" CssClass="labeltextlong" ReadOnly="true" runat="server"></asp:TextBox>
                            </td>
                            <td width="11%" class="head">　￥：</td>
                            <td width="20%">
                                <asp:TextBox ID="txtTotal2" CssClass="labeltext" ReadOnly="true" runat="server"></asp:TextBox>
                            </td>
                          </tr>
                        </table></td>
                        <td>&nbsp;</td>
                      </tr>
                      <tr>
                        <td>&nbsp;</td>
                        <td width="190" class="head">收款单位（盖章有效）：</td>
                        <td width="160">&nbsp;</td>
                        <td width="70" class="head">开票人：</td>
                        <td width="81">
                            <asp:TextBox ID="txtStaff" CssClass="labeltext" ReadOnly="true" runat="server"></asp:TextBox>
                        </td>
                        <td width="84" class="head">开票日期：</td>
                        <td width="96">
                            <asp:TextBox ID="txtDate" CssClass="labeltext" ReadOnly="true" runat="server"></asp:TextBox>
                        </td>
                        <td>&nbsp;</td>
                      </tr>
                    </table>

                </div>
            </div>
            

            
            </ContentTemplate>
        </asp:UpdatePanel>
        
    </form>
    
</body>
</html>
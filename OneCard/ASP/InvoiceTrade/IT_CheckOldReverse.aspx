<%@ Page Language="C#" AutoEventWireup="true" CodeFile="IT_CheckOldReverse.aspx.cs" Inherits="ASP_InvoiceTrade_IT_CheckOldReverse" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <link href="../../css/invoice.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="../../js/print.js"></script>
    <script type="text/javascript">
    function printFaPiao()
    {
        printdiv('printfapiao');
    }
    </script>
    <title>红冲</title>
</head>
<body>
    <form id="form1" runat="server">
    
        <div class="tb">发票 -> 红冲</div>

        <ajaxToolkit:ToolkitScriptManager runat="Server" EnableScriptGlobalization="true"
            EnableScriptLocalization="true" ID="ScriptManager2" />
        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
            <ContentTemplate>
            <!-- #include file="../../ErrorMsg.inc" -->
            
            <aspControls:PrintFaPiao ID="ptnFaPiao" runat="server" PrintArea="printfapiao" />
            
            <div class="con">
                <div class="pip">红冲<font color="red">(*作废且无法正常上传地税的发票进行红冲)</font></div>
                <div class="kuang5">
			        <table width="95%" border="0" cellpadding="0" cellspacing="0" class="12text">
			          <tr>
			            <td width="5%" align="right">发票代码:</td>
			            <td width="10%"><asp:TextBox ID="txtVolumn" CssClass="inputmid" MaxLength="12" runat="server" />
			            <asp:HiddenField runat="server" ID="hidVolumn" />
			            </td>
			            <td width="5%"><div align="right">红冲发票号:</div></td>
			            <td width="10%">
					        <asp:TextBox ID="reverseInvoiceId" CssClass="inputmid" MaxLength="8" runat="server"></asp:TextBox>
				        </td>
			            <td width="14%">
			                <asp:Button ID="btnQuery" CssClass="button1" OnClick="Read_Click" Text="读发票" runat="server"/>
			            </td>
			            </tr>
			        </table>
		        </div>
		        <asp:HiddenField  ID="hidCallingName" runat="server" />
		        <asp:HiddenField ID="hidNo" runat="server" />
		        <asp:HiddenField ID="hidReaded" runat="server" Value="false" />
		        <asp:HiddenField ID="hidPrinted" runat="server" Value="false" />
		        
                 <div class="kuang5">

                    <table width="806" border="0" cellpadding="0" cellspacing="0">
                      <tr>
                        <td width="60" height="38">&nbsp;</td>
                        <td colspan="6">
                        
                         <table width="100%">
                                    <tr>
                                    <td width="60">
                                    <div align="right">
                                    <asp:Label ID="lblValidateCode" runat="server"></asp:Label></div>
                                    </td>
                                    <td  class="bt">
                                     <div align="center">
                                        苏州市民卡有限公司通用机打发票
                                    </div>
                                    </td>
                                    </tr>
                                    </table>
                        
                        </td>
                        <td width="65">&nbsp;</td>
                      </tr>
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
                            <asp:TextBox ID="txtCode" MaxLength="12" CssClass="textbox100" runat="server"></asp:TextBox>
                            </td>
                          </tr>
                          <tr>
                            <td class="head">收款方：</td>
                            <td colspan="3">
                                <asp:TextBox ID="txtPayee" CssClass="labeltextlonger" ReadOnly="true" runat="server"></asp:TextBox>
                            </td>
                            <td class="head"><div align="right">&nbsp;</div></td>
                            <td>&nbsp;</td>
                          </tr>
                          <tr>
                            <td colspan="2" class="head">纳税人识别号：</td>
                            <td width="27%" class="head">
                                <asp:TextBox ID="txtTaxPayerId" CssClass="labeltext" ReadOnly="true" runat="server"></asp:TextBox>
                            </td>
                            <td>&nbsp;</td>
                            <td class="head"><div align="right">发票号码：</div></td>
                            <td>
                                <asp:TextBox ID="txtInvoiceId" CssClass="textbox100" MaxLength="8" runat="server"></asp:TextBox>
                            </td>
                          </tr>
                            <tr>
                                                        <td colspan="2" class="head">
                                                            苏信开户行：</td>
                                                        <td width="27%" class="head">
                                                            <asp:DropDownList ID="selSZBank" CssClass="inputmidder" runat="server" AutoPostBack="true" OnSelectedIndexChanged="selSZBank_SelectedIndexChanged">
                                                            </asp:DropDownList>
                                                        </td>
                                                        <td>
                                                            </td>
                                                        <td class="head">
                                                            <div align="right">
                                                            &nbsp;
                                                            </div>
                                                        </td>
                                                        <td>
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
                                  <tr>
                                    <td><div align="center">
                                        收款方：
                                        </div>
                                    </td>
                                    <td><div align="left">
                                        <asp:Label runat="server" ID="lblPayeeName"></asp:Label>
                                    </div>
                                    </td>
                                  </tr>
                                   <tr>
                                    <td><div align="center">
                                        苏信开户行：
                                        </div>
                                    </td>
                                    <td><div align="left">
                                        <asp:Label runat="server" ID="lblSZBank"></asp:Label>
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
                                        <asp:TextBox ID="txtNote" Height="140" Columns="20" MaxLength="100" TextMode="MultiLine" runat="server"></asp:TextBox>
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
            
            <div class="btns">
              <table width="100" border="0" align="right" cellpadding="0" cellspacing="0">
                <tr>
                  <td>
                    <asp:Button ID="btnPrintFaPiao" runat="server" Text="打印发票" CssClass="button1" OnClick="Print_Click" />
                  </td>
                </tr>
              </table>
            </div>
            
            </ContentTemplate>
        </asp:UpdatePanel>
        
    </form>
    
</body>
</html>
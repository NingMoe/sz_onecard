<%@ Page Language="C#" AutoEventWireup="true" CodeFile="IT_PrintModify.aspx.cs" Inherits="ASP_InvoiceTrade_IT_PrintModify" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">

    <script type="text/javascript" src="../../js/print.js"></script>

    <script type="text/javascript" src="../../js/myext.js"></script>

    <script type="text/javascript" src="../../js/currency.js"></script>

    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <link href="../../css/invoice.css" rel="stylesheet" type="text/css" />

    <script type="text/javascript">
    <!--
    function printFaPiao()
    {
        printdiv('printfapiao');
    }
    function Change(){
        sumCurrency('txtAmount1','txtAmount2','txtAmount3','txtTotal','txtTotal2');
    }
    function Total() {
        sumCurrency2('txtPrice1', 'txtPrice2', 'txtPrice3', 'txtNum1', 'txtNum2', 'txtNum3', 'txtAmount1', 'txtAmount2', 'txtAmount3', 'txtTotal', 'txtTotal2');
    }
//    function clearData(){
//        var errorList = document.getElementById("bulMsgShow");
//        if(errorList){
//            errorList.innerHTML = "";
//        }
//        document.getElementById("hidPrinted").value = "false";
//        
//        document.getElementById("btnPrintFaPiao").value = "打印发票";

//        document.getElementById("txtPayer").disabled = false;
//        document.getElementById("txtPayer").className = "textbox200";
//        document.getElementById("txtInvoiceId").disabled = false;
//        document.getElementById("txtInvoiceId").className = "textbox100";
//        
//        document.getElementById("txtInvoiceId").style.background = "white";
//        
//        document.getElementById("selProj1").disabled = false;
//        document.getElementById("selProj1").className = "textbox200";
//        document.getElementById("selProj2").disabled = false;
//        document.getElementById("selProj2").className = "textbox200";
//        document.getElementById("selProj3").disabled = false;
//        document.getElementById("selProj3").className = "textbox200";
//        document.getElementById("selProj4").disabled = false;
//        document.getElementById("selProj4").className = "textbox200";
//        document.getElementById("selProj5").disabled = false;
//        document.getElementById("selProj5").className = "textbox200";
//        document.getElementById("txtAmount1").disabled = false;
//        document.getElementById("txtAmount1").className = "textbox100";
//        document.getElementById("txtAmount2").disabled = false;
//        document.getElementById("txtAmount2").className = "textbox100";
//        document.getElementById("txtAmount3").disabled = false;
//        document.getElementById("txtAmount3").className = "textbox100";
//        document.getElementById("txtAmount4").disabled = false;
//        document.getElementById("txtAmount4").className = "textbox100";
//        document.getElementById("txtAmount5").disabled = false;
//        document.getElementById("txtAmount5").className = "textbox100";
//        
//        document.getElementById("txtAmount1").style.background = "white";
//        document.getElementById("txtAmount2").style.background = "white";
//        document.getElementById("txtAmount3").style.background = "white";
//        document.getElementById("txtAmount4").style.background = "white";
//        document.getElementById("txtAmount5").style.background = "white";
//        
//        
//        document.getElementById("txtNote").disabled = false;
//        document.getElementById("txtNote").className = "";

//        document.getElementById("txtPayer").value = "个人";
//        document.getElementById("txtInvoiceId").value = "";
//        
//        document.getElementById("selProj1").value = "";
//        document.getElementById("selProj2").value = "";
//        document.getElementById("selProj3").value = "";
//        document.getElementById("selProj4").value = "";
//        document.getElementById("selProj5").value = "";
//        document.getElementById("txtAmount1").value = "";
//        document.getElementById("txtAmount2").value = "";
//        document.getElementById("txtAmount3").value = "";
//        document.getElementById("txtAmount4").value = "";
//        document.getElementById("txtAmount5").value = "";
//        document.getElementById("txtNote").value = "";
//        
//        document.getElementById("txtTotal").value = "";
//        document.getElementById("txtTotal2").value = "";
//        
//        return false;
//    }
    //-->
    </script>

    <title>财务发票打印</title>
</head>
<body>
    <form id="form1" runat="server">
        <div class="tb">
            发票 -> 打印</div>
        <ajaxToolkit:ToolkitScriptManager runat="Server" EnableScriptGlobalization="true"
            EnableScriptLocalization="true" ID="ScriptManager2" />

        <script type="text/javascript" language="javascript">
                var swpmIntance = Sys.WebForms.PageRequestManager.getInstance();
                swpmIntance.add_initializeRequest(BeginRequestHandler);
                swpmIntance.add_pageLoading(EndRequestHandler);
				function BeginRequestHandler(sender, args){
				    try {MyExtShow('请等待', '正在提交后台处理中...'); } catch(ex){}
				}
				function EndRequestHandler(sender, args) {
				    try {MyExtHide(); } catch(ex){}
				}
        </script>

        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
            <ContentTemplate>
                <!-- #include file="../../ErrorMsg.inc" -->
                <aspControls:PrintFaPiao ID="ptnFaPiao" runat="server" PrintArea="printfapiao" />
                <asp:HiddenField ID="hidPrinted" Value="false" runat="server" />
                <div class="con">
                    <div class="pip">
                        财务发票打印-可修改项目</div>
                    <div class="kuang5">
                        <table width="806" border="0" cellpadding="0" cellspacing="0">
                            <tr>
                                <td width="60" height="38">
                                    &nbsp;</td>
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
                                <td width="65">
                                    &nbsp;</td>
                            </tr>
                            <tr style="height: 15px">
                                <td colspan="8">
                                </td>
                            </tr>
                            <tr style="height: 25px">
                                <td width="10px">
                                    &nbsp;</td>
                                <td class="head" colspan="5" >
                                    开票日期：&nbsp;&nbsp;<asp:TextBox ID="txtDate" CssClass="labeltext" runat="server"></asp:TextBox>
                                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                    行业分类：&nbsp;&nbsp;<asp:DropDownList ID="selCalling"  CssClass="input" runat="server">
                                        <asp:ListItem Value="0799" Selected>其他服务</asp:ListItem>
                                        <%-- <asp:ListItem Value="0770">广告业</asp:ListItem>--%>
                                        </asp:DropDownList>
                                </td>
                              
                                <td align="left">
                                </td>
                                <td>
                                </td>
                                <td>
                                    &nbsp;
                                </td>
                            </tr>
                            <tr>
                                <td height="78">
                                    &nbsp;</td>
                                <td colspan="6">
                                    <table style="border: 2px; border-color: #000000; border-style: solid">
                                        <tr>
                                            <td width="10px">
                                                &nbsp;
                                            </td>
                                            <td>
                                                <table width="100%" height="100" border="0" cellpadding="0" cellspacing="0">
                                                    <tr>
                                                        <td width="9%" class="head">
                                                            付款方：</td>
                                                        <td colspan="3">
                                                            <asp:TextBox ID="txtPayer" CssClass="textbox200" runat="server"></asp:TextBox>
                                                        </td>
                                                        <%--<td width="20%" rowspan="2" class="cgl">存　根　联</td>--%>
                                                        <td width="13%" class="head">
                                                            <div align="right">
                                                                发票代码：</div>
                                                        </td>
                                                        <td width="23%">
                                                            <asp:TextBox ID="txtCode" MaxLength="12" CssClass="textbox100" runat="server"></asp:TextBox>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td width="19%" class="head">
                                                            付款方纳税人识别号：</td>
                                                        <td colspan="5">
                                                            <asp:TextBox ID="txtPayCode" CssClass="textbox200" runat="server"></asp:TextBox>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td class="head">
                                                            收款方：</td>
                                                        <td colspan="3">
                                                            <asp:TextBox ID="txtPayee" CssClass="labeltextlonger" MaxLength="50" ReadOnly="true"
                                                                runat="server"></asp:TextBox>
                                                        </td>
                                                        <td class="head">
                                                            <div align="right">
                                                                发票号码：</div>
                                                        </td>
                                                        <td>
                                                            <asp:TextBox ID="txtInvoiceId" CssClass="textbox100" MaxLength="8" runat="server"></asp:TextBox></td>
                                                    </tr>
                                                    <tr>
                                                        <td colspan="2" class="head">
                                                            纳税人识别号：</td>
                                                        <td width="27%" class="head">
                                                            <asp:TextBox ID="txtTaxPayerId" CssClass="labeltext" ReadOnly="true" runat="server"></asp:TextBox>
                                                        </td>
                                                        <td>
                                                            &nbsp;</td>
                                                        <td class="head">
                                                            <div align="right">
                                                            </div>
                                                        </td>
                                                        <td>
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
                                                </table>
                                                <table width="679" height="210" border="0" cellpadding="0" cellspacing="0" class="">
                                                    <tr>
                                                        <td height="193" colspan="4" valign="top">
                                                            <table width="100%" height="193" border="0" cellpadding="0" cellspacing="0" class="">
                                                                <tr>
                                                                    <td width="69%" valign="top">
                                                                        <table width="100%" height="192" border="0" cellpadding="0" cellspacing="0" class="line3">
                                                                            <tr>
                                                                                <td width="30%">
                                                                                    <div align="left" class="head">
                                                                                        项目内容</div>
                                                                                </td>
                                                                                <td width="20%">
                                                                                    <div align="left" class="head">
                                                                                        单价</div>
                                                                                </td>
                                                                                <td width="20%">
                                                                                    <div align="left" class="head">
                                                                                        数量</div>
                                                                                </td>
                                                                                 <td width="20%">
                                                                                    <div align="left" class="head">
                                                                                        总额</div>
                                                                                </td>
                                                                            </tr>
                                                                            <tr>
                                                                                <td>
                                                                                    <div align="left">
                                                                                       <asp:TextBox ID="txtProj1" CssClass="textbox150" MaxLength="25" runat="server"></asp:TextBox>

                                                                                    </div>
                                                                                </td>
                                                                                 <td>                          
                                                                                    <div align="left">
                                                                                        <asp:TextBox ID="txtPrice1" CssClass="textbox80" runat="server"></asp:TextBox>
                                                                                    </div>
                                                                                </td>
                                                                                <td>
                                                                                    
                                                                                    <div align="left">
                                                                                        <asp:TextBox ID="txtNum1" CssClass="textbox80" runat="server"></asp:TextBox>
                                                                                    </div>

                                                                                </td> 
                                                                                <td>
                                                                                    <div align="left">
                                                                                        <asp:TextBox ID="txtAmount1" CssClass="textbox80" runat="server"></asp:TextBox>
                                                                                    </div>
                                                                                </td>
                                                                            </tr>
                                                                            <tr>
                                                                                <td>
                                                                                    <div align="left">
                                                                                       <asp:TextBox ID="txtProj2" CssClass="textbox150" MaxLength="25" runat="server"></asp:TextBox>
                                                                                    </div>
                                                                                </td>
                                                                                <td>                          
                                                                                    <div align="left">
                                                                                        <asp:TextBox ID="txtPrice2" CssClass="textbox80" runat="server"></asp:TextBox>
                                                                                    </div>
                                                                                </td>
                                                                                <td>
                                                                                    
                                                                                    <div align="left">
                                                                                        <asp:TextBox ID="txtNum2" CssClass="textbox80" runat="server"></asp:TextBox>
                                                                                    </div>

                                                                                </td> 
                                                                                <td>
                                                                                    <div align="left">
                                                                                        <asp:TextBox ID="txtAmount2" CssClass="textbox80" runat="server"></asp:TextBox>
                                                                                    </div>
                                                                                </td>
                                                                            </tr>
                                                                            <tr>
                                                                                <td>
                                                                                    <div align="left">
                                                                                       <asp:TextBox ID="txtProj3" CssClass="textbox150" MaxLength="25" runat="server"></asp:TextBox>
                                                                                    </div>
                                                                                </td>
                                                                                <td>                          
                                                                                    <div align="left">
                                                                                        <asp:TextBox ID="txtPrice3" CssClass="textbox80" runat="server"></asp:TextBox>
                                                                                    </div>
                                                                                </td>
                                                                                <td>
                                                                                    
                                                                                    <div align="left">
                                                                                        <asp:TextBox ID="txtNum3" CssClass="textbox80" runat="server"></asp:TextBox>
                                                                                    </div>

                                                                                </td> 
                                                                                <td>
                                                                                    <div align="left">
                                                                                        <asp:TextBox ID="txtAmount3" CssClass="textbox80" runat="server"></asp:TextBox>
                                                                                    </div>
                                                                                </td>
                                                                            </tr>
                                                                            <tr>
                                                                                <td>
                                                                                    <div align="left">
                                                                                       <asp:TextBox ID="txtProj4" Visible="false"  CssClass="textbox150" MaxLength="25" runat="server"></asp:TextBox>
                                                                                    </div>
                                                                                </td>
                                                                                 <td>                          
                                                                                    <div align="left">
                                                                                        <asp:TextBox ID="txtPrice4"  Visible="false" CssClass="textbox80" runat="server"></asp:TextBox>
                                                                                    </div>
                                                                                </td>
                                                                                <td>
                                                                                    
                                                                                    <div align="left">
                                                                                        <asp:TextBox ID="txtNum4" Visible="false"  CssClass="textbox80" runat="server"></asp:TextBox>
                                                                                    </div>

                                                                                </td> 
                                                                                <td>
                                                                                    <div align="left">
                                                                                        <asp:TextBox ID="txtAmount4" Visible="false"  CssClass="textbox80" runat="server"></asp:TextBox>
                                                                                    </div>
                                                                                </td>
                                                                            </tr>
                                                                            <tr>
                                                                                <td>
                                                                                    <div align="left">
                                                                                        <asp:TextBox ID="txtProj5" Visible="false"  CssClass="textbox150" MaxLength="25" runat="server"></asp:TextBox>
                                                                                    </div>
                                                                                </td>
                                                                                <td>                          
                                                                                    <div align="left">
                                                                                        <asp:TextBox ID="txtPrice5"  Visible="false"  CssClass="textbox80" runat="server"></asp:TextBox>
                                                                                    </div>
                                                                                </td>
                                                                                <td>
                                                                                    
                                                                                    <div align="left">
                                                                                        <asp:TextBox ID="txtNum5" Visible="false"  CssClass="textbox80" runat="server"></asp:TextBox>
                                                                                    </div>

                                                                                </td> 
                                                                                <td>
                                                                                    <div align="left">
                                                                                        <asp:TextBox ID="txtAmount5" Visible="false"  CssClass="textbox80" runat="server"></asp:TextBox>
                                                                                    </div>
                                                                                </td>
                                                                            </tr>
                                                                        </table>
                                                                    </td>
                                                                    <td width="31%" valign="top">
                                                                        <table width="195" height="192" border="0" align="center" cellpadding="0" cellspacing="0">
                                                                            <tr>
                                                                                <td class="head" align="left">
                                                                                    附注</td>
                                                                            </tr>
                                                                            <tr>
                                                                                <td align="left">
                                                                                    <asp:TextBox ID="txtNote" Height="140" Rows="5" Columns="20" MaxLength="100" TextMode="MultiLine"
                                                                                        runat="server"></asp:TextBox>
                                                                                </td>
                                                                            </tr>
                                                                        </table>
                                                                    </td>
                                                                </tr>
                                                            </table>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td width="18%">
                                                            <span class="head">合计（大写）：</span></td>
                                                        <td width="54%">
                                                            <asp:TextBox ID="txtTotal" CssClass="labeltextlong" ReadOnly="true" runat="server"></asp:TextBox>
                                                        </td>
                                                        <td width="11%" class="head">
                                                            ￥：</td>
                                                        <td width="17%">
                                                            <asp:TextBox ID="txtTotal2" CssClass="labeltext" ReadOnly="true" runat="server"></asp:TextBox>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                                <td>
                                    &nbsp;</td>
                            </tr>
                            <tr style="height: 25px">
                                <td>
                                    &nbsp;</td>
                                <td width="190" class="head">
                                    收款单位（盖章有效）：</td>
                                <td width="160">
                                    &nbsp;</td>
                                <td width="70" class="head">
                                </td>
                                <td width="81">
                                </td>
                                <td width="84" class="head">
                                    开票人：
                                </td>
                                <td width="96">
                                    <asp:TextBox ID="txtStaff" CssClass="labeltext" ReadOnly="true" runat="server"></asp:TextBox>
                                </td>
                                <td>
                                    &nbsp;</td>
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
                            <td>
                                &nbsp;</td>
                            <td>
                                <asp:Button ID="btnClear" runat="server" Text="新发票" CssClass="button1" OnClick="btnClear_Click" />
                            </td>
                        </tr>
                    </table>
                   
                </div>
            </ContentTemplate>
        </asp:UpdatePanel>
    </form>
</body>
</html>

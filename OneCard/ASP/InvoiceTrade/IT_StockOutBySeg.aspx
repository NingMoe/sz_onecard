<%@ Page Language="C#" AutoEventWireup="true" CodeFile="IT_StockOutBySeg.aspx.cs" Inherits="ASP_InvoiceTrade_IT_StockOutBySeg" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />

    <script type="text/JavaScript" src="../../js/mootools.js"></script>

    <script type="text/javascript" src="../../js/myext.js"></script>

    <script type="text/javascript" src="../../js/cardreaderhelper.js"></script>

    <script type="text/JavaScript">
        function FillZero(obj)
        {
            var beginNo = obj.value;

            if(beginNo.test("^\\s*\\d+\\s*$") ==false)
            {
                obj.value = "";
                return;
            }

            var allNo = '00000000' + beginNo;

            obj.value = allNo.substr(allNo.length - 8, 8);
        }

        function submitConfirm() {
            var sFCard = $get('txtBeginNo').value;
            var sECard = $get('hidEndNo').value;
            if (sFCard.test("^\\s*\\d{8}\\s*$") && sECard.test("\\s*^\\d{8}\\s*$")) {
                var lFCard = sFCard.toInt();
                var lECard = sECard.toInt();
                if (lECard - lFCard >= 0)
                    lCardSum = lECard - lFCard + 1;
            }


            $('txtCount').value = lCardSum;

//            Change();
            var selStaff="";
            var obj = document.getElementById("selStaff");   
            if(obj.value!="")
            {
                for(i=0;i<obj.length;i++){      
                    if(obj.options[i].selected){   
                        selStaff = obj.options[i].text+"";   
                        break;
                    }   
                }
            }
            if($get('txtVolumnNo').value != "" 
                &&  $get('txtBeginNo').value != "" 
                &&  $get('txtCount').value != "" 
                &&  selStaff != "")
           {
		        MyExtConfirm('确认',
		        '发票代码为： '+ $get('txtVolumnNo').value + '<br>' + 
		        '发票起始号码为： '+ $get('txtBeginNo').value + '<br>' + 
		        '发票最末号码为： '+ $get('hidEndNo').value + '<br>' +
		        '发票份数为：'+ $get('txtCount').value + '<br>' +
		        '领用人为：'+ selStaff + '<br>' +
		        '是否确认？'
		        , submitConfirmCallback);
                return false;
           }
           return true;
		}
		function submitConfirmCallback(btn)
        {
             if (btn == 'yes') {
                $get('btnConfirm').click();
            }
        }
    
    </script>

    <title>发票出库</title>
</head>
<body>
    <form id="form1" runat="server">
        <div class="tb">
            发票 -> 出库</div>
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
                <div class="con">
                    <div class="base">
                    </div>
                    <div class="kuang5">
                        <table class="text25" cellspacing="0" cellpadding="0" width="98%" border="0">
                            <tbody>
                                <tr>
                                    <td style="width: 10%; height: 25px" align="right">
                                        发票代码:
                                    </td>
                                    <td style="width: 20%; height: 25px" valign="middle">
                                        <asp:TextBox ID="txtVolumnNo_Sel" runat="server" CssClass="input" MaxLength="12"
                                            Width="135px"></asp:TextBox>&nbsp;&nbsp;
                                    </td>
                                    <td style="width: 10%; height: 25px" align="right">
                                        起讫发票号:
                                    </td>
                                    <td style="width: 40%; height: 25px" valign="middle">
                                        <asp:TextBox ID="txtBeginNo_Sel" CssClass="input" runat="server" MaxLength="8"></asp:TextBox>
                                        -
                                        <asp:TextBox ID="txtEndNo_Sel" CssClass="input" runat="server" MaxLength="8"></asp:TextBox>
                                    </td>
                                    <td style="width: 5%; height: 25px" align="right">
                                        &nbsp;</td>
                                    <td style="width: 15%; height: 25px">
                                        <asp:Button ID="btnQuery" OnClick="btnQuery_Click" runat="server" CssClass="button1"
                                            Text="查询"></asp:Button>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                    <div class="kuang5">
                        <div class="gdtb" style="height: 300px">
                            <asp:GridView ID="gvResult" runat="server" AutoGenerateSelectButton="False" Width="98%"
                                CssClass="tab1" HeaderStyle-CssClass="tabbt" AlternatingRowStyle-CssClass="tabjg"
                                SelectedRowStyle-CssClass="tabsel" PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left"
                                PagerStyle-VerticalAlign="Top" EmptyDataText="没有数据记录!" AllowPaging="True" PageSize="20"
                                OnPageIndexChanging="gvResult_PageIndexChanging">
                                <PagerSettings Mode="NumericFirstLast" />
                                <PagerStyle HorizontalAlign="Left" VerticalAlign="Top" />
                                <SelectedRowStyle CssClass="tabsel" />
                                <HeaderStyle CssClass="tabbt" />
                                <AlternatingRowStyle CssClass="tabjg" />
                            </asp:GridView>
                        </div>
                    </div>
                    <div class="pip">
                        发票出库</div>
                    <div class="kuang5">
                        <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                            <tr>
                                <tr>
                                    <td>
                                        <div align="right">
                                            发票代码:</div>
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtVolumnNo" CssClass="input" runat="server" MaxLength="12"></asp:TextBox>
                                    </td>
                                    <td>
                                        <div align="right">
                                            发票起始号码:</div>
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtBeginNo" CssClass="input" runat="server" MaxLength="8"></asp:TextBox>
                                        
                                    </td>
                                    <td>
                                        <div align="right">
                                            发票发票终止号码:</div>
                                    </td>
                                    <td>
                                    <input type="hidden" runat="server" id="txtCount" value="" />
                                    <asp:TextBox ID="hidEndNo" CssClass="input" runat="server" MaxLength="8"></asp:TextBox>
                                    
                                        
                                    </td>
                                </tr>
                            </tr>
                            <tr>
                                <td>
                                    <div align="right">
                                        领用部门:</div>
                                </td>
                                <td>
                                    <asp:DropDownList CssClass="input" ID="selDept" runat="server" AutoPostBack="true"
                                        OnSelectedIndexChanged="selDept_Changed">
                                    </asp:DropDownList>
                                </td>
                                <td>
                                    <div align="right">
                                        领用人:</div>
                                </td>
                                <td>
                                    <asp:DropDownList CssClass="input" ID="selStaff" runat="server">
                                    </asp:DropDownList>
                                </td>
                                <td colspan="2">
                                </td>
                            </tr>
                        </table>
                    </div>
                </div>
                <div class="btns">
                    <table width="100" border="0" align="right" cellpadding="0" cellspacing="0">
                        <tr>
                            <td>
                                <asp:LinkButton runat="server" ID="btnConfirm" OnClick="InvoiceStockOut_Click" />
                                <asp:Button ID="btnStockOut" CssClass="button1" runat="server" Text="发票出库"  OnClick="InvoiceStockOut_Click" OnClientClick="return submitConfirm()" />
                            </td>
                        </tr>
                    </table>
                </div>
            </ContentTemplate>
        </asp:UpdatePanel>
    </form>
</body>
</html>

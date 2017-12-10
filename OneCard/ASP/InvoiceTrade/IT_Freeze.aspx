<%@ Page Language="C#" AutoEventWireup="true" CodeFile="IT_Freeze.aspx.cs" Inherits="ASP_InvoiceTrade_IT_Freeze" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />

    <script type="text/JavaScript" src="../../js/mootools.js"></script>

    <script type="text/javascript" src="../../js/myext.js"></script>

    <script type="text/javascript" src="../../js/cardreaderhelper.js"></script>

    <script type="text/JavaScript">
    function Change()
    {
        var beginNo = $get('txtBeginNo').value;
        
        if(beginNo.test("^\\s*\\d+\\s*$") ==false)
        {
            $get('txtBeginNo').value = "";
            return;
        }
        
        var allNo = '00000000' + beginNo;
        
        $get('txtBeginNo').value = allNo.substr(allNo.length-8,8);

        if($get('txtCount').value != "")
        {
            txtCountControlChange();
        }
     }
    
        function txtCountControlChange()
        {
            var count = $get('txtCount').value;
            var beginNo = $get('txtBeginNo').value;
              
            if(count.test("^\\s*\\d+\\s*$")==false)
            {
                $get('txtCount').value="";
                return;
            }
            
            var endNo = Number(count) + Number(beginNo) -1;
            var allEndNo = '00000000' + endNo;
            $get('hidEndNo').value = allEndNo.substr(allEndNo.length-8,8);
        }
        
        function submitConfirm(){

            if($get('txtVolumnNo').value != "" 
                &&  $get('txtBeginNo').value != "" 
                &&  $get('txtCount').value != "" )
           {
		        MyExtConfirm('确认',
		        '发票代码为： '+ $get('txtVolumnNo').value + '<br>' + 
		        '发票起始号码为： '+ $get('txtBeginNo').value + '<br>' + 
		        '发票最末号码为： '+ $get('hidEndNo').value + '<br>' +
		        '发票份数为：'+ $get('txtCount').value + '<br>' +
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

    <title>发票冻结</title>
</head>
<body>
    <form id="form1" runat="server">
        <div class="tb">
            发票 -> 冻结</div>
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
                    <div class="pip">
                        发票冻结</div>
                    <div class="kuang5">
                        <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
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
                                    <input type="hidden" runat="server" id="hidEndNo" value="" />
                                </td>
                                <td>
                                    <div align="right">
                                        发票份数:</div>
                                </td>
                                <td>
                                    <asp:TextBox ID="txtCount" CssClass="input" runat="server" MaxLength="6"></asp:TextBox>
                                </td>
                            </tr>
                        </table>
                    </div>
                </div>
                <div class="btns">
                    <table width="100" border="0" align="right" cellpadding="0" cellspacing="0">
                        <tr>
                            <td>
                                <asp:LinkButton runat="server" ID="btnConfirm" OnClick="InvoiceStockIn_Click" />
                                <asp:Button ID="btnStockIn" CssClass="button1" runat="server" Text="发票冻结" OnClick="InvoiceStockIn_Click"
                                    OnClientClick="return submitConfirm()" />
                            </td>
                        </tr>
                    </table>
                </div>
            </ContentTemplate>
        </asp:UpdatePanel>
    </form>
</body>
</html>

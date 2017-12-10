<%@ Page Language="C#" AutoEventWireup="true" CodeFile="IT_Adopt.aspx.cs"
    Inherits="ASP_InvoiceTrade_IT_Adopt" %>

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
            发票 -> 领用</div>
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
                   
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="12text">
                        <tr>
                            <td width="20%">
                                <div class="jieguo">
                                    未领用发票信息</div>
                            </td>
                            <td width="30%">
                                <div align="left">
                                    </div>
                            </td>
                            <td width="10%">
                            </td>
                            <td width="30%">
                                <div align="left">
                                   </div>
                            </td>
                            <td width="10%">
                            </td>
                        </tr>
                    </table>
                    <div class="kuang5">
                        <div class="gdtb" style="height: 285px">
                             <asp:GridView ID="gvResult" runat="server" AutoGenerateSelectButton="False" Width="98%"
                                CssClass="tab1" HeaderStyle-CssClass="tabbt" AlternatingRowStyle-CssClass="tabjg"
                                SelectedRowStyle-CssClass="tabsel" PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left"
                                PagerStyle-VerticalAlign="Top" EmptyDataText="没有数据记录!"
                                >
                                <PagerSettings Mode="NumericFirstLast" />
                                <PagerStyle HorizontalAlign="Left" VerticalAlign="Top" />
                                <SelectedRowStyle CssClass="tabsel" />
                                <HeaderStyle CssClass="tabbt" />
                                <AlternatingRowStyle CssClass="tabjg" />
                            </asp:GridView>
                        </div>
                    </div>         
                </div>
                <div class="btns">
                    <table width="100" border="0" align="right" cellpadding="0" cellspacing="0">
                        <tr>
                            <td>
                                <asp:Button ID="Button1" runat="server" Text="发票领用" CssClass="button1" OnClick="InvoiceAdopt_Click"
                                     />
                            </td>
                        </tr>
                    </table>
                </div>
            </ContentTemplate>
        </asp:UpdatePanel>
    </form>
</body>
</html>

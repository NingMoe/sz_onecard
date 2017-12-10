<%@ Page Language="C#" AutoEventWireup="true" CodeFile="FI_CommissionAudit.aspx.cs" Inherits="ASP_Financial_FI_CommissionAudit" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <title>商户佣金凭证审核</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
     <script type="text/javascript" src="../../js/print.js"></script>
     <script type="text/javascript" src="../../js/myext.js"></script>
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
    
        <div class="tb">
		    财务管理->商户佣金凭证审核
	    </div>
	
	    <ajaxToolkit:ToolkitScriptManager runat="Server" EnableScriptGlobalization="true" EnableScriptLocalization="true" ID="ToolkitScriptManager1" />
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
        <asp:UpdatePanel ID="UpdatePanel2" runat="server">  
            <ContentTemplate>  
               
            <!-- #include file="../../ErrorMsg.inc" -->  
	        <div class="con">

	           <div class="card">查询</div>
               <div class="kuang5">
               <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                <tr>
                   <td width="18%"> <div align="right">商户佣金凭证号:</div></td>
                   <td width="58%">
                        <asp:TextBox ID="txtNo" CssClass="inputmid" runat="server" ></asp:TextBox>
                   </td>
                   <td width="24%">
                        <asp:Button ID="btnQuery" CssClass="button1" runat="server" Text="查询" OnClick="btnQuery_Click" />
                   </td>
                </tr>
               </table>
             </div>
	
            <div class="jieguo">查询结果</div>
              <div class="kuang5">
                <div id="gdtb" style="height:auto;min-height:350px">
                
                    <asp:GridView ID="gvResult" runat="server"
                            Width = "98%"
                            CssClass="tab2"
                            HeaderStyle-CssClass="tabbt"
                            AlternatingRowStyle-CssClass="tabjg"
                            SelectedRowStyle-CssClass="tabsel"
                            PagerSettings-Mode="NumericFirstLast"
                            PagerStyle-HorizontalAlign="left"
                            PagerStyle-VerticalAlign="Top"
                            AutoGenerateColumns="true">
                    </asp:GridView>
                    
                </div>
              </div>
              
              <div class="btns">
                  <table width="200" border="0" align="right" cellpadding="0" cellspacing="0">
                    <tr>
                      <td><asp:Button ID="btnBilling" CssClass="button1" runat="server" OnClick="btnBilling_Click" Text="确认开票" /></td>
                      <td><asp:Button ID="btnWithdraw" CssClass="button1" runat="server" OnClick="btnWithdraw_Click" Text="回退" /></td>
                    </tr>
                  </table>
                  审核状态:
                  <asp:TextBox ID="txtState" CssClass="input" runat="server" ReadOnly="true" ></asp:TextBox>
              </div>
            
            </div>

            </ContentTemplate>
        </asp:UpdatePanel>
        
    </form>
</body>
</html>

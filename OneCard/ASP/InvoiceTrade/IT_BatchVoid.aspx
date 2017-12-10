<%@ Page Language="C#" AutoEventWireup="true" CodeFile="IT_BatchVoid.aspx.cs" Inherits="ASP_InvoiceTrade_IT_BatchVoid" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
	<link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <script type="text/JavaScript" src="../../js/mootools.js"></script>

     <script type="text/javascript" src="../../js/myext.js"></script>
<script type="text/javascript" src="../../js/cardreaderhelper.js"></script>
    <script type="text/JavaScript">
    function Change()
    {
        var sF = $get('txtBeginNo').value;
        var sE = $get('txtEndNo').value;
        var lSum = 0;
        if(sF.test("^\\s*\\d+\\s*$") && sE.test("^\\s*\\d+\\s*$"))
        {
            var lF = Number(sF);
            var lE = Number(sE);
            if(lE - lF >= 0)
                lSum = lE - lF + 1;
        }
       
        $('txtCount').value = lSum;
    }
    </script>
    <title>发票批量作废</title>
</head>
<body>
    <form id="form1" runat="server">
    
        <div class="tb">发票 -> 批量作废</div>

        <ajaxToolkit:ToolkitScriptManager runat="Server" EnableScriptGlobalization="true"
            EnableScriptLocalization="true" ID="ScriptManager2" />
        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
            <ContentTemplate>
            <!-- #include file="../../ErrorMsg.inc" --> 
           
            <div class="con">
                <div class="pip">发票批量作废</div>
                <div class="kuang5">
                   <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                     <tr>
                       <td width="12%"><div align="right">起讫发票号:</div></td>
                       <td width="60%">
                            <asp:TextBox ID="txtBeginNo" CssClass="input" runat="server" MaxLength="8"></asp:TextBox>
                         -
                            <asp:TextBox ID="txtEndNo" CssClass="input" runat="server" MaxLength="8"></asp:TextBox>
                       </td>
                       <td width="28%">&nbsp;</td>
                      </tr>
                      <tr>
                       <td><div align="right">作废数量:</div></td>
                       <td>
                            <asp:TextBox ID="txtCount" CssClass="labeltext" runat="server" Text="0" ReadOnly="true"></asp:TextBox>
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
                  <asp:LinkButton runat="server" ID="btnConfirm" OnClick="InvoiceVoid_Click" />
                    <asp:Button ID="Button1" CssClass="button1" runat="server" Text="发票作废"  OnClientClick="return FapiaoCheck()"/>
                  </td>

                </tr>
              </table>
              发票代码:<span class="red"><asp:Label runat="server" ID="labVolumnNo"/></span>
            </div>
            
            
            </ContentTemplate>
        </asp:UpdatePanel>
        
    </form>
    
</body>
</html>
<%@ Page Language="C#" AutoEventWireup="true" CodeFile="UC_StockIn.aspx.cs" Inherits="ASP_UserCard_UC_StockIn" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
     <title>用户卡入库</title>
   <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
   <script type="text/javascript" src="../../js/myext.js"></script>
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />

    <script type="text/javascript" src="../../js/mootools.js"></script>

    <script type="text/javascript">
        function Change()
        {
            var sFCard = $('txtFromCardNo').value;
            var sECard = $('txtToCardNo').value;
            var sCardMoney = $('txtUnitPrice').value;
            var lCardSum = 0;
            var lCardMoney = 0;
            if(sFCard.test("^\\s*\\d{16}\\s*$") && sECard.test("\\s*^\\d{16}\\s*$"))
            {
                var lFCard = sFCard.toInt();
                var lECard = sECard.toInt();
                if(lECard - lFCard >= 0)
                    lCardSum = lECard - lFCard + 1;
            }
            
            if(sCardMoney.test("^\\d{1,10}(\\.\\d{0,2})?$"))
            {
                lCardMoney = sCardMoney.toFloat();
            }

            $('txtCardSum').value = lCardSum;
            $('txtTotal').value = lCardSum*lCardMoney + " * 100 分";
        }
    </script>

</head>
<body>
    <form id="form1" runat="server">
        <div class="tb">
             卡片管理->用户卡入库（原）
        </div>
       
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
    <asp:BulletedList  ID="bulMsgShow" runat="server"/>
    <script runat="server" >public override void ErrorMsgShow(){ErrorMsgHelper(bulMsgShow);}</script>
    
 <div class="con">
    <div class="card">
    卡批量入库</div>
    <div class="kuang5">
    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
    <tr>
    <td>
        <div align="right">
            起讫卡号:</div>
    </td>
    <td colspan="3">
        <asp:TextBox ID="txtFromCardNo" CssClass="inputmid" runat="server" MaxLength="16"></asp:TextBox>
        -
        <asp:TextBox ID="txtToCardNo" CssClass="inputmid" runat="server" MaxLength="16"
         AutoPostBack="true" OnTextChanged="txtToCardNo_Changed"></asp:TextBox>
        <span class="red">*</span>
        <div align="right">
        </div>
    </td>
    </tr>
    <tr>
    <td>
        <div align="right">
            入库数量:</div>
    </td>
    <td>&nbsp;
        <asp:TextBox ID="txtCardSum" CssClass="labeltext" width=100 runat="server" Text="0"></asp:TextBox></td>
    <td>
        <div align="right">
            卡片单价:</div>
    </td>
    <td>
        <asp:TextBox ID="txtUnitPrice" CssClass="input" runat="server" MaxLength="13"></asp:TextBox>
        <span class="red">*</span> 100 分</td>
    <td>
        <div align="right">
            总金额:</div>
    </td>
    <td>
        &nbsp;<asp:TextBox ID="txtTotal" CssClass="labeltext" width=100 Text="0 * 100 分" runat="server" ></asp:TextBox>
        </td>
    </tr>
    <tr>
    <td>
        <div align="right">
            卡面类型:</div>
    </td>
    <td>
        <asp:TextBox ID="txtFaceType" CssClass="labeltext" runat="server">
        </asp:TextBox></td>
    <td>
        <div align="right">
            卡片类型:</div>
    </td>
    <td>
        <asp:TextBox ID="txtCardType" CssClass="labeltext" runat="server">
        </asp:TextBox></td>
    <td>
        <div align="right">
            芯片类型:</div>
    </td>
    <td>
        <asp:DropDownList ID="selChipType" CssClass="inputmid" runat="server">
        </asp:DropDownList></td>
    </tr>
    <tr>
    <td>
        <div align="right">
            COS类型:</div>
    </td>
    <td>
        <asp:DropDownList ID="selCosType" CssClass="inputmid" runat="server">
        </asp:DropDownList></td>
    <td>
        <div align="right">
            卡片厂商:</div>
    </td>
    <td>
        <asp:DropDownList ID="selProducer" CssClass="inputmid" runat="server">
        </asp:DropDownList></td>
    <td>
        <div align="right">
            应用版本:</div>
    </td>
    <td>
        <asp:TextBox ID="txtAppVersion" runat="server" CssClass="input" MaxLength="2"></asp:TextBox>
        <span class="red">*</span>
        </td>
    </tr>
    <tr>
    <td>
        <div align="right">
            有效日期:</div>
    </td>
    <td colspan="3">
        <asp:TextBox runat="server" ID="txtEffDate" CssClass="inputmid"  MaxLength="8"/>
        -
        <asp:TextBox runat="server" ID="txtExpDate" CssClass="inputmid"  MaxLength="8"/>
        <ajaxToolkit:CalendarExtender ID="FCalendar" runat="server" TargetControlID="txtEffDate"
            Format="yyyyMMdd" />
        <ajaxToolkit:CalendarExtender ID="ECalendar" runat="server" TargetControlID="txtExpDate"
            Format="yyyyMMdd" />
            <span class="red">*</span>
    </td>
    <td>
        &nbsp;</td>
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
    <asp:Button ID="btnStockIn" CssClass="button1" runat="server" Text="提交" OnClick="btnStockIn_Click" /></td>
    </tr>
    </table>
    </div>
            </ContentTemplate>
        </asp:UpdatePanel>
    </form>
</body>
</html>

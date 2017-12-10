<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PB_BatchSaleCard.aspx.cs"
    Inherits="ASP_PersonalBusiness_PB_BatchSaleCard" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>批量修改客户信息</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />

    <script type="text/javascript" src="../../js/myext.js"></script>

    <link href="../../css/card.css" rel="stylesheet" type="text/css" />

    <script type="text/javascript" src="../../js/mootools.js"></script>

    <script type="text/javascript">
        function Change() {
            var sFCard = $('txtFromCardNo').value;
            var sECard = $('txtToCardNo').value;
            var sDeposit = $('txtDeposit').value;
            var sCardCost = $('txtCardCost').value;
            var lCardSum = 0;
            var lCardMoney = 0;
            if (sFCard.test("^\\s*\\d{16}\\s*$") && sECard.test("\\s*^\\d{16}\\s*$")) {
                var lFCard = sFCard.toInt();
                var lECard = sECard.toInt();
                if (lECard - lFCard >= 0)
                    lCardSum = lECard - lFCard + 1;
            }

            if (sDeposit.test("^\\d{1,10}(\\.\\d{0,2})?$")) {
                lCardMoney += sDeposit.toFloat();
            }
            if (sCardCost.test("^\\d{1,10}(\\.\\d{0,2})?$")) {
                lCardMoney += sCardCost.toFloat();
            }

            //            $('txtCardSum').value = lCardSum;
            //            $('txtTotal').value = lCardSum * lCardMoney + " * 100 分";
            document.getElementById("txtSellTimes").value = lCardSum;
            document.getElementById("txtMoney").value = lCardSum * lCardMoney + " * 100 分";
        }
    </script>

</head>
<body>
    <form id="form1" runat="server">
    <div class="tb">
        个人业务->批量售卡
    </div>
    <ajaxToolkit:ToolkitScriptManager runat="Server" EnableScriptGlobalization="true"
        EnableScriptLocalization="true" ID="ScriptManager2" />

    <script type="text/javascript" language="javascript">
        var swpmIntance = Sys.WebForms.PageRequestManager.getInstance();
        swpmIntance.add_initializeRequest(BeginRequestHandler);
        swpmIntance.add_pageLoading(EndRequestHandler);
        function BeginRequestHandler(sender, args) {
            try { MyExtShow('请等待', '正在提交后台处理中...'); } catch (ex) { }
        }
        function EndRequestHandler(sender, args) {
            try { MyExtHide(); } catch (ex) { }
        }
    </script>

    <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
            <asp:BulletedList ID="bulMsgShow" runat="server">
            </asp:BulletedList>

            <script runat="server">public override void ErrorMsgShow() { ErrorMsgHelper(bulMsgShow); }</script>

            <div class="con">
                <div class="card">
                    起讫卡号</div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td width="10%">
                                <div align="right">
                                    起讫卡号:</div>
                            </td>
                            <td width="40%">
                                <asp:TextBox ID="txtFromCardNo" CssClass="inputmid" runat="server" MaxLength="16"></asp:TextBox>
                                -
                                <asp:TextBox ID="txtToCardNo" CssClass="inputmid" runat="server" MaxLength="16"></asp:TextBox>
                            </td>
                            <td width="10%">
                                &nbsp;
                            </td>
                            <td width="20%">
                                &nbsp;
                            </td>
                            <td width="20%">
                                &nbsp;
                            </td>
                        </tr>
                        <tr>
                            <td width="10%">
                                <div align="right">
                                    卡押金:</div>
                            </td>
                            <td width="30%">
                                <asp:TextBox ID="txtDeposit" CssClass="inputshort" runat="server" Text="0"></asp:TextBox><span
                                    class="red">*</span> 100 分
                            </td>
                            <td width="10%">
                                <div align="right">
                                    卡费:</div>
                            </td>
                            <td width="30%">
                                <asp:TextBox ID="txtCardCost" CssClass="inputshort" runat="server" Text="0"></asp:TextBox><span
                                    class="red">*</span> 100 分
                            </td>
                            <td width="20%">
                            </td>
                        </tr>
                        <tr>
                            <td width="10%" align="right">
                                总笔数:
                            </td>
                            <td width="20%" align="left">
                                <asp:TextBox ID="txtSellTimes" CssClass="inputshort" runat="server" Text="0"></asp:TextBox>
                            </td>
                            <td width="10%" align="right">
                                总金额:
                            </td>
                            <td width="20%" align="left">
                                <asp:TextBox ID="txtMoney" CssClass="inputshort" runat="server" Text="0 * 100 分"></asp:TextBox>
                            </td>
                            <td width="20%">
                                &nbsp;
                            </td>
                        </tr>
                        <tr>
                            <td width="10%">
                                <div align="right">
                                    售卡时间:</div>
                            </td>
                            <td width="40%">
                                <asp:TextBox runat="server" ID="txtSellTime" CssClass="inputshort" MaxLength="8" />
                                <ajaxToolkit:CalendarExtender ID="FCalendar" runat="server" TargetControlID="txtSellTime"
                                    Format="yyyyMMdd" />
                                <span class="red">*</span>
                            </td>
                            <td width="10%" align="right">
                                备注:
                            </td>
                            <td width="20%">
                                <asp:TextBox ID="txtReMark" CssClass="inputlong" MaxLength="50" runat="server"></asp:TextBox>
                            </td>
                            <td width="20%">
                                &nbsp;
                            </td>
                        </tr>
                    </table>
                </div>
                <div class="btns">
                    <table width="200" border="0" align="right" cellpadding="0" cellspacing="0">
                        <tr>
                            <td>
                                <asp:Button ID="btnRefund" CssClass="button1" runat="server" Text="提交" OnClick="btnSubmit_Click" />
                            </td>
                        </tr>
                    </table>
                </div>
        </ContentTemplate>
    </asp:UpdatePanel>
    </form>
</body>
</html>

<%@ Page Language="C#" AutoEventWireup="true" CodeFile="EM_ReaderStockOut.aspx.cs"
    Inherits="ASP_EquipmentManagement_EM_ReaderStockOut" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>读卡器出库</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="../../js/mootools.js"></script>
    <script type="text/javascript" src="../../js/myext.js"></script>
    <script type="text/javascript" language="javascript">
        function Change() {
            var sFCard;
            var sECard;
            var lCardSum;
            var lFCard;
            var lECard;
            sFCard = $('txtFromReaderNo').value;
            sECard = $('txtToReaderNo').value;
            lCardSum = 0;
            if (sFCard.test("^\\s*\\d{16}\\s*$") && sECard.test("\\s*^\\d{16}\\s*$")) {
                lFCard = sFCard.toInt();
                lECard = sECard.toInt();
                if (lECard - lFCard >= 0)
                    lCardSum = lECard - lFCard + 1;
            }

            $('txtReaderNum').value = lCardSum;
            return false;
        }

        function submitConfirm() {
            if (true) {
                MyExtConfirm('确认',
		        '读卡器' + $get('txtFromReaderNo').value + '-' + $get('txtToReaderNo').value + '出库，<br>是否确认提交？'
		        , submitConfirmCallback);
            }
            return false;
        }
        function submitConfirmCallback(btn) {
            if (btn == 'yes') {
                $get('btnConfirm').click();
            }
            return false;
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
    <div class="tb">
        设备管理->读卡器出库
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
            <asp:BulletedList ID="bulMsgShow" runat="server" />
            <script runat="server">public override void ErrorMsgShow() { ErrorMsgHelper(bulMsgShow); }</script>
            <div class="con">
                <div class="card">
                    读卡器出库</div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td width="12%">
                                <div align="right">
                                    起讫序列号:</div>
                            </td>
                            <td width="36%" colspan="3">
                                <asp:TextBox ID="txtFromReaderNo" CssClass="inputmid" runat="server" MaxLength="16"></asp:TextBox>
                                -
                                <asp:TextBox ID="txtToReaderNo" CssClass="inputmid" runat="server" MaxLength="16"></asp:TextBox>
                                <span class="red">*</span>
                                <div align="right">
                                </div>
                            </td>
                            <td width="12%">
                                <div align="right">
                                    出库数量:</div>
                            </td>
                            <td width="40%" colspan="3">
                                <asp:TextBox ID="txtReaderNum" CssClass="labeltext" runat="server" MaxLength="8"></asp:TextBox>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    领用员工:</div>
                            </td>
                            <td colspan="3">
                                <asp:DropDownList ID="selAssignedStaff" CssClass="inputmid" runat="server"  AutoPostBack="true" OnSelectedIndexChanged="selAssignedStaff_Change">
                                </asp:DropDownList>
                                <span class="red">*</span>
                            </td>
                            <td align="right">
                                销售金额:
                            </td>
                            <td colspan="3">
                                <asp:TextBox ID="txtSaleMoney" CssClass="input" runat="server" MaxLength="4" /><span
                                    class="red">*</span>100 分
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    备注:</div>
                            </td>
                            <td colspan="7">
                                <asp:TextBox ID="txtRemark" CssClass="inputlong" runat="server" MaxLength="50"></asp:TextBox>
                            </td>
                        </tr>
                    </table>
                    <div class="linex">
                    </div>
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td style="width: 12%" align="right">
                                保证金余额:
                            </td>
                            <td style="width: 12%">
                                <asp:Label ID="labDeposit" runat="server" />
                            </td>
                            <td style="width: 12%" align="right">
                                可领卡价值额度:
                            </td>
                            <td style="width: 12%">
                                <asp:Label ID="labUsablevalue" runat="server" />
                            </td>
                            <td style="width: 12%" align="right">
                                网点剩余卡价值:
                            </td>
                            <td style="width: 12%">
                                <asp:Label ID="labStockvalue" runat="server" />
                            </td>
                        </tr>
                        <tr>
                            <td style="width: 12%" align="right">
                                最大可领用数：
                            </td>
                            <td style="width: 12%" colspan="5">
                                <asp:Label ID="labMaxAvailaCard" runat="server" />
                            </td>
                        </tr>
                    </table>
                </div>
            </div>
            <div class="btns">
                <table width="100" border="0" align="right" cellpadding="0" cellspacing="0">
                    <tr>
                        <td>
                            <asp:LinkButton runat="server" ID="btnConfirm" OnClick="btnConfirm_Click" />
                            <asp:Button ID="btnStockIn" CssClass="button1" runat="server" Text="提交" OnClick="btnStockIn_Click" />
                        </td>
                    </tr>
                </table>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
    </form>
</body>
</html>

<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PS_PrepayManger.aspx.cs"
    Inherits="ASP_PartnerShip_PS_PrepayManger" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>预付款收支管理</title>

    <script type="text/javascript" src="../../js/myext.js"></script>

    <script type="text/javascript" src="../../js/Numtochinese.js"></script>

    <link href="../../css/card.css" rel="stylesheet" type="text/css" />

    <script type="text/javascript">
        function checkPrepayMoney() {
            Numbertochinese();
            var dealMoney = parseFloat($get('txtDealMoney').value);
            var prepay = parseFloat($get('labPrepay').innerHTML.replace(/,/g, ""));
            var prepayLimitLine = parseFloat($get('labPrepayLimitLine').innerHTML.replace(/,/g, ""));
            var prepayWarnLine = parseFloat($get('labPrepayWarnLine').innerHTML.replace(/,/g, ""));
            if ($get('Pay').checked == true) {
                if (dealMoney > prepay) {
                    //MyExtAlert('错误', '交易金额大于预付款余额！', false);
                    if ($get('bulMsgShow') != null) {
                        $get('bulMsgShow').innerHTML = "";
                    }
                    $get('ErrorMessage').innerHTML = '<ul class="errormessage"><li>A008905010：交易金额不能大于预付款余额</li></ul>';
                    $get('txtDealMoney').style.backgroundColor = "#FFC0C0";
                    return false;
                }
                else if (prepay - dealMoney < prepayLimitLine) {
                    MyExtConfirm('确认', '交易后预付款余额低于预付款最低值，是否确认支出？', submitConfirmCallback);
                    return false;
                }
                else if (prepay - dealMoney < prepayWarnLine) {
                    MyExtConfirm('确认', '交易后预付款余额低于预付款预警值，是否确认支出？', submitConfirmCallback);
                    return false;
                }
                else {
                    MyExtConfirm('确认', '支出金额为' + $get("txtDealMoney").value + '元，是否确认支出？', submitConfirmCallback);
                    return false;
                }
            }
            else if ($get('Income').checked == true) {
                MyExtConfirm('确认', '收入金额为' + $get("txtDealMoney").value + '元，是否确认收入？', submitConfirmCallback);

                return false;
            }


        }
        function submitConfirmCallback(btn) {
            if (btn == 'yes') {
                $get('btnConfirm').click();
            }
        }

        function Numbertochinese() {
            var num = $get("txtDealMoney").value;
            if (numtochinese(num) == false) {
                var numInfo = $get("txtDealMoney").value;
                numInfo = numInfo.substring(0, numInfo.length - 1);
                $get("txtDealMoney").value = numInfo;
                if (numInfo == "") {
                    $get('labChineseNum').innerHTML = "";
                    $get('hidChineseNum').value = "";
                }
            }
            else {
                $get('labChineseNum').innerHTML = numtochinese(num);
                $get('hidChineseNum').value = numtochinese(num);

            }
        }
    </script>

</head>
<body>
    <form id="form1" runat="server">
    <div class="tb">
        合作伙伴->预付款收支管理</div>
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
            <div id="ErrorMessage">
            </div>
            <asp:BulletedList ID="bulMsgShow" runat="server" />

            <script runat="server">public override void ErrorMsgShow() { ErrorMsgHelper(bulMsgShow); }</script>

            <div class="con">
                <div class="card">
                    查询单位信息</div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="12text">
                        <tr>
                            <td align="right" width="15%">
                                单元类型:
                            </td>
                            <td width="15%">
                                <asp:DropDownList ID="ddlBalType" CssClass="input" runat="server" OnSelectedIndexChanged="ddlBalType_SelectedIndexChanged"
                                    AutoPostBack="true">
                                    <asp:ListItem Text="---请选择---" Value=""></asp:ListItem>
                                    <asp:ListItem Text="1:代理网点" Value="1"></asp:ListItem>
                                    <asp:ListItem Text="2:代理商户" Value="2"></asp:ListItem>
                                </asp:DropDownList>
                            </td>
                            <td width="15%">
                                <div align="right">
                                    网点结算单元:</div>
                            </td>
                            <td width="25%">
                                <asp:DropDownList ID="ddlBalUnit" CssClass="inputmidder" runat="server" AutoPostBack="true"
                                    OnSelectedIndexChanged="ddlBalUnit_Change">
                                </asp:DropDownList>
                            </td>
                            <td width="15%">
                                <div align="right">
                                    审核状态:</div>
                            </td>
                            <td width="15%">
                                <asp:DropDownList ID="selExamState" CssClass="input" runat="server">
                                    <asp:ListItem Text="0: 等待审核" Value="0"></asp:ListItem>
                                    <asp:ListItem Text="1: 审核通过" Value="1"></asp:ListItem>
                                    <asp:ListItem Text="2: 审核作废" Value="2"></asp:ListItem>
                                </asp:DropDownList>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    开始日期:</div>
                            </td>
                            <td>
                                <asp:TextBox runat="server" ID="txtFromDate" MaxLength="8" CssClass="input"></asp:TextBox>
                                <ajaxToolkit:CalendarExtender ID="CalendarExtender1" runat="server" TargetControlID="txtFromDate"
                                    Format="yyyyMMdd" />
                            </td>
                            <td>
                                <div align="right">
                                    结束日期:</div>
                            </td>
                            <td>
                                <asp:TextBox runat="server" ID="txtToDate" MaxLength="8" CssClass="input"></asp:TextBox>
                                <ajaxToolkit:CalendarExtender ID="CalendarExtender2" runat="server" TargetControlID="txtToDate"
                                    Format="yyyyMMdd" />
                            </td>
                            <td align="right">
                                <asp:Button ID="btnQuery" runat="server" Text="查询" CssClass="button1" OnClick="btnQuery_Click" />
                            </td>
                            <td>
                            </td>
                        </tr>
                    </table>
                </div>
                <table border="0" width="95%">
                    <tr>
                        <td align="left">
                            <div class="jieguo">
                                网点结算单元预付款信息</div>
                        </td>
                        <td align="right">
                            <asp:Button ID="btnExport" CssClass="button1" runat="server" Text="导出Excel" OnClick="btnExport_Click" />
                        </td>
                    </tr>
                </table>
                <div class="kuang5">
                    <div id="gdtb" style="height: 105px">
                        <asp:GridView ID="lvwPrepayQuery" runat="server" Width="1600px" CssClass="tab1" HeaderStyle-CssClass="tabbt"
                            AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel" AllowPaging="True"
                            PageSize="20" PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left"
                            PagerStyle-VerticalAlign="Top" AutoGenerateColumns="true" OnPageIndexChanging="lvwPrepayQuery_Page"
                            OnRowDataBound="lvwPrepayQuery_RowDataBound">
                        </asp:GridView>
                    </div>
                </div>
                <div class="base">
                    网点结算单元信息</div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td align="right" style="width: 12%">
                                结算单元编码:
                            </td>
                            <td style="width: 12%">
                                <asp:Label ID="labBalUnitNO" runat="server" />
                            </td>
                            <td style="width: 12%" align="right">
                                结算单元名称:
                            </td>
                            <td style="width: 36%" colspan="3">
                                <asp:Label ID="labBalUnit" runat="server" />
                            </td>
                            <td style="width: 12%" align="right">
                                合作时间:
                            </td>
                            <td style="width: 12%">
                                <asp:Label ID="labCreatTime" runat="server" />
                            </td>
                        </tr>
                        <tr>
                            <td align="right">
                                网点类型:
                            </td>
                            <td>
                                <asp:Label ID="labDeptType" runat="server" />
                            </td>
                            <td align="right" style="width: 12%">
                                开户银行:
                            </td>
                            <td colspan="3">
                                <asp:Label ID="labBank" runat="server" />
                            </td>
                            <td align="right">
                                银行帐号:
                            </td>
                            <td>
                                <asp:Label ID="labBankAccNo" runat="server" />
                            </td>
                        </tr>
                    </table>
                    <div class="linex">
                    </div>
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td style="width: 12%" align="right">
                                结算周期类型:
                            </td>
                            <td style="width: 12%">
                                <asp:Label ID="labBalCyclType" runat="server" />
                            </td>
                            <td style="width: 12%" align="right">
                                结算周期跨度:
                            </td>
                            <td style="width: 12%">
                                <asp:Label ID="labBalInterval" runat="server" />
                            </td>
                            <td style="width: 12%" align="right">
                                转账类型:
                            </td>
                            <td style="width: 12%">
                                <asp:Label ID="labFinType" runat="server" />
                            </td>
                            <td style="width: 12%" align="right">
                                划账周期类型:
                            </td>
                            <td style="width: 12%">
                                <asp:Label ID="labFinCyclType" runat="server" />
                            </td>
                        </tr>
                        <tr>
                            <td style="width: 12%" align="right">
                                划账周期跨度:
                            </td>
                            <td style="width: 12%">
                                <asp:Label ID="labFinCyclInterval" runat="server" />
                            </td>
                            <td style="width: 12%" align="right">
                                转出银行:
                            </td>
                            <td colspan="5">
                                <asp:Label ID="labFinBank" runat="server" />
                            </td>
                        </tr>
                    </table>
                    <div class="linex">
                    </div>
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td style="width: 12%" align="right">
                                联系人:
                            </td>
                            <td style="width: 12%">
                                <asp:Label ID="labLinkMan" runat="server" />
                            </td>
                            <td style="width: 12%" align="right">
                                联系电话:
                            </td>
                            <td style="width: 12%">
                                <asp:Label ID="labPhone" runat="server" />
                            </td>
                            <td style="width: 12%" align="right">
                                联系地址:
                            </td>
                            <td style="width: 36%">
                                <asp:Label ID="labAddress" runat="server" />
                            </td>
                        </tr>
                        <tr>
                            <td style="width: 12%" align="right">
                                电子邮件:
                            </td>
                            <td style="width: 12%">
                                <asp:Label ID="labEmail" runat="server" />
                            </td>
                            <td style="width: 12%" align="right">
                                备注:
                            </td>
                            <td style="width: 60%" colspan="3">
                                <asp:Label ID="labReMark" runat="server" />
                            </td>
                        </tr>
                    </table>
                    <div class="linex">
                    </div>
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td style="width: 12%" align="right">
                                预付款余额:
                            </td>
                            <td style="width: 12%">
                                <asp:Label ID="labPrepay" runat="server" />元
                            </td>
                            <td style="width: 12%" align="right">
                                预付款预警值:
                            </td>
                            <td style="width: 12%">
                                <asp:Label ID="labPrepayWarnLine" runat="server" />元
                            </td>
                            <td style="width: 12%" align="right">
                                预付款最低值:
                            </td>
                            <td style="width: 12%" colspan="3">
                                <asp:Label ID="labPrepayLimitLine" runat="server" />元
                            </td>
                        </tr>
                        <tr>
                            <td style="width: 12%" align="right">
                            </td>
                            <td style="width: 12%">
                                <asp:Label ID="Label1" runat="server" />
                            </td>
                            <td style="width: 12%" align="right">
                            </td>
                            <td style="width: 12%">
                                <asp:Label ID="Label2" runat="server" />
                            </td>
                            <td style="width: 12%" align="right">
                            </td>
                            <td style="width: 12%">
                                <asp:Label ID="Label3" runat="server" />
                            </td>
                            <td style="width: 12%" align="right">
                            </td>
                            <td style="width: 12%">
                                <asp:Label ID="Label4" runat="server" />
                            </td>
                        </tr>
                    </table>
                </div>
                <div class="info">
                    收支信息</div>
                <div class="kuang5" style="height: 30px;">
                    <table>
                        <tr>
                            <td style="width: 10%" align="right">
                                <asp:RadioButton ID="Income" Visible="true" Checked="true" Text="收入" GroupName="SupplyMoney"
                                    TextAlign="Right" runat="server" />
                            </td>
                            <td style="width: 10%" align="center">
                                <asp:RadioButton ID="Pay" Visible="true" Checked="false" Text="支出" GroupName="SupplyMoney"
                                    TextAlign="Right" runat="server" />
                            </td>
                            <td style="width: 10%">
                                <div align="right">
                                    交易金额:</div>
                            </td>
                            <td style="width: 20%">
                                <asp:TextBox ID="txtDealMoney" runat="server" CssClass="input" onkeyup="Numbertochinese();"
                                    MaxLength="10"></asp:TextBox>
                            </td>
                            <td style="width: 10%">
                                <div align="right">
                                    大写:</div>
                            </td>
                            <td style="width: 20%" align="left">
                                <asp:Label ID="labChineseNum" runat="server" /><input type="hidden" id="hidChineseNum"
                                    runat="server" />
                            </td>
                            <td style="width: 10%">
                                <div align="right">
                                    备注:</div>
                            </td>
                            <td>
                                <asp:TextBox ID="txtReMark" runat="server" CssClass="input" Width="200px" MaxLength="50"></asp:TextBox>
                            </td>
                            <td style="width: 10%" align="left">
                                <asp:LinkButton runat="server" ID="btnConfirm" OnClick="btnSupply_Click" />
                                <asp:Button ID="btnSupply" CssClass="button1" runat="server" Text="提交" Enabled="false"
                                    OnClientClick="return checkPrepayMoney()" />
                            </td>
                        </tr>
                    </table>
                </div>
            </div>
        </ContentTemplate>
        <Triggers>
            <asp:PostBackTrigger ControlID="btnExport" />
        </Triggers>
    </asp:UpdatePanel>
    </form>
</body>
</html>

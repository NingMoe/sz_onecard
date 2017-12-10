<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PS_PrepayDepositExam.aspx.cs"
    Inherits="ASP_PartnerShip_PS_PrepayDepositExam" EnableEventValidation="false" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>预付款保证金收支审核</title>

    <script type="text/javascript" src="../../js/myext.js"></script>

    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
    <div class="tb">
        合作伙伴->预付款保证金收支审核</div>
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
                <div class="jieguo">
                    预付款保证金待审核信息</div>
                <div class="kuang5">
                    <div id="gdtb" style="height: 150px">
                        <asp:GridView ID="lvwExamQuery" runat="server" Width="1600px" CssClass="tab1" HeaderStyle-CssClass="tabbt"
                            AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel" AllowPaging="True"
                            PageSize="20" PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left"
                            PagerStyle-VerticalAlign="Top" AutoGenerateColumns="False" OnPageIndexChanging="lvwExamQuery_Page"
                            OnSelectedIndexChanged="lvwExamQuery_SelectedIndexChanged" OnRowCreated="lvwExamQuery_RowCreated"
                            OnRowDataBound="lvwExamQuery_RowDataBound">
                            <Columns>
                                <asp:BoundField DataField="ID" HeaderText="审核流水号" />
                                <asp:BoundField DataField="TRADETYPECODE" HeaderText="业务类型编码" />
                                <asp:BoundField DataField="TRADETYPE" HeaderText="业务类型" />
                                <asp:BoundField DataField="DBALUNITNO" HeaderText="结算单元编码" />
                                <asp:BoundField DataField="DBALUNIT" HeaderText="结算单元名称" />
                                <asp:BoundField DataField="CURRENTMONEY" HeaderText="收支金额" />
                                <asp:BoundField DataField="CHINESEMONEY" HeaderText="金额大写" />
                                <asp:BoundField DataField="STAFFNAME" HeaderText="操作员工" />
                                <asp:BoundField DataField="OPERATETIME" HeaderText="操作时间" />
                                <asp:BoundField DataField="REMARK" HeaderText="备注" />
                                <asp:BoundField DataField="FINDATE" HeaderText="划款日期" />
                                <asp:BoundField DataField="FINTRADENO" HeaderText="划款单号" />
                                <asp:BoundField DataField="FINBANK" HeaderText="划款银行" />
                                <asp:BoundField DataField="USEWAY" HeaderText="用途" />
                            </Columns>
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                        <td>
                                            业务类型
                                        </td>
                                        <td>
                                            结算单元编码
                                        </td>
                                        <td>
                                            结算单元名称
                                        </td>
                                        <td>
                                            发生金额
                                        </td>
                                        <td>
                                            金额大写
                                        </td>
                                        <td>
                                            操作员工
                                        </td>
                                        <td>
                                            操作时间
                                        </td>
                                        <td>
                                            备注
                                        </td>
                                        <td>
                                            划款日期
                                        </td>
                                        <td>
                                            划款单号
                                        </td>
                                        <td>
                                            划款银行
                                        </td>
                                        <td>
                                            用途
                                        </td>
                                    </tr>
                                </table>
                            </EmptyDataTemplate>
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
                            <td align="right">
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
                            <td colspan="5">
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
                    <div class="linex">
                    </div>
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td style="width: 12%" align="right">
                                保证金余额:
                            </td>
                            <td style="width: 12%">
                                <asp:Label ID="labDeposit" runat="server" />元
                            </td>
                            <td style="width: 12%" align="right">
                                可领卡价值额度:
                            </td>
                            <td style="width: 12%">
                                <asp:Label ID="labUsablevalue" runat="server" />元
                            </td>
                            <td style="width: 12%" align="right">
                                网点剩余卡价值:
                            </td>
                            <td style="width: 12%" colspan="3">
                                <asp:Label ID="labStockvalue" runat="server" />元
                            </td>
                        </tr>
                        <tr>
                            <td style="width: 12%" align="right">
                            </td>
                            <td style="width: 12%">
                                <asp:Label ID="Label5" runat="server" />
                            </td>
                            <td style="width: 12%" align="right">
                            </td>
                            <td style="width: 12%">
                                <asp:Label ID="Label6" runat="server" />
                            </td>
                            <td style="width: 12%" align="right">
                            </td>
                            <td style="width: 12%">
                                <asp:Label ID="Label7" runat="server" />
                            </td>
                            <td style="width: 12%" align="right">
                            </td>
                            <td style="width: 12%">
                                <asp:Label ID="Label8" runat="server" />
                            </td>
                        </tr>
                    </table>
                </div>
            </div>
            <div class="footall">
            </div>
            <div class="btns">
                <table width="200" border="0" align="right" cellpadding="0" cellspacing="0">
                    <tr>
                        <td>
                            <asp:Button ID="btnPass" runat="server" Text="通过" CssClass="button1" Enabled="false"
                                OnClick="btnPass_Click" />
                        </td>
                        <td>
                            <asp:Button ID="btnCancel" runat="server" Text="作废" CssClass="button1" Enabled="false"
                                OnClick="btnCancel_Click" />
                        </td>
                    </tr>
                </table>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
    </form>
</body>
</html>

<%@ Page Language="C#" AutoEventWireup="true" CodeFile="SD_SpeAdjustAccInput.aspx.cs" Inherits="ASP_SpecialDeal_SD_SpeAdjustAccInput" EnableEventValidation="false" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>特殊调帐录入</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <script type="text/JavaScript" src="../../js/mootools.js"></script>

    <script type="text/javascript" src="../../js/myext.js"></script>
    <script type="text/JavaScript">
        function submitConfirm(state) {

            MyExtConfirm('确认',
           '该交易的特殊圈存状态为：<b>' + state +
            '</b><br>是否确认？'
            , submitConfirmCallback);
        }
        function submitConfirmCallback(btn) {
            if (btn == 'yes') {
                $get('btnConfirm').click();
            }
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <div class="tb">异常处理->特殊调帐录入</div>

        <ajaxToolkit:ToolkitScriptManager runat="Server" EnableScriptGlobalization="true"
            EnableScriptLocalization="true" ID="ScriptManager2" />
        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
            <ContentTemplate>

                <asp:BulletedList ID="bulMsgShow" runat="server" />
                <script runat="server">public override void ErrorMsgShow() { ErrorMsgHelper(bulMsgShow); }</script>

                <div class="con">
                    <div class="card">查询</div>
                    <div class="kuang5">
                        <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                            <tr>
                                <td>
                                    <div align="right">行业名称:</div>
                                </td>
                                <td>
                                    <asp:DropDownList ID="selCalling" CssClass="inputmidder" runat="server" AutoPostBack="true" OnSelectedIndexChanged="selCalling_SelectedIndexChanged">
                                    </asp:DropDownList>
                                </td>
                                <td>
                                    <div align="right">IC卡号:</div>
                                </td>
                                <td>
                                    <asp:TextBox ID="txtCardNo" runat="server" CssClass="input" MaxLength="16"></asp:TextBox>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <div align="right">单位名称:</div>
                                </td>
                                <td>
                                    <asp:DropDownList ID="selCorp" CssClass="inputmidder" runat="server" AutoPostBack="true" OnSelectedIndexChanged="selCorp_SelectedIndexChanged">
                                    </asp:DropDownList>
                                </td>
                                <td>
                                    <div align="right">交易日期:</div>
                                </td>
                                <td>
                                    <asp:TextBox ID="txtTradeDate" runat="server" CssClass="input" MaxLength="10"></asp:TextBox>
                                    <ajaxToolkit:CalendarExtender ID="CalendarExtender2"
                                        runat="server" TargetControlID="txtTradeDate" Format="yyyy-MM-dd" PopupPosition="BottomLeft" />
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <div align="right">部门名称:</div>
                                </td>
                                <td>
                                    <asp:DropDownList ID="selDepart" CssClass="inputmidder" runat="server">
                                    </asp:DropDownList>
                                </td>
                                <td>&nbsp;</td>
                                <td>
                                    <asp:Button ID="btnQuery" runat="server" Text="查询" CssClass="button1" OnClick="btnQuery_Click" /></td>
                            </tr>
                        </table>
                    </div>

                    <div class="jieguo">交易信息</div>
                    <div class="kuang5">
                        <div id="gdtb" style="height: 200px;">


                            <asp:GridView ID="lvwConsumeInfo" runat="server"
                                CssClass="tab1"
                                Width="100%"
                                HeaderStyle-CssClass="tabbt"
                                AlternatingRowStyle-CssClass="tabjg"
                                SelectedRowStyle-CssClass="tabsel"
                                AllowPaging="True"
                                PageSize="6"
                                PagerSettings-Mode="NumericFirstLast"
                                PagerStyle-HorizontalAlign="Left"
                                PagerStyle-VerticalAlign="Top"
                                AutoGenerateColumns="False"
                                OnPageIndexChanging="lvwConsumeInfo_Page"
                                OnRowDataBound="lvwConsumeInfo_RowDataBound"
                                OnSelectedIndexChanged="lvwConsumeInfo_SelectedIndexChanged"
                                OnRowCreated="lvwConsumeInfo_RowCreated">
                                <Columns>

                                    <asp:BoundField DataField="CARDNO" HeaderText="IC卡号" />
                                    <asp:BoundField DataField="CALLINGNAME" HeaderText="行业" />
                                    <asp:BoundField DataField="CORPNAME" HeaderText="单位" />
                                    <asp:BoundField DataField="DEPARTNAME" HeaderText="部门" />
                                    <asp:BoundField DataField="TRADEDATE" HeaderText="交易日期" />
                                    <asp:BoundField DataField="TRADETIME" HeaderText="交易时间" />
                                    <asp:BoundField DataField="PREMONEY" HeaderText="交易前卡内金额" />
                                    <asp:BoundField DataField="TRADEMONEY" HeaderText="交易金额" />
                                    <asp:BoundField DataField="CARDTRADENO" HeaderText="卡片交易序列号" />
                                    <asp:BoundField DataField="ID" HeaderText="ID" />
                                    <asp:BoundField DataField="NAME" HeaderText="佣金方案" />

                                </Columns>

                                <EmptyDataTemplate>
                                    <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                        <tr class="tabbt">
                                            <td>IC卡号</td>
                                            <td>行业</td>
                                            <td>单位</td>
                                            <td>部门</td>
                                            <td>交易日期</td>
                                            <td>交易时间</td>
                                            <td>交易前卡内金额</td>
                                            <td>交易金额</td>
                                            <td>卡片交易序列号</td>
                                            <td>佣金方案</td>
                                        </tr>
                                    </table>
                                </EmptyDataTemplate>
                            </asp:GridView>

                        </div>
                    </div>


                    <div class="card">调帐信息</div>
                    <div class="kuang5">
                        <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                            <tr>
                                <td width="9%">
                                    <div align="right">行业名称:</div>
                                </td>
                                <td>
                                    <asp:Label ID="labCalling" runat="server"></asp:Label>
                                </td>
                                <td width="10%">
                                    <div align="right">单位名称:</div>
                                </td>
                                <td>
                                    <asp:Label ID="labCorp" runat="server"></asp:Label>
                                </td>
                                <td>
                                    <div align="right">部门名称:</div>
                                </td>
                                <td>
                                    <table>
                                        <tr>
                                            <td width="100px">
                                                <asp:Label ID="labDepart" runat="server"></asp:Label>
                                            </td>
                                            <td>
                                                <div align="right">佣金比例:</div>
                                            </td>
                                            <td>
                                                <asp:Label ID="labComScheme" runat="server"></asp:Label>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <div align="right">IC卡号:</div>
                                </td>
                                <td>
                                    <%--<asp:Label ID="labCardNo" runat="server" ></asp:Label>--%>

                                    <asp:TextBox ID="txtCardNoExt" runat="server" CssClass="input" MaxLength="16"></asp:TextBox>

                                </td>
                                <td>
                                    <div align="right">交易日期:</div>
                                </td>
                                <td>
                                    <asp:Label ID="labTradeDate" runat="server"></asp:Label></td>
                                <td>
                                    <div align="right">交易金额:</div>
                                </td>
                                <td>
                                    <table>
                                        <tr>
                                            <td width="100px">
                                                <asp:Label ID="labTradeMoney" runat="server"></asp:Label>
                                                <asp:HiddenField ID="hidTradeMoneyExt" runat="server" />
                                            </td>
                                            <td>
                                                <div align="right">最大可调账金额:</div>
                                            </td>
                                            <td>
                                                <asp:Label ID="LabMaxAdjustMoney" runat="server"></asp:Label>
                                                <asp:HiddenField ID="hidMaxAdjustMoney" runat="server" />
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <div align="right">持卡人姓名:</div>
                                </td>
                                <td>
                                    <asp:TextBox ID="txtCardUser" runat="server" CssClass="input" MaxLength="50"></asp:TextBox></td>
                                <td>
                                    <div align="right">退款金额:</div>
                                </td>
                                <td>
                                    <asp:TextBox ID="txtRefundment" runat="server" CssClass="input" MaxLength="10"></asp:TextBox></td>

                                <td>
                                    <div align="right">调账原因:</div>
                                </td>
                                <td>
                                    <asp:DropDownList ID="selAdjReason" runat="server" CssClass="inputmid"></asp:DropDownList>
                                </td>


                            </tr>
                            <tr>
                                <td>
                                    <div align="right">持卡人电话:</div>
                                </td>
                                <td>
                                    <asp:TextBox ID="txtUserPhone" runat="server" CssClass="input" MaxLength="40"></asp:TextBox></td>
                                <td>
                                    <div align="right">应退佣金:</div>
                                </td>
                                <td>
                                    <asp:TextBox ID="txtReBrokerage" runat="server" CssClass="input" MaxLength="10"></asp:TextBox></td>
                                <td>
                                    <div align="right">交易说明:</div>
                                </td>
                                <td colspan="3">
                                    <asp:TextBox ID="txtRemark" runat="server" CssClass="inputlong" MaxLength="100"></asp:TextBox></td>
                            </tr>
                        </table>
                    </div>
                </div>
                <div class="btns">
                    <table width="100" border="0" align="right" cellpadding="0" cellspacing="0">
                        <tr>
                            <td>
                                <asp:LinkButton runat="server" ID="btnConfirm" OnClick="btnConfirm_Click" />
                                <asp:Button ID="btnInput" runat="server" Text="录入" CssClass="button1" OnClick="btnInput_Click" /></td>
                        </tr>
                    </table>
                </div>


            </ContentTemplate>
        </asp:UpdatePanel>


    </form>
</body>
</html>

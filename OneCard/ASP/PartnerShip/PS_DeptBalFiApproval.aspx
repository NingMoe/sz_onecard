<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PS_DeptBalFiApproval.aspx.cs" 
Inherits="ASP_PartnerShip_PS_DeptBalFiApproval" EnableEventValidation="false" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>网点结算单元财务审核</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
    <div class="tb">
        合作伙伴->网点结算单元财务审核</div>
    <ajaxToolkit:ToolkitScriptManager runat="Server" EnableScriptGlobalization="true"
        EnableScriptLocalization="true" ID="ScriptManager2" />
    <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
            <asp:BulletedList ID="bulMsgShow" runat="server" />

            <script runat="server">public override void ErrorMsgShow() { ErrorMsgHelper(bulMsgShow); }</script>

            <div class="con">
                <div class="jieguo">
                    待审核网点结算单元信息</div>
                <div class="kuang5">
                    <div class="gdtb" style="height: 170px">
                        <asp:GridView ID="lvwBalUnitsAppral" runat="server" CssClass="tab1" Width="2400"
                            HeaderStyle-CssClass="tabbt" AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel"
                            AllowPaging="True" PageSize="100" PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="Left"
                            PagerStyle-VerticalAlign="Top" AutoGenerateColumns="False" OnPageIndexChanging="lvwBalUnitsAppral_Page"
                            OnSelectedIndexChanged="lvwBalUnitsAppral_SelectedIndexChanged" OnRowCreated="lvwBalUnitsAppral_RowCreated"
                            OnRowDataBound="lvwBalUnitsAppral_RowDataBound">
                            <Columns>
                                <asp:BoundField DataField="DTRADETYPECODE" HeaderText="业务类型编码" />
                                <asp:BoundField DataField="TRADEID" HeaderText="业务流水号" />
                                <asp:BoundField DataField="REMARK" HeaderText="备注" />
                                <asp:BoundField DataField="BANKCODE" HeaderText="开户银行编码" />
                                <asp:BoundField DataField="FINBANKCODE" HeaderText="转出银行编码" />
                                <asp:BoundField DataField="DEPTTYPECODE" HeaderText="网点类型编码" />
                                <asp:BoundField DataField="BALCYCLETYPECODE" HeaderText="结算周期类型编码" />
                                <asp:BoundField DataField="FINCYCLETYPECODE" HeaderText="转账周期类型编码" />
                                <asp:BoundField DataField="FINTYPECODE" HeaderText="转账类型编码" />

                                <asp:BoundField DataField="BIZTYPE" HeaderText="操作类型" />
                                <asp:BoundField DataField="DBALUNITNO" HeaderText="结算单元编码" />
                                <asp:BoundField DataField="DBALUNIT" HeaderText="结算单元名称" />
                                <asp:BoundField DataField="DEPTTYPE" HeaderText="网点类型" />
                                <asp:BoundField DataField="CREATETIME" HeaderText="合作时间" DataFormatString="{0:yyyy-MM-dd}"
                                    HtmlEncode="False"/>
                                <asp:BoundField DataField="OPENBANK" HeaderText="开户银行" />
                                <asp:BoundField DataField="BANKACCNO" HeaderText="银行帐号" />
                                <asp:BoundField DataField="BALCYCLETYPE" HeaderText="结算周期类型" />
                                <asp:BoundField DataField="BALINTERVAL" HeaderText="结算周期跨度" />
                                <asp:BoundField DataField="FINCYCLETYPE" HeaderText="划账周期类型" />
                                <asp:BoundField DataField="FININTERVAL" HeaderText="划账周期跨度" />
                                <asp:BoundField DataField="FINTYPE" HeaderText="转账类型" />
                                <asp:BoundField DataField="PREPAYWARNLINE" HeaderText="预警额度" />
                                <asp:BoundField DataField="PREPAYLIMITLINE" HeaderText="最低额度" />
                                <asp:BoundField DataField="FINBANK" HeaderText="转出银行" />
                                <asp:BoundField DataField="LINKMAN" HeaderText="联系人" />
                                <asp:BoundField DataField="UNITPHONE" HeaderText="联系电话" />
                                <asp:BoundField DataField="UNITADD" HeaderText="联系地址" />
                                <asp:BoundField DataField="UNITEMAIL" HeaderText="电子邮件" />
                                <asp:BoundField DataField="OPERTSTUFFNO" HeaderText="操作员工" />
                                <asp:BoundField DataField="CHECKTIME" HeaderText="操作时间" />
                            </Columns>
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                        <td>
                                            操作类型
                                        </td>
                                        <td>
                                            结算单元编码
                                        </td>
                                        <td>
                                            结算单元名称
                                        </td>
                                        <td>
                                            网点类型
                                        </td>
                                        <td>
                                            合作时间
                                        </td>
                                        <td>
                                            开户银行
                                        </td>
                                        <td>
                                            银行帐号
                                        </td>
                                        <td>
                                            结算周期类型
                                        </td>
                                        <td>
                                            结算周期跨度
                                        </td>
                                        <td>
                                            划账周期类型
                                        </td>
                                        <td>
                                            划账周期跨度
                                        </td>
                                        <td>
                                            转账类型
                                        </td>
                                         <td>
                                            预警额度
                                        </td>
                                        <td>
                                            最低额度
                                        </td>
                                        <td>
                                            转出银行
                                        </td>
                                        <td>
                                            联系人
                                        </td>
                                        <td>
                                            联系电话
                                        </td>
                                        <td>
                                            联系地址
                                        </td>
                                        <td>
                                            电子邮件
                                        </td>
                                        <td>
                                            操作员工
                                        </td>
                                        <td>
                                            操作时间
                                        </td>
                                    </tr>
                                </table>
                            </EmptyDataTemplate>
                        </asp:GridView>
                    </div>
                </div>
            </div>
            <div class="basicinfoz3">
                <div class="base">
                    网点结算单元信息</div>
                <div class="kuang5">
                    <table width="100%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <asp:HiddenField runat="server" ID="hidTradeID" />
                            <asp:HiddenField runat="server" ID="hidTradeTypeCode" />
                            <asp:HiddenField runat="server" ID="hidBankCode" />
                            <asp:HiddenField runat="server" ID="hidFinBankCode" />
                            <asp:HiddenField runat="server" ID="hidDeptTypeCode" />
                            <asp:HiddenField runat="server" ID="hidBalCycleTypeCode" />
                            <asp:HiddenField runat="server" ID="hidFinCycleTypeCode" />
                            <asp:HiddenField runat="server" ID="hidFinTypeCode" />
                            <td align="right" style="width: 13%">
                                单元编码:
                            </td>
                            <td style="width: 19%">
                                <asp:Label ID="labBalUnitNO" runat="server" />
                            </td>
                            <td align="right" style="width: 15%">
                                单元名称:
                            </td>
                            <td style="width: 19%">
                                <asp:Label ID="labBalUnit" runat="server" />
                            </td>
                            <td align="right" style="width: 15%">
                                网点类型:
                            </td>
                            <td style="width: 19%">
                                <asp:Label ID="labBalType" runat="server" CssClass="labeltext" />
                            </td>
                        </tr>
                        <tr>
                            <td align="right">
                                合作时间:
                            </td>
                            <td>
                                <asp:Label ID="labCreateTime" runat="server" />
                            </td>
                            <td align="right">
                                操作员工:
                            </td>
                            <td>
                                <asp:Label ID="labOpeStuff" runat="server" />
                            </td>
                            <td align="right">
                                开户银行:
                            </td>
                            <td>
                                <asp:Label ID="labBank" runat="server" />
                            </td>
                        </tr>
                        <tr>
                            <td align="right">
                                银行帐号:
                            </td>
                            <td>
                                <asp:Label ID="labBankAccNo" runat="server" />
                            </td>
                            <td align="right">
                                转出银行:
                            </td>
                            <td>
                                <asp:Label ID="labFinBank" runat="server" />
                            </td>
                            <td align="right">
                            </td>
                            <td>
                            </td>
                        </tr>
                    </table>
                    <div class="linex">
                    </div>
                    <table width="98%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td align="right" style="width: 13%">
                                转账类型:
                            </td>
                            <td style="width: 19%">
                                <asp:Label ID="labFinType" runat="server" />
                            </td>
                            <td align="right" style="width: 15%">
                                结算周期类型:
                            </td>
                            <td style="width: 19%">
                                <asp:Label ID="labBalCyclType" runat="server" />
                            </td>
                            <td align="right" style="width: 15%">
                                结算周期跨度:
                            </td>
                            <td style="width: 19%">
                                <asp:Label ID="labBalInterval" runat="server" />
                            </td>
                        </tr>
                        <tr>
                            <td align="right">
                                划账周期类型:
                            </td>
                            <td>
                                <asp:Label ID="labFinCyclType" runat="server" />
                            </td>
                            <td align="right">
                                划账周期跨度:
                            </td>
                            <td>
                                <asp:Label ID="labFinCyclInterval" runat="server" />
                            </td>
                            <td align="right">
                                预警额度:
                            </td>
                            <td>
                                <asp:Label ID="labPrepayWarnLine" runat="server" />
                            </td>
                        </tr>
                        <tr>
                            <td align="right">
                                最低额度:
                            </td>
                            <td>
                                <asp:Label ID="labPrepayLimitLine" runat="server" />
                            </td>
                            <td align="right">
                                备注:
                            </td>
                            <td colspan="3">
                                <asp:Label ID="labReMark" runat="server" />
                            </td>
                        </tr>
                    </table>
                    <div class="linex">
                    </div>
                    <table width="98%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td align="right" style="width: 13%">
                                联系人:
                            </td>
                            <td style="width: 19%">
                                <asp:Label ID="labLinkMan" runat="server" />
                            </td>
                            <td align="right" style="width: 15%">
                                联系地址:
                            </td>
                            <td style="width: 53%" colspan="3">
                                <asp:Label ID="labAddress" runat="server" />
                            </td>
                        </tr>
                        <tr>
                            <td align="right">
                                联系电话:
                            </td>
                            <td>
                                <asp:Label ID="labPhone" runat="server" />
                            </td>
                            <td align="right">
                                电子邮件:
                            </td>
                            <td colspan="3">
                                <asp:Label ID="labEmail" runat="server" />
                            </td>
                        </tr>
                    </table>
                </div>
            </div>
            <div class="pipinfoz3">
                <div class="info">
                   <asp:Label ID="labBal" runat="server" Text="佣金方案[当前处理]"></asp:Label>
                    </div>
                <div class="kuang5" style="height: 70px;">
                    <div class="gdtb2" style="height: 100%;">
                        <asp:GridView ID="lvwBalComScheme" runat="server" Width="400" CssClass="tab1" HeaderStyle-CssClass="tabbt"
                            AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel" AllowPaging="True"
                            PageSize="10" PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left"
                            PagerStyle-VerticalAlign="Top" AutoGenerateColumns="False">
                            <Columns>
                                <asp:BoundField DataField="NAME" HeaderText="方案名称" />
                                <asp:BoundField DataField="TRADETYPE" HeaderText="业务类型" />
                                <asp:BoundField DataField="RETRADETYPE" HeaderText="返销类型" />
                                <asp:BoundField DataField="BEGINTIME" HeaderText="起始月" DataFormatString="{0:yyyy-MM}"
                                    HtmlEncode="False" />
                                <asp:BoundField DataField="ENDTIME" HeaderText="终止月" DataFormatString="{0:yyyy-MM}"
                                    HtmlEncode="False" />
                                <asp:BoundField DataField="REMARK" HeaderText="方案描述" />
                            </Columns>
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                        <td>
                                            方案名称
                                        </td>
                                        <td>
                                            业务类型
                                        </td>
                                        <td>
                                            返销类型
                                        </td>
                                        <td>
                                            起始月
                                        </td>
                                        <td>
                                            终止月
                                        </td>
                                        <td>
                                            方案描述
                                        </td>
                                    </tr>
                                </table>
                            </EmptyDataTemplate>
                        </asp:GridView>
                        <asp:GridView Visible="false" ID="lvwBalRelationScheme" runat="server" Width="300" CssClass="tab1" HeaderStyle-CssClass="tabbt"
                            AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel" AllowPaging="True"
                            PageSize="10" PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left"
                            PagerStyle-VerticalAlign="Top" AutoGenerateColumns="False">
                            <Columns>
                                <asp:BoundField DataField="DBALUNIT" HeaderText="结算单元" />
                                <asp:BoundField DataField="DEPARTNAME" HeaderText="网点" />
                                <asp:BoundField DataField="DEPTTYPE" HeaderText="网点类型" />
                            </Columns>
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                        <td>
                                            结算单元
                                        </td>
                                        <td>
                                            网点
                                        </td>
                                        <td>
                                            网点类型
                                        </td>
                                    </tr>
                                </table>
                            </EmptyDataTemplate>
                        </asp:GridView>
                    </div>
                </div>
            </div>
            <div class="pipinfoz3">
                <div class="info">
                    <asp:Label ID="labBalExist" runat="server" Text="佣金方案[已有方案]"></asp:Label></div>
                <div class="kuang5" style="height: 90px;">
                    <div class="gdtb2" style="height: 100%;">
                        <asp:GridView ID="lvwExistedComScheme" runat="server" Width="400" CssClass="tab1"
                            HeaderStyle-CssClass="tabbt" AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel"
                            AllowPaging="True" PageSize="5" PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left"
                             OnPageIndexChanging="lvwExistedComScheme_Page" 
                            PagerStyle-VerticalAlign="Top" AutoGenerateColumns="False">
                            <Columns>
                                <asp:BoundField DataField="NAME" HeaderText="方案名称" />
                                <asp:BoundField DataField="TRADETYPE" HeaderText="业务类型" />
                                <asp:BoundField DataField="RETRADETYPE" HeaderText="返销类型" />
                                <asp:BoundField DataField="BEGINTIME" HeaderText="起始月" DataFormatString="{0:yyyy-MM}"
                                    HtmlEncode="False" />
                                <asp:BoundField DataField="ENDTIME" HeaderText="终止月" DataFormatString="{0:yyyy-MM}"
                                    HtmlEncode="False" />
                                <asp:BoundField DataField="REMARK" HeaderText="方案描述" />
                            </Columns>
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                        <td>
                                            方案名称
                                        </td>
                                        <td>
                                            业务类型
                                        </td>
                                        <td>
                                            返销类型
                                        </td>
                                        <td>
                                            起始月
                                        </td>
                                        <td>
                                            终止月
                                        </td>
                                        <td>
                                            方案描述
                                        </td>
                                    </tr>
                                </table>
                            </EmptyDataTemplate>
                        </asp:GridView>
                        <asp:GridView Visible="false" ID="lvwExistedRelationScheme" runat="server" Width="300" CssClass="tab1"
                            HeaderStyle-CssClass="tabbt" AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel"
                            AllowPaging="True" PageSize="5" PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left"
                            OnPageIndexChanging="lvwExistedRelationScheme_Page" 
                            PagerStyle-VerticalAlign="Top" AutoGenerateColumns="False">
                            <Columns>
                                <asp:BoundField DataField="DBALUNIT" HeaderText="结算单元" />
                                <asp:BoundField DataField="DEPARTNAME" HeaderText="网点" />
                                <asp:BoundField DataField="DEPTTYPE" HeaderText="网点类型" />
                            </Columns>
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                        <td>
                                            结算单元
                                        </td>
                                        <td>
                                            网点
                                        </td>
                                        <td>
                                            网点类型
                                        </td>
                                    </tr>
                                </table>
                            </EmptyDataTemplate>
                        </asp:GridView>
                    </div>
                </div>
            </div>
            <div class="footall">
            </div>
            <div class="btns">
                <table width="200" border="0" align="right" cellpadding="0" cellspacing="0">
                    <tr>
                        <td>
                            <asp:Button ID="btnPass" runat="server" Text="通过" Enabled="false" CssClass="button1" OnClick="btnPass_Click" />
                        </td>
                        <td>
                            <asp:Button ID="btnCancel" runat="server" Text="作废" Enabled="false" CssClass="button1" OnClick="btnCancel_Click" />
                        </td>
                    </tr>
                </table>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
    </form>
</body>
</html>

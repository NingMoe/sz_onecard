<%@ Page Language="C#" AutoEventWireup="true" CodeFile="TS_ReadCardRecord.aspx.cs"
    Inherits="ASP_TaxiService_TS_ReadCardRecord" %>

<%@ Register Src="../../CardReader.ascx" TagName="CardReader" TagPrefix="cr" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>卡内交易记录</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <cr:CardReader ID="cardReader" runat="server" />
    <form id="form1" runat="server">
    <div class="tb">
        司机卡->读取卡内交易记录</div>
    <ajaxToolkit:ToolkitScriptManager runat="Server" EnableScriptGlobalization="true"
        EnableScriptLocalization="true" ID="ScriptManager2" />
    <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
            <asp:BulletedList ID="bulMsgShow" runat="server" />
            <script runat="server">public override void ErrorMsgShow() { ErrorMsgHelper(bulMsgShow); }</script>
            <div class="con">
                <div class="base">
                    卡信息查询</div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="12text">
                        <tr>
                            <td width="9%">
                                <div align="right">
                                    卡号:</div>
                            </td>
                            <td width="12%">
                                <asp:TextBox ID="txtCardno" CssClass="labeltext" MaxLength="16" runat="server"></asp:TextBox>
                            </td>
                            <td width="12%">
                                <div align="right">
                                    数据类型:</div>
                            </td>
                            <td width="11%">
                                <asp:DropDownList ID="selTradeTypes" CssClass="inputmid" runat="server" 
                                AutoPostBack="true"
                                OnSelectedIndexChanged="selTradeTypes_Changed">
                                </asp:DropDownList>
                            </td>
                            <td width="9%">
                                <div align="right">
                                    &nbsp;</div>
                            </td>
                            <td width="10%">
                                &nbsp;
                            </td>
                            <td width="9%">
                                <div align="right">
                                    &nbsp;</div>
                            </td>
                            <td width="12%">
                                &nbsp;
                            </td>
                            <td width="16%">
                                <asp:Button ID="btnReadCard" CssClass="button1" runat="server" Text="读卡" OnClientClick="return readDriverRecord('hidDriverRecord')"
                                    OnClick="btnReadCard_Click" />
                                <asp:Button ID="btnReadCardYL" CssClass="button1" runat="server" Text="读卡" OnClientClick="return readDriverRecordYL('hidDriverRecordYL')" Visible="false"
                                    OnClick="btnReadCardYL_Click" />
                                  <asp:Button ID="btnReadCardSMK" CssClass="button1" runat="server" Text="读卡" OnClientClick="return readDriverRecordSMK('hidDriverRecordSMK')" Visible="false"
                                    OnClick="btnReadCardSMK_Click" />
                                       <asp:Button ID="btnReadCardJT" CssClass="button1" runat="server" Text="读卡" OnClientClick="return readDriverRecordJT('hidDriverRecordJT')" Visible="false"
                                    OnClick="btnReadCardJT_Click" />
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <asp:HiddenField ID="hidDriverRecord" runat="server" />
                                <asp:HiddenField ID="hidDriverRecordYL" runat="server" />
                                <asp:HiddenField ID="hidDriverRecordSMK" runat="server" />
                                <asp:HiddenField ID="hidDriverRecordJT" runat="server" />
                            </td>
                            <td>
                            </td>
                            <td>
                                &nbsp;
                            </td>
                            <td>
                                &nbsp;
                            </td>
                            <td>
                                &nbsp;
                            </td>
                            <td>
                                &nbsp;
                            </td>
                            <td>
                                &nbsp;
                            </td>
                            <td>
                                &nbsp;
                            </td>
                            <td>
                                &nbsp;
                            </td>
                        </tr>
                    </table>
                </div>
                <div class="jieguo">
                    交易记录信息</div>
                <div class="kuang5">
                    <div class="gdtb1" style="height: 380px;">
                        <asp:GridView ID="lvwQuery" runat="server" Width="98%" CssClass="tab1" HeaderStyle-CssClass="tabbt"
                            AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel" AllowPaging="false"
                            PageSize="10" PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left"
                            PagerStyle-VerticalAlign="Top" AutoGenerateColumns="False">
                            <Columns>
                                <asp:BoundField DataField="TRADEMONEY" HeaderText="交易金额" />
                                <asp:BoundField DataField="PSAMNO" HeaderText="终端机编号" />
                                <asp:BoundField DataField="CARDTRADENO" HeaderText="终端交易序号" />
                                <asp:BoundField DataField="TRADEDATE" HeaderText="交易日期" />
                                <asp:BoundField DataField="TRADETIME" HeaderText="交易时间" />
                                <asp:BoundField DataField="TAC" HeaderText="TAC码" />
                                <asp:BoundField DataField="OUTLINECARDTRADENO" HeaderText="卡片脱机交易序号" />
                                <asp:BoundField DataField="ASN" HeaderText="用户卡应用序列号" />
                                <asp:BoundField DataField="PREMONEY" HeaderText="交易前金额" />
                            </Columns>
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                        <td>
                                            交易金额
                                        </td>
                                        <td>
                                            终端机编号
                                        </td>
                                        <td>
                                            终端交易序号
                                        </td>
                                        <td>
                                            交易日期
                                        </td>
                                        <td>
                                            交易时间
                                        </td>
                                        <td>
                                            TAC码
                                        </td>
                                        <td>
                                            卡片脱机交易序号
                                        </td>
                                        <td>
                                            用户卡应用序列号
                                        </td>
                                        <td>
                                            交易前金额
                                        </td>
                                    </tr>
                                </table>
                            </EmptyDataTemplate>
                        </asp:GridView>
                        <asp:GridView ID="lvwQueryYL" runat="server" Width="250%" CssClass="tab1" HeaderStyle-CssClass="tabbt"
                            AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel" AllowPaging="false"
                            PageSize="10" PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left"
                            PagerStyle-VerticalAlign="Top" AutoGenerateColumns="False">
                            <Columns>
                            <asp:BoundField DataField="TRADETYPE" HeaderText="交易类型" />
                                        <asp:BoundField DataField="TRADEID" HeaderText="交易流水号" />
                                        <asp:BoundField DataField="TRADEDATE" HeaderText="交易日期" />
                                        <asp:BoundField DataField="TRADETIME" HeaderText="交易时间" />
                                        <asp:BoundField DataField="MAINACCOUNT" HeaderText="主账号" />
                                        <asp:BoundField DataField="TRADEMONEY" HeaderText="交易金额" />
                                        <asp:BoundField DataField="VAILDTIME" HeaderText="卡有效期" />
                                        <asp:BoundField DataField="ASN" HeaderText="卡片序列号" />
                                        <asp:BoundField DataField="APPCIPHER" HeaderText="应用密文" />
                                        <asp:BoundField DataField="APPLICATIONDATA" HeaderText="发卡行应用数据" />
                                        <asp:BoundField DataField="UNPREDICTABLE" HeaderText="不可预知数据" />
                                        <asp:BoundField DataField="APPCOUNT" HeaderText="应用交易计数器" />
                                        <asp:BoundField DataField="VERRESULTS" HeaderText="终端验证结果" />
                                        <asp:BoundField DataField="FILENAME" HeaderText="专用文件名称" />
                                        <asp:BoundField DataField="AUTHORIZATIONCODE" HeaderText="发卡行授权码" />
                            </Columns>
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                         <td>
                                            交易类型
                                        </td>
                                        <td>
                                            交易流水号
                                        </td>
                                        <td>
                                            交易日期
                                        </td>
                                         <td>
                                            交易时间
                                        </td>
                                        <td>
                                            主账号
                                        </td>
                                        <td>
                                            交易金额
                                        </td>
                                        <td>
                                            卡有效期
                                        </td>
                                        <td>
                                            卡片序列号
                                        </td>
                                        <td>
                                            应用密文
                                        </td>
                                        <td>
                                            发卡行应用数据
                                        </td>
                                        <td>
                                            不可预知数据
                                        </td>
                                        <td>
                                            应用交易计数器
                                        </td>

                                         <td>
                                            终端验证结果
                                        </td>
                                        <td>
                                            专用文件名称
                                        </td>
                                        <td>
                                            发卡行授权码
                                        </td>
                                    </tr>
                                </table>
                            </EmptyDataTemplate>
                        </asp:GridView>
                        <asp:GridView ID="lvwQuerySMK" runat="server" Width="98%" CssClass="tab1" HeaderStyle-CssClass="tabbt"
                            AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel" AllowPaging="false"
                            PageSize="10" PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left"
                            PagerStyle-VerticalAlign="Top" AutoGenerateColumns="False">
                            <Columns>
                                <asp:BoundField DataField="TRADEMONEY" HeaderText="交易金额" />
                                <asp:BoundField DataField="PSAMNO" HeaderText="终端机编号" />
                                <asp:BoundField DataField="CARDTRADENO" HeaderText="终端交易序号" />
                                <asp:BoundField DataField="TRADEDATE" HeaderText="交易日期" />
                                <asp:BoundField DataField="TRADETIME" HeaderText="交易时间" />
                                <asp:BoundField DataField="TAC" HeaderText="TAC码" />
                                <asp:BoundField DataField="OUTLINECARDTRADENO" HeaderText="卡片脱机交易序号" />
                                <asp:BoundField DataField="ASN" HeaderText="用户卡应用序列号" />
                                <asp:BoundField DataField="PREMONEY" HeaderText="交易前金额" />
                            </Columns>
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                            <tr class="tabbt">
                                        <td>
                                            交易金额
                                        </td>
                                        <td>
                                            终端机编号
                                        </td>
                                        <td>
                                            终端交易序号
                                        </td>
                                        <td>
                                            交易日期
                                        </td>
                                        <td>
                                            交易时间
                                        </td>
                                        <td>
                                            TAC码
                                        </td>
                                        <td>
                                            卡片脱机交易序号
                                        </td>
                                        <td>
                                            用户卡应用序列号
                                        </td>
                                        <td>
                                            交易前金额
                                        </td>
                                    </tr>
                                </table>
                            </EmptyDataTemplate>
                        </asp:GridView>
                        <asp:GridView ID="lvwQueryJT" runat="server" Width="148%" CssClass="tab1" HeaderStyle-CssClass="tabbt"
                            AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel" AllowPaging="false"
                            PageSize="10" PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left"
                            PagerStyle-VerticalAlign="Top" AutoGenerateColumns="False">
                            <Columns>
                                <asp:BoundField DataField="TRADEMONEY" HeaderText="交易金额" />
                                <asp:BoundField DataField="PSAMNO" HeaderText="终端机编号" />
                                <asp:BoundField DataField="CARDTRADENO" HeaderText="终端交易序号" />
                                <asp:BoundField DataField="TRADEDATE" HeaderText="交易日期" />
                                <asp:BoundField DataField="TRADETIME" HeaderText="交易时间" />
                                <asp:BoundField DataField="TAC" HeaderText="TAC码" />
                                <asp:BoundField DataField="OUTLINECARDTRADENO" HeaderText="卡片脱机交易序号" />
                                <asp:BoundField DataField="ASN" HeaderText="用户卡应用序列号" />
                                <asp:BoundField DataField="PREMONEY" HeaderText="交易前金额" />
                                <asp:BoundField DataField="ISSUERCODE" HeaderText="发卡结构代码" />
                                <asp:BoundField DataField="KEYVERSION" HeaderText="消费秘钥版本" />
                                <asp:BoundField DataField="KEYINDEX" HeaderText="消费秘钥索引" />
                                <asp:BoundField DataField="PSAM" HeaderText="PSAM版本" />
                                <asp:BoundField DataField="RESERVE" HeaderText="预留" />
                            </Columns>
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                        <td>
                                            交易金额
                                        </td>
                                        <td>
                                            终端机编号
                                        </td>
                                        <td>
                                            终端交易序号
                                        </td>
                                        <td>
                                            交易日期
                                        </td>
                                        <td>
                                            交易时间
                                        </td>
                                        <td>
                                            TAC码
                                        </td>
                                        <td>
                                            卡片脱机交易序号
                                        </td>
                                        <td>
                                            用户卡应用序列号
                                        </td>
                                        <td>
                                            交易前金额
                                        </td>
                                        <td>
                                            发卡结构代码
                                        </td>
                                         <td>
                                            消费秘钥版本
                                        </td>
                                        <td>
                                            消费秘钥索引
                                        </td>
                                        <td>
                                            PSAM版本
                                        </td>
                                        <td>
                                            预留
                                        </td>
                                    </tr>
                                </table>
                            </EmptyDataTemplate>
                        </asp:GridView>
                    </div>
                </div>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
    <div class="btns">
        <table width="100" border="0" align="right" cellpadding="0" cellspacing="0">
            <tr>
                <td width="102">
                    <asp:Button ID="btnSave" CssClass="button1" runat="server" Text="导出" OnClick="btnSave_Click" />
                </td>
            </tr>
        </table>
    </div>
    </form>
</body>
</html>

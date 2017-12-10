<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PB_RefundInputApproval.aspx.cs"
    Inherits="ASP_PersonalBusiness_PB_RefundInputApproval" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>退款记录审核</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />

    <script type="text/javascript" src="../../js/myext.js"></script>

    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
    <div class="tb">
        个人业务->退款记录审核
    </div>
    <ajaxToolkit:ToolkitScriptManager EnableScriptGlobalization="true" EnableScriptLocalization="true"
        ID="ScriptManager1" runat="server" />

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

    <asp:UpdatePanel ID="UpdatePanel1" UpdateMode="Conditional" runat="server">
        <ContentTemplate>
            <asp:BulletedList ID="bulMsgShow" runat="server" />

            <script runat="server">public override void ErrorMsgShow() { ErrorMsgHelper(bulMsgShow); }</script>

            <div class="con">
                <div class="base">
                    退款记录查询</div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td>
                                <div align="right">
                                    查询状态:</div>
                            </td>
                            <td>
                                <asp:DropDownList ID="selQueryType" AutoPostBack="true" runat="server">
                                </asp:DropDownList>
                            </td>
                            <td>
                                <div align="right">
                                    &nbsp;</div>
                            </td>
                            <td>
                            </td>
                            <td>
                                <div align="right">
                                    &nbsp;</div>
                            </td>
                            <td>
                            </td>
                            <td>
                                <div align="center">
                                    <asp:Button ID="btnQuery" CssClass="button1" runat="server" Text="查询" OnClick="btnQuery_Click" /></div>
                            </td>
                        </tr>
                    </table>
                </div>
                <div class="jieguo">
                    退款记录审核</div>
                <div class="kuang5">
                    <div class="gdtb" style="height: 310px">
                        <asp:GridView ID="gvResult" runat="server" Width="98%" CssClass="tab1" HeaderStyle-CssClass="tabbt"
                            AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel" AllowPaging="false"
                            PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top"
                            OnRowDataBound="gvResult_RowDataBound" AutoGenerateColumns="False">
                            <Columns>
                                <asp:TemplateField>
                                    <HeaderTemplate>
                                        <asp:CheckBox ID="CheckBox1" runat="server" AutoPostBack="true" OnCheckedChanged="CheckAll" />
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                        <asp:CheckBox ID="ItemCheckBox" runat="server" />
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField>
                                    <ItemTemplate>
                                        <asp:HiddenField ID="hiddenTradeID" runat="server" Value='<%#Eval("tradeid") %>' />
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField HeaderText="状态" DataField="TradeType" />
                                <asp:BoundField HeaderText="卡号" DataField="CardNo" />
                                <asp:BoundField HeaderText="充值日期" DataField="TradeDate" />
                                <asp:BoundField HeaderText="充值金额" DataField="backmoney" />
                                <asp:BoundField HeaderText="返还比例" DataField="backslope"  DataFormatString="{0:P}"/>
                                <asp:BoundField HeaderText="退款账户的开户行" DataField="bank" />
                                <asp:BoundField HeaderText="退款账户的银行账户" DataField="bankaccno" />
                                <asp:BoundField HeaderText="退款账户的开户名" DataField="custname" />
                                <asp:BoundField HeaderText="收款人账户类型" DataField="purPoseType" />
                                <asp:BoundField HeaderText="备注" DataField="remark" />
                                <asp:BoundField HeaderText="充值ID" DataField="ID" />
                            </Columns>
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                        <td>
                                            <input type="checkbox" />
                                        </td>
                                        <td>
                                            状态
                                        </td>
                                        <td>
                                            卡号
                                        </td>
                                        <td>
                                            充值日期
                                        </td>
                                        <td>
                                            充值金额
                                        </td>
                                        <td>
                                            退款比例
                                        </td>
                                        <td>
                                            退款账户的开户行
                                        </td>
                                        <td>
                                            退款账户的银行账户
                                        </td>
                                        <td>
                                            退款账户的开户名
                                        </td>
                                        <td>
                                            收款人账户类型
                                        </td>
                                        <td>
                                            备注
                                        </td>
                                        <td>
                                            充值ID
                                        </td>
                                    </tr>
                                </table>
                            </EmptyDataTemplate>
                        </asp:GridView>
                    </div>
                </div>
            </div>
            <div class="btns">
                <table width="95%" border="0" cellpadding="0" cellspacing="0">
                    <tr>
                        <td width="70%">
                            &nbsp;
                        </td>
                        <td align="right">
                            <asp:CheckBox ID="chkApprove" AutoPostBack="true" Text="通过" runat="server" OnCheckedChanged="chkApprove_CheckedChanged" />
                        </td>
                        <td align="right">
                            <asp:CheckBox ID="chkReject" AutoPostBack="true" Text="作废" runat="server" OnCheckedChanged="chkReject_CheckedChanged" />
                        </td>
                        <td align="right">
                            <asp:Button ID="btnSubmit" Enabled="false" CssClass="button1" runat="server" Text="提交"
                                OnClick="btnSubmit_Click" />
                        </td>
                    </tr>
                </table>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
    </form>
</body>
</html>

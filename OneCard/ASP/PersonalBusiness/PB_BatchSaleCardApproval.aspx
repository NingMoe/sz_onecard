<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PB_BatchSaleCardApproval.aspx.cs"
    Inherits="ASP_PersonalBusiness_PB_BatchSaleCardApproval" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>批量售卡财审</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />

    <script type="text/javascript" src="../../js/myext.js"></script>

    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
    <div class="tb">
        个人业务->批量售卡财审
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

    <asp:UpdatePanel ID="UpdatePanel1" UpdateMode="Conditional" runat="server">
        <ContentTemplate>
            <asp:BulletedList ID="bulMsgShow" runat="server">
            </asp:BulletedList>

            <script runat="server">public override void ErrorMsgShow() { ErrorMsgHelper(bulMsgShow); }</script>

            <div class="con">
                <div class="jieguo">
                    批量售卡财审</div>
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
                                <asp:BoundField HeaderText="业务流水号" DataField="tradeid" />
                                <asp:BoundField HeaderText="开始卡号" DataField="begincardno" />
                                <asp:BoundField HeaderText="终止卡号" DataField="endcardno" />
                                <asp:BoundField HeaderText="卡押金" DataField="carddeposit" />
                                <asp:BoundField HeaderText="卡费" DataField="cardcost" />
                                <asp:BoundField HeaderText="售卡时间" DataField="selltime" />
                                <asp:BoundField HeaderText="售卡总张数" DataField="selltimes" />
                                <asp:BoundField HeaderText="售卡总金额" DataField="sellmoney" />
                                <asp:BoundField HeaderText="操作员工姓名" DataField="staffname" />
                                <asp:BoundField HeaderText="操作部门" DataField="departname" />
                                <asp:BoundField HeaderText="操作时间" DataField="OPERATETIME" />
                                <asp:BoundField HeaderText="备注" DataField="remark" />
                                <asp:BoundField HeaderText="操作员工编号" DataField="OPERATESTAFFNO" />
                                <asp:BoundField HeaderText="操作部门编号" DataField="OPERATEDEPARTID" />
                            </Columns>
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                        <td>
                                            <input type="checkbox" />
                                        </td>
                                        <td>
                                            业务流水号
                                        </td>
                                        <td>
                                            开始卡号
                                        </td>
                                        <td>
                                            终止卡号
                                        </td>
                                        <td>
                                            卡押金
                                        </td>
                                        <td>
                                            卡费
                                        </td>
                                        <td>
                                            售卡时间
                                        </td>
                                        <td>
                                            售卡总张数
                                        </td>
                                        <td>
                                            售卡总金额
                                        </td>
                                        <td>
                                            操作员工姓名
                                        </td>
                                        <td>
                                            操作部门
                                        </td>
                                        <td>
                                            操作时间
                                        </td>
                                        <td>
                                            备注
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

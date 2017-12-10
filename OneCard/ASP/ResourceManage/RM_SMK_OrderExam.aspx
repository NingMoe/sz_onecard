<%@ Page Language="C#" AutoEventWireup="true" CodeFile="RM_SMK_OrderExam.aspx.cs" Inherits="ASP_ResourceManage_RM_SMK_OrderExam"
    EnableEventValidation="false" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>下单审核</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="../../js/myext.js"></script>
    <script type="text/javascript" src="../../js/RMHelper.js"></script>
    <script type="text/javascript" language="javascript">
    </script>
</head>
<body>
    <form id="form1" runat="server">
    <div class="tb">
        卡片管理->下单审核
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
            <asp:HiddenField ID="hidCardType" runat="server" />
            <div class="con">
                <div class="card">
                    查询</div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td width="12%">
                                <div align="right">
                                    订购单号:</div>
                            </td>
                            <td width="36%" colspan="3">
                                <asp:TextBox ID="txtOrderID" CssClass="inputmid" MaxLength="18" runat="server">
                                </asp:TextBox>
                            </td>
                            <td width="12%">
                                <div align="right">
                                    审核状态:</div>
                            </td>
                            <td width="12%">
                                <asp:DropDownList ID="selExamState" CssClass="input" runat="server">
                                    <asp:ListItem Text="0: 待审核" Value="0"></asp:ListItem>
                                    <asp:ListItem Text="1: 审核通过" Value="1"></asp:ListItem>
                                    <asp:ListItem Text="2: 审核作废" Value="2"></asp:ListItem>
                                </asp:DropDownList>
                            </td>
                            <td width="12%" align="right">
                                <asp:Button ID="btnQuery" CssClass="button1" runat="server" Text="查询" OnClick="btnQuery_Click" />
                            </td>
                            <td width="12%">
                            </td>
                        </tr>
                    </table>
                </div>
                <div class="jieguo">
                    待审核订购单</div>
                <div class="kuang5">
                    <div id="gvUseCard" style="height: 300px; overflow: auto; display: block">
                        <asp:GridView ID="gvResult" runat="server" Width="250%" CssClass="tab1" HeaderStyle-CssClass="tabbt"
                            FooterStyle-CssClass="tabcon" AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel"
                            PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top"
                            AutoGenerateColumns="false" OnRowDataBound="gvResult_RowDataBound" PageSize="50" AllowPaging="true"
                            OnPageIndexChanging="gvResult_Page" OnRowCreated="gvResult_RowCreated">
                            <Columns>
                                <asp:BoundField DataField="CARDORDERID" HeaderText="订购单号" />
                                <asp:BoundField DataField="CARDORDERTYPE" HeaderText="订购类型" />
                                <asp:BoundField DataField="CARDORDERSTATE" HeaderText="订购单状态" />
                                <asp:BoundField DataField="FILENAME" HeaderText="制卡文件名" />
                                <asp:BoundField DataField="MANUNAME" HeaderText="卡片厂商" />
                                <asp:BoundField DataField="BATCHNO" HeaderText="批次号" />
                                <asp:BoundField DataField="CARDNUM" HeaderText="订购数量" />
                                <asp:BoundField DataField="BATCHDATE" HeaderText="批次日期" />
                                <asp:BoundField DataField="BEGINCARDNO" HeaderText="起始卡号" />
                                <asp:BoundField DataField="ENDCARDNO" HeaderText="结束卡号" />
                                <asp:BoundField DataField="ORDERTIME" HeaderText="下单时间" />
                                <asp:BoundField DataField="ORDERSTAFF" HeaderText="下单员工" />
                                <asp:BoundField DataField="EXAMTIME" HeaderText="审核时间" />
                                <asp:BoundField DataField="EXAMSTAFF" HeaderText=" 审核员工" />
                                <asp:BoundField DataField="REMARK" HeaderText="备注" />
                            </Columns>
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                        <td>
                                            订购单号
                                        </td>
                                        <td>
                                            需求单号
                                        </td>
                                        <td>
                                            审核状态
                                        </td>
                                        <td>
                                            订购类型
                                        </td>
                                        <td>
                                            卡片类型
                                        </td>
                                        <td>
                                            卡面类型
                                        </td>
                                        <td>
                                            卡样编码
                                        </td>
                                        <td>
                                            订购数量
                                        </td>
                                        <td>
                                            要求到货日期
                                        </td>
                                        <td>
                                            起始卡号
                                        </td>
                                        <td>
                                            结束卡号
                                        </td>
                                        <td>
                                            芯片类型
                                        </td>
                                        <td>
                                            COS类型
                                        </td>
                                        <td>
                                            卡片厂商
                                        </td>
                                        <td>
                                            应用版本
                                        </td>
                                        <td>
                                            起始有效日期
                                        </td>
                                        <td>
                                            结束有效日期
                                        </td>
                                        <td>
                                            下单时间
                                        </td>
                                        <td>
                                            下单员工
                                        </td>
                                        <td>
                                            审核时间
                                        </td>
                                        <td>
                                            审核员工
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

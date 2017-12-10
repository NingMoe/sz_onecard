<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PB_TransitLimit.aspx.cs"
    Inherits="ASP_PersonalBusiness_PB_TransitLimit" EnableEventValidation="false" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>换卡转值限制</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <script type="text/javascript" src="../../js/print.js"></script>
    <script type="text/javascript" src="../../js/myext.js"></script>
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
    <div class="tb">
        个人业务->换卡转值限制
    </div>
    <ajaxToolkit:ToolkitScriptManager runat="Server" EnableScriptGlobalization="true"
        EnableScriptLocalization="true" ID="ToolkitScriptManager1" />
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
    <asp:UpdatePanel ID="UpdatePanel2" runat="server">
        <ContentTemplate>
            <!-- #include file="../../ErrorMsg.inc" -->
            <div class="con">
                <div class="card">
                    查询</div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td width="12%">
                                <div align="right">
                                    卡号:</div>
                            </td>
                            <td width="12%">
                                <asp:TextBox ID="txtCardno" CssClass="input" runat="server" MaxLength="16"></asp:TextBox>
                            </td>
                            <td width="12%">
                                <div align="right">
                                    状态:</div>
                            </td>
                            <td width="12%">
                                <asp:DropDownList ID="selState" CssClass="input" runat="server">
                                    <asp:ListItem Text="0: 添加" Value="0"></asp:ListItem>
                                    <asp:ListItem Text="1: 删除" Value="1"></asp:ListItem>
                                </asp:DropDownList>
                            </td>
                            <td width="12%">
                            </td>
                            <td width="12%">
                            </td>
                            <td width="12%" align="right">
                                <asp:Button ID="btnQuery" CssClass="button1" runat="server" Text="查询" OnClick="btnQuery_Click" />
                            </td>
                            <td width="12%">
                            </td>
                        </tr>
                    </table>
                </div>
                <table border="0" width="95%">
                    <tr>
                        <td align="left">
                            <div class="jieguo">
                                查询结果</div>
                        </td>
                    </tr>
                </table>
                <div class="kuang5">
                    <asp:HiddenField ID="hidTradeId" runat="server" />
                    <div id="gdtbfix" style="height: 250px">
                        <asp:GridView ID="gvResult" runat="server" Width="95%" CssClass="tab1" HeaderStyle-CssClass="tabbt"
                            FooterStyle-CssClass="tabcon" AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel"
                            PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top"
                            PageSize="20" AutoGenerateColumns="false" OnRowDataBound="gvResult_RowDataBound"
                            OnPageIndexChanging="gvResult_Page" OnSelectedIndexChanged="gvResult_SelectedIndexChanged"
                            OnRowCreated="gvResult_RowCreated" ShowFooter="false">
                            <Columns>
                                <asp:BoundField DataField="TRADEID" HeaderText="业务流水号" />
                                <asp:BoundField DataField="CARDNO" HeaderText="卡号" />
                                <asp:BoundField DataField="STATE" HeaderText="状态" />
                                <asp:BoundField DataField="ADDTIME" HeaderText="添加时间" />
                                <asp:BoundField DataField="ADDSTAFFNO" HeaderText="添加员工" />
                                <asp:BoundField DataField="DELETETIME" HeaderText="删除时间" />
                                <asp:BoundField DataField="DELETESTAFFNO" HeaderText="删除员工" />
                                <asp:BoundField DataField="REMARK" HeaderText="备注" />
                            </Columns>
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                        <td>
                                            卡号
                                        </td>
                                        <td>
                                            状态
                                        </td>
                                        <td>
                                            添加时间
                                        </td>
                                        <td>
                                            添加员工
                                        </td>
                                        <td>
                                            删除时间
                                        </td>
                                        <td>
                                            删除员工
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
                <div class="card">
                    换卡转值限制控制</div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td width="12%">
                                <div align="right">
                                    卡号:</div>
                            </td>
                            <td width="12%">
                                <asp:TextBox ID="txtOpCardno" CssClass="input" runat="server" MaxLength="16"></asp:TextBox>
                            </td>
                            <td width="12%">
                                <div align="right">
                                    备注:</div>
                            </td>
                            <td width="36%" colspan="3">
                                <asp:TextBox ID="txtRemark" CssClass="inputmidder" runat="server" MaxLength="16"></asp:TextBox>
                            </td>
                            <td width="12%">
                            </td>
                            <td width="12%">
                            </td>
                        </tr>
                    </table>
                </div>
            </div>
            <div class="btns">
                <table width="95%" border="0" cellpadding="0" cellspacing="0">
                    <tr>
                        <td width="12%">
                        </td>
                        <td width="12%">
                        </td>
                        <td width="12%">
                        </td>
                        <td width="12%">
                        </td>
                        <td width="12%">
                        </td>
                        <td width="12%">
                        </td>
                        <td width="12%" align="right">
                            <asp:Button ID="btnAdd" Enabled="true" CssClass="button1" runat="server" Text="添加"
                                OnClick="btnAdd_Click" />
                        </td>
                        <td width="12%">
                            &nbsp;&nbsp;
                            <asp:Button ID="btnCancel" Enabled="false" CssClass="button1" runat="server" Text="删除"
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

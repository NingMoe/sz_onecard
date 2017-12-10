<%@ Page Language="C#" AutoEventWireup="true" CodeFile="AS_GardenCardBlackList.aspx.cs"
    Inherits="ASP_AddtionalService_AS_GardenCardBlackList" EnableEventValidation="false" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>园林年卡-黑名单维护</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
    <div class="tb">
        附加业务->园林年卡-黑名单维护
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
    <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
            <asp:BulletedList ID="bulMsgShow" runat="server">
            </asp:BulletedList>
            <script runat="server">public override void ErrorMsgShow() { ErrorMsgHelper(bulMsgShow); }</script>
            <asp:HiddenField ID="hidPaperNo" runat="server" />
            <div class="con">
                <div class="card">
                    查询</div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td width="15%">
                                <div align="right">
                                    身份证号:</div>
                            </td>
                            <td width="15%">
                                <asp:TextBox ID="txtPaperNo" CssClass="inputmid" runat="server" MaxLength="18" />
                            </td>
                            <td width="40%">
                            </td>
                            <td width="15%">
                            </td>
                            <td width="15%">
                                <asp:Button ID="Button1" CssClass="button1" runat="server" Text="查询" OnClick="btnQuery_Click" />
                            </td>
                        </tr>
                    </table>
                </div>
                <div class="jieguo">
                    园林黑名单</div>
                <div class="kuang5">
                    <div class="gdtb" style="height: 300px">
                        <asp:GridView ID="gvResult" runat="server" Width="98%" CssClass="tab1" HeaderStyle-CssClass="tabbt"
                            AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel" AllowPaging="True"
                            PageSize="10" PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left"
                            PagerStyle-VerticalAlign="Top" AutoGenerateColumns="False" OnPageIndexChanging="gvResult_Page"
                            OnSelectedIndexChanged="gvResult_SelectedIndexChanged" OnRowCreated="gvResult_RowCreated">
                            <Columns>
                                <asp:BoundField HeaderText="姓名" DataField="CUSTNAME" />
                                <asp:BoundField HeaderText="身份证号" DataField="PAPERNO" />
                            </Columns>
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                        <td>
                                            姓名
                                        </td>
                                        <td>
                                            身份证号
                                        </td>
                                    </tr>
                                </table>
                            </EmptyDataTemplate>
                        </asp:GridView>
                    </div>
                </div>
                <div class="card">
                    添加删除黑名单</div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td width="15%">
                                <div align="right">
                                    身份证号:</div>
                            </td>
                            <td width="15%">
                                <asp:TextBox ID="txtAddPaperno" CssClass="inputmid" runat="server" MaxLength="18" />
                            </td>
                            <td width="40%">
                            </td>
                            <td width="15%" align="right">
                                <asp:Button ID="btnAddBlack" runat="server" Text="加入黑名单" CssClass="button1" Enabled="true"
                                    OnClick="btnAddBlack_Click" />
                            </td>
                            <td width="15%">&nbsp;&nbsp;
                                <asp:Button ID="btnCancelBlack" runat="server" Text="取消黑名单" CssClass="button1" Enabled="false"
                                    OnClick="btnCancelBlack_Click" />
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
                    </tr>
                </table>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
    </form>
</body>
</html>

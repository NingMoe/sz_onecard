<%@ Page Language="C#" AutoEventWireup="true" CodeFile="AS_ReStartOrStopSync.aspx.cs"
    Inherits="ASP_AddtionalService_AS_ReStartOrStopSync" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>园林/休闲/图书馆数据</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <script type="text/javascript" src="../../js/print.js"></script>
    <script type="text/javascript" src="../../js/myext.js"></script>
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="../../js/jquery-1.5.min.js"></script>
    <script type="text/javascript">
        function SelectAll(tempControl, temp) {

            var theBox = tempControl;
            xState = theBox.checked;
            var inputs = document.getElementById(temp).getElementsByTagName("input");
            for (i = 0; i < inputs.length; i++) {
                if (inputs[i].type == "checkbox") {
                    if (inputs[i].checked != xState)
                        inputs[i].checked = xState;
                }
            }
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
    <div class="tb">
        附加业务->园林/休闲/图书馆数据
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
                            <td>
                                <div align="right">
                                    同步类型:</div>
                            </td>
                            <td>
                                <asp:DropDownList ID="selSyncTypes" CssClass="inputmid" runat="server" OnSelectedIndexChanged="selSyncTypes_Changed"
                                    AutoPostBack="true">
                                </asp:DropDownList>
                            </td>
                            <td colspan="4" align="right">
                                <asp:Button ID="btnQuery" CssClass="button1" runat="server" Text="查询" OnClick="btnQuery_Click" />
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
                        <td align="right">
                        </td>
                    </tr>
                </table>
                <div id="printarea" class="kuang5">
                    <div style="height: 380px; overflow: auto;">
                        <asp:GridView ID="gvLibrary" runat="server" Width="150%" CssClass="tab1" HeaderStyle-CssClass="tabbt"
                            AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel" PagerSettings-Mode="NumericFirstLast"
                            PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top" AutoGenerateColumns="False"
                            OnPageIndexChanging="gvLibrary_PageIndexChanging" PageSize="10" AllowPaging="True" OnRowDataBound="gvLibrary_RowDataBound">
                            <Columns>
                                <asp:TemplateField>
                                    <HeaderTemplate>
                                        <asp:CheckBox ID="CheckBox1" runat="server" onclick="SelectAll(this,'gvLibrary');" />
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                        <asp:CheckBox ID="ItemCheckBox" runat="server" />
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField HeaderText="卡号" DataField="CARDNO" />
                                <asp:BoundField DataField="TRADEID" HeaderText="TRADEID" />
                                <asp:BoundField HeaderText="失败原因" DataField="SYNERRINFO" />
                                <asp:BoundField HeaderText="同步时间" DataField="LASTSYNCTIME" />
                                <asp:BoundField HeaderText="同步类型" DataField="SYNCTYPECODE" />
                                <asp:BoundField HeaderText="同步状态" DataField="SYNCCODE" />
                                <asp:BoundField HeaderText="同步业务类型" DataField="TRADETYPECODE" />
                                <asp:BoundField HeaderText="业务处理结果" DataField="PROCEDURESYNCCODE" />
                                <asp:BoundField HeaderText="同步发起方" DataField="SYNCHOME" />
                                <asp:BoundField HeaderText="同步接收方" DataField="SYNCCLIENT" />
                                <asp:BoundField HeaderText="社保号" DataField="SOCLSECNO" />
                                <asp:BoundField HeaderText="姓名" DataField="NAME" />
                                <asp:BoundField HeaderText="证件类型" DataField="PAPERTYPECODE" />
                                <asp:BoundField HeaderText="证件号码" DataField="PAPERNO" />
                                <asp:BoundField HeaderText="出生日期" DataField="BIRTH" />
                                <asp:BoundField HeaderText="性别" DataField="SEX" />
                                <asp:BoundField HeaderText="电话" DataField="PHONE" />
                                <asp:BoundField HeaderText="邮政编码" DataField="CUSTPOST" />
                                <asp:BoundField HeaderText="联系地址" DataField="ADDR" />
                                <asp:BoundField HeaderText="邮箱" DataField="EMAIL" />
                                
                            </Columns>
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                        <td>
                                            <input type="checkbox" />
                                        </td>
                                        <td width="5%">
                                            卡号
                                        </td>
                                        <td width="5%">
                                            失败原因
                                        </td>
                                        <td width="5%">
                                            同步时间
                                        </td>
                                        <td width="5%">
                                            同步类型
                                        </td>
                                        <td width="5%">
                                            同步状态
                                        </td>
                                        <td width="5%">
                                            同步业务类型
                                        </td>
                                        <td width="5%">
                                            业务处理结果
                                        </td>
                                        <td width="8%">
                                            同步发起方
                                        </td>
                                        <td width="5%">
                                            同步接收方
                                        </td>
                                        <td width="8%">
                                            社保号
                                        </td>
                                        <td width="5%">
                                            姓名
                                        </td>
                                        <td width="5%">
                                            证件类型
                                        </td>
                                        <td width="5%">
                                            证件号码
                                        </td>
                                        <td width="5%">
                                            出生日期
                                        </td>
                                        <td width="5%">
                                            性别
                                        </td>
                                        <td width="5%">
                                            电话
                                        </td>
                                        <td width="5%">
                                            邮政编码
                                        </td>
                                        <td width="5%">
                                            联系地址
                                        </td>
                                        <td width="5%">
                                            邮箱
                                        </td>
                                    </tr>
                                </table>
                            </EmptyDataTemplate>
                        </asp:GridView>
                        <asp:GridView ID="gvGarden" runat="server" Width="150%" CssClass="tab1" HeaderStyle-CssClass="tabbt"
                            AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel" PagerSettings-Mode="NumericFirstLast"
                            PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top" AutoGenerateColumns="False"
                            OnPageIndexChanging="gvGarden_PageIndexChanging"  PageSize="10" AllowPaging="True" OnRowDataBound="gvGarden_RowDataBound">
                            <Columns>
                                <asp:TemplateField>
                                    <HeaderTemplate>
                                        <asp:CheckBox ID="CheckBox1" runat="server" onclick="SelectAll(this,'gvGarden');" />
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                        <asp:CheckBox ID="ItemCheckBox" runat="server" />
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField HeaderText="卡号" DataField="CARDNO" />
                                <asp:BoundField DataField="TRADEID" HeaderText="TRADEID" />
                                <asp:BoundField HeaderText="卡操作时间" DataField="CARDTIME" />
                                <asp:BoundField HeaderText="类型" DataField="TRADETYPE" />
                                <asp:BoundField HeaderText="处理状态" DataField="DEALTYPE" />
                                <asp:BoundField HeaderText="姓名" DataField="CUSTNAME" />
                                <asp:BoundField HeaderText="证件类型" DataField="PAPERTYPE" />
                                <asp:BoundField HeaderText="证件号码" DataField="PAPERNO" />
                                <asp:BoundField HeaderText="有效期" DataField="ENDDATE" />
                                <asp:BoundField HeaderText="剩余次数" DataField="TIMES" />
                                
                            </Columns>
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                        <td width="5%">
                                            <input type="checkbox" />
                                        </td>
                                        <td width="5%">
                                            卡号
                                        </td>
                                        <td width="5%">
                                            卡操作时间
                                        </td>
                                        <td width="5%">
                                            类型
                                        </td>
                                        <td width="5%">
                                            处理状态
                                        </td>
                                        <td width="5%">
                                            姓名
                                        </td>
                                        <td width="5%">
                                            证件类型
                                        </td>
                                        <td width="5%">
                                            证件号码
                                        </td>
                                        <td width="5%">
                                            有效期
                                        </td>
                                        <td width="5%">
                                            剩余次数
                                        </td>
                                    </tr>
                                </table>
                            </EmptyDataTemplate>
                        </asp:GridView>
                        <asp:GridView ID="gvRelax" runat="server" Width="150%" CssClass="tab1" HeaderStyle-CssClass="tabbt"
                            AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel" PagerSettings-Mode="NumericFirstLast"
                            PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top" AutoGenerateColumns="False"
                            OnPageIndexChanging="gvRelax_PageIndexChanging" PageSize="10" AllowPaging="True" OnRowDataBound="gvRelax_RowDataBound">
                            <Columns>
                                <asp:TemplateField>
                                    <HeaderTemplate>
                                        <asp:CheckBox ID="CheckBox1" runat="server" onclick="SelectAll(this,'gvRelax');" />
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                        <asp:CheckBox ID="ItemCheckBox" runat="server" />
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField HeaderText="卡号" DataField="CARDNO" />
                                <asp:BoundField DataField="TRADEID" HeaderText="TRADEID" />
                                <asp:BoundField HeaderText="卡操作时间" DataField="CARDTIME" />
                                <asp:BoundField HeaderText="类型" DataField="TRADETYPE" />
                                <asp:BoundField HeaderText="处理状态" DataField="DEALTYPE" />
                                <asp:BoundField HeaderText="姓名" DataField="CUSTNAME" />
                                <asp:BoundField HeaderText="证件类型" DataField="PAPERTYPE" />
                                <asp:BoundField HeaderText="证件号码" DataField="PAPERNO" />
                                <asp:BoundField HeaderText="有效期" DataField="ENDDATE" />
                                <asp:BoundField HeaderText="剩余次数" DataField="TIMES" />
                                
                            </Columns>
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                        <td width="5%">
                                            <input type="checkbox" />
                                        </td>
                                        <td width="5%">
                                            卡号
                                        </td>
                                        <td width="5%">
                                            卡操作时间
                                        </td>
                                        <td width="5%">
                                            类型
                                        </td>
                                        <td width="5%">
                                            处理状态
                                        </td>
                                        <td width="5%">
                                            姓名
                                        </td>
                                        <td width="5%">
                                            证件类型
                                        </td>
                                        <td width="5%">
                                            证件号码
                                        </td>
                                        <td width="5%">
                                            有效期
                                        </td>
                                        <td width="5%">
                                            剩余次数
                                        </td>
                                    </tr>
                                </table>
                            </EmptyDataTemplate>
                        </asp:GridView>
                    </div>
                </div>
                <div class="btns">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0">
                        <tr>
                            <td align="right">
                                <asp:Button ID="btnReStart"  CssClass="button1" runat="server" Text="重新同步"
                                    OnClick="btnReStart_Click" />
                                <asp:Button ID="btnStop"  CssClass="button1" runat="server" Text="停止同步"
                                    OnClick="btnStop_Click" />
                            </td>
                        </tr>
                    </table>
                </div>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
    </form>
</body>
</html>

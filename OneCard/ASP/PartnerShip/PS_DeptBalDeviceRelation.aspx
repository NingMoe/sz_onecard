<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PS_DeptBalDeviceRelation.aspx.cs"
    Inherits="ASP_PartnerShip_PS_DeptBalDeviceRelation" EnableEventValidation="false" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>代理商户结算设备关系</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />

    <script type="text/javascript" src="../../js/myext.js"></script>

</head>
<body>
    <form id="form1" runat="server">
    <div class="tb">
        合作伙伴->代理商户结算设备关系</div>
    <ajaxToolkit:ToolkitScriptManager runat="Server" EnableScriptGlobalization="true"
        AsyncPostBackTimeout="600" EnableScriptLocalization="true" ID="ScriptManager2" />

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
            <asp:BulletedList ID="bulMsgShow" runat="server" />

            <script runat="server">public override void ErrorMsgShow() { ErrorMsgHelper(bulMsgShow); }</script>

            <div class="con">
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="12text">
                        <tr>
                            <td>
                                <div align="right">
                                    结算单元:</div>
                            </td>
                            <td>
                                <asp:TextBox ID="txtBalUnitName" CssClass="inputmid" runat="server" AutoPostBack="true"
                                    OnTextChanged="txtBalUnitName_Changed"></asp:TextBox>
                                <asp:DropDownList ID="ddlBalUnit" CssClass="inputmidder" runat="server" />
                            </td>
                            <td>
                                <div align="right">
                                    设备序列号:</div>
                            </td>
                            <td>
                                <asp:TextBox ID="txtBegDeviceNo" CssClass="inputmid" runat="server" MaxLength="16"></asp:TextBox>
                                -
                                <asp:TextBox ID="txtEndDeviceNo" CssClass="inputmid" runat="server" MaxLength="16"></asp:TextBox>
                            </td>
                            <td width="9%">
                                <asp:Button ID="btnQuery" runat="server" Text="查询" CssClass="button1" OnClick="btnQuery_Click" />
                            </td>
                    </table>
                </div>
                <div class="jieguo">
                    代理商户结算设备关系信息
                </div>
                <div class="kuang5">
                    <div class="gdtb" style="height: 320px">
                        <asp:GridView ID="lvwRelation" runat="server" CssClass="tab1" Width="98%" HeaderStyle-CssClass="tabbt"
                            AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel" PagerSettings-Mode="NumericFirstLast"
                            PagerStyle-HorizontalAlign="Left" PagerStyle-VerticalAlign="Top" AutoGenerateColumns="False"
                            AllowPaging="true" PageSize="20" OnPageIndexChanging="lvwRelation_Page" EmptyDataText="没有数据记录!">
                            <PagerSettings Mode="NumericFirstLast" />
                            <Columns>
                                <asp:TemplateField>
                                    <HeaderTemplate>
                                        <asp:CheckBox ID="chkCheckAll" runat="server" AutoPostBack="true" OnCheckedChanged="CheckAll" />
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                        <asp:CheckBox ID="ItemCheckBox" runat="server" />
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField DataField="NUM" HeaderText="#" />
                                <asp:BoundField DataField="DBALUNITNO" HeaderText="结算单元编码" />
                                <asp:BoundField DataField="DBALUNIT" HeaderText="结算单元名称" />
                                <asp:BoundField DataField="READERNO" HeaderText="设备序列号" />
                            </Columns>
                            <PagerStyle HorizontalAlign="Left" VerticalAlign="Top" />
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                        <td>
                                            #
                                        </td>
                                        <td>
                                            结算单元编码
                                        </td>
                                        <td>
                                            结算单元名称
                                        </td>
                                        <td>
                                            设备序列号
                                        </td>
                                    </tr>
                                </table>
                            </EmptyDataTemplate>
                            <SelectedRowStyle CssClass="tabsel" />
                            <HeaderStyle CssClass="tabbt" />
                            <AlternatingRowStyle CssClass="tabjg" />
                        </asp:GridView>
                        <asp:GridView ID="gvResult" runat="server" Width="98%" CssClass="tab1" HeaderStyle-CssClass="tabbt"
                            AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel" AllowPaging="false"
                            PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top"
                            AutoGenerateColumns="true" EmptyDataText="没有数据记录!">
                        </asp:GridView>
                    </div>
                </div>
                <div class="card">
                    添加删除代理商户结算设备关系</div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td>
                                <div align="right">
                                    结算单元:</div>
                            </td>
                            <td>
                                <asp:DropDownList ID="ddlBalUnitInp" CssClass="inputmidder" runat="server">
                                </asp:DropDownList>
                            </td>
                            <td>
                                <div align="right">
                                    导入文件:</div>
                            </td>
                            <td>
                                <asp:FileUpload ID="FileUpload1" runat="server" CssClass="inputmid" />
                                <asp:Button ID="btnUpload" CssClass="button1" runat="server" Text="导入" OnClick="btnUpload_Click" />
                            </td>
                            <td align="right">
                                <asp:Button ID="btnSubmit" Enabled="false" CssClass="button1" runat="server" Text="提交"
                                    OnClick="btnSubmit_Click" />
                            </td>
                            <td width="15%" align="right">
                                <asp:Button ID="btnDel" Enabled="false" CssClass="button1" runat="server" Text="删除"
                                    OnClick="btnDel_Click" />
                            </td>
                        </tr>
                    </table>
                </div>
            </div>
        </ContentTemplate>
        <Triggers>
            <asp:PostBackTrigger ControlID="btnUpload" />
        </Triggers>
    </asp:UpdatePanel>
    </form>
</body>
</html>

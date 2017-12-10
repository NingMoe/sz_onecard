<%@ Page Language="C#" AutoEventWireup="true" CodeFile="RM_ResourceCondition.aspx.cs"
    Inherits="ASP_ResourceManage_ResourceCondition" EnableEventValidation="false" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>资源定义</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />

    <script type="text/javascript" src="../../js/print.js"></script>

    <script type="text/javascript" src="../../js/myext.js"></script>

    <script type="text/javascript" src="../../js/RMHelper.js"></script>

    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
    <div class="tb">
        资源管理->资源定义
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
                            <td width="24%">
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="text25">
                                    <tr>
                                        <td>
                                            <td width="50%">
                                                <div align="right">
                                                    资源类型:</div>
                                            </td>
                                            <td width="50%">
                                                <asp:DropDownList ID="selResourceType" CssClass="inputmid" runat="server">
                                                </asp:DropDownList>
                                            </td>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                            <td width="12%">
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
                    <div id="gvUseCard" style="height: 250px; display: block">
                        <asp:GridView ID="gvResult" runat="server" Width="95%" CssClass="tab1" HeaderStyle-CssClass="tabbt"
                            FooterStyle-CssClass="tabcon" AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel"
                            PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top"
                            AutoGenerateColumns="true" OnRowDataBound="gvResult_RowDataBound" OnSelectedIndexChanged="gvResult_SelectedIndexChanged"
                            OnRowCreated="gvResult_RowCreated">
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                        <td>
                                            资源类型
                                        </td>
                                        <td>
                                            资源编码
                                        </td>
                                        <td>
                                            资源名称
                                        </td>
                                        <td>
                                            属性名称
                                        </td>
                                        <td>
                                            描述
                                        </td>
                                    </tr>
                                </table>
                            </EmptyDataTemplate>
                        </asp:GridView>
                    </div>
                </div>
                <div class="card">
                    资源信息</div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td width="12%">
                                <div align="right">
                                    资源类型:</div>
                            </td>
                            <td width="36%">
                                <asp:DropDownList ID="InResourceType" CssClass="inputmid" runat="server">
                                </asp:DropDownList>
                            </td>
                            <td width="12%">
                                <div align="right">
                                    资源编码：</div>
                            </td>
                            <td width="36%">
                                <asp:TextBox ID="txtResourceCode" CssClass="input" runat="server" MaxLength="6"></asp:TextBox><span
                                    class="red">*</span>
                            </td>
                        </tr>
                        <tr>
                            <td width="12%">
                                <div align="right">
                                    资源名称:</div>
                            </td>
                            <td width="36%">
                                <asp:TextBox ID="txtResourceName" CssClass="input" runat="server"></asp:TextBox><span
                                    class="red">*</span>
                            </td>
                            <td width="12%">
                                <div align="right">
                                    </div>
                            </td>
                            <td width="36%">
                            </td>
                        </tr>
                        <tr>
                            <td width="12%">
                                <div align="right">
                                    属性名称1:</div>
                            </td>
                            <td width="36%">
                                <asp:TextBox ID="txtAttribute1" CssClass="input" runat="server"></asp:TextBox>
                                <asp:CheckBox ID="cbType1" runat="server" Text="领用属性:" TextAlign="Left"/>
                                <asp:CheckBox ID="cbIsNull1" runat="server" Text="是否必填:" TextAlign="Left"/>
                            </td>
                            <td width="12%">
                                <div align="right">
                                    属性名称2:</div>
                            </td>
                            <td width="36%">
                                <asp:TextBox ID="txtAttribute2" CssClass="input" runat="server"></asp:TextBox>
                                <asp:CheckBox ID="cbType2" runat="server" Text="领用属性:" TextAlign="Left"/>
                                <asp:CheckBox ID="cbIsNull2" runat="server" Text="是否必填:" TextAlign="Left"/>
                            </td>
                        </tr>
                                                <tr>
                            <td width="12%">
                                <div align="right">
                                    属性名称3:</div>
                            </td>
                            <td width="36%">
                                <asp:TextBox ID="txtAttribute3" CssClass="input" runat="server"></asp:TextBox>
                                <asp:CheckBox ID="cbType3" runat="server" Text="领用属性:" TextAlign="Left"/>
                                <asp:CheckBox ID="cbIsNull3" runat="server" Text="是否必填:" TextAlign="Left"/>
                            </td>
                            <td width="12%">
                                <div align="right">
                                    属性名称4:</div>
                            </td>
                            <td width="36%">
                                <asp:TextBox ID="txtAttribute4" CssClass="input" runat="server"></asp:TextBox>
                                <asp:CheckBox ID="cbType4" runat="server" Text="领用属性:" TextAlign="Left"/>
                                <asp:CheckBox ID="cbIsNull4" runat="server" Text="是否必填:" TextAlign="Left"/>
                            </td>
                        </tr>
                                                <tr>
                            <td width="12%">
                                <div align="right">
                                    属性名称5:</div>
                            </td>
                            <td width="36%">
                                <asp:TextBox ID="txtAttribute5" CssClass="input" runat="server"></asp:TextBox>
                                <asp:CheckBox ID="cbType5" runat="server" Text="领用属性:" TextAlign="Left"/>
                                <asp:CheckBox ID="cbIsNull5" runat="server" Text="是否必填:" TextAlign="Left"/>
                            </td>
                            <td width="12%">
                                <div align="right">
                                    属性名称6:</div>
                            </td>
                            <td width="36%">
                                <asp:TextBox ID="txtAttribute6" CssClass="input" runat="server"></asp:TextBox>
                                <asp:CheckBox ID="cbType6" runat="server" Text="领用属性:" TextAlign="Left"/>
                                <asp:CheckBox ID="cbIsNull6" runat="server" Text="是否必填:" TextAlign="Left"/>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    资源描述:</div>
                            </td>
                            <td width="36%">
                                <asp:TextBox runat="server" TextMode="MultiLine" ID="txtRemark" CssClass="inputlong"
                                    Width="313px" Height="60px" MaxLength="500" />
                            </td>
                            <td width="12%"></td>
                            <td width="36%"></td>
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
                        <td width="36%" align="right">
                            <asp:Button ID="btnAdd" Enabled="true" CssClass="button1" runat="server" Text="添加"
                                OnClick="btnAdd_Click" />
                            &nbsp;&nbsp;
                            <asp:Button ID="btnModify" Enabled="true" CssClass="button1" runat="server" Text="修改"
                                OnClick="btnModify_Click" />
                            &nbsp;&nbsp;
                            <asp:Button ID="btnCancel" Enabled="true" CssClass="button1" runat="server" Text="删除"
                                OnClick="btnCancel_Click" />
                        </td>
                        <td width="12%">
                        </td>
                    </tr>
                </table>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
    </form>
</body>
</html>

<%@ Page Language="C#" AutoEventWireup="true" CodeFile="AS_RelaxCardChangeUserInfoApproval.aspx.cs"
    Inherits="ASP_AddtionalService_AS_RelaxCardChangeUserInfoApproval" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>修改资料审核</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <script type="text/javascript" src="../../js/myext.js"></script>
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="../../js/jquery-1.5.min.js"></script>
    <script type="text/javascript">
        function SelectAll(tempControl) {

            var theBox = tempControl;
            xState = theBox.checked;
            var inputs = document.getElementById("gvResult").getElementsByTagName("input");
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
        附件业务->修改资料审核
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
                    修改资料查询
                </div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td>
                                <div align="right">
                                    开始日期:
                                </div>
                            </td>
                            <td>
                                <asp:TextBox runat="server" ID="txtFromDate" MaxLength="8" CssClass="input"></asp:TextBox>
                                <ajaxToolkit:CalendarExtender ID="FCalendar1" runat="server" TargetControlID="txtFromDate"
                                    Format="yyyyMMdd" />
                            </td>
                            <td>
                                <div align="right">
                                    结束日期:
                                </div>
                            </td>
                            <td>
                                <asp:TextBox runat="server" ID="txtToDate" MaxLength="8" CssClass="input"></asp:TextBox>
                                <ajaxToolkit:CalendarExtender ID="FCalendar2" runat="server" TargetControlID="txtToDate"
                                    Format="yyyyMMdd" />
                            </td>
                            <td>
                                <div align="right">
                                    部门:
                                </div>
                            </td>
                            <td>
                                <asp:DropDownList ID="selDept" CssClass="inputmid" runat="server" AutoPostBack="true"
                                    OnSelectedIndexChanged="selDept_Changed">
                                </asp:DropDownList>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    员工:
                                </div>
                            </td>
                            <td>
                                <asp:DropDownList ID="selStaff" CssClass="inputmid" runat="server">
                                </asp:DropDownList>
                            </td>
                            <td>
                                <div align="right">
                                    用户卡号:
                                </div>
                            </td>
                            <td>
                                <asp:TextBox ID="txtCardno" CssClass="input" runat="server" MaxLength="16" />
                            </td>
                            <td>
                                <div align="right">
                                    证件类型:
                                </div>
                            </td>
                            <td>
                                <asp:DropDownList ID="selPaperType" CssClass="input" runat="server">
                                </asp:DropDownList>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    证件号码:
                                </div>
                            </td>
                            <td>
                                <asp:TextBox ID="txtPaperNo" CssClass="input" runat="server" MaxLength="20" />
                            </td>
                            <td colspan='4'>
                                <div align="right">
                                    <asp:Button ID="btnQuery" CssClass="button1" runat="server" Text="查询" OnClick="btnQuery_Click" />
                                </div>
                            </td>
                        </tr>
                    </table>
                </div>
                <div class="jieguo">
                    修改资料审核
                </div>
                <div class="kuang5">
                    <div class="gdtb" style="height: 310px">
                        <asp:GridView ID="gvResult" runat="server" Width="150%" CssClass="tab1" HeaderStyle-CssClass="tabbt"
                            AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel" PagerSettings-Mode="NumericFirstLast"
                            PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top" AutoGenerateColumns="False"
                            OnRowDataBound="gvResult_RowDataBound" OnPageIndexChanging="gvResult_PageIndexChanging"
                            PageSize="10" AllowPaging="True">
                            <Columns>
                                <asp:TemplateField>
                                    <HeaderTemplate>
                                        <asp:CheckBox ID="CheckBox1" runat="server" onclick="SelectAll(this);" />
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                        <asp:CheckBox ID="ItemCheckBox" runat="server" />
                                        <asp:Label ID="lbOld" runat="server" Visible="false" Text="原始资料"></asp:Label>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="照片">
                                    <ItemTemplate>
                                        <asp:Image ID="Image1" Width="60px" Height="65px" runat="server" />
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField HeaderText="卡号" DataField="CARDNO" />
                                <asp:BoundField HeaderText="用户姓名" DataField="CUSTNAME" />
                                <asp:BoundField HeaderText="证件类型" DataField="PAPERTYPECODE" />
                                <asp:BoundField HeaderText="证件号码" DataField="PAPERNO" />
                                <asp:BoundField HeaderText="性别" DataField="CUSTSEX" />
                                <asp:BoundField HeaderText="出生日期" DataField="CUSTBIRTH" />
                                <asp:BoundField HeaderText="联系地址" DataField="CUSTADDR" />
                                <asp:BoundField HeaderText="邮政编码" DataField="CUSTPOST" />
                                <asp:BoundField HeaderText="联系电话" DataField="CUSTPHONE" />
                                <asp:BoundField HeaderText="EMAIL地址" DataField="CUSTEMAIL" />
                                <asp:BoundField HeaderText="更新员工" DataField="UPDATESTAFFNO" />
                                <asp:BoundField HeaderText="更新时间" DataField="UPDATETIME" />
                            </Columns>
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                        <td>
                                            <input type="checkbox" />
                                        </td>
                                        <td>
                                            卡号
                                        </td>
                                        <td>
                                            用户姓名
                                        </td>
                                        <td>
                                            性别
                                        </td>
                                        <td>
                                            出生日期
                                        </td>
                                        <td>
                                            证件类型
                                        </td>
                                        <td>
                                            证件号码
                                        </td>
                                        <td>
                                            联系地址
                                        </td>
                                        <td>
                                            邮政编码
                                        </td>
                                        <td>
                                            联系电话
                                        </td>
                                        <td>
                                            EMAIL地址
                                        </td>
                                        <td>
                                            更新员工
                                        </td>
                                        <td>
                                            更新时间
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
 <%--       <Triggers>
            <asp:PostBackTrigger ControlID="btnQuery" />
        </Triggers>--%>
    </asp:UpdatePanel>
    </form>
</body>
</html>

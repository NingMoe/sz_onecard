<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PB_QueryReader.aspx.cs" Inherits="ASP_PersonalBusiness_PB_QueryReader" EnableEventValidation="false" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>读卡器查询</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <script type="text/javascript" src="../../js/myext.js"></script>
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
    <div class="tb">
        个人业务->读卡器查询</div>
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
    <asp:UpdatePanel ID="UpdatePanel1" runat="server" RenderMode="Inline">
        <ContentTemplate>
            <aspControls:PrintPingZheng ID="ptnPingZheng" runat="server" PrintArea="ptnPingZheng1" />
            <asp:BulletedList ID="bulMsgShow" runat="server">
            </asp:BulletedList>
            <script runat="server">public override void ErrorMsgShow() { ErrorMsgHelper(bulMsgShow); }</script>
            <asp:HiddenField ID="hidChangeType" runat="server" />
            <div class="con">
                <div class="card">
                    查询</div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text20">
                        <tr>
                            <td width="12%" align="right">
                                读卡器序列号:
                            </td>
                            <td width="12%">
                                <asp:TextBox ID="txtReaderNo" CssClass="inputmid" runat="server" MaxLength="16" />
                            </td>
                            <td width="12%">
                                <div align="right">
                                    起始售出日期:</div>
                            </td>
                            <td width="12%">
                                <ajaxToolkit:CalendarExtender ID="BeginCalendar" runat="server" TargetControlID="txtStartDate"
                                    Format="yyyyMMdd" PopupPosition="BottomLeft" />
                                <asp:TextBox ID="txtStartDate" runat="server" CssClass="input" MaxLength="8"></asp:TextBox>
                            </td>
                            <td width="12%">
                                <div align="right">
                                    结束售出日期:</div>
                            </td>
                            <td width="12%">
                                <asp:TextBox ID="txtEndDate" runat="server" CssClass="input" MaxLength="8"></asp:TextBox>
                                <ajaxToolkit:CalendarExtender ID="CalendarExtender2" runat="server" TargetControlID="txtEndDate"
                                    Format="yyyyMMdd" PopupPosition="BottomLeft" />
                            </td>
                            <td width="12%" align="right">
                            </td>
                            <td width="12%" align="left">
                                <asp:Button ID="btnQuery" CssClass="button1" runat="server" Text="查询" OnClick="btnQuery_Click" />
                            </td>
                        </tr>
                    </table>
                </div>
                <div class="jieguo">
                    查询结果</div>
                <div class="kuang5">
                    <div id="gvUseCard" style="height: 150px; overflow: auto; display: block">
                        <asp:GridView ID="gvResult" runat="server" Width="98%" CssClass="tab1" HeaderStyle-CssClass="tabbt"
                            FooterStyle-CssClass="tabcon" AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel"
                            PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top"
                            AutoGenerateColumns="false" PageSize="50" AllowPaging="true" OnRowDataBound="gvResult_RowDataBound"
                            OnPageIndexChanging="gvResult_Page" OnSelectedIndexChanged="gvResult_SelectedIndexChanged" 
                            OnRowCreated="gvResult_RowCreated">
                            <Columns>
                                <asp:BoundField DataField="SERIALNUMBER" HeaderText="读卡器序号" />
                                <asp:BoundField DataField="SALETIME" HeaderText="出售时间" />
                                <asp:BoundField DataField="DEPARTNAME" HeaderText="出售部门" />
                                <asp:BoundField DataField="STAFFNAME" HeaderText="出售员工" />
                                <asp:BoundField DataField="READERSTATE" HeaderText="读卡器状态" />
                                <asp:BoundField DataField="CUSTNAME" HeaderText="姓名" />
                                <asp:BoundField DataField="CUSTSEX" HeaderText="性别" />
                                <asp:BoundField DataField="CUSTBIRTH" HeaderText="出生日期" />
                                <asp:BoundField DataField="PAPERTYPECODE" HeaderText="证件类型" />
                                <asp:BoundField DataField="PAPERNO" HeaderText="证件号码" />
                                <asp:BoundField DataField="CUSTADDR" HeaderText="地址" />
                                <asp:BoundField DataField="CUSTPOST" HeaderText="邮编" />
                                <asp:BoundField DataField="CUSTPHONE" HeaderText="电话" />
                                <asp:BoundField DataField="CUSTEMAIL" HeaderText="EMAIL" />
                                <asp:BoundField DataField="REMARK" HeaderText="备注" />
                            </Columns>
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                        <td>
                                            读卡器序号
                                        </td>
                                        <td>
                                            出售时间
                                        </td>
                                        <td>
                                            出售部门
                                        </td>
                                        <td>
                                            出售员工
                                        </td>
                                        <td>
                                            读卡器状态
                                        </td>
                                        <td>
                                            姓名
                                        </td>
                                    </tr>
                                </table>
                            </EmptyDataTemplate>
                        </asp:GridView>
                    </div>
                </div>
                <div class="pip">
                    用户信息</div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text20">
                        <tr>
                            <td width="12%">
                                <div align="right">
                                    用户姓名:</div>
                            </td>
                            <td width="12%">
                                <asp:Label ID="CustName" runat="server" Text=""></asp:Label>
                            </td>
                            <td width="12%">
                                <div align="right">
                                    出生日期:</div>
                            </td>
                            <td width="12%">
                                <asp:Label ID="CustBirthday" runat="server" Text=""></asp:Label>
                            </td>
                            <td width="12%">
                                <div align="right">
                                    证件类型:</div>
                            </td>
                            <td width="12%">
                                <asp:Label ID="Papertype" runat="server" Text=""></asp:Label>
                            </td>
                            <td width="12%">
                                <div align="right">
                                    证件号码:</div>
                            </td>
                            <td width="12%" colspan="3">
                                <asp:Label ID="Paperno" runat="server" Text=""></asp:Label>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    用户性别:</div>
                            </td>
                            <td>
                                <asp:Label ID="Custsex" runat="server" Text=""></asp:Label>
                            </td>
                            <td>
                                <div align="right">
                                    联系电话:</div>
                            </td>
                            <td>
                                <asp:Label ID="Custphone" runat="server" Text=""></asp:Label>
                            </td>
                            <td>
                                <div align="right">
                                    邮政编码:</div>
                            </td>
                            <td>
                                <asp:Label ID="Custpost" runat="server" Text=""></asp:Label>
                            </td>
                            <td>
                                <div align="right">
                                    联系地址:</div>
                            </td>
                            <td colspan="3">
                                <asp:Label ID="Custaddr" runat="server" Text=""></asp:Label>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                电子邮件:
                            </td>
                            <td>
                                <asp:Label ID="txtEmail" runat="server" Text=""></asp:Label>
                            </td>
                            <td valign="top">
                                <div align="right">
                                    备注 :</div>
                            </td>
                            <td colspan="5">
                                <asp:Label ID="Remark" runat="server" Text=""></asp:Label>
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

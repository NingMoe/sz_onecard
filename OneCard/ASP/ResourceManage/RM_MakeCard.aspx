<%@ Page Language="C#" AutoEventWireup="true" CodeFile="RM_MakeCard.aspx.cs" Inherits="ASP_ResourceManage_RM_MakeCard"
    EnableEventValidation="false" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <%--<link rel="stylesheet" type="text/css" href="../../css/frame.css" />--%>
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="../../js/myext.js"></script>
    <script type="text/javascript" src="../../js/RMHelper.js"></script>
    <script type="text/javascript" src="../../js/printorder.js"></script>
    <script src="../../js/jquery-1.5.min.js" type="text/javascript"></script>
    <script type="text/javascript" src="../../js/Window.js"></script>
    <title>生成制卡</title>
    <style type="text/css">
        table.data
        {
            font-size: 90%;
            border-collapse: collapse;
            border: 0px solid black;
        }
        table.data th
        {
            background: #bddeff;
            width: 25em;
            text-align: left;
            padding-right: 8px;
            font-weight: normal;
            border: 1px solid black;
        }
        table.data td
        {
            background: #ffffff;
            vertical-align: middle;
            padding: 0px 2px 0px 2px;
            border: 1px solid black;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
    <div class="tb">
        卡片管理->生成制卡
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
    <asp:UpdatePanel ID="UpdatePanel1" UpdateMode="Conditional" runat="server">
        <ContentTemplate>
            <asp:BulletedList ID="bulMsgShow" runat="server" />
            <script runat="server">public override void ErrorMsgShow() { ErrorMsgHelper(bulMsgShow); }</script>
            <div class="con">
                <div class="card">
                    查询
                </div>
                <div class="kuang5" style="text-align: left">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td width="15%">
                                <div align="right">
                                    订购单号:</div>
                            </td>
                            <td width="15%">
                                <asp:TextBox runat="server" ID="txtApplyOrderID" CssClass="inputmid" MaxLength="18"></asp:TextBox>
                            </td>
                            <td width="15%">
                                <div align="right">
                                    起始日期:</div>
                            </td>
                            <td width="15%">
                                <ajaxToolkit:CalendarExtender ID="BeginCalendar" runat="server" TargetControlID="txtStartDate"
                                    Format="yyyyMMdd" PopupPosition="BottomLeft" />
                                <asp:TextBox ID="txtStartDate" runat="server" CssClass="input" MaxLength="8"></asp:TextBox>
                            </td>
                            <td width="15%">
                                <div align="right">
                                    结束日期:</div>
                            </td>
                            <td width="15%">
                                <asp:TextBox ID="txtEndDate" runat="server" CssClass="input" MaxLength="8"></asp:TextBox>
                                <ajaxToolkit:CalendarExtender ID="CalendarExtender2" runat="server" TargetControlID="txtEndDate"
                                    Format="yyyyMMdd" PopupPosition="BottomLeft" />
                            </td>
                        </tr>
                        <tr>
                            <th style="text-align: right">
                                私钥：
                            </th>
                            <td colspan='2'>
                                <asp:FileUpload ID="FileUpload1" runat="server" CssClass="inputlong" />
                                <%--<asp:Button ID="btnUpload" CssClass="button1" runat="server" Text="导入" OnClick="btnUpload_Click" />--%>
                            </td>
                            <td>
                                <asp:Label ID="lblMessage" runat="server" Text=""></asp:Label>
                            </td>
                            <td width="15%" colspan='2' align="right">
                                <asp:Button ID="btnQuery" CssClass="button1" runat="server" Text="查询" OnClick="btnQuery_Click" />
                            </td>
                        </tr>
                    </table>
                </div>
                <div class="jieguo">
                    查询结果</div>
                <div class="kuang5">
                    <div id="gvSupplyCard" style="height: 330px; overflow: auto; display: block">
                        <asp:GridView ID="gvResult" runat="server" Width="120%" CssClass="tab1" HeaderStyle-CssClass="tabbt"
                            FooterStyle-CssClass="tabcon" AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel"
                            PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top"
                            AutoGenerateColumns="false" OnRowCreated="gvResult_RowCreated" OnRowDataBound="gvResult_RowDataBound">
                            <Columns>
                                <asp:BoundField DataField="CARDORDERID" HeaderText="订购单号" />
                                <asp:BoundField DataField="VALUECODE" HeaderText="面值" />
                                <asp:BoundField DataField="CARDNUM" HeaderText="下单数量" />
                                <asp:BoundField DataField="STATE" HeaderText="审核状态" />
                                <asp:BoundField DataField="ORDERTIME" HeaderText="下单时间" />
                                <asp:BoundField DataField="TASKID" HeaderText="任务ID" />
                                <asp:BoundField DataField="MANUTYPECODE" HeaderText="厂商" />
                                <asp:BoundField DataField="APPVERNO" HeaderText="批次号" />
                                <asp:BoundField DataField="SECTION" HeaderText="充值卡号段" />
                                <asp:BoundField DataField="TASKSTATE" HeaderText="任务状态" />
                                <asp:BoundField DataField="TASKSTARTTIME" HeaderText="开始时间" />
                                <asp:BoundField DataField="TASKENDTIME" HeaderText="结束时间" />
                                <asp:BoundField DataField="ORDERSTAFF" HeaderText="操作员工" />
                                <asp:BoundField DataField="DATETIME" HeaderText=" 操作时间" />
                                <asp:TemplateField>
                                    <HeaderTemplate>
                                        <asp:Label ID="headerText" Text="制卡文件下载" runat="server"></asp:Label>
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                        <asp:Button ID="btnDownload" Enabled="true" Width="60px" CssClass="button1" runat="server"
                                            Text="下载" CommandArgument='<%# Container.DataItemIndex%>' OnClick="btnDownload_Click" />
                                        <asp:HiddenField ID="hidFilePath" runat="server" Value='<%#Eval("FILEPATH")%>' />
                                        <asp:HiddenField ID="hidTaskState" runat="server" Value='<%#Eval("TASKSTATE")%>' />
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField>
                                    <HeaderTemplate>
                                        <asp:Label ID="headerText" Text="制卡文件删除" runat="server"></asp:Label>
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                        <asp:Button ID="btnDelete" Enabled="true" Width="60px" CssClass="button1" runat="server"
                                            Text="删除" CommandArgument='<%# Container.DataItemIndex%>' OnClick="btnDelete_Click" />
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField DataField="REMARK" HeaderText=" 说明" />
                            </Columns>
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                        <td>
                                            订购单号
                                        </td>
                                        <td>
                                            面值
                                        </td>
                                        <td>
                                            下单数量
                                        </td>
                                        <td>
                                            审核状态
                                        </td>
                                        <td>
                                            下单时间
                                        </td>
                                        <td>
                                            任务ID
                                        </td>
                                        <td>
                                            厂商
                                        </td>
                                        <td>
                                            批次号
                                        </td>
                                        <td>
                                            充值卡号段
                                        </td>
                                        <td>
                                            任务状态
                                        </td>
                                        <td>
                                            开始时间
                                        </td>
                                        <td>
                                            结束时间
                                        </td>
                                        <td>
                                            操作员工
                                        </td>
                                        <td>
                                            操作时间
                                        </td>
                                        <td>
                                            制卡文件下载
                                        </td>
                                        <td>
                                            制卡文件删除
                                        </td>
                                        <td>
                                            说明
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
                <table width="300" border="0" align="right" cellpadding="0" cellspacing="0">
                    <tr>
                        <td>
                            <asp:Button ID="btnSubmit" Text="提交任务" CssClass="button1" runat="server" OnClick="btnSubmit_Click" />
                        </td>
                        <td>
                            <asp:Button ID="btnCancel" Text="作废任务" CssClass="button1" runat="server" OnClick="btnCancel_Click" />
                        </td>
                        <td>
                            <asp:Button ID="btnRestart" Text="重启失败任务" CssClass="button1" runat="server" OnClick="btnRestart_Click"
                                Width="101px" />
                        </td>
                    </tr>
                </table>
            </div>
        </ContentTemplate>
        <Triggers>
            <asp:PostBackTrigger ControlID="btnQuery" />
            <asp:PostBackTrigger ControlID="btnSubmit" />
            <asp:PostBackTrigger ControlID="btnCancel" />
            <asp:PostBackTrigger ControlID="btnRestart" />
        </Triggers>
    </asp:UpdatePanel>
    </form>
</body>
</html>

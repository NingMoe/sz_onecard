<%@ Page Language="C#" AutoEventWireup="true" CodeFile="WA_GrayList.aspx.cs" Inherits="ASP_Warn_WA_WA_GrayList"
    EnableEventValidation="false" %>

<%@ Register Src="../../CardReader.ascx" TagName="CardReader" TagPrefix="cr" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>轻轨灰名单</title>
    <%--<link rel="stylesheet" type="text/css" href="../../css/frame.css" />--%>
    <script type="text/javascript" src="../../js/print.js"></script>
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <cr:CardReader ID="cardReader" runat="server" />
    <form id="form1" runat="server">
    <div class="tb">
        财务监控->轻轨灰名单
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
    <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
            <asp:BulletedList ID="bulMsgShow" runat="server">
            </asp:BulletedList>
            <script runat="server">public override void ErrorMsgShow() { ErrorMsgHelper(bulMsgShow); }</script>
            <div class="con">
                <div class="card">
                    查询</div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td width="10%">
                                <div align="right">
                                    卡号:</div>
                            </td>
                            <td width="10%">
                                <asp:TextBox ID="txtCardNum" runat="server" CssClass="input" MaxLength="16"></asp:TextBox>
                            </td>
                            <td width="10%">
                                <div align="right">
                                    起始日期:</div>
                            </td>
                            <td width="10%">
                                <ajaxToolkit:CalendarExtender ID="BeginCalendar" runat="server" TargetControlID="txtStartDate"
                                    Format="yyyyMMdd" PopupPosition="BottomLeft" />
                                <asp:TextBox ID="txtStartDate" runat="server" CssClass="input" MaxLength="8"></asp:TextBox>
                            </td>
                            <td width="10%">
                                <div align="right">
                                    结束日期:</div>
                            </td>
                            <td width="10%">
                                <asp:TextBox ID="txtEndDate" runat="server" CssClass="input" MaxLength="8"></asp:TextBox>
                                <ajaxToolkit:CalendarExtender ID="CalendarExtender2" runat="server" TargetControlID="txtEndDate"
                                    Format="yyyyMMdd" PopupPosition="BottomLeft" />
                            </td>
                            <td width="10%">
                            </td>
                            <td width="10%">
                            </td>
                            <td width="10%">
                            </td>
                            <td width="12%" align="right">
                                <asp:Button ID="Button1" runat="server" Text="查询" CssClass="button1" OnClick="btnQuery_Click" />
                            </td>
                        </tr>
                    </table>
                </div>
                <div class="jieguo">
                    轻轨灰名单信息</div>
                <div class="kuang5">
                    <div id="gdtb" style="height: 280px;">
                        <asp:GridView ID="gvResult" runat="server" CssClass="tab1" Width="100%" HeaderStyle-CssClass="tabbt"
                            AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel" AllowPaging="True"
                            PageSize="10" PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="Left"
                            PagerStyle-VerticalAlign="Top" AutoGenerateColumns="False" OnPageIndexChanging="gvResult_Page"
                            OnSelectedIndexChanged="gvResult_SelectedIndexChanged" AutoGenerateSelectButton="true">
                            <Columns>
                                <asp:BoundField DataField="CARDNO" HeaderText="卡号" />
                                <asp:BoundField DataField="REMARK" HeaderText="录入原因" />
                                <asp:BoundField DataField="CREATETIME" HeaderText="录入时间" />
                                <asp:BoundField DataField="STAFFNAME" HeaderText="录入员工" />
                            </Columns>
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                        <td>
                                            卡号
                                        </td>
                                        <td>
                                            录入原因
                                        </td>
                                        <td>
                                            录入时间
                                        </td>
                                        <td>
                                            录入员工
                                        </td>
                                    </tr>
                                </table>
                            </EmptyDataTemplate>
                        </asp:GridView>
                    </div>
                </div>
                <div class="pip">
                    轻轨灰名单录入</div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td align="right" width="8%">
                                卡号:
                            </td>
                            <td width="17%">
                                <asp:TextBox runat="server" ID="txtCardno" CssClass="input" MaxLength="16" />
                                <span class="red">*</span>
                            </td>
                            <td width="22%">
                            </td>
                            <td align="right" width="8%">
                                录入时间:
                            </td>
                            <td width="15%">
                                <asp:Label runat="server" ID="labCreateTime" />
                            </td>
                            <td align="right" width="10%">
                                录入员工:
                            </td>
                            <td width="10%">
                                <asp:Label runat="server" ID="labCreateStaffNo" />
                            </td>
                        </tr>
                        <tr>
                            <td align="right">
                                录入原因:
                            </td>
                            <td colspan="5">
                                <asp:TextBox runat="server" ID="txtRemark" CssClass="inputlong" MaxLength="50" length="300px" />
                                <span class="red">*</span>
                            </td>
                            <td colspan="2" align="right">
                                <asp:Button ID="btnGrayAdd" Text="增加" CssClass="button1" runat="server" OnClick="btnGrayAdd_Click" />&nbsp;&nbsp;&nbsp;
                                <asp:Button ID="btnGrayDelete" Text="删 除" CssClass="button1" runat="server" Enabled="false"
                                    OnClick="btnGrayDelete_Click" />
                            </td>
                        </tr>
                    </table>
                </div>
                <div class="base">
                    轻轨灰名单批量导入</div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td>
                                <div align="right">
                                    导入文件:</div>
                            </td>
                            <td>
                                <asp:FileUpload ID="FileUpload1" runat="server" CssClass="inputlong" />
                                <asp:Button ID="btnBatchAdd" CssClass="button1" runat="server" Text="导入" OnClick="btnBatchAdd_Click" />
                            </td>
                        </tr>
                    </table>
                </div>
            </div>
        </ContentTemplate>
        <Triggers>
            <asp:PostBackTrigger ControlID="btnBatchAdd" />
        </Triggers>
    </asp:UpdatePanel>
    </form>
</body>
</html>

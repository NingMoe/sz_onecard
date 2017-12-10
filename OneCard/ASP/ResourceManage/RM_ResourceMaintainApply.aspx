<%@ Page Language="C#" AutoEventWireup="true" CodeFile="RM_ResourceMaintainApply.aspx.cs"
    Inherits="ASP_ResourceManage_RM_ResourceMaintainApply" EnableEventValidation="false" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>资源维护申请</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="../../js/myext.js"></script>
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

        .attributeDIV
        {
            width: 24%;
            float: left;
            text-align: center;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="tb">
            其他资源管理->资源维护申请
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
                    <div class="card">
                        查询
                    </div>
                    <div class="kuang5">
                        <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                            <tr>
                                <td width="15%">
                                    <div align="right">
                                        开始日期:
                                    </div>
                                </td>
                                <td width="15%">
                                    <asp:TextBox runat="server" ID="txtFromDate" MaxLength="8" CssClass="input"></asp:TextBox>
                                    <ajaxToolkit:CalendarExtender ID="FCalendar1" runat="server" TargetControlID="txtFromDate"
                                        Format="yyyyMMdd" />
                                </td>
                                <td width="15%">
                                    <div align="right">
                                        结束日期:
                                    </div>
                                </td>
                                <td width="15%">
                                    <asp:TextBox runat="server" ID="txtToDate" MaxLength="8" CssClass="input"></asp:TextBox>
                                    <ajaxToolkit:CalendarExtender ID="FCalendar2" runat="server" TargetControlID="txtToDate"
                                        Format="yyyyMMdd" />
                                </td>
                                <td width="15%">
                                    <div align="right">
                                        资源类型:
                                    </div>
                                </td>
                                <td width="15%">
                                    <asp:DropDownList ID="ddlResourceType" CssClass="inputmid" runat="server">
                                    </asp:DropDownList>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <div align="right">
                                        维护部门:
                                    </div>
                                </td>
                                <td>
                                    <asp:DropDownList ID="selDept" CssClass="input" runat="server">
                                    </asp:DropDownList>
                                </td>
                                <td>
                                    <div align="right">
                                        维护单状态:
                                    </div>
                                </td>
                                <td>
                                    <asp:DropDownList ID="selExamState" CssClass="input" runat="server">
                                        <asp:ListItem Text="全部" Value="" Selected="True"></asp:ListItem>
                                        <asp:ListItem Text="0: 待审核" Value="0"></asp:ListItem>
                                        <asp:ListItem Text="1: 审核通过" Value="1"></asp:ListItem>
                                        <asp:ListItem Text="2: 审核作废" Value="2"></asp:ListItem>
                                    </asp:DropDownList>
                                </td>
                                <td colspan="2"></td>
                                <td align="right">
                                    <asp:Button ID="btnQuery" CssClass="button1" runat="server" Text="查询" OnClick="btnQuery_Click" />
                                </td>
                            </tr>
                        </table>
                    </div>
                    <div class="jieguo">
                        查询结果
                    </div>
                    <div class="kuang5">
                        <div id="gvUseCard" style="height: 130px; overflow: auto; display: block">
                            <asp:GridView ID="gvResult" runat="server" Width="150%" CssClass="tab1" HeaderStyle-CssClass="tabbt"
                                FooterStyle-CssClass="tabcon" AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel"
                                PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top"
                                AutoGenerateColumns="false" OnRowDataBound="gvResult_RowDataBound" OnSelectedIndexChanged="gvResult_SelectedIndexChanged"
                                OnRowCreated="gvResult_RowCreated">
                                <Columns>
                                    <asp:BoundField DataField="MAINTAINORDERID" HeaderText="维护单号" />
                                    <asp:BoundField DataField="STATE" HeaderText="维护单状态" />
                                    <asp:BoundField DataField="RESUOURCETYPE" HeaderText="资源类型" />
                                    <asp:BoundField DataField="RESOURCENAME" HeaderText="资源名称" />
                                    <asp:BoundField DataField="MAINTAINREASON" HeaderText="申请原因" />
                                    <asp:BoundField DataField="DEPARTNAME" HeaderText="申请维护部门" />
                                    <asp:BoundField DataField="MAINTAINSTAFF" HeaderText="维护员工" />
                                    <asp:BoundField DataField="MAINTAINREQUEST" HeaderText="维护要求" />
                                    <asp:BoundField DataField="TIMELIMIT" HeaderText="维护期限" />
                                    <asp:BoundField DataField="FEEDBACK" HeaderText="反馈信息" />
                                    <asp:BoundField DataField="ORDERTIME" HeaderText="下单时间" />
                                    <asp:BoundField DataField="STAFFNAME" HeaderText="下单员工" />
                                    <asp:BoundField DataField="ORDERDEPART" HeaderText="下单部门" />
                                    <asp:BoundField DataField="REMARK" HeaderText="备注" />
                                </Columns>
                                <EmptyDataTemplate>
                                    <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                        <tr class="tabbt">
                                            <td>维护单号
                                            </td>
                                            <td>维护单状态
                                            </td>
                                            <td>资源类型
                                            </td>
                                            <td>资源名称
                                            </td>
                                            <td>申请原因
                                            </td>
                                            <td>申请维护部门
                                            </td>
                                            <td>维护员工
                                            </td>
                                            <td>维护要求
                                            </td>
                                            <td>维护期限
                                            </td>
                                            <td>反馈信息
                                            </td>
                                            <td>下单时间
                                            </td>
                                            <td>下单员工
                                            </td>
                                            <td>下单部门
                                            </td>
                                            <td>备注
                                            </td>
                                        </tr>
                                    </table>
                                </EmptyDataTemplate>
                            </asp:GridView>
                        </div>
                    </div>
                    <div>
                        <asp:Panel ID="Panel1" runat="server">
                            <div class="card">
                                维护反馈信息
                            </div>
                            <div class="kuang5">
                                <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                                    <tr>
                                        <td width="10%">
                                            <div align="right">
                                                维护日期:
                                            </div>
                                        </td>
                                        <td width="40%">
                                            <asp:TextBox runat="server" ID="maintainDate" MaxLength="8" CssClass="input"></asp:TextBox>
                                            <ajaxToolkit:CalendarExtender ID="CalendarExtender2" runat="server" TargetControlID="maintainDate"
                                                Format="yyyyMMdd" />
                                            <span class="red">*</span>
                                        </td>
                                        <td width="10%">
                                            <div align="right">
                                                维护结果:
                                            </div>
                                        </td>
                                        <td width="40%">
                                            <asp:DropDownList ID="ddlResult" runat="server" CssClass="input">
                                                <asp:ListItem Text="---请选择---" Value="" Selected="True"></asp:ListItem>
                                                <asp:ListItem Text="已完成" Value="0"></asp:ListItem>
                                                <asp:ListItem Text="未完成" Value="1"></asp:ListItem>
                                            </asp:DropDownList>
                                            <span class="red">*</span>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <div align="right">
                                                其他:
                                            </div>
                                        </td>
                                        <td>
                                            <asp:TextBox ID="txtOther" Width="200px" Height="20px" runat="server" TextMode="MultiLine"></asp:TextBox>
                                        </td>
                                        <td>
                                            <div align="right">
                                                实际维护人员:
                                            </div>
                                        </td>
                                        <td>
                                            <asp:TextBox runat="server" ID="txtMaintainStaff" MaxLength="8" CssClass="input"></asp:TextBox>
                                            <span class="red">*</span>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td width="10%"></td>
                                        <td width="40%"></td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <div align="right">
                                                反馈信息汇总:
                                            </div>
                                        </td>
                                        <td colspan="3">
                                            <asp:Label ID="txtMessage" runat="server" />
                                        </td>
                                    </tr>
                                </table>
                            </div>
                            <div class="footall">
                            </div>
                            <div class="btns">
                                <table width="200" border="0" align="right" cellpadding="0" cellspacing="0">
                                    <tr>
                                        <td>
                                            <asp:Button ID="btnFeedBackSubmit" runat="server" Text="提交" CssClass="button1" Enabled="true"
                                                OnClick="btnFeedBackSubmit_Click" />
                                        </td>
                                    </tr>
                                </table>
                            </div>
                        </asp:Panel>
                    </div>
                    <div>
                        <asp:Panel ID="Panel2" runat="server">
                            <div class="card">
                                资源维护申请
                            </div>
                            <div class="kuang5">
                                <asp:HiddenField ID="hideValue" runat="server" />
                                <asp:HiddenField ID="hideMaintainOrderId" runat="server" />
                                <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                                    <tr>
                                        <td width="10%">
                                            <div align="right">
                                                资源类型:
                                            </div>
                                        </td>
                                        <td width="40%">
                                            <asp:DropDownList ID="ddlResourceType2" runat="server" CssClass="input" OnSelectedIndexChanged="ddlResourceType2_SelectIndexChange"
                                                AutoPostBack="true" Height="17px">
                                            </asp:DropDownList>
                                            <span class="red">*</span>
                                        </td>
                                        <td width="10%">
                                            <div align="right">
                                                资源名称:
                                            </div>
                                        </td>
                                        <td width="40%">
                                            <asp:DropDownList ID="ddlResource" runat="server" CssClass="input">
                                            </asp:DropDownList>
                                            <span class="red">*</span>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <div align="right">
                                                申请原因:
                                            </div>
                                        </td>
                                        <td>
                                            <asp:TextBox ID="txtMaintainReason" CssClass="inputlong" Width="313px" Height="60px"
                                                MaxLength="255" Rows="4" runat="server" TextMode="MultiLine">
                                </asp:TextBox>
                                            <span class="red">*</span>
                                        </td>
                                        <td>
                                            <div align="right">
                                                备注:
                                            </div>
                                        </td>
                                        <td>
                                            <asp:TextBox ID="txtRemark" CssClass="inputlong" Width="313px" Height="60px" MaxLength="255"
                                                Rows="4" runat="server" TextMode="MultiLine">
                                </asp:TextBox>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <div align="right">
                                                申请维护部门:
                                            </div>
                                        </td>
                                        <td>
                                            <asp:DropDownList ID="ddlMaintainDepart" CssClass="input" runat="server">
                                            </asp:DropDownList>
                                            <span class="red">*</span>
                                        </td>
                                        <td>
                                            <div align="right">
                                                维护期限:
                                            </div>
                                        </td>
                                        <td>
                                            <asp:TextBox runat="server" ID="txtTimeLimit" MaxLength="8" CssClass="input"></asp:TextBox>
                                            <span class="red">*</span>
                                            <ajaxToolkit:CalendarExtender ID="CalendarExtender1" runat="server" TargetControlID="txtTimeLimit"
                                                Format="yyyyMMdd" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <div align="right">
                                                联系电话:
                                            </div>
                                        </td>
                                        <td>
                                            <asp:TextBox runat="server" ID="txtTel" MaxLength="8" CssClass="input"></asp:TextBox>
                                            </asp:TextBox>
                                        </td>
                                        <td>
                                            <div align="right">
                                                维护要求:
                                            </div>
                                        </td>
                                        <td>
                                            <asp:TextBox ID="txtMaintainRequest" CssClass="inputlong" Width="313px" Height="60px"
                                                MaxLength="255" Rows="4" runat="server" TextMode="MultiLine">
                                </asp:TextBox>
                                        </td>
                                    </tr>
                                </table>
                            </div>
                            <div class="btns">
                                <table width="200" border="0" align="right" cellpadding="0" cellspacing="0">
                                    <tr>
                                        <td>
                                            <asp:Button ID="btnSubmit" runat="server" Text="维护申请" CssClass="button1" Enabled="true"
                                                OnClick="btnSubmit_Click" />
                                        </td>
                                    </tr>
                                </table>
                            </div>
                        </asp:Panel>
                    </div>
                </div>
                <div style="display: none" runat="server" id="printarea">
                </div>
            </ContentTemplate>
        </asp:UpdatePanel>
    </form>
</body>
</html>

<%@ Page Language="C#" AutoEventWireup="true" CodeFile="RM_ContractManager.aspx.cs"
    Inherits="ASP_ResourceManage_RM_ContractManager" EnableEventValidation="false" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>合同管理</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="../../js/myext.js"></script>
</head>
<body>
    <form id="form1" runat="server">
    <div class="tb">
        其他资源管理->合同管理
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
                    查询</div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td width="15%">
                                <div align="right">
                                    合同名称:</div>
                            </td>
                            <td width="15%">
                                <asp:TextBox ID="txtSelContractName" runat="server" CssClass="input" MaxLength="8"></asp:TextBox>
                            </td>
                            <td width="15%">
                                <div align="right">
                                    合同单位:</div>
                            </td>
                            <td width="15%">
                                <asp:TextBox ID="txtSelComPany" runat="server" CssClass="input" MaxLength="8"></asp:TextBox>
                            </td>
                        </tr>
                        <tr>
                            <td width="15%">
                                <div align="right">
                                    开始日期:</div>
                            </td>
                            <td width="15%">
                                <ajaxToolkit:CalendarExtender ID="BeginCalendar" runat="server" TargetControlID="txtStartDate"
                                    Format="yyyyMMdd" PopupPosition="BottomLeft" />
                                <asp:TextBox ID="txtStartDate" runat="server" CssClass="input" MaxLength="8"></asp:TextBox>
                            </td>
                            <td width="10%">
                                <div align="right">
                                    结束日期:</div>
                            </td>
                            <td width="15%">
                                <asp:TextBox ID="txtEndDate" runat="server" CssClass="input" MaxLength="8"></asp:TextBox>
                                <ajaxToolkit:CalendarExtender ID="CalendarExtender2" runat="server" TargetControlID="txtEndDate"
                                    Format="yyyyMMdd" PopupPosition="BottomLeft" />
                            </td>
                            <td width="10%">
                            </td>
                            <td width="15%">
                                <asp:Button ID="btnQuery" CssClass="button1" runat="server" Text="查询" OnClick="btnQuery_Click" />
                            </td>
                        </tr>
                    </table>
                </div>
                <div class="jieguo">
                    查询结果</div>
                <div class="kuang5">
                    <div id="gvReslut" style="height: 130px; overflow: auto; display: block">
                        <asp:GridView ID="gvResult" runat="server" Width="100%" CssClass="tab1" HeaderStyle-CssClass="tabbt"
                            FooterStyle-CssClass="tabcon" AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel"
                            PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top"
                            AutoGenerateColumns="false" OnSelectedIndexChanged="gvResult_SelectedIndexChanged"
                            OnRowDataBound="gvResult_RowDataBound" OnRowCreated="gvResult_RowCreated">
                            <Columns>
                                <asp:BoundField DataField="CONTRACTCODE" HeaderText="合同单号" HeaderStyle-CssClass="Hide"
                                    ItemStyle-CssClass="Hide" />
                                <asp:BoundField DataField="CONTRACTNAME" HeaderText="合同名称" />
                                <asp:BoundField DataField="CONTRACTID" HeaderText="合同编号" />
                                <asp:BoundField DataField="SIGNINGCOMPANY" HeaderText="合同单位" />
                                <asp:BoundField DataField="SIGNINGDATE" HeaderText="签订日期" />
                            </Columns>
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                        <td>
                                            合同名称
                                        </td>
                                        <td>
                                            合同编号
                                        </td>
                                        <td>
                                            合同单位
                                        </td>
                                        <td>
                                            签订日期
                                        </td>
                                    </tr>
                                </table>
                            </EmptyDataTemplate>
                        </asp:GridView>
                    </div>
                </div>
                <div class="card">
                    合同信息</div>
                <div class="kuang5">
                    <table id="supplyUseCard" width="95%" border="0" cellpadding="0" cellspacing="0"
                        class="text25" style="display: block">
                        <tr>
                            <td width="12%">
                                <div align="right">
                                    合同名称:</div>
                            </td>
                            <td width="13%">
                                <asp:TextBox ID="txtContractName" runat="server" CssClass="input">
                                </asp:TextBox>
                                <asp:HiddenField ID="hideContractCode" runat="server" />
                                <span class="red">*</span>
                            </td>
                            <td width="12%">
                                <div align="right">
                                    合同编号:</div>
                            </td>
                            <td width="13%">
                                <asp:TextBox ID="txtContractID" runat="server" CssClass="input">
                                </asp:TextBox>
                                <span class="red">*</span>
                            </td>
                            <td>
                                <div align="right">
                                    合同单位:</div>
                            </td>
                            <td width="13%">
                                <asp:TextBox ID="txtSigningCompany" runat="server" CssClass="input">
                                </asp:TextBox>
                                <span class="red">*</span>
                            </td>
                            <td width="12%">
                                <div align="right">
                                    签订日期:</div>
                            </td>
                            <td width="13%">
                                <asp:TextBox ID="txtSigningDate" CssClass="input" runat="server" MaxLength="8" />
                                <ajaxToolkit:CalendarExtender ID="FCalendar" runat="server" TargetControlID="txtSigningDate"
                                    Format="yyyyMMdd" />
                                <span class="red">*</span>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    扫描件:</div>
                            </td>
                            <td colspan="3">
                                <asp:FileUpload ID="FileUpload1" runat="server" CssClass="textfield" />（多个附件请压缩上传）
                                <asp:LinkButton ID="linkDownLoad" runat="server" OnClick="linkDownLoad_Click">下载</asp:LinkButton>
                            </td>
                            <td>
                                <div align="right">
                                    合同内容概要:</div>
                            </td>
                            <td colspan="3">
                                <asp:TextBox ID="txtReMark" runat="server" CssClass="inputlong">
                                </asp:TextBox>
                            </td>
                        </tr>
                    </table>
                </div>
            </div>
            <div class="footall">
            </div>
            <div class="btns">
                <table width="300" border="0" align="right" cellpadding="0" cellspacing="0">
                    <tr>
                        <td>
                            <asp:Button ID="btnContractAdd" runat="server" Text="增加" CssClass="button1" OnClick="btnContractAdd_Click" />
                        </td>
                        <td>
                            <asp:Button ID="btnContractModify" runat="server" Text="修改" CssClass="button1" OnClick="btnContractModify_Click" />
                        </td>
                        <td>
                            <asp:Button ID="btnContractDelete" runat="server" Text="删除" CssClass="button1" OnClick="btnContractDelete_Click" />
                        </td>
                    </tr>
                </table>
            </div>
            <div style="display: none" runat="server" id="printarea">
            </div>
        </ContentTemplate>
        <Triggers>
            <asp:PostBackTrigger ControlID="linkDownLoad" />
            <asp:PostBackTrigger ControlID="btnContractAdd" />
            <asp:PostBackTrigger ControlID="btnContractModify" />
        </Triggers>
    </asp:UpdatePanel>
    </form>
</body>
</html>

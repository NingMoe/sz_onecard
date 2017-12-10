<%@ Page Language="C#" AutoEventWireup="true" CodeFile="RM_DocumentManager.aspx.cs" Inherits="ASP_ResourceManage_RM_DocumentManager"
    EnableEventValidation="false" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>文档管理</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="../../js/myext.js"></script>
</head>
<body>
    <form id="form1" runat="server">
        <div class="tb">
            其他资源管理->文档管理
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
                                        文档名称:
                                    </div>
                                </td>
                                <td width="15%">
                                    <asp:TextBox ID="txtSelContractName" runat="server" CssClass="input" MaxLength="8"></asp:TextBox>
                                </td>
                                <td width="15%">
                                    <div align="right">
                                        合作单位:
                                    </div>
                                </td>
                                <td width="15%">
                                    <asp:TextBox ID="txtSelComPany" runat="server" CssClass="input" MaxLength="8"></asp:TextBox>
                                </td>
                                <td width="15%">
                                    <div align="right">
                                        文档类型:
                                    </div>
                                </td>
                                <td width="15%">
                                    <asp:DropDownList ID="ddlSelDocumentType" runat="server">
                                        <asp:ListItem Value="">请选择</asp:ListItem>
                                        <asp:ListItem Value="1">说明报告</asp:ListItem>
                                        <asp:ListItem Value="2">保密协议</asp:ListItem>
                                        <asp:ListItem Value="3">政府机构文件</asp:ListItem>
                                        <asp:ListItem Value="4">公司文档</asp:ListItem>
                                        <asp:ListItem Value="5">其他文档</asp:ListItem>
                                    </asp:DropDownList>
                                </td>
                            </tr>
                            <tr>
                                <td width="15%">
                                    <div align="right">
                                        开始日期:
                                    </div>
                                </td>
                                <td width="15%">
                                    <ajaxToolkit:CalendarExtender ID="BeginCalendar" runat="server" TargetControlID="txtStartDate"
                                        Format="yyyyMMdd" PopupPosition="BottomLeft" />
                                    <asp:TextBox ID="txtStartDate" runat="server" CssClass="input" MaxLength="8"></asp:TextBox>
                                </td>
                                <td width="10%">
                                    <div align="right">
                                        结束日期:
                                    </div>
                                </td>
                                <td width="15%">
                                    <asp:TextBox ID="txtEndDate" runat="server" CssClass="input" MaxLength="8"></asp:TextBox>
                                    <ajaxToolkit:CalendarExtender ID="CalendarExtender2" runat="server" TargetControlID="txtEndDate"
                                        Format="yyyyMMdd" PopupPosition="BottomLeft" />
                                </td>
                                <td width="10%"></td>
                                <td width="15%">
                                    <asp:Button ID="btnQuery" CssClass="button1" runat="server" Text="查询" OnClick="btnQuery_Click" />
                                </td>
                            </tr>
                        </table>
                    </div>
                    <div class="jieguo">
                        查询结果
                    </div>
                    <div class="kuang5">
                        <div id="gvReslut" style="height: 130px; overflow: auto; display: block">
                            <asp:GridView ID="gvResult" runat="server" Width="100%" CssClass="tab1" HeaderStyle-CssClass="tabbt"
                                FooterStyle-CssClass="tabcon" AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel"
                                PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top"
                                AutoGenerateColumns="false" OnSelectedIndexChanged="gvResult_SelectedIndexChanged"
                                OnRowDataBound="gvResult_RowDataBound" OnRowCreated="gvResult_RowCreated">
                                <Columns>
                                    <asp:BoundField DataField="CONTRACTCODE" HeaderText="文档单号" HeaderStyle-CssClass="Hide"
                                        ItemStyle-CssClass="Hide" />
                                    <asp:BoundField DataField="CONTRACTNAME" HeaderText="文档名称" />
                                    <asp:BoundField DataField="CONTRACTID" HeaderText="文档编号" />
                                    <asp:BoundField DataField="DOCUMENTTYPE" HeaderText="文档类型" />
                                    <asp:BoundField DataField="SIGNINGCOMPANY" HeaderText="合作单位" />
                                    <asp:BoundField DataField="SIGNINGDATE" HeaderText="签订日期" />
                                </Columns>
                                <EmptyDataTemplate>
                                    <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                        <tr class="tabbt">
                                            <td>文档名称
                                            </td>
                                            <td>文档编号
                                            </td>
                                            <td>文档类型
                                            </td>
                                            <td>合作单位
                                            </td>
                                            <td>签订日期
                                            </td>
                                        </tr>
                                    </table>
                                </EmptyDataTemplate>
                            </asp:GridView>
                        </div>
                    </div>
                    <div class="card">
                        文档信息
                    </div>
                    <div class="kuang5">
                        <table id="supplyUseCard" width="95%" border="0" cellpadding="0" cellspacing="0"
                            class="text25" style="display: block">
                            <tr>
                                <td width="12%">
                                    <div align="right">
                                        文档名称:
                                    </div>
                                </td>
                                <td width="13%">
                                    <asp:TextBox ID="txtContractName" runat="server" CssClass="input">
                                    </asp:TextBox>
                                    <asp:HiddenField ID="hideContractCode" runat="server" />
                                    <span class="red">*</span>
                                </td>
                                <td width="12%">
                                    <div align="right">
                                        文档编号:
                                    </div>
                                </td>
                                <td width="13%">
                                    <asp:TextBox ID="txtContractID" runat="server" CssClass="input">
                                    </asp:TextBox>
                                    <span class="red">*</span>
                                </td>
                                <td>
                                    <div align="right">
                                        合作单位:
                                    </div>
                                </td>
                                <td width="13%">
                                    <asp:TextBox ID="txtSigningCompany" runat="server" CssClass="input">
                                    </asp:TextBox>
                                </td>
                                <td width="12%">
                                    <div align="right">
                                        文档类型:
                                    </div>
                                </td>
                                <td width="13%">
                                     <asp:DropDownList ID="ddlDocumentType" runat="server">
                                        <asp:ListItem Value="1">说明报告</asp:ListItem>
                                        <asp:ListItem Value="2">保密协议</asp:ListItem>
                                        <asp:ListItem Value="3">政府机构文件</asp:ListItem>
                                        <asp:ListItem Value="4">公司文档</asp:ListItem>
                                        <asp:ListItem Value="5">其他文档</asp:ListItem>
                                    </asp:DropDownList>   <span class="red">*</span>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <div align="right">
                                        扫描件:
                                    </div>
                                </td>
                                <td colspan="3">
                                    <asp:FileUpload ID="FileUpload1" runat="server" CssClass="textfield" />（多个附件请压缩上传）
                                <asp:LinkButton ID="linkDownLoad" runat="server" OnClick="linkDownLoad_Click">下载</asp:LinkButton>
                                </td>
                                <td>
                                    <div align="right">
                                        签订日期:
                                    </div>
                                </td>
                                <td>
                                    <asp:TextBox ID="txtSigningDate" CssClass="input" runat="server" MaxLength="8" />
                                    <ajaxToolkit:CalendarExtender ID="FCalendar" runat="server" TargetControlID="txtSigningDate"
                                        Format="yyyyMMdd" />
                                </td>
                                <td>
                                    <div align="right">
                                        文档内容概要:
                                    </div>
                                </td>
                                <td colspan="3">
                                    <asp:TextBox ID="txtReMark" runat="server" CssClass="input">
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
                                <asp:Button ID="btnContractAdd" runat="server" Text="增加" CssClass="button1" OnClick="btnDocumentAdd_Click" />
                            </td>
                            <td>
                                <asp:Button ID="btnContractModify" runat="server" Text="修改" CssClass="button1" OnClick="btnDocumentModify_Click" />
                            </td>
                            <td>
                                <asp:Button ID="btnContractDelete" runat="server" Text="删除" CssClass="button1" OnClick="btnDocumentDelete_Click" />
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

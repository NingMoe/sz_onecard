<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PB_BuyCardQuery.aspx.cs"
    Inherits="ASP_PersonalBusiness_PB_BuyCardQuery" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>购卡查询</title>
    <link href="../../css/RightFrame.css" rel="stylesheet" type="text/css" />
    
</head>
<body>
    <form id="form1" runat="server">
    <div class="NavigationName">
        个人业务->购卡查询</div>
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

            <script runat="server">public override void ErrorMsgShow() { ErrorMsgHelper(bulMsgShow); }</script>

            <asp:BulletedList ID="bulMsgShow" runat="server" />
            <div class="Content">
                <div id="Content1" class="ContentModule">
                    <div class="Head">
                        查询方式</div>
                    <div class="IIRe">
                        <table class="tb" border="0" cellpadding="0" cellspacing="0">
                            <tr>
                                <td align="right">
                                    查询对象:
                                </td>
                                <td>
                                    <asp:DropDownList ID="ddlSO" CssClass="inputmidder" runat="server" Width="150" OnSelectedIndexChanged="ddlSO_SelectedIndexChanged"
                                        AutoPostBack="true">
                                        <asp:ListItem Value="0">单位</asp:ListItem>
                                        <asp:ListItem Value="1">个人</asp:ListItem>
                                    </asp:DropDownList>
                                </td>
                                <td align="right">
                                    购卡起始日期:
                                </td>
                                <td>
                                    <ajaxToolkit:CalendarExtender ID="BeginCalendar" runat="server" TargetControlID="txtStartDate"
                                        Format="yyyyMMdd" PopupPosition="BottomLeft" />
                                    <asp:TextBox ID="txtStartDate" runat="server" CssClass="input" Width="150" MaxLength="8"></asp:TextBox>
                                </td>
                                <td align="right">
                                    购卡终止日期:
                                </td>
                                <td>
                                    <asp:TextBox ID="txtEndDate" runat="server" CssClass="input" Width="150" MaxLength="8"></asp:TextBox>
                                    <ajaxToolkit:CalendarExtender ID="CalendarExtender2" runat="server" TargetControlID="txtEndDate"
                                        Format="yyyyMMdd" PopupPosition="BottomLeft" />
                                </td>
                            </tr>
                            <tr id="indiInfo" runat="server" visible="false">
                                <td align="right">
                                    姓名:
                                </td>
                                <td>
                                    <asp:TextBox ID="txtName" runat="server" CssClass="input" Width="150"></asp:TextBox>
                                </td>
                                <td align="right">
                                    身份证号:
                                </td>
                                <td>
                                    <asp:TextBox ID="txtID" runat="server" CssClass="input" Width="150"></asp:TextBox>
                                </td>
                                <td>
                                </td>
                                <td>
                                </td>
                            </tr>
                            <tr id="deptInfo1" runat="server">
                                <td align="right">
                                    单位名称:
                                </td>
                                <td>
                                    <asp:TextBox ID="txtDeptName" runat="server" CssClass="input" Width="150"></asp:TextBox>
                                </td>
                                <td align="right">
                                    单位证件号:
                                </td>
                                <td>
                                    <asp:TextBox ID="txtDeptID" runat="server" CssClass="input" Width="150"></asp:TextBox>
                                </td>
                                <td align="right">
                                    单位经办人姓名:
                                </td>
                                <td>
                                    <asp:TextBox ID="txtManaName" runat="server" CssClass="input" Width="150"></asp:TextBox>
                                </td>
                            </tr>
                            <tr id="deptInfo2" runat="server">
                                <td align="right">
                                    单位经办人证件号:
                                </td>
                                <td>
                                    <asp:TextBox ID="txtManaID" runat="server" CssClass="input" Width="150"></asp:TextBox>
                                </td>
                                <td colspan="4">
                                </td>
                            </tr>
                            <tr>
                                <td colspan="6" align="right">
                                    <asp:Button ID="btnQuery" runat="server" Text="查询" CssClass="button1" OnClick="btnQuery_Click" />
                                </td>
                            </tr>
                        </table>
                    </div>
                </div>
                <div id="Content2" class="ContentModule" style="margin-bottom: 5px;">
                    <div class="Head">
                        购卡信息</div>
                    <div class="IIRe">
                        <div class="GVLayOut">
                            <asp:GridView ID="gvResult" runat="server" CssClass="tab1" Width="2000" HeaderStyle-CssClass="tabbt"
                                AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel" AllowPaging="True"
                                PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top"
                                AutoGenerateColumns="False" OnPageIndexChanging="gvResult_Page" PageSize="15">
                                <Columns>
                                    <asp:BoundField DataField="COMPANYNAME" HeaderText="单位名称" />
                                    <asp:BoundField DataField="COMPANYPAPERTYPE" HeaderText="单位证件类型" />
                                    <asp:BoundField DataField="COMPANYPAPERNO" HeaderText="单位证件号码" />
                                    <asp:BoundField DataField="NAME" HeaderText="经办人姓名" />
                                    <asp:BoundField DataField="PAPERTYPE" HeaderText="经办人证件类型" />
                                    <asp:BoundField DataField="PAPERNO" HeaderText="经办人证件号码" />
                                    <asp:BoundField DataField="PHONENO" HeaderText="联系电话" />
                                    <asp:BoundField DataField="ADDRESS" HeaderText="联系地址" />
                                    <asp:BoundField DataField="EMAIL" HeaderText="EMAIL" />
                                    <asp:BoundField DataField="OUTBANK" HeaderText="转出银行" />
                                    <asp:BoundField DataField="OUTACCT" HeaderText="转出账户" />
                                    <asp:BoundField DataField="STARTCARDNO" HeaderText="起始卡号" />
                                    <asp:BoundField DataField="ENDCARDNO" HeaderText="结束卡号" />
                                    <asp:BoundField DataField="BUYCARDDATE" HeaderText="购卡日期" DataFormatString="{0:yyyy-MM-dd}"
                                        HtmlEncode="False" />
                                    <asp:BoundField DataField="BUYCARDNUM" HeaderText="购卡数量" />
                                    <asp:BoundField DataField="BUYCARDMONEY" HeaderText="购卡金额" />
                                    <asp:BoundField DataField="CHARGEMONEY" HeaderText="充值金额" />
                                    <asp:BoundField DataField="REMARK" HeaderText="备注" />
                                </Columns>
                                <EmptyDataTemplate>
                                    <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                        <tr class="tabbt">
                                            <td>
                                                单位名称
                                            </td>
                                            <td>
                                                单位证件类型
                                            </td>
                                            <td>
                                                单位证件号码
                                            </td>
                                            <td>
                                                经办人姓名
                                            </td>
                                            <td>
                                                经办人证件类型
                                            </td>
                                            <td>
                                                经办人证件号码
                                            </td>
                                            <td>
                                                联系电话
                                            </td>
                                            <td>
                                                联系地址
                                            </td>
                                            <td>
                                                EMAIL
                                            </td>
                                            <td>
                                                转出银行
                                            </td>
                                            <td>
                                                转出账户
                                            </td>
                                            <td>
                                                购买卡号/卡号段
                                            </td>
                                            <td>
                                                购卡日期
                                            </td>
                                            <td>
                                                购卡数量
                                            </td>
                                            <td>
                                                购卡金额
                                            </td>
                                            <td>
                                                充值金额
                                            </td>
                                            <td>
                                                备注
                                            </td>
                                        </tr>
                                    </table>
                                </EmptyDataTemplate>
                            </asp:GridView>
                            <asp:GridView Visible="false" ID="gvResultindiInfo" runat="server" Width="2000" CssClass="tab1"
                                HeaderStyle-CssClass="tabbt" AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel"
                                AllowPaging="True" PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left"
                                PagerStyle-VerticalAlign="Top" AutoGenerateColumns="False" PageSize="15" OnPageIndexChanging="gvResult_Page">
                                <Columns>
                                    <asp:BoundField DataField="NAME" HeaderText="姓名" />
                                    <asp:BoundField DataField="BIRTHDAY" HeaderText="出生日期" />
                                    <asp:BoundField DataField="PAPERTYPE" HeaderText="证件类型" />
                                    <asp:BoundField DataField="PAPERNO" HeaderText="证件号码" />
                                    <asp:BoundField DataField="SEX" HeaderText="性别" />
                                    <asp:BoundField DataField="PHONENO" HeaderText="联系电话" />
                                    <asp:BoundField DataField="ADDRESS" HeaderText="联系地址" />
                                    <asp:BoundField DataField="EMAIL" HeaderText="EMAIL" />
                                    <asp:BoundField DataField="STARTCARDNO" HeaderText="起始卡号" />
                                    <asp:BoundField DataField="ENDCARDNO" HeaderText="结束卡号" />
                                    <asp:BoundField DataField="BUYCARDDATE" HeaderText="购卡日期" DataFormatString="{0:yyyy-MM-dd}"
                                        HtmlEncode="False" />
                                    <asp:BoundField DataField="BUYCARDNUM" HeaderText="购卡数量" />
                                    <asp:BoundField DataField="BUYCARDMONEY" HeaderText="购卡金额" />
                                    <asp:BoundField DataField="CHARGEMONEY" HeaderText="充值金额" />
                                    <asp:BoundField DataField="REMARK" HeaderText="备注" />
                                </Columns>
                                <EmptyDataTemplate>
                                    <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                        <tr class="tabbt">
                                            <td>
                                                姓名
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
                                                性别
                                            </td>
                                            <td>
                                                联系电话
                                            </td>
                                            <td>
                                                联系地址
                                            </td>
                                            <td>
                                                EMAIL
                                            </td>
                                            <td>
                                                购买卡号/卡号段
                                            </td>
                                            <td>
                                                购卡日期
                                            </td>
                                            <td>
                                                购卡数量
                                            </td>
                                            <td>
                                                购卡金额
                                            </td>
                                            <td>
                                                充值金额
                                            </td>
                                            <td>
                                                备注
                                            </td>
                                        </tr>
                                    </table>
                                </EmptyDataTemplate>
                            </asp:GridView>
                        </div>
                    </div>
                </div>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
    </form>
</body>
</html>

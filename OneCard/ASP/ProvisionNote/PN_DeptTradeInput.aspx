<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PN_DeptTradeInput.aspx.cs"
    Inherits="ASP_ProvisionNote_PN_DeptTradeInput" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>网点代办业务录入</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
    <div class="tb">
        备付金管理->网点代办业务录入
    </div>
    <ajaxToolkit:ToolkitScriptManager EnableScriptGlobalization="true" EnableScriptLocalization="true"
        ID="ScriptManager1" runat="server" />
    <asp:UpdatePanel ID="UpdatePanel1" UpdateMode="Conditional" runat="server">
        <ContentTemplate>
            <asp:BulletedList ID="bulMsgShow" runat="server" />
            <script runat="server">public override void ErrorMsgShow() { ErrorMsgHelper(bulMsgShow); }</script>
            <div class="con" width="95%">
                <div class="card">
                    查询</div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td>
                                <div align="right">
                                    日期:</div>
                            </td>
                            <td>
                                <asp:TextBox runat="server" ID="txtSelDate" MaxLength="8" CssClass="input"></asp:TextBox>
                                <ajaxToolkit:CalendarExtender ID="CalendarExtender1" runat="server" TargetControlID="txtSelDate"
                                    Format="yyyyMMdd" />
                            </td>
                            <td>
                                <div align="right">
                                    业务类型:</div>
                            </td>
                            <td>
                                <asp:DropDownList ID="selTradeIn" CssClass="inputmid" runat="server">
                                    <asp:ListItem Text="---请选择---" Value=""></asp:ListItem>
                                    <asp:ListItem Text="公共自行车开通" Value="01"></asp:ListItem>
                                    <asp:ListItem Text="吴江旅游年卡" Value="02"></asp:ListItem>
                                    <asp:ListItem Text="苏州乐园门票" Value="03"></asp:ListItem>
                                    <asp:ListItem Text="A卡业务" Value="04"></asp:ListItem>
                                    <asp:ListItem Text="其他" Value="99"></asp:ListItem>
                                </asp:DropDownList>
                            </td>
                            <td>
                                <div align="right">
                                    部门名称:</div>
                            </td>
                            <td>
                                <asp:DropDownList ID="selDept" CssClass="inputmid" runat="server">
                                </asp:DropDownList>
                            </td>
                            <td>
                                <asp:Button runat="server" CssClass="button1" ID="btnQuery" Text="查询" OnClick="btnQuery_Click" />
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
                        <td align="right">
                        </td>
                    </tr>
                </table>
                <asp:HiddenField ID="hidTradeId" runat="server" />
                <div id="printarea" class="kuang5">
                    <div id="gdtbfix" style="height: 250px">
                        <asp:GridView ID="gvResult" runat="server" Width="95%" CssClass="tab1" HeaderStyle-CssClass="tabbt"
                            AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel" AutoGenerateColumns="false"
                            OnSelectedIndexChanged="gvResult_SelectedIndexChanged" OnRowCreated="gvResult_RowCreated"
                            OnRowDataBound="gvResult_RowDataBound">
                            <Columns>
                                <asp:BoundField HeaderText="业务流水号" DataField="业务流水号" />
                                <asp:BoundField HeaderText="业务类型" DataField="业务类型" />
                                <asp:BoundField HeaderText="交易金额" DataField="交易金额" />
                                <asp:BoundField HeaderText="操作部门" DataField="操作部门" />
                                <asp:BoundField HeaderText="更新员工" DataField="更新员工" />
                                <asp:BoundField HeaderText="更新时间" DataField="更新时间" />
                                <asp:BoundField HeaderText="备注" DataField="REMARK" />
                                <asp:BoundField HeaderText="更新时间" DataField="OPERATETIME" />
                                <asp:BoundField HeaderText="业务类型" DataField="TRADETYPECODE" />
                            </Columns>
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                        <td>
                                            业务流水号
                                        </td>
                                        <td>
                                            业务类型
                                        </td>
                                        <td>
                                            交易金额
                                        </td>
                                        <td>
                                            操作部门
                                        </td>
                                        <td>
                                            更新员工
                                        </td>
                                        <td>
                                            更新时间
                                        </td>
                                        <td>
                                            网上业务
                                        </td>
                                    </tr>
                                </table>
                            </EmptyDataTemplate>
                        </asp:GridView>
                    </div>
                </div>
                <div class="base">
                    网点代办业务录入</div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td>
                                <div align="right">
                                    日期:</div>
                            </td>
                            <td>
                                <asp:TextBox ID="txtDate" CssClass="inputmid" runat="server"></asp:TextBox>
                                <ajaxToolkit:CalendarExtender ID="FCalendar1" runat="server" TargetControlID="txtDate"
                                    Format="yyyyMMdd" PopupPosition="TopLeft" />
                            </td>
                            <td>
                                <div align="right">
                                    金额:</div>
                            </td>
                            <td>
                                <asp:TextBox ID="txtMoney" CssClass="inputmid" runat="server"></asp:TextBox>
                            </td>
                            <td>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    业务类型:</div>
                            </td>
                            <td>
                                <asp:DropDownList ID="selTradeType" CssClass="inputmid" runat="server">
                                    <asp:ListItem Text="公共自行车开通" Value="01"></asp:ListItem>
                                    <asp:ListItem Text="吴江旅游年卡" Value="02"></asp:ListItem>
                                    <asp:ListItem Text="苏州乐园门票" Value="03"></asp:ListItem>
                                    <asp:ListItem Text="A卡业务" Value="04"></asp:ListItem>
                                    <asp:ListItem Text="其他" Value="99"></asp:ListItem>
                                </asp:DropDownList>
                            </td>
                            <td>
                                <div align="right">
                                    备注:</div>
                            </td>
                            <td>
                                <asp:TextBox ID="txtRemark" CssClass="inputlong" runat="server" Height="50px" 
                                    Width="250px" TextMode="MultiLine" MaxLength="500"></asp:TextBox>
                            </td>
                        </tr>
                    </table>
                </div>
                <div class="footall">
                </div>
                <div class="btns">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0">
                        <tr>
                            <td width="70%">
                                &nbsp;
                            </td>
                            <td align="right">
                            </td>
                            <td align="right">
                                <asp:Button ID="btnSubmit" CssClass="button1" runat="server" Text="新增" OnClick="btnSubmit_Click" />
                            </td>
                            <td align="right">
                                <asp:Button ID="Button1" CssClass="button1" runat="server" Text="删除" OnClick="btnDelete_Click" />
                            </td>
                        </tr>
                    </table>
                </div>
        </ContentTemplate>
    </asp:UpdatePanel>
    </form>
</body>
</html>

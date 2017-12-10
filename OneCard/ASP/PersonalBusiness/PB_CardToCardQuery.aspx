<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PB_CardToCardQuery.aspx.cs"
    Inherits="ASP_PersonalBusiness_PB_CardToCardQuery" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>卡卡转账查询</title>
    <script type="text/javascript" src="../../js/myext.js"></script>
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
    <div class="tb">
        个人业务->卡卡转账查询</div>
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
            <div id="ErrorMessage">
            </div>
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
                                    卡号:</div>
                            </td>
                            <td width="15%">
                                <asp:TextBox ID="txtCardNo" runat="server" CssClass="input" MaxLength="16"></asp:TextBox>
                            </td>
                            <td width="15%">
                                <div align="right">
                                    业务类型:</div>
                            </td>
                            <td width="15%">
                                <asp:DropDownList ID="selTradeType" CssClass="input" runat="server" AutoPostBack="true" OnSelectedIndexChanged="selTradeType_change">
                                    <asp:ListItem Text="0: 圈提" Value="0"></asp:ListItem>
                                    <asp:ListItem Text="1: 圈存" Value="1"></asp:ListItem>
                                </asp:DropDownList>                                
                            </td>
                            <td width="15%">
                                <div align="right">
                                    转账状态:</div>
                            </td>
                            <td width="15%">
                                <asp:DropDownList ID="selTranstate" CssClass="input" runat="server">
                                    <asp:ListItem Text="--请选择--" Value=""></asp:ListItem>
                                    <asp:ListItem Text="0: 圈提待转账" Value="0"></asp:ListItem>
                                    <asp:ListItem Text="1: 已圈存" Value="1"></asp:ListItem>
                                </asp:DropDownList>
                            </td>
                        </tr>
                        <tr>
                            <td width="15%">
                                <div align="right">
                                    起始日期:</div>
                            </td>
                            <td width="15%">
                                    <ajaxToolkit:CalendarExtender ID="BeginCalendar" runat="server" TargetControlID="txtStartDate"
                                        Format="yyyyMMdd" PopupPosition="BottomLeft" />
                                    <asp:TextBox ID="txtStartDate" runat="server" CssClass="input"  MaxLength="8"></asp:TextBox>
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
                            <td width="15%">
                            </td>
                            <td width="15%">
                                <asp:Button ID="btnQuery" runat="server" Text="查询" CssClass="button1" OnClick="btnQuery_Click" />
                            </td>
                        </tr>
                    </table>
                </div>
                <div class="jieguo">
                    卡卡转账记录</div>
                <div class="kuang5">
                    <div id="gdtb" style="height: 300px">
                        <asp:GridView ID="lvwloadOutQuery" runat="server" Width="200%" CssClass="tab1" HeaderStyle-CssClass="tabbt"
                            AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel" 
                            PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left"
                            PagerStyle-VerticalAlign="Top" AutoGenerateColumns="false" 
                            OnRowDataBound="lvwloadOutQuery_RowDataBound" Visible="true" ShowFooter="true">
                            <Columns>
                                <asp:BoundField DataField="OUTCARDNO"  HeaderText="圈提卡号" />
                                <asp:BoundField DataField="INCARDNO"   HeaderText="圈存卡号" />
                                <asp:BoundField DataField="MONEY"      HeaderText="圈提金额" />
                                <asp:BoundField DataField="OUTTIME"    HeaderText="圈提时间" />
                                <asp:BoundField DataField="OUTSTAFFNO" HeaderText="圈提员工" />
                                <asp:BoundField DataField="OUTDEPTNO"  HeaderText="圈提部门" />
                                <asp:BoundField DataField="INTIME"     HeaderText="圈存时间" />
                                <asp:BoundField DataField="INSTAFFNO"  HeaderText="圈存员工" />
                                <asp:BoundField DataField="INDEPTNO"   HeaderText="圈存部门" />
                                <asp:BoundField DataField="REMARK"     HeaderText="备注"     />
                                <asp:BoundField DataField="TRANSTATE"  HeaderText="转账状态" />
                            </Columns>
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                        <td>
                                            圈提卡号
                                        </td>
                                        <td>
                                            圈存卡号
                                        </td>
                                        <td>
                                            圈提金额
                                        </td>
                                        <td>
                                            圈提时间
                                        </td>
                                        <td>
                                            圈提员工
                                        </td>
                                        <td>
                                            圈提部门
                                        </td>
                                        <td>
                                            圈存时间
                                        </td>
                                        <td>
                                            圈存员工
                                        </td>
                                        <td>
                                            圈存部门
                                        </td>
                                        <td>
                                            备注
                                        </td>
                                        <td>
                                            转账状态
                                        </td>
                                    </tr>
                                    </table>
                            </EmptyDataTemplate>
                        </asp:GridView>

                        <asp:GridView ID="lvwloadInQuery" runat="server" Width="150%" CssClass="tab1" HeaderStyle-CssClass="tabbt"
                            AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel"  
                            PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left"
                            PagerStyle-VerticalAlign="Top" AutoGenerateColumns="false" 
                            OnRowDataBound="lvwloadInQuery_RowDataBound" Visible="false" ShowFooter="true">
                            <Columns>
                                <asp:BoundField DataField="OUTCARDNO"  HeaderText="圈提卡号" />
                                <asp:BoundField DataField="INCARDNO"   HeaderText="圈存卡号" />
                                <asp:BoundField DataField="MONEY"      HeaderText="圈存金额" />                                
                                <asp:BoundField DataField="INTIME"     HeaderText="圈存时间" />
                                <asp:BoundField DataField="INSTAFFNO"  HeaderText="圈存员工" />
                                <asp:BoundField DataField="INDEPTNO"   HeaderText="圈存部门" />
                                <asp:BoundField DataField="REMARK"     HeaderText="备注"     />
                                <asp:BoundField DataField="TRANSTATE"  HeaderText="转账状态" />
                            </Columns>
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                        <td>
                                            圈提卡号
                                        </td>
                                        <td>
                                            圈存卡号
                                        </td>
                                        <td>
                                            圈存金额
                                        </td>                                        
                                        <td>
                                            圈存时间
                                        </td>
                                        <td>
                                            圈存员工
                                        </td>
                                        <td>
                                            圈存部门
                                        </td>
                                        <td>
                                            备注
                                        </td>
                                        <td>
                                            转账状态
                                        </td>   
                                    </tr>
                                    </table>
                            </EmptyDataTemplate>
                        </asp:GridView>
                    </div>
                </div>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
    </form>
</body>
</html>

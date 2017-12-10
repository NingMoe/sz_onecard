<%@ Page Language="C#" AutoEventWireup="true" CodeFile="FI_GroupBusinessMark.aspx.cs"
    Inherits="ASP_PersonalBusiness_FI_GroupBusinessMark" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>团购业务录入</title>
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="../../js/myext.js"></script>
    <script type="text/javascript" src="../../js/mootools.js"></script>
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
        管理报表->团购业务录入
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
    <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
            <asp:BulletedList ID="bulMsgShow" runat="server" />
            <script runat="server">public override void ErrorMsgShow() { ErrorMsgHelper(bulMsgShow); }</script>
            <div class="con">
                <div class="card">
                    查询</div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td style="width: 100px;">
                                <div align="right">
                                    业务类型:</div>
                            </td>
                            <td>
                                <asp:DropDownList ID="selTradeType" CssClass="inputmid" runat="server">
                                </asp:DropDownList>
                            </td>
                            <td style="width: 100px;">
                                <div align="right">
                                    卡号:</div>
                            </td>
                            <td >
        <asp:TextBox ID="txtCardno" CssClass="input" runat="server" MaxLength="16"/>
                            </td>
                             <td align="right" >
                                <asp:Button ID="btnQuery" CssClass="button1" runat="server" Text="查询" OnClick="btnQuery_Click" />
                            </td>
                        </tr>
                    </table>
                </div>
                <asp:HiddenField ID="hidTradeIDs" runat="server" />
                <div style="width: 99%; background-color: #ddddff; border: 1px solid #aaaaff; margin-top: 5px;
                    margin-left: 5px;" id="Div1">
                    <div class="jieguo">
                        查询结果</div>
                    <div class="kuang5">
                        <div class="gdtb" style="height: 300px; overflow: auto;">
                            <asp:GridView ID="gvResult" runat="server" Width="95%" CssClass="tab2" 
                            HeaderStyle-CssClass="tabbt"
                                FooterStyle-CssClass="tabcon" 
                                AlternatingRowStyle-CssClass="tabjg" 
                                SelectedRowStyle-CssClass="tabsel"
                                PagerSettings-Mode="NumericFirstLast" 
                                PagerStyle-HorizontalAlign="left" 
                                PagerStyle-VerticalAlign="Top"
                                AutoGenerateColumns="false" 
                                ShowFooter="true" 
                                OnRowDataBound="gvResult_RowDataBound"
                                PageSize="100" 
                                AllowPaging="True"
                                OnPageIndexChanging="gvResult_PageIndexChanging">
                                <Columns>
                                    <asp:TemplateField>
                                        <HeaderTemplate>
                                            <asp:CheckBox ID="chkAll" runat="server" onclick="SelectAll(this);" />
                                        </HeaderTemplate>
                                        <ItemTemplate>
                                            <asp:CheckBox ID="chkTradeList" runat="server" />
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:BoundField DataField="TRADEID" HeaderText="TRADEID" />
                                    <asp:BoundField DataField="卡号" HeaderText="卡号" />
                                    <asp:BoundField DataField="交易类型" HeaderText="交易类型" />
                                    <asp:BoundField DataField="卡服务费" HeaderText="卡服务费" />
                                    <asp:BoundField DataField="卡押金" HeaderText="卡押金" />
                                    <asp:BoundField DataField="充值" HeaderText="充值" />
                                    <asp:BoundField DataField="手续费" HeaderText="手续费" />
                                    <asp:BoundField DataField="功能费" HeaderText="功能费" />
                                    <asp:BoundField DataField="其它费" HeaderText="其它费" />
                                    <asp:BoundField DataField="交易时间" HeaderText="交易时间" />
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
                                                交易类型
                                            </td>
                                            <td>
                                                卡服务费
                                            </td>
                                            <td>
                                                卡押金
                                            </td>
                                            <td>
                                                充值
                                            </td>
                                            <td>
                                                手续费
                                            </td>
                                            <td>
                                                功能费
                                            </td>
                                            <td>
                                                其它费
                                            </td>
                                            <td>
                                                交易时间
                                            </td>
                                        </tr>
                                    </table>
                                </EmptyDataTemplate>
                            </asp:GridView>
                        </div>
                    </div>
                </div>
            </div>
            <div class="kuang5">
                <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                    <tr>
                        <td width="9%">
                            <div align="right">
                                团购商家:</div>
                        </td>
                        <td style="height: 37px">
                            <asp:DropDownList ID="selShop" CssClass="inputmid" runat="server">
                            </asp:DropDownList>
                            <span style="color: Red">*</span>
                        </td>
                        <td width="15%">
                            <div align="right">
                                团购劵号:</div>
                        </td>
                        <td style="height: 37px">
                            <asp:TextBox ID="txtGroupBuyNO" runat="server" CssClass="input" MaxLength="30" Width="150px"></asp:TextBox>
                            <span style="color: Red">*</span>
                        </td>
                        <td>
                        </td>
                    </tr>
                    <tr>
                        <td width="12%">
                            <div align="right">
                                备注:</div>
                        </td>
                        <td style="height: 37px" colspan="3">
                            <asp:TextBox ID="txtComment" runat="server" CssClass="inputmax" MaxLength="200"></asp:TextBox>
                        </td>
                        <td align="right">
                            <asp:Button ID="btnAdd" runat="server" Text="录入" CssClass="button1" OnClick="btnAdd_Click" />
                        </td>
                    </tr>
                </table>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
    </form>
</body>
</html>

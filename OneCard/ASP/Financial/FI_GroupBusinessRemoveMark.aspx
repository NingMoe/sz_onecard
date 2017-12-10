<%@ Page Language="C#" AutoEventWireup="true" CodeFile="FI_GroupBusinessRemoveMark.aspx.cs"
    EnableEventValidation="false" Inherits="ASP_Financial_FI_GroupBusinessRemoveMark" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>团购业务录入取消</title>
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="../../js/myext.js"></script>
    <script type="text/javascript" src="../../js/mootools.js"></script>
    <script type="text/javascript" src="../../js/jquery-1.5.min.js"></script>
    <script type="text/javascript">
        function SelectAll(tempControl) {

            var theBo
            x = tempControl;
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
        管理报表->团购业务录入取消
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
                          <td>
                                <div align="right">
                                    团购商家:</div>
                            </td>
                            <td>
                                <asp:DropDownList ID="selShop" CssClass="input" runat="server">
                                </asp:DropDownList>
                            </td>
                            <td>
                                <div align="right">
                                    部门:</div>
                            </td>
                            <td>
                                <asp:DropDownList ID="selDept" CssClass="inputmid" runat="server" AutoPostBack="true"
                                    OnSelectedIndexChanged="selDept_Changed">
                                </asp:DropDownList>
                            </td>
                            <td>
                                <div align="right">
                                    员工:</div>
                            </td>
                            <td>
                                <asp:DropDownList ID="selStaff" CssClass="inputmid" runat="server">
                                </asp:DropDownList>
                            </td>
                            
                           
                        </tr>
                        <tr>
                          <td>
                                <div align="right">
                                    团购劵号:</div>
                            </td>
                            <td>
                                <asp:TextBox runat="server" ID="txtGroupBuyNo" MaxLength="30" CssClass="input"></asp:TextBox>
                            </td>
                              <td>
                            </td>
                            <td align="right" colspan='3'>
                                <asp:Button ID="btnQuery" CssClass="button1" runat="server" Text="查询" OnClick="btnQuery_Click" />
                            </td>
                           
                        </tr>
                    </table>
                </div>
                <asp:HiddenField ID="hidTradeIDs" runat="server" />
                <div style="width: 99%; background-color: #ddddff; border: 1px solid #aaaaff; margin-top: 5px;
                    margin-left: 5px;" id="divResult">
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
                                AllowPaging="True"
                                PageSize="20" 
                                OnRowCreated="gvResult_RowCreated"
                                OnPageIndexChanging="gvResult_PageIndexChanging"
                                OnSelectedIndexChanged="gvResult_SelectedIndexChanged">
                                <Columns>
                                    <asp:TemplateField>
                                        <HeaderTemplate>
                                            <asp:CheckBox ID="chkAll" runat="server" onclick="SelectAll(this);" />
                                        </HeaderTemplate>
                                        <ItemTemplate>
                                            <asp:CheckBox ID="chkGroupBuyCodeList" runat="server" />
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:BoundField DataField="团购劵号" HeaderText="团购劵号" />
                                    <asp:BoundField DataField="团购商家" HeaderText="团购商家" />
                                    <asp:BoundField DataField="操作人" HeaderText="操作人" />
                                    <asp:BoundField DataField="操作部门" HeaderText="操作部门" />
                                    <asp:BoundField DataField="操作时间" HeaderText="操作时间" />
                                    <asp:BoundField DataField="备注" HeaderText="备注" />
                                </Columns>
                                <EmptyDataTemplate>
                                    <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                        <tr class="tabbt">
                                            <td>
                                                <input type="checkbox" />
                                            </td>
                                            <td>
                                                团购劵号
                                            </td>
                                            <td>
                                                团购商家
                                            </td>
                                            <td>
                                                操作人
                                            </td>
                                            <td>
                                                操作部门
                                            </td>
                                            <td>
                                                操作时间
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
            <div class="kuang5">
                <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                    <tr>
                        <td>
                            <div align="right">
                            </div>
                        </td>
                        <td>
                            &nbsp;
                        </td>
                        <td colspan="4">
                            <table width="300" border="0" align="right" cellpadding="0" cellspacing="0">
                                <tr>
                                    <td align="right" colspan='5'>
                                        <asp:Button ID="btnRemove" runat="server" Text="取消录入" CssClass="button1" OnClick="btnRemove_Click" />
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                </table>
            </div>
            <div style="width: 99%; background-color: #ddddff; border: 1px solid #aaaaff; margin-top: 5px;
                margin-left: 5px;" id="divList">
                <div class="jieguo">
                    关联业务</div>
                <div class="kuang5">
                    <div class="gdtb" style="height: 300px; overflow: auto;">
                        <asp:GridView ID="gvList" runat="server" Width="95%" CssClass="tab2" 
                            HeaderStyle-CssClass="tabbt"
                            FooterStyle-CssClass="tabcon" 
                            AlternatingRowStyle-CssClass="tabjg" 
                            SelectedRowStyle-CssClass="tabsel"
                            PagerSettings-Mode="NumericFirstLast" 
                            PagerStyle-HorizontalAlign="left" 
                            PagerStyle-VerticalAlign="Top"
                            AutoGenerateColumns="false" 
                            ShowFooter="true" >
                            <Columns>
                                <asp:BoundField DataField="部门" HeaderText="部门" />
                                <asp:BoundField DataField="营业员" HeaderText="营业员" />
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
                                            部门
                                        </td>
                                        <td>
                                            营业员
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
        </ContentTemplate>
    </asp:UpdatePanel>
    </form>
</body>
</html>

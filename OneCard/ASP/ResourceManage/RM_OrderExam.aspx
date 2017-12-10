<%@ Page Language="C#" AutoEventWireup="true" CodeFile="RM_OrderExam.aspx.cs" Inherits="ASP_ResourceManage_RM_OrderExam"
    EnableEventValidation="false" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>下单审核</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="../../js/myext.js"></script>
    <script type="text/javascript" src="../../js/RMHelper.js"></script>
    <script type="text/javascript" language="javascript">
        function SelectUseCard() {
            $get('hidCardType').value = "usecard";

            //提交部分，显示存货补货，其他隐藏
            //supplyUseCard.style.display = "block";
            //supplyChargeCard.style.display = "none";
            //Gridview部分，显示充值卡，其他隐藏
            gvUseCard.style.display = "block";
            gvChargeCard.style.display = "none";

            usecard.className = "on";
            chargecard.className = null;

            return false;
        }
        function SelectChargeCard() {
            $get('hidCardType').value = "chargecard";

            //提交部分，显示充值卡，其他隐藏
            //supplyUseCard.style.display = "none";
            //supplyChargeCard.style.display = "block";
            //Gridview部分，显示充值卡，其他隐藏
            gvUseCard.style.display = "none";
            gvChargeCard.style.display = "block";

            usecard.className = null;
            chargecard.className = "on";

            return false;
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
    <div class="tb">
        卡片管理->下单审核
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
            <asp:HiddenField ID="hidCardType" runat="server" />
            <div style="height: 22px">
                <table>
                    <tr>
                        <td width="10%">
                        </td>
                        <td align="center">
                            <ul class="nav_list">
                                <li runat="server" id="liusecard" visible="true">
                                    <asp:LinkButton ID="usecard" Target="_top" CssClass="on" runat="server" onmouseover="mover(this);"
                                        onmouseout="mout();" OnClientClick="return SelectUseCard()"><span class="signA">用户卡</span></asp:LinkButton></li>
                                <li runat="server" id="lichargecard" visible="true">
                                    <asp:LinkButton ID="chargecard" Target="_top" runat="server" onmouseover="mover(this);"
                                        onmouseout="mout();" OnClientClick="return SelectChargeCard()"><span class="signB">充值卡</span></asp:LinkButton></li>
                            </ul>
                        </td>
                    </tr>
                </table>
            </div>
            <div class="con">
                <div class="card">
                    查询</div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td width="12%">
                                <div align="right">
                                    订购单号:</div>
                            </td>
                            <td width="36%">
                                <asp:TextBox ID="txtOrderID" CssClass="inputmid" MaxLength="18" runat="server">
                                </asp:TextBox>
                            </td>
                            <td width="12%">
                                <div align="right">
                                    审核状态:</div>
                            </td>
                            <td width="12%">
                                <asp:DropDownList ID="selExamState" CssClass="input" runat="server">
                                    <asp:ListItem Text="0: 待审核" Value="0"></asp:ListItem>
                                    <asp:ListItem Text="1: 审核通过" Value="1"></asp:ListItem>
                                    <asp:ListItem Text="2: 审核作废" Value="2"></asp:ListItem>
                                </asp:DropDownList>
                            </td>
                            <td width="12%" align="right">
                                <asp:Button ID="btnQuery" CssClass="button1" runat="server" Text="查询" OnClick="btnQuery_Click" />
                            </td>
                            <td width="12%">
                            </td>
                        </tr>
                    </table>
                </div>
                <div class="jieguo">
                    待审核订购单</div>
                <div class="kuang5">
                    <div id="gvUseCard" style="height: 300px; overflow: auto; display: block">
                        <asp:GridView ID="gvResultUseCard" runat="server" Width="250%" CssClass="tab1" HeaderStyle-CssClass="tabbt"
                            FooterStyle-CssClass="tabcon" AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel"
                            PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top"
                            AutoGenerateColumns="false" OnRowDataBound="gvResult_RowDataBound" PageSize="50"
                            AllowPaging="true" OnPageIndexChanging="gvUseCardOrder_Page">
                            <Columns>
                                <asp:TemplateField>
                                    <HeaderTemplate>
                                        <asp:CheckBox ID="CheckBox1" runat="server" AutoPostBack="true" OnCheckedChanged="CheckAll" />
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                        <asp:CheckBox ID="ItemCheckBox" runat="server" />
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField DataField="CARDORDERID" HeaderText="订购单号" />
                                <asp:BoundField DataField="APPLYORDERID" HeaderText="需求单号" />
                                <asp:BoundField DataField="STATE" HeaderText="审核状态" />
                                <asp:BoundField DataField="CARDORDERTYPE" HeaderText="订购类型" />
                                <asp:BoundField DataField="CARDTYPE" HeaderText="卡片类型" />
                                <asp:BoundField DataField="CARDFACE" HeaderText="卡面类型" />
                                <asp:BoundField DataField="CARDSAMPLECODE" HeaderText="卡样编码" />
                                <asp:BoundField DataField="CARDNUM" HeaderText="订购数量" />
                                <asp:BoundField DataField="REQUIREDATE" HeaderText="要求到货日期" />
                                <asp:BoundField DataField="BEGINCARDNO" HeaderText="起始卡号" />
                                <asp:BoundField DataField="ENDCARDNO" HeaderText="结束卡号" />
                                <asp:BoundField DataField="CARDCHIP" HeaderText="芯片类型" />
                                <asp:BoundField DataField="COSTYPE" HeaderText="COS类型" />
                                <asp:BoundField DataField="MANUNAME" HeaderText="卡片厂商" />
                                <asp:BoundField DataField="APPVERNO" HeaderText="应用版本" />
                                <asp:BoundField DataField="VALIDBEGINDATE" HeaderText="起始有效日期" />
                                <asp:BoundField DataField="VALIDENDDATE" HeaderText="结束有效日期" />
                                <asp:BoundField DataField="ORDERTIME" HeaderText="下单时间" />
                                <asp:BoundField DataField="ORDERSTAFF" HeaderText="下单员工" />
                                <asp:BoundField DataField="EXAMTIME" HeaderText="审核时间" />
                                <asp:BoundField DataField="EXAMSTAFF" HeaderText=" 审核员工" />
                                <asp:BoundField DataField="REMARK" HeaderText="备注" />
                            </Columns>
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                        <td>
                                            <input type="checkbox" />
                                        </td>
                                        <td>
                                            订购单号
                                        </td>
                                        <td>
                                            需求单号
                                        </td>
                                        <td>
                                            审核状态
                                        </td>
                                        <td>
                                            订购类型
                                        </td>
                                        <td>
                                            卡片类型
                                        </td>
                                        <td>
                                            卡面类型
                                        </td>
                                        <td>
                                            卡样编码
                                        </td>
                                        <td>
                                            订购数量
                                        </td>
                                        <td>
                                            要求到货日期
                                        </td>
                                        <td>
                                            起始卡号
                                        </td>
                                        <td>
                                            结束卡号
                                        </td>
                                        <td>
                                            芯片类型
                                        </td>
                                        <td>
                                            COS类型
                                        </td>
                                        <td>
                                            卡片厂商
                                        </td>
                                        <td>
                                            应用版本
                                        </td>
                                        <td>
                                            起始有效日期
                                        </td>
                                        <td>
                                            结束有效日期
                                        </td>
                                        <td>
                                            下单时间
                                        </td>
                                        <td>
                                            下单员工
                                        </td>
                                        <td>
                                            审核时间
                                        </td>
                                        <td>
                                            审核员工
                                        </td>
                                        <td>
                                            备注
                                        </td>
                                    </tr>
                                </table>
                            </EmptyDataTemplate>
                        </asp:GridView>
                    </div>
                    <div id="gvChargeCard" style="height: 300px; overflow: auto; display: none">
                        <asp:GridView ID="gvResultChargeCard" runat="server" Width="200%" CssClass="tab1"
                            HeaderStyle-CssClass="tabbt" FooterStyle-CssClass="tabcon" AlternatingRowStyle-CssClass="tabjg"
                            SelectedRowStyle-CssClass="tabsel" PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left"
                            PagerStyle-VerticalAlign="Top" AutoGenerateColumns="false" OnRowDataBound="gvResult_RowDataBound"
                            PageSize="50" OnPageIndexChanging="gvUseCardOrder_Page" AllowPaging="true">
                            <Columns>
                                <asp:TemplateField>
                                    <HeaderTemplate>
                                        <asp:CheckBox ID="CheckBox1" runat="server" AutoPostBack="true" OnCheckedChanged="CheckAll" />
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                        <asp:CheckBox ID="ItemCheckBox" runat="server" />
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField DataField="CARDORDERID" HeaderText="订购单号" />
                                <asp:BoundField DataField="APPLYORDERID" HeaderText="需求单号" />
                                <asp:BoundField DataField="STATE" HeaderText="审核状态" />
                                <asp:BoundField DataField="VALUECODE" HeaderText="面值" />
                                <asp:BoundField DataField="CARDNUM" HeaderText="订购数量" />
                                <asp:BoundField DataField="CORPNAME" HeaderText="厂商" />
                                <asp:BoundField DataField="VALIDENDDATE" HeaderText="有效期" />
                                <asp:BoundField DataField="REQUIREDATE" HeaderText="要求到货日期" />
                                <asp:BoundField DataField="BEGINCARDNO" HeaderText="起始卡号" />
                                <asp:BoundField DataField="ENDCARDNO" HeaderText="结束卡号" />
                                <asp:BoundField DataField="ORDERTIME" HeaderText="下单时间" />
                                <asp:BoundField DataField="ORDERSTAFF" HeaderText="下单员工" />
                                <asp:BoundField DataField="EXAMTIME" HeaderText="审核时间" />
                                <asp:BoundField DataField="EXAMSTAFF" HeaderText=" 审核员工" />
                                <asp:BoundField DataField="REMARK" HeaderText="备注" />
                            </Columns>
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                        <td>
                                            <input type="checkbox" />
                                        </td>
                                        <td>
                                            订购单号
                                        </td>
                                        <td>
                                            需求单号
                                        </td>
                                        <td>
                                            审核状态
                                        </td>
                                        <td>
                                            面值
                                        </td>
                                        <td>
                                            订购数量
                                        </td>
                                        <td>
                                            厂商
                                        </td>
                                        <td>
                                            有效期
                                        </td>
                                        <td>
                                            要求到货日期
                                        </td>
                                        <td>
                                            起始卡号
                                        </td>
                                        <td>
                                            结束卡号
                                        </td>
                                        <td>
                                            下单时间
                                        </td>
                                        <td>
                                            下单员工
                                        </td>
                                        <td>
                                            审核时间
                                        </td>
                                        <td>
                                            审核员工
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
            <div class="footall">
            </div>
            <div class="btns">
                <table width="200" border="0" align="right" cellpadding="0" cellspacing="0">
                    <tr>
                        <td>
                            <asp:Button ID="btnPass" runat="server" Text="通过" CssClass="button1" Enabled="false"
                                OnClick="btnPass_Click" />
                        </td>
                        <td>
                            <asp:Button ID="btnCancel" runat="server" Text="作废" CssClass="button1" Enabled="false"
                                OnClick="btnCancel_Click" />
                        </td>
                    </tr>
                </table>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
    </form>
</body>
</html>

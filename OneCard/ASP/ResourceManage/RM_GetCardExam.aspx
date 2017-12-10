<%@ Page Language="C#" AutoEventWireup="true" CodeFile="RM_GetCardExam.aspx.cs" Inherits="ASP_ResourceManage_RM_GetCardExam" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>领卡审批</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="../../js/myext.js"></script>
    <script type="text/javascript" src="../../js/RMHelper.js"></script>
    <script type="text/javascript" language="javascript">
        function SelectUseCard() {
            $get('hidCardType').value = "usecard";

            //提交部分，显示存货补货，其他隐藏
//            supplyUseCard.style.display = "block";
//            supplyChargeCard.style.display = "none";
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
//            supplyUseCard.style.display = "none";
//            supplyChargeCard.style.display = "block";
            //Gridview部分，显示充值卡，其他隐藏
            gvUseCard.style.display = "none";
            gvChargeCard.style.display = "block";

            usecard.className = null;
            chargecard.className = "on";

            return false;
        }
        function submitConfirm(checkednum) {

            if (true) {
                MyExtConfirm('确认',
		         checkednum + '是否确认通过？'
		        , submitConfirmCallback);
            }

        }
        function submitConfirmCallback(btn) {
            if (btn == 'yes') {
                $get('btnConfirm').click();
            }
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
    <div class="tb">
        卡片管理->领卡审批
    </div>
    <ajaxToolkit:ToolkitScriptManager EnableScriptGlobalization="true" EnableScriptLocalization="true"
        ID="ScriptManager1" runat="server" />
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
                <div class="base">
                    待审核领用单</div>
                <div class="kuang5">
                    <div id="gvUseCard" style="height: 400px;overflow:auto; display: block">
                        <asp:GridView ID="gvResultUseCard" runat="server" Width="95%" CssClass="tab1" HeaderStyle-CssClass="tabbt"
                            FooterStyle-CssClass="tabcon" AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel"
                            PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top"
                            AutoGenerateColumns="false">
                            <Columns>
                                <asp:TemplateField>
                                    <HeaderTemplate>
                                      <asp:CheckBox ID="CheckBox1" runat="server"  AutoPostBack="true" OnCheckedChanged="CheckAll" />
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                      <asp:CheckBox ID="ItemCheckBox" runat="server"/>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField DataField="getcardorderid" HeaderText="领用单号" />
                                <asp:BoundField DataField="cardtypename" HeaderText="卡片名称" />
                                <asp:BoundField DataField="cardsurfacename" HeaderText="卡面名称" />
                                <asp:BoundField DataField="applygetnum" HeaderText="申请领用数量" />
                                <asp:TemplateField HeaderText="同意领用数量">
                                    <ItemTemplate>
                                        <asp:TextBox ID="txtAgreeGetNum" style="text-align:center" Text='<%# Bind("applygetnum") %>' CssClass="input" runat="server"></asp:TextBox>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField DataField="useway" HeaderText="用途" />
                                <asp:BoundField DataField="ordertime" HeaderText="申请时间" />
                                <asp:BoundField DataField="staffname" HeaderText="申请员工" />
                                <asp:BoundField DataField="departname" HeaderText="申请部门" />
                                <asp:BoundField DataField="remark" HeaderText="备注" />
                            </Columns>
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                        <td>
                                            <input type="checkbox" />
                                        </td>
                                        <td>
                                            领用单号
                                        </td>
                                        <td>
                                            卡片类型
                                        </td>
                                        <td>
                                            卡面类型
                                        </td>
                                        <td>
                                            申请领用数量
                                        </td>
                                        <td>
                                            同意领用数量
                                        </td>
                                        <td>
                                            用途
                                        </td>
                                        <td>
                                            申请时间
                                        </td>
                                        <td>
                                            申请员工
                                        </td>
                                        <td>
                                            申请部门
                                        </td>
                                        <td>
                                            备注
                                        </td>
                                    </tr>
                                </table>
                            </EmptyDataTemplate>
                        </asp:GridView>
                    </div>
                    <div id="gvChargeCard" style="height: 400px;overflow:auto; display: none">
                        <asp:GridView ID="gvResultChargeCard" runat="server" Width="95%" CssClass="tab1"
                            HeaderStyle-CssClass="tabbt" FooterStyle-CssClass="tabcon" AlternatingRowStyle-CssClass="tabjg"
                            SelectedRowStyle-CssClass="tabsel" PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left"
                            PagerStyle-VerticalAlign="Top" AutoGenerateColumns="false">
                            <Columns>
                                <asp:TemplateField>
                                    <HeaderTemplate>
                                      <asp:CheckBox ID="CheckBox1" runat="server"  AutoPostBack="true" OnCheckedChanged="CheckChargeCardAll" />
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                      <asp:CheckBox ID="ItemCheckBox" runat="server"/>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField DataField="getcardorderid" HeaderText="领用单号" />
                                <asp:BoundField DataField="value" HeaderText="面额" />
                                <asp:BoundField DataField="applygetnum" HeaderText="申请领用数量" />
                                <asp:TemplateField HeaderText="同意领用数量">
                                    <ItemTemplate>
                                        <asp:TextBox ID="txtAgreeGetNum" style="text-align:center" Text='<%# Bind("applygetnum") %>' CssClass="input" runat="server"></asp:TextBox>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField DataField="useway" HeaderText="用途" />
                                <asp:BoundField DataField="ordertime" HeaderText="申请时间" />
                                <asp:BoundField DataField="staffname" HeaderText="申请员工" />
                                <asp:BoundField DataField="departname" HeaderText="申请部门" />
                                <asp:BoundField DataField="remark" HeaderText="备注" />
                            </Columns>
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                        <td>
                                            <input type="checkbox" />
                                        </td>
                                        <td>
                                            领用单号
                                        </td>
                                        <td>
                                            面值
                                        </td>
                                        <td>
                                            申请领用数量
                                        </td>
                                        <td>
                                            同意领用数量
                                        </td>
                                        <td>
                                            用途
                                        </td>
                                        <td>
                                            申请时间
                                        </td>
                                        <td>
                                            申请人
                                        </td>
                                        <td>
                                            申请部门
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
                            <asp:LinkButton runat="server" ID="btnConfirm" OnClick="btnPass_Click" />
                            <asp:Button ID="btnPass" runat="server" Text="通过" CssClass="button1" Enabled="true"
                                OnClick="submitConfirm_Click" />
                        </td>
                        <td>
                            <asp:Button ID="btnCancel" runat="server" Text="作废" CssClass="button1" Enabled="true"
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
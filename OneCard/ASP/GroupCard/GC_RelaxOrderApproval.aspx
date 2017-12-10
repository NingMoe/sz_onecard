<%@ Page Language="C#" AutoEventWireup="true" EnableEventValidation="false" CodeFile="GC_RelaxOrderApproval.aspx.cs"
    Inherits="ASP_GroupCard_GC_RelaxOrderApproval" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>休闲订单资料审核</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="../../js/myext.js"></script>
    <script type="text/javascript" src="../../js/mootools.js"></script>
    <script type="text/javascript" src="../../js/jquery-1.5.min.js"></script>
    <script type="text/javascript" src="../../js/Window.js"></script>
    <script type="text/javascript">
        function SelectAll(tempControl) {
            //将除头模板中的其它所有的CheckBox取反 

            var theBox = tempControl;
            xState = theBox.checked;

            elem = theBox.form.elements;
            for (i = 0; i < elem.length; i++)
                if (elem[i].type == "checkbox" && elem[i].id != theBox.id) {
                    if (elem[i].checked != xState)
                        elem[i].click();
                }
    } 
    </script>
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
    </style>
</head>
<body>
    <form id="form1" runat="server">
    <div class="tb">
        休闲订单资料审核
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
            <asp:HiddenField ID="hidShowCheckQuery" runat="server" />
            <asp:HiddenField ID="hidRemind" runat="server" />
            <asp:HiddenField ID="hidApprove" runat="server" />
            <asp:HiddenField ID="hidIndex" runat="server" />
            <div class="con" width="95%">
                <div class="card">
                    订单查询</div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td>
                                <div align="right">
                                    订单类型:</div>
                            </td>
                            <td>
                                <asp:DropDownList ID="selOrderType" CssClass="inputmid" runat="server">
                                    <asp:ListItem Text="新办卡开通" Value="0" />
                                    <asp:ListItem Text="有卡开通" Value="1" />
                                </asp:DropDownList>
                            </td>
                            <td>
                                <div align="right">
                                    订单号:</div>
                            </td>
                            <td>
                                <asp:TextBox runat="server" ID="txtOrderNo" CssClass="inputmid"></asp:TextBox>
                            </td>
                            <td>
                                <div align="right">
                                    开始日期:</div>
                            </td>
                            <td>
                                <asp:TextBox runat="server" ID="txtFromDate" MaxLength="8" CssClass="input"></asp:TextBox>
                                <ajaxToolkit:CalendarExtender ID="FCalendar1" runat="server" TargetControlID="txtFromDate"
                                    Format="yyyyMMdd" />
                            </td>
                            <td>
                                <div align="right">
                                    结束日期:</div>
                            </td>
                            <td>
                                <asp:TextBox runat="server" ID="txtToDate" MaxLength="8" CssClass="input"></asp:TextBox>
                                <ajaxToolkit:CalendarExtender ID="FCalendar2" runat="server" TargetControlID="txtToDate"
                                    Format="yyyyMMdd" />
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    驳回状态:</div>
                            </td>
                            <td>
                                <asp:DropDownList ID="selOrderStates" CssClass="inputmid" runat="server">
                                    <asp:ListItem Text="正常" Value="1" Selected="True" />
                                    <asp:ListItem Text="驳回" Value="0" />
                                </asp:DropDownList>
                            </td>
                            <td>
                                <div align="right">
                                    支付渠道:</div>
                            </td>
                            <td>
                                <asp:DropDownList ID="selPayCanal" CssClass="inputmid" runat="server">
                                    <asp:ListItem Text="---请选择---" Value="" />
                                    <asp:ListItem Text="支付宝" Value="01" />
                                    <asp:ListItem Text="微信" Value="02" />
                                    <asp:ListItem Text="银联" Value="03" />
                                </asp:DropDownList>
                            </td>
                            <td colspan="2">
                            </td>
                            <td align="right">
                            </td>
                            <td>
                                <asp:Button runat="server" CssClass="button1" ID="btnQuery" Text="查询" OnClick="btnQuery_Click" />
                            </td>
                        </tr>
                    </table>
                </div>
            </div>
            <div style="width: 99%; background-color: #ddddff; border: 1px solid #aaaaff; margin-top: 5px;
                margin-left: 5px;" id="supplyUseCard">
                <div class="base">
                    订单列表
                </div>
                <div class="kuang5" style="height: 375px;">
                    <div class="gdtb" style="height: 350px; overflow: auto">
                        <asp:GridView ID="gvOrderList" Width="225%" CssClass="tab1" HeaderStyle-CssClass="tabbt"
                            FooterStyle-CssClass="tabcon" AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel"
                            PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top"
                            runat="server" AutoGenerateColumns="false" OnRowDataBound="gvOrderList_RowDataBound">
                            <Columns>
                                <asp:TemplateField>
                                    <HeaderTemplate>
                                        <asp:CheckBox ID="chkAllOrder" runat="server" onclick="javascript:SelectAll(this);" />
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                        <asp:CheckBox ID="chkOrderList" runat="server" Height="20px" />
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField DataField="ordertype" HeaderText="类型" />
                                <asp:BoundField DataField="detailstates" HeaderText="状态" />
                                <asp:BoundField DataField="cardno" HeaderText="卡号" />
                                <asp:TemplateField>
                                    <HeaderTemplate>
                                        <asp:Label ID="labHeadPhoto" runat="server" Text="人物照片"></asp:Label>
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                        <%--<asp:Image ID="imgPerson" runat="server" Width="60px" Height="60px" ImageUrl="~/Images/nom.jpg" />--%>
                                        <img id="imgPerson" alt="" runat="server" width="60" height="60" imageurl="~/Images/nom.jpg"
                                            onclick="" />
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField>
                                    <HeaderTemplate>
                                        <asp:Label ID="labHeadPaperPhoto" runat="server" Text="身份证照片"></asp:Label>
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                        <%-- <asp:Image ID="imgIDCard" runat="server" Width="60px" Height="60px" ImageUrl="~/Images/nom.jpg" />--%>
                                        <img id="imgIDCard" runat="server" width="60" height="60" imageurl="~/Images/nom.jpg" />
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField DataField="packagetype" HeaderText="套餐类型" />
                                <asp:BoundField DataField="logcustname" HeaderText="收货人" />
                                <asp:BoundField DataField="logaddress" HeaderText="收货地址" />
                                <asp:BoundField DataField="logcustphone" HeaderText="收货号码" />
                                <asp:BoundField DataField="custname" HeaderText="客户姓名" />
                                <asp:BoundField DataField="paperno" HeaderText="证件号码" />
                                <asp:BoundField DataField="custphone" HeaderText="联系电话" />
                                <asp:BoundField DataField="address" HeaderText="地址" />
                                <asp:BoundField DataField="papertypename" HeaderText="证件类型" />
                                <asp:BoundField DataField="custpost" HeaderText="邮编" />
                                <asp:BoundField DataField="custsex" HeaderText="性别" />
                                <asp:BoundField DataField="custbirth" HeaderText="生日" />
                                <asp:BoundField DataField="custemail" HeaderText="邮箱" />
                                <asp:BoundField DataField="orderno" HeaderText="订单号" />
                                <asp:BoundField DataField="paycanal" HeaderText="支付渠道" />
                                <asp:BoundField DataField="orderdetailid" HeaderText="子订单号" />
                                <asp:BoundField DataField="updatetime" HeaderText="更新日期" />
                            </Columns>
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                        <td>
                                            <input type="checkbox" />
                                        </td>
                                        <td>
                                            订单类型
                                        </td>
                                        <td>
                                            订单状态
                                        </td>
                                        <td>
                                            卡号
                                        </td>
                                        <td>
                                            人物照片
                                        </td>
                                        <td>
                                            套餐类型
                                        </td>
                                        <td>
                                            收货人
                                        </td>
                                        <td>
                                            收货地址
                                        </td>
                                        <td>
                                            收货号码
                                        </td>
                                        <td>
                                            客户姓名
                                        </td>
                                        <td>
                                            证件类型
                                        </td>
                                        <td>
                                            地址
                                        </td>
                                        <td>
                                            邮编
                                        </td>
                                        <td>
                                            性别
                                        </td>
                                        <td>
                                            生日
                                        </td>
                                        <td>
                                            邮箱
                                        </td>
                                        <td>
                                            订单号
                                        </td>
                                        <td>
                                            支付渠道
                                        </td>
                                        <td>
                                            子订单号
                                        </td>
                                        <td>
                                            订单日期
                                        </td>
                                    </tr>
                                </table>
                            </EmptyDataTemplate>
                        </asp:GridView>
                    </div>
                    <asp:LinkButton ID="previousLink" runat="server" CommandName="page" OnCommand="Link_Click"
                        Text="上一页" />
                    <asp:LinkButton ID="nextLink" runat="server" CommandName="page" OnCommand="Link_Click"
                        Text="下一页" />
                </div>
            </div>
            <div class="pip">
                备注信息</div>
            <div class="kuang5" style="overflow: auto">
                <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25" align="left">
                    <tr>
                        <td width="10%">
                            <div align="right">
                                驳回原因：</div>
                        </td>
                        <td>
                            <div align="left">
                                <asp:DropDownList ID="selRemark" CssClass="inputmid" runat="server" AutoPostBack="true"
                                    OnSelectedIndexChanged="selRemark_SelectedIndexChanged">
                                    <asp:ListItem Text="---请选择---" Value="" />
                                    <asp:ListItem Text="照片信息模糊" Value="01" />
                                    <asp:ListItem Text="证件信息有误" Value="02" />
                                    <asp:ListItem Text="其他" Value="03" />
                                </asp:DropDownList>
                                <asp:TextBox runat="server" ID="txtRemark" MaxLength="50" CssClass="inputlong" Visible="false"></asp:TextBox>
                            </div>
                        </td>
                        <td width="13%" align="left">
                        </td>
                        <td>
                        </td>
                        <td>
                            <div align="right">
                            </div>
                        </td>
                        <td>
                        </td>
                        <td>
                            <div align="right">
                            </div>
                        </td>
                        <td>
                        </td>
                    </tr>
                </table>
            </div>
            <div class="btns">
                <table width="200px" border="0" align="right" cellpadding="0" cellspacing="0">
                    <tr>
                        <td>
                            <asp:Button ID="btnRollBack" Text="驳 回" CssClass="button1" runat="server" Enabled="false"
                                OnClick="btnRollBack_Click" />
                        </td>
                        <td>
                            <asp:Button ID="btnRevoke" Text="撤销驳回" CssClass="button1" runat="server" Enabled="false"
                                OnClick="btnRevoke_Click" />
                        </td>
                    </tr>
                </table>
            </div>
            <div id="RoleWindow" style="width: 400px;position: absolute; display: none; z-index: 999;">
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
    </form>
</body>
</html>

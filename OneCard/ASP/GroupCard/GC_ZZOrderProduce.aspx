<%@ Page Language="C#" AutoEventWireup="true" EnableEventValidation="false" CodeFile="GC_ZZOrderProduce.aspx.cs"
    Inherits="ASP_GroupCard_GC_ZZOrderProduce" %>

<%@ Register Src="../../CardReader.ascx" TagName="CardReader" TagPrefix="cr" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>休闲订单制卡</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="../../js/myext.js"></script>
    <script type="text/javascript" src="../../js/mootools.js"></script>
    <script type="text/javascript" src="../../js/jquery-1.5.min.js"></script>
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
        table.data {
            font-size: 90%;
            border-collapse: collapse;
            border: 0px solid black;
        }

            table.data th {
                background: #bddeff;
                width: 25em;
                text-align: left;
                padding-right: 8px;
                font-weight: normal;
                border: 1px solid black;
            }

            table.data td {
                background: #ffffff;
                vertical-align: middle;
                padding: 0px 2px 0px 2px;
                border: 1px solid black;
            }
    </style>
</head>
<body>
    <cr:CardReader ID="cardReader" runat="server" />
    <form id="form1" runat="server">
        <div class="tb">
            休闲订单制卡
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
                <asp:HiddenField ID="hidSaletype" runat="server" />
                <div class="con" width="95%">
                    <div class="card">
                        订单查询
                    </div>
                    <div class="kuang5">
                        <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                            <tr>
                                <td>
                                    <div align="right">
                                        支付渠道:
                                    </div>
                                </td>
                                <td>
                                    <asp:DropDownList ID="selPayCanal" CssClass="inputmid" runat="server">
                                        <asp:ListItem Text="---请选择---" Value="" />
                                        <asp:ListItem Text="支付宝" Value="01" />
                                        <asp:ListItem Text="微信" Value="02" />
                                        <asp:ListItem Text="银联" Value="03" />
                                    </asp:DropDownList>
                                </td>
                                <td>
                                    <div align="right">
                                        订单号:
                                    </div>
                                </td>
                                <td>
                                    <asp:TextBox runat="server" ID="txtOrderNo" CssClass="inputmid"></asp:TextBox>
                                </td>
                                <td>
                                    <div align="right">
                                        开始日期:
                                    </div>
                                </td>
                                <td>
                                    <asp:TextBox runat="server" ID="txtFromDate" MaxLength="8" CssClass="input"></asp:TextBox>
                                    <ajaxToolkit:CalendarExtender ID="FCalendar1" runat="server" TargetControlID="txtFromDate"
                                        Format="yyyyMMdd" />
                                </td>
                                <td>
                                    <div align="right">
                                        结束日期:
                                    </div>
                                </td>
                                <td>
                                    <asp:TextBox runat="server" ID="txtToDate" MaxLength="8" CssClass="input"></asp:TextBox>
                                    <ajaxToolkit:CalendarExtender ID="FCalendar2" runat="server" TargetControlID="txtToDate"
                                        Format="yyyyMMdd" />
                                </td>
                            </tr>
                            <tr>
                                <td></td>
                                <td></td>
                                <td></td>
                                <td></td>
                                <td colspan="2"></td>
                                <td align="right"></td>
                                <td>
                                    <asp:Button runat="server" CssClass="button1" ID="btnQuery" Text="查询" OnClick="btnQuery_Click" />
                                </td>
                            </tr>
                        </table>
                    </div>
                </div>
                <div style="width: 99%; background-color: #ddddff; border: 1px solid #aaaaff; margin-top: 5px; margin-left: 5px;"
                    id="supplyUseCard">
                    <div class="base">
                        <table>
                            <tr>
                                <td width="70%">订单列表
                                </td>
                                <td>
                                    <div align="right">
                                        本次制卡卡号:
                                    </div>
                                </td>
                                <td>
                                    <asp:TextBox runat="server" ID="txtCardno" MaxLength="16" CssClass="labeltext"></asp:TextBox>
                                </td>
                            </tr>
                        </table>
                    </div>
                    <asp:HiddenField ID="hidTradeNo" runat="server" />
                    <asp:HiddenField ID="hidOrderCardNo" runat="server" />
                    <asp:HiddenField ID="hidOrderNo" runat="server" />
                    <asp:HiddenField ID="hidDetailNo" runat="server" />
                    <asp:HiddenField ID="hiddencMoney" runat="server" />
                    <asp:HiddenField ID="hiddentradeno" runat="server" />
                    <asp:HiddenField ID="hiddenDepositFee" runat="server" />
                    <asp:HiddenField ID="hiddenCardcostFee" runat="server" />
                    <asp:HiddenField ID="hidOtherFee" runat="server" />
                    <asp:HiddenField ID="hiddenLabCardtype" runat="server" />
                    <asp:HiddenField ID="hiddenAsn" runat="server" />
                    <asp:HiddenField ID="hidcustName" runat="server" />
                    <asp:HiddenField ID="hidpaperType" runat="server" />
                    <asp:HiddenField ID="hidpaperNo" runat="server" />
                    <asp:HiddenField ID="hidcustPhone" runat="server" />
                    <asp:HiddenField ID="hidaddress" runat="server" />
                    <asp:HiddenField ID="hidcustPost" runat="server" />
                    <asp:HiddenField ID="hidcustSex" runat="server" />
                    <asp:HiddenField ID="hidcustBirth" runat="server" />
                    <asp:HiddenField ID="hidcustEmail" runat="server" />
                    <asp:HiddenField runat="server" ID="hidCardnoForCheck" />
                    <asp:HiddenField runat="server" ID="hidSupplyMoney" />
                    <asp:HiddenField runat="server" ID="hiddenSupply" />
                    <asp:HiddenField ID="hidLockBlackCardFlag" runat="server" />
                    <asp:HiddenField ID="hidWarning" runat="server" />
                    <asp:HiddenField ID="hidMoney" runat="server" />
                    <asp:HiddenField runat="server" ID="hidoutTradeid" />
                    <asp:LinkButton runat="server" ID="btnConfirm" OnClick="btnConfirm_Click" />
                    <div class="kuang5" style="height: 375px">
                        <div class="gdtb" style="height: 350px; overflow: auto">
                            <asp:GridView ID="gvOrderList" Width="200%" CssClass="tab1" HeaderStyle-CssClass="tabbt"
                                FooterStyle-CssClass="tabcon" AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel"
                                PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top"
                                runat="server" AutoGenerateColumns="false" OnRowDataBound="gvOrderList_RowDataBound"
                                OnRowCommand="gvOrderList_RowCommand">
                                <Columns>
                                    <asp:TemplateField HeaderStyle-Width="100px">
                                        <HeaderTemplate>
                                            <asp:Label ID="Label1" runat="server" Text="售卡"></asp:Label>
                                        </HeaderTemplate>
                                        <ItemTemplate>
                                            <asp:Button ID="btnProduce" CssClass="button1" runat="server" Text="售卡" CausesValidation="true"
                                                CommandName="Produce" CommandArgument='<%#Container.DataItemIndex%>' />
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderStyle-Width="100px">
                                        <HeaderTemplate>
                                            <asp:Label ID="Label1" runat="server" Text="充值"></asp:Label>
                                        </HeaderTemplate>
                                        <ItemTemplate>
                                            <asp:Button ID="btnCharge" CssClass="button1" runat="server" Text="充值" CausesValidation="true"
                                                CommandName="Charge" CommandArgument='<%#Container.DataItemIndex%>'/>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:BoundField DataField="SUPPLYMONEY" HeaderText="充值金额" />
                                    <asp:BoundField DataField="ORDERNO" HeaderText="订单号" />
                                    <asp:BoundField DataField="ORDERSTATE" HeaderText="订单状态" />
                                    <asp:BoundField DataField="CARDNO" HeaderText="卡号" />
                                    <asp:TemplateField>
                                        <HeaderTemplate>
                                            <asp:Label ID="labHeadPhoto" runat="server" Text="人物照片"></asp:Label>
                                        </HeaderTemplate>
                                        <ItemTemplate>
                                            <asp:Image ID="imgPerson" runat="server" Width="60px" Height="60px" ImageUrl="~/Images/nom.jpg" />
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:BoundField DataField="PACKAGENAME" HeaderText="套餐类型" />
                                    <asp:BoundField DataField="RECEIVECUSTNAME" HeaderText="收货人" />
                                    <asp:BoundField DataField="RECEIVEADDRESS" HeaderText="收货地址" />
                                    <asp:BoundField DataField="RECEIVECUSTPHONE" HeaderText="收货号码" />
                                    <asp:BoundField DataField="CUSTNAME" HeaderText="客户姓名" />
                                    <asp:BoundField DataField="PAPERNO" HeaderText="客户证件号码" />
                                    <asp:BoundField DataField="CUSTPHONE" HeaderText="客户电话" />
                                    <asp:BoundField DataField="DETAILNO" HeaderText="子订单号" />
                                </Columns>
                                <EmptyDataTemplate>
                                    <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                        <tr class="tabbt">
                                            <td>功能区域
                                            </td>
                                            <td>订单号
                                            </td>
                                            <td>订单状态
                                            </td>
                                            <td>卡号
                                            </td>
                                            <td>人物照片
                                            </td>
                                            <td>套餐类型
                                            </td>
                                            <td>收货人
                                            </td>
                                            <td>收货地址
                                            </td>
                                            <td>收货号码
                                            </td>
                                            <td>客户姓名
                                            </td>
                                            <td>客户证件号码
                                            </td>
                                            <td>客户电话
                                            </td>
                                            <td>子订单号
                                            </td>
                                            <td>充值金额
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
            </ContentTemplate>
        </asp:UpdatePanel>
    </form>
</body>
</html>

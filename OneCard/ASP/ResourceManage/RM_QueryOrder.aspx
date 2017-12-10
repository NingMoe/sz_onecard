<%@ Page Language="C#" AutoEventWireup="true" CodeFile="RM_QueryOrder.aspx.cs" Inherits="ASP_ResourceManage_RM_QueryOrder"
    EnableEventValidation="false" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>订购单查询</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="../../js/myext.js"></script>
    <script type="text/javascript" src="../../js/RMHelper.js"></script>
    <script type="text/javascript" src="../../js/printorder.js"></script>
    <script type="text/javascript" language="javascript">
        function SelectUseCard() {
            $get('hidCardType').value = "usecard";

            queryCardFace.style.display = "block";

            //提交部分，显示存货补货，其他隐藏
            supplyUseCard.style.display = "block";
            supplyChargeCard.style.display = "none";
            //Gridview部分，显示充值卡，其他隐藏
            gvUseCard.style.display = "block";
            gvChargeCard.style.display = "none";

            usecard.className = "on";
            chargecard.className = null;

            return false;
        }
        function SelectChargeCard() {
            $get('hidCardType').value = "chargecard";

            queryCardFace.style.display = "none";

            //提交部分，显示充值卡，其他隐藏
            supplyUseCard.style.display = "none";
            supplyChargeCard.style.display = "block";
            //Gridview部分，显示充值卡，其他隐藏
            gvUseCard.style.display = "none";
            gvChargeCard.style.display = "block";

            usecard.className = null;
            chargecard.className = "on";

            return false;
        }
    </script>
    
     <style type="text/css">

        table.data {font-size: 90%; border-collapse: collapse; border: 0px solid black;}
        table.data th {background: #bddeff; width: 25em; text-align: left; padding-right: 8px; font-weight: normal; border: 1px solid black;}
        table.data td {background: #ffffff; vertical-align:middle;padding: 0px 2px 0px 2px; border: 1px solid black;}

    </style>
    
</head>
<body>
    <form id="form1" runat="server">
    <div class="tb">
        卡片管理->订购单查询
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
                            <td width="15%">
                                <div align="right">
                                    起始日期:</div>
                            </td>
                            <td width="15%">
                                <ajaxToolkit:CalendarExtender ID="BeginCalendar" runat="server" TargetControlID="txtStartDate"
                                    Format="yyyyMMdd" PopupPosition="BottomLeft" />
                                <asp:TextBox ID="txtStartDate" runat="server" CssClass="input" MaxLength="8"></asp:TextBox>
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
                                <div align="right">
                                    订购单状态:</div>
                            </td>
                            <td width="15%">
                                <asp:DropDownList ID="selExamState" CssClass="input" runat="server">
                                    <asp:ListItem Text="---请选择---" Value=""></asp:ListItem>
                                    <asp:ListItem Text="0: 待审核" Value="0"></asp:ListItem>
                                    <asp:ListItem Text="1: 审核通过" Value="'1'"></asp:ListItem>
                                    <asp:ListItem Text="2: 审核作废" Value="'2'"></asp:ListItem>
                                    <asp:ListItem Text="3: 部分到货" Value="'3'"></asp:ListItem>
                                    <asp:ListItem Text="4: 全部到货" Value="'4'"></asp:ListItem>
                                    <asp:ListItem Text="5: 未全部到货" Value="'1','3'" Selected="True"></asp:ListItem>
                                </asp:DropDownList>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    订购单号:</div>
                            </td>
                            <td>
                                <asp:TextBox ID="txtOrderID" CssClass="inputmid" MaxLength="18" runat="server">
                                </asp:TextBox>
                            </td>
                            <td>
                                <div align="right">
                                    需求单号:</div>
                            </td>
                            <td>
                                <asp:TextBox ID="txtApplyOrderID" CssClass="inputmid" MaxLength="18" runat="server">
                                </asp:TextBox>
                            </td>
                            <td colspan="2">
                                <table id="queryCardFace" style="display: block;" border="0" cellpadding="0" cellspacing="0"
                                    class="text25" width="100%">
                                    <tr>
                                        <td width="50%">
                                            <div align="right">
                                                卡面类型:</div>
                                        </td>
                                        <td width="50%">
                                            <asp:DropDownList ID="selFaceType" CssClass="inputmid" runat="server">
                                            </asp:DropDownList>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                            <td align="right">
                                <asp:Button ID="btnQuery" CssClass="button1" runat="server" Text="查询" OnClick="btnQuery_Click" />
                            </td>
                        </tr>
                    </table>
                </div>
                <div class="jieguo">
                    查询结果</div>
                <div class="kuang5">
                    <div id="gvUseCard" style="height: 150px; overflow: auto; display: block">
                        <asp:GridView ID="gvResultUseCard" runat="server" Width="250%" CssClass="tab1" HeaderStyle-CssClass="tabbt"
                            FooterStyle-CssClass="tabcon" AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel"
                            PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top"
                            AutoGenerateColumns="false" OnRowDataBound="gvResult_RowDataBound" PageSize="50"
                            OnPageIndexChanging="gvResult_Page" OnSelectedIndexChanged="gvResult_SelectedIndexChanged"
                            OnRowCreated="gvResultUseCard_RowCreated" AllowPaging="true">
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
                                <asp:BoundField DataField="ORDERTYPE" HeaderText="订购类型" />
                                <asp:BoundField DataField="APPLYORDERID" HeaderText="需求单号" />
                                <asp:BoundField DataField="STATE" HeaderText="订购单状态" />
                                <asp:BoundField DataField="CARDTYPE" HeaderText="卡片类型" />
                                <asp:BoundField DataField="CARDFACE" HeaderText="卡面类型" />
                                <asp:BoundField DataField="CARDSAMPLECODE" HeaderText="卡样编码" />
                                <asp:BoundField DataField="CARDNAME" HeaderText="卡片名称" />
                                <asp:BoundField DataField="WAY" HeaderText="卡面确认方式" />
                                <asp:BoundField DataField="CARDNUM" HeaderText="订购数量" />
                                <asp:BoundField DataField="REQUIREDATE" HeaderText="要求到货日期" />
                                <asp:BoundField DataField="LATELYDATE" HeaderText="最近到货日期" />
                                <asp:BoundField DataField="ALREADYARRIVENUM" HeaderText="已到货数量" />
                                <asp:BoundField DataField="RETURNCARDNUM" HeaderText="退货数量" />
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
                                            订购类型
                                        </td>
                                        <td>
                                            需求单号
                                        </td>
                                        <td>
                                            订购单状态
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
                                            卡片名称
                                        </td>
                                        <td>
                                            卡面确认方式
                                        </td>
                                        <td>
                                            订购数量
                                        </td>
                                        <td>
                                            要求到货日期
                                        </td>
                                        <td>
                                            最近到货日期
                                        </td>
                                        <td>
                                            已到货数量
                                        </td>
                                        <td>
                                            退货数量
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
                    <div id="gvChargeCard" style="height: 175px; overflow: auto; display: none">
                        <asp:GridView ID="gvResultChargeCard" runat="server" Width="150%" CssClass="tab1"
                            HeaderStyle-CssClass="tabbt" FooterStyle-CssClass="tabcon" AlternatingRowStyle-CssClass="tabjg"
                            SelectedRowStyle-CssClass="tabsel" PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left"
                            PagerStyle-VerticalAlign="Top" AutoGenerateColumns="false" OnRowDataBound="gvResult_RowDataBound"
                            PageSize="50" OnPageIndexChanging="gvResult_Page" OnSelectedIndexChanged="gvResult_SelectedIndexChanged"
                            OnRowCreated="gvResultChargeCard_RowCreated" AllowPaging="true">
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
                                <asp:BoundField DataField="STATE" HeaderText="订购单状态" />
                                <asp:BoundField DataField="CARDVALUE" HeaderText="面值" />
                                <asp:BoundField DataField="CARDNUM" HeaderText="订购数量" />
                                <asp:BoundField DataField="REQUIREDATE" HeaderText="要求到货日期" />
                                <asp:BoundField DataField="LATELYDATE" HeaderText="最近到货日期" />
                                <asp:BoundField DataField="ALREADYARRIVENUM" HeaderText="已到货数量" />
                                <asp:BoundField DataField="RETURNCARDNUM" HeaderText="退货数量" />
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
                                            订购单状态
                                        </td>
                                        <td>
                                            面值
                                        </td>
                                        <td>
                                            订购数量
                                        </td>
                                        <td>
                                            要求到货日期
                                        </td>
                                        <td>
                                            最近到货日期
                                        </td>
                                        <td>
                                            已到货数量
                                        </td>
                                        <td>
                                            退货数量
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
                <div class="card">
                    订购单详细信息</div>
                <div class="kuang5">
                    <table id="supplyUseCard" width="95%" border="0" cellpadding="0" cellspacing="0"
                        class="text25" style="display: block">
                        <tr>
                            <td width="12%">
                                <div align="right">
                                    订购单号:</div>
                            </td>
                            <td width="12%">
                                <asp:Label ID="txtCardOrderID"  runat="server">
                                </asp:Label>
                            </td>
                            <td width="12%">
                                <div align="right">
                                    需求单号:</div>
                            </td>
                            <td width="12%">
                                <asp:Label ID="txtApplyCardOrderID"  runat="server">
                                </asp:Label>
                            </td>
                            <td>
                                <div align="right" width="12%">
                                    订购类型:</div>
                            </td>
                            <td width="12%">
                                <asp:Label ID="txtOrderType"  runat="server">
                                </asp:Label>
                            </td>
                            <td width="12%">
                                <div align="right">
                                    订购单状态:</div>
                            </td>
                            <td width="12%">
                                <asp:Label ID="txtExamState"  runat="server"></asp:Label>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    卡片类型:</div>
                            </td>
                            <td>
                                <asp:Label ID="txtCardType"  runat="server">
                                </asp:Label>
                            </td>
                            <td>
                                <div align="right">
                                    卡面类型:</div>
                            </td>
                            <td>
                                <asp:Label ID="txtFaceType"  runat="server">
                                </asp:Label>
                            </td>
                            <td>
                                <div align="right">
                                    卡样编号:</div>
                            </td>
                            <td>
                                <asp:Label ID="txtCardSampleCode"  runat="server"></asp:Label>
                            </td>
                            <td>
                                <div align="right">
                                    卡片名称:</div>
                            </td>
                            <td>
                                <asp:Label ID="txtCardName"  runat="server">
                                </asp:Label>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    起始卡号:</div>
                            </td>
                            <td>
                                <asp:Label ID="txtFromCardNo"  runat="server"></asp:Label>
                            </td>
                            <td>
                                <div align="right">
                                    结束卡号:</div>
                            </td>
                            <td>
                                <asp:Label ID="txtToCardNo"  runat="server"></asp:Label>
                            </td>
                            <td>
                                <div align="right">
                                    订购数量:</div>
                            </td>
                            <td>
                                <asp:Label ID="txtCardSum"  Width="100" runat="server"></asp:Label>
                            </td>
                            <td>
                                <div align="right">
                                    要求到货日期:</div>
                            </td>
                            <td>
                                <asp:Label ID="txtDate"  runat="server"></asp:Label>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    最近到货日期:</div>
                            </td>
                            <td>
                                <asp:Label runat="server" ID="txtLatelyDate"  />
                            </td>
                            <td>
                                <div align="right">
                                    已到货数量:</div>
                            </td>
                            <td>
                                <asp:Label ID="txtAlreadyArriveNum"  runat="server">
                                </asp:Label>
                            </td>
                            <td>
                                <div align="right">
                                    退货数量:</div>
                            </td>
                            <td>
                                <asp:Label ID="txtReturnCardNum"  runat="server">
                                </asp:Label>
                            </td>
                            <td>
                                <div align="right">
                                    卡片厂商:</div>
                            </td>
                            <td>
                                <asp:Label ID="txtProducer"  runat="server">
                                </asp:Label>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    下单员工:</div>
                            </td>
                            <td>
                                <asp:Label ID="txtOrderStaff"  runat="server">
                                </asp:Label>
                            </td>
                            <td>
                                <div align="right">
                                    下单时间:</div>
                            </td>
                            <td>
                                <asp:Label ID="txtOrderTime" runat="server" ></asp:Label>
                            </td>
                            <td>
                                <div align="right">
                                    备注:</div>
                            </td>
                            <td colspan="3">
                                <asp:Label ID="txtReMark"  runat="server">
                                </asp:Label>
                            </td>
                        </tr>
                    </table>
                    <table id="supplyChargeCard" width="95%" border="0" cellpadding="0" cellspacing="0"
                        class="text25" style="display: none">
                        <tr>
                            <td width="12%">
                                <div align="right">
                                    订购单号:</div>
                            </td>
                            <td width="12%">
                                <asp:Label ID="txtChargeOrderID"  runat="server">
                                </asp:Label>
                            </td>
                            <td width="12%">
                                <div align="right">
                                    需求单号:</div>
                            </td>
                            <td width="12%">
                                <asp:Label ID="txtApplyChargeOrderID"  runat="server">
                                </asp:Label>
                            </td>
                            <td width="12%">
                                <div align="right">
                                    订购单状态:</div>
                            </td>
                            <td width="12%">
                                <asp:Label ID="txtChargeExamState"  runat="server"></asp:Label>
                            </td>
                            <td width="12%">
                                <div align="right">
                                    面值:</div>
                            </td>
                            <td width="12%">
                                <asp:Label ID="txtCardValue"  runat="server">
                                </asp:Label>
                            </td>
                        </tr>
                        <tr>
                            <tr>
                                <td>
                                    <div align="right">
                                        起始卡号:</div>
                                </td>
                                <td>
                                    <asp:Label ID="txtFromChargeCardno"  runat="server"></asp:Label>
                                </td>
                                <td>
                                    <div align="right">
                                        结束卡号:</div>
                                </td>
                                <td>
                                    <asp:Label ID="txtToChargeCardno"  runat="server"></asp:Label>
                                </td>
                                <td>
                                    <div align="right">
                                        订购数量:</div>
                                </td>
                                <td>
                                    <asp:Label ID="txtChargeCardNum"  Width="100" runat="server"></asp:Label>
                                </td>
                                <td>
                                    <div align="right">
                                        要求到货日期:</div>
                                </td>
                                <td>
                                    <asp:Label ID="txtChargeCardDate"  runat="server"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <div align="right">
                                        最近到货日期:</div>
                                </td>
                                <td>
                                    <asp:Label runat="server" ID="txtChargeLatelyDate"  />
                                </td>
                                <td>
                                    <div align="right">
                                        已到货数量:</div>
                                </td>
                                <td>
                                    <asp:Label ID="txtChargeAlreadyArriveNum"  runat="server">
                                    </asp:Label>
                                </td>
                                <td>
                                    <div align="right">
                                        退货数量:</div>
                                </td>
                                <td>
                                    <asp:Label ID="txtChargeReturnCardNum"  runat="server">
                                    </asp:Label>
                                </td>
                                <td>
                                </td>
                                <td>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <div align="right">
                                        下单员工:</div>
                                </td>
                                <td>
                                    <asp:Label ID="txtChargeOrderStaff"  runat="server">
                                    </asp:Label>
                                </td>
                                <td>
                                    <div align="right">
                                        下单时间:</div>
                                </td>
                                <td>
                                    <asp:Label ID="txtChargeOrderTime" runat="server" ></asp:Label>
                                </td>
                                <td>
                                    <div align="right">
                                        备注:</div>
                                </td>
                                <td colspan="3">
                                    <asp:Label ID="txtChargeReMark"  runat="server">
                                    </asp:Label>
                                </td>
                            </tr>
                    </table>
                </div>
            </div>
            <div class="footall">
            </div>
            <div class="btns">
                <table width="200" border="0" align="right" cellpadding="0" cellspacing="0">
                    <tr>
                        <td>
                            <asp:Button ID="btnPrint" runat="server" Text="打印订购单" CssClass="button1" Enabled="true"
                                OnClick="btnPrint_Click" />
                        </td>
                    </tr>
                </table>
            </div>
            <div style="display:none" runat="server" id="printarea"></div>
        </ContentTemplate>
    </asp:UpdatePanel>
    </form>
</body>
</html>

<%@ Page Language="C#" AutoEventWireup="true" CodeFile="RM_ApplyOrder.aspx.cs" Inherits="ASP_ResourceManage_RM_ApplyOrder" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <%--<link rel="stylesheet" type="text/css" href="../../css/frame.css" />--%>
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="../../js/myext.js"></script>
    <script type="text/javascript" src="../../js/RMHelper.js"></script>
    <script type="text/javascript" src="../../js/printorder.js"></script>
    <script src="../../js/jquery-1.5.min.js" type="text/javascript"></script>
    <script type="text/javascript" src="../../js/Window.js"></script>
    <title>下单申请</title>
    <script type="text/javascript" language="javascript">
        function SelectRadioTag() {
            if ($get('hidCardType').value == "usecard") {
                if ($get('hidApplyType').value == "ApplyStock") {
                    $get('radSupplyStock').checked = true;
                }
                else {
                    $get('radNewCard').checked = true;
                }
                SelectRadio();
            }
            return false;
        }
        function SelectRadio() {
            if ($get('radSupplyStock').checked == true) {
                $get('hidApplyType').value = "ApplyStock";

                //查询部分
                querySupplyStock.style.display = "block";
                queryNewCard.style.display = "none";
                //提交部分
                applySupplyStock.style.display = "block";
                applyNewCard.style.display = "none";
                //Gridview
                gvSupplyCard.style.display = "block";
                gvNewCard.style.display = "none";
            }
            else {
                $get('hidApplyType').value = "ApplyNew";

                //查询部分
                querySupplyStock.style.display = "none";
                queryNewCard.style.display = "block";
                //提交部分
                applySupplyStock.style.display = "none";
                applyNewCard.style.display = "block";
                //Gridview
                gvSupplyCard.style.display = "none";
                gvNewCard.style.display = "block";
            }
            return false;
        }
        function SelectUseCard() {
            $get('hidCardType').value = "usecard";

            //显示radio
            trRadio.style.display = "block";
            //查询部分，显示存货补货，其他隐藏
            queryChargeCard.style.display = "none";
            querySupplyStock.style.display = "block";
            queryNewCard.style.display = "none";
            //提交部分，显示存货补货，其他隐藏
            applySupplyStock.style.display = "block";
            applyNewCard.style.display = "none";
            applyChargeCard.style.display = "none";
            //Gridview部分，显示充值卡，其他隐藏
            gvSupplyCard.style.display = "block";
            gvNewCard.style.display = "none";
            gvChargeCard.style.display = "none";

            $get('radSupplyStock').checked = true;
            usecard.className = "on";
            chargecard.className = null;

            return false;
        }
        function SelectChargeCard() {
            $get('hidCardType').value = "chargecard";

            //隐藏radio
            trRadio.style.display = "none";
            //查询部分，显示充值卡，其他隐藏
            queryChargeCard.style.display = "block";
            querySupplyStock.style.display = "none";
            queryNewCard.style.display = "none";
            //提交部分，显示充值卡，其他隐藏
            applySupplyStock.style.display = "none";
            applyNewCard.style.display = "none";
            applyChargeCard.style.display = "block";
            //Gridview部分，显示充值卡，其他隐藏
            gvSupplyCard.style.display = "none";
            gvNewCard.style.display = "none";
            gvChargeCard.style.display = "block";

            usecard.className = null;
            chargecard.className = "on";

            return false;
        }

        function ViewCardFaceClick() {
            CreateWindow('RoleWindow', 'RM_ShowPicture.aspx?surFaceCode=' + $get('txtCardSampleCode').value + '');

            return false;
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
        卡片管理->下单申请
    </div>
    <ajaxToolkit:ToolkitScriptManager runat="Server" EnableScriptGlobalization="true"
        EnableScriptLocalization="true" ID="ToolkitScriptManager1" />
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
            <asp:HiddenField ID="hidApplyType" runat="server" />
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
                    查询
                </div>
                <div class="kuang5" style="text-align: left">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td width="30%" colspan="2">
                                <table id="trRadio" style="display: block;" border="0" cellpadding="0" cellspacing="0"
                                    class="text25" width="100%">
                                    <tr>
                                        <td width="50%" align="right">
                                            <input type="radio" value="存货补货" name="usecardradio" id="radSupplyStock" checked="checked"
                                                onclick="SelectRadio()" />存货补货
                                        </td>
                                        <td width="50%" align="left">
                                            &nbsp;&nbsp;&nbsp;
                                            <input type="radio" value="新制卡片" name="usecardradio" id="radNewCard" onclick="SelectRadio()" />新制卡片
                                        </td>
                                    </tr>
                                </table>
                                <table id="queryChargeCard" style="display: none;" border="0" cellpadding="0" cellspacing="0"
                                    class="text25" width="100%">
                                    <tr>
                                        <td width="50%">
                                            <div align="right">
                                                面值:</div>
                                        </td>
                                        <td width="50%">
                                            <asp:DropDownList ID="selCardValue" CssClass="input" runat="server">
                                            </asp:DropDownList>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                            <td width="60%" colspan="4">
                                <table id="querySupplyStock" style="display: block;" border="0" cellpadding="0" cellspacing="0"
                                    class="text25" width="100%">
                                    <tr>
                                        <td width="25%">
                                            <div align="right">
                                                卡片类型:</div>
                                        </td>
                                        <td width="25%">
                                            <asp:DropDownList ID="selCardType" CssClass="inputmid" runat="server" AutoPostBack="true"
                                                OnSelectedIndexChanged="selCardType_change">
                                            </asp:DropDownList>
                                        </td>
                                        <td width="25%">
                                            <div align="right">
                                                卡面类型:</div>
                                        </td>
                                        <td width="25%">
                                            <asp:DropDownList ID="selFaceType" CssClass="inputmid" runat="server">
                                            </asp:DropDownList>
                                        </td>
                                    </tr>
                                </table>
                                <table id="queryNewCard" style="display: none" border="0" cellpadding="0" cellspacing="0"
                                    class="text25" width="100%">
                                    <tr>
                                        <td width="25%">
                                            <div align="right">
                                                卡片名称:</div>
                                        </td>
                                        <td width="25%">
                                            <asp:TextBox runat="server" ID="txtCardName" CssClass="input"></asp:TextBox>
                                        </td>
                                        <td width="25%">
                                        </td>
                                        <td width="25%">
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                        <tr>
                            <td width="15%">
                                <div align="right">
                                    需求单号:</div>
                            </td>
                            <td width="15%">
                                <asp:TextBox runat="server" ID="txtApplyOrderID" CssClass="inputmid" MaxLength="18"></asp:TextBox>
                            </td>
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
                        </tr>
                        <tr>
                            <td width="15%">
                                <div align="right">
                                    需求单状态:</div>
                            </td>
                            <td width="15%">
                                <asp:DropDownList ID="selOrderState" CssClass="input" runat="server">
                                    <asp:ListItem Text="--请选择--" Value=""></asp:ListItem>
                                    <asp:ListItem Text="0:未下订购单" Value="0"></asp:ListItem>
                                    <asp:ListItem Text="1:部分下单" Value="1"></asp:ListItem>
                                    <asp:ListItem Text="2:完成订购" Value="2"></asp:ListItem>
                                </asp:DropDownList>
                            </td>
                            <td width="15%">
                                <div align="right">
                                    有效标志:</div>
                            </td>
                            <td width="15%">
                                <asp:DropDownList ID="selUseTag" CssClass="input" runat="server">
                                    <asp:ListItem Text="1:有效" Value="1"></asp:ListItem>
                                    <asp:ListItem Text="0:无效" Value="0"></asp:ListItem>
                                </asp:DropDownList>
                            </td>
                            <td width="15%">
                            </td>
                            <td width="15%">
                                <asp:Button ID="btnQuery" CssClass="button1" runat="server" Text="查询" OnClick="btnQuery_Click" />
                            </td>
                        </tr>
                    </table>
                </div>
                <div class="jieguo">
                    查询结果</div>
                <div class="kuang5">
                    <div id="gvSupplyCard" style="height: 180px; overflow: auto; display: block">
                        <asp:GridView ID="gvResultSupplyCard" runat="server" Width="120%" CssClass="tab1"
                            HeaderStyle-CssClass="tabbt" FooterStyle-CssClass="tabcon" AlternatingRowStyle-CssClass="tabjg"
                            SelectedRowStyle-CssClass="tabsel" PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left"
                            PagerStyle-VerticalAlign="Top" AutoGenerateColumns="false" PageSize="50" AllowPaging="true"
                            OnPageIndexChanging="gvResult_Page">
                            <Columns>
                                <asp:TemplateField>
                                    <HeaderTemplate>
                                        <asp:CheckBox ID="CheckBox1" runat="server" AutoPostBack="true" OnCheckedChanged="CheckAll" />
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                        <asp:CheckBox ID="ItemCheckBox" runat="server" />
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField DataField="APPLYORDERID" HeaderText="需求单号" />
                                <asp:BoundField DataField="STATE" HeaderText="需求单状态" />
                                <asp:BoundField DataField="CARDTYPE" HeaderText="卡片类型" />
                                <asp:BoundField DataField="CARDFACE" HeaderText="卡面类型" />
                                <asp:BoundField DataField="CARDSAMPLECODE" HeaderText="卡样编码" />
                                <asp:BoundField DataField="CARDNUM" HeaderText="下单数量" />
                                <asp:BoundField DataField="REQUIREDATE" HeaderText="要求到货日期" />
                                <asp:BoundField DataField="ORDERDEMAND" HeaderText="订单要求" />
                                <asp:BoundField DataField="ORDERTIME" HeaderText="下单时间" />
                                <asp:BoundField DataField="ORDERSTAFF" HeaderText="下单员工" />
                                <asp:BoundField DataField="ALREADYORDERNUM" HeaderText="已订购数量" />
                                <asp:BoundField DataField="LATELYDATE" HeaderText=" 最近到货时间" />
                                <asp:BoundField DataField="NUM" HeaderText="已到货数量" />
                                <asp:BoundField DataField="REMARK" HeaderText="备注" />
                            </Columns>
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                        <td>
                                            <input type="checkbox" />
                                        </td>
                                        <td>
                                            需求单号
                                        </td>
                                        <td>
                                            需求单状态
                                        </td>
                                        <td>
                                            卡片类型
                                        </td>
                                        <td>
                                            卡面类型
                                        </td>
                                        <td>
                                            下单数量
                                        </td>
                                        <td>
                                            要求到货日期
                                        </td>
                                        <td>
                                            订单要求
                                        </td>
                                        <td>
                                            下单时间
                                        </td>
                                        <td>
                                            下单员工
                                        </td>
                                        <td>
                                            已订购数量
                                        </td>
                                        <td>
                                            最近到货时间
                                        </td>
                                        <td>
                                            已到货数量
                                        </td>
                                        <td>
                                            备注
                                        </td>
                                    </tr>
                                </table>
                            </EmptyDataTemplate>
                        </asp:GridView>
                    </div>
                    <div id="gvNewCard" style="height: 180px; overflow: auto; display: none">
                        <asp:GridView ID="gvResultNewCard" runat="server" Width="120%" CssClass="tab1" HeaderStyle-CssClass="tabbt"
                            FooterStyle-CssClass="tabcon" AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel"
                            PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top"
                            AutoGenerateColumns="false" PageSize="50" AllowPaging="true" OnPageIndexChanging="gvResult_Page">
                            <Columns>
                                <asp:TemplateField>
                                    <HeaderTemplate>
                                        <asp:CheckBox ID="CheckBox1" runat="server" AutoPostBack="true" OnCheckedChanged="CheckAll" />
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                        <asp:CheckBox ID="ItemCheckBox" runat="server" />
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField DataField="APPLYORDERID" HeaderText="需求单号" />
                                <asp:BoundField DataField="STATE" HeaderText="需求单状态" />
                                <asp:BoundField DataField="CARDNAME" HeaderText="卡片名称" />
                                <asp:BoundField DataField="WAY" HeaderText="卡面确认方式" />
                                <asp:BoundField DataField="CARDNUM" HeaderText="下单数量" />
                                <asp:BoundField DataField="REQUIREDATE" HeaderText="要求到货日期" />
                                <asp:BoundField DataField="ORDERDEMAND" HeaderText="订单要求" />
                                <asp:BoundField DataField="ORDERTIME" HeaderText="下单时间" />
                                <asp:BoundField DataField="ORDERSTAFF" HeaderText="下单员工" />
                                <asp:BoundField DataField="ALREADYORDERNUM" HeaderText="已订购数量" />
                                <asp:BoundField DataField="LATELYDATE" HeaderText=" 最近到货时间" />
                                <asp:BoundField DataField="NUM" HeaderText="已到货数量" />
                                <asp:BoundField DataField="REMARK" HeaderText="备注" />
                            </Columns>
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                        <td>
                                            <input type="checkbox" />
                                        </td>
                                        <td>
                                            需求单号
                                        </td>
                                        <td>
                                            需求单状态
                                        </td>
                                        <td>
                                            卡片名称
                                        </td>
                                        <td>
                                            卡面确认方式
                                        </td>
                                        <td>
                                            下单数量
                                        </td>
                                        <td>
                                            到货日期
                                        </td>
                                        <td>
                                            订单要求
                                        </td>
                                        <td>
                                            下单时间
                                        </td>
                                        <td>
                                            下单员工
                                        </td>
                                        <td>
                                            已订购数量
                                        </td>
                                        <td>
                                            最近到货时间
                                        </td>
                                        <td>
                                            已到货数量
                                        </td>
                                        <td>
                                            备注
                                        </td>
                                    </tr>
                                </table>
                            </EmptyDataTemplate>
                        </asp:GridView>
                    </div>
                    <div id="gvChargeCard" style="height: 180px; overflow: auto; display: none">
                        <asp:GridView ID="gvResultChargeCard" runat="server" Width="120%" CssClass="tab1"
                            HeaderStyle-CssClass="tabbt" FooterStyle-CssClass="tabcon" AlternatingRowStyle-CssClass="tabjg"
                            SelectedRowStyle-CssClass="tabsel" PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left"
                            PagerStyle-VerticalAlign="Top" AutoGenerateColumns="false" PageSize="50" AllowPaging="true"
                            OnPageIndexChanging="gvResult_Page">
                            <Columns>
                                <asp:TemplateField>
                                    <HeaderTemplate>
                                        <asp:CheckBox ID="CheckBox1" runat="server" AutoPostBack="true" OnCheckedChanged="CheckAll" />
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                        <asp:CheckBox ID="ItemCheckBox" runat="server" />
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField DataField="APPLYORDERID" HeaderText="需求单号" />
                                <asp:BoundField DataField="STATE" HeaderText="需求单状态" />
                                <asp:BoundField DataField="VALUECODE" HeaderText="充值卡面值" />
                                <asp:BoundField DataField="CARDNUM" HeaderText="下单数量" />
                                <asp:BoundField DataField="REQUIREDATE" HeaderText="要求到货日期" />
                                <asp:BoundField DataField="ORDERDEMAND" HeaderText="订单要求" />
                                <asp:BoundField DataField="ORDERTIME" HeaderText="下单时间" />
                                <asp:BoundField DataField="ORDERSTAFF" HeaderText="下单员工" />
                                <asp:BoundField DataField="ALREADYORDERNUM" HeaderText="已订购数量" />
                                <asp:BoundField DataField="LATELYDATE" HeaderText=" 最近到货时间" />
                                <asp:BoundField DataField="NUM" HeaderText="已到货数量" />
                                <asp:BoundField DataField="REMARK" HeaderText="备注" />
                            </Columns>
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                        <td>
                                            <input type="checkbox" />
                                        </td>
                                        <td>
                                            需求单号
                                        </td>
                                        <td>
                                            需求单状态
                                        </td>
                                        <td>
                                            面值
                                        </td>
                                        <td>
                                            下单数量
                                        </td>
                                        <td>
                                            到货日期
                                        </td>
                                        <td>
                                            订单要求
                                        </td>
                                        <td>
                                            下单时间
                                        </td>
                                        <td>
                                            下单员工
                                        </td>
                                        <td>
                                            已订购数量
                                        </td>
                                        <td>
                                            最近到货时间
                                        </td>
                                        <td>
                                            已到货数量
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
                    填写需求单</div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr id="applySupplyStock" style="display: block">
                            <td width="12%">
                                <div align="right">
                                    卡面类型:</div>
                            </td>
                            <td width="36%" colspan="3">
                                <asp:DropDownList ID="selSupplyFaceType" CssClass="inputmid" Width="200px" runat="server"
                                    AutoPostBack="true" OnSelectedIndexChanged="selSupplyFaceType_change">
                                </asp:DropDownList>
                                <span class="red">*</span>
                            </td>
                            <td width="12%">
                                <div align="right">
                                    卡样编号:</div>
                            </td>
                            <td width="36%" colspan="3">
                                <asp:TextBox ID="txtCardSampleCode" CssClass="labeltext" runat="server"></asp:TextBox>&nbsp;
                                <asp:LinkButton ID="linkViewCardFace" Text="查看" Visible="false" runat="server" OnClientClick="return ViewCardFaceClick();" />
                                <%--<asp:Button ID="btnViewCardFace" Text="" Visible="false" CssClass="button1" runat="server" OnClick="btnViewCardFace_Click" />--%>
                                <%--<asp:LinkButton runat="server" ID="btnViewCardFace" OnClick="btnViewCardFace_Click" />--%>
                                <%--<u style="color:Blue">查看</u>--%>
                            </td>
                        </tr>
                        <tr id="applyNewCard" style="display: none">
                            <td width="12%">
                                <div align="right">
                                    卡片名称:</div>
                            </td>
                            <td width="36%" colspan="3">
                                <asp:TextBox ID="txtSupplyardName" CssClass="input" runat="server"></asp:TextBox><span
                                    class="red">*</span>
                            </td>
                            <td width="12%">
                                <div align="right">
                                    卡面确认方式:</div>
                            </td>
                            <td width="36%" colspan="3">
                                <asp:DropDownList ID="selCardFaceAffirmWay" CssClass="input" runat="server">
                                </asp:DropDownList>
                                <span class="red">*</span>
                            </td>
                        </tr>
                        <tr id="applyChargeCard" style="display: none">
                            <td width="12%">
                                <div align="right">
                                    面值:</div>
                            </td>
                            <td width="36%" colspan="3">
                                <asp:DropDownList ID="selSupplyCardValue" CssClass="input" runat="server">
                                </asp:DropDownList>
                                <span class="red">*</span>
                            </td>
                            <td width="12%">
                            </td>
                            <td width="36%" colspan="3">
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    下单数量:</div>
                            </td>
                            <td colspan="3">
                                <asp:TextBox ID="txtCardNum" CssClass="input" MaxLength="8" runat="server"></asp:TextBox><span
                                    class="red">*</span>
                            </td>
                            <td>
                                <div align="right">
                                    要求到货日期:</div>
                            </td>
                            <td colspan="3">
                                <asp:TextBox ID="txtDate" CssClass="input" runat="server" MaxLength="8" />
                                <ajaxToolkit:CalendarExtender ID="FCalendar" runat="server" TargetControlID="txtDate"
                                    Format="yyyyMMdd" />
                                <span class="red">*</span>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    订单要求:</div>
                            </td>
                            <td colspan="3">
                                <asp:TextBox ID="txtOrderMand" CssClass="inputlong" runat="server"></asp:TextBox>
                            </td>
                            <td>
                                <div align="right">
                                    备注:</div>
                            </td>
                            <td colspan="3">
                                <asp:TextBox ID="txtReMark" CssClass="inputlong" runat="server"></asp:TextBox>
                            </td>
                        </tr>
                    </table>
                </div>
            </div>
            <div class="footall">
            </div>
            <div class="btns">
                <table width="300" border="0" align="right" cellpadding="0" cellspacing="0">
                    <tr>
                        <td>
                            <asp:Button ID="btnPrint" Text="打印需求单" CssClass="button1" runat="server" OnClick="btnPrint_Click" />
                        </td>
                        <td>
                            <asp:Button ID="btnApply" Text="申 请" CssClass="button1" runat="server" OnClick="btnApply_Click" />
                        </td>
                        <td>
                            <asp:Button ID="btnClose" Text="关 闭" CssClass="button1" runat="server" OnClick="btnClose_Click" />
                        </td>
                    </tr>
                </table>
                <asp:CheckBox ID="chkOrder" runat="server" Checked="true" />自动打印需求单
            </div>
            <div style="display: none" runat="server" id="printarea">
            </div>
            <div id="RoleWindow" style="width: 670px; position: absolute; display: none; z-index: 999;">
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
    </form>
</body>
</html>

<%@ Page Language="C#" AutoEventWireup="true" CodeFile="RM_CardOrder.aspx.cs" Inherits="ASP_ResourceManage_RM_CardOrder"
    EnableEventValidation="false" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>卡片下单</title>
    <%--<link rel="stylesheet" type="text/css" href="../../css/frame.css" />--%>
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="../../js/mootools.js"></script>
    <script type="text/javascript" src="../../js/myext.js"></script>
    <script type="text/javascript" src="../../js/RMHelper.js"></script>
    
    <script type="text/javascript" src="../../js/printorder.js"></script>
    
    <script type="text/javascript" language="javascript">
        function SelectUseCard() {
            $get('hidCardType').value = "usecard";

            //提交部分，显示存货补货，其他隐藏
            supplyUseCard.style.display = "block";
            supplyUseCardNo.style.display = "block";
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

            //提交部分，显示充值卡，其他隐藏
            supplyUseCard.style.display = "none";
            supplyUseCardNo.style.display = "none";
            supplyChargeCard.style.display = "block";
            //Gridview部分，显示充值卡，其他隐藏
            gvUseCard.style.display = "none";
            gvChargeCard.style.display = "block";

            usecard.className = null;
            chargecard.className = "on";

            return false;
        }

        function Change() {
            var sFCard;
            var sECard;
            var lCardSum;
            var lFCard;
            var lECard;
            if ($get('hidCardType').value == "usecard") {
                sFCard = $('txtFromCardNo').value;
                sECard = $('txtToCardNo').value;
                lCardSum = 0;
                if (sFCard.test("^\\s*\\d{16}\\s*$") && sECard.test("\\s*^\\d{16}\\s*$")) {
                    lFCard = sFCard.toInt();
                    lECard = sECard.toInt();
                    if (lECard - lFCard >= 0)
                        lCardSum = lECard - lFCard + 1;
                }

                $('txtCardSum').value = lCardSum;
            }
            else {
                sFCard = $('txtFromChargeCardno').value.substring(6, 14);
                sECard = $('txtToChargeCardno').value.substring(6, 14);
                lCardSum = 0;
                if (sFCard.test("^\\s*\\d{8}\\s*$") && sECard.test("\\s*^\\d{8}\\s*$")) {
                    lFCard = sFCard.toInt();
                    lECard = sECard.toInt();
                    if (lECard - lFCard >= 0)
                        lCardSum = lECard - lFCard + 1;
                }

                $('txtChargeCardNum').value = lCardSum;
            }
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
        卡片管理->卡片下单
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
                    查询
                </div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td width="12%">
                                <div align="right">
                                    需求单号:</div>
                            </td>
                            <td width="12%">
                                <asp:TextBox runat="server" ID="txtApplyOrderID" CssClass="inputmid" MaxLength="18"></asp:TextBox>
                            </td>
                            <td width="12%">
                                <div align="right">
                                    起始日期:</div>
                            </td>
                            <td width="12%">
                                <ajaxToolkit:CalendarExtender ID="BeginCalendar" runat="server" TargetControlID="txtStartDate"
                                    Format="yyyyMMdd" PopupPosition="BottomLeft" />
                                <asp:TextBox ID="txtStartDate" runat="server" CssClass="input" MaxLength="8"></asp:TextBox>
                            </td>
                            <td width="12%">
                                <div align="right">
                                    结束日期:</div>
                            </td>
                            <td width="12%">
                                <asp:TextBox ID="txtEndDate" runat="server" CssClass="input" MaxLength="8"></asp:TextBox>
                                <ajaxToolkit:CalendarExtender ID="CalendarExtender2" runat="server" TargetControlID="txtEndDate"
                                    Format="yyyyMMdd" PopupPosition="BottomLeft" />
                            </td>
                            <td width="12%">
                            </td>
                            <td width="12%" align="left">
                                <asp:Button ID="btnQuery" CssClass="button1" runat="server" Text="查询" OnClick="btnQuery_Click" />
                            </td>
                        </tr>
                    </table>
                </div>
                <div class="jieguo">
                    需求单</div>
                <div class="kuang5">
                    <div id="gvUseCard" style="height: 140px; overflow: auto; display: block">
                        <asp:GridView ID="gvUseCardOrder" runat="server" Width="120%" CssClass="tab1" HeaderStyle-CssClass="tabbt"
                            FooterStyle-CssClass="tabcon" AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel"
                            PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top"
                            AutoGenerateColumns="false" PageSize="50" OnPageIndexChanging="gvUseCardOrder_Page" AllowPaging="true"
                            OnSelectedIndexChanged="gvUseCardOrder_SelectedIndexChanged" OnRowCreated="gvUseCardOrder_RowCreated"
                            OnRowDataBound="gvResult_RowDataBound">
                            <Columns>
                                <asp:BoundField DataField="APPLYORDERID" HeaderText="需求单号" />
                                <asp:BoundField DataField="ORDERTYPE" HeaderText="需求单类型" />
                                <asp:BoundField DataField="CARDTYPE" HeaderText="卡片类型" />
                                <asp:BoundField DataField="CARDFACE" HeaderText="卡面类型" />
                                <asp:BoundField DataField="CARDSAMPLECODE" HeaderText="卡样编码" />
                                <asp:BoundField DataField="CARDNAME" HeaderText="卡片名称" />
                                <asp:BoundField DataField="WAY" HeaderText="卡面确认方式" />
                                <asp:BoundField DataField="CARDNUM" HeaderText="下单数量" />
                                <asp:BoundField DataField="REQUIREDATE" HeaderText="要求到货日期" />
                                <asp:BoundField DataField="ORDERDEMAND" HeaderText="订单要求" />
                                <asp:BoundField DataField="ALREADYORDERNUM" HeaderText="已订购数量" />
                                <asp:BoundField DataField="ORDERTIME" HeaderText="下单时间" />
                                <asp:BoundField DataField="ORDERSTAFF" HeaderText="下单员工" />
                                <asp:BoundField DataField="REMARK" HeaderText="备注" />
                            </Columns>
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                        <td>
                                            需求单号
                                        </td>
                                        <td>
                                            需求单类型
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
                                            备注
                                        </td>
                                    </tr>
                                </table>
                            </EmptyDataTemplate>
                        </asp:GridView>
                    </div>
                    <div id="gvChargeCard" style="height: 180px; overflow: auto; display: none">
                        <asp:GridView ID="gvChargeCardOrder" runat="server" Width="95%" CssClass="tab1" HeaderStyle-CssClass="tabbt"
                            FooterStyle-CssClass="tabcon" AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel"
                            PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top"
                            AutoGenerateColumns="false" PageSize="50" OnPageIndexChanging="gvChargeCardOrder_Page" AllowPaging="true"
                            OnSelectedIndexChanged="gvChargeCardOrder_SelectedIndexChanged" OnRowCreated="gvChargeCardOrder_RowCreated"
                            OnRowDataBound="gvResult_RowDataBound">
                            <Columns>
                                <asp:BoundField DataField="APPLYORDERID" HeaderText="需求单号" />
                                <asp:BoundField DataField="VALUECODE" HeaderText="充值卡面值" />
                                <asp:BoundField DataField="CARDNUM" HeaderText="下单数量" />
                                <asp:BoundField DataField="REQUIREDATE" HeaderText="要求到货日期" />
                                <asp:BoundField DataField="ORDERDEMAND" HeaderText="订单要求" />
                                <asp:BoundField DataField="ALREADYORDERNUM" HeaderText="已订购数量" />
                                <asp:BoundField DataField="ORDERTIME" HeaderText="下单时间" />
                                <asp:BoundField DataField="ORDERSTAFF" HeaderText="下单员工" />
                                <asp:BoundField DataField="REMARK" HeaderText="备注" />
                            </Columns>
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                        <td>
                                            需求单号
                                        </td>
                                        <td>
                                            面值
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
                                            备注
                                        </td>
                                    </tr>
                                </table>
                            </EmptyDataTemplate>
                        </asp:GridView>
                    </div>
                </div>
            </div>
            <div class="pipinfo2" style="width: 72%" id="supplyUseCard" style="display: block">
                <div class="card">
                    订购单信息填写</div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td>
                                <div align="right">
                                    卡片类型:</div>
                            </td>
                            <td colspan="3">
                                <asp:TextBox ID="txtCardType" CssClass="labeltext" runat="server">
                                </asp:TextBox>
                            </td>
                            <td>
                                <div align="right">
                                    卡面类型:</div>
                            </td>
                            <td>
                                <asp:DropDownList ID="selFaceType" CssClass="inputmid" runat="server" Enabled="false"
                                    AutoPostBack="true" OnSelectedIndexChanged="selFaceType_Change">
                                </asp:DropDownList>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    卡样编号:</div>
                            </td>
                            <td colspan="3">
                                <asp:TextBox ID="txtCardSampleCode" CssClass="labeltext" runat="server" MaxLength="6"></asp:TextBox>
                            </td>
                            <td>
                                <div align="right">
                                    要求到货日期:</div>
                            </td>
                            <td>
                                <asp:TextBox ID="txtDate" CssClass="labeltext" runat="server" MaxLength="8"></asp:TextBox>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    起讫卡号:</div>
                            </td>
                            <td colspan="3">
                                <asp:TextBox ID="txtFromCardNo" CssClass="input" runat="server" MaxLength="16"></asp:TextBox>
                                -
                                <asp:TextBox ID="txtToCardNo" CssClass="input" runat="server" MaxLength="16"></asp:TextBox>
                                <span class="red">*</span>
                            </td>
                            <td>
                                <div align="right">
                                    订购数量:</div>
                            </td>
                            <td>
                                <asp:TextBox ID="txtCardSum" CssClass="labeltext" Width="100" runat="server"></asp:TextBox>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    芯片类型:</div>
                            </td>
                            <td colspan="3">
                                <asp:DropDownList ID="selChipType" CssClass="input" runat="server">
                                </asp:DropDownList><span class="red">*</span>
                            </td>
                            <td>
                                <div align="right">
                                    COS类型:</div>
                            </td>
                            <td>
                                <asp:DropDownList ID="selCosType" CssClass="input" runat="server">
                                </asp:DropDownList>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    有效日期:</div>
                            </td>
                            <td colspan="3">
                                <asp:TextBox runat="server" ID="txtEffDate" CssClass="input" MaxLength="8" />
                                -
                                <asp:TextBox runat="server" ID="txtExpDate" CssClass="input" MaxLength="8" />
                                <ajaxToolkit:CalendarExtender ID="FCalendar" runat="server" TargetControlID="txtEffDate"
                                    Format="yyyyMMdd" />
                                <ajaxToolkit:CalendarExtender ID="ECalendar" runat="server" TargetControlID="txtExpDate"
                                    Format="yyyyMMdd" />
                                <span class="red">*</span>
                            </td>
                            <td>
                                <div align="right">
                                    卡片厂商:</div>
                            </td>
                            <td>
                                <asp:DropDownList ID="selProducer" CssClass="input" runat="server">
                                </asp:DropDownList><span class="red">*</span>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    备注:</div>
                            </td>
                            <td colspan="3">
                                <asp:TextBox ID="txtReMark" runat="server" CssClass="inputlong" Width="240px"></asp:TextBox>
                            </td>
                            <td>
                                <div align="right">
                                    应用版本:</div>
                            </td>
                            <td>
                                <asp:TextBox ID="txtAppVersion" runat="server" Text="02" CssClass="input" MaxLength="2"></asp:TextBox>
                                <span class="red">*</span>
                            </td>
                        </tr>
                    </table>
                </div>
            </div>
            <div class="basicinfo2" style="margin-left: 73.3%" id="supplyUseCardNo" style="display: block">
                <div class="jieguo">
                    卡号段</div>
                <div class="kuang5">
                    <div class="gdtb" style="height: 150px; overflow: auto">
                        <asp:GridView ID="gvResult" runat="server" Width="95%" CssClass="tab1" HeaderStyle-CssClass="tabbt"
                            FooterStyle-CssClass="tabcon" AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel"
                            PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top"
                            AutoGenerateColumns="False" OnSelectedIndexChanged="gvResult_SelectedIndexChanged"
                            OnRowCreated="gvResult_RowCreated">
                            <Columns>
                                <asp:BoundField DataField="startcardno" HeaderText="起始卡号" />
                                <asp:BoundField DataField="endcardno" HeaderText="结束卡号" />
                                <asp:BoundField DataField="cardnum" HeaderText="数量" />
                            </Columns>
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                        <td>
                                            起始卡号
                                        </td>
                                        <td>
                                            结束卡号
                                        </td>
                                        <td>
                                            数量
                                        </td>
                                    </tr>
                                </table>
                            </EmptyDataTemplate>
                        </asp:GridView>
                    </div>
                </div>
            </div>
            <div class="con" id="supplyChargeCard" style="display: none">
                <div class="card">
                    订购单信息填写</div>
                <div class="kuang5" style="height: 90px">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td>
                                <div align="right">
                                    面值:</div>
                            </td>
                            <td colspan="3">
                                <asp:TextBox ID="txtCardValue" CssClass="labeltext" runat="server">
                                </asp:TextBox>
                            </td>
                            <td>
                                <div align="right">
                                    要求到货日期:</div>
                            </td>
                            <td>
                                <asp:TextBox ID="txtChargeCardDate" CssClass="labeltext" runat="server" MaxLength="8"></asp:TextBox>
                            </td>
                        </tr>
                        <tr>
                             <td>
                                <div align="right">
                                    卡片厂商:</div>
                            </td>
                            <td colspan="3">
                                <asp:DropDownList ID="ddlProducer" CssClass="input" runat="server" 
                                     AutoPostBack="true" OnSelectedIndexChanged="ddlProducer_change">
                                </asp:DropDownList><span class="red">*</span>
                            </td>
                             <td>
                                <div align="right">
                                    订购数量:</div>
                            </td>
                            <td>
                                <asp:TextBox ID="txtChargeCardNum" CssClass="labeltext" runat="server" MaxLength="8"></asp:TextBox>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    起讫卡号:</div>
                            </td>
                            <td colspan="3">
                                <asp:TextBox ID="txtFromChargeCardno" CssClass="input" runat="server" MaxLength="14"></asp:TextBox>
                                -
                                <asp:TextBox ID="txtToChargeCardno" CssClass="input" runat="server" MaxLength="14"></asp:TextBox>
                                <span class="red">*</span>
                            </td>
                            <td>
                                <div align="right">
                                    批次号:</div>
                            </td>
                            <td>
                                <asp:TextBox ID="txtBATCHNO" runat="server"  CssClass="input" MaxLength="2" ReadOnly="True" 
                                  ></asp:TextBox>
                                <span class="red">*</span>
                                <asp:HiddenField id = "hidBatchno" runat="server" />
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    有效日期:</div>
                            </td>
                            <td colspan="3">
                                <asp:TextBox runat="server" ID="txtEffectiveDate" CssClass="input" MaxLength="8" />
                               
                                <ajaxToolkit:CalendarExtender ID="CalendarExtender1" runat="server" TargetControlID="txtEffectiveDate"
                                    Format="yyyyMMdd" />
                                
                                <span class="red">*</span>
                            </td>
                 <td>
                                <div align="right">
                                    备注:</div>
                            </td>
                            <td >
                                <asp:TextBox ID="txtChargeReMark" runat="server" CssClass="inputlong" Width="240px"></asp:TextBox>
                            </td>
                        </tr>
                       
                    </table>
                </div>
            </div>
            <div class="btns">
                <table width="200" border="0" align="right" cellpadding="0" cellspacing="0">
                    <tr>
                        <td>
                            <asp:Button ID="btnPrint" Enabled="false" CssClass="button1" runat="server" Text="打印订购单"
                                OnClick="btnPrint_Click" />
                        </td>
                        <td>
                            <asp:Button ID="btnSubmit" Enabled="false" CssClass="button1" runat="server" Text="提交"
                                OnClick="btnSubmit_Click" />
                        </td>
                    </tr>
                </table>
                <asp:CheckBox ID="chkOrder" runat="server" Checked="true" />自动打印订购单
            </div>
            <div style="display:none" runat="server" id="printarea"></div>
        </ContentTemplate>
    </asp:UpdatePanel>
    </form>
</body>
</html>

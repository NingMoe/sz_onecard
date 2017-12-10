<%@ Page Language="C#" AutoEventWireup="true" CodeFile="RM_SignInStorage.aspx.cs"
    Inherits="ASP_ResourceManage_RM_SignInStorage" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>签收入库</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="../../js/myext.js"></script>
    <script type="text/javascript" src="../../js/RMHelper.js"></script>
    <script type="text/javascript" src="../../js/printorder.js"></script>
    <script type="text/javascript" language="javascript">
        function SelectUseCard() {
            if ($get('hidCardType').value != "usecard") {
                $get('txtFromCardNo').value = "";
                $get('txtToCardNo').value = "";
                $get('txtCardno').value = "";
            }
            $get('hidCardType').value = "usecard";

            //提交部分，显示用户卡，其他隐藏
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
            if ($get('hidCardType').value != "chargecard") {
                $get('txtFromCardNo').value = "";
                $get('txtToCardNo').value = "";
                $get('txtCardno').value = "";
            }
            $get('hidCardType').value = "chargecard";

            //提交部分，显示充值卡，其他隐藏
            supplyUseCard.style.display = "none";
            supplyChargeCard.style.display = "block";
            //Gridview部分，显示充值卡，其他隐藏
            gvUseCard.style.display = "none";
            gvChargeCard.style.display = "block";

            chargecard.className = "on";
            usecard.className = null;
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
        卡片管理->签收入库
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
                    签收入库</div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td width="12%">
                                <div align="right">
                                    起讫卡号:</div>
                            </td>
                            <td width="60%" colspan="5">
                                <asp:TextBox ID="txtFromCardNo" CssClass="inputmid" runat="server" MaxLength="16"></asp:TextBox>
                                -
                                <asp:TextBox ID="txtToCardNo" CssClass="inputmid" runat="server" MaxLength="16"></asp:TextBox>
                                <span class="red">*</span>
                            </td>
                            <td width="12%" align="right">
                                
                            </td>
                            <td width="12%">
                            </td>
                        </tr>
                    </table>
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td width="12%">
                                <div align="right">
                                    导入文件:</div>
                            </td>
                            <td>
                                <asp:FileUpload ID="FileUpload1" runat="server" CssClass="inputlong" />
                                <asp:Button ID="btnUpload" CssClass="button1" runat="server" Text="导入" OnClick="btnUpload_Click" />
                            </td>
                        </tr>
                    </table>
                </div>
                <div class="btns">
                <table width="200" border="0" align="right" cellpadding="0" cellspacing="0">
                    <tr>
                        <td width="80%">
                            <asp:Button ID="btnPrint" Text="打印入库单" CssClass="button1" runat="server" OnClick="btnPrint_Click" />&nbsp;
                        </td>
                        <td align="center">
                            &nbsp;&nbsp;
                            <asp:Button ID="btnSubmit" Enabled="true" CssClass="button1" runat="server" Text="提交" OnClick="btnSubmit_Click" />
                        </td>
                    </tr>
                </table>
                <asp:CheckBox ID="chkOrder" runat="server" Checked="true" />自动打印入库单
            </div>
            </div>
            <div class="con">
                <div class="card">查询</div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td width="12%">
                                <div align="right">
                                    卡号:</div>
                            </td>
                            <td width="36%" colspan="3">
                                <asp:TextBox ID="txtCardno" CssClass="input" MaxLength="16" runat="server">
                                </asp:TextBox>
                            </td>
                            <td width="12%">
                            </td>
                            <td width="12%">
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
                    所属需求单详细信息</div>
                <div class="kuang5">
                    <table id="supplyUseCard" width="95%" border="0" cellpadding="0" cellspacing="0"
                        class="text25" style="display: block">
                        <tr>
                            <td width="12%">
                                <div align="right">
                                    需求单号:</div>
                            </td>
                            <td width="12%">
                                <asp:Label ID="txtCardOrderID" runat="server">
                                </asp:Label>
                            </td>
                            <td width="12%">
                                <div align="right">
                                    需求类型:</div>
                            </td>
                            <td width="12%">
                                <asp:Label ID="txtOrderType" runat="server">
                                </asp:Label>
                            </td>
                            <td width="12%">
                                <div align="right">
                                    卡片类型:</div>
                            </td>
                            <td width="12%">
                                <asp:Label ID="txtCardType" runat="server">
                                </asp:Label>
                            </td>
                            <td width="12%">
                                <div align="right">
                                    卡面类型:</div>
                            </td>
                            <td width="12%">
                                <asp:Label ID="txtCardFace" runat="server">
                                </asp:Label>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    卡片名称:</div>
                            </td>
                            <td>
                                <asp:Label ID="txtCardName" runat="server"></asp:Label>
                            </td>
                            <td>
                                <div align="right">
                                    下单数量:</div>
                            </td>
                            <td>
                                <asp:Label ID="txtCardSum" runat="server"></asp:Label>
                            </td>
                            <td>
                                <div align="right">
                                    要求到货日期:</div>
                            </td>
                            <td>
                                <asp:Label ID="txtDate" runat="server"></asp:Label>
                            </td>
                            <td>
                                <div align="right">
                                    最近到货日期:</div>
                            </td>
                            <td>
                                <asp:Label runat="server" ID="txtLatelyDate" />
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    已到货数量:</div>
                            </td>
                            <td>
                                <asp:Label runat="server" ID="txtAlreadyArriveNum" />
                            </td>
                            <td>
                                <div align="right">
                                    退货数量:</div>
                            </td>
                            <td>
                                <asp:Label runat="server" ID="txtReturnNum" />
                            </td>
                            <td>
                                <div align="right">
                                    下单员工:</div>
                            </td>
                            <td>
                                <asp:Label ID="txtOrderStaff" runat="server">
                                </asp:Label>
                            </td>
                            <td>
                                <div align="right">
                                    下单时间:</div>
                            </td>
                            <td>
                                <asp:Label ID="txtOrderTime" runat="server">
                                </asp:Label>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    备注:</div>
                            </td>
                            <td colspan="7">
                                <asp:Label ID="txtRemark" runat="server">
                                </asp:Label>
                            </td>
                        </tr>
                    </table>
                    <table id="supplyChargeCard" width="95%" border="0" cellpadding="0" cellspacing="0"
                        class="text25" style="display: none">
                        <tr>
                            <td width="12%">
                                <div align="right">
                                    需求单号:</div>
                            </td>
                            <td width="12%">
                                <asp:Label ID="txtChargeCardOrderID" runat="server">
                                </asp:Label>
                            </td>
                            <td width="12%">
                                <div align="right">
                                    需求类型:</div>
                            </td>
                            <td width="12%">
                                <asp:Label ID="txtChargeApplyType" runat="server">
                                </asp:Label>
                            </td>
                            <td width="12%">
                                <div align="right">
                                    面值:</div>
                            </td>
                            <td width="12%">
                                <asp:Label ID="txtCardValue" runat="server"></asp:Label>
                            </td>
                            <td width="12%">
                                <div align="right">
                                    下单数量:</div>
                            </td>
                            <td width="12%">
                                <asp:Label ID="txtChargeCardNum" runat="server"></asp:Label>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    要求到货日期:</div>
                            </td>
                            <td>
                                <asp:Label ID="txtChargeDate" runat="server"></asp:Label>
                            </td>
                            <td>
                                <div align="right">
                                    最近到货日期:</div>
                            </td>
                            <td>
                                <asp:Label ID="txtChargeLatelyDate" runat="server"></asp:Label>
                            </td>
                            <td>
                                <div align="right">
                                    已到货数量:</div>
                            </td>
                            <td>
                                <asp:Label ID="txtChargeAlreadyArriveNum" runat="server">
                                </asp:Label>
                            </td>
                            <td>
                                <div align="right">
                                    退货数量:</div>
                            </td>
                            <td>
                                <asp:Label ID="txtChargeReturnNum" runat="server"></asp:Label>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    下单时间:</div>
                            </td>
                            <td>
                                <asp:Label ID="txtChargeOrderTime" runat="server"></asp:Label>
                            </td>
                            <td>
                                <div align="right">
                                    下单员工:</div>
                            </td>
                            <td>
                                <asp:Label ID="txtChargeOrderStaff" runat="server">
                                </asp:Label>
                            </td>
                            <td>
                                <div align="right">
                                    备注:</div>
                            </td>
                            <td colspan="3">
                                <asp:Label ID="txtChargeRemark" runat="server">
                                </asp:Label>
                            </td>
                        </tr>
                    </table>
                </div>
                <div class="jieguo">
                    订购单信息</div>
                <div class="kuang5">
                    <div id="gvUseCard" style="height: 130px; overflow: auto; display: block">
                        <asp:GridView ID="gvResultUseCard" runat="server" Width="150%" CssClass="tab1" HeaderStyle-CssClass="tabbt"
                            FooterStyle-CssClass="tabcon" AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel"
                            PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top"
                            AutoGenerateColumns="false">
                            <Columns>
                                <asp:BoundField DataField="CARDORDERID" HeaderText="订购单号" />
                                <asp:BoundField DataField="ORDERTYPE" HeaderText="订购类型" />
                                <asp:BoundField DataField="CARDTYPE" HeaderText="卡片类型" />
                                <asp:BoundField DataField="CARDFACE" HeaderText="卡面类型" />
                                <asp:BoundField DataField="CARDNAME" HeaderText="卡片名称" />
                                <asp:BoundField DataField="CARDNUM" HeaderText="订购数量" />
                                <asp:BoundField DataField="BEGINCARDNO" HeaderText="起始卡号" />
                                <asp:BoundField DataField="ENDCARDNO" HeaderText="结束卡号" />
                                <asp:BoundField DataField="REQUIREDATE" HeaderText="要求到货日期" />
                                <asp:BoundField DataField="LATELYDATE" HeaderText="最近到货日期" />
                                <asp:BoundField DataField="ALREADYARRIVENUM" HeaderText="已到货数量" />
                                <asp:BoundField DataField="RETURNCARDNUM" HeaderText="退货数量" />
                                <asp:BoundField DataField="MANUNAME" HeaderText="卡片厂商" />
                                <asp:BoundField DataField="ORDERTIME" HeaderText="下单时间" />
                                <asp:BoundField DataField="STAFF" HeaderText="下单员工" />
                                <asp:BoundField DataField="REMARK" HeaderText="备注" />
                            </Columns>
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                        <td>
                                            订购单号
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
                                            卡片名称
                                        </td>
                                        <td>
                                            订购数量
                                        </td>
                                        <td>
                                            起始卡号
                                        </td>
                                        <td>
                                            结束卡号
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
                                            卡片厂商
                                        </td>
                                        <td>
                                            下单时间
                                        </td>
                                        <td>
                                            下单员工
                                        </td>
                                        <td>
                                            备注
                                        </td>
                                    </tr>
                                </table>
                            </EmptyDataTemplate>
                        </asp:GridView>
                    </div>
                    <div id="gvChargeCard" style="height: 150px; overflow: auto; display: none">
                        <asp:GridView ID="gvResultChargeCard" runat="server" Width="95%" CssClass="tab1"
                            HeaderStyle-CssClass="tabbt" FooterStyle-CssClass="tabcon" AlternatingRowStyle-CssClass="tabjg"
                            SelectedRowStyle-CssClass="tabsel" PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left"
                            PagerStyle-VerticalAlign="Top" AutoGenerateColumns="false">
                            <Columns>
                                <asp:BoundField DataField="CARDORDERID" HeaderText="订购单号" />
                                <asp:BoundField DataField="CARDVALUE" HeaderText="面值" />
                                <asp:BoundField DataField="CARDNUM" HeaderText="订购数量" />
                                <asp:BoundField DataField="BEGINCARDNO" HeaderText="起始卡号" />
                                <asp:BoundField DataField="ENDCARDNO" HeaderText="结束卡号" />
                                <asp:BoundField DataField="REQUIREDATE" HeaderText="要求到货日期" />
                                <asp:BoundField DataField="LATELYDATE" HeaderText="最近到货日期" />
                                <asp:BoundField DataField="ALREADYARRIVENUM" HeaderText="已到货数量" />
                                <asp:BoundField DataField="RETURNCARDNUM" HeaderText="退货数量" />
                                <asp:BoundField DataField="ORDERTIME" HeaderText="下单时间" />
                                <asp:BoundField DataField="STAFF" HeaderText="下单员工" />
                                <asp:BoundField DataField="REMARK" HeaderText="备注" />
                            </Columns>
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                        <td>
                                            订购单号
                                        </td>
                                        <td>
                                            面值
                                        </td>
                                        <td>
                                            订购数量
                                        </td>
                                        <td>
                                            起始卡号
                                        </td>
                                        <td>
                                            结束卡号
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
                                            下单时间
                                        </td>
                                        <td>
                                            下单员工
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
            <div style="display:none" runat="server" id="printarea"></div>
        </ContentTemplate>
           <Triggers>
    <asp:PostBackTrigger ControlID="btnUpload" />
    </Triggers>  
    </asp:UpdatePanel>
    </form>
</body>
</html>

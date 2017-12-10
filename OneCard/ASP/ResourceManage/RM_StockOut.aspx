<%@ Page Language="C#" AutoEventWireup="true" EnableEventValidation="false" CodeFile="RM_StockOut.aspx.cs" Inherits="ASP_ResourceManage_RM_StockOut" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>出库</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="../../js/myext.js"></script>
    <script type="text/javascript" src="../../js/mootools.js"></script>
    <script type="text/javascript" src="../../js/RMHelper.js"></script>
    <script type="text/javascript" src="../../js/printorder.js"></script>
    <script type="text/javascript" language="javascript">
        function SelectUseCard() {
            $get('hidCardType').value = "usecard";

            //提交部分，显示存货补货，其他隐藏
            supplyUseCard.style.display = "block";
            supplyChargeCard.style.display = "none";
            //Gridview部分，显示充值卡，其他隐藏
            gvUseCard.style.display = "block";
            gvChargeCard.style.display = "none";

            usecard.className = "on";
            
            div1.style.display = "block";
            
            chargecard.className = null;

            return false;
        }
        function SelectChargeCard() {
            $get('hidCardType').value = "chargecard";

            //提交部分，显示充值卡，其他隐藏
            supplyUseCard.style.display = "none";
            supplyChargeCard.style.display = "block";
            //Gridview部分，显示充值卡，其他隐藏
            gvUseCard.style.display = "none";
            gvChargeCard.style.display = "block";

            usecard.className = null;
            chargecard.className = "on";
            div1.style.display = "none";
            return false;
        }
        function Change()
        {
            var sFCard = $('txtFromCardNo').value;
            var sECard = $('txtToCardNo').value;
            var lCardSum = 0;

            if(sFCard.test("^\\s*\\d{16}\\s*$") && sECard.test("\\s*^\\d{16}\\s*$"))
            {
                var lFCard = sFCard.toInt();
                var lECard = sECard.toInt();
                if(lECard - lFCard >= 0)
                    lCardSum = lECard - lFCard + 1;
            }
            

            $('txtCardSum').value = lCardSum;
        }
        
        function ChargeCardChange()
        {
            var sFCard = $('txtStartCardNo').value.substring(6, 14);
            var sECard = $('txtEndCardNo').value.substring(6, 14);
            var lCardSum = 0;
            if(sFCard.test("^\\s*\\d{8}\\s*$") && sECard.test("\\s*^\\d{8}\\s*$"))
            {
                var lFCard = sFCard.toInt();
                var lECard = sECard.toInt();
                if(lECard - lFCard >= 0)
                    lCardSum = lECard - lFCard + 1;
            }
            $('txtTotalCardNum').value = lCardSum;
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
        卡片管理->出库
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
                                    领用单号:</div>
                            </td>
                            <td width="12%">
                                <asp:TextBox runat="server" ID="txtGetApplyNo" Text="LY" CssClass="inputmid" MaxLength="18"></asp:TextBox>
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
                        <tr>
                            <td width="12%">
                                <div align="right">
                                    领用员工:</div>
                            </td>
                            <td width="12%">
                                <asp:DropDownList ID="ddlAssignedStaff" CssClass="input" runat="server" AutoPostBack="true" OnSelectedIndexChanged="selAssignedStaff_Change"></asp:DropDownList>
                            </td>
                            <td width="12%">
                                <div align="right">
                                    领用状态:</div>
                            </td>
                            <td width="12%">
                                <asp:DropDownList ID="ddlAssignedState" CssClass="input" runat="server"></asp:DropDownList>
                            </td>
                            <td width="12%">
                                <div align="right">
                                    打印状态:</div>
                            </td>
                            <td width="12%">
                                <asp:DropDownList ID="ddlPrintState" CssClass="input" runat="server"></asp:DropDownList>
                            </td>
                        </tr>
                    </table>
                </div>
            <div class="jieguo">
                    领用单</div>
                <div class="kuang5">
                <div id="gvUseCard" style="height: 160px;overflow:auto; display: block">
                        <asp:GridView ID="gvResultUseCard" runat="server" Width="100%" CssClass="tab1" HeaderStyle-CssClass="tabbt"
                            FooterStyle-CssClass="tabcon" AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel"
                            PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top"
                            AutoGenerateColumns="false" AllowPaging="true" PageSize=20 OnPageIndexChanging="gvResultUseCard_Page"
                            OnRowCreated="gvResultUseCard_RowCreated" OnSelectedIndexChanged="gvResultUseCard_SelectedIndexChanged">
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
                                <asp:BoundField DataField="cardtypename" HeaderText="卡片类型" />
                                <asp:BoundField DataField="cardsurfacename" HeaderText="卡面类型" />
                                <asp:BoundField DataField="applygetnum" HeaderText="申请领用数量" />
                                <asp:BoundField DataField="agreegetnum" HeaderText="同意领用数量" />
                                <asp:BoundField DataField="alreadygetnum" HeaderText="已经领用数量" />
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
                                            已领用数量
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
                   <div id="gvChargeCard" style="height: 160px;overflow:auto; display: none">
                        <asp:GridView ID="gvResultChargeCard" runat="server" Width="95%" CssClass="tab1" HeaderStyle-CssClass="tabbt"
                            FooterStyle-CssClass="tabcon" AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel"
                            PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top"
                            AutoGenerateColumns="false" AllowPaging="true" PageSize=20
                            OnPageIndexChanging="gvResultChargeCard_Page" 
                            OnRowCreated="gvResultChargeCard_RowCreated">
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
                                <asp:BoundField DataField="value" HeaderText="面值" />
                                <asp:BoundField DataField="applygetnum" HeaderText="申请领用数量" />
                                <asp:BoundField DataField="agreegetnum" HeaderText="同意领用数量" />
                                <asp:BoundField DataField="alreadygetnum" HeaderText="已经领用数量" />
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
                                            已领用数量
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
                </div>
                
                <div class="card">
                    出库信息</div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25" id="supplyUseCard" style="display: block">
                        <tr>
                            <td width="12%">
                                <div align="right">
                                    起讫卡号:</div>
                            </td>
                            <td width="30%" colspan="3">
                                <asp:TextBox ID="txtFromCardNo" CssClass="input" runat="server" MaxLength="16"></asp:TextBox>
                                -
                                <asp:TextBox ID="txtToCardNo" CssClass="input" runat="server" MaxLength="16" 
                                AutoPostBack="true" OnTextChanged="txtToCardNo_Changed"></asp:TextBox>
                                <span class="red">*</span>
                                <div align="right">
                                </div>
                            </td>
                            <td width="12%">
                                <div align="right">
                                    出库数量:</div>
                            </td>
                            <td width="12%">
                                <asp:TextBox ID="txtCardSum" CssClass="labeltext" Width="100" runat="server"></asp:TextBox>
                            </td>
                            <td width="12%">
                                <div align="right">
                                    卡面类型:</div>
                            </td>
                            <td width="20%">
                                <asp:TextBox ID="txtFaceType" CssClass="labeltext" runat="server" MaxLength="8"></asp:TextBox>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    领用员工:</div>
                            </td>
                            <td colspan="3">
                                <asp:DropDownList ID="selAssignedStaff" CssClass="input" runat="server" AutoPostBack="true" OnSelectedIndexChanged="selAssignedStaff_Change">
                                </asp:DropDownList>
                            </td>
                            <td>
                                <div align="right">
                                    售卡方式:</div>
                            </td>
                            <td>
                                <asp:DropDownList ID="selSaleType" CssClass="input" runat="server" AutoPostBack="true" OnSelectedIndexChanged="selSellType_change"></asp:DropDownList>
                            </td>
                            <td>
                                <div align="right">
                                    服务周期:</div>
                            </td>
                            <td>
                                <asp:DropDownList ID="selServiceCycle" CssClass="input" runat="server" Enabled="false">
                                </asp:DropDownList>
                            </td>
                            
                        </tr>
                        <tr>
                        <td>
                                <div align="right">
                                    服务费 :</div>
                            </td>
                            <td colspan="3">
                                <asp:TextBox ID="txtServiceFee" CssClass="input" runat="server" MaxLength="13" Enabled="false" Text="0"></asp:TextBox>
                                <span class="red">*</span> 100分
                            </td>
                            <td>
                                <div align="right">
                                    退值 :</div>
                            </td>
                            <td>
                                <asp:DropDownList ID="selRetValMode" CssClass="input" runat="server">
                                </asp:DropDownList>
                            </td>
                            
                            <td>
                                <div align="right">
                                    卡片单价:</div>
                            </td>
                            <td>
                                <asp:TextBox ID="txtCardPrice" CssClass="input" runat="server" MaxLength="13"></asp:TextBox>
                                <span class="red">*</span> 100分
                            </td>
                        </tr>
                    </table>
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25" id="supplyChargeCard" style="display: none">
                        <tr>
                            <td width="12%">
                                <div align="right">
                                    起讫卡号:</div>
                            </td>
                            <td width="30%" colspan="3">
                                <asp:TextBox ID="txtStartCardNo" CssClass="input" runat="server" MaxLength="14"></asp:TextBox>
                                -
                                <asp:TextBox ID="txtEndCardNo" CssClass="input" runat="server" MaxLength="14" 
                                AutoPostBack="true" OnTextChanged="txtEndCardNo_Changed"></asp:TextBox>
                                <span class="red">*</span>
                                <div align="right">
                                </div>
                            </td>
                            <td width="12%">
                                <div align="right">
                                    出库数量:</div>
                            </td>
                            <td width="12%">
                                <asp:TextBox ID="labQuantity" CssClass="labeltext" Width="100" runat="server"></asp:TextBox>
                            </td>
                            <td width="12%">
                                <div align="right">
                                    总面值:</div>
                            </td>
                            <td width="20%">
                                <asp:TextBox ID="labTotalValue" CssClass="labeltext" runat="server" MaxLength="8"></asp:TextBox>
                            </td>
                        </tr>
                        <tr>
                        
                        <td>
                            <div align="right">领用部门:</div>
                        </td>
                            <td>
                                <asp:DropDownList ID="selDept" CssClass="inputmid" runat="server" AutoPostBack="true" OnSelectedIndexChanged="selDept_Changed"></asp:DropDownList>
                            </td>
                            <td width="12%"><div align="right">领用员工:</div></td>
                            <td>
                                <asp:DropDownList ID="selStaff" CssClass="inputmid" runat="server"></asp:DropDownList>
                            </td>
                        
                            <%--<td>
                                <div align="right">
                                    领用部门:</div>
                            </td>
                            <td colspan="7">
                                <asp:DropDownList ID="selAssignedDepart" CssClass="input" runat="server">
                                </asp:DropDownList>
                            </td>--%>
                        </tr>
                    </table>
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25" id="Table1" style="display: block">
                    <tr>
                        <td width="12%" >
                                <div align="right">
                                    导入文件:</div>
                            </td>
                            <td width="30%" colspan="3">
                                <asp:FileUpload ID="FileUpload1" runat="server" CssClass="inputlong" />
                               
                            </td>
                            <td width="12%">
                             <asp:Button ID="btnUpload" CssClass="button1" runat="server" Text="导入" OnClick="btnUpload_Click" />
                            </td>
                            <td width="12%">
                            </td>
                            <td width="12%">
                            </td>
                            <td width="20%">
                            </td>

                        </tr>
                    </table>
                    <div id="div1">
                    <div class="linex">
                    </div>
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td style="width: 12%" align="right">
                                保证金余额:
                            </td>
                            <td style="width: 12%">
                                <asp:Label ID="labDeposit" runat="server" />
                            </td>
                            <td style="width: 12%" align="right">
                                可领卡价值额度:
                            </td>
                            <td style="width: 12%">
                                <asp:Label ID="labUsablevalue" runat="server" />
                            </td>
                            <td style="width: 12%" align="right">
                                网点剩余卡价值:
                            </td>
                            <td style="width: 12%">
                                <asp:Label ID="labStockvalue" runat="server" />
                            </td>
                        </tr>
                        <tr>
                          <td style="width: 12%" align="right">
                              最大可领卡数：
                          </td>
                          <td style="width: 12%" colspan="5">
                              <asp:Label ID="labMaxAvailaCard" runat="server" />
                          </td>
                        </tr>
                    </table>
                    </div>
                </div>
            </div>
            <div class="btns">
                <table width="200" border="0" align="right" cellpadding="0" cellspacing="0">
                    <tr>
                        <td width="80%">
                            <asp:Button ID="btnPrint" Text="打印领用单" CssClass="button1" runat="server" OnClick="btnPrint_Click" />&nbsp;
                        </td>
                        <td align="center">
                            <asp:Button ID="btnSubmit" Enabled="true" CssClass="button1" runat="server" Text="提交"
                                OnClick="btnSubmit_Click" />
                        </td>
                    </tr>
                </table>
                <%--<asp:CheckBox ID="chkOrder" runat="server" Checked="true" />自动打印出库单--%>
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

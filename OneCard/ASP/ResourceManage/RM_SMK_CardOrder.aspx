<%@ Page Language="C#" AutoEventWireup="true" CodeFile="RM_SMK_CardOrder.aspx.cs" Inherits="ASP_ResourceManage_RM_SMK_CardOrder"
    EnableEventValidation="false" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>市民卡下单申请</title>
    <%--<link rel="stylesheet" type="text/css" href="../../css/frame.css" />--%>
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="../../js/mootools.js"></script>
    <script type="text/javascript" src="../../js/myext.js"></script>
    <script type="text/javascript" src="../../js/RMHelper.js"></script>
    
    <script type="text/javascript" src="../../js/printorder.js"></script>
    
    <script type="text/javascript" language="javascript">
        function SelectUseCard() {
            $get('hidCardType').value = "usecard";

            fileLable.style.visibility = "visible";
            fileList.style.visibility = "visible";
            //Gridview部分，显示充值卡，其他隐藏

            usecard.className = "on";
            chargecard.className = null;

            return false;
        }
        function SelectChargeCard() {
            $get('hidCardType').value = "chargecard";

            fileLable.style.visibility = "hidden";
            fileList.style.visibility = "hidden";
            //Gridview部分，显示充值卡，其他隐藏
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
        资源管理->市民卡下单申请
    </div>
    <ajaxToolkit:ToolkitScriptManager EnableScriptGlobalization="true" EnableScriptLocalization="true"
        ID="ScriptManager1" runat="server"  AsyncPostBackTimeout="360000"/>
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
                                        onmouseout="mout();" OnClientClick="return SelectUseCard()"><span class="signA">成品卡</span></asp:LinkButton></li>
                                <li runat="server" id="lichargecard" visible="true">
                                    <asp:LinkButton ID="chargecard" Target="_top" runat="server" onmouseover="mover(this);"
                                        onmouseout="mout();" OnClientClick="return SelectChargeCard()"><span class="signB">半成品卡</span></asp:LinkButton></li>
                            </ul>
                        </td>
                    </tr>
                </table>
            </div>
            <div class="pipinfo2" style="width: 72%">
                <div class="card">
                    订购单信息填写</div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25" height="150px">
                        <tr>
                            <td  id="fileLable">
                                <div align="right">
                                制卡文件名:</div>
                            </td>
                            <td id="fileList">
                                <asp:DropDownList ID="selFileName" CssClass="inputlong" runat="server"
                                    AutoPostBack="true" OnSelectedIndexChanged="selFileName_Change">
                                </asp:DropDownList><span class="red">*</span>
                            </td>
                            <td >
                                <div align="right">
                                    卡厂商:</div>
                            </td>
                            <td>
                                <asp:DropDownList ID="selManu" CssClass="inputmid" runat="server">
                                </asp:DropDownList><span class="red">*</span>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    批次号:</div>
                            </td>
                            <td>
                                <asp:TextBox ID="txtBatchNo" CssClass="input" runat="server" MaxLength="12"></asp:TextBox><span class="red">*</span>
                            </td>
                            <td>
                                <div align="right">
                                    订购数量:</div>
                            </td>
                            <td>
                                <asp:TextBox ID="txtCardSum" CssClass="input" runat="server"></asp:TextBox><span class="red">*</span>
                            </td>
                            <td>
                                <asp:LinkButton ID="linkCreateCard" runat="server" Text="生成卡号" OnClick="linkCreateCard_OnClick"></asp:LinkButton>
                                <asp:LinkButton ID="linkGetCard" runat="server" Text="获取卡号" OnClick="linkGetCard_OnClick"></asp:LinkButton>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    批次日期:</div>
                            </td>
                            <td>
                            <ajaxToolkit:CalendarExtender ID="BeginCalendar" runat="server" TargetControlID="txtDate"
                                    Format="yyyyMMdd" PopupPosition="BottomLeft" />
                                <asp:TextBox ID="txtDate" CssClass="input" runat="server" MaxLength="8"></asp:TextBox><span class="red">*</span>
                            </td>
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
                                    </div>
                            </td>
                            <td>
                            </td>
                        </tr>
                    </table>
                </div>
            </div>
            <div class="basicinfo2" style="margin-left: 73.3%" style="display: block">
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
            <div class="btns">
                <table width="200" border="0" align="right" cellpadding="0" cellspacing="0">
                    <tr>
                        <td>
                        </td>
                        <td>
                            <asp:Button ID="btnSubmit" CssClass="button1" runat="server" Text="提交"
                                OnClick="btnSubmit_Click" />
                        </td>
                    </tr>
                </table>
                <%--<asp:CheckBox ID="chkOrder" runat="server" Checked="true" />自动打印订购单--%>
            </div>
            <div style="display:none" runat="server" id="printarea"></div>
        </ContentTemplate>
    </asp:UpdatePanel>
    </form>
</body>
</html>

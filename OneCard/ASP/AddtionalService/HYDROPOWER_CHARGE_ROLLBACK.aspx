<%@ Page Language="C#" AutoEventWireup="true" CodeFile="HYDROPOWER_CHARGE_ROLLBACK.aspx.cs" Inherits="ASP_PersonalBusiness_HYDROPOWER_CHARGE_ROLLBACK" %>

<%@ Register Src="../../CardReader.ascx" TagName="CardReader" TagPrefix="cr" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>公共事业代缴返销</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <script type="text/javascript" src="../../js/print.js"></script>
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" language="javascript">
        function $(_sId) {
            return window.document.getElementById(_sId);
        }
        function checkQuery() {
            var msg = "";
            //var selItemCodeValue = $('selItemCode').value.trim();
            var txtAccountIdValue = $('txtAccountId').value.trim();
            //if (selItemCodeValue == '') {
            //    msg += "请选择缴费类别</br>";
            //}
            if (txtAccountIdValue == '') {
                msg += "请输入用户号</br>";
            }
            if (msg == "") {
                return true;
            } else {
                MyExtAlert('操作提示', msg);
                return false;
            }
        }
    </script>
    <style>
    </style>
</head>
<body>
    <cr:CardReader ID="cardReader" runat="server" />
    <form id="form1" runat="server">
    <div class="tb">
        附加业务->公共事业代缴返销
    </div>
    <object classid="clsid:016E79EE-0B07-46E1-8866-2B679B73898A" id="ICcard" codebase="ICcard.ocx"
        width="0" height="0">
    </object>
    <ajaxToolkit:ToolkitScriptManager runat="Server" EnableScriptGlobalization="true"
        EnableScriptLocalization="true" ID="ScriptManager2" />
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
            <aspControls:PrintPingZheng ID="ptnPingZheng" runat="server" PrintArea="ptnPingZheng1" />
            <aspControls:PrintRMPingZheng ID="PrintRMPingZheng" runat="server" PrintArea="ptnPingZheng2" />
            <asp:BulletedList ID="bulMsgShow" runat="server">
            </asp:BulletedList>
            <script runat="server">public override void ErrorMsgShow() { ErrorMsgHelper(bulMsgShow); }</script>
            <div class="con">
                <div class="kuang5">
                    <table>
                        <tr>
                            <%--<td><span style="margin-left: 30px; font-weight: normal; height: 25px; line-height: 25px; display: block;">缴费类别:</span></td>
                            <td><asp:DropDownList ID="selItemCode" CssClass="inputmid" runat="server"></asp:DropDownList></td>--%>
                            <td><span style="margin-left: 25px;font-weight: normal;height: 25px; line-height: 25px; display: block;">用户号:</span></td>
                            <td><asp:TextBox ID="txtAccountId" CssClass="inputAccountId" runat="server" MaxLength="40" /></td>
                            <td><asp:Button ID="btnQuery" CssClass="buttonTopQuery" runat="server" Text="查询" OnClientClick="return checkQuery()" OnClick="btnQuery_OnClick"/></td>
                            <td>
                                <asp:Button ID="btnReadCard" CssClass="buttonTopQuery" runat="server" Text="读卡"  OnClientClick="return ReadCardInfo()" 
                                    OnClick="btnReadCard_Click" />
                            </td>
                        </tr>
                    </table>
                </div>

                <div class="kuang5">
                    <div style="min-height: 70px">
                        <asp:GridView ID="lvwSupplyQuery" runat="server" Width="95%" CssClass="tab1" HeaderStyle-CssClass="tabbt"
                            AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel" AllowPaging="false"
                            PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top"
                            AutoGenerateColumns="False" ShowFooter="true">
                            <Columns>
                                <asp:BoundField DataField="SEQNO" HeaderText="交易流水号" />
                                <asp:BoundField DataField="CUSTOMER_NO" HeaderText="用户号" />
                                <asp:BoundField DataField="CUSTOMER_NAME" HeaderText="用户姓名" />
                                <asp:BoundField DataField="CARDNO" HeaderText="卡号" />
                                <asp:BoundField DataField="CHARGE_ITEM_TYPE_DISPLAY" HeaderText="缴费项目" />
                                <asp:BoundField DataField="CHARGE_TYPE_DISPLAY" HeaderText="缴费方式" />
                                <asp:BoundField DataField="BILL_MONTH" HeaderText="账单月份" />
                                <asp:BoundField DataField="REAL_AMOUNT" HeaderText="缴费金额" NullDisplayText="0" DataFormatString="{0:n}"
                                    HtmlEncode="false" />
                                <asp:BoundField DataField="REQUEST_TIME" HeaderText="缴费时间" />
                                <asp:BoundField DataField="CHARGE_STATUS_DISPLAY" HeaderText="缴费状态" />
                            </Columns>
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                        <td>
                                            交易流水号
                                        </td>
                                        <td>
                                            用户号
                                        </td>
                                        <td>
                                            用户姓名
                                        </td>
                                        <td>
                                            卡号
                                        </td>
                                        <td>
                                            缴费项目
                                        </td>
                                        <td>
                                            缴费方式
                                        </td>
                                        <td>
                                            账单月份
                                        </td>
                                        <td>
                                            缴费金额:元
                                        </td>
                                        <td>
                                            缴费时间
                                        </td>
                                        <td>
                                            缴费状态
                                        </td>
                                    </tr>
                                </table>
                            </EmptyDataTemplate>
                        </asp:GridView>
                    </div>
                </div>
                
                <div class="card">
                    卡片信息</div>
                <asp:Panel runat="server" CssClass="kuang5" ID="CardInfoContent">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text20">
                        <tr>
                            <td width="9%">
                                <div align="right">
                                    用户卡号:</div>
                            </td>
                            <td width="13%">
                                <asp:TextBox ID="txtCardno" CssClass="labeltext" MaxLength="16" runat="server"></asp:TextBox>
                            </td>
                            <td width="9%">
                                <div align="right">
                                    卡序列号:</div>
                            </td>
                            <td width="13%">
                                <asp:TextBox ID="LabAsn" CssClass="labeltext" runat="server"></asp:TextBox>
                            </td>
                            <asp:HiddenField ID="hiddenAsn" runat="server" />
                            <td width="9%">
                                <div align="right">
                                    卡片类型:</div>
                            </td>
                            <td width="13%">
                                <asp:TextBox ID="LabCardtype" CssClass="labeltext" Width="120" runat="server"></asp:TextBox>
                            </td>
                            <asp:HiddenField ID="hiddenLabCardtype" runat="server" />
                            <td width="9%">
                                <div align="right">
                                    卡片状态:</div>
                            </td>
                            <td width="10%">
                                <asp:TextBox ID="RESSTATE" CssClass="labeltext" runat="server"></asp:TextBox>
                            </td>
                            <asp:HiddenField ID="hiddentxtCardno" runat="server" />
                            <asp:HiddenField ID="hiddentradeno" runat="server" />
                            <asp:HiddenField ID="hidWarning" runat="server" />
                            <asp:HiddenField runat="server" ID="hidSupplyMoney" />
                            <asp:HiddenField runat="server" ID="hiddenSupply" />
                            <asp:HiddenField ID="hidLockBlackCardFlag" runat="server" />
                            <td width="12%">
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    启用日期:</div>
                            </td>
                            <td>
                                <asp:TextBox ID="sDate" CssClass="labeltext" Width="100" runat="server" Text=""></asp:TextBox>
                            </td>
                            <asp:HiddenField ID="hiddensDate" runat="server" />
                            <td>
                                <div align="right">
                                    结束日期:</div>
                            </td>
                            <td>
                                <asp:TextBox ID="eDate" CssClass="labeltext" Width="100" runat="server" Text=""></asp:TextBox>
                            </td>
                            <asp:HiddenField ID="hiddeneDate" runat="server" />
                            <td>
                                <div align="right">
                                    卡内余额:</div>
                            </td>
                            <td>
                                <asp:TextBox ID="cMoney" CssClass="labeltext" Width="100" runat="server" Text=""></asp:TextBox>
                            </td>
                            <asp:HiddenField ID="hiddencMoney" runat="server" Value="0"/>
                            <asp:HiddenField ID="hidRelBalance" runat="server" Value="0"/>
                            <asp:HiddenField ID="hidSupplyFee" runat="server" />
                            <asp:HiddenField ID="hidIsJiMing" runat="server" />
                            <asp:LinkButton runat="server" ID="btnConfirm" OnClick="btnConfirm_Click" />
                            <asp:HiddenField runat="server" ID="hidCardReaderToken" />
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    开通功能:</div>
                            </td>
                            <td colspan="7">
                                <aspControls:OpenFunc ID="openFunc" runat="server" />
                            </td>
                        </tr>
                    </table>
                </asp:Panel>
                <div class="pip">用户信息</div>
                <asp:Panel runat="server" CssClass="kuang5" ID="UserInfoContent">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text20">
                        <tr>
                            <td width="9%">
                                <div align="right">
                                    用户姓名:</div>
                            </td>
                            <td width="13%">
                                <asp:Label ID="CustName" runat="server" Text=""></asp:Label>
                            </td>
                            <td width="9%">
                                <div align="right">
                                    出生日期:</div>
                            </td>
                            <td width="13%">
                                <asp:Label ID="CustBirthday" runat="server" Text=""></asp:Label>
                            </td>
                            <td width="9%">
                                <div align="right">
                                    证件类型:</div>
                            </td>
                            <td width="13%">
                                <asp:Label ID="Papertype" runat="server" Text=""></asp:Label>
                            </td>
                            <td width="9%">
                                <div align="right">
                                    证件号码:</div>
                            </td>
                            <td width="25%" colspan="3">
                                <asp:Label ID="Paperno" runat="server" Text=""></asp:Label>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    用户性别:</div>
                            </td>
                            <td>
                                <asp:Label ID="Custsex" runat="server" Text=""></asp:Label>
                            </td>
                            <td>
                                <div align="right">
                                    联系电话:</div>
                            </td>
                            <td>
                                <asp:Label ID="Custphone" runat="server" Text=""></asp:Label>
                            </td>
                            <td>
                                <div align="right">
                                    邮政编码:</div>
                            </td>
                            <td>
                                <asp:Label ID="Custpost" runat="server" Text=""></asp:Label>
                            </td>
                            <td>
                                <div align="right">
                                    联系地址:</div>
                            </td>
                            <td colspan="3">
                                <asp:Label ID="Custaddr" runat="server" Text=""></asp:Label>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                电子邮件:
                            </td>
                            <td>
                                <asp:Label ID="txtEmail" runat="server" Text=""></asp:Label>
                            </td>
                            <td valign="top">
                                <div align="right">
                                    备注 :</div>
                            </td>
                            <td colspan="5">
                                <asp:Label ID="Remark" runat="server" Text=""></asp:Label>
                            </td>
                        </tr>
                    </table>
            </asp:Panel>
            <div class="con">
                <div class="info">费用信息</div>
                <div class="kuang5">
                    <div style="height: 100px;">
                        <div class="left">
                            <img src="../../Images/show-change.JPG" alt="返销" height="100px"/>
                        </div>
                        <div class="left" style="width: 300px;"></div>
                        <div class="feeZoo" style="margin: 0 auto;">
                            <div style="margin: 0px;">
                                <div style="padding-top: 15px;">
                                    <span class="feespan" style="color: black; padding-right: 5px;">返销金额(元):</span>
                                    <asp:Label runat="server" ID="txtTotalPayFee" CssClass="feespan">0.00</asp:Label>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="footall">
            </div>
            <div class="btns">
                <table width="200" border="0" align="right" cellpadding="0" cellspacing="0">
                    <tr>
                        <td>
                            <asp:Button ID="btnPrintPZ" runat="server" Text="打印凭证" CssClass="button1" Enabled="false"
                                OnClientClick="" />
                        </td>
                        <td>
                            <asp:Button ID="btnSupply" CssClass="button1" runat="server" Text="提交" Enabled="false"
                                OnClick="btnSupply_Click" />
                        </td>
                    </tr>
                </table>
                <asp:CheckBox ID="chkPingzheng" runat="server" Checked="True" Text="自动打印凭证"  OnClick=""/>
            </div>
            <asp:HiddenField runat="server" ID="hidTotalPayFee" Value="0"/>
            <asp:HiddenField runat="server" ID="hidRollBackWay" Value=""/>
            <asp:HiddenField runat="server" ID="hidResponseTradeId" Value=""/>
            <asp:HiddenField runat="server" ID="hidQueryTradeId" Value=""/>
            <asp:HiddenField runat="server" ID="hidTPTradeId" Value=""/>
        </ContentTemplate>
    </asp:UpdatePanel>
    </form>
    <%--        <iframe name="idFrame" width="0" height="0" src="..\..\Tools\print\printArea.html"> 
    </iframe> --%>
</body>
</html>

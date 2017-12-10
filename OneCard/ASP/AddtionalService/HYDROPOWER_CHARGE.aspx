<%@ Page Language="C#" AutoEventWireup="true" CodeFile="HYDROPOWER_CHARGE.aspx.cs" Inherits="ASP_PersonalBusiness_HYDROPOWER_CHARGE" %>

<%@ Register Src="../../CardReader.ascx" TagName="CardReader" TagPrefix="cr" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>公共事业费用代缴</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <script type="text/javascript" src="../../js/print.js"></script>
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" language="javascript">
        var strInput = "";
        function $(_sId) {
            return window.document.getElementById(_sId);
        }
        function ReadNewKey() {
            try {

                var com = "4,9600,n,8,1";
                reta = ICcard.Read_Key(com, 1, 25000);
                return reta;
            }
            catch (e) {
                return "";
            }
        }
        function StartPort() {
            $('account_pass').value = '';
            $('account_pass').focus();

            MSComm1_OnComm();
        }
        function MSComm1_OnComm() {
            strInput = ReadNewKey();
            if (strInput == null || strInput == "") {
                MyExtAlert('密码键盘有误：', '请检查密码键盘是否插好' + ', 错误信息:' + strInput);
                return false;
            } else {
                if (strInput.indexOf('串口') > -1) {
                    MyExtAlert('密码键盘有误：', '请检查密码键盘和COM端口号' + ', 错误信息:' + strInput);
                    return false;
                }
            }

            if (strInput != "") {
                $("account_pass").value = strInput;
            }
            return true;
        }

        function checkQuery() {
            var msg = "";
            var selItemCodeValue = $('selItemCode').value.trim();
            var txtAccountIdValue = $('txtAccountId').value.trim();
            if (selItemCodeValue == '') {
                msg += "请选择缴费类别</br>";
            }
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
        附加业务->公共事业费用代缴
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
                
                <div class="card" style="background-image: none; margin-left: 0px;">
                    <table>
                        <tr>
                            <td><span style="margin-left: 30px; font-weight: normal; height: 25px; line-height: 25px; display: block;">缴费类别:</span></td>
                            <td><asp:DropDownList ID="selItemCode" CssClass="inputmid" runat="server" AutoPostBack="True" OnSelectedIndexChanged="selItemCode_OnSelectedIndexChanged"></asp:DropDownList></td>
                            <td><span style="margin-left: 25px;font-weight: normal;height: 25px; line-height: 25px; display: block;">用户号:</span></td>
                            <td><asp:TextBox ID="txtAccountId" CssClass="inputAccountId" runat="server" MaxLength="40"/></td>
                            <td><asp:Button ID="btnQuery" CssClass="buttonTopQuery" runat="server" Text="查询" OnClientClick="return checkQuery()" OnClick="btnQuery_OnClick"/></td>
                        </tr>
                    </table> 
                </div>
                <div class="kuang5">
                    <div style="min-height: 50px">
                        <asp:GridView ID="lvwSupplyQuery" runat="server" Width="95%" CssClass="tab1" HeaderStyle-CssClass="tabbt"
                            AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel" AllowPaging="false"
                            PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top"
                            AutoGenerateColumns="False" ShowFooter="true">
                            <Columns>
                                <asp:BoundField DataField="AccountId" HeaderText="用户号" />
                                <asp:BoundField DataField="UserName" HeaderText="用户姓名" />
                                <asp:BoundField DataField="ContractNo" HeaderText="合同号" />
                                <asp:BoundField DataField="Balance" HeaderText="账户余额" NullDisplayText="0" DataFormatString="{0:n}"
                                    HtmlEncode="false" />
                                <asp:BoundField DataField="AccountMonth" HeaderText="账单月份"/>
                                <asp:BoundField DataField="TotalAmount" HeaderText="缴费总金额:元" NullDisplayText="0" DataFormatString="{0:n}"
                                    HtmlEncode="false" />
                                <asp:BoundField DataField="DelayCharge" HeaderText="滞纳金" NullDisplayText="0" DataFormatString="{0:n}"
                                    HtmlEncode="false" />
                            </Columns>
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                        <td>
                                            用户号
                                        </td>
                                        <td>
                                            用户姓名
                                        </td>
                                        <td>
                                            合同号
                                        </td>
                                        <td>
                                            账户余额
                                        </td>
                                        <td>
                                            账单月份
                                        </td>
                                        <td>
                                            缴费总金额:元
                                        </td>
                                        <td>
                                            滞纳金
                                        </td>
                                    </tr>
                                </table>
                            </EmptyDataTemplate>
                        </asp:GridView>
                    </div>
                </div>
                <div class="kuang5">
                    <table>
                        <tr>
                            <td><span style="margin-left: 30px; font-weight: normal; height: 15px; line-height: 15px; display: block; padding-right: 20px;">缴费方式</span></td>
                            <td>
                                <asp:RadioButton runat="server" ID="way_wallet" Text="电子钱包" GroupName="pay_way" TextAlign="Right" AutoPostBack="true" OnCheckedChanged="way_account_OnCheckedChanged"/>
                            </td>
                            <td>
                                <asp:RadioButton runat="server" ID="way_account" Text="专有账户" GroupName="pay_way" TextAlign="Right" AutoPostBack="true" OnCheckedChanged="way_account_OnCheckedChanged"/>
                            </td>
                            <td>
                                <asp:Label runat="server" ID="account_label" Visible="False">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;专有账户密码: </asp:Label>
                                <asp:TextBox runat="server" ID="account_pass"  TextMode="password" Visible="False"></asp:TextBox>
                            </td>
                            <td>
                                <asp:Panel runat="server" ID="btnPassInputContent" Visible="False">
                                    <input type="button" id="btnPassInput" value="小键盘输入密码" onclick="return StartPort()" 
                                        class="buttonTopQuery" style="width: 100px;"/>
                                </asp:Panel>
                            </td>
                        </tr>
                    </table>
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
                                <asp:Button ID="btnReadCard" CssClass="button1" runat="server" Text="读卡" OnClientClick="return ReadCardInfo()"
                                    OnClick="btnReadCard_Click" />
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
                            <td>
                                <div align="right">
                                    账户余额:</div>
                            </td>
                            <td>
                                <asp:TextBox ID="relBalance" CssClass="labeltext" Width="100" runat="server" Text=""></asp:TextBox>
                            </td>
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
                            <img src="../../Images/show-sale.JPG" alt="缴费" height="100px"/>
                        </div>
                        <div class="left" style="width: 300px;"></div>
                        <div class="feeZoo" style="width: 345px; margin: 0 auto; background-image: url('../../images/u4_normal_large.png');">
                            <div style="margin: 0px;">
                                <div style="padding-top: 15px;">
                                    <span class="feespan" style="color: black; padding-right: 5px;">缴费金额(元):</span>
                                    <asp:Label runat="server" ID="txtTotalPayFee" CssClass="feespan">0.00</asp:Label>
                                    <div></div>
                                    <asp:Panel runat="server" ID="feeContent" Visible="False">
                                        <asp:RadioButton runat="server" ID="Fifty" AutoPostBack="True" Text="50" OnCheckedChanged="selectFee_OnCheckedChanged" GroupName="selectFee"/>
                                        <asp:RadioButton runat="server" ID="One_hundred" AutoPostBack="True" Text="100" OnCheckedChanged="selectFee_OnCheckedChanged" GroupName="selectFee"/>
                                        <asp:RadioButton runat="server" ID="Two_hundred" AutoPostBack="True" Text="200" OnCheckedChanged="selectFee_OnCheckedChanged" GroupName="selectFee"/>
                                        <asp:RadioButton runat="server" ID="Five_hundred" AutoPostBack="True" Text="500" OnCheckedChanged="selectFee_OnCheckedChanged" GroupName="selectFee"/>
                                        <asp:RadioButton runat="server" ID="One_thousand" AutoPostBack="True" Text="1000" OnCheckedChanged="selectFee_OnCheckedChanged" GroupName="selectFee"/>
                                    </asp:Panel>
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
            <asp:HiddenField runat="server" ID="hidOrginTotalPayFee" Value="0"/>
            <asp:HiddenField runat="server" ID="hidResponseStatus"/>
            <asp:HiddenField runat="server" ID="hidCode"/>
            <asp:HiddenField runat="server" ID="hidMessage"/>
            <asp:HiddenField runat="server" ID="hidTotalNum" Value="0"/>
            <asp:HiddenField runat="server" ID="hidSeqNo"/>
            <asp:HiddenField runat="server" ID="hidTime"/>
            <asp:HiddenField runat="server" ID="hidItemCode"/>
            <asp:HiddenField runat="server" ID="hidAccountId"/>
            <asp:HiddenField runat="server" ID="hidResponseTradeId" />
            <asp:HiddenField runat="server" ID="hidUserName"/>
            <asp:HiddenField runat="server" ID="hidTotalAmount"/>
            <asp:HiddenField runat="server" ID="hidAccountMonth"/>
            <asp:HiddenField runat="server" ID="hidBalance"/>
            <asp:HiddenField runat="server" ID="hidDelayCharge"/>
            <asp:HiddenField runat="server" ID="hidContractNo"/>
            <asp:HiddenField runat="server" ID="hidORIGDATE"/>
        </ContentTemplate>
    </asp:UpdatePanel>
    </form>
    <%--        <iframe name="idFrame" width="0" height="0" src="..\..\Tools\print\printArea.html"> 
    </iframe> --%>
</body>
</html>

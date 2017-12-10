<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PB_ChangeReader.aspx.cs"
    Inherits="ASP_PersonalBusiness_PB_ChangeReader" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>读卡器更换</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <script type="text/javascript" src="../../js/print.js"></script>
    <script type="text/javascript" src="../../js/cardreaderhelper.js"></script>
    <script type="text/javascript" src="../../js/myext.js"></script>
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" language="javascript">
        function SelectRadio() {
            if ($get('radCharge').checked == true) {
                $get('hidChangeType').value = "1";
                $get('txtSaleMoney').value = "";
                $get('txtSaleMoney').disabled = false;
            }
            else {
                $get('hidChangeType').value = "0";
                $get('txtSaleMoney').value = "0";
                $get('txtSaleMoney').disabled = true;
            }
            return false;
        }

        function submitConfirm() {
            if (true) {
                MyExtConfirm('确认',
		        '将旧读卡器' + $get('txtOldReaderNo').value + '更换为新读卡器' + $get('txtReaderNo').value + '，<br>是否确认更换？'
		        , submitConfirmCallback);
            }
            return false;
        }
        function submitConfirmCallback(btn) {
            if (btn == 'yes') {
                $get('btnConfirm').click();
            }
            return false;
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
    <div class="tb">
        个人业务->读卡器更换</div>
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
    <asp:UpdatePanel ID="UpdatePanel1" runat="server" RenderMode="Inline">
        <ContentTemplate>
            <aspControls:PrintPingZheng ID="ptnPingZheng" runat="server" PrintArea="ptnPingZheng1" />
            <asp:BulletedList ID="bulMsgShow" runat="server">
            </asp:BulletedList>
            <script runat="server">public override void ErrorMsgShow() { ErrorMsgHelper(bulMsgShow); }</script>
            <asp:HiddenField ID="hidChangeType" runat="server" />
            <asp:HiddenField ID="hidTradeid" runat="server" />
            <asp:HiddenField ID="hidOldReaderno" runat="server" />
            <asp:HiddenField ID="hidNewReaderno" runat="server" />
            <asp:HiddenField ID="hidSaleMoney" runat="server" />
            <div class="con">
                <div class="card">
                    旧读卡器</div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text20">
                        <tr>
                            <td width="12%" align="right">
                                旧读卡器序列号:
                            </td>
                            <td width="32%">
                                <asp:TextBox ID="txtOldReaderNo" CssClass="inputmid" runat="server" MaxLength="16" AutoPostBack="true"
                                    OnTextChanged="OldReader_OnTextChanged"/>
                            </td>
                            <td width="9%">
                                <div align="right">
                                    售出时间:</div>
                            </td>
                            <td width="12%">
                                <asp:Label ID="labSellTime" runat="server" Text=""></asp:Label>
                            </td>
                            <td width="10%">
                                <div align="right">
                                    状态:</div>
                            </td>
                            <td width="21%">
                                <asp:Label ID="labOState" runat="server" Text=""></asp:Label>
                            </td>
                        </tr>
                    </table>
                </div>
                <div class="pip">
                    用户信息</div>
                <div class="kuang5">
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
                            <td width="12%">
                                <asp:Label ID="Papertype" runat="server" Text=""></asp:Label>
                            </td>
                            <td width="10%">
                                <div align="right">
                                    证件号码:</div>
                            </td>
                            <td width="21%" colspan="3">
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
                </div>
                <div class="card">
                    新读卡器</div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text20">
                        <tr>
                            <td width="12%" align="right">
                                新读卡器序列号:
                            </td>
                            <td width="88%">
                                <asp:TextBox ID="txtReaderNo" CssClass="inputmid" runat="server" MaxLength="16" AutoPostBack="true"
                                    OnTextChanged="Reader_OnTextChanged" />
                            </td>
                        </tr>
                    </table>
                </div>
                <div class="money">
                    费用信息</div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text20">
                        <tr>
                            <%--<td width="12%" align="right">
                                <input type="radio" value="收费更换" name="moneyradio" id="radCharge" checked="checked"
                                    onclick="SelectRadio()" />收费更换
                            </td>
                            <td width="12%" align="left">
                                &nbsp;&nbsp;&nbsp;
                                <input type="radio" value="免费更换" name="moneyradio" id="radFree" onclick="SelectRadio()" />免费更换
                            </td>--%>
                            <td>
                            <asp:RadioButton ID="radCharge" runat="server" Text="收费更换" GroupName="SupplyMoney"  Checked="True"  onclick="SelectRadio()" />
                            
                            </td>
                            <td>
                             <asp:RadioButton ID="radFree" runat="server" Text="免费更换" GroupName="SupplyMoney"  onclick="SelectRadio()"/>
                            </td>

                            <td width="12%" align="right">
                                更换金额:
                            </td>
                            <td width="12%">
                                <asp:TextBox ID="txtSaleMoney" CssClass="input" Text="" Enabled="true" runat="server"
                                    MaxLength="4" Width="50px" /><span class="red"> *</span>100 分
                            </td>
                            <td width="12%">
                                <div align="right">
                                    备注:</div>
                            </td>
                            <td width="40%">
                                <asp:TextBox ID="txtRemark" CssClass="inputlong" runat="server" MaxLength="60"></asp:TextBox>
                            </td>
                        </tr>
                    </table>
                </div>
            </div>
            <div class="footall">
            </div>
            <div class="btns">
                <table width="200" align="right" border="0" cellpadding="0" cellspacing="0">
                    <tr>
                        <td>
                            <asp:Button ID="btnPrintPZ" runat="server" Text="打印凭证" CssClass="button1" Enabled="false"
                                OnClick="btnPrintPZ_Click" />
                        </td>
                        <td>
                            <asp:LinkButton runat="server" ID="btnConfirm" OnClick="btnConfirm_Click" />
                            <asp:Button ID="btnSubmit" Enabled="true" CssClass="button1" runat="server" Text="提交"
                                OnClick="btnSubmit_Click" />
                        </td>
                    </tr>
                </table>
                <asp:CheckBox ID="chkPingzheng" runat="server" Text="自动打印凭证" Checked="true" />
            </div>
            <div style="display: none" runat="server" id="printarea">
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
    </form>
</body>
</html>

<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PB_CardToCardIn.aspx.cs"
    Inherits="ASP_PersonalBusiness_PB_CardToCardIn" EnableEventValidation="false"  %>
<%@ Register Src="../../CardReader.ascx" TagName="CardReader" TagPrefix="cr" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>卡卡转账圈存</title>
    <script type="text/javascript" src="../../js/myext.js"></script>
    <script type="text/javascript" src="../../js/print.js"></script>
    <script type="text/javascript" language="javascript">
        function loadCheck() {
            var ret = ReadCardInfoForCheck();
            if (!ret) {
                return false;
            }

            if (cardReader.CardInfo.cardNo != $get('txtCardno').value) {
                MyExtAlert("警告", "读卡器上卡片为:<br>"
            + '<span class="red">' + cardReader.CardInfo.cardNo + '</span>'
            + "<br>先前读出卡号为: <br>"
            + '<span class="red">' + $get('txtCardno').value + '</span>'
            + "<br>不一致。<br><br> 请重新点击读卡按钮后再圈存！");
                return false;
            }

            if (!checkMaxBalance()) return false;

            MyExtConfirm('提示', '是否确认圈存:' + $get('SupplyFee').innerHTML + '元?', SupplyCheckConfirm);
            return false;
        }
    </script>
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <cr:CardReader ID="cardReader" runat="server" />
    <form id="form1" runat="server">
    <div class="tb">
        个人业务->卡卡转账圈存</div>
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
            <div id="ErrorMessage">
            </div>
            <aspControls:PrintPingZheng ID="ptnPingZheng" runat="server" PrintArea="ptnPingZheng1" />
            <asp:BulletedList ID="bulMsgShow" runat="server" />
            <script runat="server">public override void ErrorMsgShow() { ErrorMsgHelper(bulMsgShow); }</script>
            <div class="con">
                <div class="card">
                    查询圈提信息</div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="12text">
                        <tr>
                            <td width="12%">
                                <div align="right">
                                    圈提卡号:</div>
                            </td>
                            <td width="12">
                                <asp:TextBox ID="txtOutCardno" runat="server" CssClass="input" MaxLength="16"></asp:TextBox>
                                
                            </td>
                            <td width="12%">
                            </td>
                            <td width="12%">
                            </td>
                            <td width="12%">
                            </td>
                            <td width="12%">
                            </td>
                            <td width="12%" align="right">
                            <asp:Button ID="btnReadCardNO" runat="server" Text="读卡" CssClass="button1" OnClientClick="return ReadCardInfo('txtOutCardno')" OnClick="btnReadCardNO_Click" />                                
                            </td>
                            <td width="12%" align="left">&nbsp
                            <asp:Button ID="btnReadDBCard" runat="server" Text="读数据库" CssClass="button1" OnClientClick="return warnCheck()" />
                            </td>
                        </tr>
                    </table>
                </div>
                <div class="pip" style="display: none">
                    圈提用户信息</div>
                <div class="kuang5" style="display: none">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text20">
                        <tr>
                            <td width="12%">
                                <div align="right">
                                    用户姓名:</div>
                            </td>
                            <td width="12%">
                                <asp:Label ID="OutCustName" runat="server" Text=""></asp:Label>
                            </td>
                            <td width="12%">
                                <div align="right">
                                    出生日期:</div>
                            </td>
                            <td width="12%">
                                <asp:Label ID="OutCustBirthday" runat="server" Text=""></asp:Label>
                            </td>
                            <td width="12%">
                                <div align="right">
                                    证件类型:</div>
                            </td>
                            <td width="12%">
                                <asp:Label ID="OutPapertype" runat="server" Text=""></asp:Label>
                            </td>
                            <td width="12%">
                                <div align="right">
                                    证件号码:</div>
                            </td>
                            <td width="12%">
                                <asp:Label ID="OutPaperno" runat="server" Text=""></asp:Label>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    用户性别:</div>
                            </td>
                            <td>
                                <asp:Label ID="OutCustsex" runat="server" Text=""></asp:Label>
                            </td>
                            <td>
                                <div align="right">
                                    联系电话:</div>
                            </td>
                            <td>
                                <asp:Label ID="OutCustphone" runat="server" Text=""></asp:Label>
                            </td>
                            <td>
                                <div align="right">
                                    邮政编码:</div>
                            </td>
                            <td>
                                <asp:Label ID="OutCustpost" runat="server" Text=""></asp:Label>
                            </td>
                            <td>
                                <div align="right">
                                    联系地址:</div>
                            </td>
                            <td>
                                <asp:Label ID="OutCustaddr" runat="server" Text=""></asp:Label>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                电子邮件:
                            </td>
                            <td>
                                <asp:Label ID="txtOutEmail" runat="server" Text=""></asp:Label>
                            </td>
                            <td valign="top">
                                <div align="right">
                                    备注 :</div>
                            </td>
                            <td colspan="5">
                                <asp:Label ID="OutRemark" runat="server" Text=""></asp:Label>
                            </td>
                        </tr>
                    </table>
                </div>
                <div class="jieguo">
                    圈提记录</div>
                <div class="kuang5">
                    <div id="gdtb" style="height: 160px">
                        <asp:GridView ID="lvwloadInQuery" runat="server" Width="100%" CssClass="tab1" HeaderStyle-CssClass="tabbt"
                            AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel" AllowPaging="True"
                            PageSize="10" PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left"
                            PagerStyle-VerticalAlign="Top" AutoGenerateColumns="false" OnPageIndexChanging="lvwloadInQuery_Page"
                            OnSelectedIndexChanged="lvwloadInQuery_SelectedIndexChanged" OnRowCreated="lvwloadInQuery_RowCreated"
                            OnRowDataBound="lvwloadInQuery_RowDataBound">
                            <Columns>
                                <asp:BoundField DataField="TRADEID" HeaderText="业务流水号" />
                                <asp:BoundField DataField="OUTCARDNO" HeaderText="圈提卡号" />
                                <asp:BoundField DataField="MONEY" HeaderText="圈提金额" />
                                <asp:BoundField DataField="OUTTIME" HeaderText="圈提时间" />
                                <asp:BoundField DataField="OUTSTAFFNO" HeaderText="圈提员工" />
                                <asp:BoundField DataField="OUTDEPTNO" HeaderText="圈提部门" />
                                <asp:BoundField DataField="REMARK" HeaderText="备注" />
                            </Columns>
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                        <td>
                                            圈提卡号
                                        </td>
                                        <td>
                                            圈提金额
                                        </td>
                                        <td>
                                            圈提时间
                                        </td>
                                        <td>
                                            圈提员工
                                        </td>
                                        <td>
                                            圈提部门
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
                <div class="base">
                    确认信息</div>
                <div class="kuang5" style="height: 30px;">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td style="width: 12%" align="right">
                                圈提卡号:
                            </td>
                            <td style="width: 12%">
                                <asp:Label ID="labOutCardNo" runat="server" />
                            </td>
                            <td style="width: 12%" align="right">
                                圈提金额:
                            </td>
                            <td style="width: 12%">
                                <asp:Label ID="SupplyFee" runat="server" />
                            </td>
                            <td style="width: 12%" align="right">
                                圈提时间:
                            </td>
                            <td style="width: 12%" >
                                <asp:Label ID="labOutTime" runat="server" />
                            </td>
                            <td style="width: 12%" align="right">
                                备注:
                            </td>
                            <td style="width: 12%" >
                                <asp:Label ID="labremark" runat="server" />
                            </td>
                        </tr>
                    </table>
                </div>
                <div class="card">
                    待圈存卡片信息</div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text20">
                        <tr>
                            <td width="12%">
                                <div align="right">
                                    用户卡号:</div>
                            </td>
                            <td width="12%">
                                <asp:TextBox ID="txtCardno" CssClass="labeltext" MaxLength="16" runat="server"></asp:TextBox>
                            </td>
                            <td width="12%">
                                <div align="right">
                                    卡内余额:</div>
                            </td>
                            <td width="12%">
                                <asp:TextBox ID="cMoney" CssClass="labeltext" runat="server" Text=""></asp:TextBox>
                            </td>
                            <td width="12%">
                                <div align="right">
                                    卡片状态:</div>
                            </td>
                            <td width="12%">
                                <asp:TextBox ID="RESSTATE" CssClass="labeltext" ReadOnly="true" runat="server"></asp:TextBox>
                            </td>
                            <td width="12%" align="right">
                                <asp:Button ID="btnReadCard" CssClass="button1" runat="server" Text="读卡" OnClientClick="return ReadCardInfo()"
                                    OnClick="btnReadCard_Click" />
                            </td>
                            <td width="12%">&nbsp
                            <asp:Button ID="btnCheckRead" CssClass="button1" runat="server" Text="圈存校验" 
                             OnClientClick="return readCardForCheck()"/>
                            </td>
                        </tr>
                        <asp:HiddenField ID="hidisReadDBCard" runat="server" />
                        <asp:HiddenField ID="hiddenread" runat="server" />
                        <asp:HiddenField ID="hiddenOutCardno" runat="server" />
                        <asp:HiddenField ID="hiddentxtCardno" runat="server" />
                        <asp:HiddenField ID="hiddenAsn" runat="server" />
                        <asp:HiddenField ID="hiddenLabCardtype" runat="server" />
                        <asp:HiddenField ID="hiddensDate" runat="server" />
                        <asp:HiddenField ID="hiddeneDate" runat="server" />
                        <asp:HiddenField ID="hiddencMoney" runat="server" />
                        <asp:HiddenField ID="hiddentradeno" runat="server" />
                        <asp:HiddenField ID="hiddenState" runat="server" />
                        <asp:HiddenField ID="hidWarning" runat="server" />
                        <asp:HiddenField ID="hidUnSupplyMoney" runat="server" />
                        <asp:HiddenField runat="server" ID="hidSupplyMoney" />
                        <asp:HiddenField runat="server" ID="hiddenSupply" />
                        <asp:HiddenField runat="server" ID="hidoutTradeid" />
                        <asp:LinkButton runat="server" ID="btnConfirm" OnClick="btnConfirm_Click" />
                        <asp:HiddenField runat="server" ID="hidCardReaderToken" />
                        <asp:HiddenField runat="server" ID="hidCardnoForCheck" /> 
                        <asp:HiddenField ID="hiddenCheck" runat="server" />
                        <asp:HiddenField ID="hidIsJiMing" runat="server" />
                        <asp:HiddenField ID="hidInCardMoney" runat="server" />
                        <asp:HiddenField ID="hidOutCardMoney" runat="server" />
                        <asp:HiddenField ID="hidInCardno" runat="server" />
                        <asp:HiddenField ID="hidOutCardno" runat="server" />
                    </table>
                </div>
                <div class="pip" style="display: none">
                    待圈存用户信息</div>
                <div class="kuang5" style="display: none">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text20">
                        <tr>
                            <td width="12%">
                                <div align="right">
                                    用户姓名:</div>
                            </td>
                            <td width="12%">
                                <asp:Label ID="InCustName" runat="server" Text=""></asp:Label>
                            </td>
                            <td width="12%">
                                <div align="right">
                                    出生日期:</div>
                            </td>
                            <td width="12%">
                                <asp:Label ID="InCustBirthday" runat="server" Text=""></asp:Label>
                            </td>
                            <td width="12%">
                                <div align="right">
                                    证件类型:</div>
                            </td>
                            <td width="12%">
                                <asp:Label ID="InPapertype" runat="server" Text=""></asp:Label>
                            </td>
                            <td width="12%">
                                <div align="right">
                                    证件号码:</div>
                            </td>
                            <td width="12%">
                                <asp:Label ID="InPaperno" runat="server" Text=""></asp:Label>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    用户性别:</div>
                            </td>
                            <td>
                                <asp:Label ID="InCustsex" runat="server" Text=""></asp:Label>
                            </td>
                            <td>
                                <div align="right">
                                    联系电话:</div>
                            </td>
                            <td>
                                <asp:Label ID="InCustphone" runat="server" Text=""></asp:Label>
                            </td>
                            <td>
                                <div align="right">
                                    邮政编码:</div>
                            </td>
                            <td>
                                <asp:Label ID="InCustpost" runat="server" Text=""></asp:Label>
                            </td>
                            <td>
                                <div align="right">
                                    联系地址:</div>
                            </td>
                            <td>
                                <asp:Label ID="InCustaddr" runat="server" Text=""></asp:Label>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                电子邮件:
                            </td>
                            <td>
                                <asp:Label ID="txtInEmail" runat="server" Text=""></asp:Label>
                            </td>
                            <td valign="top">
                                <div align="right">
                                    备注 :</div>
                            </td>
                            <td colspan="5">
                                <asp:Label ID="InRemark" runat="server" Text=""></asp:Label>
                            </td>
                        </tr>
                    </table>
                </div>
                <div class="info">
                    确认提交</div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text20">
                    <tr>
                            <td width="12%">
                            </td>
                            <td width="12%">
                            </td>
                            <td width="12%">
                            </td>
                            <td width="12%">
                            </td>
                            <td width="12%">
                            </td>
                            <td width="12%">
                            </td>
                            <td width="12%">
                            </td>
                            <td width="12%">
                            </td>
                        </tr>
                        <tr>
                            <td align="right"><asp:CheckBox ID="chkPingzheng" runat="server" Checked="true" />自动打印凭证</td>
                            <td colspan="5">
                            </td>
                            <td align="right">
                            <asp:Button ID="btnPrintPZ" runat="server" Text="打印凭证" CssClass="button1" Enabled="false" 
                             OnClick="btnPrintPZ_Click"/>
                            </td>
                            <td align="left">&nbsp
                                <asp:Button ID="btnLoadIn" CssClass="button1" runat="server" Text="圈存" Enabled="false"
                                    OnClientClick="return loadCheck()"/>
                            </td>
                        </tr>
                    </table>
                </div>
            </div>
            <div style="display:none" runat="server" id="printarea"></div>
        </ContentTemplate>
    </asp:UpdatePanel>
    </form>
</body>
</html>

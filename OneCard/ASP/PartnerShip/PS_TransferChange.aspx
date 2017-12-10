<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PS_TransferChange.aspx.cs"
    Inherits="ASP_PartnerShip_PS_TransferChange" EnableEventValidation="false" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>结算单元维护</title>
    <script type="text/javascript" src="../../js/myext.js"></script>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <script language="javascript" type="text/javascript">
        function stopbackspace() {
            var c = event.keyCode;
            if (c == 8)
                event.returnValue = false;
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
    <div class="tb">
        合作伙伴->结算单元信息维护</div>
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
    <asp:UpdatePanel ID="UpdatePanel1" runat="server" RenderMode="Inline">
        <ContentTemplate>
            <asp:BulletedList ID="bulMsgShow" runat="server" />
            <script runat="server">public override void ErrorMsgShow() { ErrorMsgHelper(bulMsgShow); }</script>
        </ContentTemplate>
    </asp:UpdatePanel>
    <div class="con">
        <div class="jieguo">
            查询结算单元信息</div>
        <div class="kuang5">
            <table width="98%" border="0" cellpadding="0" cellspacing="0" class="text25">
                <tr>
                    <td align="right">
                        行业名称:
                    </td>
                    <td>
                        <asp:DropDownList ID="selCalling" CssClass="inputmidder" runat="server" AutoPostBack="true"
                            OnSelectedIndexChanged="selCalling_SelectedIndexChanged">
                        </asp:DropDownList>
                    </td>
                    <td align="right">
                        单位名称:
                    </td>
                    <td>
                        <asp:DropDownList ID="selCorp" CssClass="inputmidder" runat="server" AutoPostBack="true"
                            OnSelectedIndexChanged="selCorp_SelectedIndexChanged">
                        </asp:DropDownList>
                    </td>
                </tr>
                <tr>
                    <td align="right">
                        部门名称:
                    </td>
                    <td>
                        <asp:DropDownList ID="selDepart" CssClass="inputmidder" runat="server" AutoPostBack="true"
                            OnSelectedIndexChanged="selDepart_SelectedIndexChanged">
                        </asp:DropDownList>
                    </td>
                    <td align="right">
                        结算单元:
                    </td>
                    <td>
                        <asp:DropDownList ID="selBalUint" CssClass="inputmidder" runat="server">
                        </asp:DropDownList>
                    </td>
                </tr>
                <tr>
                    <td align="right">
                        审批状态:
                    </td>
                    <td>
                        <asp:DropDownList ID="selAprvState" CssClass="input" runat="server">
                            <asp:ListItem Text="0: 财审通过" Value="0"></asp:ListItem>
                            <asp:ListItem Text="1: 财审作废" Value="1"></asp:ListItem>
                            <asp:ListItem Text="2: 审批通过" Value="2"></asp:ListItem>
                            <asp:ListItem Text="3: 审批作废" Value="3"></asp:ListItem>
                            <asp:ListItem Text="4: 等待审批" Value="4"></asp:ListItem>
                        </asp:DropDownList>
                    </td>
                    <td>
                        <div align="right">
                            商户经理:</div>
                    </td>
                    <td>
                        <asp:DropDownList ID="selMsgQry" CssClass="input" runat="server" />
                        <asp:UpdatePanel ID="UpdatePanel4" runat="server" RenderMode="Inline">
                            <ContentTemplate>
                                <asp:HiddenField runat="server" ID="hidAprvState" Value="0" />
                                <asp:HiddenField runat="server" ID="hidSeqNo" />
                                <asp:Button ID="btnQuery" runat="server" Text="查询" CssClass="button1" OnClick="btnQuery_Click" />
                            </ContentTemplate>
                        </asp:UpdatePanel>
                    </td>
                </tr>
            </table>
            <div class="gdtb" style="height: 160px">
                <asp:UpdatePanel ID="UpdatePanel2" runat="server" RenderMode="Inline">
                    <ContentTemplate>
                        <asp:GridView ID="lvwBalUnits" runat="server" CssClass="tab1" Width="280%" HeaderStyle-CssClass="tabbt"
                            AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel" AllowPaging="True"
                            PageSize="1000" PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="Left"
                            PagerStyle-VerticalAlign="Top" AutoGenerateColumns="False" OnPageIndexChanging="lvwBalUnits_Page"
                            OnSelectedIndexChanged="lvwBalUnits_SelectedIndexChanged" OnRowCreated="lvwBalUnits_RowCreated"
                            EmptyDataText="没有数据记录!">
                            <Columns>
                                <asp:BoundField DataField="ROWNUM" HeaderText="#" />
                                <asp:TemplateField HeaderText="有效标志">
                                    <ItemTemplate>
                                        <asp:Label ID="labUseTag" Text='<%# Eval("USETAG").ToString() == "1" ? "有效" : Eval("USETAG").ToString() == "0" ? "无效" : Eval("USETAG").ToString()%>'
                                            runat="server"></asp:Label>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField DataField="BALUNITNO" HeaderText="结算单元编码" />
                                <asp:BoundField DataField="BALUNIT" HeaderText="结算单元名称" />
                                <asp:BoundField DataField="BALUNITTYPE" HeaderText="单元类型" />
                                <asp:BoundField DataField="CHANNELNAME" HeaderText="结算通道" />
                                <asp:BoundField DataField="SOURCETYPE" HeaderText="来源识别类型" />
                                <asp:BoundField DataField="CREATETIME" HeaderText="合作时间" DataFormatString="{0:yyyy-MM-dd}"
                                    HtmlEncode="false" />
                                <asp:BoundField DataField="CALLINGNAME" HeaderText="行业" />
                                <asp:BoundField DataField="CORPNAME" HeaderText="单位" />
                                <asp:BoundField DataField="DEPARTNAME" HeaderText="部门" />
                                <asp:BoundField DataField="BANKNAME" HeaderText="开户银行" />
                                <asp:BoundField DataField="BANKACCNO" HeaderText="银行帐号" />
                                <asp:BoundField DataField="SERMANAGER" HeaderText="商户经理" />
                                <asp:BoundField DataField="BALLEVEL" HeaderText="结算级别" />
                                <asp:BoundField DataField="BALCYCLETYPE" HeaderText="结算周期类型" />
                                <asp:BoundField DataField="BALINTERVAL" HeaderText="结算周期跨度" />
                                <asp:BoundField DataField="FINCYCLETYPE" HeaderText="划账周期类型" />
                                <asp:BoundField DataField="FININTERVAL" HeaderText="划账周期跨度" />
                                <asp:BoundField DataField="FINTYPE" HeaderText="转账类型" />
                                <asp:BoundField DataField="COMFEETAKE" HeaderText="佣金扣减方式" />
                                <asp:BoundField DataField="FINBANK" HeaderText="转出银行" />
                                <asp:BoundField DataField="LINKMAN" HeaderText="联系人" />
                                <asp:BoundField DataField="UNITPHONE" HeaderText="联系电话" />
                                <asp:BoundField DataField="UNITADD" HeaderText="联系地址" />
                                <asp:BoundField DataField="UNITEMAIL" HeaderText="电子邮件" />
                                <asp:BoundField DataField="PURPOSE" HeaderText="收款人账户类型" />
                                <asp:BoundField DataField="BANKCHANNEL" HeaderText="银行渠道" />
                                <asp:BoundField DataField="REGIONNAME" HeaderText="地区名称" />
                                <asp:BoundField DataField="DELIVERYMODE" HeaderText="POS投放模式" />
                                <asp:BoundField DataField="APPCALLING" HeaderText="应用行业" />
                            </Columns>
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                        <td>
                                            #
                                        </td>
                                        <td>
                                            有效标志
                                        </td>
                                        <td>
                                            结算单元编码
                                        </td>
                                        <td>
                                            结算单元名称
                                        </td>
                                        <td>
                                            单元类型
                                        </td>
                                        <td>
                                            结算通道
                                        </td>
                                        <td>
                                            来源识别类型
                                        </td>
                                        <td>
                                            合作时间
                                        </td>
                                        <td>
                                            行业
                                        </td>
                                        <td>
                                            单位
                                        </td>
                                        <td>
                                            部门
                                        </td>
                                        <td>
                                            开户银行
                                        </td>
                                        <td>
                                            银行帐号
                                        </td>
                                        <td>
                                            商户经理
                                        </td>
                                        <td>
                                            结算级别
                                        </td>
                                        <td>
                                            结算周期类型
                                        </td>
                                        <td>
                                            结算周期跨度
                                        </td>
                                        <td>
                                            划账周期类型
                                        </td>
                                        <td>
                                            划账周期跨度
                                        </td>
                                        <td>
                                            转账类型
                                        </td>
                                        <td>
                                            佣金扣减方式
                                        </td>
                                        <td>
                                            转出银行
                                        </td>
                                        <td>
                                            联系人
                                        </td>
                                        <td>
                                            联系电话
                                        </td>
                                        <td>
                                            联系地址
                                        </td>
                                        <td>
                                            收款人账户类型
                                        </td>
                                        <td>
                                            银行渠道
                                        </td>
                                        <td>
                                            地区名称
                                        </td>
                                        <td>
                                            POS投放模式
                                        </td>
                                        <td>
                                            应用行业
                                        </td>
                                    </tr>
                                </table>
                            </EmptyDataTemplate>
                        </asp:GridView>
                    </ContentTemplate>
                </asp:UpdatePanel>
            </div>
        </div>
    </div>
    <asp:UpdatePanel ID="UpdatePanel3" runat="server" RenderMode="Inline">
        <ContentTemplate>
            <div class="con">
                <%--<div class="base">结算单元信息</div>--%>
                <div class="kuang5">
                    <table width="880" border="0" cellpadding="0" cellspacing="0" class="12text">
                        <tr>
                            <td width="9%">
                                <div align="right">
                                    行业名称:</div>
                            </td>
                            <td>
                                <asp:DropDownList ID="selCallingExt" CssClass="input" runat="server" AutoPostBack="true"
                                    OnSelectedIndexChanged="selCallingExt_SelectedIndexChanged">
                                </asp:DropDownList>
                            </td>
                            <td width="9%">
                                <div align="right">
                                    单位名称:</div>
                            </td>
                            <td>
                                <asp:DropDownList ID="selCorpExt" CssClass="input" runat="server" AutoPostBack="true"
                                    OnSelectedIndexChanged="selCorpExt_SelectedIndexChanged">
                                </asp:DropDownList>
                            </td>
                            <td width="9%">
                                <div align="right">
                                    地区名称:</div>
                            </td>
                            <td>
                                <asp:DropDownList ID="selRegionExt" CssClass="input" runat="server" AutoPostBack="true"
                                    OnSelectedIndexChanged="selRegionExt_SelectedIndexChanged">
                                </asp:DropDownList>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    POS投放模式:</div>
                            </td>
                            <td>
                                <asp:DropDownList ID="selDeliveryModeExt" CssClass="input" runat="server" AutoPostBack="true"
                                    OnSelectedIndexChanged="selDeliveryModeExt_SelectedIndexChanged">
                                </asp:DropDownList>
                            </td>
                            <td>
                                <div align="right">
                                    应用行业:
                                </div>
                            </td>
                            <td>
                                <asp:DropDownList ID="selAppCallingExt" AutoPostBack="true" runat="server" OnSelectedIndexChanged="selAppCallingExt_changed">
                                </asp:DropDownList>
                            </td>
                            <td>
                                <div align="right">
                                    单元编码:</div>
                            </td>
                            <td>
                                <asp:TextBox ID="txtBalUnitNo" onkeydown="stopbackspace(this.value)" ReadOnly="true"
                                    CssClass="input" runat="server" MaxLength="8"></asp:TextBox>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    单元类型:</div>
                            </td>
                            <td>
                                <asp:DropDownList ID="selBalType" CssClass="input" runat="server">
                                </asp:DropDownList>
                            </td>
                            <td>
                                <div align="right">
                                    结算单元:</div>
                            </td>
                            <td>
                                <asp:TextBox ID="txtBalUnit" runat="server" CssClass="input" MaxLength="100"></asp:TextBox>
                            </td>
                            <td>
                                <div align="right">
                                    商户经理:</div>
                            </td>
                            <td>
                                <asp:DropDownList ID="selSerMgr" CssClass="input" runat="server" />
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    来源识别类型:</div>
                            </td>
                            <td colspan="3">
                                <asp:DropDownList ID="selSourceType" CssClass="inputmidder" runat="server">
                                </asp:DropDownList>
                            </td>
                            <td>
                                <div align="right">
                                    部门名称:</div>
                            </td>
                            <td>
                                <asp:DropDownList ID="selDepartExt" CssClass="inputmidder" runat="server">
                                </asp:DropDownList>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    开户银行:</div>
                            </td>
                            <td colspan="3">
                                <asp:TextBox ID="txtBank" CssClass="inputmid" runat="server" AutoPostBack="true"
                                    OnTextChanged="txtBank_Changed"></asp:TextBox>
                                <asp:DropDownList ID="selBank" CssClass="inputmidder" runat="server">
                                </asp:DropDownList>
                            </td>
                            <td>
                                <div align="right">
                                    银行帐号:</div>
                            </td>
                            <td>
                                <asp:TextBox ID="txtBankAccNo" runat="server" CssClass="inputlong" MaxLength="30"></asp:TextBox>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    转出银行:</div>
                            </td>
                            <td colspan="3">
                                <asp:TextBox ID="txtFinBank" CssClass="inputmid" runat="server" AutoPostBack="true"
                                    OnTextChanged="txtFinBank_Changed"></asp:TextBox>
                                <asp:DropDownList ID="selFinBank" CssClass="inputmidder" runat="server">
                                </asp:DropDownList>
                            </td>
                            <td>
                                <div align="right">
                                    银行渠道:</div>
                            </td>
                            <td>
                                <asp:DropDownList ID="selBankChannel" CssClass="inputmidder" runat="server">
                                </asp:DropDownList>
                            </td>
                        </tr>
                    </table>
                    <div style="float: left">
                        <div class="linex">
                        </div>
                        <table width="560" border="0" cellpadding="0" cellspacing="0" class="12text">
                            <tr>
                                <td>
                                    <div align="right">
                                        结算级别:</div>
                                </td>
                                <td>
                                    <asp:DropDownList ID="selBalLevel" CssClass="input" runat="server">
                                    </asp:DropDownList>
                                </td>
                                <td>
                                    <div align="right">
                                        结算周期类型:</div>
                                </td>
                                <td>
                                    <asp:DropDownList ID="selBalCyclType" CssClass="input" runat="server" Width="60px">
                                    </asp:DropDownList>
                                </td>
                                <td>
                                    <div align="right">
                                        结算周期跨度:</div>
                                </td>
                                <td>
                                    <asp:TextBox ID="txtBalInterval" runat="server" CssClass="input" MaxLength="7" Width="98px"></asp:TextBox>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <div align="right">
                                        划账周期类型:</div>
                                </td>
                                <td>
                                    <asp:DropDownList ID="selFinCyclType" CssClass="input" runat="server">
                                    </asp:DropDownList>
                                </td>
                                <td>
                                    <div align="right">
                                        划账周期跨度:</div>
                                </td>
                                <td>
                                    <asp:TextBox ID="txtFinInterval" runat="server" CssClass="input" MaxLength="7" Width="52px"></asp:TextBox>
                                </td>
                                <td>
                                    <div align="right">
                                        转账类型:</div>
                                </td>
                                <td>
                                    <asp:DropDownList ID="selFinType" CssClass="input" runat="server" Width="100px">
                                    </asp:DropDownList>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <div align="right">
                                        佣金减扣方式:</div>
                                </td>
                                <td>
                                    <asp:DropDownList ID="selComFeeTake" CssClass="input" runat="server" Width="130px">
                                    </asp:DropDownList>
                                </td>
                                <td>
                                    <div align="right">
                                        有效标志:</div>
                                </td>
                                <td>
                                    <asp:DropDownList ID="selUseTag" CssClass="input" runat="server" Width="60px">
                                    </asp:DropDownList>
                                </td>
                                <td>
                                    <div align="right">
                                        收款人账户类型:</div>
                                </td>
                                <td>
                                    <asp:DropDownList ID="selPurPoseType" CssClass="input" runat="server" Width="100px">
                                    </asp:DropDownList>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <div align="right">
                                        备注:</div>
                                </td>
                                <td>
                                    <asp:TextBox ID="txtRemark" runat="server" Width="100px" CssClass="input" MaxLength="100"></asp:TextBox>
                                </td>
                            </tr>
                        </table>
                        <div class="linex">
                        </div>
                        <table width="560" border="0" cellpadding="0" cellspacing="0" class="12text">
                            <tr>
                                <td>
                                    <div align="right">
                                        联系人:</div>
                                </td>
                                <td>
                                    <asp:TextBox ID="txtLinkMan" runat="server" CssClass="input" MaxLength="10"></asp:TextBox>
                                </td>
                                <td>
                                    <div align="right">
                                        联系地址:</div>
                                </td>
                                <td>
                                    <asp:TextBox ID="txtAddress" runat="server" CssClass="inputlong" MaxLength="50"></asp:TextBox>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <div align="right">
                                        联系电话:</div>
                                </td>
                                <td>
                                    <asp:TextBox ID="txtPhone" runat="server" CssClass="input" MaxLength="20"></asp:TextBox>
                                </td>
                                <td>
                                    <div align="right">
                                        电子邮件:</div>
                                </td>
                                <td>
                                    <asp:TextBox ID="txtEmail" runat="server" CssClass="inputlong" MaxLength="200"></asp:TextBox>
                                </td>
                            </tr>
                        </table>
                    </div>
                    <div style="float: left;">
                        <div class="con">
                            <div class="base">
                                佣金方案[仅限新增]</div>
                            <div class="kuang5">
                                <table width="220" border="0" cellpadding="0" cellspacing="0" class="text25">
                                    <tr>
                                        <td width="60">
                                            <div align="right">
                                                方案名称:</div>
                                        </td>
                                        <td colspan="2">
                                            <asp:DropDownList ID="selScheme" CssClass="inputmid" runat="server">
                                            </asp:DropDownList>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <div align="right">
                                                起始年月:</div>
                                        </td>
                                        <td colspan="2">
                                            <asp:TextBox ID="txtBeginTime" runat="server" CssClass="input" MaxLength="7" Width="80px" />
                                            [YYYY-MM]
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <div align="right">
                                                终止年月:</div>
                                        </td>
                                        <td>
                                            <asp:TextBox ID="txtEndTime" runat="server" CssClass="input" MaxLength="7" Width="80px" />
                                            <asp:CheckBox ID="chkEndDate" runat="server" AutoPostBack="true" OnCheckedChanged="chkEndDate_CheckedChanged" />无限期
                                        </td>
                                    </tr>
                                </table>
                            </div>
                        </div>
                    </div>
                    <div class="footall" style="height: 1px;">
                    </div>
                </div>
            </div>
            <div class="btns">
                <table width="200" border="0" align="right" cellpadding="0" cellspacing="0">
                    <tr>
                        <td>
                            <asp:Button ID="btnAdd" runat="server" Text="增加" CssClass="button1" OnClick="btnAdd_Click" />
                        </td>
                        <td>
                            <asp:Button ID="btnModify" runat="server" Text="修改" Enabled="false" CssClass="button1"
                                OnClick="btnModify_Click" />
                        </td>
                    </tr>
                </table>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
    </form>
</body>
</html>

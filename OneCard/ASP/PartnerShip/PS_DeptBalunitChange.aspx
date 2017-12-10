<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PS_DeptBalunitChange.aspx.cs"
    Inherits="ASP_PartnerShip_PS_DeptBalunitChange" EnableEventValidation="false" %>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>网点结算单元维护</title>
    <script type="text/javascript" src="../../js/myext.js"></script>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
    <div class="tb">
        合作伙伴->网点结算单元信息维护</div>
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
            查询网点结算单元信息</div>
        <div class="kuang5">
            <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                <tr>
                    <td align="right">
                        单元类型:
                    </td>
                    <td>
                        <asp:DropDownList ID="ddlBalType" CssClass="input" runat="server" OnSelectedIndexChanged="ddlBalType_SelectedIndexChanged"
                            AutoPostBack="true">
                            <asp:ListItem Text="---请选择---" Value=""></asp:ListItem>
                            <asp:ListItem Text="0:自营网点" Value="0"></asp:ListItem>
                            <asp:ListItem Text="1:代理网点" Value="1"></asp:ListItem>
                            <asp:ListItem Text="2:代理商户" Value="2"></asp:ListItem>
                        </asp:DropDownList>
                    </td>
                    <td align="right">
                        结算单元:
                    </td>
                    <td>
                        <asp:DropDownList ID="selBalUnit" CssClass="inputmidder" runat="server">
                        </asp:DropDownList>
                    </td>
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
                        <asp:Button ID="btnQuery" runat="server" Text="查询" CssClass="button1" OnClick="btnQuery_Click" />
                    </td>
                </tr>
            </table>
            <div style="height: 200px; width: 100%; overflow: scroll">
                <asp:UpdatePanel ID="UpdatePanel2" runat="server" RenderMode="Inline">
                    <ContentTemplate>
                        <asp:GridView ID="lvwBalUnits" runat="server" CssClass="tab1" Width="280%" HeaderStyle-CssClass="tabbt"
                            AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel" AllowPaging="False"
                            PageSize="1000" PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="Left"
                            PagerStyle-VerticalAlign="Top" AutoGenerateColumns="False" OnSelectedIndexChanged="lvwBalUnits_SelectedIndexChanged"
                            OnRowCreated="lvwBalUnits_RowCreated" EmptyDataText="没有数据记录!">
                            <Columns>
                                <asp:BoundField DataField="NUM" HeaderText="#" />
                                <asp:TemplateField HeaderText="有效标志">
                                    <ItemTemplate>
                                        <asp:Label ID="labUseTag" Text='<%# Eval("USETAG").ToString() == "1" ? "有效" : Eval("USETAG").ToString() == "0" ? "无效" : Eval("USETAG").ToString()%>'
                                            runat="server"></asp:Label>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField DataField="DBALUNITNO" HeaderText="结算单元编码" />
                                <asp:BoundField DataField="DBALUNIT" HeaderText="结算单元名称" />
                                <asp:BoundField DataField="DEPTTYPE" HeaderText="单元类型" />
                                <asp:BoundField DataField="CREATETIME" HeaderText="合作时间" DataFormatString="{0:yyyy-MM-dd}"
                                    HtmlEncode="false" />
                                <asp:BoundField DataField="BANKNAME" HeaderText="开户银行" />
                                <asp:BoundField DataField="BANKACCNO" HeaderText="银行帐号" />
                                <asp:BoundField DataField="BALCYCLETYPE" HeaderText="结算周期类型" />
                                <asp:BoundField DataField="BALINTERVAL" HeaderText="结算周期跨度" />
                                <asp:BoundField DataField="FINCYCLETYPE" HeaderText="划账周期类型" />
                                <asp:BoundField DataField="FININTERVAL" HeaderText="划账周期跨度" />
                                <asp:BoundField DataField="FINTYPE" HeaderText="转账类型" />
                                <asp:BoundField DataField="FINBANK" HeaderText="转出银行" />
                                <asp:BoundField DataField="PREPAYWARNLINE" HeaderText="预警额度" />
                                <asp:BoundField DataField="PREPAYLIMITLINE" HeaderText="最低额度" />
                                <asp:BoundField DataField="LINKMAN" HeaderText="联系人" />
                                <asp:BoundField DataField="UNITPHONE" HeaderText="联系电话" />
                                <asp:BoundField DataField="UNITADD" HeaderText="联系地址" />
                                <asp:BoundField DataField="UNITEMAIL" HeaderText="电子邮件" />
                                <asp:BoundField DataField="DBALUNITKEY" HeaderText="商户key" />
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
                                            合作时间
                                        </td>
                                        <td>
                                            开户银行
                                        </td>
                                        <td>
                                            银行帐号
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
                                            转出银行
                                        </td>
                                        <td>
                                            预警额度
                                        </td>
                                        <td>
                                            最低额度
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
                                            商户key
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
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="12text">
                        <tr>
                            <td>
                                <div align="right">
                                    单元编码:</div>
                            </td>
                            <td>
                                <asp:TextBox ID="txtBalUnitNo" CssClass="input" runat="server" MaxLength="8"></asp:TextBox>
                            </td>
                            <td>
                                <div align="right">
                                    单元类型:</div>
                            </td>
                            <td>
                                <asp:DropDownList ID="selBalType" CssClass="input" runat="server" OnSelectedIndexChanged="selBalType_SelectedIndexChanged"
                                    AutoPostBack="true">
                                    <asp:ListItem Text="---请选择---" Value=""></asp:ListItem>
                                    <asp:ListItem Text="0:自营网点" Value="0"></asp:ListItem>
                                    <asp:ListItem Text="1:代理网点" Value="1"></asp:ListItem>
                                    <asp:ListItem Text="2:代理商户" Value="2"></asp:ListItem>
                                </asp:DropDownList>
                            </td>
                            <td>
                                <div align="right">
                                    单元名称:</div>
                            </td>
                            <td>
                                <asp:TextBox ID="txtBalUnit" runat="server" CssClass="inputmidder" MaxLength="25"></asp:TextBox>
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
                            <td colspan="5">
                                <asp:TextBox ID="txtFinBank" CssClass="inputmid" runat="server" AutoPostBack="true"
                                    OnTextChanged="txtFinBank_Changed"></asp:TextBox>
                                <asp:DropDownList ID="selFinBank" CssClass="inputmidder" runat="server">
                                </asp:DropDownList>
                            </td>
                        </tr>
                    </table>
                    <div class="linex">
                    </div>
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="12text">
                        <tr>
                            <td>
                                <div align="right">
                                    转账类型:
                                </div>
                            </td>
                            <td>
                                <asp:DropDownList ID="selFinType" CssClass="input" runat="server">
                                </asp:DropDownList>
                            </td>
                            <td>
                                <div align="right">
                                    结算周期类型:</div>
                            </td>
                            <td>
                                <asp:DropDownList ID="selBalCyclType" CssClass="input" runat="server">
                                </asp:DropDownList>
                            </td>
                            <td>
                                <div align="right">
                                    结算周期跨度:</div>
                            </td>
                            <td>
                                <asp:TextBox ID="txtBalInterval" runat="server" CssClass="input" MaxLength="7"></asp:TextBox>
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
                                <asp:TextBox ID="txtFinInterval" runat="server" CssClass="input" MaxLength="7"></asp:TextBox>
                            </td>
                            <td>
                                <div align="right">
                                    有效标志:
                                </div>
                            </td>
                            <td>
                                <asp:DropDownList ID="selUseTag" CssClass="input" runat="server">
                                </asp:DropDownList>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    预警额度:</div>
                            </td>
                            <td>
                                <asp:TextBox ID="txtWarnline" CssClass="input" runat="server" MaxLength="8"></asp:TextBox>元
                            </td>
                            <td>
                                <div align="right">
                                    最低额度:</div>
                            </td>
                            <td>
                                <asp:TextBox ID="txtLimitline" CssClass="input" runat="server" MaxLength="8"></asp:TextBox>元
                            </td>
                            <td>
                                <div align="right">
                                    备注:</div>
                            </td>
                            <td>
                                <asp:TextBox ID="txtRemark" runat="server" CssClass="inputmidder" MaxLength="50"></asp:TextBox>
                            </td>
                        </tr>
                    </table>
                    <div class="linex">
                    </div>
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="12text">
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
                                <asp:TextBox ID="txtAddress" runat="server" CssClass="inputlong" MaxLength="25"></asp:TextBox>
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
                                <asp:TextBox ID="txtEmail" runat="server" CssClass="inputlong" MaxLength="50"></asp:TextBox>
                            </td>
                        </tr>
                    </table>
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

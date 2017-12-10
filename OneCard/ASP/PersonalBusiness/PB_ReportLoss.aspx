<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PB_ReportLoss.aspx.cs" Inherits="ASP_PersonalBusiness_PB_ReportLoss" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head2" runat="server">
    <title>挂失解挂</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <link href="../../css/photo.css" rel="stylesheet" type="text/css" />

    <script type="text/javascript" src="../../js/print.js"></script>

    <script type="text/javascript" src="../../js/myext.js"></script>

</head>
<body>
    <form id="form2" runat="server">
        <div class="tb">
            个人业务->挂失解挂
        </div>
        <ajaxToolkit:ToolkitScriptManager EnableScriptGlobalization="true" EnableScriptLocalization="true"
            ID="ToolkitScriptManager1" runat="server" />

        <script type="text/javascript" language="javascript">
                var swpmIntance = Sys.WebForms.PageRequestManager.getInstance();
                swpmIntance.add_initializeRequest(BeginRequestHandler);
                swpmIntance.add_pageLoading(EndRequestHandler);
								function BeginRequestHandler(sender, args){
    							try {MyExtShow('请等待', '正在提交后台处理中...'); } catch(ex){}
								}
								function EndRequestHandler(sender, args) {
    							try {MyExtHide(); } catch(ex){}
								}
        </script>

        <asp:UpdatePanel ID="UpdatePanel2" UpdateMode="Conditional" runat="server" RenderMode="inline">
            <ContentTemplate>
                <aspControls:PrintPingZheng ID="ptnPingZheng" runat="server" PrintArea="ptnPingZheng1">
                </aspControls:PrintPingZheng>
                <asp:BulletedList ID="bulMsgShow" runat="server">
                </asp:BulletedList>

                <script runat="server">public override void ErrorMsgShow() { ErrorMsgHelper(bulMsgShow); }</script>

                <div class="con">
                    <div class="base">
                    </div>
                    <div class="kuang5">
                        <table class="text25" cellspacing="0" cellpadding="0" width="100%" border="0">
                            <tbody>
                                <tr>
                                    <td style="width: 10%; height: 25px" align="right">
                                        证件号:
                                    </td>
                                    <td style="width: 20%; height: 25px" valign="middle">
                                        <asp:TextBox ID="txtPaperno" runat="server" CssClass="input" MaxLength="18" Width="135px"></asp:TextBox>&nbsp;&nbsp;
                                    </td>
                                    <td style="width: 10%; height: 25px" align="right">
                                        卡号:
                                    </td>
                                    <td style="width: 20%; height: 25px" valign="middle">
                                        <asp:TextBox ID="txtCardNo" runat="server" CssClass="input" MaxLength="16" Width="135px"></asp:TextBox>&nbsp;&nbsp;
                                    </td>
                                    <td style="width: 5%; height: 25px" align="right">
                                        &nbsp;</td>
                                    <td style="width: 15%; height: 25px">
                                        <asp:Button ID="btnQuery" OnClick="btnQuery_Click" runat="server" CssClass="button1"
                                            Text="查询"></asp:Button>
                                    </td>
                                    <td style="width: 20%; height: 25px">
                                        &nbsp;</td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                    <div class="base">
                    </div>
                    <div class="kuang5">
                        <div style="height: 130px" class="gdtb">
                            <asp:GridView ID="gvResult" runat="server" CssClass="tab1" AllowPaging="False" EmptyDataText="没有数据记录!"
                                PagerStyle-VerticalAlign="Top" PagerStyle-HorizontalAlign="left" PagerSettings-Mode="NumericFirstLast"
                                SelectedRowStyle-CssClass="tabsel" AlternatingRowStyle-CssClass="tabjg" HeaderStyle-CssClass="tabbt"
                                Width="98%" OnSelectedIndexChanged="gv_SelectedIndexChanged" AutoGenerateSelectButton="True"
                                PageSize="5">
                                <PagerSettings Mode="NumericFirstLast"></PagerSettings>
                                <PagerStyle HorizontalAlign="Left" VerticalAlign="Top"></PagerStyle>
                                <SelectedRowStyle CssClass="tabsel" ></SelectedRowStyle>
                                <HeaderStyle CssClass="tabbt"></HeaderStyle>
                                <AlternatingRowStyle CssClass="tabjg"></AlternatingRowStyle>
                            </asp:GridView>
                        </div>
                    </div>
                </div>
                <div class="basicinfo">
                    <div class="money">
                        费用信息</div>
                    <div class="kuang5">
                        <div style="height: 170px">
                            <table class="tab1" cellspacing="0" cellpadding="0" width="98%" border="0">
                                <tbody>
                                    <tr class="tabbt">
                                        <td width="66">
                                            费用项目</td>
                                        <td width="94">
                                            费用金额(元)</td>
                                    </tr>
                                    <tr>
                                        <td>
                                            挂失</td>
                                        <td>
                                            0.00</td>
                                    </tr>
                                    <tr class="tabjg">
                                        <td>
                                            解挂</td>
                                        <td>
                                            0.00</td>
                                    </tr>
                                    <tr>
                                        <td>
                                            其他费用</td>
                                        <td>
                                            0.00</td>
                                    </tr>
                                    <tr>
                                    </tr>
                                    <tr class="tabjg">
                                        <td>
                                            合计应收</td>
                                        <td>
                                            0.00</td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
                <div class="pipinfo">
                    <div class="info">
                        卡片信息</div>
                    <div class="kuang5" style="height:65px">
                        <table class="text20" cellspacing="0" cellpadding="0" width="98%" border="0">
                            <tbody>
                                <tr>
                                    <td width="12%">
                                        <div align="right">
                                            用户卡号:</div>
                                    </td>
                                    <td width="18%">
                                        <asp:Label ID="lblCardno" runat="server" Text="" Width="100%"></asp:Label>
                                    </td>
                                    <td width="15%">
                                        <div align="right">
                                            卡序列号:</div>
                                    </td>
                                    <td width="20%">
                                        <asp:Label ID="lblAsn" runat="server" Text="" Width="100%"></asp:Label>
                                    </td>
                                    <td width="15%">
                                        <div align="right">
                                            卡片类型:</div>
                                    </td>
                                    <td width="20%">
                                        <asp:Label ID="lblCardtype" runat="server" Text="" Width="100%"></asp:Label>
                                    </td>
                                </tr>
                                <tr>
                                    <td width="12%">
                                        <div align="right">
                                            卡片状态:</div>
                                    </td>
                                    <td width="18%">
                                        <asp:Label ID="lblCardstate" runat="server" Text="" Width="100%"></asp:Label>
                                        <input id="hidCardstate" type="hidden" runat="server" />
                                    </td>
                                    <td width="15%">
                                        <div align="right">
                                            启用日期:</div>
                                    </td>
                                    <td width="20%">
                                        <asp:Label ID="lblSDate" runat="server" Text="" Width="100%"></asp:Label>
                                    </td>
                                    <td width="15%">
                                        <div align="right">
                                            结束日期:</div>
                                    </td>
                                    <td width="20%">
                                        <asp:Label ID="lblEDate" runat="server" Text="" Width="100%"></asp:Label>
                                    </td>
                                </tr>
                                <tr>
                                    <td width="12%">
                                        <div align="right">
                                            账户余额:</div>
                                    </td>
                                    <td width="18%">
                                        <asp:Label ID="lblCardaccmoney" runat="server" Text="" Width="100%"></asp:Label>
                                    </td>
                                    <td colspan="4">
                                        &nbsp;</td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
                <div class="pipinfo">
                    <div class="pip">
                        用户信息</div>
                    <div class="kuang5"  style="height:65px">
                        <table class="text20" cellspacing="0" cellpadding="0" width="98%" border="0">
                            <tbody>
                                <tr>
                                    <td width="12%">
                                        <div align="right">
                                            用户姓名:</div>
                                    </td>
                                    <td width="18%">
                                        <asp:Label ID="lblCustName" runat="server" Text="" Width="100%"></asp:Label>
                                    </td>
                                    <td width="15%">
                                        <div align="right">
                                            出生日期:</div>
                                    </td>
                                    <td width="20%">
                                        <asp:Label ID="lblCustBirthday" runat="server" Text="" Width="100%"></asp:Label>
                                    </td>
                                    <td width="15%">
                                        <div align="right">
                                            证件类型:</div>
                                    </td>
                                    <td width="20%">
                                        <asp:Label ID="lblPapertype" runat="server" Text="" Width="100%"></asp:Label>
                                    </td>
                                </tr>
                                <tr>
                                    <td width="12%">
                                        <div align="right">
                                            用户性别:</div>
                                    </td>
                                    <td width="18%">
                                        <asp:Label ID="lblCustsex" runat="server" Text="" Width="100%"></asp:Label>
                                    </td>
                                    <td width="15%">
                                        <div align="right">
                                            联系电话:</div>
                                    </td>
                                    <td width="20%">
                                        <asp:Label ID="lblCustphone" runat="server" Text="" Width="100%"></asp:Label>
                                    </td>
                                    <td width="15%">
                                        <div align="right">
                                            证件号码:</div>
                                    </td>
                                    <td width="20%">
                                        <asp:Label ID="lblPaperno" runat="server" Text="" Width="100%"></asp:Label>
                                    </td>
                                </tr>
                                <tr>
                                    <td width="12%">
                                        <div align="right">
                                            邮政编码:</div>
                                    </td>
                                    <td width="18%">
                                        <asp:Label ID="lblCustpost" runat="server" Text="" Width="100%"></asp:Label>
                                    </td>
                                    <td width="15%">
                                        <div align="right">
                                            联系地址:</div>
                                    </td>
                                    <td colspan="3">
                                        <asp:Label ID="lblCustaddr" runat="server" Text="" Width="100%"></asp:Label>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
                <div class="btns">
                    <table cellspacing="0" cellpadding="0" width="95%" border="0">
                        <tbody>
                            <tr>
                                <td width="55%">
                                    <asp:CheckBox ID="chkPingzheng" runat="server" Text="自动打印凭证" Checked="true"></asp:CheckBox>
                                    &nbsp;&nbsp;&nbsp;
                                </td>
                                <td align="right">
                                    <asp:Button ID="btnPrintPZ" runat="server" CssClass="button1" Text="打印凭证" OnClientClick="printdiv('ptnPingZheng1')"
                                        Enabled="false"></asp:Button>
                                </td>
                                <td align="right">
                                    <asp:RadioButton ID="rdoReportLoss" runat="server" Text="口头挂失" Enabled="false" Visible="false" OnCheckedChanged="rdo_CheckedChanged"
                                        GroupName="ReportLoss" AutoPostBack="true"></asp:RadioButton>
                                </td>
                                <td align="right">
                                    <asp:RadioButton ID="rdoRealReportLoss" runat="server" Text="书面挂失" Enabled="false"
                                        OnCheckedChanged="rdo_CheckedChanged" GroupName="ReportLoss" AutoPostBack="true">
                                    </asp:RadioButton>
                                </td>
                                <td align="right">
                                    <asp:RadioButton ID="rdoCancelLoss" runat="server" Text="解挂" Enabled="false" OnCheckedChanged="rdo_CheckedChanged"
                                        GroupName="ReportLoss" AutoPostBack="true"></asp:RadioButton>
                                </td>
                                <td align="right">
                                    <asp:Button ID="btnSubmit" OnClick="btnSubmit_Click" runat="server" CssClass="button1"
                                        Text="提交" Enabled="false"></asp:Button></td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </ContentTemplate>
        </asp:UpdatePanel>
    </form>
</body>
</html>

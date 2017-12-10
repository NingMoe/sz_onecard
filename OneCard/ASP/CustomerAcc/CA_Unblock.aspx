<%@ Page Language="C#" AutoEventWireup="true" CodeFile="CA_Unblock.aspx.cs" Inherits="ASP_CustomerAcc_CA_Unblock" EnableEventValidation="false"%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>账户解挂</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <link href="../../css/photo.css" rel="stylesheet" type="text/css" />        
    <link  href="../../css/Cust_AS.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="../../js/print.js"></script>

    <script type="text/javascript" src="../../js/myext.js"></script>

</head>
<body>
    <form id="form1" runat="server">
        <table border="0" cellpadding="0" cellspacing="0" width="100%">
            <tr>
                <td class="cust_left"></td>
                <td class="cust_mid">专有账户->账户解挂</td>
                <td class="cust_right"></td>
             </tr>
        </table>
        <ajaxToolkit:ToolkitScriptManager runat="Server" EnableScriptGlobalization="true"
            EnableScriptLocalization="true" ID="ScriptManager2" />

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

        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
            <ContentTemplate>
                <aspControls:PrintPingZheng ID="ptnPingZheng" runat="server" PrintArea="ptnPingZheng1" />
                <asp:BulletedList ID="bulMsgShow" runat="server">
                </asp:BulletedList>

                <script runat="server">public override void ErrorMsgShow() { ErrorMsgHelper(bulMsgShow); }</script>
                <div class="cust_tabbox">
                    <table border="0" cellpadding="0" cellspacing="0" width="100%">
    	                <td class="cust_top1_l"><div class="cust_p6"></div></td>
                        <td class="cust_top1_m"><span style="line-height:22px; margin-left:5px; color:#333;">查询卡号</span></td>
                        <td class="cust_top1_r"></td>
                    </table>
                    <div class="cust_line1"></div>
                    <div class="cust_line2"></div>
                    <table border="0" cellpadding="0" cellspacing="0" width="100%" class="cust_form">
    	                <tr>
    	                <th width="5%">姓名：</th>
                            <td width="15%"><asp:TextBox ID="txtName" runat="server" CssClass="input" MaxLength="20" Width="135px"></asp:TextBox>
                                </td>
        	                <th width="10%">证件号码：</th>
                            <td width="20%"><asp:TextBox ID="txtPaperno" runat="server" CssClass="input" MaxLength="20" Width="135px"></asp:TextBox>
                                </td>
                            <th width="10%">卡号：</th>
                            <td width="20%"><asp:TextBox ID="txtCardNo" runat="server" CssClass="input" MaxLength="16" Width="135px"></asp:TextBox>
                            </td>
                        </tr>
                        <tr>
                            <th width="10%">
                                单位：
                            </th>
                            <td width="30%" colspan=4>
                               <asp:DropDownList ID="selCorp" CssClass="inputmidder" runat="server"></asp:DropDownList>
                            </td>
                            <td style="width: 15%; height: 25px"><div class="cust_bton2"><asp:LinkButton ID="btnQuery" OnClick="btnQuery_Click" runat="server" 
                                            Text="查询"></asp:LinkButton></div></td>
                        </tr>
                    </table>
                    <table cellspacing="0" cellpadding="0" width="100%" border="0">
                        <tr>
                            <td>
                                <div>
                                    <asp:GridView ID="gvResult" runat="server" CssClass="tab1" AllowPaging="true" EmptyDataText="没有数据记录!"
                                        PagerStyle-VerticalAlign="Top" PagerStyle-HorizontalAlign="left" PagerSettings-Mode="NumericFirstLast"
                                        SelectedRowStyle-CssClass="tabsel" AlternatingRowStyle-CssClass="tabjg" HeaderStyle-CssClass="tabbt"
                                        Width="100%" OnSelectedIndexChanged="gv_SelectedIndexChanged" OnRowDataBound="gvResult_RowDataBound" 
                                        OnRowCreated="gv_RowCreated" PageSize="5" OnPageIndexChanging="gvResult_Page">
                                        <PagerSettings Mode="NumericFirstLast"></PagerSettings>
                                        <PagerStyle HorizontalAlign="Left" VerticalAlign="Top"></PagerStyle>
                                        <SelectedRowStyle CssClass="tabsel"></SelectedRowStyle>
                                        <HeaderStyle CssClass="tabbt"></HeaderStyle>
                                        <AlternatingRowStyle CssClass="tabjg"></AlternatingRowStyle>
                                    </asp:GridView>
                                </div>
                            </td>
                        </tr>
                    </table>
                </div>
             <div class="cust_tabbox">
    	        <table border="0" cellpadding="0" cellspacing="0" width="100%">
    	        <td class="cust_top1_l"><div class="cust_p3"></div></td>
                <td class="cust_top1_m"><span style="line-height:22px; margin-left:5px; color:#333;">账户信息</span></td>
                <td class="cust_top1_r"></td>
                </table>
                <div class="cust_line1"></div>
                <div class="cust_line2"></div>
                <table border="0" cellpadding="0" cellspacing="0" width="100%">
    	            <tr>
    	                <td>
    	                    <div>
                            <asp:GridView ID="gvAccount" runat="server" Width="100%" CssClass="tab1" HeaderStyle-CssClass="tabbt"
                                AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel" PagerSettings-Mode="NumericFirstLast"
                                PageSize="200" AllowPaging="True"  PagerStyle-HorizontalAlign="left"
                                PagerStyle-VerticalAlign="Top" AutoGenerateColumns="false" 
                                EmptyDataText="没有数据记录!">
                                <Columns>
                                    <asp:BoundField DataField="ACCT_TYPE_NAME" HeaderText="账户类型" />
                                    <asp:BoundField DataField="LIMIT_DAYAMOUNT" HeaderText="每日消费限额" />
                                    <asp:BoundField DataField="LIMIT_EACHTIME" HeaderText="每笔消费限额" />
                                    <asp:BoundField DataField="EFF_DATE" HeaderText="生效日期" />
                                    <asp:BoundField DataField="STATENAME" HeaderText="状态" />
                                    <asp:BoundField DataField="Create_Date" HeaderText="创建日期" />
                                    <asp:BoundField DataField="REL_BALANCE" HeaderText="专有账户余额" />
                                    <asp:BoundField DataField="Total_Consume_Money" HeaderText="总消费金额" />
                                    <asp:BoundField DataField="Total_Consume_Times" HeaderText="总消费次数" />
                                    <asp:BoundField DataField="LAST_CONSUME_TIME" HeaderText="最后消费时间" />
                                    <asp:BoundField DataField="Total_Supply_Money" HeaderText="总充值金额" />
                                    <asp:BoundField DataField="Total_Supply_Times" HeaderText="总充值次数" />
                                    <asp:BoundField DataField="LAST_SUPPLY_TIME" HeaderText="最后充值时间" />
                                </Columns>
                            </asp:GridView>
                            </div>
    	                </td>
    	            </tr>
    	         </table>
             </div>
             <div class="cust_tabbox">
                <table border="0" cellpadding="0" cellspacing="0" width="100%">
                <tr>
    	        <td class="cust_top1_l"><div class="cust_p10"></div></td>
                <td class="cust_top1_m"><span style="line-height:22px; margin-left:5px; color:#333;">用户信息</span></td>
                <td class="cust_top1_r"></td>
                </tr>
                </table>
                <div class="cust_line1"></div>
                <div class="cust_line2"></div>
                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="cust_form">
                            <tr>
                                <th style="width: 10%">
                                        用户姓名：
                                </th>
                                <td style="width: 17%">
                                    <asp:Label ID="lblCustName" runat="server" CssClass="labeltext"></asp:Label>
                                </td>
                                <th style="width: 10%">
 
                                        出生日期：
                                </th>
                                <td style="width: 15%">
                                    <asp:Label ID="lblCustBirthday" runat="server" CssClass="labeltext"></asp:Label>
                                </td>
                                <th style="width: 10%">
                                        证件类型：
                                </th>
                                <td style="width: 10%">
                                    <asp:Label ID="lblPapertype" runat="server" CssClass="labeltext"></asp:Label>
                                    <input type="hidden" id="hidPapertype" runat="server" />
                                </td>
                                <th style="width: 10%">
                                        证件号码：
                                </th>
                                <td style="width: 18%">
                                    <asp:Label ID="lblPaperno" runat="server" CssClass="labeltext"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <th>
                                        用户性别：
                                </th>
                                <td>
                                    <asp:Label ID="lblCustsex" runat="server" CssClass="labeltext"></asp:Label></td>
                                <th>
                                        手机号码：
                                </th>
                                <td>
                                    <asp:Label ID="lblCustphone" runat="server" CssClass="labeltext"></asp:Label></td>
                                <th>
                                        固定电话：
                                </th>
                                <td>
                                    <asp:Label ID="lblCustTelphone" runat="server" CssClass="labeltext"></asp:Label>
                                </td>
                                <th>
                                        邮政编码：
                                </th>
                                <td>
                                    <asp:Label ID="lblCustpost" runat="server" CssClass="labeltext"></asp:Label></td>
                            </tr>
                            <tr>
                                <th>
                                        电子邮件：
                                </th>
                                <td>
                                    <asp:Label ID="lblEmail" runat="server" CssClass="labeltext"></asp:Label>
                                </td>
                                <th valign="top">
                                        联系地址：
                                </th>
                                <td colspan="5">
                                    <asp:Label ID="lblCustaddr" runat="server" CssClass="labeltext"></asp:Label></td>
                            </tr>
                        </table>
            </div>
                <div class="cust_tabbox">
                <div class="cust_bottom_bton"> <asp:LinkButton ID="btnSubmit" OnClientClick="return confirm('确认提交?');"  OnClick="btnSubmit_Click" runat="server" 
                                        Text="提交" Enabled="false"></asp:LinkButton></div>
                </div>
                
            </ContentTemplate>
        </asp:UpdatePanel>
    </form>
</body>
</html>

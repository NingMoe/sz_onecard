<%@ Page Language="C#" AutoEventWireup="true" CodeFile="CA_Recover.aspx.cs" Inherits="ASP_CustomerAcc_CA_Recover" EnableEventValidation="false" %>

<%@ Register Src="../../CardReader.ascx" TagName="CardReader" TagPrefix="cr" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>抹帐</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <link  href="../../css/Cust_AS.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="../../js/jquery-1.5.min.js"></script>
    <script type="text/javascript" src="../../js/print.js"></script>

    <script type="text/javascript">
    function showMoreToggle()
    {
        $("#divCardInfoTitle").toggle("slow");
        
        $("#divCardInfo").toggle();
        
        if($("#btnMore").html() == "更多&lt;&lt;")
        {
            $("#btnMore").html("更多&gt;&gt;");
            
        }
        else
        {
            $("#btnMore").html("更多&lt;&lt;");
        }
    }
    </script>

</head>
<body>
    <cr:CardReader ID="cardReader" runat="server" />
    <form id="form1" runat="server">
        <table border="0" cellpadding="0" cellspacing="0" width="100%">
            <tr>
                <td class="cust_left"></td>
                <td class="cust_mid">专有账户->抹帐</td>
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
                    <tr>
    	                <td class="cust_top1_l"><div class="cust_p1"></div></td>
                        <td class="cust_top1_m"><span style="line-height:22px; margin-left:5px; color:#333;">卡内信息</span></td>
                        <td class="cust_top1_r"></td>
                    </tr>
                    </table>
                    <div class="cust_line1"></div>
                    <div class="cust_line2"></div>
                    <table width="100%" border="0" cellpadding="0" cellspacing="0" class="cust_form">
                            <tr>
                                <th style="width: 10%">
                                        用户卡号：
                                    <asp:HiddenField ID="hiddenSupplyid" runat="server" />
                                    <asp:HiddenField ID="hidCANCELTAG" runat="server" />
                                </th>
                                <td style="width: 17%">
                                    <asp:TextBox ID="txtCardno" CssClass="input" MaxLength="16" runat="server"></asp:TextBox>
                                </td>
                                <th style="width: 10%">
                                        卡序列号：
                                </th>
                                <td style="width: 15%">
                                    <asp:TextBox ID="LabAsn" CssClass="labeltext" runat="server"></asp:TextBox>
                                    <asp:HiddenField ID="hiddenAsn" runat="server" />
                                </td>
                                <th style="width: 10%">
                                        卡片类型：
                                </th>
                                <td style="width: 10%">
                                    <asp:TextBox ID="LabCardtype" CssClass="labeltext" runat="server"></asp:TextBox>
                                    <asp:HiddenField ID="hiddenLabCardtype" runat="server" />
                                </td>
                                <th>
                                        电子钱包余额：
                                </th>
                                <td>
                                    <asp:TextBox ID="cMoney" CssClass="labeltext" runat="server"></asp:TextBox>
                                    <asp:HiddenField ID="hiddencMoney" runat="server" />
                                </td>
                            </tr>
                            <tr>
                                
                                <th>
                                        启用日期：
                                </th>
                                <td>
                                    <asp:TextBox ID="sDate" CssClass="labeltext" runat="server"></asp:TextBox>
                                    <asp:HiddenField ID="hiddensDate" runat="server" />
                                </td>
                                <th>
                                        结束日期：
                                </th>
                                <td colspan=5>
                                    <asp:TextBox ID="eDate" CssClass="labeltext" runat="server"></asp:TextBox>
                                    <asp:HiddenField ID="hiddeneDate" runat="server" />
                                </td>
                                
                            </tr>
                            <tr>
                                <td colspan=8>
                                    <div class="cust_bton1"><a id="btnMore" onclick="showMoreToggle()">更多<<</a></div>
                                    <div class="cust_bton1"><asp:LinkButton ID="btnDBread" runat="server" Text="读数据库" OnClick="btnDBread_Click" /></div>
                                    <div class="cust_bton1"><asp:LinkButton ID="btnReadCard"  runat="server" OnClick="btnReadCard_Click"
                                        Text="读卡" OnClientClick="return ReadCardInfo()" /></div>
                                </td>
                            </tr>
                        </table>
                </div>
                <div class="cust_tabbox">
                    <div  id="divCardInfoTitle" style="display: none">
                        <table border="0" cellpadding="0" cellspacing="0" width="100%">
                        <tr>
    	                    <td class="cust_top2_l"><div class="cust_p2"></div></td>
                            <td class="cust_top2_m"><span style="line-height:22px; margin-left:5px; color:#FFF;">卡户信息</span></td>
                            <td class="cust_top2_r"></td>
                        </tr>
                        </table>
                        <div class="cust_line1"></div>
                        <div class="cust_line2"></div>
                    </div>
                    <div id="divCardInfo" style="display: none">
                        <table width="100%" border="0" cellpadding="0" cellspacing="0" class="cust_form1">
                            <tr>
                                <th style="width: 10%">
                                        库存状态：
                                </th>
                                <td style="width: 17%">
                                    <asp:Label ID="lblResState" runat="server" CssClass="labeltext"></asp:Label>
                                </td>
                                <th style="width: 10%">
                                        卡序列号：
                                </th>
                                <td style="width: 15%">
                                    <asp:Label ID="lblAsn" runat="server" CssClass="labeltext"></asp:Label>
                                </td>
                                <th style="width: 10%">
                                        卡片类型：
                                </th>
                                <td style="width: 10%" colspan=3>
                                    <asp:Label ID="lblCardtype" runat="server" CssClass="labeltext"></asp:Label>
                                </td>
                                <%--<th style="width: 10%">
                                        库内余额：
                                </th>
                                <td style="width: 18%">
                                    <asp:Label ID="lblCardccMoney" runat="server" CssClass="labeltext"></asp:Label>
                                </td>--%>
                            </tr>
                            <tr>
                                <th>
                                        售卡日期：
                                </th>
                                <td>
                                    <asp:Label ID="lblSellDate" runat="server" CssClass="labeltext"></asp:Label>
                                </td>
                                <th>
                                        结束日期：
                                </th>
                                <td>
                                    <asp:Label ID="lblEndDate" runat="server" CssClass="labeltext"></asp:Label>
                                </td>
                                <td>
                                    &nbsp;
                                </td>
                                <td>
                                    &nbsp;
                                </td>
                                <td>
                                    &nbsp;</td>
                                <td>
                                    &nbsp;</td>
                            </tr>
                            <tr>
                                <th>
                                        开通功能：
                                </th>
                                <td colspan="7">
                                    <aspControls:OpenFunc ID="openFunc" runat="server" />
                                </td>
                            </tr>
                        </table>
                    </div>
                </div>
                <div class="cust_tabbox">
                    <table border="0" cellpadding="0" cellspacing="0" width="100%">
                    <tr>
    	                <td class="cust_top1_l"><div class="cust_p3"></div></td>
                        <td class="cust_top1_m"><span style="line-height:22px; margin-left:5px; color:#333;">账户信息</span></td>
                        <td class="cust_top1_r"></td>
                    </tr>
                    </table>
                    <div class="cust_line1"></div>
                    <div class="cust_line2"></div>
                     <table width="100%" border="0" cellpadding="0" cellspacing="0">
                        <tr>
                            <td>
                                <div style="height: 100px" class="gdtb">
                                    <asp:GridView ID="gvAccount" runat="server" Width="100%" CssClass="tab1" HeaderStyle-CssClass="tabbt"
                                        AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel" PagerSettings-Mode="NumericFirstLast"
                                        PageSize="200" AllowPaging="True"  PagerStyle-HorizontalAlign="left"
                                        PagerStyle-VerticalAlign="Top" AutoGenerateColumns="false" onrowcreated="gvAccount_RowCreated"
                                        onselectedindexchanged="gvAccount_SelectedIndexChanged"
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
                                <th >
                                        联系地址：
                                </th>
                                <td colspan="5">
                                    <asp:Label ID="lblCustaddr" runat="server" CssClass="labeltext"></asp:Label></td>
                            </tr>
                        </table>
                 </div>
                <div class="cust_tabbox">
	                <table border="0" cellpadding="0" cellspacing="0" width="100%">
	                    <td width="70%">
	                        <table border="0" cellpadding="0" cellspacing="0" width="100%">
            	                <td class="cust_top1_l"><div class="cust_p9"></div></td>
        		                <td class="cust_top1_m">
                	                <table border="0" cellpadding="0" cellspacing="0" width="100%">
                    	                <tr>
                        	                <td align="left"><span style="line-height:22px; margin-left:5px; color:#333;">充值历史</span></td>
                                            <td align="right">
                                                <div class="cust_toptxt"><%--<asp:LinkButton ID="btnQuery"  runat="server" Text="查询" Enabled="false"
                                                                            OnClick="btnQuery_Click" />--%></div>
                                                <span style="float:right;margin-right:5px;margin-top:2px;color:#444;">起始日期：&nbsp;<asp:Label ID="beginDate" runat="server"></asp:Label>&nbsp;&nbsp;&nbsp;
                                                终止日期：&nbsp;<asp:Label ID="endDate" runat="server"></asp:Label></span></td>
                                        </tr>
                                    </table>
                               </td>
        		                <td class="cust_top1_r"></td>
                            </table>
                            <div class="cust_line1"></div>
        	                <div class="cust_line2"></div>
        	                <table border="0" cellpadding="0" cellspacing="0" width="100%">
            	                <tr>
            	                    <td>
            	                        <div style="height: 110px" class="gdtb">
                                            <asp:GridView ID="lvwSupplyQuery" runat="server" Width="100%" CssClass="tab1" HeaderStyle-CssClass="tabbt"
                                                AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel" AllowPaging="false"
                                                PageSize="5" PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left"
                                                OnRowDataBound="lvwSupplyQuery_RowDataBound" PagerStyle-VerticalAlign="Top" AutoGenerateColumns="False">
                                                <Columns>
                                                    <asp:BoundField DataField="ID" HeaderText="序号" />
                                                    <asp:BoundField DataField="TRADETYPE" HeaderText="交易类型" />
                                                    <asp:BoundField DataField="SUPPLYMONEY" HeaderText="交易金额" NullDisplayText="0" DataFormatString="{0:n}"
                                                        HtmlEncode="false" />
                                                    <asp:BoundField DataField="PREMONEY" HeaderText="交易前金额" NullDisplayText="0" DataFormatString="{0:n}"
                                                        HtmlEncode="false" />
                                                    <asp:BoundField DataFormatString="{0:yyyy-MM-dd}" DataField="OPERATETIME" HeaderText="交易日期" />
                                                    <asp:BoundField DataField="STAFFNAME" HeaderText="充值员工" />
                                                    <asp:BoundField DataField="CANCELTAG" HeaderText="回退标志" />
                                                </Columns>
                                                <EmptyDataTemplate>
                                                    <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                                        <tr class="tabbt">
                                                            <td>
                                                                序号</td>
                                                            <td>
                                                                交易类型</td>
                                                            <td>
                                                                交易金额</td>
                                                            <td>
                                                                交易前金额</td>
                                                            <td>
                                                                交易时间</td>
                                                            <td>
                                                                充值员工</td>
                                                        </tr>
                                                    </table>
                                                </EmptyDataTemplate>
                                            </asp:GridView>
                                        </div>
            	                    </td>
            	                </tr>
        	                </table>
	                    </td>
	                    <td width="5px"></td>
                        <td>
                            <table border="0" cellpadding="0" cellspacing="0" width="100%">
            	                <td class="cust_top1_l"><div class="cust_p8"></div></td>
        		                <td class="cust_top1_m"><span style="line-height:22px; margin-left:5px; color:#333;">抹帐信息</span></td>
        		                <td class="cust_top1_r"></td>  
                            </table>
                            <div class="cust_line1"></div>
        	                <div class="cust_line2"></div>
                            <table border="0" cellpadding="0" cellspacing="0" width="100%" class="cust_form2">
            	                <tr>
                	                <th width="30%">充值金额：</th>
                	                <td> <asp:Label ID="SupplyMoney" runat="server" Text=""></asp:Label></td>
                                </tr>
                                <tr>
                	                <th>充值员工：</th>
                	                <td> <asp:Label ID="StaffName" runat="server" Text=""></asp:Label></td>
                                </tr>
                                <tr>
                	                <th>充值日期：</th>
                	                <td><asp:Label ID="SupplyDate" runat="server" Text=""></asp:Label></td>
                                </tr>
                                <tr>
                	                <th>抹帐金额：</th>
                	                <td><asp:Label ID="reCoverMoney" Text="" runat="server"></asp:Label></td>
                                </tr>
                            </table>
                        </td>
	                </table>
	            </div>
               <div class="cust_tabbox">
                <div class="cust_bottom_bton"><asp:LinkButton ID="btnRecover"  runat="server" Text="抹帐" Enabled="false"
                                OnClientClick="return confirm('确认抹帐?');"    OnClick="btnRecover_Click" /></div>
                </div>
                
            </ContentTemplate>
        </asp:UpdatePanel>
    </form>
</body>
</html>

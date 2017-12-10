<%@ Page Language="C#" AutoEventWireup="true" CodeFile="CA_Charge.aspx.cs" Inherits="ASP_CustomerAcc_CA_Charge" EnableEventValidation="false" %>

<%@ Register Src="../../CardReader.ascx" TagName="CardReader" TagPrefix="cr" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>账户充值</title>
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
    
    function submitConfirm()
    {
         if($("#Money").val() != "") 
           {
		        MyExtConfirm('确认','是否确认充值:' + $("#Money").val() + '元?', submitConfirmCallback);
                return false;
           }
           
        return true;
    }
	function submitConfirmCallback(btn)
    {
         if (btn == 'yes') {
            $get('btnConfirm').click();
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
            <td class="cust_mid">专有账户>账户充值</td>
            <td class="cust_right"></td>
         </tr>
    </table>
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
                                </th>
                                <td style="width: 17%">
                                    <asp:TextBox ID="txtCardno" CssClass="input" MaxLength="16" runat="server"></asp:TextBox>
                                    <asp:HiddenField ID="HiddetxtCardno" runat="server" />
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
            
           
        </tr>
        <tr>
				<th>电子钱包余额：</th>
            <td><asp:TextBox ID="cMoney" CssClass="labeltext" runat="server"></asp:TextBox>
                            <asp:HiddenField ID="hiddencMoney" runat="server" /></td>
		
        	<th>启用日期：</th>
			<td>
			<asp:TextBox ID="sDate" CssClass="labeltext" runat="server"></asp:TextBox>
                            <asp:HiddenField ID="hiddensDate" runat="server" />
							</td>
            <th>结束日期：</th>
			<td>
			<asp:TextBox ID="eDate" CssClass="labeltext" runat="server"></asp:TextBox>
			<asp:HiddenField ID="hiddeneDate" runat="server" />
			</td>
                                
        </tr>
        <tr>
            <td colspan=6>
                <div class="cust_bton1"><a id="btnMore" onclick="showMoreToggle()">更多<<</a></div>
                <div class="cust_bton1"><asp:LinkButton ID="btnDBread"  runat="server" Text="读数据库" OnClick="btnDBread_Click" /></div>
                <div class="cust_bton1"><asp:LinkButton ID="btnReadCard"   runat="server" Text="读卡" OnClientClick="return ReadCardInfo()" 
			OnClick="btnReadCard_Click" /></div>
            </td>
        </tr>
	</table>
</div>
<div class="cust_tabbox">
    <div id="divCardInfoTitle" style="display: none" >
		<table border="0" cellpadding="0" cellspacing="0" width="100%">
        <tr>
    	<td class="cust_top2_l"><div class="cust_p2"></div></td>
        <td class="cust_top2_m"><span style="line-height:22px; margin-left:5px; color:#FFF;">卡户信息</span></td>
        <td class="cust_top2_r"></td>
        </tr>
        </table>
        <div class="cust_line1"></div>
        <div class="cust_line3"></div>
	</div>
	<div  id="divCardInfo" style="display: none">
		<table border="0" cellpadding="0" cellspacing="0" width="100%" class="cust_form1">
		<tr>
			<th width="10%">库存状态：</th>
			<td width="15%"><asp:Label ID="lblResState" runat="server" CssClass="labeltext"></asp:Label></td>
			<th width="10%">卡序列号：</th>
			<td width="15%"><asp:Label ID="lblAsn" runat="server" CssClass="labeltext"></asp:Label></td>
			<th width="10%">卡片类型：</th>
			<td width="15%" colspan="3"><asp:Label ID="lblCardtype" runat="server" CssClass="labeltext"></asp:Label></td>
            <%--<th width="10%">库内余额：</th>
            <td width="15%"><asp:Label ID="lblCardccMoney" runat="server" CssClass="labeltext"></asp:Label></td>--%>
        </tr>
        <tr>
        	<th width="10%">售卡日期：</th>
            <td><asp:Label ID="lblSellDate" runat="server" CssClass="labeltext"></asp:Label></td>
            <th width="10%">结束日期：</th>
            <td><asp:Label ID="lblEndDate" runat="server" CssClass="labeltext"></asp:Label></td>
            <th width="10%">开通功能：</th>
            <td colspan="3"><aspControls:OpenFunc ID="openFunc" runat="server" /></td>
        </tr>
        </table>
    
    </div>
</div>
    <div class="cust_tabbox">
        <table border="0" cellpadding="0" cellspacing="0" width="100%">
    	<td class="cust_top1_l"><div class="cust_p3"></div></td>
        <td class="cust_top1_m"><span style="line-height:22px; margin-left:5px; color:#333;">账户信息</span></td>
        <td class="cust_top1_r"></td>
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
        <table border="0" cellpadding="0" cellspacing="0" width="100%" class="cust_form">
    	    <tr>
        	    <th width="10%"> <div align="right">用户姓名：</div></th>
                <td width="15%"><asp:Label ID="lblCustName" runat="server" CssClass="labeltext"></asp:Label></td>
                <th width="10%"><div align="right">出生日期：</div></th>
                <td width="15%"><asp:Label ID="lblCustBirthday" runat="server" CssClass="labeltext"></asp:Label></td>
                <th width="10%"><div align="right">证件类型：</div></th>
                <td width="15%"><asp:Label ID="lblPapertype" runat="server" CssClass="labeltext"></asp:Label>
                                <input type="hidden" id="hidPapertype" runat="server" /></td>
                <th width="10%"><div align="right">证件号码：</div></th>
                <td width="15%"><asp:Label ID="lblPaperno" runat="server" CssClass="labeltext"></asp:Label></td>
            </tr>
            <tr>
        	    <th width="10%"><div align="right">用户性别：</div></th>
                <td width="15%"><asp:Label ID="lblCustsex" runat="server" CssClass="labeltext"></asp:Label></td>
                <th width="10%"><div align="right">手机号码：</div></th>
                <td width="15%"><asp:Label ID="lblCustphone" runat="server" CssClass="labeltext"></asp:Label></td>
                <th width="10%"><div align="right">固定电话：</div></th>
                <td width="15%"><asp:Label ID="lblCustTelphone" runat="server" CssClass="labeltext"></asp:Label></td>
                <th width="10%"><div align="right">邮政编码：</div></th>
                <td width="15%"><asp:Label ID="lblCustpost" runat="server" CssClass="labeltext"></asp:Label></td></td>
            </tr>
            <tr>
        	    <th width="10%"><div align="right">电子邮件：</div></th>
                <td colspan="3"><asp:Label ID="lblEmail" runat="server" CssClass="labeltext"></asp:Label></td>
                <th width="10%"><div align="right">联系地址：</div></th>
                <td colspan="3"><asp:Label ID="lblCustaddr" runat="server" CssClass="labeltext"></asp:Label></td></td>
            </tr>
	    </table>
    </div>
    <div class="cust_tabbox">
         <table border="0" cellpadding="0" cellspacing="0" width="100%">
    <tr>
        <td>
        	<table border="0" cellpadding="0" cellspacing="0" width="100%">
            <tr>	
                <td class="cust_top1_l"><div class="cust_p4"></div></td>
        		<td class="cust_top1_m"><span style="line-height:22px; margin-left:5px; color:#333;">费用信息</span></td>
        		<td class="cust_top1_r"></td>
            </tr>
            </table>
            <div class="cust_line1"></div>
        	<div class="cust_line2"></div>
            <table border="0" cellpadding="0" cellspacing="0" width="100%" class="cust_form2">
            	<tr>
                    <th width="50%" class="cust_tab_cost">费用项目</th>
                    <th width="50%" class="cust_tab_cost">费用金额（元）</th>
        		</tr>
                <tr>
                	<th>充值</th>
                    <td><asp:Label ID="SupplyFee" runat="server" Text="0.00"></asp:Label></td>
                </tr>
                <tr>
                	<th>其他费用</th>
                    <td><asp:Label ID="OtherFee" runat="server" Text="0.00"></asp:Label></td>
                </tr>
                <tr>
                	<th>合计应收</th>
                    <td><asp:Label ID="Total" runat="server" Text="0.00"></asp:Label></td>
                </tr>
            </table>
        </td>
        <td width="5px"></td>
        <td>
        	<table border="0" cellpadding="0" cellspacing="0" width="100%">
            <tr>
            	<td class="cust_top1_l"><div class="cust_p5"></div></td>
        		<td class="cust_top1_m"><span style="line-height:22px; margin-left:5px; color:#333;">充值信息</span></td>
        		<td class="cust_top1_r"></td>  
            </tr>
            </table>
            <div class="cust_line1"></div>
        	<div class="cust_line2"></div>
            <div style="display: none">
            <asp:RadioButton ID="Cash" Visible="true" Checked="true" Text="现金" GroupName="SupplyMoney" TextAlign="Right" AutoPostBack="true" runat="server" /> 
            <asp:RadioButton ID="XFCard" Visible="true" Checked="false" Text="充值卡" GroupName="SupplyMoney" TextAlign="Right" AutoPostBack="true" runat="server" /> 
            </div>
            <table border="0" cellpadding="0" cellspacing="0" width="100%" class="cust_form2">
            <tr>	
                <td >
            	<div style="width:400px; margin:0 auto; overflow:hidden;">
            	<div class="cust_tab_tu"></div>
                <div class="cust_tab_txt">请输入充值金额：</div>
                <div class="cust_tab_txt1"><asp:TextBox ID="Money" CssClass="input" MaxLength="7" runat="server"></asp:TextBox></div>
                </div>
                </td>
            </tr>
            </table>
        </td>
     </tr>
     </table>  
    </div>
    <div class="cust_tabbox">
    <div class="cust_bottom_bton"><asp:LinkButton ID="btnChargeAcc"  OnClick="submitConfirm_Click" runat="server" Text="充值" Enabled="false" /></div>
    <div class="cust_bottom_bton"><asp:LinkButton ID="btnPrintPZ" runat="server" Text="打印凭证" Enabled="false"
                                       OnClientClick="printdiv('ptnPingZheng1')" /></div>
    <div class="cust_bottom_txt"><span style="margin-right:5px;"><asp:CheckBox ID="chkPingzheng" runat="server" Checked="true"/></span>自动打印凭证</div>
    <asp:LinkButton runat="server" ID="btnConfirm" OnClick="btnCharge_Click" />
</div>
                
                   
            </ContentTemplate>
        </asp:UpdatePanel>
    </form>
</body>
</html>

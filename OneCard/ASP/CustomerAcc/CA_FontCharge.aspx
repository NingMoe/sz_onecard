﻿<%@ Page Language="C#" AutoEventWireup="true" CodeFile="CA_FontCharge.aspx.cs" Inherits="ASP_CustomerAcc_CA_FontCharge" EnableEventValidation="false" %>

<%@ Register Src="../../CardReader.ascx" TagName="CardReader" TagPrefix="cr" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>圈存</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />

    <script type="text/javascript" src="../../js/print.js"></script>

    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <link  href="../../css/Cust_AS.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="../../js/jquery-1.5.min.js"></script>

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
    
    function Confirm()
    {
        if(confirm('确认提交?'))
        {
            return  checkMaxBalanceText('txtSupplyFee');
        }
        else
        {
            return false;
        }
    }
    
    </script>

    <script language="javascript">
  <!--
  function OpenPort()
  {     
        if(!MSComm1.PortOpen)
        {
            var  WshShell;
            var  keyValue;
        
            try{
                WshShell  =  new  ActiveXObject("WScript.Shell");
            }catch(ex)
            {
                alert("请调整IE的ActiveX安全级别");
                return false;
            }
            
            try
            {
                  
                 keyValue  =  WshShell.RegRead("HKEY_LOCAL_MACHINE\\SOFTWARE\\OneCard\\ComPort");

                if(keyValue == '' || keyValue.charCodeAt(0) < 49 || keyValue.charCodeAt(0) > 57)
                {
                    alert("请在【系统管理->本地参数管理】页面里，配置ComPort端口！"); 
                    return false;
                }
                
            }
            catch(ex)
            {
                alert("请在【系统管理->本地参数管理】页面里，配置ComPort端口！"); 
                return false;
            }
        
        
            try{
                MSComm1.CommPort = keyValue;
                MSComm1.PortOpen = true;
            }catch(ex)
            {
                alert("小键盘端口无法打开，请在【系统管理->本地参数管理】页面里，配置ComPort端口！");
                return false;
            }
            
        }
  }
  
  function ClosePort()
  {     
        if(MSComm1.PortOpen)
        {
            MSComm1.PortOpen = false;
        }
  }
  
  -->
    </script>

    <script id="clientEventHandlersJS" language="javascript">   
  <!--
  function MSComm1_OnComm(){
        var fldWeight = $get("PassWD");
        var strInput;
        strInput = MSComm1.Input;
        if(strInput.charCodeAt(0) == 13)
        {
            ClosePort();
            alert("密码输入完毕");
        }else if(strInput.charCodeAt(0) == 8)
        {
            fldWeight.value = "";
        }else{
            fldWeight.value = fldWeight.value + strInput; 
        }
        fldWeight.focus();
        return false;
  }
  -->
    </script>

    <script language="javascript" for="MSComm1" event="OnComm">
  MSComm1_OnComm();
    </script>

</head>
<body>
    <cr:CardReader ID="cardReader" runat="server" />
    <form id="form1" runat="server">
        <table border="0" cellpadding="0" cellspacing="0" width="100%">
            <tr>
                <td class="cust_left"></td>
                <td class="cust_mid">专有账户->钱包圈存</td>
                <td class="cust_right"></td>
             </tr>
        </table>
        <object classid="clsid:648A5600-2C6E-101B-82B6-000000000014" id="MSComm1" codebase="MSCOMM32.OCX"
            type="application/x-oleobject" width='0' height='0'>
            <param name="InputLen" value="0">
            <param name="Rthreshold" value="1">
            <param name="Settings" value="1200,N,8,1">
        </object>
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
                                    <div align="right">
                                        用户卡号：</div>
                                </th>
                                <td style="width: 17%">
                                    <asp:TextBox ID="txtCardno" CssClass="labeltext" MaxLength="16" runat="server"></asp:TextBox>
                                    <asp:HiddenField ID="hiddenAsn" runat="server" />
                                    <asp:HiddenField ID="hiddentradeno" runat="server" />
                                    <asp:HiddenField runat="server" ID="hidSupplyMoney" />
                                    <asp:LinkButton runat="server" ID="btnConfirm" OnClick="btnConfirm_Click" />
                                    <asp:HiddenField ID="hidWarning" runat="server" />
                                    <asp:HiddenField runat="server" ID="hidCardReaderToken" />
                                </td>
                                <th style="width: 10%">
                                    <div align="right">
                                        卡序列号：</div>
                                </th>
                                <td style="width: 15%">
                                    <asp:TextBox ID="LabAsn" CssClass="labeltext" runat="server"></asp:TextBox>
                                </td>
                                <th style="width: 10%">
                                    <div align="right">
                                        卡片类型：</div>
                                </th>
                                <td style="width: 10%">
                                    <asp:TextBox ID="LabCardtype" CssClass="labeltext"  runat="server"></asp:TextBox>
                                    <asp:HiddenField ID="hiddenLabCardtype" runat="server" />
                                </td>
                                <th>
                                    <div align="right">
                                        电子钱包余额：</div>
                                </th>
                                <td>
                                    <asp:TextBox ID="cMoney" CssClass="labeltext"  runat="server"></asp:TextBox>
                                    <asp:HiddenField ID="hiddencMoney" runat="server" />
                                </td>
                            </tr>
                            <tr>
                                <th>
                                    <div align="right">
                                        启用日期：</div>
                                </th>
                                <td>
                                    <asp:TextBox ID="sDate" CssClass="labeltext"  runat="server"></asp:TextBox>
                                    <asp:HiddenField ID="hiddensDate" runat="server" />
                                </td>
                                <th>
                                    <div align="right">
                                        结束日期：</div>
                                </th>
                                <td colspan=5>
                                    <asp:TextBox ID="eDate" CssClass="labeltext"  runat="server"></asp:TextBox>
                                    <asp:HiddenField ID="hiddeneDate" runat="server" />
                                </td>
                            </tr>
                            <tr>
                                <td colspan=8>
                                    <div class="cust_bton1"><asp:LinkButton ID="btnReadCard" runat="server" Text="读卡" OnClientClick="return ReadCardInfo()"
                                        OnClick="btnReadCard_Click" /></div>
                                    <div class="cust_bton1"><a id="btnMore" onclick="showMoreToggle()">更多<<</a></div>
                                </td>
                            </tr>
                        </table>
                </div>
                <div class="cust_tabbox">
                    <div id="divCardInfoTitle" style="display: none">
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
	                <div id="divCardInfo" style="display: none">
	                    <table width="100%" border="0" cellpadding="0" cellspacing="0" class="cust_form">
                            <tr>
                                <th style="width: 10%">
                                    <div align="right">
                                        库存状态：</div>
                                </th>
                                <td style="width: 17%">
                                    <asp:Label ID="lblResState" runat="server" CssClass="labeltext"></asp:Label>
                                </td>
                                <th style="width: 10%">
                                    <div align="right">
                                        卡序列号：</div>
                                </th>
                                <td style="width: 15%">
                                    <asp:Label ID="lblAsn" runat="server" CssClass="labeltext"></asp:Label>
                                </td>
                                <th style="width: 10%">
                                    <div align="right">
                                        卡片类型：</div>
                                </th>
                                <td style="width: 10%">
                                    <asp:Label ID="lblCardtype" runat="server" CssClass="labeltext"></asp:Label>
                                </td>
                                <%--<th style="width: 10%">
                                    <div align="right">
                                        库内余额：</div>
                                </th>
                                <td style="width: 18%">
                                    <asp:Label ID="lblCardccMoney" runat="server" CssClass="labeltext"></asp:Label>
                                </td>--%>
                            </tr>
                            <tr>
                                <th>
                                    <div align="right">
                                        售卡日期：</div>
                                </th>
                                <td>
                                    <asp:Label ID="lblSellDate" runat="server" CssClass="labeltext"></asp:Label>
                                </td>
                                <th>
                                    <div align="right">
                                        结束日期：</div>
                                </th>
                                <td>
                                    <asp:Label ID="lblEndDate" runat="server" CssClass="labeltext"></asp:Label>
                                </td>
                                <th>
                                    <div align="right">
                                        开通功能：</div>
                                </th>
                                <td>
                                    <aspControls:OpenFunc ID="openFunc" runat="server" />
                                </td>
                          
                            </tr>
                            <tr>
                                
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
                                   <div>
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
                                    <div align="right">
                                        用户姓名：</div>
                                </th>
                                <td style="width: 17%">
                                    <asp:Label ID="lblCustName" runat="server" CssClass="labeltext"></asp:Label>
                                </td>
                                <th style="width: 10%">
                                    <div align="right">
                                        出生日期：</div>
                                </th>
                                <td style="width: 15%">
                                    <asp:Label ID="lblCustBirthday" runat="server" CssClass="labeltext"></asp:Label>
                                </td>
                                <th style="width: 10%">
                                    <div align="right">
                                        证件类型：</div>
                                </th>
                                <td style="width: 10%">
                                    <asp:Label ID="lblPapertype" runat="server" CssClass="labeltext"></asp:Label>
                                    <input type="hidden" id="hidPapertype" runat="server" />
                                </td>
                                <th style="width: 10%">
                                    <div align="right">
                                        证件号码：</div>
                                </th>
                                <td style="width: 18%">
                                    <asp:Label ID="lblPaperno" runat="server" CssClass="labeltext"></asp:Label>
                                </td>
                            </tr>
                            <tr>
                                <th>
                                    <div align="right">
                                        用户性别：</div>
                                </th>
                                <td>
                                    <asp:Label ID="lblCustsex" runat="server" CssClass="labeltext"></asp:Label></td>
                                <th>
                                    <div align="right">
                                        手机号码：</div>
                                </th>
                                <td>
                                    <asp:Label ID="lblCustphone" runat="server" CssClass="labeltext"></asp:Label></td>
                                <th>
                                    <div align="right">
                                        固定电话：
                                    </div>
                                </th>
                                <td>
                                    <asp:Label ID="lblCustTelphone" runat="server" CssClass="labeltext"></asp:Label>
                                </td>
                                <th>
                                    <div align="right">
                                        邮政编码：</div>
                                </th>
                                <td>
                                    <asp:Label ID="lblCustpost" runat="server" CssClass="labeltext"></asp:Label></td>
                            </tr>
                            <tr>
                                <th>
                                    <div align="right">
                                        电子邮件：</div>
                                </th>
                                <td>
                                    <asp:Label ID="lblEmail" runat="server" CssClass="labeltext"></asp:Label>
                                </td>
                                <th valign="top">
                                    <div align="right">
                                        联系地址：
                                    </div>
                                </th>
                                <td colspan="5">
                                    <asp:Label ID="lblCustaddr" runat="server" CssClass="labeltext"></asp:Label></td>
                            </tr>
                        </table>
                </div>
                <div class="cust_tabbox">
                    <table border="0" cellpadding="0" cellspacing="0" width="100%">
                        <tr>
    	                <td class="cust_top1_l"><div class="cust_p4"></div></td>
                        <td class="cust_top1_m"><span style="line-height:22px; margin-left:5px; color:#333;">圈存金额</span></td>
                        <td class="cust_top1_r"></td>
                        </tr>
                     </table>
                     <div class="cust_line1"></div>
                     <div class="cust_line2"></div>
                     <table width="100%" border="0" cellpadding="0" cellspacing="0" class="cust_form">
                            <tr>
                                <th width="10%">
                                    <div align="right">
                                        圈存金额：
                                    </div>
                                </th>
                                <td width="25%">
                                    <asp:TextBox ID="txtSupplyFee" CssClass="input" MaxLength="7" runat="server"></asp:TextBox>
                                    <asp:HiddenField ID="hidIsJiMing" runat=server Value="1" />
                                </td>
                                <td width="40%">
                                </td>
                                <td width="10%">
                                </td>
                            </tr>
                        </table>
                </div>
                <div class="cust_tabbox">
                    <table border="0" cellpadding="0" cellspacing="0" width="100%">
                    <tr>
    	            <td class="cust_top1_l"><div class="cust_p7"></div></td>
                    <td class="cust_top1_m"><span style="line-height:22px; margin-left:5px; color:#333;">输入密码</span></td>
                    <td class="cust_top1_r"></td>
                    </tr>
                    </table>
                    <div class="cust_line1"></div>
                    <div class="cust_line2"></div>
                    <table width="100%" border="0" cellpadding="0" cellspacing="0" class="cust_form">
                            <tr>
                                <th width="10%">密码：</th>
                                <td width="90%">
                                    <asp:TextBox ID="PassWD" CssClass="inputmid" style="float:left;" TextMode="password" MaxLength="6" runat="server"></asp:TextBox>
                                    <div class="cust_bton2"><asp:LinkButton ID="btnPassInput" runat="server" Text="小键盘输入密码" Width="100px" OnClientClick="return OpenPort()"/></div>
                                </td>
                            </tr>
                        </table>
               </div>
                <div class="cust_tabbox">
                    <div class="cust_bottom_bton"><asp:LinkButton ID="btnCharge"  OnClick="btnCharge_Click" runat="server"
                                    Text="圈存" Enabled="false" OnClientClick="return Confirm();" /></div>
                    <div class="cust_bottom_bton"><asp:LinkButton ID="btnPrintPZ" runat="server" Text="打印凭证"  Enabled="false"
                                    OnClientClick="printdiv('ptnPingZheng1')" /></div>
                    <div class="cust_bottom_txt"><span style="margin-right:5px;"><asp:CheckBox ID="chkPingzheng" runat="server" Checked="true" Text="自动打印凭证" /></span></div>
                </div>
                
            </ContentTemplate>
        </asp:UpdatePanel>
    </form>
</body>
</html>
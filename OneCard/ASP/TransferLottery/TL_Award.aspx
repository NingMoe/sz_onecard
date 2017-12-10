<%@ Page Language="C#" AutoEventWireup="true" CodeFile="TL_Award.aspx.cs" Inherits="ASP_TransferLottery_TL_Award"
    EnableEventValidation="false" %>

<%@ Register Src="../../CardReader.ascx" TagName="CardReader" TagPrefix="cr" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />

    <script type="text/javascript" src="../../js/myext.js"></script>

    <script type="text/javascript" src="../../js/print.js"></script>

    <script type="text/javascript">
        function mover() {
            //去除相邻节点样式
            var object_nav = arguments[0].parentElement.parentElement;
            for (var i = 0; i < object_nav.children.length; ++i) {
                var object_cld = object_nav.children[i].children[0];
                object_cld.children[0].style.color = "#000";
                object_cld.className = null;

            }

            //当前节点添加样式
            arguments[0].className = "on";
            arguments[0].children[0].style.color = "#fff";
            arguments[0].children[0].style.cursor = "pointer";
        }

        function mout() {
            var cardname = 'tagAward' + $get('hidAwardType').value.toString();
            var object = document.getElementById(cardname);
            mover(object);
        }

        function SelectCharge() {
            $get('trChargeCard').style.display = "none";
            $get('trCharge').style.display = "block";
            $get('trChargeSex').style.display = "block";
            $get('hidAwardType').value = '0';
            return false;
        }

        function SelectChargeCard() {
            $get('trChargeCard').style.display = "block";
            $get('trCharge').style.display = "none";
            $get('trChargeSex').style.display = "none";
            $get('hidAwardType').value = '1';
            return false;
        }


        function choosePintPingZheng() {
            var chkPingzheng = document.getElementById('chkPingzheng');
            var chkPingzhengRemin = document.getElementById('chkPingzhengRemin');
            if (chkPingzheng.checked == false && chkPingzhengRemin.checked == false) {
                MyExtAlert("警告", "请选择打印方式后再打印！");
            }
            if (chkPingzheng.checked == true) {
                printdiv('ptnPingZheng1');
            }
            if (chkPingzhengRemin.checked == true) {
                printdiv('ptnPingZheng2');
            }
        }

        function chkPingZheng() {
            var chkPingzheng = document.getElementById('chkPingzheng');
            var chkPingzhengRemin = document.getElementById('chkPingzhengRemin');
            if (chkPingzheng.checked == true) {
                chkPingzhengRemin.checked = false;
            }

        }
        function chkPingZhengRemin() {
            var chkPingzheng = document.getElementById('chkPingzheng');
            var chkPingzhengRemin = document.getElementById('chkPingzhengRemin');
            if (chkPingzhengRemin.checked == true) {
                chkPingzheng.checked = false;
            }
        }
    </script>

    <title>领奖</title>
</head>
<body>
    <cr:CardReader ID="cardReader" runat="server" />
    <form id="form1" runat="server">
    <div class="tb">
        换乘奖励->领奖
    </div>
    <ajaxtoolkit:toolkitscriptmanager runat="Server" enablescriptglobalization="true"
        enablescriptlocalization="true" id="ToolkitScriptManager1" />

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

    <asp:UpdatePanel ID="UpdatePanel1" UpdateMode="Conditional" runat="server">
        <contenttemplate>
            <aspControls:PrintTLPingZheng ID="ptnPingZheng" runat="server" PrintArea="ptnPingZheng1" />
            <aspControls:PrintTLRMPingZheng ID="PrintRMPingZheng" runat="server" PrintArea="ptnPingZheng2" />
            
                <asp:BulletedList ID="bulMsgShow" runat="server" />
                <script runat="server">public override void ErrorMsgShow() { ErrorMsgHelper(bulMsgShow); }</script>
                <div class="con">
                    <div class="card">
                        中奖查询
                    </div>
                    <div class="kuang5" style="text-align: left">
                        <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                            <tr>
                                <td width="15%">
                                    <div align="right">
                                        卡号:
                                    </div>
                                </td>
                                <td width="15%">
                                    <asp:TextBox runat="server" ID="txtCardno" CssClass="input" MaxLength="16"></asp:TextBox>
                                </td>
                                <td width="15%"></td>
                                <td align="right">
                                    <asp:Button ID="btnQuery" CssClass="button1" runat="server" Text="读卡" OnClientClick="return ReadCardInfo()"
                                        OnClick="btnReadCard_Click" />
                                    <asp:Button ID="btnQueryDB" CssClass="button1" runat="server" Text="查询中奖" OnClick="btnReadCard_Click" />
                                    <asp:HiddenField ID="hiddencMoney" runat="server" />
                                    <asp:HiddenField ID="hiddentradeno" runat="server" />
                                    <asp:HiddenField ID="hidSupplyFee" runat="server" />
                                    <asp:HiddenField ID="hidSupplyOtherFee" runat="server" />
                                    <asp:HiddenField ID="hidSupplyMoney" runat="server" />
                                    <asp:HiddenField ID="hideCardno" runat="server" />
                                    <asp:HiddenField runat="server" ID="hidCardReaderToken" />
                                    <asp:HiddenField ID="hideAwardsName" runat="server" />
                                    <asp:HiddenField ID="hidTax" runat="server" />
                                </td>
                            </tr>
                        </table>
                    </div>
                    <div class="jieguo">
                        查询结果
                    </div>
                    <div class="kuang5">
                        <div id="divResult" style="height: 180px; overflow: auto; display: block">
                            <asp:GridView ID="gvResult" runat="server" Width="98%" CssClass="tab1"
                                HeaderStyle-CssClass="tabbt" FooterStyle-CssClass="tabcon" AlternatingRowStyle-CssClass="tabjg"
                                SelectedRowStyle-CssClass="tabsel" AutoGenerateColumns="false" 
                                OnSelectedIndexChanged="gvResult_SelectedIndexChanged"  OnRowCreated="gvResult_RowCreated">
                                <Columns> 
                                <asp:BoundField DataField="CARDNO" HeaderText="卡号" />
                                <asp:BoundField DataField="CARDTYPE" HeaderText="卡类型" />
                                <asp:BoundField DataField="LOTTERYPERIOD" HeaderText="奖期" />
                                <asp:BoundField DataField="AWARDSNAME" HeaderText="奖项" />
                                <asp:BoundField DataField="BONUS" HeaderText="奖金" />
                                <asp:BoundField DataField="CUSTNAME" HeaderText="姓名" />
                                <asp:BoundField DataField="CARDSTATE" HeaderText="状态" /> 
                                <asp:BoundField DataField="TAX" HeaderText="扣税" />
                            </Columns>
                                <EmptyDataTemplate>
                                    <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                        <tr class="tabbt">
                                            <td>卡号 
                                            </td>
                                            <td>卡类型 
                                            </td>
                                            <td>奖期
                                            </td>
                                            <td>奖项 
                                            </td>
                                            <td>奖金
                                            </td>
                                            <td>姓名
                                            </td>
                                            <td>状态
                                            </td>
                                            <td>扣税
                                            </td>
                                        </tr>
                                    </table>
                                </EmptyDataTemplate>
                            </asp:GridView>
                        </div>
                    </div>
                    <div style="height: 22px">
                        <table>
                            <tr>
                                <td width="10%"></td>
                                <td align="center">
                                    <ul class="nav_list">
                                        <li>
                                            <asp:LinkButton ID="tagAward0" Target="_top" CssClass="on" runat="server" onmouseover="mover(this);"
                                                onmouseout="mout();" OnClientClick="return SelectCharge()"><span class="signA">领奖充值</span></asp:LinkButton></li>
                                        <li id="liChargeCard" runat="server" visible="true">
                                            <asp:LinkButton ID="tagAward1" Target="_top" runat="server" onmouseover="mover(this);"
                                                onmouseout="mout();" OnClientClick="return SelectChargeCard()"><span class="signB">领充值卡</span></asp:LinkButton></li>
                                    </ul>
                                </td>
                            </tr>
                        </table>
                        <asp:HiddenField ID="hidAwardType" runat="server" Value="0" />
                        <asp:HiddenField ID="hidBonus" runat="server" Value="0" />
                        <asp:HiddenField ID="hidCardTypeCode" runat="server" />
                        <asp:HiddenField ID="hidLotteryPeriod" runat="server" />
                    </div>
                    <div class="kuang5">
                        <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                            <tr id="trCharge">
                                <td width="12%">
                                    <div align="right">
                                        电子钱包卡号:
                                    </div>
                                </td>
                                <td colspan="5" >
                                    <asp:TextBox runat="server" ID="txtCardNoC" CssClass="input"></asp:TextBox>
                                   
                                </td>
                                <td align="right" colspan="2" >
                                    <asp:Button ID="btnReadCardC" Text="读卡" CssClass="button1" runat="server"  OnClientClick="return ReadCardInfo('txtCardNoC')" OnClick="btnReadCardC_Click"/>
                                    <asp:Button ID="btnReadDBC" Text="读数据库" CssClass="button1" runat="server"  OnClick="btnReadCardC_Click"/>
                                </td>

                            </tr>
                            <tr>
                                <td width="12%">
                                      <div align="right">
                                        姓名:
                                    </div>
                                </td>
                                <td width="15%">
                                     <asp:TextBox ID="txtCusname" CssClass="input" runat="server"></asp:TextBox><span class="red">*</span>
                                </td>
                                <td width="10%">
                                    <div align="right">证件类型:</div>
                                </td>
                                <td width="12%">
                                    <asp:DropDownList ID="selPapertype" CssClass="input" runat="server">
                                    </asp:DropDownList><span class="red">*</span>
                                </td>
                                <td width="10%">
                                     <div align="right">证件号码:</div>
                                </td>
                                <td width="12%">
                                    <asp:TextBox ID="txtCustpaperno" CssClass="input" runat="server"></asp:TextBox><span class="red">*</span>
                                </td>
                                <td width="10%">
                                   <div align="right">手机号码:</div>
                                </td>
                                <td width="15%">
                                   <asp:TextBox ID="txtCustphone" CssClass="input" runat="server"></asp:TextBox><span class="red">*</span>
                                </td>
                            </tr>
                            <tr id="trChargeSex">
                                <td width="12%">
                                    <div align="right">
                                        性别:
                                    </div>
                                </td>
                                <td width="12%" colspan="6">
                                     <asp:DropDownList ID="selCustsex" CssClass="input" runat="server">
                                    </asp:DropDownList>
                                </td>
                                <td style="padding-left:12px"><asp:Button ID="txtReadPaper" Text="读二代证" CssClass="button1" runat="server" 
    OnClientClick="readIDCardEx('txtCusname', 'selCustsex', 'txtCustbirth', 'selPapertype', 'txtCustpaperno', 'txtCustaddr')" /></td>
                            </tr>
                            <tr id="trChargeCard" style="display:none">
                                <td width="12%">
                                    <div align="right">
                                        充值卡卡号:
                                    </div>
                                </td>
                                <td colspan="6">
                                    <asp:TextBox ID="txtChargeCard" CssClass="inputlong" runat="server"></asp:TextBox>
                                    多张充值卡之间用英文逗号分隔
                                </td> 
                                <td style="padding-left:12px"><asp:Button ID="txtReadPaper2" Text="读二代证" CssClass="button1" runat="server" 
    OnClientClick="readIDCardEx('txtCusname', 'selCustsex', 'txtCustbirth', 'selPapertype', 'txtCustpaperno', 'txtCustaddr')" /></td>
                            </tr>
                            <tr>
  <td><div align="right">照片文件导入:</div></td>
    
    <td colspan="6"  id="tdFileUpload" runat="server">
      <asp:FileUpload ID="FileUpload1" runat="server" CssClass="inputlong" />
     </td>
    <td>
    </td>
  </tr>
                        </table>
                        <asp:HiddenField ID="txtCustbirth" runat="server" />
                        <asp:HiddenField ID="txtCustaddr" runat="server" />
                    </div> 
                </div>
                <div class="footall">
                </div>
                <div class="btns">
                    <table width="200" border="0" align="right" cellpadding="0" cellspacing="0">
                        <tr>
                            <td>
                                <asp:Button ID="btnPrintPZ" runat="server" Text="打印凭证" 
        CssClass="button1" Enabled="false" OnClientClick="return choosePintPingZheng();" />
                            </td>
                            <td>
                                <asp:Button ID="btnAward" Text="确认领奖" CssClass="button1" runat="server" Enabled="false" OnClick="btnAward_Click"/>
                            </td>
                        </tr>
                    </table>
                    <asp:CheckBox ID="chkPingzheng" runat="server"  Text="针式打印凭证" OnClick="return chkPingZheng();"/>
                    <asp:CheckBox ID="chkPingzhengRemin" runat="server"  Text="热敏打印凭证"  OnClick="return chkPingZhengRemin();"/>
                </div>
                 
                
            
            </contenttemplate>
        <triggers>
        <asp:PostBackTrigger ControlID="btnAward" />
        </triggers>
    </asp:UpdatePanel>
    </form>
</body>
</html>

<%@ Page Language="C#" AutoEventWireup="true" CodeFile="UC_SaletypeChange.aspx.cs"
    Inherits="ASP_UserCard_UC_SaletypeChange" %>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>卡片销售方式修改</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />

    <script type="text/javascript" src="../../js/myext.js"></script>

    <script type="text/javascript" src="../../js/mootools.js"></script>

    <script type="text/javascript">
        function Change()
        {
            var sFCard = $('txtFromCardNo').value;
            var sECard = $('txtToCardNo').value;
            var lCardSum = 0;

            if(sFCard.test("^\\s*\\d{16}\\s*$") && sECard.test("\\s*^\\d{16}\\s*$"))
            {
                var lFCard = sFCard.toInt();
                var lECard = sECard.toInt();
                if(lECard - lFCard >= 0)
                    lCardSum = lECard - lFCard + 1;
            }
            

            $('txtCardSum').value = lCardSum;
        }

        function submitConfirm() {
            Change();
            var saletype = "";
            var obj = document.getElementById("selSaleType");
            if (obj.value != "") {
                for (i = 0; i < obj.length; i++) {
                    if (obj.options[i].selected) {
                        saletype = obj.options[i].text + "";
                        break;
                    }
                }
            }
            if ($get('txtFromCardNo').value != ""
                && $get('txtToCardNo').value != "") {
                MyExtConfirm('确认',
		        '起始卡号为： ' + $get('txtFromCardNo').value + '<br>' +
		        '最末卡号为： ' + $get('txtToCardNo').value + '<br>' +
		        '卡片数量为：' + $get('txtCardSum').value + '<br>' +
		        '修改售卡方式为：' + saletype + '<br>' +
		        '是否确认？'
		        , submitConfirmCallback);
                return false;
            }
            return true;
        }
        
        function submitConfirmCallback(btn) {
            if (btn == 'yes') {
                $get('btnConfirm').click();
            }
        }
    </script>

</head>
<body>
    <form id="form1" runat="server">
    <div class="tb">
        卡片管理->卡片销售方式修改（原）
    </div>
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

    <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
            <asp:BulletedList ID="bulMsgShow" runat="server" />

            <script runat="server">public override void ErrorMsgShow() { ErrorMsgHelper(bulMsgShow); }</script>

            <div class="con">
                <div class="card">
                    卡片销售方式修改</div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td>
                                <div align="right">
                                    起讫卡号:</div>
                            </td>
                            <td colspan="3">
                                <asp:TextBox ID="txtFromCardNo" CssClass="inputmid" runat="server" MaxLength="16"></asp:TextBox>
                                -
                                <asp:TextBox ID="txtToCardNo" CssClass="inputmid" runat="server" MaxLength="16"></asp:TextBox>
                                <span class="red">*</span>
                            </td>
                            <td>
                                <div align="right">
                                    数量:</div>
                            </td>
                            <td>
                                &nbsp;<asp:TextBox ID="txtCardSum" CssClass="labeltext" Width="100" runat="server"
                                    Text="0"></asp:TextBox>
                            </td>
                              <td style="width:200px">
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    修改售卡方式为:</div>
                            </td>
                            <td>
                                <asp:DropDownList ID="selSaleType" CssClass="input" runat="server">
                                </asp:DropDownList>
                            </td>
                            <td>
                                <div align="right">
                                </div>
                            </td>
                            <td>
                            </td>
                            <td>
                            </td>
                        </tr>
                    </table>
                </div>
            </div>
            <div class="btns">
                <table width="100" border="0" align="right" cellpadding="0" cellspacing="0">
                    <tr>
                        <td>
                            <asp:LinkButton runat="server" ID="btnConfirm" OnClick="btnSubmit_Click" />
                            <asp:Button ID="btnSubmit" CssClass="button1" runat="server" Text="提交"  OnClick="btnSubmit_Click" OnClientClick="return submitConfirm()"  />
                        </td>
                    </tr>
                </table>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
    </form>
</body>
</html>

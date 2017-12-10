<%@ Page Language="C#" AutoEventWireup="true" CodeFile="CG_CashGiftSaleBatch.aspx.cs"
    Inherits="ASP_CashGift_CG_CashGiftSaleBatch" %>

<%@ Register Src="../../CardReader.ascx" TagName="CardReader" TagPrefix="cr" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>利金卡批量售卡</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />

    <script type="text/javascript">
        function StartOperation() {
            try {
                var ctrl = document.getElementById('BatchCardOpObject');
                var ret = ctrl.CheckControl();
                if (ret != "0") {
                    alert("未检测到控件,请关闭浏览器并尝试重新安装控件");
                    return;
                }

                var needCount = parseInt(document.getElementById('txtSalCount').value);

                var params = {

                    // 批次号
                    BatchId: document.getElementById('hidBatchId').value,

                    //操作类型 :1为利金卡售卡
                    OperationType: 1,

                    // 写卡数量
                    Count: needCount,

                    // 充值金额
                    ChargeAmount: parseInt(document.getElementById('txtSaleMoney').value),

                    // 写卡前提交URL
                    PrewriteSubmitUrl: document.getElementById('hidPrewriteUrl').value,

                    // 写卡后提交URL
                    PostwriteSubmitUrl: document.getElementById('hidPostwriteUrl').value,

                    // 启用日期
                    StartDate: document.getElementById('hidSysDate').value,

                    // 完成回调
                    OnFinish: function(batchId, status, successCount, failCount, successNums, failNums, message) {

                        var msg = '';
                        msg += '批量操作完成，';
                        msg += ' 批次号: ' + batchId + '，';
                        msg += ' 成功数量: ' + successCount + '，';
                        msg += ' 失败数量: ' + failCount;
                        //alert(msg);

                        document.getElementById('hidMsg').value = msg;

                        document.getElementById('hidSuccessCount').value = successCount;
                        document.getElementById('hidFailCount').value = failCount;
                        document.getElementById('hidSuccessCardnos').value = successNums;
                        document.getElementById('hidFailCardnos').value = failNums;
                        document.getElementById('hidFinishmessage').value = message;

                        document.getElementById('btnConfirm').click();
                    },

                    // 过程回调
                    OnProgress: function(batchId, currentIndex, successCount, failCount) {
                        document.getElementById('out').innerHTML =
                              '已处理数量: ' + currentIndex + '<br/>'
                            + '成功数量: ' + successCount + '<br/>'
                            + '需要数量: ' + needCount + '<br/>'
                            + '失败数量: ' + failCount;
                    }
                };
                var ctrl = document.getElementById('BatchCardOpObject');
                var ret = ctrl.StartOperation(params);
                if (ret != '0') {

                    alert('失败: ' + ret + '，请刷新页面后重试');
                    return;
                }
            }
            catch (e) {
                alert(e);
                return;
            }
        }
    </script>

    <script type="text/javascript">

        function checkOpcardno() {
            var operCardNo = cardReader.testingMode ? "2150010200010001" : readOperCardNo();
            if (operCardNo == null) {
                return false;
            }
            assignValue('hiddenCheck', operCardNo);
            return true;
        }
    </script>

</head>
<body>
    <cr:CardReader ID="cardReader" runat="server" />
    <form id="form1" runat="server">
    <div class="tb">
        利金卡->批量售卡</div>
    <object id="BatchCardOpObject" classid="CLSID:5F194517-98DB-4B1E-B301-5825E70978BF"
        height="0" codebase="../../Tools/BatchCardOpControl.cab">
    </object>
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

    <asp:UpdatePanel ID="UpdatePanel1" runat="server" RenderMode="Inline">
        <ContentTemplate>
            <aspControls:PrintShouJu ID="ptnShouJu" runat="server" PrintArea="ptnShouJu1" />
            <asp:BulletedList ID="bulMsgShow" runat="server">
            </asp:BulletedList>

            <script runat="server">public override void ErrorMsgShow() { ErrorMsgHelper(bulMsgShow); }</script>

            <asp:HiddenField runat="server" ID="hidWarning" />
            <asp:HiddenField runat="server" ID="hidBatchId" />
            <asp:HiddenField runat="server" ID="hidMsg" />
            <asp:HiddenField runat="server" ID="hidSuccessCount" />
            <asp:HiddenField runat="server" ID="hidSuccessCardnos" />
            <asp:HiddenField runat="server" ID="hidFailCount" />
            <asp:HiddenField runat="server" ID="hidFailCardnos" />
            <asp:HiddenField runat="server" ID="hidFinishmessage" />
            <asp:HiddenField runat="server" ID="hidPrewriteUrl" />
            <asp:HiddenField runat="server" ID="hidPostwriteUrl" />
            <asp:HiddenField runat="server" ID="hidSysDate" />
            <asp:HiddenField ID="hiddenCheck" runat="server" />
            <asp:LinkButton runat="server" ID="btnConfirm" OnClick="btnConfirm_Click" />
            <div class="con">
                <div class="card">
                    交易信息</div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td align="right">
                                售卡数量:
                            </td>
                            <td>
                                <asp:TextBox ID="txtSalCount" CssClass="input" runat="server" MaxLength="3" Width="50px" /><span
                                    class="red">*</span>
                            </td>
                            <td align="right">
                                每张售卡金额:
                            </td>
                            <td>
                                <asp:TextBox ID="txtSaleMoney" CssClass="input" runat="server" MaxLength="6" Width="50px" />元<span
                                    class="red">*</span>
                            </td>
                            <td align="center">
                                <asp:Button ID="btnSaleCard" CssClass="button1" runat="server" Text="开始售卡" OnClick="btnSaleCard_Click"
                                    OnClientClick="return checkOpcardno();" />
                            </td>
                        </tr>
                    </table>
                </div>
                <div class="kuang5" style="height: 80px">
                    <p id="out" class="text20">
                    </p>
                </div>
            </div>
            <div class="footall">
            </div>
            <div class="con" id="divErrorList" runat="server" visible="false">
                <div class="jieguo">
                    失败卡片
                </div>
                <div class="kuang5">
                    <div id="gdtb" style="height: 200px">
                        <asp:GridView ID="gvResult" runat="server" Width="98%" CssClass="tab1" HeaderStyle-CssClass="tabbt"
                            AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel" PagerSettings-Mode="NumericFirstLast"
                            PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top" AutoGenerateColumns="False">
                            <Columns>
                                <asp:BoundField HeaderText="#" ItemStyle-Width="5%" DataField="seq" />
                                <asp:BoundField HeaderText="批次号" DataField="batchid" />
                                <asp:BoundField HeaderText="卡号" DataField="cardno" />
                                <asp:BoundField HeaderText="操作时间" DataField="operatetime" />
                                <asp:BoundField HeaderText="错误原因" DataField="msg" />
                            </Columns>
                        </asp:GridView>
                    </div>
                </div>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
    </form>
    <iframe width="0" height="0" id="emptyFrame" src="../../Empty.aspx"></iframe>

    <script type="text/javascript">
        function keepSession() {
            document.all["emptyFrame"].src = "../../Empty.aspx?rad=" + Math.random();

            window.setTimeout("keepSession()", 1000000); //每隔1000秒调用一下

        }
        keepSession();
    </script>

</body>
</html>

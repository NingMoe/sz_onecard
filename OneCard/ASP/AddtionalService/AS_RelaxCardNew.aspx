<%@ Page Language="C#" AutoEventWireup="true" CodeFile="AS_RelaxCardNew.aspx.cs"
    Inherits="ASP_AddtionalService_AS_RelaxCardNew" ValidateRequest="false" %>

<%@ Register Src="../../CardReader.ascx" TagName="CardReader" TagPrefix="cr" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>休闲开通</title>
    <script type="text/javascript" src="../../js/jquery.min.js"></script>
    <script type="text/javascript" src="../../js/webcam/jquery.webcam.min.js"></script>
    <script type="text/javascript" src="../../js/RelaxOpenWebCam.js"></script>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <script type="text/javascript" src="../../js/print.js"></script>
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <style type="text/css">
        #preview {
            width: 120px;
            height: 160px;
            overflow: hidden;
        }

        #preview_size_fake {
            filter: progid:DXImageTransform.Microsoft.AlphaImageLoader(sizingMethod=image);
        }
    </style>
    <script language="javascript" type="text/javascript">
        function showPic() {
            document.getElementById('BtnShowPic').click();
            return false;
        }

        function clearPic() {
            document.getElementById("hfPic").value = "";
            return true;
        }

        //金额选择
        function setGeneral() {
            $get('hidAccRecv').value = '198.00';
            $get('annualFee').innerHTML = '198.00';
            $get('txtRealRecv').value = '198';
            $get('txtDiscount').value = '0';
            $get('hidFuncType').value = '0F';
            $get('txtChanges').innerHTML = (parseFloat($get('txtRealRecv').value) + parseFloat($get('txtDiscount').value) - parseFloat($get('hidAccRecv').value)).toFixed(2);
            $get('Total').innerHTML = (parseFloat($get('DepositFee').innerHTML) + parseFloat($get('ProcedureFee').innerHTML) + parseFloat($get('annualFee').innerHTML)).toFixed(2);
        }

        function setXXGeneral() {
            $get('hidAccRecv').value = '298.00';
            $get('annualFee').innerHTML = '298.00';
            $get('txtRealRecv').value = '298';
            $get('txtDiscount').value = '0';
            $get('hidFuncType').value = '06';
            $get('txtChanges').innerHTML = (parseFloat($get('txtRealRecv').value) + parseFloat($get('txtDiscount').value) - parseFloat($get('hidAccRecv').value)).toFixed(2);
            $get('Total').innerHTML = (parseFloat($get('DepositFee').innerHTML) + parseFloat($get('ProcedureFee').innerHTML) + parseFloat($get('annualFee').innerHTML)).toFixed(2);
        }

        function setWXGeneral() {
            $get('hidAccRecv').value = '299.00';
            $get('annualFee').innerHTML = '299.00';
            $get('txtRealRecv').value = '299';
            $get('txtDiscount').value = '0';
            $get('hidFuncType').value = '0E';
            $get('txtChanges').innerHTML = (parseFloat($get('txtRealRecv').value) + parseFloat($get('txtDiscount').value) - parseFloat($get('hidAccRecv').value)).toFixed(2);
            $get('Total').innerHTML = (parseFloat($get('DepositFee').innerHTML) + parseFloat($get('ProcedureFee').innerHTML) + parseFloat($get('annualFee').innerHTML)).toFixed(2);
        }

        function recvChanging(testId, hidAccRecv) {
            var realRecv = $get('txtRealRecv');
            var discount = $get('txtDiscount');
            var test = $get(testId != null ? testId : 'txtChanges');
            test.innerHTML = (parseFloat(realRecv.value) + parseFloat(discount.value) -
                parseFloat($get(hidAccRecv != null ? hidAccRecv : 'hidAccRecv').value)).toFixed(2);
            if (test.innerHTML == 'NaN') {
                test.innerHTML = '';
            }
        }

        function setPicType() {
            $get('hidPicType').value = "take";
        }

        //图片上传预览    IE是用了滤镜。
        function previewImage(file) {
            var MAXWIDTH = 120;
            var MAXHEIGHT = 160;
            var div = document.getElementById('preview');
            if (file.files && file.files[0]) {
                div.innerHTML = '<img id=preview_size_fake>';
                var img = document.getElementById('preview_size_fake');
                img.onload = function () {
                    var rect = clacImgZoomParam(MAXWIDTH, MAXHEIGHT, 120, 160);
                    img.width = rect.width;
                    img.height = rect.height;
                    //                 img.style.marginLeft = rect.left+'px';
                    img.style.marginTop = rect.top + 'px';
                }
                var reader = new FileReader();
                reader.onload = function (evt) { img.src = evt.target.result; }
                reader.readAsDataURL(file.files[0]);
            }
            else //兼容IE
            {
                var sFilter = 'filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(sizingMethod=scale,src="';
                file.select();
                var src = document.selection.createRange().text;
                div.innerHTML = '<img id=preview_size_fake>';
                var img = document.getElementById('preview_size_fake');
                img.filters.item('DXImageTransform.Microsoft.AlphaImageLoader').src = src;
                var rect = clacImgZoomParam(MAXWIDTH, MAXHEIGHT, img.offsetWidth, img.offsetHeight);
                status = ('rect:' + rect.top + ',' + rect.left + ',' + rect.width + ',' + rect.height);
                div.innerHTML = "<div id=divhead style='width:" + rect.width + "px;height:" + rect.height + "px;margin-top:" + rect.top + "px;" + sFilter + src + "\"'></div>";
            }
        }
        function clacImgZoomParam(maxWidth, maxHeight, width, height) {
            var param = { top: 0, left: 0, width: width, height: height };
            if (width > maxWidth || height > maxHeight) {
                rateWidth = width / maxWidth;
                rateHeight = height / maxHeight;

                if (rateWidth > rateHeight) {
                    param.width = maxWidth;
                    param.height = Math.round(height / rateWidth);
                } else {
                    param.width = Math.round(width / rateHeight);
                    param.height = maxHeight;
                }
            }

            param.left = Math.round((maxWidth - param.width) / 2);
            param.top = Math.round((maxHeight - param.height) / 2);
            return param;
        }
    </script>
</head>
<body>
    <cr:CardReader ID="cardReader" runat="server" />
    <form id="form1" runat="server">
        <div class="tb">
            附加业务->惠民休闲年卡-开通
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
                <aspControls:PrintHMXXPingZheng ID="ptnPingZheng" runat="server" PrintArea="ptnPingZheng1" />
                <asp:BulletedList ID="bulMsgShow" runat="server">
                </asp:BulletedList>
                <script runat="server">public override void ErrorMsgShow() { ErrorMsgHelper(bulMsgShow); }</script>
                <div class="con">
                    <div class="card">
                        卡片信息
                    </div>
                    <div class="kuang5">
                        <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text20">
                            <tr>
                                <td width="10%">
                                    <div align="right">
                                        用户卡号:
                                    </div>
                                </td>
                                <td width="13%">
                                    <asp:TextBox ID="txtCardNo" CssClass="labeltext" runat="server" />
                                </td>
                                <td width="9%">
                                    <div align="right">
                                        卡片类型:
                                    </div>
                                </td>
                                <td width="13%">
                                    <asp:Label ID="labCardType" CssClass="labeltext" runat="server" />
                                </td>
                                <td width="9%">
                                    <div align="right">
                                        卡内余额:
                                    </div>
                                </td>
                                <td width="13%">
                                    <asp:TextBox ID="txtCardBalance" CssClass="labeltext" runat="server" />
                                </td>
                                <td width="9%">&nbsp;
                                </td>
                                <td width="24%">
                                    <asp:Button ID="btnReadCard" Text="读卡" CssClass="button1" runat="server" OnClientClick="return clearPic()&&readXXParkInfo();"
                                        OnClick="btnReadCard_Click" />
                                </td>
                                <asp:HiddenField runat="server" ID="hidWarning" />
                                <asp:HiddenField runat="server" ID="hidAsn" />
                                <asp:HiddenField runat="server" ID="hidTradeNo" />
                                <asp:HiddenField runat="server" ID="hidAccRecv" />
                                <asp:HiddenField runat="server" ID="hidParkInfo" />
                                <asp:HiddenField runat="server" ID="hidCardReaderToken" />
                                <asp:HiddenField runat="server" ID="hidForPaperNo" />
                                <asp:HiddenField runat="server" ID="hidForPhone" />
                                <asp:HiddenField runat="server" ID="hidForAddr" />
                                <asp:HiddenField runat="server" ID="hidFuncType" />
                                <asp:HiddenField ID="hfPic" runat="server" />
                                <asp:HiddenField runat="server" ID="hidNewCardNo" />
                                <asp:HiddenField ID="hiddenDepositFee" runat="server" />
                                <asp:HiddenField ID="hidProcedureFee" runat="server" />
                                <asp:HiddenField ID="hiddenAnnualFee" runat="server" />
                                <asp:HiddenField ID="hidLockBlackCardFlag" runat="server" />
                                <asp:HiddenField ID="hidStaffNo" runat="server" />
                                <asp:HiddenField runat="server" ID="hidPicType" />
                                <asp:HiddenField runat="server" ID="hidPackageTypeCode" />
                                <asp:LinkButton runat="server" ID="btnConfirm" OnClick="btnConfirm_Click" />
                            </tr>
                            <tr>
                                <td>
                                    <div align="right">
                                        启用日期:
                                    </div>
                                </td>
                                <td>
                                    <asp:TextBox ID="txtStartDate" CssClass="labeltext" runat="server" />
                                </td>
                                <td>
                                    <div align="right">
                                        休闲到期:
                                    </div>
                                </td>
                                <td>
                                    <asp:Label ID="labGardenEndDate" CssClass="labeltext" runat="server" />
                                </td>
                                <td>
                                    <div align="right">
                                        卡内次数:
                                    </div>
                                </td>
                                <td>
                                    <asp:Label ID="labUsableTimes" CssClass="labeltext" runat="server" />
                                </td>
                                <td>&nbsp;
                                </td>
                                <td>&nbsp;
                                </td>
                            </tr>
                        </table>
                    </div>
                    <div class="pip">
                        用户信息
                    </div>
                    <div class="kuang5">
                        <table border="0" cellpadding="0" cellspacing="0" style="line-height: 35px; font-size: 12px;">
                            <tr>
                                <td width="5%">
                                    <div align="right">
                                        用户姓名:
                                    </div>
                                </td>
                                <td width="15%">
                                    <asp:TextBox ID="txtCustName" CssClass="input" runat="server" MaxLength="50" /><span
                                        class="red">*</span>
                                </td>
                                <td width="5%">
                                    <div align="right">
                                        证件类型:
                                    </div>
                                </td>
                                <td width="15%" style="white-space: nowrap">
                                    <asp:DropDownList ID="selPaperType" CssClass="input" runat="server">
                                    </asp:DropDownList>
                                    <span class="red">*</span>
                                </td>
                                <td width="20%" rowspan="5" align="center">
                                    <div id="webcam">
                                    </div>
                                </td>
                                <td width="10%" rowspan="5" align="center">
                                    <div id="preview">
                                        <img src="~/Images/nom.jpg" runat="server" alt="" width="120" height="160" id="preview_size_fake" />
                                        <img runat="server" alt="" width="120" height="160" id="Img1" />
                                    </div>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <div align="right">
                                        证件号码:
                                    </div>
                                </td>
                                <td>
                                    <asp:TextBox ID="txtPaperNo" CssClass="inputmid" runat="server" MaxLength="20" /><span
                                        class="red">*</span>
                                </td>
                                <td>
                                    <div align="right">
                                        出生日期:
                                    </div>
                                </td>
                                <td>
                                    <asp:TextBox ID="txtCustBirth" CssClass="input" runat="server" MaxLength="8" />
                                </td>
                                <ajaxToolkit:CalendarExtender ID="FCalendar" runat="server" TargetControlID="txtCustBirth"
                                    Format="yyyyMMdd" />
                            </tr>
                            <tr>
                                <td>
                                    <div align="right">
                                        用户性别:
                                    </div>
                                </td>
                                <td>
                                    <asp:DropDownList ID="selCustSex" CssClass="input" runat="server">
                                    </asp:DropDownList>
                                </td>
                                <td>
                                    <div align="right">
                                        联系电话:
                                    </div>
                                </td>
                                <td>
                                    <asp:TextBox ID="txtCustPhone" CssClass="input" runat="server" MaxLength="20" />
                            </tr>
                            <tr>
                                <td>
                                    <div align="right">
                                        邮政编码:
                                    </div>
                                </td>
                                <td>
                                    <asp:TextBox ID="txtCustPost" CssClass="input" runat="server" MaxLength="6" />
                                </td>
                                <td>
                                    <div align="right">
                                        联系地址:
                                    </div>
                                </td>
                                <td>
                                    <asp:TextBox ID="txtCustAddr" CssClass="inputmid" runat="server" MaxLength="50" />
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <div align="right">
                                        电子邮件:
                                    </div>
                                </td>
                                <td colspan="2">
                                    <asp:TextBox ID="txtEmail" CssClass="input" runat="server" MaxLength="30" />
                                </td>
                                <td>
                                    <asp:Button ID="txtReadPaper" Text="读二代证" CssClass="button1" runat="server" OnClientClick="clearPic();readIDCard('txtCustName', 'selCustSex', 'txtCustBirth', 'selPaperType', 'txtPaperNo', 'txtCustAddr', 'hfPic');showPic();" />
                                    <asp:LinkButton ID="BtnShowPic" runat="server" OnClick="BtnShowPic_Click" />
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <div align="right">
                                        备注:
                                    </div>
                                </td>
                                <td colspan="3">
                                    <asp:TextBox ID="txtRemark" CssClass="inputlong" runat="server" MaxLength="100" />
                                </td>
                                <td align="center">
                                    <asp:Button ID="btnShowWebCam" runat="server" CssClass="button1" OnClientClick="return Capture();"
                                        Text="拍摄" />
                                </td>
                                <td></td>
                            </tr>
                            <tr>
                                <td>
                                    <div align="right">
                                        照片导入:
                                    </div>
                                </td>
                                <td colspan="2" id="tdFileUpload" runat="server">
                                    <asp:FileUpload ID="FileUpload1" runat="server" CssClass="inputlong" onchange="previewImage(this)" />
                                </td>
                                <td align="left">
                                    <asp:Button ID="btnUpload" runat="server" CssClass="button1" Text="导入" OnClick="btnUpload_Click" />
                                </td>
                                <td id="tdMsg" runat="server" align="center">
                                    <asp:Label ID="lblMsg" runat="server" Text="请尽快补录照片！" ForeColor="Red"></asp:Label>
                                </td>
                            </tr>
                        </table>
                    </div>
                </div>
                <div class="basicinfo">
                    <div class="money">
                        费用信息
                    </div>
                    <div class="kuang5">
                        <div style="height: 124px">
                            <table width="180" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                <tr class="tabbt">
                                    <td width="66">费用项目
                                    </td>
                                    <td width="94">费用金额(元)
                                    </td>
                                </tr>
                                <tr>
                                    <td>押金
                                    </td>
                                    <td>
                                        <asp:Label ID="DepositFee" runat="server" Text=""></asp:Label>
                                    </td>
                                </tr>
                                <tr class="tabjg">
                                    <td>手续费
                                    </td>
                                    <td>
                                        <asp:Label ID="ProcedureFee" runat="server" Text=""></asp:Label>
                                    </td>
                                </tr>
                                <tr>
                                    <td>年费
                                    </td>
                                    <td>
                                        <asp:Label ID="annualFee" runat="server" Text=""></asp:Label>
                                    </td>
                                </tr>
                                <tr class="tabjg">
                                    <td>合计应收
                                    </td>
                                    <td>
                                        <asp:Label ID="Total" runat="server" Text=""></asp:Label>
                                    </td>
                                </tr>
                            </table>
                        </div>
                    </div>
                </div>
                <div class="pipinfo">
                    <div class="info">
                        收款信息
                    </div>
                    <div class="kuang5">
                        <div class="bigkuang" style="height: 124px">
                            <div class="left">
                                <img src="../../Images/show-sale.JPG" width="164" height="96" />
                            </div>
                            <div class="big2">
                                <table width="400" border="0" cellpadding="0" cellspacing="0" class="text25">
                                    <tr>
                                        <td>
                                            <label>
                                                本次实收:&nbsp;</label>
                                        </td>
                                        <td>
                                            <asp:TextBox ID="txtRealRecv" CssClass="inputshort" runat="server" MaxLength="9" />
                                        </td>
                                        <td colspan="2"></td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <label>
                                                本次折扣:&nbsp;</label>
                                        </td>
                                        <td>
                                            <asp:TextBox ID="txtDiscount" CssClass="inputshort" runat="server" MaxLength="9" />
                                        </td>
                                        <td colspan="2"></td>
                                    </tr>
                                    <script type="text/javascript">
                                        function setChargeValue(chargeVal) {
                                            $get('hidAccRecv').value = chargeVal;
                                            changannualMoney($get('hidAccRecv'));
                                            realRecvChanging($get(''));
                                            return false;
                                        }
                                    </script>
                                    <tr>
                                        <td width="80">
                                            <asp:RadioButton ID="radioGeneral" runat="server" GroupName="radio" Text="198套餐" />
                                            <%--OnClick="return setGeneral();"--%>
                                        </td>
                                        <td width="120">
                                            <asp:RadioButton ID="radioXXGeneral" runat="server" GroupName="radio" Text="298套餐(乐园)" Visible="False"/>
                                            <%--OnClick="return setXXGeneral();" --%>
                                        </td>
                                        <td colspan="2">
                                            <asp:RadioButton ID="radioWXGeneral" runat="server" GroupName="radio" Text="299套餐(动物园)" Visible="False" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>本次应找:
                                        </td>
                                        <td>
                                            <div id="txtChanges" runat="server">
                                                0.00
                                            </div>
                                        </td>
                                        <td colspan="2" class="red">
                                            <asp:Label runat="server" ID="labPromptFor" Text=""></asp:Label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td colspan="2">
                                            <asp:DropDownList ID="selChargeType" CssClass="inputmid" runat="server" AutoPostBack="true"
                                                OnSelectedIndexChanged="selChargeType_SelectedIndexChanged" Width="120">
                                                <asp:ListItem Text="现金" Value="01" Selected="True"></asp:ListItem>
                                                <asp:ListItem Text="兑换卡" Value="02"></asp:ListItem>
                                            </asp:DropDownList>
                                            <asp:Label runat="server" ID="labPrompt" Text="兑换卡密码：" Visible="false"></asp:Label>
                                        </td>
                                        <td colspan="2">
                                            <asp:TextBox ID="txtPrompt" runat="server" CssClass="input" Visible="false" AutoPostBack="true"
                                                OnTextChanged="txtPrompt_Changed" />
                                        </td>
                                    </tr>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="footall">
                </div>
                <div class="btns">
                    <table width="300" align="right" border="0" cellpadding="0" cellspacing="0">
                        <tr>
                            <td>
                                <asp:Button ID="btnPrintPZ" runat="server" Text="打印凭证" CssClass="button1" Enabled="false"
                                    OnClientClick="printdiv('ptnPingZheng1')" />
                            </td>
                            <td>
                                <%--<asp:Button ID="btnUpload" runat="server" Text="上传照片" CssClass="button1" Enabled="false"
                                OnClick="btnUpload_Click" />--%>
                            </td>
                            <td>
                                <asp:Button ID="btnSubmit" Enabled="false" CssClass="button1" runat="server" Text="提交"
                                    OnClick="btnSubmit_Click" />
                            </td>
                        </tr>
                    </table>
                    <asp:CheckBox ID="chkPingzheng" runat="server" Text="自动打印凭证" Checked="true" />
                </div>
            </ContentTemplate>
            <Triggers>
                <asp:PostBackTrigger ControlID="btnUpload" />
                <asp:PostBackTrigger ControlID="BtnShowPic" />
            </Triggers>
        </asp:UpdatePanel>
    </form>
</body>
</html>

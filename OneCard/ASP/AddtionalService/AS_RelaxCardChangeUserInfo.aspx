<%@ Page Language="C#" AutoEventWireup="true" CodeFile="AS_RelaxCardChangeUserInfo.aspx.cs"
    Inherits="ASP_AddtionalService_AS_RelaxCardChangeUserInfo" ValidateRequest="false" %>

<%@ Register Src="../../CardReader.ascx" TagName="CardReader" TagPrefix="cr" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>修改资料</title>
    <script type="text/javascript" src="../../js/jquery.min.js"></script>
    <script type="text/javascript" src="../../js/webcam/jquery.webcam.min.js"></script>
    <script type="text/javascript" src="../../js/RelaxUserWebCam.js"></script>
    <script type="text/javascript" src="../../js/print.js"></script>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
        <style type="text/css">  
    #preview{width:120px;height:160px;overflow:hidden;}  
    #preview_size_fake {filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(sizingMethod=image);}  
    </style>  
    <script type="text/javascript">
        function showPic() {
            document.getElementById('BtnShowPic').click();
            return false;
        }

        function clearPic() {
            document.getElementById("hfPic").value = "";
            return true;
        }

        function setPicType() {
            $get('hidPicType').value = "take";
        }
        function previewImage(file) {
            var MAXWIDTH = 120;
            var MAXHEIGHT = 160;
            var div = document.getElementById('preview');
            if (file.files && file.files[0]) {
                div.innerHTML = '<img id=preview_size_fake>';
                var img = document.getElementById('preview_size_fake');
                img.onload = function () {
                    var rect = clacImgZoomParam(MAXWIDTH, MAXHEIGHT, img.offsetWidth, img.offsetHeight);
                    img.width = rect.width;
                    img.height = rect.height;
                    img.style.marginLeft = rect.left + 'px';
                    img.style.marginTop = rect.top + 'px';
                }
                var reader = new FileReader();
                reader.onload = function (evt) { img.src = evt.target.result; }
                reader.readAsDataURL(file.files[0]);
            }
            else {
                var sFilter = 'filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(sizingMethod=scale,src="';
                file.select();
                var src = document.selection.createRange().text;
                div.innerHTML = '<img id=preview_size_fake>';
                var img = document.getElementById('preview_size_fake');
                img.filters.item('DXImageTransform.Microsoft.AlphaImageLoader').src = src;
                var rect = clacImgZoomParam(MAXWIDTH, MAXHEIGHT, img.offsetWidth, img.offsetHeight);
                status = ('rect:' + rect.top + ',' + rect.left + ',' + rect.width + ',' + rect.height);
                div.innerHTML = "<div id=divhead style='width:" + rect.width + "px;height:" + rect.height + "px;margin-top:" + rect.top + "px;margin-left:" + rect.left + "px;" + sFilter + src + "\"'></div>";
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
        附加业务->修改资料
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
                    卡片信息</div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text20">
                        <tr>
                            <td width="10%">
                                <div align="right">
                                    用户卡号:</div>
                            </td>
                            <td width="13%">
                                <asp:TextBox ID="txtCardNo" CssClass="input" runat="server" />
                            </td>
                            <td width="9%">
                                <div align="right">
                                    休闲到期:</div>
                            </td>
                            <td width="13%">
                                <asp:Label ID="labRelaxEndDate" CssClass="labeltext" runat="server" />
                            </td>
                            <td width="9%">
                                <div align="right">
                                    休闲套餐:</div>
                            </td>
                            <td width="13%">
                                <asp:Label ID="labRelaxPackage" runat="server" />
                            </td>
                            <td width="9%">
                                <asp:Button ID="btnReadCard" Text="读卡" CssClass="button1" runat="server" OnClientClick="return readXXParkInfo()"
                                    OnClick="btnReadCard_Click" />
                            </td>
                            <td width="24%">
                                &nbsp;<asp:Button ID="btnReadDb" Text="读数据库" CssClass="button1" runat="server" OnClick="btnReadDb_Click" />
                            </td>
                            <asp:HiddenField runat="server" ID="hidWarning" />
                            <asp:HiddenField runat="server" ID="hidAsn" />
                            <asp:HiddenField runat="server" ID="hidTradeNo" />
                            <asp:HiddenField runat="server" ID="hidAccRecv" />
                            <asp:HiddenField runat="server" ID="hidFuncType" />
                            <asp:HiddenField runat="server" ID="hidForPaperNo" />
                            <asp:HiddenField runat="server" ID="hidForPhone" />
                            <asp:HiddenField runat="server" ID="hidForAddr" />
                            <asp:HiddenField ID="hfPic" runat="server" />
                            <asp:HiddenField ID="hidStaffNo" runat="server" />
                            <asp:HiddenField runat="server" ID="hidParkInfo" Value="FFFFFFFF02FF" />
                            <asp:HiddenField runat="server" ID="hidCardReaderToken" />
                            <asp:HiddenField runat="server" ID="hidPicType" />
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    账户类型:</div>
                            </td>
                            <td>
                                <asp:Label ID="labAccountType" runat="server" />
                            </td>
                            <td>
                                <div align="right">
                                    园林到期:</div>
                            </td>
                            <td>
                                <asp:Label ID="labGardenEndDate" runat="server" />
                            </td>
                            <td>
                                &nbsp;
                            </td>
                            <td>
                                &nbsp;
                            </td>
                            <td>
                                &nbsp;
                            </td>
                            <td>
                                &nbsp;
                            </td>
                        </tr>
                       <%-- <tr>
                            <td>
                                <div align="right">
                                    开通员工:</div>
                            </td>
                            <td>
                                <asp:Label ID="labUpdateStaff" runat="server" />
                            </td>
                            <td>
                                <div align="right">
                                    开通时间:</div>
                            </td>
                            <td>
                                <asp:Label ID="labUpdateTime" runat="server" />
                            </td>
                            <td>
                                <div align="right">
                                    开通套餐:</div>
                            </td>
                            <td>
                                <asp:Label ID="labPackage" runat="server" />
                            </td>
                            <td>
                                <div align="right">
                                    账户类型:</div>
                            </td>
                            <td>
                                <asp:Label ID="labAccountType" runat="server" />
                            </td>
                        </tr>--%>
                    </table>
                </div>
                  <div class="pip">
                    用户信息</div>
                <div class="kuang5">
                    <table border="0" cellpadding="0" cellspacing="0" style="line-height: 35px; font-size: 12px;">
                        <tr>
                            <td width="5%">
                                <div align="right">
                                    用户姓名:</div>
                            </td>
                            <td width="15%">
                                <asp:TextBox ID="txtCustName" CssClass="input" runat="server" MaxLength="50" /><span
                                    class="red">*</span>
                            </td>
                            <td width="5%">
                                <div align="right">
                                    证件类型:</div>
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
                              <div  id="preview">
                                <img src="~/Images/nom.jpg" runat="server" alt="" width="120" height="160" id="preview_size_fake" />
                                </div>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    证件号码:</div>
                            </td>
                            <td>
                                <asp:TextBox ID="txtPaperNo" CssClass="inputmid" runat="server" MaxLength="20" /><span
                                    class="red">*</span>
                            </td>
                            <td>
                                <div align="right">
                                    出生日期:</div>
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
                                    用户性别:</div>
                            </td>
                            <td>
                                <asp:DropDownList ID="selCustSex" CssClass="input" runat="server">
                                </asp:DropDownList>
                            </td>
                            <td>
                                <div align="right">
                                    联系电话:</div>
                            </td>
                            <td>
                                <asp:TextBox ID="txtCustPhone" CssClass="input" runat="server" MaxLength="20" />
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    邮政编码:</div>
                            </td>
                            <td>
                                <asp:TextBox ID="txtCustPost" CssClass="input" runat="server" MaxLength="6" />
                            </td>
                            <td>
                                <div align="right">
                                    联系地址:</div>
                            </td>
                            <td>
                                <asp:TextBox ID="txtCustAddr" CssClass="inputmid" runat="server" MaxLength="50" />
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    电子邮件:</div>
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
                                    备注:</div>
                            </td>
                            <td colspan="3">
                                <asp:TextBox ID="txtRemark" CssClass="inputlong" runat="server" MaxLength="100" />
                            </td>
                            <td align="center">
                                <asp:Button ID="btnShowWebCam" runat="server" CssClass="button1" OnClientClick="return Capture();"
                                    Text="拍摄" />
                            </td>
                            <td>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    照片导入:</div>
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
            <div class="footall">
            </div>
            <div class="btns">
                <table width="300" align="right" border="0" cellpadding="0" cellspacing="0">
                    <tr>
                       <%-- <td>
                            <asp:Button ID="btnUpload" runat="server" Text="上传照片" CssClass="button1" Enabled="false"
                                OnClick="btnUpload_Click" />
                        </td>--%>
                        <td>
                            <asp:Button ID="btnUpdate" Enabled="false" CssClass="button1" runat="server" Text="修改"
                                OnClick="btnUpdate_Click" />
                        </td>
                    </tr>
                </table>
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

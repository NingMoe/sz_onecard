<%@ Page Language="C#" AutoEventWireup="true" CodeFile="RM_CardFaceConfirm.aspx.cs"
    Inherits="ASP_ResourceManage_RM_CardFaceConfirm" EnableEventValidation="false" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>卡面确认 </title>
    <style type="text/css">
        #preview_wrapper{  
            display:inline-block;  
            width:200px;  
            height:160px;  
            background-color:#CCC;  
        }
        #preview_fake{   
            filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(sizingMethod=scale);  
        }  
        #preview_size_fake{   
            filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(sizingMethod=image);    
            visibility:hidden;  
        }  
    </style>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />

    <script type="text/javascript">
        function onUploadImgChange(sender) {
            if (!sender.value.match(/.jpg|.jpeg|.gif|.png|.bmp/i)) {
                alert('图片格式无效');
                return false;
            }

            var objPreview = document.getElementById('preview');
            var objPreviewFake = document.getElementById('preview_fake');
            var objPreviewSizeFake = document.getElementById('preview_size_fake');

            if (sender.files && sender.files[0]) {
                objPreview.style.display = 'block';
                objPreview.style.width = 'auto';
                objPreview.style.height = 'auto';

                // Firefox 因安全性问题已无法直接通过 input[file].value 获取完整的文件路径  
                objPreview.src = sender.files[0].getAsDataURL();
            } else if (objPreviewFake.filters) {
                // IE7,IE8 在设置本地图片地址为 img.src 时出现莫名其妙的后果  
                //（相同环境有时能显示，有时不显示），因此只能用滤镜来解决 

                // IE7, IE8因安全性问题已无法直接通过 input[file].value 获取完整的文件路径  
                sender.select();
                var imgSrc = document.selection.createRange().text;

                objPreviewFake.filters.item('DXImageTransform.Microsoft.AlphaImageLoader').src = imgSrc;
                objPreviewSizeFake.filters.item('DXImageTransform.Microsoft.AlphaImageLoader').src = imgSrc;

                autoSizePreview(objPreviewFake,
            objPreviewSizeFake.offsetWidth, objPreviewSizeFake.offsetHeight);
                objPreview.style.display = 'none';
            }
        }

        function onPreviewLoad(sender) {
            autoSizePreview(sender, sender.offsetWidth, sender.offsetHeight);
        }

        function autoSizePreview(objPre, originalWidth, originalHeight) {
            var zoomParam = clacImgZoomParam(650, 160, originalWidth, originalHeight);
            objPre.style.width = zoomParam.width + 'px';
            objPre.style.height = zoomParam.height + 'px';
            objPre.style.marginTop = zoomParam.top + 'px';
            objPre.style.marginLeft = zoomParam.left + 'px';
        }

        function clacImgZoomParam(maxWidth, maxHeight, width, height) {
            var param = { width: width, height: height, top: 0, left: 0 };

            if (width > maxWidth || height > maxHeight) {
                rateWidth = width / maxWidth;
                rateHeight = height / maxHeight;

                if (rateWidth > rateHeight) {
                    param.width = maxWidth;
                    param.height = height / rateWidth;
                } else {
                    param.width = width / rateHeight;
                    param.height = maxHeight;
                }
            }

            param.left = (maxWidth - param.width) / 2;
            param.top = (maxHeight - param.height) / 2;

            return param;
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
    <div class="tb">
        卡片管理->卡面确认
    </div>
    <ajaxToolkit:ToolkitScriptManager runat="Server" EnableScriptGlobalization="true"
        EnableScriptLocalization="true" ID="ToolkitScriptManager1" />
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
        <ContentTemplate>
            <asp:BulletedList ID="bulMsgShow" runat="server" />
            <script runat="server">public override void ErrorMsgShow() { ErrorMsgHelper(bulMsgShow); }</script>
            <div class="con">
                <div class="jieguo">
                    需求单</div>
                <div class="kuang5">
                    <div id="gdtb" style="height: 150px">
                        <asp:GridView ID="gvOrder" runat="server" Width="95%" CssClass="tab1" HeaderStyle-CssClass="tabbt"
                            FooterStyle-CssClass="tabcon" AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel"
                            PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top"
                            AutoGenerateColumns="false" PageSize="50" OnSelectedIndexChanged="gvOrder_SelectedIndexChanged"
                            OnRowCreated="gvOrder_RowCreated" OnPageIndexChanging="gvOrder_Page">
                            <Columns>
                                <asp:BoundField DataField="APPLYORDERID" HeaderText="需求单号" />
                                <asp:BoundField DataField="CARDNAME" HeaderText="卡片名称" />
                                <asp:BoundField DataField="WAY" HeaderText="卡面确认方式" />
                                <asp:BoundField DataField="CARDNUM" HeaderText="下单数量" />
                                <asp:BoundField DataField="REQUIREDATE" HeaderText="要求到货日期" />
                                <asp:BoundField DataField="ORDERDEMAND" HeaderText="订单要求" />
                                <asp:BoundField DataField="ORDERTIME" HeaderText="下单时间" />
                                <asp:BoundField DataField="ORDERSTAFF" HeaderText="下单员工" />
                                <asp:BoundField DataField="REMARK" HeaderText="备注" />
                            </Columns>
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                        <td>
                                            需求单号
                                        </td>
                                        <td>
                                            卡片名称
                                        </td>
                                        <td>
                                            卡面确认方式
                                        </td>
                                        <td>
                                            下单数量
                                        </td>
                                        <td>
                                            要求到货日期
                                        </td>
                                        <td>
                                            订单要求
                                        </td>
                                        <td>
                                            下单时间
                                        </td>
                                        <td>
                                            下单员工
                                        </td>
                                        <td>
                                            备注
                                        </td>
                                    </tr>
                                </table>
                            </EmptyDataTemplate>
                        </asp:GridView>
                    </div>
                </div>
                <div class="base">
                    文件上传</div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td width="10%">
                                <div align="right">
                                    需求单号:</div>
                            </td>
                            <td width="20%">
                                <asp:Label ID="txtApplyCardOrderID" runat="server">
                                </asp:Label>
                            </td>
                            <td>
                                <div align="right">
                                    上传卡样文件:</div>
                            </td>
                            <td>
                                <asp:FileUpload ID="FileUpload1" runat="server" CssClass="inputlong" onchange="onUploadImgChange(this)" />
                                <%--<asp:LinkButton ID="btnUpload" runat="server" OnClick="btnUpload_Click" />--%>
                                <asp:Button ID="btnUpload" CssClass="button1" runat="server" Text="上传" OnClick="btnUpload_Click" />
                                <%--<input type="file" size="30" name="picaddress" CssClass="inputlong" onchange="javascript:FileChange(this.value);">--%>
                            </td>
                        </tr>
                    </table>
                </div>
            </div>
            <div class="pipinfo2" style="width: 60%">
                <div class="jieguo">
                    卡面图片</div>
                <div class="kuang5" style="height: 160px">
                    <div class="left" id="preview_fake">
                        <img id="preview" runat="server" alt="图片"  src="../../Images/cardface.jpg" style="cursor:hand" height="160" />
                        <img src="" alt="图片预览" id="preview_size_fake"/></div>
                </div>
            </div>
            <div class="basicinfo2" style="margin-left: 61.3%">
                <div class="jieguo">
                    需求单与卡样对应关系</div>
                <div class="kuang5" style="height: 160px">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                        <tr class="tabbt">
                            <td width="50%">
                                需求单号
                            </td>
                            <td width="50%">
                                卡样编码
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <asp:Label ID="labApplyOrderID" runat="server" Text=" "></asp:Label>
                            </td>
                            <td>
                                <asp:Label ID="labCardSampleNo" runat="server" Text=" "></asp:Label>
                            </td>
                        </tr>
                    </table>
                </div>
            </div>
            <div class="btns">
                <table width="95%" border="0" cellpadding="0" cellspacing="0">
                    <tr>
                        <td width="70%">
                            &nbsp;
                        </td>
                        <td align="right">
                            <asp:Button ID="btnSubmit" Enabled="false" CssClass="button1" runat="server" Text="提交"
                                OnClick="btnSubmit_Click" />
                        </td>
                    </tr>
                </table>
            </div>
        </ContentTemplate>
        <Triggers>
            <asp:PostBackTrigger ControlID="btnUpload" />
        </Triggers>
    </asp:UpdatePanel>
    </form>
</body>
</html>

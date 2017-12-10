<%@ Page Language="C#" AutoEventWireup="true" CodeFile="AS_RelaxCardPrintPic.aspx.cs" Inherits="ASP_AS_RelaxCardPrintPic" %>

<%@ Register Src="../../CardReader.ascx" TagName="CardReader" TagPrefix="cr" %>
<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>打印照片</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <script type="text/javascript" src="../../js/print.js"></script>
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="../../js/jquery.min.js"></script>
    <script type="text/javascript" src="../../js/webcam/jquery.webcam.min.js"></script>
    <script src="../../js/RelaxCardPrintPhoto.js"></script>
</head>
<body>
    <cr:CardReader ID="cardReader" runat="server" />
    <form id="form1" runat="server">
        <div class="tb">
            附加业务->打印照片 
        </div>
        <ajaxToolkit:ToolkitScriptManager EnableScriptGlobalization="true" EnableScriptLocalization="true" ID="ScriptManager1" runat="server" />
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
                    <div class="card">卡片信息</div>
                    <div class="kuang5">
                        <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text20">
                            <tr>
                                <td height="35" width="10%">
                                    <div align="right">用户卡号:</div>
                                </td>
                                <td width="13%">
                                    <asp:TextBox ID="txtCardno" CssClass="input" runat="server" /></td>
                                <td width="9%"><asp:Button ID="btnReadCard" Text="读卡" CssClass="button1" runat="server"
                                        OnClientClick="return ReadCardInfo()" OnClick="btnReadCard_Click" /></td>
                                <td width="13%"></td>
                                <td width="9%"></td>
                                <td width="13%"></td>
                                <td rowspan="5"  width="14%" align="center">
                                     <div id="webcam"></div> 
                                     <asp:Button  CssClass="button1" runat="server" Text="重拍照片" ID="btnShowWebCam" OnClientClick="return Capture();" />  
                                </td>
                                <td rowspan="5"  width="2%"></td> 
                                <td rowspan="5" >
                                     <img src="~/Images/nom.jpg" runat="server" alt="" width="150" height="200" id="imgCustomerPic" /> 
                                     <asp:HiddenField runat="server" ID="hidWarning" />
                                     <asp:HiddenField runat="server" ID="hiddenAsn" />
                                     <asp:HiddenField runat="server" ID="hidTradeNo" />
                                     <asp:HiddenField runat="server" ID="hidAccRecv" />
                                     <asp:HiddenField runat="server" ID="hidFuncType" />
                                     <asp:HiddenField runat="server" ID="hidAccountType" />
                                     <asp:HiddenField runat="server" ID="hidParkInfo" Value="FFFFFFFF02FF" />
                                     <asp:HiddenField runat="server" ID="hidCardReaderToken" />
                                     <asp:HiddenField runat="server" ID="hidStaffno" />
                                </td>  
                            </tr>
                            <tr>
                                <td height="35">
                                    <div align="right">用户姓名:</div>
                                </td>
                                <td>
                                    <asp:Label ID="txtCustName" runat="server" /></td>
                                <td>
                                    <div align="right">出生日期:</div>
                                </td>
                                <td>
                                    <asp:Label ID="txtCustBirth" runat="server" /></td>
                                <td>
                                    <div align="right">证件类型:</div>
                                </td>
                                <td>
                                    <asp:Label ID="selPaperType" runat="server" />
                                </td>  
                            </tr> 
                             <tr>
                                <td height="35">
                                    <div align="right">证件号码:</div>
                                </td>
                                <td>
                                    <asp:Label ID="txtPaperNo" runat="server" />
                                </td>
                                <td>
                                    <div align="right">用户性别:</div>
                                </td>
                                <td>
                                    <asp:Label ID="selCustSex" runat="server" />
                                </td>
                                <td>
                                    <div align="right">联系电话:</div>
                                </td>
                                <td>
                                    <asp:Label ID="txtCustPhone" runat="server" /> 
                                </td>
                            </tr>
                             <tr>
                                <td height="35">
                                    <div align="right">联系地址:</div>
                                </td>
                                <td>
                                    <asp:Label ID="txtCustAddr" runat="server" />
                                </td>
                                <td>
                                    <div align="right">电子邮件:</div>
                                </td>
                                <td>
                                    <asp:Label ID="txtEmail" runat="server" />
                                </td>
                                <td>
                                    <div align="right">邮编:</div>
                                </td>
                                <td> 
                                    <asp:Label ID="txtCustPost" runat="server" CssClass="disable" /> 
                                </td>
                                <td> 
                                    <asp:HiddenField ID="hidIsCapture" runat="server" Value="0" /> 
                                    <asp:HiddenField ID="hidCardno" runat="server" Value="" />
                                </td>
                            </tr>
                             <tr>
                                <td height="35"> 
                                    <div align="right">备注:</div>
                                </td>
                                <td  colspan="5"> 
                                    <asp:Label ID="txtRemark" runat="server" CssClass="disable" />
                                </td>
                                
                            </tr>
                        </table>

                    </div>  
                    <div class="pip">打印模板</div>
                    <div class="kuang5">
                        <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                            <tr>
                                <td width="30%">
                                    <div align="center" style="vertical-align: middle;">
                                        <asp:RadioButton ID="rdoPrintTemplate1" runat="server" GroupName="rdoPrintTemplate" Text="公交月票卡" CssClass="disable"/>公交月票卡
                                    </div>
                                </td>
                                <td width="30%">
                                    <div align="center" style="vertical-align: middle;">
                                        <asp:RadioButton ID="rdoPrintTemplate2" runat="server" GroupName="rdoPrintTemplate" Text="公务员卡" CssClass="disable"/>公务员卡
                                    </div>
                                </td>
                                <td>
                                    <div align="center" valign="middle" style="vertical-align: middle;">
                                        <asp:RadioButton ID="rdoPrintTemplate3" runat="server" GroupName="rdoPrintTemplate" Text="二维码市民卡" CssClass="disable"/>二维码市民卡
                                    </div>
                                </td>
                            </tr>
                            <tr>
                                <td width="30%" class="tdTemplate" id="tdTemplate1">
                                    <div align="center" style="vertical-align: middle;">
                                        <img onclick="ChangeTemplate('1')" style="cursor: pointer" src="../../Images/PrintTemplate2.jpg" />
                                    </div>
                                </td>
                                <td width="30%" class="tdTemplate" id="tdTemplate2">
                                    <div align="center" style="vertical-align: middle;">
                                        <img onclick="ChangeTemplate('2')" style="cursor: pointer" src="../../Images/PrintTemplate3.jpg" />
                                    </div>
                                </td>
                                <td class="tdTemplate" id="tdTemplate3">
                                    <div align="center" valign="middle" style="vertical-align: middle;">
                                        <img onclick="ChangeTemplate('3')" style="cursor: pointer" src="../../Images/PrintTemplate7.jpg" />
                                    </div>
                                </td>
                            </tr>
                            <tr>
                                <td width="30%">
                                     <div align="center" style="vertical-align: middle;">
                                        <asp:RadioButton ID="rdoPrintTemplate4" runat="server" GroupName="rdoPrintTemplate" Text="联名卡" CssClass="disable"/>联名卡
                                    </div> 
                                </td>
                                <td width="30%"> 
                                    <div align="center" valign="middle" style="vertical-align: middle;">
                                        <asp:RadioButton ID="rdoPrintTemplate5" runat="server" GroupName="rdoPrintTemplate" Text="非联名卡" CssClass="disable" />非联名卡
                                    </div>
                                </td>
                                <td>
                                    <div align="center" style="vertical-align: middle;">
                                        <asp:RadioButton ID="rdoPrintTemplate6" runat="server" GroupName="rdoPrintTemplate" Text="市民卡" CssClass="disable"/>市民卡
                                    </div>
                                </td>
                            </tr>
                            <tr>
                                <td width="30%" class="tdTemplate"  id="tdTemplate4">
                                   <div align="center" style="vertical-align: middle;">
                                        <img onclick="ChangeTemplate('4')" style="cursor: pointer" src="../../Images/PrintTemplate5.jpg" />
                                    </div>
                                </td>
                                <td width="30%" class="tdTemplate"  id="tdTemplate5">
                                      <div align="center" valign="middle" style="vertical-align: middle;">
                                        <img onclick="ChangeTemplate('5')" style="cursor: pointer" src="../../Images/PrintTemplate1.jpg" />
                                    </div> 
                                </td>
                                <td class="tdTemplate"  id="tdTemplate6">
                                    <div align="center" style="vertical-align: middle;">
                                        <img onclick="ChangeTemplate('6')" style="cursor: pointer" src="../../Images/PrintTemplate6.jpg" />
                                    </div>
                                </td>
                            </tr>
                        </table>
                    </div>
                    <div id="PrintArea" style="display: none">
                        <div id="divImg" class="juedui">
                            <img src="~/Images/nom.jpg" runat="server" alt="" id="imgPrint" />
                        </div>
                    </div>
                </div>
                <div class="footall"></div>
                <div class="btns">
                    <table width="200" align="right" border="0" cellpadding="0" cellspacing="0">
                        <tr>
                            <td>
                                <asp:Button ID="btnPrint" runat="server" Text="打印照片"
                                    CssClass="button1" Enabled="false" OnClientClick="return PrintCard();"  />
                                <asp:Button ID="btnSave" runat="server" Text="保存"
                                    CssClass="disable"  OnClick="btnSaveImg_Click" />

                            </td>
                            <td></td>
                        </tr>
                    </table>
                </div>
            </ContentTemplate>
        </asp:UpdatePanel>
    </form>
</body>
</html>

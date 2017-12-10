<%@ Page Language="C#" AutoEventWireup="true" CodeFile="AS_GardenCardNewCheck.aspx.cs"
    Inherits="ASP_AddtionalService_AS_GardenCardNewCheck" %>

<%@ Register Src="../../CardReader.ascx" TagName="CardReader" TagPrefix="cr" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>园林年卡-身份审核</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <script type="text/javascript" src="../../js/print.js"></script>
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <script language="javascript" type="text/javascript">
                function showPic() {
                    document.getElementById('BtnShowPic').click();
                    return false;
                }

                function clearPic() {
                    document.getElementById("hfPic").value = "";
                    return true;
                }
    </script>
</head>
<body>
    <cr:CardReader ID="cardReader" runat="server" />
    <form id="form1" runat="server">
    <div class="tb">
        附加业务->园林年卡-身份审核
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
            <asp:BulletedList ID="bulMsgShow" runat="server">
            </asp:BulletedList>
            <script runat="server">public override void ErrorMsgShow() { ErrorMsgHelper(bulMsgShow); }</script>
            <asp:HiddenField ID="hidPaperNo" runat="server" />
            <div class="con">
                <div class="card">
                    查询条件</div>
                <div class="kuang5">
                    <table width="100%" border="0" cellpadding="0" cellspacing="3" class="text25">
                        <tr>
                            <td width="14%">
                                <div align="right">
                                    卡号:</div>
                            </td>
                            <td width="16%">
                                <asp:TextBox ID="txtCardno" CssClass="input" runat="server" MaxLength="16" />
                            </td>
                            <td width="50%">
                                &nbsp;&nbsp;
                                <asp:Button ID="btnReadCardno" CssClass="button1" runat="server" Text="读卡" OnClientClick="return clearPic() && ReadCardInfo('txtCardno')"
                                    OnClick="btnReadCard_Click" />
                                &nbsp;&nbsp;
                                <asp:Button ID="btnReadCardDB" CssClass="button1" runat="server" Text="卡号查询" OnClick="btnReadCard_Click" />
                            </td>
                            <td width="20%"></td>
                        </tr>
                    </table>
                    <div class="linex">
                    </div>
                    <div class="linex">
                    </div>
                    <table width="100%" border="0" cellpadding="0" cellspacing="3" class="text25">
                        <tr>
                            <td width="14%">
                                <div align="right">
                                    身份证号:</div>
                            </td>
                            <td width="16%">
                                <asp:TextBox ID="txtPaperNo" CssClass="inputmid" runat="server" MaxLength="18" />
                            </td>
                            <td width="60%">
                                &nbsp;&nbsp;
                                <asp:Button ID="btnReadIDCard" CssClass="button1" runat="server" Text="读二代证" OnClientClick="return readIDCardOnlyID('selPaperType', 'txtPaperNo', 'hfPic');"
                                    OnClick="btnReadIDCard_Click" />
                                &nbsp;&nbsp;
                                <asp:Button ID="btnReadIDCardDB" CssClass="button1fix" runat="server" Text="身份证号查询" OnClientClick="return clearPic();"
                                    OnClick="btnReadIDCard_Click" />
                                    <asp:LinkButton ID="BtnShowPic"  runat="server" OnClick="BtnShowPic_Click" />&nbsp;&nbsp;
                                <asp:Button ID="btnSavePic" Text="保存照片" CssClass="button1" runat="server" OnClick="btnSavePic_Click" />
                            </td>
                            <td width="10%" align="left"><asp:Image ID="picImg" AlternateText="照片" ToolTip="二代证照片" runat="server" ImageUrl="" Width="60px" Height="65px" /></td>
                            <td width="10%"></td>
                        </tr>
                    </table>
                    <asp:HiddenField ID="hfPic" runat="server" />
                </div>
                <div class="jieguo">
                    查询结果</div>
                <div class="kuang5">
                    <div class="gdtb" style="height: 200px">
                        <asp:GridView ID="gvResult" runat="server" Width="98%" CssClass="tab1" HeaderStyle-CssClass="tabbt"
                            AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel" AllowPaging="True"
                            PageSize="10" PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left"
                            PagerStyle-VerticalAlign="Top" AutoGenerateColumns="False" OnPageIndexChanging="gvResult_Page"
                            OnRowDataBound="gvResult_RowDataBound">
                            <Columns>
                                <asp:BoundField HeaderText="卡号" DataField="CARDNO" />
                                <asp:BoundField HeaderText="有效期" DataField="ENDDATE" />
                                <asp:BoundField HeaderText="姓名" DataField="CUSTNAME" />
                                <asp:BoundField HeaderText="身份证号" DataField="PAPERNO" />
                                <asp:BoundField HeaderText="是否免检" DataField="EXEMPTION" />
                                <asp:TemplateField HeaderText="照片">
                                    <ItemTemplate>
                                        <asp:Image ID="Image1" Width="60px" Height="65px" runat="server" />
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                        <td>
                                            卡号
                                        </td>
                                        <td>
                                            有效期
                                        </td>
                                        <td>
                                            姓名
                                        </td>
                                        <td>
                                            身份证号
                                        </td>
                                        <td>
                                            是否免检
                                        </td>
                                    </tr>
                                </table>
                            </EmptyDataTemplate>
                        </asp:GridView>
                    </div>
                </div>
            </div>
            <div class="con">
                <div class="card">
                    加入撤销免检</div>
                <div class="kuang5">
                    <table width="100%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td width="14%">
                                <div align="right">
                                    身份证号:</div>
                            </td>
                            <td width="62%">
                                <asp:TextBox ID="txtPaperNoExemption" runat="server" CssClass="inputmid" MaxLength="18"></asp:TextBox>
                            </td>
                            <td width="24%">
                                &nbsp;&nbsp;
                                <asp:Button ID="btnExemption" runat="server" Text="加入免检" CssClass="button1" Enabled="true"
                                    OnClick="btnExemption_Click" />
                                &nbsp;&nbsp;
                                <asp:Button ID="btnCancelExemption" runat="server" Text="撤销免检" CssClass="button1"
                                    Enabled="true" OnClick="btnCancelExemption_Click" />
                            </td>
                    </table>
                </div>
            </div>
        </ContentTemplate>
                                                <Triggers>
            <asp:PostBackTrigger ControlID="BtnShowPic" />
        </Triggers>
    </asp:UpdatePanel>
    </form>
</body>
</html>

<%@ Page Language="C#" AutoEventWireup="true" CodeFile="GC_BillImport.aspx.cs" Inherits="ASP_GroupCard_GC_BillImport" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>到账导入</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript">
        function SelectAll(tempControl) {
            //将除头模板中的其它所有的CheckBox取反 

            var theBox = tempControl;
            xState = theBox.checked;

            elem = theBox.form.elements;
            for (i = 0; i < elem.length; i++)
                if (elem[i].type == "checkbox" && elem[i].id != theBox.id) {
                    if (elem[i].checked != xState)
                        elem[i].click();
                }
        } 
    </script>
</head>
<body>
    <form id="form1" runat="server">
    <div class="tb">
        到账导入
    </div>
    <ajaxToolkit:ToolkitScriptManager EnableScriptGlobalization="true" EnableScriptLocalization="true"
        ID="ScriptManager1" runat="server" />
    <asp:UpdatePanel ID="UpdatePanel1" UpdateMode="Conditional" runat="server">
        <ContentTemplate>
            <asp:BulletedList ID="bulMsgShow" runat="server" />
            <script runat="server">public override void ErrorMsgShow() { ErrorMsgHelper(bulMsgShow); }</script>
            <div class="con">
                <div class="base">
                    到账导入</div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td>
                                <div align="right">
                                    导入文件:</div>
                            </td>
                            <td>
                                <asp:FileUpload ID="FileUpload1" runat="server" CssClass="inputlong" />
                                <asp:Button ID="btnUpload" CssClass="button1" runat="server" Text="导入" OnClick="btnUpload_Click" />
                            </td>
                        </tr>
                    </table>
                </div>
                <div class="jieguo">
                    导入到账单信息</div>
                <div class="kuang5">
                    <div class="gdtb" style="height: 310px">
                        <asp:GridView ID="gvResult" runat="server" Width="98%" CssClass="tab1" HeaderStyle-CssClass="tabbt"
                            AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel" AllowPaging="True"
                            PageSize="100" PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left"
                            PagerStyle-VerticalAlign="Top" AutoGenerateColumns="False" OnPageIndexChanging="gvResult_Page"
                            OnRowDataBound="gvResult_RowDataBound" >
                            <Columns>
                                <asp:TemplateField HeaderText="校验结果">
                                    <ItemStyle Width="200px" />
                                    <HeaderTemplate>
                                        <asp:CheckBox ID="CheckBox1" runat="server" onclick="javascript:SelectAll(this);"  />
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                        <asp:CheckBox ID="ItemCheckBox" runat="server" />
                                        <asp:Label runat="server" ID="Label" Text='<%#Eval("ValidRet")%>'></asp:Label>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField DataField="F0" HeaderText="交易日期" />
                                <asp:BoundField DataField="F1" HeaderText="收入金额" />
                                <asp:BoundField DataField="F2" HeaderText="对方开户行" />
                                <asp:BoundField DataField="F3" HeaderText="对方户名" />
                                <asp:BoundField DataField="F4" HeaderText="对方账号" />
                                <asp:BoundField DataField="F5" HeaderText="交易说明" />
                                <asp:BoundField DataField="F6" HeaderText="交易摘要" />
                                <asp:BoundField DataField="F7" HeaderText="交易附言" />
                                <asp:BoundField DataField="F8" HeaderText="到账银行" />
                                <asp:BoundField DataField="F9" HeaderText="到账账号" />
                            </Columns>
                        </asp:GridView>
                    </div>
                </div>
            </div>
            <div class="btns">
                <table width="95%" border="0" cellpadding="0" cellspacing="0">
                    <tr>
                        <td width="70%">
                            &nbsp;
                        </td>
                        <td align="right">
                            <asp:Button ID="btnSubmit" CssClass="button1" runat="server" Text="提交" OnClick="btnSubmit_Click" />
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

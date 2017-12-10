<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PB_ExceptionSync.aspx.cs"
    Inherits="ASP_PersonalBusiness_PB_ExceptionSync" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ Register Src="../../CardReader.ascx" TagName="CardReader" TagPrefix="cr" %>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>张家港衍生卡异常同步</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <link href="../../css/Cust_AS.css" rel="stylesheet" type="text/css" />
    <style type="text/css">
        .auto-style1
        {
            width: 8%;
            height: 28px;
        }
        
        .auto-style2
        {
            width: auto;
            height: 28px;
        }
    </style>
</head>
<body>
    <cr:CardReader ID="cardReader" runat="server" />
    <form id="form1" runat="server">
    <div class="tb">
        个人业务->张家港衍生卡异常同步
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
        //        swpmIntance.add_endRequest(EndRequest);
        //        function EndRequest(sender, args) {
        //            bindingSelect('checkbox', 'ItemCheckBox', 'btnSubmit');
        //        }
    </script>
    <asp:UpdatePanel ID="UpdatePanel1" UpdateMode="Conditional" runat="server">
        <contenttemplate>
            <asp:BulletedList ID="bulMsgShow" runat="server" />
            <script runat="server">public override void ErrorMsgShow() { ErrorMsgHelper(bulMsgShow); }</script>
            <div class="con">
                <div class="card">
                    数据同步</div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td width="9%">
                                <div align="right">
                                    业务类型:
                                </div>
                            </td>
                            <td width="13%">
                                <asp:DropDownList ID="ddlTradeType" runat="server" Width="115px">
                                    <asp:ListItem Value="">00:全部业务</asp:ListItem>
                                    <asp:ListItem Value="9501">9501:单笔申请</asp:ListItem>
                                    <asp:ListItem Value="9506">9506:信息变更</asp:ListItem>
                                    <asp:ListItem Value="9505">9505:换卡申请</asp:ListItem>
                                    <asp:ListItem Value="9507">9507:注销申请</asp:ListItem>
                                    <asp:ListItem Value="9508">9508:售卡返销</asp:ListItem>
                                    <asp:ListItem Value="9510">9510:换卡返销</asp:ListItem>
                                    <asp:ListItem Value="9511">9511:退卡返销</asp:ListItem>
                                </asp:DropDownList>
                            </td>
                            <td width="9%">
                                <div align="right">
                                    异常状态:
                                </div>
                            </td>
                            <td width="13%">
                                <asp:DropDownList ID="radioExType" runat="server">
                                    <asp:ListItem Selected="True" Text="同步未成功" Value="0"></asp:ListItem>
                                    <asp:ListItem Text="未同步" Value="5"></asp:ListItem>
                                    <asp:ListItem Text="已作废" Value="3"></asp:ListItem>
                                </asp:DropDownList>
                            </td>
                            <td width="9%">
                                <div align="right">
                                    用户姓名:
                                </div>
                            </td>
                            <td width="13%">
                                <asp:TextBox ID="txtName" CssClass="input" MaxLength="20" runat="server"></asp:TextBox>
                            </td>
                            <td>
                            </td>
                        </tr>
                        <tr>
                            <td width="9%">
                                <div align="right">
                                    证件类型:
                                </div>
                            </td>
                            <td width="13%">
                                <asp:DropDownList ID="ddlPaperType" CssClass="input" runat="server">
                                    <asp:ListItem Value="" Selected="True">---请选择---</asp:ListItem>
                                    <asp:ListItem Value="00">00:身份证</asp:ListItem>
                                    <asp:ListItem Value="01">01：学生证</asp:ListItem>
                                    <asp:ListItem Value="02">02:军官证</asp:ListItem>
                                    <asp:ListItem Value="05">05:护照</asp:ListItem>
                                    <asp:ListItem Value="06">06:港澳居民来往内地通行证</asp:ListItem>
                                    <asp:ListItem Value="07">07:户口簿</asp:ListItem>
                                    <asp:ListItem Value="08">08:武警证</asp:ListItem>
                                    <asp:ListItem Value="09">09:台湾同胞来往内地通行证</asp:ListItem>
                                    <asp:ListItem Value="99">99:其他</asp:ListItem>
                                </asp:DropDownList>
                            </td>
                            <td width="9%">
                                <div align="right">
                                    证件号码:
                                </div>
                            </td>
                            <td width="13%">
                                <asp:TextBox ID="txtPaperNo" CssClass="inputmid" MaxLength="20" runat="server"></asp:TextBox>
                            </td>
                            <td>
                                &nbsp;
                            </td>
                            <td>
                            </td>
                            <td align="center">
                                <asp:Button ID="btnQuery" runat="server" CssClass="button1" OnClick="btnQuery_Click"
                                    Text="查询" />
                            </td>
                        </tr>
                    </table>
                </div>
                <div class="jieguo">
                    <span>
                        <asp:Label ID="LabExText" runat="server"></asp:Label></span>
                </div>
                <div class="kuang5">
                    <div id="gdtb" style="height: 350px">
                        <asp:GridView ID="gvResult" runat="server" Width="150%" CssClass="tab1" HeaderStyle-CssClass="tabbt"
                            AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="spec" AllowPaging="True"
                            PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top"
                            AutoGenerateColumns="false" EmptyDataText="没有数据记录!" OnPageIndexChanging="gvResult_Page"
                            OnRowDataBound="gvResult_RowDataBound">
                            <Columns>
                                <asp:TemplateField>
                                    <HeaderTemplate>
                                        <asp:CheckBox ID="checkAll" runat="server" AutoPostBack="true" OnCheckedChanged="CheckAll" />
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                        <asp:CheckBox ID="ItemCheckBox" runat="server" />
                                    </ItemTemplate>
                                    <ItemStyle Width="30px" />
                                </asp:TemplateField>
                                <asp:BoundField DataField="TRANS_CODE" HeaderText="业务类型" />
                                <asp:BoundField DataField="TRADEID" HeaderText="业务流水号" />
                                <asp:BoundField DataField="CITIZEN_CARD_NO" HeaderText="市民卡号" />
                                <asp:BoundField DataField="NAME" HeaderText="姓名" />
                                <asp:BoundField DataField="NEWPAPERTYPENAME" HeaderText="证件类型" />
                                <asp:BoundField DataField="PAPER_NO" HeaderText="证件号码" />
                                <asp:BoundField DataField="SYNCERRINFO" HeaderText="异常信息" />
                                <asp:BoundField DataField="SYNCTIME" HeaderText="同步时间" />
                                <asp:BoundField DataField="OPERATETIME" HeaderText="操作时间" />
                                <asp:BoundField DataField="OLD_CARD_NO" HeaderText="旧市民卡号" />
                                <asp:BoundField DataField="OLD_NAME" HeaderText="原姓名" />
                                <asp:BoundField DataField="OLDPAPERTYPENAME" HeaderText="原证件类型" />
                                <asp:BoundField DataField="OLD_PAPER_NO" HeaderText="原证件号码" />
                            </Columns>
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                        <td>
                                            业务类型
                                        </td>
                                        <td>
                                            市民卡号
                                        </td>
                                        <td>
                                            姓名
                                        </td>
                                        <td>
                                            证件类型
                                        </td>
                                        <td>
                                            证件号码
                                        </td>
                                        <td>
                                            同步异常信息
                                        </td>
                                        <td>
                                            同步时间
                                        </td>
                                        <td>
                                            操作时间
                                        </td>
                                        <td>
                                            旧市民卡号
                                        </td>
                                        <td>
                                            原姓名
                                        </td>
                                        <td>
                                            原证件类型
                                        </td>
                                        <td>
                                            原证件号码
                                        </td>
                                    </tr>
                                </table>
                            </EmptyDataTemplate>
                            <PagerStyle CssClass="page" />
                        </asp:GridView>
                    </div>
                </div>
            </div>
            <div class="cust_tabbox cust_tabbox_spec ">
                <div style="float: right; margin: 5px">
                    <asp:RadioButtonList ID="radioType" runat="server" RepeatDirection="Horizontal" RepeatLayout="Flow">
                        <asp:ListItem Value="1" Enabled="false">作废同步</asp:ListItem>
                        <asp:ListItem Value="2" Enabled="false">取消作废</asp:ListItem>
                        <asp:ListItem Value="0" Selected="True">重新同步</asp:ListItem>
                    </asp:RadioButtonList>
                    <asp:Button ID="btnSubmit" runat="server" Text="提交" CssClass="button1" OnClick="btnSubmit_Click"
                        OnClientClick="return confirm('确认提交?');" />
                </div>
            </div>
        </contenttemplate>
    </asp:UpdatePanel>
    </form>
</body>
</html>

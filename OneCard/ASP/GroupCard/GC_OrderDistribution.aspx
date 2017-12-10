<%@ Page Language="C#" AutoEventWireup="true" EnableEventValidation="false" CodeFile="GC_OrderDistribution.aspx.cs"
    Inherits="ASP_GroupCard_GC_OrderDistribution" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>订单分配</title>
    <%--<link rel="stylesheet" type="text/css" href="../../css/frame.css" />--%>
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="../../js/myext.js"></script>
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
        function setRadio(nowRadio) {
            var myForm, objRadio;
            myForm = document.forms[0];
            ///alert(myForm);
            for (var i = 0; i < myForm.length; i++) {
                if (myForm.elements[i].type == "radio") {
                    objRadio = myForm.elements[i];
                    ///alert(objRadio.name);
                    if (objRadio != nowRadio && objRadio.name.indexOf("gvOrderList") > -1 && objRadio.name.indexOf("RadioButton1") > -1) {
                        alert(objRadio.name);
                        if (objRadio.checked) {
                            objRadio.checked = false;
                        }
                    }
                }
            }
        }
    </script>
    <style type="text/css">
        table.data
        {
            font-size: 90%;
            border-collapse: collapse;
            border: 0px solid black;
        }
        table.data th
        {
            background: #bddeff;
            width: 25em;
            text-align: left;
            padding-right: 8px;
            font-weight: normal;
            border: 1px solid black;
        }
        table.data td
        {
            background: #ffffff;
            vertical-align: middle;
            padding: 0px 2px 0px 2px;
            border: 1px solid black;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
    <div class="tb">
        订单分配
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
                <div class="base">
                    订单分配</div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td width="8%">
                                <div align="right">
                                    单位名称:</div>
                            </td>
                            <td width="10%">
                                <asp:TextBox ID="txtGroupName" CssClass="inputmid" runat="server" AutoPostBack="true"
                                    OnTextChanged="queryGroupName"></asp:TextBox>
                            </td>
                            <td colspan="2">
                                <asp:DropDownList ID="selCompany" CssClass="inputmid" Width="206" runat="server"
                                 AutoPostBack="true" OnSelectedIndexChanged="selCompany_Changed">
                                </asp:DropDownList>
                            </td>
                            <td width="8%">
                                <div align="right">
                                    联系人:</div>
                            </td>
                            <td width="8%">
                                <asp:TextBox ID="txtName" CssClass="input" runat="server"></asp:TextBox>
                            </td>
                            <td width="8%">
                                <div align="right">
                                    部门:</div>
                            </td>
                            <td width="8%">
                                <asp:DropDownList ID="ddlDepart" CssClass="inputmid" runat="server" AutoPostBack="true"
                                    OnSelectedIndexChanged="ddlDept_Change">
                                </asp:DropDownList>
                            </td>
                        </tr>
                        <tr>
                            <td width="8%">
                                <div align="right">
                                    经办人:</div>
                            </td>
                            <td width="8%">
                                <asp:DropDownList ID="ddlTransactor" CssClass="inputmid" runat="server">
                                </asp:DropDownList>
                            </td>
                            <td width="8%">
                                <div align="right">
                                    金额:</div>
                            </td>
                            <td width="5%">
                                <asp:TextBox ID="txtTotalMoney" CssClass="input" runat="server"></asp:TextBox>
                            </td>
                            <td width="8%">
                                <div align="right">
                                    开始日期:</div>
                            </td>
                            <td width="8%">
                                <asp:TextBox runat="server" ID="txtFromDate" MaxLength="8" CssClass="input"></asp:TextBox>
                                <ajaxToolkit:CalendarExtender ID="CalendarExtender1" runat="server" TargetControlID="txtFromDate"
                                    Format="yyyyMMdd" />
                            </td>
                            <td width="8%">
                                <div align="right">
                                    结束日期:</div>
                            </td>
                            <td width="8%">
                                <asp:TextBox runat="server" ID="txtToDate" MaxLength="8" CssClass="input"></asp:TextBox>
                                <ajaxToolkit:CalendarExtender ID="CalendarExtender2" runat="server" TargetControlID="txtToDate"
                                    Format="yyyyMMdd" />
                            </td>
                        </tr>
                        <tr>
                            <td colspan="7">
                            </td>
                            <td>
                                &nbsp;&nbsp;<asp:Button runat="server" CssClass="button1" ID="btnQuery" Text="查询"
                                    OnClick="btnQuery_Click" />
                            </td>
                        </tr>
                    </table>
                </div>
                <table border="0" width="95%">
                    <tr>
                        <td align="left">
                            <div class="jieguo">
                                订单列表</div>
                        </td>
                    </tr>
                </table>
                <div class="kuang5">
                    <div class="gdtb" style="height: 270px; overflow: auto">
                        <asp:GridView ID="gvOrderList" CssClass="tab2" HeaderStyle-CssClass="tabbt" FooterStyle-CssClass="tabcon"
                            AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel" PagerSettings-Mode="NumericFirstLast"
                            PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top" runat="server"
                            AutoGenerateColumns="false" Width="150%" OnRowDataBound="gvOrderList_RowDataBound">
                            <Columns>
                                <asp:TemplateField>
                                    <HeaderTemplate>
                                        <asp:CheckBox ID="CheckBox1" runat="server" onclick="javascript:SelectAll(this);" />
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                        <asp:CheckBox ID="ItemCheckBox" runat="server" />
                                        <asp:HiddenField ID="hidGetDept" runat="server" Value='<%#Eval("getdepartment")%>' />
                                        <asp:HiddenField ID="hidGetDate" runat="server" Value='<%#Eval("getdate")%>' />
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField>
                                    <ItemTemplate>
                                        <asp:Button ID="btnDetail" CommandArgument='<%# Container.DataItemIndex%>' runat="server"
                                            Text="详细信息" CssClass="button1" OnClick="btnDetail_Click" />
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="领卡网点">
                                    <ItemTemplate>
                                        <asp:DropDownList ID="ddlGetDepart" CssClass="input" runat="server">
                                        </asp:DropDownList>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="领卡日期">
                                    <ItemTemplate>
                                        <asp:TextBox runat="server" ID="txtGetDate" MaxLength="8" CssClass="input"></asp:TextBox>
                                        <ajaxToolkit:CalendarExtender ID="CalendarExtender3" runat="server" TargetControlID="txtGetDate"
                                            Format="yyyyMMdd" />
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="关联卡">
                                    <ItemTemplate>
                                        <asp:RadioButton ID="radioButton1" runat="server" Text="制卡关联" GroupName="SupplyMoney"
                                            Checked="True" />
                                        <asp:RadioButton ID="radioButton2" runat="server" Text="领卡关联" GroupName="SupplyMoney" />
                                        <%--<asp:HiddenField ID="hidIsRelated" runat="server" Value='<%# Bind("isrelated") %>' />--%>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField DataField="orderno" HeaderText="订单号" />
                                <asp:BoundField DataField="groupname" HeaderText="单位名称" />
                                <asp:BoundField DataField="name" HeaderText="联系人" />
                                <asp:BoundField DataField="idcardno" HeaderText="身份证号码" />
                                <asp:BoundField DataField="phone" HeaderText="联系电话" />
                                <asp:BoundField DataField="totalmoney" HeaderText="购卡总金额(元)" />
                                <asp:BoundField DataField="transactor" HeaderText="经办人" />
                                <asp:BoundField DataField="inputtime" HeaderText="录入时间" />
                            </Columns>
                        </asp:GridView>
                    </div>
                </div>
            </div>
            <div class="con">
                <div class="jieguo">
                    详细信息</div>
                <div class="kuang5" runat="server" id="divInfo">
                </div>
            </div>
            <div class="btns">
                <table width="95%" border="0" cellpadding="0" cellspacing="0">
                    <tr>
                        <td width="80%">
                            &nbsp;
                        </td>
                        <td align="right">
                            <asp:Button ID="btnSubmit" CssClass="button1" Text="确认分配" runat="server" OnClick="btnSubmit_Click" />
                        </td>
                    </tr>
                </table>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
    </form>
</body>
</html>

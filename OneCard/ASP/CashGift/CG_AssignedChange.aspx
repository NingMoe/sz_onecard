<%@ Page Language="C#" AutoEventWireup="true" CodeFile="CG_AssignedChange.aspx.cs"
    Inherits="ASP_CashGift_CG_AssignedChange" EnableEventValidation="false" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>调配网点</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="../../js/myext.js"></script>
        <link href="../../css/card.css" rel="stylesheet" type="text/css" /> 
    
        <script type="text/JavaScript">

            function submitConfirm(cardtype,staff,dept) {

                if (true) {
                    MyExtConfirm('确认',
		        '已选中'  +cardtype+ '分配给' + dept + '的'+staff+',<br>是否确认调配？'
		        , submitConfirmCallback);
                }

            }
            function submitConfirmCallback(btn) {
                if (btn == 'yes') {
                    $get('btnConfirm').click();
                }
            }
    </script>
     <script language="javascript">
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
        利金卡->调配网点</div>
    <ajaxToolkit:ToolkitScriptManager runat="Server" EnableScriptGlobalization="true"
        EnableScriptLocalization="true" ID="ScriptManager2" />
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
                    查询
                </div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="2" class="12text">
                        <tr>
                            <td width="15%">
                                <div align="right">
                                    回收部门:</div>
                            </td>
                            <td width="15%">
                                <asp:DropDownList ID="ddlDept" CssClass="inputmid" runat="server" AutoPostBack="true"
                                    OnSelectedIndexChanged="ddlDept_Change" />
                            </td>
                            <td width="15%">
                                <div align="right">
                                    回收员工:</div>
                            </td>
                            <td width="15%">
                                <asp:DropDownList ID="ddlStaff" CssClass="inputmid" runat="server" />
                            </td>
                            <td width="15%">
                                <div align="right">
                                    最大数量:</div>
                            </td>
                            <td width="25%">
                                <asp:TextBox ID="txtCardNum" runat="server" CssClass="input" MaxLength="8" Text="100"></asp:TextBox>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    起始日期:</div>
                            </td>
                            <td>
                                <ajaxToolkit:CalendarExtender ID="BeginCalendar" runat="server" TargetControlID="txtStartDate"
                                    Format="yyyyMMdd" PopupPosition="BottomLeft" />
                                <asp:TextBox ID="txtStartDate" runat="server" CssClass="input" MaxLength="8"></asp:TextBox>
                            </td>
                            <td>
                                <div align="right">
                                    结束日期:</div>
                            </td>
                            <td>
                                <asp:TextBox ID="txtEndDate" runat="server" CssClass="input" MaxLength="8"></asp:TextBox>
                                <ajaxToolkit:CalendarExtender ID="CalendarExtender2" runat="server" TargetControlID="txtEndDate"
                                    Format="yyyyMMdd" PopupPosition="BottomLeft" />
                            </td>
                            <td width="15%">
                                <div align="right">
                                    利金卡类型:</div>
                            </td>
                            <td width="15%">
                                <asp:DropDownList ID="ddlCashType" CssClass="inputmid" runat="server" />
                            </td>
                            <td align="left">
                                <asp:Button ID="btnQuery" runat="server" Text="查询" CssClass="button1" OnClick="btnQuery_Click" />
                            </td>
                        </tr>
                    </table>
                </div>
                <div class="jieguo">
                    查询结果&nbsp;&nbsp;&nbsp;&nbsp;
                    <asp:Label ID="Label1" runat="server" Text="数量："></asp:Label>
                    <asp:Label ID="lblNum" runat="server" Text=""></asp:Label>&nbsp;&nbsp;
                    <asp:Label ID="Label3" runat="server" Text="第一张："></asp:Label>
                    <asp:Label ID="lblFirst" runat="server" Text=""></asp:Label>&nbsp;&nbsp;
                    <asp:Label ID="Label5" runat="server" Text="最后一张："></asp:Label>
                    <asp:Label ID="lblLast" runat="server" Text=""></asp:Label>&nbsp;&nbsp;
                </div>
                <div class="kuang5">
                    <div class="gdtb" style="height: 300px">
                        <asp:GridView ID="gvResult" runat="server" CssClass="tab1" Width="98%" HeaderStyle-CssClass="tabbt"
                            FooterStyle-CssClass="tabcon" AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel"
                            PageSize="1000" PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="Left"
                            PagerStyle-VerticalAlign="Top" AutoGenerateColumns="False" EmptyDataText="没有数据记录!">
                            <PagerSettings Mode="NumericFirstLast" />
                            <Columns>
                                <asp:TemplateField>
                                    <HeaderTemplate>
                                        <asp:CheckBox ID="CheckBox1" runat="server" onclick="javascript:SelectAll(this);" />
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                        <asp:CheckBox ID="ItemCheckBox" runat="server" />
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField DataField="CARDNO" HeaderText="卡号" />
                                <asp:BoundField DataField="CARDTYPENAME"  HeaderText = "卡片类型" />
                                <asp:BoundField DataField="STAFFNAME" HeaderText="卡片归属员工" />
                                <asp:BoundField DataField="DEPARTNAME" HeaderText="卡片归属部门" />
                                <asp:BoundField DataField="RECLAIMTIME" HeaderText="回收时间" />
                            </Columns>
                            <PagerStyle HorizontalAlign="Left" VerticalAlign="Top" />
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                        <td>
                                            <input type="checkbox" />
                                        </td>
                                        <td>
                                            卡号
                                        </td>
                                        <td>
                                            卡片类型
                                        </td>
                                        <td>
                                            卡片归属员工
                                        </td>
                                        <td>
                                            卡片归属部门
                                        </td>
                                        <td>
                                            回收时间
                                        </td>
                                    </tr>
                                </table>
                            </EmptyDataTemplate>
                            <SelectedRowStyle CssClass="tabsel" />
                            <HeaderStyle CssClass="tabbt" />
                            <AlternatingRowStyle CssClass="tabjg" />
                        </asp:GridView>
                    </div>
                </div>
                <div class="card">
                    调配网点</div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td width="15%">
                                <div align="right">
                                    归属部门:</div>
                            </td>
                            <td width="15%">
                                <asp:DropDownList ID="selDept" CssClass="inputmid" runat="server" AutoPostBack="true"
                                    OnSelectedIndexChanged="selDept_Change">
                                </asp:DropDownList>
                            </td>
                            <td width="15%">
                                <div align="right">
                                    归属员工:</div>
                            </td>
                            <td width="15%">
                                <asp:DropDownList ID="selStaff" CssClass="inputmid" runat="server" >
                                </asp:DropDownList>
                            </td>
                            <td width="15%">
                            </td>
                            <td align="left" width="25%">
                                <asp:LinkButton runat="server" ID="btnConfirm" OnClick="btnConfirm_Click" />
                                <asp:Button ID="btnSummit" runat="server" Text="提交" CssClass="button1" OnClick="btnSummit_Click" />
                            </td>
                        </tr>
                    </table>
                </div>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
    </form>
</body>
</html>

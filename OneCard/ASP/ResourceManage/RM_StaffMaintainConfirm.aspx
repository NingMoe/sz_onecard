<%@ Page Language="C#" AutoEventWireup="true" CodeFile="RM_StaffMaintainConfirm.aspx.cs" Inherits="ASP_ResourceManage_RM_StaffMaintainConfirm"  EnableEventValidation="false" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
<link href="../../css/card.css" rel="stylesheet" type="text/css" />

    <script type="text/javascript" src="../../js/myext.js"></script>

    <script type="text/javascript" src="../../js/RMHelper.js"></script>

    <script type="text/javascript" src="../../js/printorder.js"></script>

    <script src="../../js/jquery-1.5.min.js" type="text/javascript"></script>

    <script type="text/javascript" src="../../js/Window.js"></script>
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
    <title>工单确认</title>
</head>
<body>
    <form id="form1" runat="server">
    <div class="tb">
        资源管理->工单确认
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
                <div class="card">
                    查询
                </div>
                <div class="kuang5" style="text-align: left">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            
                            <td width="15%">
                                <div align="right">
                                    起始日期:</div>
                            </td>
                            <td width="15%">
                                <ajaxToolkit:CalendarExtender ID="BeginCalendar" runat="server" TargetControlID="txtStartDate"
                                    Format="yyyyMMdd" PopupPosition="BottomLeft" />
                                <asp:TextBox ID="txtStartDate" runat="server" CssClass="input" MaxLength="8"></asp:TextBox>
                            </td>
                            <td width="15%">
                                <div align="right">
                                    结束日期:</div>
                            </td>
                            <td width="15%">
                                <asp:TextBox ID="txtEndDate" runat="server" CssClass="input" MaxLength="8"></asp:TextBox>
                                <ajaxToolkit:CalendarExtender ID="CalendarExtender2" runat="server" TargetControlID="txtEndDate"
                                    Format="yyyyMMdd" PopupPosition="BottomLeft" />
                            </td>
                            <td width="15%">
                                <div align="right">
                                    维护网点:</div>
                            </td>
                            <td width="15%">
                                <asp:DropDownList ID="selDept" CssClass="inputmid" runat="server" >
                                </asp:DropDownList>
                            </td>
                        </tr>
                        <tr>
                            <td width="15%">
                                <div align="right">
                                    完成情况:</div>
                            </td>
                            <td width="15%">
                                <asp:DropDownList ID="ddlIfFinish" CssClass="inputmid" runat="server">
                                <asp:ListItem Text="---请选择---" Value=""></asp:ListItem>
                                <asp:ListItem Text="0:未完成" Value="0"></asp:ListItem>
                                <asp:ListItem Text="1:已完成" Value="1"></asp:ListItem>
                                </asp:DropDownList>
                            </td>
                            
                            <td width="15%">
                                <div align="right">
                                    是否确认:</div>
                            </td>
                            <td width="15%">
                            
                                <asp:DropDownList ID="ddlState" CssClass="inputmid" runat="server">
                                <asp:ListItem Text="---请选择---" Value=""></asp:ListItem>
                                <asp:ListItem Text="0:未确认" Value="0"></asp:ListItem>
                                <asp:ListItem Text="1:已确认" Value="1"></asp:ListItem>
                                </asp:DropDownList>
                            </td>
                           
                        </tr>
                        <tr>
                        <td width="15%" colspan='6' align="right">
                                <asp:Button ID="btnQuery" CssClass="button1" runat="server" Text="查询" OnClick="btnQuery_Click" />
                            </td>
                        </tr>
                    </table>
                </div>
                <div class="jieguo">
                    查询结果</div>
                <div class="kuang5">
                    <div id="gvSupplyCard" style="height: 180px; overflow: auto; display: block">
                        <asp:GridView ID="gvResult" runat="server" Width="100%" CssClass="tab1" HeaderStyle-CssClass="tabbt"
                            FooterStyle-CssClass="tabcon" AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel"
                            PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top"
                            AutoGenerateColumns="false" PageSize="20" AllowPaging="true" OnPageIndexChanging="gvResult_Page"
                           OnRowCreated="gvResult_RowCreated" OnSelectedIndexChanged="gvResult_SelectedIndexChanged">
                            <Columns>
                                <asp:BoundField DataField="SIGNINMAINTAINID" HeaderText="维护单号" />
                                <asp:BoundField DataField="MAINTAINDEPT" HeaderText="维护网点" />
                                <asp:BoundField DataField="RESOURCENAME" HeaderText="资源名称" />
                                <asp:BoundField DataField="SIGNINTIME" HeaderText="维护时间" />
                                <asp:BoundField DataField="STAFFNAME" HeaderText="维护员工" />
                                <asp:BoundField DataField="USETIME" HeaderText="维护时长" />
                                <asp:BoundField DataField="EXPLANATION" HeaderText="维护说明" />
                                <asp:BoundField DataField="STATE" HeaderText="是否确认" />
                                <asp:BoundField DataField="ISFINISHED" HeaderText="完成情况" />
                                <asp:BoundField DataField="SATISFATION" HeaderText="满意度" />
                                <asp:BoundField DataField="CONFIRMATION" HeaderText="确认说明" />
                            </Columns>
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                        
                                        <td>
                                            维护单号
                                        </td>
                                        <td>
                                            维护网点
                                        </td>
                                        <td>
                                            资源名称
                                        </td>
                                        <td>
                                            维护时间
                                        </td>
                                        <td>
                                            维护员工
                                        </td>
                                        <td>
                                            维护时长
                                        </td>
                                        <td>
                                           维护说明 
                                        </td>
                                         <td>
                                           是否确认 
                                        </td>
                                         <td>
                                            完成情况
                                        </td>
                                        <td>
                                            满意度
                                        </td>
                                        <td>
                                            确认说明
                                        </td>
                                        
                                    </tr>
                                </table>
                            </EmptyDataTemplate>
                        </asp:GridView>
                    </div>
                </div>
                <div class="card">
                    填写工单</div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr id="applySupplyStock">
                            <td width="12%">
                                <div align="right">
                                    完成情况:</div>
                            </td>
                            <td width="36%">
                                <asp:DropDownList ID="ddlInFinish" CssClass="inputmid" runat="server">
                                <asp:ListItem Text="---请选择---" Value=""></asp:ListItem>
                                <asp:ListItem Text="0:未完成" Value="0"></asp:ListItem>
                                <asp:ListItem Text="1:已完成" Value="1"></asp:ListItem>
                                </asp:DropDownList>
                                <asp:Label Text="*" runat="server" ID="lb1" Font-Bold="True" ForeColor="Red"></asp:Label>
                            </td>
                            <td width="12%">
                                <div align="right">
                                    满意度:</div>
                            </td>
                            <td width="36%">
                                <asp:DropDownList ID="ddlSatisfy" CssClass="inputmid" runat="server">
                                <asp:ListItem Text="---请选择---" Value=""></asp:ListItem>
                                <asp:ListItem Text="一星级" Value="1"></asp:ListItem>
                                <asp:ListItem Text="二星级" Value="2"></asp:ListItem>
                                <asp:ListItem Text="三星级" Value="3"></asp:ListItem>
                                <asp:ListItem Text="四星级" Value="4"></asp:ListItem>
                                <asp:ListItem Text="五星级" Value="5"></asp:ListItem>
                                </asp:DropDownList>
                                <asp:Label Text="*" runat="server" ID="Label3" Font-Bold="True" ForeColor="Red"></asp:Label>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    确认说明:</div>
                            </td>
                            <td>
                                <asp:TextBox ID="txtExplanation" CssClass="input"  runat="server" Width="200px"
                                    Height="42px" TextMode="MultiLine"></asp:TextBox>
                               
                            </td>
                            
                           
                        </tr>

                    </table>
                </div>
                </div>
                <div class="btns">
                <table width="95%" border="0" cellpadding="0" cellspacing="0" style="height: 30px">
                    <tr>
                    <td width="80%">
                            &nbsp;
                        </td>
                        <td width="10%" align="right">
                            <asp:Button ID="btnModify" Text="修改" CssClass="button1" runat="server" OnClick="btnModify_Click" />
                        </td>

                        <td width="10%" align="right">
                            <asp:Button ID="btnAdd" Text="提交" CssClass="button1" runat="server" OnClick="btnbtnAdd_Click" />
                        </td>
                    </tr>
                </table>
                </div>
               
            

            
        </ContentTemplate>
    </asp:UpdatePanel>
    </form>
</body>
</html>

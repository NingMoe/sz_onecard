<%@ Page Language="C#" AutoEventWireup="true" CodeFile="RM_StaffMaintainInput.aspx.cs" Inherits="ASP_ResourceManage_RM_StaffMaintainInput" EnableEventValidation="false" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
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
    <title>工单录入</title>
</head>
<body>
    <form id="form1" runat="server">
    <div class="tb">
        资源管理->工单录入
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
                                    资源类型:</div>
                            </td>
                            <td width="15%">
                                <asp:DropDownList ID="selResourceType" CssClass="inputmid" runat="server" 
                                AutoPostBack="true" OnSelectedIndexChanged="selResourceType_change">
                                </asp:DropDownList>
                            </td>
                            <td width="15%">
                                <div align="right">
                                    资源名称:</div>
                            </td>
                            <td width="15%">
                                <asp:DropDownList ID="selResourceName" CssClass="inputmid" runat="server">
                                </asp:DropDownList>
                            </td>
                            <td width="15%">
                                <div align="right">
                                    匹配情况:</div>
                            </td>
                            <td width="15%">
                            
                                <asp:DropDownList ID="ddlState" CssClass="inputmid" runat="server">
                                <asp:ListItem Text="---请选择---" Value=""></asp:ListItem>
                                <asp:ListItem Text="0:未匹配" Value="0"></asp:ListItem>
                                <asp:ListItem Text="1:已匹配" Value="1"></asp:ListItem>
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
                                <asp:BoundField DataField="RESUOURCETYPE" HeaderText="资源类型" />
                                <asp:BoundField DataField="RESOURCENAME" HeaderText="资源名称" />
                                <asp:BoundField DataField="MAINTAINDEPT" HeaderText="维护网点" />
                                <asp:BoundField DataField="USETIME" HeaderText="维护时长" />
                                <asp:BoundField DataField="EXPLANATION" HeaderText="故障说明" />
                                <asp:BoundField DataField="RELATEDSTATE" HeaderText="匹配情况" />
                            </Columns>
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                        
                                        <td>
                                            维护单号
                                        </td>
                                        <td>
                                            资源类型
                                        </td>
                                        <td>
                                            资源名称
                                        </td>
                                        <td>
                                            维护网点
                                        </td>
                                        <td>
                                            维护时长
                                        </td>
                                        <td>
                                            故障说明
                                        </td>
                                        <td>
                                            是否匹配
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
                                    资源类型:</div>
                            </td>
                            <td width="36%">
                                <asp:DropDownList ID="InResourceType" CssClass="inputmid" Width="200px" runat="server"
                                    AutoPostBack="true" OnSelectedIndexChanged="InResourceType_change">
                                </asp:DropDownList>
                                <asp:Label Text="*" runat="server" ID="lb1" Font-Bold="True" ForeColor="Red"></asp:Label>
                            </td>
                            <td width="12%">
                                <div align="right">
                                    资源名称:</div>
                            </td>
                            <td width="36%">
                                <asp:DropDownList ID="InResourceName" CssClass="inputmid" Width="200px" runat="server">
                                </asp:DropDownList>
                                <asp:Label Text="*" runat="server" ID="Label3" Font-Bold="True" ForeColor="Red"></asp:Label>
                            </td>
                        </tr>
                        <tr>
                        <td >
                               <div align="right">
                                    维护网点:</div>
                            </td>
                            <td >
                                <asp:DropDownList ID="ddlDept" CssClass="inputmid" runat="server" >
                                </asp:DropDownList>
                            </td>
                            
                            <td>
                                <div align="right">
                                    维护时长:</div>
                            </td>
                            <td>
                                <asp:TextBox ID="txtTime" CssClass="input"  runat="server" Width="200px"></asp:TextBox>
                                <asp:Label Text="小时(允许一位小数)" runat="server" ID="Label2"  ></asp:Label>
                                <asp:Label Text="*" runat="server" ID="Label1" Font-Bold="True" ForeColor="Red"></asp:Label>
                            </td>
                           
                        </tr>
                        <tr>
                        <td>
                                <div align="right">
                                    故障情况说明:</div>
                            </td>
                            <td>
                                <asp:TextBox ID="txtExplanation" CssClass="input"  runat="server" Width="200px"
                                    Height="42px" TextMode="MultiLine"></asp:TextBox>
                                <asp:Label Text="*" runat="server" ID="lb2" Font-Bold="True" ForeColor="Red"></asp:Label>
                            </td>
                        </tr>

                    </table>
                </div>
                <div class="btn" style="height: 50px">
                <table width="300" border="0" align="right" cellpadding="0" cellspacing="0" style="height: 30px">
                    <tr>
                        <td width="36%" align="right">
                            <asp:Button ID="btnModify" Text="修改" CssClass="button1" runat="server" OnClick="btnModify_Click" />
                        </td>

                        <td width="36%" align="left">
                            <asp:Button ID="btnAdd" Text="新增" CssClass="button1" runat="server" OnClick="btnAdd_Click" />
                        </td>
                    </tr>
                </table>
                </div>
                <div class="card">
                    查询签到表
                </div>
                <div class="kuang5" style="text-align: left">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            
                            <td width="15%">
                                <div align="right">
                                    起始日期:</div>
                            </td>
                            <td width="15%">
                                <ajaxToolkit:CalendarExtender ID="CalendarExtender1" runat="server" TargetControlID="txtStartDate2"
                                    Format="yyyyMMdd" PopupPosition="BottomLeft" />
                                <asp:TextBox ID="txtStartDate2" runat="server" CssClass="input" MaxLength="8"></asp:TextBox>
                            </td>
                            <td width="15%">
                                <div align="right">
                                    结束日期:</div>
                            </td>
                            <td width="15%">
                                <asp:TextBox ID="txtEndDate2" runat="server" CssClass="input" MaxLength="8"></asp:TextBox>
                                <ajaxToolkit:CalendarExtender ID="CalendarExtender3" runat="server" TargetControlID="txtEndDate2"
                                    Format="yyyyMMdd" PopupPosition="BottomLeft" />
                            </td>
                            <td width="15%">
                                <div align="right">
                                    匹配情况:</div>
                            </td>
                            <td width="15%">
                            
                                <asp:DropDownList ID="ddlState2" CssClass="inputmid" runat="server">
                                <asp:ListItem Text="---请选择---" Value=""></asp:ListItem>
                                <asp:ListItem Text="0:未匹配" Value="0"></asp:ListItem>
                                <asp:ListItem Text="1:已匹配" Value="1"></asp:ListItem>
                                </asp:DropDownList>
                            </td>
                        </tr>
                        <tr>
                            <td width="15%">
                                <div align="right">
                                    维护员工:</div>
                            </td>
                          
                             <td width="15%">
                                <asp:DropDownList ID="selStaff" CssClass="inputmid" runat="server" >
                                </asp:DropDownList>
                            </td>
                            
                            <td width="15%" colspan='4' align="right">
                                <asp:Button ID="Button1" CssClass="button1" runat="server" Text="查询" OnClick="btnQuery2_Click" />
                            </td>
                        </tr>
                    </table>
                </div>
                <div class="jieguo">
                    查询结果</div>
                <div class="kuang5">
                    <div id="Div1" style="height: 180px; overflow: auto; display: block">
                        <asp:GridView ID="gvResult2" runat="server" Width="100%" CssClass="tab1" HeaderStyle-CssClass="tabbt"
                            FooterStyle-CssClass="tabcon" AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel"
                            PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top"
                            AutoGenerateColumns="false"  AllowPaging="false" 
                           >
                            <Columns>
                            <asp:TemplateField>
                                    <HeaderTemplate>
                                      <asp:CheckBox ID="CheckBox1" runat="server"  onclick="javascript:SelectAll(this);" />
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                      <asp:CheckBox ID="ItemCheckBox" runat="server"/>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField DataField="SIGNINSHEETID" HeaderText="签到单号" />
                                <asp:BoundField DataField="CARDNO" HeaderText="卡号" />
                                <asp:BoundField DataField="STAFFNAME" HeaderText="姓名" />
                                <asp:BoundField DataField="SIGNINTIME" HeaderText="签到时间" />
                                <asp:BoundField DataField="OPERATEDEPT" HeaderText="操作部门" />
                                <asp:BoundField DataField="STATE" HeaderText="匹配情况" />
                            </Columns>
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                        <td>
                                            <input type="checkbox" />
                                        </td>
                                        <td>
                                            签到单号
                                        </td>
                                        <td>
                                            卡号
                                        </td>
                                        <td>
                                            姓名
                                        </td>
                                        <td>
                                            签到时间
                                        </td>
                                        <td>
                                            操作部门
                                        </td>
                                        <td>
                                            匹配情况
                                        </td>
                                        
                                    </tr>
                                </table>
                            </EmptyDataTemplate>
                        </asp:GridView>
                    </div>
                </div>
              
                
                <table width="300" border="0" align="right" cellpadding="0" cellspacing="0" style="height: 30px">
                    <tr>
                    <td width="30%">
                    </td> 
                    <td width="25%">
                    </td>                     
                        <td width="45%" align="left">
                            <asp:Button ID="btnRelation" runat="server" Text="关联签到单" CssClass="button1" Enabled="true"
                                OnClick="btnRelation_Click" />
                        </td>
                    </tr>
                </table>
           
            </div>
            <div class="footall">
            </div>
            <div class="btns">
                
                
            </div>
            

            
        </ContentTemplate>
    </asp:UpdatePanel>
    </form>
</body>
</html>

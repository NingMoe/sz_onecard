<%@ Page Language="C#" AutoEventWireup="true" CodeFile="RM_ResourceDistribution.aspx.cs" Inherits="ASP_ResourceManage_RM_ResourceDistribution" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>资源领用申请</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="../../js/myext.js"></script>

    <style type="text/css">

        table.data {font-size: 90%; border-collapse: collapse; border: 0px solid black;}
        table.data th {background: #bddeff; width: 25em; text-align: left; padding-right: 8px; font-weight: normal; border: 1px solid black;}
        table.data td {background: #ffffff; vertical-align:middle;padding: 0px 2px 0px 2px; border: 1px solid black;}
        .attributeDIV {WIDTH:24%;float:left; text-align:center }
    </style>
</head>
<body>
    <form id="form1" runat="server">
    <div class="tb">
        其他资源管理->资源派发
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
    <asp:UpdatePanel ID="UpdatePanel1" UpdateMode="Conditional" runat="server">
        <ContentTemplate>
            <asp:BulletedList ID="bulMsgShow" runat="server" />
            <script runat="server">public override void ErrorMsgShow() { ErrorMsgHelper(bulMsgShow); }</script>
            <div class="con">
                <div class="card">查询</div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td width="15%">
                                <div align="right">
                                    开始日期:</div>
                            </td>
                            <td width="15%">
                               <asp:TextBox runat="server" ID="txtFromDate" MaxLength="8" CssClass="input"></asp:TextBox>
                                <ajaxToolkit:CalendarExtender ID="FCalendar1" runat="server" TargetControlID="txtFromDate"
                                    Format="yyyyMMdd" />
                            </td>
                            <td width="15%">
                                <div align="right">
                                    结束日期:</div>
                            </td>
                            <td width="15%">
                                 <asp:TextBox runat="server" ID="txtToDate" MaxLength="8" CssClass="input"></asp:TextBox>
                                <ajaxToolkit:CalendarExtender ID="FCalendar2" runat="server" TargetControlID="txtToDate"
                                    Format="yyyyMMdd" />
                            </td>
                            <td width="15%">
                                <div align="right">
                                    审核状态:</div>
                            </td>
                            <td width="15%">
                                <asp:DropDownList ID="selExamState" CssClass="input" runat="server">
                                    <asp:ListItem Text="1: 审核通过" Value="1"></asp:ListItem>
                                    <asp:ListItem Text="3: 部分领用" Value="3"></asp:ListItem>
                                    <asp:ListItem Text="4: 完成领用" Value="4"></asp:ListItem>
                                </asp:DropDownList>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    接收部门:</div>
                            </td>
                            <td>
                                <asp:DropDownList ID="selDept" CssClass="input" runat="server" AutoPostBack="true"
                                    OnSelectedIndexChanged="selDept_Changed">
                                </asp:DropDownList>
                            </td>
                            <td>
                                <div align="right">
                                    接收员工:</div>
                            </td>
                            <td>
                                 <asp:DropDownList ID="selStaff" CssClass="input" runat="server">
                                </asp:DropDownList>
                            </td>
                            <td colspan="2">
                               
                            </td>
                            <td align="right">
                                <asp:Button ID="btnQuery" CssClass="button1" runat="server" Text="查询" OnClick="btnQuery_Click" />
                            </td>
                        </tr>
                    </table>
                </div>
                <div class="jieguo">
                    查询结果</div>
                <div class="kuang5">
                    <div id="gvUseCard" style="height: 130px; overflow: auto; display: block">
                        <asp:GridView ID="gvResult" runat="server" Width="150%" CssClass="tab1" HeaderStyle-CssClass="tabbt"
                            FooterStyle-CssClass="tabcon" AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel"
                            PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top"
                            AutoGenerateColumns="false"     OnRowDataBound="gvResultResourceDistribution_RowDataBound" >
                            <Columns>
                                <asp:BoundField DataField="GETORDERID" HeaderText="领用单号" />
                                <asp:BoundField DataField="STATE" HeaderText="领用状态" />
                                <asp:BoundField DataField="RESUOURCETYPE" HeaderText="资源类型" />
                                <asp:BoundField DataField="RESOURCENAME" HeaderText="资源名称" />
                                <asp:BoundField HeaderText="资源属性" />
                                <asp:BoundField DataField="AGREEGETNUM" HeaderText="派发数量" />
                                <asp:BoundField DataField="ORDERTIME" HeaderText="派发时间" />
                                <asp:BoundField DataField="STAFFNAME" HeaderText="接收员工" />
                                <asp:BoundField DataField="DEPARTNAME" HeaderText="接收部门" />
                                <asp:BoundField DataField="USEWAY" HeaderText="用途" />
                                <asp:BoundField DataField="REMARK" HeaderText="备注" />
                                <asp:BoundField DataField="BATTRIBUTE1"  />
                                <asp:BoundField DataField="AATTRIBUTE1"  />
                                <asp:BoundField DataField="BATTRIBUTE2"  />
                                <asp:BoundField DataField="AATTRIBUTE2"  />
                                <asp:BoundField DataField="BATTRIBUTE3"  />
                                <asp:BoundField DataField="AATTRIBUTE3"  />
                                <asp:BoundField DataField="BATTRIBUTE4"  />
                                <asp:BoundField DataField="AATTRIBUTE4"  />
                                <asp:BoundField DataField="BATTRIBUTE5"  />
                                <asp:BoundField DataField="AATTRIBUTE5"  />
                                <asp:BoundField DataField="BATTRIBUTE6"  />
                                <asp:BoundField DataField="AATTRIBUTE6"  />
                            </Columns>
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                        <td>
                                            领用单号
                                        </td>
                                        <td>
                                            领用状态
                                        </td>
                                        <td>
                                            资源类型
                                        </td>
                                        <td>
                                            资源名称
                                        </td>
                                        <td>
                                            资源属性
                                        </td> 
                                        <td>
                                            派发数量
                                        </td>              
                                        <td>
                                            派发时间
                                        </td>
                                        <td>
                                            接收员工
                                        </td>
                                        <td>
                                            接收部门
                                        </td>
                                        <td>
                                            用途
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
                   <div class="card">
                    订购单信息填写</div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td width="12%">
                            </td>
                            <td width="12%">
                            </td>
                            <td width="12%">
                            </td>
                            <td width="12%">
                            </td>
                            <td width="12%">
                            </td>
                            <td width="12%">
                            </td>
                            <td width="12%">
                            </td>
                            <td width="12%">
                            </td>
                        </tr>
                        <tr id="supplyUseCard" style="display: block">
                            <td width="12%">
                                <div align="right">
                                    资源类型:</div>
                            </td>
                            <td width="36%" colspan="3">
                                <asp:DropDownList ID="ddlResourceType" CssClass="inputmid" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlChangeResourceType_change">
                                </asp:DropDownList>
                                <span class="red">*</span>
                            </td>
                            <td width="12%">
                                <div align="right">
                                    资源名称:</div>
                            </td>
                            <td width="36%" colspan="3">
                                <asp:DropDownList ID="ddlResource" CssClass="inputmid" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlChangeResource_change" Enabled="false">
                                </asp:DropDownList>
                                <span class="red">*</span>
                            </td>
                        </tr>
                        <tr>
                            <td width="12%">
                                <div align="right">
                                    接收部门:</div>
                            </td>
                            <td colspan="3" width="36%">
                                <asp:DropDownList ID="ddlDepartment" runat="server" AutoPostBack="true" 
                                    CssClass="inputmid" OnSelectedIndexChanged="ddlDepartment_change">
                                </asp:DropDownList>
                                <span class="red">*</span>
                            </td>
                            <td width="12%">
                                <div align="right">
                                    接收员工:</div>
                            </td>
                            <td colspan="3" width="36%">
                                <asp:DropDownList ID="ddlStaff" runat="server"  Enabled="false"
                                    CssClass="inputmid" >
                                </asp:DropDownList>
                                <span class="red">*</span>
                            </td>
                            <tr>
                                <td>
                                    <div align="right">
                                        派发数量:</div>
                                </td>
                                <td colspan="7">
                                    <asp:TextBox ID="txtApplyNum" runat="server" CssClass="input" ></asp:TextBox>
                                    <span class="red">*</span>
                                </td>
                            </tr>
                            <tr>
                                <div>
                                    <asp:Panel ID="divAttribute1" runat="server">
                                        <td align="right" width="12%">
                                            <asp:Label ID="lblAttribute1Name" runat="server" style="width:12% " />
                                            <asp:HiddenField ID="hideISNULL1" runat="server" />
                                        </td>
                                        <td colspan="3" width="36%">
                                            <asp:DropDownList ID="ddlAttribute1" CssClass="inputmid" runat="server"></asp:DropDownList> <span ID="spanAttribute1" class = " red"  visible="false"   runat="server">*</span>
                                            <asp:HiddenField ID="hideSelectIndex1" runat="server" />
                                        </td>
                                    </asp:Panel>
                                </div>
                                <div>
                                    <asp:Panel ID="divAttribute2" runat="server">
                                        <td align="right" width="12%">
                                            <asp:Label ID="lblAttribute2Name" runat="server" style="width:12%" />
                                            <asp:HiddenField ID="hideISNULL2" runat="server" />
                                        </td>
                                        <td colspan="3" width="36%">
                                            <asp:DropDownList ID="ddlAttribute2" CssClass="inputmid" runat="server"></asp:DropDownList> <span ID="span1" class = " red"  visible="false"   runat="server">*</span>
                                            <asp:HiddenField ID="hideSelectIndex2" runat="server" />
                                        </td>
                                    </asp:Panel>
                                </div>
                            </tr>
                            <tr>
                                <div>
                                    <asp:Panel ID="divAttribute3" runat="server">
                                        <td align="right" width="12%">
                                            <asp:Label ID="lblAttribute3Name" runat="server" style="width:12%" />
                                            <asp:HiddenField ID="hideISNULL3" runat="server" />
                                        </td>
                                        <td colspan="3" width="36%"> 
                                            <asp:DropDownList ID="ddlAttribute3" CssClass="inputmid" runat="server"></asp:DropDownList> <span ID="span2" class = " red"  visible="false"   runat="server">*</span>
                                            <asp:HiddenField ID="hideSelectIndex3" runat="server" />
                                        </td>
                                    </asp:Panel>
                                </div>
                                <div>
                                    <asp:Panel ID="divAttribute4" runat="server">
                                        <td align="right" width="12%">
                                            <asp:Label ID="lblAttribute4Name" runat="server" style="width:12%" />
                                            <asp:HiddenField ID="hideISNULL4" runat="server" />
                                        </td>
                                        <td colspan="3" width="36%">
                                           <asp:DropDownList ID="ddlAttribute4" CssClass="inputmid" runat="server"></asp:DropDownList> <span ID="span3" class = " red"  visible="false"   runat="server">*</span>
                                           <asp:HiddenField ID="hideSelectIndex4" runat="server" />
                                        </td>
                                    </asp:Panel>
                                </div>
                            </tr>
                            <tr>
                                <div>
                                    <asp:Panel ID="divAttribute5" runat="server">
                                        <td align="right" width="12%">
                                            <asp:Label ID="lblAttribute5Name" runat="server" style="width:12%" />
                                            <asp:HiddenField ID="hideISNULL5" runat="server" />
                                        </td>
                                        <td colspan="3" width="36%">
                                            <asp:DropDownList ID="ddlAttribute5" CssClass="inputmid" runat="server"></asp:DropDownList> <span ID="span4" class = " red"  visible="false"   runat="server">*</span>
                                            <asp:HiddenField ID="hideSelectIndex5" runat="server" />
                                        </td>
                                    </asp:Panel>
                                </div>
                                <div>
                                    <asp:Panel ID="divAttribute6" runat="server">
                                        <td align="right" width="12%">
                                            <asp:Label ID="lblAttribute6Name" runat="server" style="width:12%" />
                                            <asp:HiddenField ID="hideISNULL6" runat="server" />
                                        </td>
                                        <td colspan="3" width="36%">
                                            <asp:DropDownList ID="ddlAttribute6" CssClass="inputmid" runat="server"></asp:DropDownList> <span ID="span5" class = " red"  visible="false"   runat="server">*</span>
                                            <asp:HiddenField ID="hideSelectIndex6" runat="server" />
                                        </td>
                                    </asp:Panel>
                                </div>
                            </tr>
                            <tr>
                                <td>
                                    <div align="right">
                                        用途:</div>
                                </td>
                                <td colspan="3">
                                    <asp:TextBox ID="txtUseWay" runat="server" CssClass="inputlong" 
                                        TextMode="MultiLine"></asp:TextBox> <span class="red">*</span>
                                </td>
                                <td>
                                    <div align="right">
                                        备注:</div>
                                </td>
                                <td colspan="3">
                                    <asp:TextBox ID="txtRemark" runat="server" CssClass="inputlong" 
                                        TextMode="MultiLine"></asp:TextBox>
                                </td>
                            </tr>
                        </tr>
                    </table>
                </div>
            </div>
            <div class="footall">
            </div>
            <div class="btns">
                <table width="200" border="0" align="right" cellpadding="0" cellspacing="0">
                    <tr>
                        <td>
                            <asp:Button ID="btnSubmit" runat="server" Text="派发" CssClass="button1" Enabled="true"
                                OnClick="btnSubmit_Click" />
                        </td>
                    </tr>
                </table>
            </div>
            <div style="display:none" runat="server" id="printarea"></div>
        </ContentTemplate>
    </asp:UpdatePanel>
    </form>
</body>
</html>

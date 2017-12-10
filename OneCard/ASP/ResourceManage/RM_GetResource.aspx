<%@ Page Language="C#" AutoEventWireup="true" CodeFile="RM_GetResource.aspx.cs" Inherits="ASP_ResourceManage_RM_GetResource" 
EnableEventValidation="false"%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>资源领用</title>
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
        其他资源管理->资源领用
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
                                    领用单号:</div>
                            </td>
                            <td width="15%">
                               <asp:TextBox runat="server" ID="txtGetResourceOrderId"  CssClass="input"></asp:TextBox>
                            </td>
                            <td width="15%">
                                <div align="right">
                                    开始日期:</div>
                            </td>
                            <td width="15%">
                                 <asp:TextBox runat="server" ID="txtFromDate" MaxLength="8" CssClass="input"></asp:TextBox>
                                <ajaxToolkit:CalendarExtender ID="FCalendar2" runat="server" TargetControlID="txtFromDate"
                                    Format="yyyyMMdd" />
                            </td>
                            <td width="15%">
                                <div align="right">
                                    结束日期:</div>
                            </td>
                            <td width="15%">
                                <asp:TextBox runat="server" ID="txtToDate" MaxLength="8" CssClass="input"></asp:TextBox>
                                <ajaxToolkit:CalendarExtender ID="CalendarExtender1" runat="server" TargetControlID="txtToDate"
                                    Format="yyyyMMdd" />
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    领用员工:</div>
                            </td>
                            <td>
                                <asp:DropDownList ID="selStaff" CssClass="input" runat="server" >
                                </asp:DropDownList>
                            </td>
                            <td>
                                <div align="right">
                                    领用状态:</div>
                            </td>
                            <td>
                                 <asp:DropDownList ID="selExamState" CssClass="input" runat="server">
                                 <asp:ListItem Text="---请选择---" Value="" Selected="True"></asp:ListItem>
                                    <asp:ListItem Text="0: 待审核" Value="0" ></asp:ListItem>
                                    <asp:ListItem Text="1: 审核通过" Value="1"></asp:ListItem>
                                    <asp:ListItem Text="2: 审核作废" Value="2"></asp:ListItem>
                                    <asp:ListItem Text="3: 部分领用" Value="3"></asp:ListItem>
                                    <asp:ListItem Text="4: 完成领用" Value="4"></asp:ListItem>
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
                <asp:HiddenField ID="hideResourceCode" runat="server" />
                <asp:HiddenField ID="hideGetOrderId" runat="server" />
                <asp:HiddenField ID="HiddenField1" runat="server" />
                <asp:HiddenField ID="HiddenField2" runat="server" />
                <asp:HiddenField ID="HiddenField3" runat="server" />
                <asp:HiddenField ID="HiddenField4" runat="server" />
                <asp:HiddenField ID="HiddenField5" runat="server" />
                <asp:HiddenField ID="HiddenField6" runat="server" />
                    <div id="gvUseCard" style="height: 130px; overflow: auto; display: block">
                       <asp:GridView ID="gvResult" runat="server" Width="150%" CssClass="tab1" HeaderStyle-CssClass="tabbt"
                            FooterStyle-CssClass="tabcon" AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel"
                            PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top"
                            AutoGenerateColumns="false" OnSelectedIndexChanged="gvResult_SelectedIndexChanged" 
                            OnRowDataBound ="gvResult_RowDataBound"  OnRowCreated="gvResult_RowCreated" >
                            <Columns>
                                <asp:BoundField DataField="GETORDERID" HeaderText="领用单号" />
                                <asp:BoundField DataField="STATE" HeaderText="领用状态" />
                                <asp:BoundField DataField="RESUOURCETYPE" HeaderText="资源类型" />
                                <asp:BoundField DataField="RESOURCENAME" HeaderText="资源名称" />
                                <asp:BoundField DataField="RESOURCECODE" HeaderText="资源编码" />
                                <asp:BoundField HeaderText="资源属性" />
                                <asp:BoundField DataField="APPLYGETNUM" HeaderText="申请领用数量" />
                                <asp:BoundField DataField="AGREEGETNUM" HeaderText="同意领用数量" />
                                <asp:BoundField DataField="ALREADYGETNUM" HeaderText="已领用数量" />
                                <asp:BoundField DataField="ORDERTIME" HeaderText="申请时间" />
                                <asp:BoundField DataField="STAFFNAME" HeaderText="申请员工" />
                                <asp:BoundField DataField="DEPARTNAME" HeaderText="申请部门" />
                                <asp:BoundField DataField="USEWAY" HeaderText="用途" />
                                <asp:BoundField DataField="REMARK" HeaderText="备注" />
                                <asp:BoundField DataField="ATTRIBUTE1"  />
                                <asp:BoundField DataField="ATTRIBUTE1VALUE"  />
                                <asp:BoundField DataField="ATTRIBUTE2"  />
                                <asp:BoundField DataField="ATTRIBUTE2VALUE"  />
                                <asp:BoundField DataField="ATTRIBUTE3"  />
                                <asp:BoundField DataField="ATTRIBUTE3VALUE"  />
                                <asp:BoundField DataField="ATTRIBUTE4"  />
                                <asp:BoundField DataField="ATTRIBUTE4VALUE"  />
                                <asp:BoundField DataField="ATTRIBUTE5"  />
                                <asp:BoundField DataField="ATTRIBUTE5VALUE"  />
                                <asp:BoundField DataField="ATTRIBUTE6"  />
                                <asp:BoundField DataField="ATTRIBUTE6VALUE"  />
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
                                            资源编码
                                        </td>
                                        <td>
                                            资源属性
                                        </td>
                                        <td>
                                            申请领用数量
                                        </td>
                                        <td>
                                            同意领用数量
                                        </td>
                                        <td>
                                            已领用数量
                                        </td>
                                        <td>
                                            申请时间
                                        </td>
                                        <td>
                                            申请员工
                                        </td>
                                        <td>
                                            申请部门
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
                    出库信息</div>
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
                                <asp:Label ID="txtResourceType"  runat="server">
                                </asp:Label>
                                
                            </td>
                            <td width="12%">
                                <div align="right">
                                    资源名称:</div>
                            </td>
                            <td width="36%" colspan="3">
                                <asp:Label ID="txtResourceName"  runat="server">
                                </asp:Label>
                            </td>
                        </tr>
                        <tr>
                        <td width="12%">
                                <div align="right">
                                    领用状态:</div>
                            </td>
                            <td width="36%" colspan="3">
                                <asp:Label ID="txtState"  runat="server">
                                </asp:Label>
                                
                            </td>
                            <td width="12%">
                                <div align="right">
                                    申请领用数量:</div>
                            </td>
                            <td width="36%" colspan="3">
                                <asp:Label ID="txtApplyNum"  runat="server">
                                </asp:Label>      
                            </td>
                             
                        </tr>
                        <tr>
                         <td width="12%">
                                <div align="right">
                                    同意领用数量:</div>
                            </td>
                            <td width="36%" colspan="3">
                                <asp:Label ID="txtAgreeNum"  runat="server">
                                </asp:Label>      
                            </td>
                            <td width="12%">
                                <div align="right">
                                    已领用数量:</div>
                            </td>
                            <td width="36%" colspan="3">
                                <asp:Label ID="txtAlreadyGetNum"  runat="server">
                                </asp:Label>      
                            </td>
                        </tr> 
                        <tr>
                            <td>
                                <div align="right">
                                    出库数量:</div>
                            </td>
                            <td colspan="3">
                                <asp:TextBox ID="txtStockOutNum" CssClass="input" runat="server" ></asp:TextBox> <span class="red">*</span>
                               
                            </td>
                            <td>
                                <div align="right">
                                    领用员工:</div>
                            </td>
                            <td colspan="3">
                                <asp:DropDownList ID="ddlStaff" CssClass="input" runat="server" >
                                </asp:DropDownList> <span  class = " red"  runat="server">*</span>
                            </td>
                        </tr>
                        <tr >
                        
                        <div >
                        <asp:Panel  ID= "divAttribute1" runat="server">
                            <td width="12%" align="right">
                                <asp:Label runat="server" ID="lblAttribute1Name" style="width:12% " />
                                <asp:HiddenField ID="hideISNULL1" runat="server" />
                            </td>
                            <td width="24%" colspan="2">
                                <asp:TextBox ID="txtAttribute1" CssClass="input"  runat="server"></asp:TextBox> <span ID="spanAttribute1"  class = " red"  visible="false" runat="server">*</span>
                            </td>
                            <td width="12%" align="left">
                                <asp:LinkButton ID="btnChangeStyle1" runat="server" Text="号段" Enabled="true"
                                OnClick="btnChangeStyle_Click" CommandArgument="1" ForeColor="#3333FF" />
                            </td>              
                            </asp:Panel>
                            <asp:Panel  ID= "divChangedAttribute1" runat="server"   >
                            <td width="12%" align="right">
                                <asp:Label runat="server" ID="lblChangedAttribute1Name" style="width:12% " />
                                <asp:HiddenField ID="hideChangedISNULL1" runat="server" />
                            </td>
                            <td width="30%" colspan="2">
                                <asp:TextBox ID="txtChangedAttribute1From" CssClass="input"  runat="server"/> - <asp:TextBox ID="txtChangedAttribute1To" CssClass="input" MaxLength="50" runat="server"/> <span ID="spanChangedAttribute1"  class = " red"  visible="false" runat="server">*</span>
                            </td>
                            <td width="3%" align="left">
                                <asp:LinkButton ID="btnOriginalStyle1" runat="server" Text="字符" Enabled="true"
                                OnClick="btnOriginalStyle_Click" CommandArgument="1" ForeColor="#3333FF" />
                            </td>              
                            </asp:Panel>
                             <asp:HiddenField ID="hideStyle1" runat="server" />
                            </div>
                            <div>
                              <asp:Panel  ID= "divAttribute2" runat="server"  >
                                    <td width="12%" align="right">
                                        <asp:Label ID="lblAttribute2Name" runat="server" style="width:12%" />
                                        <asp:HiddenField ID="hideISNULL2" runat="server" />
                                    </td>
                                    <td width="24%" colspan="2">
                                        <asp:TextBox ID="txtAttribute2" runat="server" CssClass="input" ></asp:TextBox> <span ID="spanAttribute2"  class = " red"  visible="false" runat="server">*</span>
                                    </td>
                                    <td width="12%" align="left">
                                       <asp:LinkButton ID="btnChangeStyle2" runat="server" Text="号段" Enabled="true" 
                                        OnClick="btnChangeStyle_Click" CommandArgument="2" ForeColor="#3333FF" />
                                   </td>   
                                </asp:Panel>
                                <asp:Panel  ID= "divChangedAttribute2" runat="server"  >
                                    <td width="12%" align="right">
                                        <asp:Label ID="lblChangedAttribute2Name" runat="server" style="width:12%" />
                                        <asp:HiddenField ID="hideChangedISNULL2" runat="server" />
                                    </td>
                                    <td colspan="2" width="36%">
                                        <asp:TextBox ID="txtChangedAttribute2From" CssClass="input"  runat="server"/> - <asp:TextBox ID="txtChangedAttribute2To" CssClass="input" MaxLength="50" runat="server"/> <span ID="spanChangedAttribute2"  class = " red"  visible="false" runat="server">*</span>
                                    </td>
                                    <td width="3%" align="left">
                                     <asp:LinkButton ID="btnOriginalStyle2" runat="server" Text="字符" Enabled="true"
                                     OnClick="btnOriginalStyle_Click" CommandArgument="2" ForeColor="#3333FF" />
                                    </td>   
                                </asp:Panel>
                                <asp:HiddenField ID="hideStyle2" runat="server" />
                            </div>
                        </tr>
                        <tr >
                        <div>
                              <asp:Panel  ID= "divAttribute3" runat="server" >
                            <td width="12%" align="right">
                                <asp:Label runat="server" ID="lblAttribute3Name" style="width:12%"  />
                                <asp:HiddenField ID="hideISNULL3" runat="server" />
                            </td>
                            <td width="24%" colspan="2">
                            <asp:TextBox ID="txtAttribute3" CssClass="input"  runat="server"></asp:TextBox> <span ID="spanAttribute3" class = " red"  visible="false"  runat="server">*</span>
                            </td>
                             <td width="12%" align="left">
                            <asp:LinkButton ID="btnChangeStyle3" runat="server" Text="号段" Enabled="true"                              
                                       OnClick="btnChangeStyle_Click" CommandArgument="3" ForeColor="#3333FF" />
                            </td>
                            </asp:Panel>
                            <asp:Panel  ID= "divChangedAttribute3" runat="server" >
                            <td width="12%" align="right">
                                <asp:Label runat="server" ID="lblChangedAttribute3Name" style="width:12%"  />
                                <asp:HiddenField ID="hideChangedISNULL3" runat="server" />
                            </td>
                            <td width="36%" colspan="2">
                                <asp:TextBox ID="txtChangedAttribute3From" CssClass="input"  runat="server"/> - <asp:TextBox ID="txtChangedAttribute3To" CssClass="input" MaxLength="50" runat="server"/> <span ID="spanChangedAttribute3"  class = " red"  visible="false" runat="server">*</span>
                            </td>
                            <td width="3%" align="left">
                                <asp:LinkButton ID="btnOriginalStyle3" runat="server" Text="字符" Enabled="true"
                                OnClick="btnOriginalStyle_Click" CommandArgument="3" ForeColor="#3333FF" />
                            </td>
                            </asp:Panel>
                            <asp:HiddenField ID="hideStyle3" runat="server" />
                            </div>
                            <div>
                              <asp:Panel  ID= "divAttribute4" runat="server" >
                            <td width="12%" align="right">
                                <asp:Label runat="server" ID="lblAttribute4Name" style="width:12%"  />
                                <asp:HiddenField ID="hideISNULL4" runat="server" />
                            </td>
                            <td width="24%" colspan="2">
                               <asp:TextBox ID="txtAttribute4" CssClass="input"  runat="server"></asp:TextBox> <span ID="spanAttribute4" class = " red"  visible="false"  runat="server">*</span>
                            </td>
                            <td width="12%" align="left">
                              <asp:LinkButton ID="btnChangeStyle4" runat="server" Text="号段" Enabled="true" 
                                        OnClick="btnChangeStyle_Click" CommandArgument="4" ForeColor="#3333FF" />
                             </td>
                             </asp:Panel>
                              <asp:Panel  ID= "divChangedAttribute4" runat="server" >
                            <td width="12%" align="right">
                                <asp:Label runat="server" ID="lblChangedAttribute4Name" style="width:12%"  />
                                <asp:HiddenField ID="hideChangedISNULL4" runat="server" />
                            </td>
                            <td width="36%" colspan="2">
                               <asp:TextBox ID="txtChangedAttribute4From" CssClass="input"  runat="server"/> - <asp:TextBox ID="txtChangedAttribute4To" CssClass="input" MaxLength="50" runat="server"/> <span ID="spanChangedAttribute4"  class = " red"  visible="false" runat="server">*</span>
                            </td>
                             <td width="3%" align="left">
                                     <asp:LinkButton ID="btnOriginalStyle4" runat="server" Text="字符" Enabled="true"
                                     OnClick="btnOriginalStyle_Click" CommandArgument="4" ForeColor="#3333FF" />
                                    </td>
                            </asp:Panel>
                            <asp:HiddenField ID="hideStyle4" runat="server" />
                            </div>
                        </tr>
                        <tr >
                        <div>
                            <asp:Panel  ID= "divAttribute5" runat="server" >
                            <td width="12%" align="right">
                                <asp:Label runat="server" ID="lblAttribute5Name" style="width:12%"  />
                                <asp:HiddenField ID="hideISNULL5" runat="server" />
                            </td>
                            <td width="24%" colspan="2">
                                <asp:TextBox ID="txtAttribute5" CssClass="input"  runat="server"></asp:TextBox> <span ID="spanAttribute5" class = " red"  visible="false"  runat="server">*</span>
                            </td>
                            <td width="12%" align="left">
                              <asp:LinkButton ID="btnChangeStyle5" runat="server" Text="号段" Enabled="true" 
                                        OnClick="btnChangeStyle_Click" CommandArgument="5" ForeColor="#3333FF" />
                             </td>
                            </asp:Panel>
                            <asp:Panel  ID= "divChangedAttribute5" runat="server" >
                             <td width="12%" align="right">
                                <asp:Label runat="server" ID="lblChangedAttribute5Name" style="width:12%"  />
                                <asp:HiddenField ID="hideChangedISNULL5" runat="server" />
                            </td>
                            <td width="36%" colspan="2">
                                <asp:TextBox ID="txtChangedAttribute5From" CssClass="input"  runat="server"/> - <asp:TextBox ID="txtChangedAttribute5To" CssClass="input" MaxLength="50" runat="server"/> <span ID="spanChangedAttribute5"  class = " red"  visible="false" runat="server">*</span>
                            </td>
                            <td width="3%" align="left">
                                <asp:LinkButton ID="btnOriginalStyle5" runat="server" Text="字符" Enabled="true"
                                OnClick="btnOriginalStyle_Click" CommandArgument="5" ForeColor="#3333FF" />
                            </td>
                            </asp:Panel>
                            <asp:HiddenField ID="hideStyle5" runat="server" />
                            </div>
                            <div>
                            <asp:Panel  ID= "divAttribute6" runat="server" >
                            <td width="12%" align="right">
                                <asp:Label runat="server" ID="lblAttribute6Name" style="width:12%"  />
                                <asp:HiddenField ID="hideISNULL6" runat="server" />
                            </td>
                            <td width="24%" colspan="2">
                               <asp:TextBox ID="txtAttribute6" CssClass="input"  runat="server"></asp:TextBox> <span ID="spanAttribute6" class = " red"  visible="false"  runat="server">*</span>
                            </td>
                            <td width="12%" align="left">
                              <asp:LinkButton ID="btnChangeStyle6" runat="server" Text="号段" Enabled="true" 
                                        OnClick="btnChangeStyle_Click" CommandArgument="6" ForeColor="#3333FF" />
                             </td>
                            </asp:Panel>
                              <asp:Panel  ID= "divChangedAttribute6" runat="server" >
                            <td width="12%" align="right">
                                <asp:Label runat="server" ID="lblChangedAttribute6Name" style="width:12%"  />
                                <asp:HiddenField ID="hideChangedISNULL6" runat="server" />
                            </td>
                            <td width="36%" colspan="2">
                               <asp:TextBox ID="txtChangedAttribute6From" CssClass="input" runat="server"/> - <asp:TextBox ID="txtChangedAttribute6To" CssClass="input" MaxLength="50" runat="server"/> <span ID="spanChangedAttribute6"  class = " red"  visible="false" runat="server">*</span>
                            </td>
                            <td width="3%" align="left">
                                     <asp:LinkButton ID="btnOriginalStyle6" runat="server" Text="字符" Enabled="true"
                                     OnClick="btnOriginalStyle_Click" CommandArgument="6" ForeColor="#3333FF" />
                                    </td>
                            </asp:Panel>
                            <asp:HiddenField ID="hideStyle6" runat="server" />
                            </div>
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
                            <asp:Button ID="btnSubmit" runat="server" Text="申请" CssClass="button1" Enabled="true"
                                OnClick="btnSubmit_Click" />
                        </td>
                    </tr>
                </table>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
    </form>
</body>
</html>

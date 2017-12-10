<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PB_RefundNFC.aspx.cs" Inherits="ASP_PersonalBusiness_PB_RefundNFC" 
EnableEventValidation="false"%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>NFC退款</title>
    
     <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="../../js/myext.js"></script>
    <script type="text/javascript" src="../../js/mootools.js"></script>
    <script type="text/javascript" src="../../js/jquery-1.5.min.js"></script>
    <script type="text/javascript" src="../../js/Window.js"></script>
  
</head>
<body>
    <form id="form1" runat="server">
<div class="tb">
个人业务->NFC退款审核

</div>
       <ajaxToolkit:ToolkitScriptManager EnableScriptGlobalization="true" EnableScriptLocalization="true" ID="ScriptManager1" runat="server"/>
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

    <asp:BulletedList ID="bulMsgShow" runat="server"/>
    <script runat="server" >public override void ErrorMsgShow(){ErrorMsgHelper(bulMsgShow);}</script>
<div class="con">
  <div class="base">退款申请查询</div>
  <div class="kuang5">
 <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
  <tr>
    <td width="8%"><div align="right">卡号:</div></td>
     <td width="14%">
        <asp:TextBox ID="txtCardno" CssClass="input" runat="server" MaxLength="16"/>
                            </td>
                           
                            <td width="12%">
                                <div align="right">
                                    审核状态:</div>
                            </td>
                            <td width="12%">
                               <asp:DropDownList ID="selExamState" CssClass="inputmid" runat="server">
                                    <asp:ListItem Text="0: 待审核" Value="0" Selected="True"></asp:ListItem>
                                    <asp:ListItem Text="1: 审核通过" Value="1"></asp:ListItem>
                                    <asp:ListItem Text="2: 审核不通过" Value="2"></asp:ListItem>
                                   
                                    </asp:DropDownList>
                            </td>
                             <td width="12%">
                                <div align="right">
                                    开始日期:</div>
                            </td>
                            <td width="12%">
                                <asp:TextBox runat="server" ID="txtFromDate" MaxLength="8" CssClass="input"></asp:TextBox>
                                <ajaxToolkit:CalendarExtender ID="CalendarExtender1" runat="server" TargetControlID="txtFromDate"
                                    Format="yyyyMMdd" />
                            </td>
                            <td width="12%">
                                <div align="right">
                                    结束日期:</div>
                            </td>
                            <td width="12%">
                                <asp:TextBox runat="server" ID="txtToDate" MaxLength="8" CssClass="input"></asp:TextBox>
                                <ajaxToolkit:CalendarExtender ID="CalendarExtender2" runat="server" TargetControlID="txtToDate"
                                    Format="yyyyMMdd" />
                            </td>
    </td>
    <td>
    </td>
  </tr>
  <tr>
    <td colspan="8" align="right">
                                <asp:Button ID="btnQuery" CssClass="button1" runat="server" Text="查询" OnClick="btnQuery_Click" />
                            </td>
  </tr>
</table>

 </div>
  <div class="jieguo">退款记录</div>
  <div class="kuang5">
<div class="gdtb" style="height: 300px; overflow: auto; display: block">


        <asp:GridView ID="gvResult" CssClass="tab2" HeaderStyle-CssClass="tabbt" FooterStyle-CssClass="tabcon"
                            AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel" PagerSettings-Mode="NumericFirstLast"
                            PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top" runat="server"
                            AutoGenerateColumns="false" Width="100%"
                            AllowPaging="true" PageSize="10" OnPageIndexChanging="gvResult_Page" OnRowCreated="gvResult_RowCreated"
                            OnSelectedIndexChanged="gvResult_SelectedIndexChanged">
           <Columns>
           <asp:TemplateField>
                                                    <HeaderTemplate>
                                                       <asp:CheckBox ID="CheckBox1" runat="server"  AutoPostBack="true" OnCheckedChanged="CheckAll" />
                                                    </HeaderTemplate>
                                                    <ItemTemplate>
                                                        <asp:CheckBox ID="ItemCheckBox" runat="server" />
                                                    </ItemTemplate>
                                                </asp:TemplateField>
            <asp:BoundField HeaderText="充值交易流水" DataField="TRADEID"/>
            <asp:BoundField HeaderText="渠道" DataField="BALUNIT"/>
            <asp:BoundField HeaderText="卡号" DataField="CARDNO"/>               
            <asp:BoundField HeaderText="应用序列号" DataField="ASN"/>
            <asp:BoundField HeaderText="交易序号" DataField="CARDTRADENO"/>
            <asp:BoundField HeaderText="交易前金额" DataField="CARDOLDBAL"/>
            <asp:BoundField HeaderText="交易金额" DataField="TRADEMONEY"/>
            <asp:BoundField HeaderText="交易时间" DataField="TRADEDATE"/>
            <asp:BoundField HeaderText="用户名" DataField="CUSTNAME"/>
            <asp:BoundField HeaderText="手机号" DataField="CUSTPHONE"/>
            <asp:BoundField HeaderText="备注" DataField="REMARK"/>
           </Columns>           
            <EmptyDataTemplate>
                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                  <tr class="tabbt">
                   <td>
                      <input type="checkbox" />
                    </td>
                    <td>充值交易流水</td>
                    <td>渠道</td>
                    <td>卡号</td>
                    <td>应用序列号</td>
                    <td>交易序号</td>
                    <td>交易前金额</td>
                    <td>交易金额</td>
                    <td>交易时间</td>
                    <td>用户名</td>
                    <td>手机号</td>
                    <td>备注</td>
                  </tr>
                  </table>
            </EmptyDataTemplate>
        </asp:GridView>
  </div>
  </div>
  <div class="jieguo">交易记录</div>
  <div class="kuang5">

         <asp:GridView ID="lvwQuery" runat="server"
                    Width = "95%"
                    CssClass="tab1"
                    HeaderStyle-CssClass="tabbt"
                    AlternatingRowStyle-CssClass="tabjg"
                    SelectedRowStyle-CssClass="tabsel"
                    PagerSettings-Mode="NumericFirstLast"
                    PageSize="200"
                    AllowPaging="True"
                    OnPageIndexChanging="lvwQuery_Page"
                    PagerStyle-HorizontalAlign="left"
                    PagerStyle-VerticalAlign="Top"
                    AutoGenerateColumns="true"
                    OnRowDataBound="lvwQuery_RowDataBound"
                    EmptyDataText="没有数据记录!" >
    </asp:GridView>
 
  </div>
</div>
<div class="btns">
<table width="95%" border="0"cellpadding="0" cellspacing="0">
  <tr>
    <td width="60%">&nbsp;</td>
    <td align="right"><asp:CheckBox ID="chkApprove" AutoPostBack="true" Text="允许退款" runat="server" OnCheckedChanged="chkApprove_CheckedChanged" /></td>
    <td align="right"><asp:CheckBox ID="chkReject" AutoPostBack="true" Text="不允许退款" runat="server" OnCheckedChanged="chkReject_CheckedChanged" /></td>
    <td align="right"><asp:Button ID="btnSubmit" Enabled="false" CssClass="button1" runat="server" Text="提交" OnClick="btnSubmit_Click"/></td>
  </tr>
</table>

</div>

            </ContentTemplate>
              
        </asp:UpdatePanel>

    </form>
</body>
</html>

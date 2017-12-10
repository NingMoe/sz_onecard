<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PB_RefundAPP.aspx.cs" Inherits="ASP_PersonalBusiness_PB_RefundAPP" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>充值补登退款</title>
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
个人业务->充值补登退款

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
  <div class="base">查询</div>
  <div class="kuang5">
 <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
  <tr>
    <td width="8%"><div align="right">卡号:</div></td>
     <td width="14%">
        <asp:TextBox ID="txtCardno" CssClass="input" runat="server" MaxLength="16"/>
                            </td>
                           
                            <%--<td width="12%">
                                <div align="right">
                                    订单状态:</div>
                            </td>
                            <td width="12%">
                               <asp:DropDownList ID="selState" CssClass="inputmid" runat="server">
                                    <asp:ListItem Text="0: 未使用" Value="0" Selected="True"></asp:ListItem>
                                    <asp:ListItem Text="1: 已使用" Value="1"></asp:ListItem>
                                    </asp:DropDownList>
                            </td>--%>
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
                            AllowPaging="true" PageSize="20" OnPageIndexChanging="gvResult_Page" 
                            >
           <Columns>
           <asp:TemplateField>
                                                    <HeaderTemplate>
                                                       <asp:CheckBox ID="CheckBox1" runat="server"  AutoPostBack="true" OnCheckedChanged="CheckAll" />
                                                    </HeaderTemplate>
                                                    <ItemTemplate>
                                                        <asp:CheckBox ID="ItemCheckBox" runat="server" />
                                                    </ItemTemplate>
                                                </asp:TemplateField>
            <asp:BoundField HeaderText="订单流水" DataField="TRADEID"/>
             <asp:BoundField HeaderText="卡号" DataField="CARDNO"/> 
            <asp:BoundField HeaderText="渠道" DataField="CHANNELNO"/>               
            <asp:BoundField HeaderText="交易金额" DataField="TRADEMONEY"/>
            <asp:BoundField HeaderText="交易方式" DataField="PAYMENTTYPE"/>
            <asp:BoundField HeaderText="账户号" DataField="ACCOUNTNO"/>
            <%--<asp:BoundField HeaderText="交易流水" DataField="PAYMENTTRADEID"/>--%>
            <asp:BoundField HeaderText="交易时间" DataField="TRADETIME"/>
            <asp:BoundField HeaderText="手机号" DataField="PHONE"/>
       <%--     <asp:BoundField HeaderText="订单状态" DataField="ORDERSTATUS"/>--%>
            <asp:BoundField HeaderText="入库时间" DataField="INLISTTIME"/>
            <asp:BoundField HeaderText="是否退款" DataField="ISREFUND"/>
            <asp:BoundField HeaderText="退款时间" DataField="REFUNDTIME"/>
            <asp:BoundField HeaderText="退款员工" DataField="STAFFNAME"/>
           </Columns>           
            <EmptyDataTemplate>
                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                  <tr class="tabbt">
                   <td>
                      <input type="checkbox" />
                    </td>
                    <td>订单流水</td>
                    <td>卡号</td>
                    <td>渠道</td>  
                    <td>交易金额</td>
                    <td>交易方式</td>
                    <td>账户号</td>
                    <%--<td>交易流水</td>--%>
                    <td>交易时间</td>
                    <td>手机号</td>
                    <%--<td>订单状态</td>--%>
                    <td>入库时间</td>
                    <td>是否退款</td>
                    <td>退款时间</td>
                    <td>退款员工</td>
                  </tr>
                  </table>
            </EmptyDataTemplate>
        </asp:GridView>
  </div>
  </div>
  
</div>
<div class="btns">
<table width="95%" border="0"cellpadding="0" cellspacing="0">
  <tr>
    <td width="60%">&nbsp;</td>
   
    <td align="right"><asp:Button ID="btnSubmit" CssClass="button1" runat="server" Text="提交" OnClick="btnSubmit_Click"/></td>
  </tr>
</table>

</div>

            </ContentTemplate>
              
        </asp:UpdatePanel>

    </form>
</body>
</html>

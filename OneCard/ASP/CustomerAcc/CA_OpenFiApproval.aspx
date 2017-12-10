<%@ Page Language="C#" AutoEventWireup="true" CodeFile="CA_OpenFiApproval.aspx.cs" Inherits="ASP_CustomerAcc_CA_OpenFiApproval" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
    <title>专有账户开户财审</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <link  href="../../css/Cust_AS.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="../../js/myext.js"></script>
    <script language="javascript">
        
    </script>
    
</head>
<body>
    <form id="form1" runat="server">
    <table border="0" cellpadding="0" cellspacing="0" width="100%">
             <td class="cust_left"></td>
             <td class="cust_mid">专有账户>开户财务审批</td>
             <td class="cust_right"></td>
     </table>
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
        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
            <ContentTemplate>

    <asp:BulletedList ID="bulMsgShow" runat="server"/>
    <script runat="server" >public override void ErrorMsgShow(){ErrorMsgHelper(bulMsgShow);}</script>
<div class="cust_tabbox">
    	<table border="0" cellpadding="0" cellspacing="0" width="100%">
    	<td class="cust_top1_l"><div class="cust_p3"></div></td>
        <td class="cust_top1_m"><span style="line-height:22px; margin-left:5px; color:#333;">开户信息</span></td>
        <td class="cust_top1_r"></td>
        </table>
        <div class="cust_line1"></div>
        <div class="cust_line2"></div>
        <table width="100%" border="0" cellpadding="0" cellspacing="0">
                   <tr>
                          <td>
                            <div class="gdtb clearCheck" style="height:310px">
                                 <asp:GridView ID="gvResult" runat="server"
                                Width = "100%"
                                CssClass="tab1"
                                HeaderStyle-CssClass="tabbt"
                                AlternatingRowStyle-CssClass="tabjg"
                                SelectedRowStyle-CssClass="tabsel"
                                AllowPaging="True"
                                PageSize="10"
                                PagerSettings-Mode="NumericFirstLast"
                                PagerStyle-HorizontalAlign="left"
                                PagerStyle-VerticalAlign="Top"
                                AutoGenerateColumns="False"
                                OnPageIndexChanging="gvResult_Page">
                                   <Columns>
                                     <asp:TemplateField>
                                        <HeaderTemplate>
                                          <asp:CheckBox ID="CheckBox1" style="clear:both" runat="server"  AutoPostBack="true" OnCheckedChanged="CheckAll" />
                                        </HeaderTemplate>
                                        <ItemTemplate>
                                          <asp:CheckBox ID="ItemCheckBox" runat="server"/>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                       <asp:BoundField HeaderText="批次号" DataField="ID"/>
                                        <asp:BoundField HeaderText="集团客户" DataField="CORPNAME"/>
                                        <asp:BoundField HeaderText="押金总额" DataField="DEPOSITFEE"  NullDisplayText="0" DataFormatString="{0:n}" HtmlEncode="False"/>
                                        <asp:BoundField HeaderText="卡费总额" DataField="CARDCOST"  NullDisplayText="0" DataFormatString="{0:n}" HtmlEncode="False"/>
                                        <asp:BoundField HeaderText="充值总额" DataField="SUPPLYMONEY"  NullDisplayText="0" DataFormatString="{0:n}" HtmlEncode="False"/>
                                        <asp:BoundField HeaderText="全部总额" DataField="TOTALMONEY"  NullDisplayText="0" DataFormatString="{0:n}" HtmlEncode="False"/>
                                        <asp:BoundField HeaderText="开卡数量" DataField="AMOUNT"/>
                                        <asp:BoundField HeaderText="审批时间" DataField="CHECKTIME" DataFormatString="{0:yyyy-MM-dd}" HtmlEncode="False" />
                                        <asp:BoundField HeaderText="审批员工" DataField="STAFFNAME"/>
                                    </Columns>           
                                    <EmptyDataTemplate>
                                        <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                          <tr class="tabbt">
                                            <td><input type="checkbox" /></td>
                                            <td>批次号</td>
                                            <td>集团客户</td>
                                            <td>押金总额</td>
                                            <td>卡费总额</td>
                                            <td>充值总额</td>
                                            <td>全部总额</td>
                                            <td>开户数量</td>
                                            <td>审批时间</td>
                                            <td>审批员工</td>
                                          </tr>
                                          </table>
                                    </EmptyDataTemplate>
                                </asp:GridView>
                          </div>
                        </td>
                   </tr>
        </table>
        
        
        </div>
<div class="cust_tabbox">
    <div class="cust_bottom_bton"><asp:LinkButton ID="btnSubmit" Enabled="false"  runat="server" Text="提交" OnClientClick="return confirm('确认提交?');" OnClick="btnSubmit_Click"/></div>
    <div class="cust_bottom_txt"><asp:CheckBox ID="chkApprove" AutoPostBack="true" Text="通过" runat="server" OnCheckedChanged="chkApprove_CheckedChanged" /></div>
    <div class="cust_bottom_txt"><asp:CheckBox ID="chkReject" AutoPostBack="true" Text="作废" runat="server" OnCheckedChanged="chkReject_CheckedChanged"  /></div>
</div>



            </ContentTemplate>         
        </asp:UpdatePanel>

    </form>
</body>
</html>


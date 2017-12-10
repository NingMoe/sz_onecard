<%@ Page Language="C#" AutoEventWireup="true" CodeFile="CA_OpenApproval.aspx.cs" Inherits="ASP_CustomerAcc_CA_OpenApproval" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
    <title>专有账户开户审批</title>

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
             <td class="cust_mid">专有账户>批量开户审批</td>
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
    <script runat="server">public override void ErrorMsgShow(){ErrorMsgHelper(bulMsgShow);}</script>
    
    <div class="cust_tabbox">
	                <table border="0" cellpadding="0" cellspacing="0" width="100%">
    	                <td class="cust_top1_l"><div class="cust_p7"></div></td>
                        <td class="cust_top1_m"><span style="line-height:22px; margin-left:5px; color:#333;">批量开户审批</span></td>
                        <td class="cust_top1_r"></td>
                    </table>
                    <div class="cust_line1"></div>
                    <div class="cust_line2"></div>
                    <table width="100%" border="0" cellpadding="0" cellspacing="0" class="cust_form">
                      <tr>
                        <th width="10%" >批次号：</th>
                        <td style="width: 400px;">
                            <asp:DropDownList ID="selBatchNo" CssClass="inputmid" runat="server" OnSelectedIndexChanged="selBatchNo_SelectedIndexChanged" AutoPostBack="true" />
                        </td>
                        <td width="17%">    
                                <div class="cust_bton1"><asp:LinkButton runat="server"  ID="btnQuery" Text="查询"
                                onclick="btnQuery_Click" /></div>
                        </td>
                      </tr>
                    </table>
    </div>
    <div class="cust_tabbox">
    	<table border="0" cellpadding="0" cellspacing="0" width="100%">
    	<td class="cust_top1_l"><div class="cust_p3"></div></td>
        <td class="cust_top1_m"><span style="line-height:22px; margin-left:5px; color:#333;">详细信息</span></td>
        <td class="cust_top1_r"></td>
        </table>
        <div class="cust_line1"></div>
        <div class="cust_line2"></div>
            
            <table width="100%" border="0" cellpadding="0" cellspacing="0">
                   <tr>
                          <td>
                                <div style="height:310px">
                                         <asp:GridView ID="gvResult" runat="server"
                                        Width = "100%"
                                        CssClass="tab1"
                                        HeaderStyle-CssClass="tabbt"
                                        AlternatingRowStyle-CssClass="tabjg"
                                        SelectedRowStyle-CssClass="tabsel"
                                        AllowPaging="True"
                                        PageSize="10"
                                        PagerSettings-Mode=NumericFirstLast
                                        PagerStyle-HorizontalAlign=left
                                        PagerStyle-VerticalAlign=Top
                                        AutoGenerateColumns="False"
                                        OnPageIndexChanging="gvResult_Page" OnRowDataBound="gvResult_RowDataBound">
                                           <Columns>
                                               <asp:BoundField HeaderText="卡号" DataField="CARDNO"/>
                                               <asp:BoundField HeaderText="账户类型" DataField="ACCTYPE"/>
                                                <asp:BoundField HeaderText="姓名" DataField="CUSTNAME"/>
                                                <asp:BoundField HeaderText="证件号码" DataField="PAPERNO"/>
                                                <asp:BoundField HeaderText="押金" DataField="DEPOSIT" NullDisplayText="0" DataFormatString="{0:n}" HtmlEncode="False"/>
                                                <asp:BoundField HeaderText="卡费" DataField="CARDFEE" NullDisplayText="0" DataFormatString="{0:n}" HtmlEncode="False"/>
                                                <asp:BoundField HeaderText="充值金额" DataField="CHARGEAMOUNT" NullDisplayText="0" DataFormatString="{0:n}" HtmlEncode="False"/>
                                           </Columns>           
                                            <EmptyDataTemplate>
                                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                                  <tr class="tabbt">
                                                    <td>卡号</td>
                                                    <td>账户类型</td>
                                                    <td>姓名</td>
                                                    <td>证件号码</td>
                                                    <td>押金</td>
                                                    <td>卡费</td>
                                                    <td>充值金额</td>
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
    	<table border="0" cellpadding="0" cellspacing="0" width="100%">
    	<td class="cust_top1_l"><div class="cust_p3"></div></td>
        <td class="cust_top1_m"><span style="line-height:22px; margin-left:5px; color:#333;">汇总</span></td>
        <td class="cust_top1_r"></td>
        </table>
        <div class="cust_line1"></div>
        <div class="cust_line2"></div>
        <table width="100%" border="0" cellpadding="0" cellspacing="0" class="cust_form">
          <tr>
            <th width="10%">集团客户：</th>
            <td width="10%"><asp:Label ID="labCorp" runat="server"></asp:Label></td>
            <th width="10%">押金汇总：</th>
            <td width="10%"><asp:Label ID="labDeposit" runat="server"></asp:Label></td>
            <th width="10%">卡费汇总：</th>
            <td width="10%"><asp:Label ID="labCardFee" runat="server"></asp:Label></td>
            <th width="10%">充值金额汇总：</th>
            <td width="10%"><asp:Label ID="labChargAmount" runat="server"></asp:Label></td>
            <th width="10%">总额：</th>
            <td width="10%"><asp:Label ID="labTotalAmount" runat="server"></asp:Label></td>
          </tr>
        </table>
  </div>
 <div class="cust_tabbox">
    <div class="cust_bottom_bton"><asp:LinkButton ID="btnSubmit" Enabled="false"  runat="server" Text="提交" OnClientClick="return confirm('确认提交?');" OnClick="btnSubmit_Click"/></div>
    <div class="cust_bottom_txt"><asp:CheckBox ID="chkApprove" AutoPostBack="true" Text="通过" runat="server" OnCheckedChanged="chk_CheckedChanged" /></div>
    <div class="cust_bottom_txt"><asp:CheckBox ID="chkReject" AutoPostBack="true" Text="作废" runat="server" OnCheckedChanged="chk_CheckedChanged"  /></div>
 </div>


            </ContentTemplate>         
        </asp:UpdatePanel>

    </form>
</body>
</html>

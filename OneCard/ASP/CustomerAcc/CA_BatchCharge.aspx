<%@ Page Language="C#" AutoEventWireup="true" CodeFile="CA_BatchCharge.aspx.cs" Inherits="ASP_CustomerAcc_CA_BatchCharge" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
    <title>专有账户批量充值</title>

    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />    
    <link  href="../../css/Cust_AS.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="../../js/myext.js"></script>
</head>
<body>
    <form id="form1" runat="server">
    <table border="0" cellpadding="0" cellspacing="0" width="100%">
        <td class="cust_left"></td>
        <td class="cust_mid">专有账户>批量充值</td>
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
        <asp:UpdatePanel ID="UpdatePanel1" UpdateMode="Conditional" runat="server">
            <ContentTemplate>
    <asp:BulletedList ID="bulMsgShow" runat="server"/>
    <script runat="server" >public override void ErrorMsgShow(){ErrorMsgHelper(bulMsgShow);}</script>

<div class="cust_tabbox">
	<table border="0" cellpadding="0" cellspacing="0" width="100%">
    	<td class="cust_top1_l"><div class="cust_p7"></div></td>
        <td class="cust_top1_m"><span style="line-height:22px; margin-left:5px; color:#333;">批量充值</span></td>
        <td class="cust_top1_r"></td>
    </table>
    <div class="cust_line1"></div>
    <div class="cust_line2"></div>
         <table width="100%" border="0" cellpadding="0" cellspacing="0" class="cust_form">
              <tr>
                <th style="width: 8%">账户类型：</th>
                <td style="width: 15%" >
                    <asp:DropDownList ID="ddlAcctType" CssClass="inputmid" runat="server">
                    </asp:DropDownList>
                </td>
                <th>集团客户：</th>
                <td><asp:DropDownList ID="selCorp" CssClass="inputmidder" runat="server"></asp:DropDownList></td>
              </tr>
              <tr>
                  <th width="10%">导入文件：</th>
                  <td colspan=3>
                    <asp:FileUpload ID="FileUpload1" runat="server" style="float:left; height:22px;" CssClass="inputlong" />
                    <div class="cust_bton2 cust_btonSpec"><asp:LinkButton ID="btnUpload"  runat="server" Text="导入" OnClick="btnUpload_Click"/></div>
                  </td>
              </tr>
          </table>
    </div>
    
    <div class="cust_tabbox">
          <table border="0" cellpadding="0" cellspacing="0" width="100%">
            	<td class="cust_top1_l"><div class="cust_p5"></div></td>
        		<td class="cust_top1_m"><span style="line-height:22px; margin-left:5px; color:#333;">充值信息</span></td>
        		<td class="cust_top1_r"></td>  
            </table>
            <div class="cust_line1"></div>
        	<div class="cust_line2"></div>
        	<table width="100%" border="0" cellpadding="0" cellspacing="0">
              <tr>
                <td>
                      <div style="height:310px" class="gdtb">
                             <asp:GridView ID="gvResult" runat="server"
                            Width = "100%"
                            CssClass="tab1"
                            HeaderStyle-CssClass="tabbt"
                            AlternatingRowStyle-CssClass="tabjg"
                            SelectedRowStyle-CssClass="tabsel"
                            AllowPaging="false"
                           
                            PagerSettings-Mode=NumericFirstLast
                            PagerStyle-HorizontalAlign=left
                            PagerStyle-VerticalAlign=Top
                            AutoGenerateColumns="False"
                            OnRowDataBound="gvResult_RowDataBound" 
                            
                            DataKeyNames="F2">
                               <Columns>
                                    <asp:TemplateField HeaderText="校验结果">
                                        <ItemStyle Width="200px" />
                                        <HeaderTemplate>
                                            <asp:CheckBox ID="CheckBox1" style="clear:both" runat="server"  AutoPostBack="true" OnCheckedChanged="CheckAll" />
                                        </HeaderTemplate>
                                        <ItemTemplate>
                                            <asp:CheckBox ID="ItemCheckBox" runat="server" AutoPostBack="true" OnCheckedChanged="Check"/>
                                            <asp:Label runat="server" ID="Label" Text='<%#Eval("F1")%>'></asp:Label>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <%--<asp:BoundField HeaderText="检查结果" DataField="F1"/>--%>
                                   <asp:BoundField HeaderText="卡号" DataField="CardNo"/>
                                   <asp:BoundField HeaderText="姓名" DataField="CUSTNAME"/>
                                   <asp:BoundField HeaderText="证件号码" DataField="PAPER_NO"/>
                                   <asp:BoundField HeaderText="账户类型" DataField="ACCT_TYPE_NO"/>
                                    <asp:BoundField HeaderText="充值金额" DataField="ChargeAmount" NullDisplayText="0"  HtmlEncode="false"/>
                               </Columns>           
                                <EmptyDataTemplate>
                                    <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                      <tr class="tabbt">
                                        <td>卡号</td>
                                        <td>姓名</td>
                                        <td>证件号码</td>
                                        <td>账户类型</td>
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
            	<td class="cust_top1_l"><div class="cust_p5"></div></td>
        		<td class="cust_top1_m"><span style="line-height:22px; margin-left:5px; color:#333;">汇总</span></td>
        		<td class="cust_top1_r"></td>  
            </table>
            <div class="cust_line1"></div>
        	<div class="cust_line2"></div>
        	<table width="100%" border="0" cellpadding="0" cellspacing="0" class="cust_form">
              <tr>
                <th width="10%">帐户数量：</th>
                <td width="10%"><asp:Label ID="labAmount" runat="server"></asp:Label></td>
                <th width="10%">充值总额：</th>
                <td width="10%"><asp:Label ID="labChargeTotal" runat="server"></asp:Label></td>
                <td width="60%" colspan="6">&nbsp;</td>
              </tr>
            </table>
      </div>
  <div class="cust_tabbox">
       <div class="cust_bottom_bton"><asp:LinkButton ID="btnSubmit" Enabled="false" runat="server" Text="提交" OnClientClick="return confirm('确认提交?');" OnClick="btnSubmit_Click"/></div>
  </div>

            </ContentTemplate>
    <Triggers>
    <asp:PostBackTrigger ControlID="btnUpload" />
    </Triggers>            
        </asp:UpdatePanel>

    </form>
</body>
</html>

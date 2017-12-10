<%@ Page Language="C#" AutoEventWireup="true" CodeFile="CA_SpeAdjustAccQuery.aspx.cs" Inherits="ASP_CustomerAcc_CA_SpeAdjustAccQuery" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
    <title>特殊调帐查询</title>
	<link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <link  href="../../css/Cust_AS.css" rel="stylesheet" type="text/css" />
   
</head>
<body>
    <form id="form1" runat="server">
        <table border="0" cellpadding="0" cellspacing="0" width="100%">
            <td class="cust_left"></td>
            <td class="cust_mid">专有账户>特殊调帐查询</td>
            <td class="cust_right"></td>
        </table>
         <ajaxToolkit:ToolkitScriptManager runat="Server" EnableScriptGlobalization="true"
            EnableScriptLocalization="true" ID="ScriptManager2" />
        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
          <ContentTemplate>
         
         <asp:BulletedList ID="bulMsgShow" runat="server"/>
         <script runat="server" >public override void ErrorMsgShow(){ErrorMsgHelper(bulMsgShow);}</script>
         <div class="cust_tabbox">
	        <table border="0" cellpadding="0" cellspacing="0" width="100%">
    	        <td class="cust_top1_l"><div class="cust_p6"></div></td>
                <td class="cust_top1_m"><span style="line-height:22px; margin-left:5px; color:#333;">调账查询</span></td>
                <td class="cust_top1_r"></td>
            </table>
            <div class="cust_line1"></div>
            <div class="cust_line2"></div>
            <table width="100%" border="0" cellpadding="0" cellspacing="0" class="cust_form">
                 <tr>
                   <th>审核状态：</th>
                   <td>
	                  <div >
	                   <asp:DropDownList ID="selChkState" runat="server"  CssClass="input"></asp:DropDownList>
                      </div>
                   </td>
                   <th>录入员工部门：</th>  
                   <td>
                      <div align="left">
                        <asp:DropDownList ID="selInSideDept" runat="Server"  CssClass="inputmidder"
                         OnSelectedIndexChanged="selDept_Changed" AutoPostBack="true"></asp:DropDownList>
                         
                      </div>
                   </td>
                    
                   <th>录入员工：</th>
                   <td>
                      <div align="left">
                        <asp:DropDownList ID="selInStaff" runat="Server" CssClass="input"></asp:DropDownList>
                      </div>
                   </td>
                 
                   <td><div align="right"></div></td>
                   </tr>
                 <tr>
                   <th>录入日期：</th>
                   <td><div >
                     <asp:TextBox ID="txtInDate" runat="server" CssClass="input" MaxLength="8" ></asp:TextBox>
                     <ajaxToolkit:CalendarExtender ID="BeginCalendar" 
                              runat="server" TargetControlID="txtInDate" Format="yyyyMMdd"  PopupPosition="BottomLeft" />
                   </div></td>
                   <th>IC卡号：</th>
                   <td colspan="2">
                     <asp:TextBox ID="txtCardNo" runat="server" CssClass="inputmid" MaxLength="16" ></asp:TextBox>
                     </td>
                   <td width="9%"><div class="cust_bton1"><asp:LinkButton ID="btnQuery" runat="server" Text="查询"  OnClick="btnQuery_Click" /></div></td>
                   <td>&nbsp;</td>
                   </tr>
               </table>
         </div>
         <div class="cust_tabbox">
            <table border="0" cellpadding="0" cellspacing="0" width="100%">
            	<td class="cust_top1_l"><div class="cust_p5"></div></td>
        		<td class="cust_top1_m"><span style="line-height:22px; margin-left:5px; color:#333;">调帐信息</span></td>
        		<td class="cust_top1_r"></td>  
            </table>
            <div class="cust_line1"></div>
        	<div class="cust_line2"></div>
        	<table border="0" cellpadding="0" cellspacing="0" width="100%">
    	        <tr>
    	            <td>
    	                <div id="gdtb" style="height:400px">
                               <asp:GridView ID="gvResult" runat="server"
                                    CssClass="tab1"
                                    Width ="1500"
                                    HeaderStyle-CssClass="tabbt"
                                    AlternatingRowStyle-CssClass="tabjg"
                                    SelectedRowStyle-CssClass="tabsel"
                                    AllowPaging="True"
                                    PageSize="200"
                                    PagerSettings-Mode="NumericFirstLast"
                                    PagerStyle-HorizontalAlign="Left"
                                    PagerStyle-VerticalAlign="Top"
                                    AutoGenerateColumns="true"
                                    OnPageIndexChanging="gvResult_Page"
                                    OnRowDataBound="gvResult_RowDataBound"
                                    EmptyDataText="没有数据记录!" />                   
                         </div>
    	            </td>
    	        </tr>
    	    </table>    
         </div>
        	
       </ContentTemplate>
     </asp:UpdatePanel>
    
    </form>
</body>
</html>


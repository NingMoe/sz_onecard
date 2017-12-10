<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PR_StaffParam.aspx.cs" Inherits="ASP_PrivilegePR_PR_StaffParam" EnableEventValidation="false"%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
<title>系统设置-内部员工参数配置</title>
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
    <ajaxToolkit:ToolkitScriptManager runat="Server" EnableScriptGlobalization="true"
    EnableScriptLocalization="true" ID="ScriptManager2" />
    <asp:UpdatePanel ID="UpdatePanel1" runat="server">
    <ContentTemplate>
<div class="tb">系统设置-&gt;内部员工参数配置</div>
<!-- #include file="../../ErrorMsg.inc" --> 
<div class="con">
 <div class="pip">员工参数配置</div>
 <div class="kuang5">
   <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
     <tr>
     <td width="12%"><div align="right">部门名称:</div></td>
       <td width="30%"><asp:DropDownList ID="selDepartName1" CssClass="inputmid" runat="server" AutoPostBack="true" OnSelectedIndexChanged="selDepartName1_SelectedIndexChanged"> </asp:DropDownList>
       </td>
       <td width="12%"><div align="right">员工姓名:</div></td>
       <td width="20%"><asp:DropDownList ID="selStaffName1" CssClass="inputmid" runat="server" ></asp:DropDownList>
       </td>
       <td width="15%"><asp:Button ID="btnQuery" runat="server" Text="查询" CssClass="button1" OnClick="btnQuery_Click" /></td>
     </tr>
   </table>
 </div>
  <div class="kuang5">
  <div id="gdtb" style="height:270px">
      <asp:GridView ID="lvwStaffParam" runat="server"

        Width = "100%"
        CssClass="tab1"
        HeaderStyle-CssClass="tabbt"
        AlternatingRowStyle-CssClass="tabjg"
        SelectedRowStyle-CssClass="tabsel"
        PagerSettings-Mode=NumericFirstLast
        PagerStyle-HorizontalAlign=left
        PagerStyle-VerticalAlign=Top
        AutoGenerateColumns="False"
        OnPageIndexChanging="lvwStaffParam_Page"
        OnRowCreated="lvwStaffParam_RowCreated"
        OnSelectedIndexChanged="lvwStaffParam_SelectedIndexChanged"
        OnRowDataBound ="lvwStaffParam_RowDataBound"
        >
           <Columns>
             <asp:BoundField HeaderText="部门名称" DataField="DEPARTNAME"/>
             <asp:BoundField HeaderText="员工姓名" DataField="STAFFNAME"/>
             <asp:BoundField DataField="CARDCOSTSTAT"  HeaderText="卡费类型"/>
             <asp:BoundField DataField="CARDCOST"      HeaderText="卡押金默认值" NullDisplayText="0" DataFormatString="{0:n}" HtmlEncode="false" />
             <asp:BoundField DataField="SUPPLEMONEY"   HeaderText="充值默认值" NullDisplayText="0" DataFormatString="{0:n}" HtmlEncode="false" />  
             </Columns>           
            <PagerSettings Mode="NumericFirstLast" />
            <SelectedRowStyle CssClass="tabsel" />
            <PagerStyle HorizontalAlign="Left" VerticalAlign="Top" />
            <HeaderStyle CssClass="tabbt" />
            <AlternatingRowStyle CssClass="tabjg" />
            <EmptyDataTemplate>
                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                  <tr class="tabbt">
                    <td>部门名称</td>
                    <td>员工姓名</td>
                    <td>卡费类型</td>
                    <td>卡押金默认值</td>
                    <td>充值默认值</td>
                  </tr>
                  </table>
            </EmptyDataTemplate>
        </asp:GridView>
  </div>
  </div>
  <div class="kuang5">
   <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
     <tr>
        <td width="10%"><div align="right">部门名称:</div></td>
       <td width="20%"><asp:DropDownList ID="selDepartName2" CssClass="inputmid" runat="server" AutoPostBack="true" OnSelectedIndexChanged="selDepartName2_SelectedIndexChanged"> </asp:DropDownList><span class="red">*</span>
       </td>
       <td width="10%"><div align="right">员工姓名:</div></td>
       <td width="20%"><asp:DropDownList ID="selStaffName2" CssClass="inputmid" runat="server" ></asp:DropDownList><span class="red">*</span>
       </td>
       <td width="10%"><div align="right">卡费类型:</div></td>
       <td width="20%"><asp:DropDownList ID="selCardCostStat" CssClass="inputmid"  runat="server" ></asp:DropDownList><span class="red">*</span>
       </td>
       <td width="10%"><div align="right"></div></td>
     </tr>
     <tr>
        <td width="10%"><div align="right">卡押金默认值:</div></td>
        <td width="20%"><asp:TextBox ID="txtCardCost" runat="server" CssClass="inputmid" MaxLength="40" Width="145px" ></asp:TextBox>元</td>
        <td width="10%"><div align="right">充值默认值:</div></td>
        <td width="20%"><asp:TextBox ID="txtSuppleMoney" runat="server" CssClass="inputmid" MaxLength="40" Width="145px" ></asp:TextBox>元        </td>
       <td width="10%"></td>
       <td width="20%"></td>
       <td width="10%"></td>
     </tr>
     <tr>
       <td><div align="right"></div></td>
       <td>&nbsp;</td>
       <td colspan="4">
           <table width="300" border="0" align="right" cellpadding="0" cellspacing="0">
             <tr>
               <td><asp:Button ID="btnStaffParaAdd" runat="server" Text="增加" CssClass="button1" OnClick="btnStaffParaAdd_Click" /></td>
               <td><asp:Button ID="btnStaffParaModify" runat="server" Text="修改" CssClass="button1" OnClick="btnStaffParaModify_Click" /></td>
               <td><asp:Button ID="btnStaffParaDelete" runat="server" Text="删除" CssClass="button1" OnClick="btnStaffParaDelete_Click" /></td>
             </tr>
           </table>
       </td>
      </tr>
   </table>
 </div>
   </div>
   
 </ContentTemplate>
</asp:UpdatePanel>
     </form>
</body>
</html>
<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PR_StaffLoginConfig.aspx.cs" Inherits="ASP_PrivilegePR_PR_StaffLoginConfig"EnableEventValidation="false" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
<title>系统设置-内部员工登陆限制</title>
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
    <ajaxToolkit:ToolkitScriptManager runat="Server" EnableScriptGlobalization="true"
    EnableScriptLocalization="true" ID="ScriptManager2" />
    <asp:UpdatePanel ID="UpdatePanel1" runat="server">
    <ContentTemplate>
    <div class="tb">系统设置-&gt;内部员工登陆限制</div>
     <!-- #include file="../../ErrorMsg.inc" --> 
<div class="con">
 <div class="pip">内部员工登陆限制</div>
 <div class="kuang5">
   <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
     <tr>
       <td width="12%"><div align="right">部门名称:</div></td>
       <td width="23%"><asp:DropDownList ID="selDepartName" CssClass="inputmid" runat="server" 
        AutoPostBack="true" OnSelectedIndexChanged="selDepartName_SelectedIndexChanged1"></asp:DropDownList>
       </td>
       <td width="9%"><div align="right">员工姓名:</div></td>
       <td width="20%"><asp:DropDownList ID="selStaffName" CssClass="inputmid" runat="server"></asp:DropDownList>
       </td>
       <td width="15%"><asp:Button ID="btnQuery" runat="server" Text="查询" CssClass="button1" OnClick="btnQuery_Click" /></td>
     </tr>
   </table>
 </div>
  <div class="kuang5">
  <div id="gdtb" style="height:310px">
  <table width="800" border="0" cellpadding="0" cellspacing="0" class="tab1">
      <asp:GridView ID="lvwStaffLoginConfig" runat="server"

        Width = "100%"
        CssClass="tab1"
        AllowPaging=true
        PageSize = 10
        HeaderStyle-CssClass="tabbt"
        AlternatingRowStyle-CssClass="tabjg"
        SelectedRowStyle-CssClass="tabsel"
        PagerSettings-Mode=NumericFirstLast
        PagerStyle-HorizontalAlign=left
        PagerStyle-VerticalAlign=Top
        AutoGenerateColumns="False"
        OnRowCreated="lvwStaffLoginConfig_RowCreated"
        OnSelectedIndexChanged="lvwStaffLoginConfig_SelectedIndexChanged"
        OnPageIndexChanging="lvwStaffLoginConfig_Page"
        >
           <Columns>
             <asp:TemplateField HeaderText="有效标志">
                       <ItemTemplate>
                         <asp:Label ID="labValidTag" Text='<%# Eval("VALIDTAG").ToString() == "0" ? "无效" : "有效" %>' runat="server"></asp:Label>
                       </ItemTemplate>
                      </asp:TemplateField>
             <asp:BoundField HeaderText="部门名称" DataField="DEPARTNAME"/>
             <asp:BoundField HeaderText="员工姓名" DataField="STAFFNAME"/>
             <asp:BoundField HeaderText="允许登录的IP地址" DataField="IPADDR"/>
             <asp:BoundField HeaderText="允许登录的起始日期" DataField="STARTDATE"/>
             <asp:BoundField HeaderText="允许登录的终止日期" DataField="ENDDATE"/>
             <asp:BoundField HeaderText="允许登录的起始时间" DataField="STARTTIME"/>
             <asp:BoundField HeaderText="允许登录的终止时间" DataField="ENDTIME"/>
            </Columns>           
            <PagerSettings Mode="NumericFirstLast" />
            <SelectedRowStyle CssClass="tabsel" />
            <PagerStyle HorizontalAlign="Left" VerticalAlign="Top" />
            <HeaderStyle CssClass="tabbt" />
            <AlternatingRowStyle CssClass="tabjg" />
            <EmptyDataTemplate>
                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                  <tr class="tabbt">
                    <td>有效标志</td>
                    <td>部门名称</td>
                    <td>员工姓名</td>
                    <td>允许登录的IP地址</td>
                    <td>允许登录的起始日期</td>
                    <td>允许登录的终止日期</td>
                    <td>允许登录的起始时间</td>
                    <td>允许登录的终止时间</td>
                  </tr>
                  </table>
            </EmptyDataTemplate>
        </asp:GridView>
    </table>
  </div>
  </div>
  <div class="kuang5">
   <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
     <tr>
       <td width="8%"><div align="right">部门名称:</div></td>
       <td width="18%"><asp:DropDownList ID="selDepartName1" CssClass="inputmid" runat="server" AutoPostBack="true" OnSelectedIndexChanged="selDepartName1_SelectedIndexChanged1"></asp:DropDownList><span class="red">*</span>
       </td>
       <td width="8%"><div align="right">员工姓名:</div></td>
       <td width="16%"><asp:DropDownList ID="selStaffName1" CssClass="inputmid" runat="server"></asp:DropDownList><span class="red">*</span>
       </td>
       <td width="14%"><div align="right">允许登录的IP地址:</div></td>
       <td width="36%"><asp:TextBox  ID="txtIPAdress" CssClass="inputmid"  MaxLength="40" runat="server"/><span class="red">*</span>
       </td>
     </tr>
     <tr>
        <td><div align="right">允许登陆日期:</div></td>
        <td colspan="3">
           <asp:TextBox runat="server" ID="txtEffDate" CssClass="inputmid"  MaxLength="8"/>
            -
           <asp:TextBox runat="server" ID="txtExpDate" CssClass="inputmid"  MaxLength="8"/>
           <ajaxToolkit:CalendarExtender ID="FCalendar" runat="server" TargetControlID="txtEffDate"
               Format="yyyyMMdd" />
           <ajaxToolkit:CalendarExtender ID="ECalendar" runat="server" TargetControlID="txtExpDate"
               Format="yyyyMMdd" /><span class="red">*</span>
       </td>
       <td><div align="right">允许登录时间:</div></td>
       <td colspan="3">
       <asp:TextBox runat="server" ID="txtEffTime" CssClass="inputmid"  MaxLength="8"/>
        -
       <asp:TextBox runat="server" ID="txtExpTime" CssClass="inputmid"  MaxLength="8"/>
       <span class="red">*</span>    
       </td>
       </tr>
     <tr>
       <td><div align="right">是否有效:</div></td>
       <td><asp:DropDownList ID="selValidTag" CssClass="inputmid" runat="server"></asp:DropDownList><span class="red">*</span></td>
       <td><div align="right"></div></td>
       <td>&nbsp;</td>
       <td colspan="4"><table width="300" border="0" align="right" cellpadding="0" cellspacing="0">
         <tr>
           
           <td><asp:Button ID="btnStaffLoginConfigAdd" runat="server" Text="增加" CssClass="button1" OnClick="btnStaffLoginConfigAdd_Click" /></td>
           <td><asp:Button ID="btnStaffLoginConfigModify" runat="server" Text="修改" CssClass="button1" OnClick="btnStaffLoginConfigModify_Click" /></td>
           <td><asp:Button ID="btnStaffLoginConfigDelete" runat="server" Text="删除" CssClass="button1" OnClick="btnStaffLoginConfigDelete_Click" /></td>
         </tr>
            </table></td>
      </tr>
   </table>
 </div>
   </div>
 </ContentTemplate>
</asp:UpdatePanel>
     </form>
</body>
</html>

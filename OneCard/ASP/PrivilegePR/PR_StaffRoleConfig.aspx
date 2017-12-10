<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PR_StaffRoleConfig.aspx.cs" Inherits="ASP_PrivilegePR_PR_StaffRoleConfig" EnableEventValidation="false"%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <title>系统设置-员工与角色对应</title>
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
<ajaxToolkit:ToolkitScriptManager runat="Server" EnableScriptGlobalization="true"
    EnableScriptLocalization="true" ID="ScriptManager2" />
    <asp:UpdatePanel ID="UpdatePanel1" runat="server">
    <ContentTemplate>
    <div class="tb">系统设置-&gt;员工与角色对应</div>
    <!-- #include file="../../ErrorMsg.inc" --> 
    <div class="con">
 <div class="pip">员工与角色对应</div>
 <div class="kuang5">
   <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
     <tr>
       <td width="12%"><div align="right">部门名称:</div></td>
       <td width="23%"><asp:DropDownList ID="selDEPARTNAME" CssClass="inputmid" runat="server" 
        AutoPostBack="true" OnSelectedIndexChanged="selDEPARTNAME_SelectedIndexChanged" ></asp:DropDownList>
       </td>
       <td width="9%"><div align="right">员工姓名:</div></td>
       <td width="20%"><asp:DropDownList ID="selSTAFFNAME" CssClass="inputmid" runat="server" 
        AutoPostBack="true" OnSelectedIndexChanged="selSTAFFNAME_SelectedIndexChanged"></asp:DropDownList>
       </td>
       <td width="9%">&nbsp;</td>
       <td width="27%">&nbsp;</td>
     </tr>
   </table>
 </div>
  <div class="kuang5">
  <div class="gdtb1" style="height:290px">
  <asp:GridView ID="lvwStaffRoleConfig" runat="server"
        Width = "98%"
        CssClass="tab1"
        HeaderStyle-CssClass="tabbt"
        AlternatingRowStyle-CssClass="tabjg"
        SelectedRowStyle-CssClass="tabsel"
        PagerSettings-Mode=NumericFirstLast
        PagerStyle-HorizontalAlign=left
        PagerStyle-VerticalAlign=Top
        AutoGenerateColumns="False">
           <Columns>
               <asp:TemplateField HeaderText="选定">
                <ItemTemplate>
                  <asp:CheckBox ID="ItemCheckBox" runat="server"/>
                </ItemTemplate>
                </asp:TemplateField>
                <asp:BoundField DataField="ROLENO" HeaderText="角色ID"/>
                <asp:BoundField DataField="ROLENAME" HeaderText="角色名称"/>
           </Columns>           
     <PagerSettings Mode="NumericFirstLast" />
     <SelectedRowStyle CssClass="tabsel" />
     <PagerStyle HorizontalAlign="Left" VerticalAlign="Top" />
     <HeaderStyle CssClass="tabbt" />
     <AlternatingRowStyle CssClass="tabjg" />
            <EmptyDataTemplate>
                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                  <tr class="tabbt">
                        <td>
                            选定</td>
                        <td>
                            角色名称</td>
                  </tr>
                  </table>
            </EmptyDataTemplate>
</asp:GridView>
</div>
<div class="btns">
  <table width="100" border="0" align="right" cellpadding="0" cellspacing="0">
    <tr>
      <td><asp:Button ID="btnStaffRoleConfig" CssClass="button1" runat="server" Text="确定" OnClick="btnStaffRoleConfig_Click" />
      </td>
    </tr>
  </table>
  <label></label>
  <label></label>
</div>
</div>
        
    </ContentTemplate>
    </asp:UpdatePanel>
    
    </form>
</body>
</html>

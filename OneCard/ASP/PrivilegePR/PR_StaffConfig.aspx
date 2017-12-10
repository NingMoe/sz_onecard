<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PR_StaffConfig.aspx.cs" Inherits="ASP_PrivilegePR_PR_StaffConfig" EnableEventValidation="false" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
    <title>系统设置-员工信息维护</title>
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
</head>
<body>
<form id="form1" runat="server">
<ajaxToolkit:ToolkitScriptManager runat="Server" EnableScriptGlobalization="true"
    EnableScriptLocalization="true" ID="ScriptManager2" />
    <asp:UpdatePanel ID="UpdatePanel1" runat="server">
    <ContentTemplate>
<div class="tb">系统设置-&gt;员工信息维护</div>
<!-- #include file="../../ErrorMsg.inc" --> 
 <div class="con">
 <div class="pip">员工信息维护</div>
 <div class="kuang5">
   <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
     <tr>
       <td width="12%"><div align="right">部门名称:</div></td>
       <td width="30%"><asp:DropDownList ID="selDepartName1" CssClass="inputmid" 
        runat="server" AutoPostBack="true" OnSelectedIndexChanged="selDepartName1_SelectedIndexChanged"> </asp:DropDownList>
       </td>
       <td width="9%"><div align="right">员工姓名:</div></td>
       <td width="20%"><asp:DropDownList ID="selStaffName" CssClass="inputmid" runat="server" ></asp:DropDownList>
              </td>
       <td><asp:Button ID="btnQuery" runat="server" Text="查询" CssClass="button1" OnClick="btnQuery_Click" /></td>
       <td width="27%">&nbsp;</td>
     </tr>
   </table>
 </div>
  <div class="kuang5">
  <div class="gdtb" style="height:300px">
  <table width="800" border="0" cellpadding="0" cellspacing="0" class="tab1" >
      <asp:GridView ID="lvwStaff" runat="server"
        Width = "100%"
        CssClass="tab1"
         AllowPaging=true
         PageSize=10
        HeaderStyle-CssClass="tabbt"
        AlternatingRowStyle-CssClass="tabjg"
        SelectedRowStyle-CssClass="tabsel"
        PagerSettings-Mode=NumericFirstLast
        PagerStyle-HorizontalAlign=left
        PagerStyle-VerticalAlign=Top
        AutoGenerateColumns="False"
        OnPageIndexChanging="lvwStaff_Page"
        OnRowCreated="lvwStaff_RowCreated" 
        OnSelectedIndexChanged="lvwStaff_SelectedIndexChanged"
        >
           <Columns>
                <asp:BoundField HeaderText="员工编码" DataField="STAFFNO"/>
                <asp:BoundField HeaderText="员工姓名" DataField="STAFFNAME"/>
                <asp:BoundField HeaderText="员工卡号" DataField="OPERCARDNO"/>
                <asp:BoundField HeaderText="部门名称" DataField="DEPARTNAME"/>
                <asp:TemplateField HeaderText="是否离职">
                       <ItemTemplate>
                         <asp:Label ID="labDimTag" Text='<%# Eval("DIMISSIONTAG").ToString() == "0" ? "是" : "否" %>' runat="server"></asp:Label>
                       </ItemTemplate>
                      </asp:TemplateField>
            </Columns>           
            <PagerSettings Mode="NumericFirstLast" />
            <SelectedRowStyle CssClass="tabsel" />
            <PagerStyle HorizontalAlign="Left" VerticalAlign="Top" />
            <HeaderStyle CssClass="tabbt" />
            <AlternatingRowStyle CssClass="tabjg" />
            <EmptyDataTemplate>
                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                  <tr class="tabbt">
                    <td>员工编码</td>
                    <td>员工姓名</td>
                    <td>员工卡号</td>
                    <td>部门名称</td>
                    <td>是否离职</td>
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
       <td width="12%"><div align="right">员工编码:</div></td>
       <td style="height: 37px"><asp:TextBox ID="txtStaffNO" runat="server" CssClass="inputmid" MaxLength="6" Width="96px" ></asp:TextBox><span class="red">*</span></td>
       <td width="9%"><div align="right">员工姓名:</div></td>
       <td style="height: 37px"><asp:TextBox ID="txtStaffName" runat="server" CssClass="inputmid" MaxLength="40" Width="96px" ></asp:TextBox><span class="red">*</span></td>
       <td width="9%"><div align="right">员工卡号:</div></td>
       <td style="height: 37px"><asp:TextBox ID="txtOpercardNO" runat="server" CssClass="inputmid" MaxLength="16" Width="200px" ></asp:TextBox></td>
     </tr>
     <tr>
       <td><div align="right">部门名称:</div></td>
       <td><asp:DropDownList ID="selDepartName" CssClass="inputmid" runat="server" ></asp:DropDownList><span class="red">*</span>
       </td>
       <td><div align="right">是否离职:</div></td>
       <td><asp:DropDownList ID="selDimTag" CssClass="input" runat="server"></asp:DropDownList><span class="red">*</span></td>
       <td><div align="right"></div></td>
     </tr>
     <tr>
       <td><div align="right"></div></td>
       <td>&nbsp;</td>
       <td colspan="4"><table width="300" border="0" align="right" cellpadding="0" cellspacing="0">
         <tr>
           
           <td><asp:Button ID="btnStaffAdd" runat="server" Text="增加" CssClass="button1" OnClick="btnStaffAdd_Click" /></td>
           <td><asp:Button ID="btnStaffModify" runat="server" Text="修改" CssClass="button1" OnClick="btnStaffModify_Click" /></td>
           <td><asp:Button ID="btnStaffDelete" runat="server" Text="删除" CssClass="button1" OnClick="btnStaffDelete_Click" /></td>
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

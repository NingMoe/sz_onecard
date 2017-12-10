<%@ Import namespace="System.Data" %> 
<%@ Page Language="C#" AutoEventWireup="true" CodeFile="UC_Distribution.aspx.cs" Inherits="ASP_UserCard_UC_Distribution" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <title>用户卡分配</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    
    <script type="text/javascript" src="../../js/mootools.js"></script>

    <script type="text/javascript">
        
    </script>
    
</head>
<body>
    <form id="form1" runat="server">
<div class="tb">
卡片管理->用户卡（取消）分配
</div>
        <ajaxToolkit:ToolkitScriptManager EnableScriptGlobalization="true" EnableScriptLocalization="true" ID="ScriptManager1" runat="server"/>
        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
            <ContentTemplate>

    <asp:BulletedList ID="bulMsgShow" runat="server"/>
    <script runat="server" >public override void ErrorMsgShow(){ErrorMsgHelper(bulMsgShow);}</script>

<div class="con">
  <div class="base">卡（取消）分配</div>
  <div class="kuang5">
 <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
  <tr>
    <td width="10%"><div align="right">操作类型:</div></td>
    <td>
    <asp:DropDownList ID="selCardState" CssClass="input" runat="server" AutoPostBack="true" OnSelectedIndexChanged="selCardState_SelectedIndexChanged"></asp:DropDownList>
    </td>
    <td width="10%"><div align="right">起讫卡号:</div></td>
    <td><asp:TextBox ID="txtFromCardNo" CssClass="input" runat="server" MaxLength="16"></asp:TextBox>
    -
    <asp:TextBox ID="txtToCardNo" CssClass="input" runat="server" MaxLength="16"></asp:TextBox>
<div align="right"></div></td>
    <td align="right">
    <asp:Button ID="btnQuery" CssClass="button1" runat="server" Text="查询" OnClick="btnQuery_Click"/>
    </td>
  </tr>
  <tr id="trUndist">
    <td><div align="right">分配日期:</div></td>
    <td style="width: 260px"><asp:TextBox runat="server" Enabled="false" ID="txtDistDate" CssClass="inputmid"  MaxLength="8"/>(仅限取消分配)
    <ajaxToolkit:CalendarExtender ID="FCalendar" runat="server" TargetControlID="txtDistDate"
        Format="yyyyMMdd" /></td>
    <td><div align="right">分配员工:</div></td>
    <td>
    <asp:DropDownList ID="selAssignee" Enabled="false" CssClass="input" runat="server"></asp:DropDownList>(仅限取消分配)
    </td>
    <td>&nbsp;</td>
  </tr>
</table>

 </div>
  <div class="jieguo">查询结果</div>
  <div class="kuang5">
<div class="gdtb" style="height:310px">
         <asp:GridView ID="gvResult" runat="server"
        Width = "98%"
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
        OnPageIndexChanging="gvResult_Page">
           <Columns>
             <asp:TemplateField>
                <HeaderTemplate>
                  <asp:CheckBox ID="CheckBox1" runat="server"  AutoPostBack="true" OnCheckedChanged="CheckAll" />
                </HeaderTemplate>
                <ItemTemplate>
                  <asp:CheckBox ID="ItemCheckBox" runat="server"/>
                </ItemTemplate>
            </asp:TemplateField>
               <asp:BoundField HeaderText="卡号" DataField="CARDNO"/>
                <asp:BoundField HeaderText="卡类型" DataField="CARDTYPENAME"/>
                <asp:BoundField HeaderText="有效期" DataField="VALIDDATE"/>
                <asp:BoundField HeaderText="卡面" DataField="CARDSURFACENAME"/>
                <asp:BoundField HeaderText="厂商" DataField="MANUNAME"/>
                <asp:BoundField HeaderText="卡状态" DataField="RESSTATE"/>
                <asp:BoundField HeaderText="COS类型" DataField="COSTYPE"/>
                <asp:BoundField HeaderText="芯片类型" DataField="CARDCHIPTYPENAME"/>
            </Columns>           
            <EmptyDataTemplate>
                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                  <tr class="tabbt">
                    <td><input type="checkbox" /></td>
                    <td>卡号</td>
                    <td>卡类型</td>
                    <td>有效期</td>
                    <td>卡面</td>
                    <td>厂商</td>
                    <td>卡状态</td>
                    <td>COS类型</td>
                    <td>芯片类型</td>
                  </tr>
                  </table>
            </EmptyDataTemplate>
        </asp:GridView>
  </div>
  </div>
 <div id="divDist">
  <div class="base">分配到员工</div>
  <div class="kuang5">
 <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
  <tr>
    <td width="10%"><div align="right">分配员工:</div></td>
    <td>
        <asp:DropDownList ID="selAssignedStaff" CssClass="input" runat="server"></asp:DropDownList>
(仅限分配)
    </td>
    </tr>
</table>
</div>
 </div>
</div>
<div class="btns">
     <table width="95%" border="0"cellpadding="0" cellspacing="0">
  <tr>
    <td width="70%">&nbsp;</td>
    <td align="right"><asp:Button ID="btnSubmit" Enabled="false" CssClass="button1" runat="server" Text="提交" OnClick="btnSubmit_Click"/></td>
  </tr>
</table>

</div>
            </ContentTemplate>
        </asp:UpdatePanel>

    </form>
</body>
</html>


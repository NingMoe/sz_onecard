<%@ Page Language="C#" AutoEventWireup="true" CodeFile="GC_AccLock.aspx.cs" Inherits="ASP_GroupCard_GC_AccLock"  EnableEventValidation="false"%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
    <title>企服卡帐户<%=labTitle.Text%></title>

    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    
    <script language="javascript">
        
    </script>
</head>
<body>
    <form id="form1" runat="server">
<div class="tb">
企服卡->帐户<asp:Label runat="server" ID="labTitle"></asp:Label>
</div>
        <ajaxToolkit:ToolkitScriptManager EnableScriptGlobalization="true" EnableScriptLocalization="true" ID="ScriptManager1" runat="server"/>
        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
            <ContentTemplate>

    <asp:BulletedList ID="bulMsgShow" runat="server"/>
    <script runat="server" >public override void ErrorMsgShow(){ErrorMsgHelper(bulMsgShow);}</script>

<asp:HiddenField runat="server" ID="hidLockType" />
<div class="con">
  <div class="base">查询</div>
  <div class="kuang5">
 <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
   <tr>
    <td width="10%"><div align="right">查询条件:</div></td>
    <td width="70%" colspan="5">
    <asp:DropDownList runat="server" ID="selQueryType">
        <asp:ListItem Selected="True" Text="01:卡号" Value="01"></asp:ListItem>
        <asp:ListItem Text="02:证件" Value="02"></asp:ListItem>
        <asp:ListItem Text="03:姓名" Value="03"></asp:ListItem>
        <asp:ListItem Text="04:电话" Value="04"></asp:ListItem>
    </asp:DropDownList>
    <asp:TextBox ID="txtCondition" CssClass="inputlong" runat="server"
     MaxLength="40" AutoPostBack="true" ontextchanged="btnQuery_Click"/><span class="red">*</span>
    </td>
     <td width="10%"> <asp:Button ID="btnQuery" Text="查询" CssClass="button1" runat="server" OnClick="btnQuery_Click"/></td>
    </tr>
   </table>
   <div class="gdtb" style="height:108px">
   <asp:GridView ID="gvCardInfo" runat="server"
        Width = "98%"
        CssClass="tab1"
        HeaderStyle-CssClass="tabbt"
        AlternatingRowStyle-CssClass="tabjg"
        SelectedRowStyle-CssClass="tabsel"
        AutoGenerateColumns="False"
        OnSelectedIndexChanged="gvCardInfo_SelectedIndexChanged"
        OnRowCreated="gvCardInfo_RowCreated"
        EmptyDataText="没有数据记录!"
        OnRowDataBound="gvCardInfo_RowDataBound"
       >
           <Columns>
               <asp:BoundField HeaderText="卡号" DataField="CARDNO" ItemStyle-Width="25%"/>
               <asp:BoundField HeaderText="姓名" DataField="CUSTNAME" ItemStyle-Width="25%"/>
               <asp:BoundField HeaderText="证件" DataField="PAPERNO" ItemStyle-Width="25%"/>
               <asp:BoundField HeaderText="电话" DataField="CUSTPHONE" ItemStyle-Width="25%"/>
            </Columns>                       
             <EmptyDataTemplate>
                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                  <tr class="tabbt">
                   <td width="25%">卡号</td>
                    <td width="25%">姓名</td>
                    <td width="25%">证件号码</td>
                    <td width="25%">联系电话</td>
                  </tr>
                  </table>
            </EmptyDataTemplate>
   </asp:GridView>
    </div>
 </div>
  <div class="card">卡片信息</div>
 <div class="kuang5">
 <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
  <tr>
    <td width="12%"><div align="right">
        卡号:</div></td>
    <td style="width: 194px">
        <asp:Label ID="labCardNo" runat="server"></asp:Label></td>
    <td style="width: 143px"><div align="right">
        企服卡帐户余额:</div></td>
    <td width="17%"><asp:Label ID="labBalance" runat="server"></asp:Label></td>
    <td width="13%"><div align="right">
        企服卡帐户状态:</div></td>
    <td width="24%"><asp:HiddenField ID="hidAccState" runat="server" /><asp:Label ID="labAccState" runat="server"></asp:Label></td>
  </tr>
  <tr>
    <td><div align="right">
        用户姓名:</div></td>
    <td style="width: 194px"><b><asp:Label ID="labName" runat="server"></asp:Label></b></td>
    <td style="width: 143px"><div align="right">
        集团客户:</div></td>
    <td><asp:Label ID="labCorp" runat="server"></asp:Label></td>
    <td><div align="right">卡片状态:</div></td>
    <td><asp:Label ID="labCardState" runat="server"></asp:Label></td>
  </tr>
  <tr>
    <td style="height: 19px"><div align="right">
        用户性别:</div></td>
    <td style="width: 194px; height: 19px;"><asp:Label ID="labSex" runat="server"></asp:Label></td>
    <td style="width: 143px; height: 19px;"><div align="right">证件类型:</div></td>
    <td style="height: 19px"><asp:Label ID="labPaperType" runat="server"></asp:Label></td>
    <td style="height: 19px"><div align="right">证件号码:</div></td>
    <td style="height: 19px"><asp:Label ID="labPaperNo" runat="server"></asp:Label></td>
  </tr>
  <tr>
    <td><div align="right">出生日期:</div></td>
    <td style="width: 194px"><asp:Label ID="labBirth" runat="server"></asp:Label></td>
    <td style="width: 143px"><div align="right">邮政编码:</div></td>
    <td><asp:Label ID="labPost" runat="server"></asp:Label></td>
    <td><div align="right">联系电话:</div></td>
    <td><asp:Label ID="labPhone" runat="server"></asp:Label></td>
  </tr>
  <tr>
    <td><div align="right">联系地址:</div></td>
    <td colspan="5"><asp:Label ID="labAddr" runat="server"></asp:Label></td>
    </tr>
</table>

 </div>
</div>
<div>
  <div class="footall"></div>
</div>

<div class="btns">
<table width="95%" border="0"cellpadding="0" cellspacing="0">
  <tr>
    <td width="70%">&nbsp;</td>
    <td align="right"><asp:CheckBox ID="chkLock" Visible="false" Enabled="false" AutoPostBack="true" Text="锁定" runat="server" OnCheckedChanged="chkLock_CheckedChanged" /></td>
    <td align="right"><asp:CheckBox ID="chkUnlock" Visible="false" Enabled="false" AutoPostBack="true" Text="解锁" runat="server" OnCheckedChanged="chkLock_CheckedChanged"  /></td>
    <td align="right"><asp:Button ID="btnSubmit" Enabled="false" CssClass="button1" runat="server" Text="提交" OnClick="btnSubmit_Click"/></td>
  </tr>
</table>
  </div>    
   </ContentTemplate>
        </asp:UpdatePanel>
  </form>
</body>
</html>

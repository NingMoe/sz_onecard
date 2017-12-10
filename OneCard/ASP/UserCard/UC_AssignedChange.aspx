<%@ Page Language="C#" AutoEventWireup="true" CodeFile="UC_AssignedChange.aspx.cs" Inherits="ASP_UserCard_UC_AssignedChange" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>卡归属更改</title>

    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <script type="text/javascript" src="../../js/myext.js"></script>
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />   
</head>
<body>
    <form id="form1" runat="server">
<div class="tb"> 卡片管理->更改卡归属（原）
</div>
        <ajaxToolkit:ToolkitScriptManager EnableScriptGlobalization="true" EnableScriptLocalization="true" ID="ScriptManager1" runat="server"/>
        <script type="text/javascript" language="javascript">
                var swpmIntance = Sys.WebForms.PageRequestManager.getInstance();
                swpmIntance.add_initializeRequest(BeginRequestHandler);
                swpmIntance.add_pageLoading(EndRequestHandler);
				function BeginRequestHandler(sender, args){
				    try {MyExtShow('请等待', '正在提交后台处理中...'); } catch(ex){}
				}
				function EndRequestHandler(sender, args) {
				    try {MyExtHide(); } catch(ex){}
				}
          </script> 
        <asp:UpdatePanel ID="UpdatePanel1" UpdateMode="Conditional" runat="server">
            <ContentTemplate>

    <asp:BulletedList ID="bulMsgShow" runat="server"/>
    <script runat="server" >public override void ErrorMsgShow(){ErrorMsgHelper(bulMsgShow);}</script>
<div class="con">
<div class="base"></div>
  <div class="kuang5">
 <table width="95%" border="0" cellpadding="0" cellspacing="0" class="12text">
  <tr>
    <td width="10%"><div align="right">起讫卡号:</div></td>
    <td width="38%"><asp:TextBox ID="txtFromCardNo" CssClass="inputmid" runat="server" MaxLength="16"></asp:TextBox>
-
  <asp:TextBox ID="txtToCardNo" CssClass="inputmid" runat="server" MaxLength="16"></asp:TextBox></td>
  <td width="10%"></td>
    <td width="32%"><asp:Button ID="btnQuery" CssClass="button1" runat="server" Text="加入到列表" OnClick="btnQuery_Click" /></td>
    </tr>
</table>
  </div>
  <div class="base"></div>
  <div class="kuang5">
 <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
  <tr>
    <td width="10%"><div align="right">导入文件:</div></td>
    <td width="38%">
    <asp:FileUpload ID="FileUpload1" runat="server" CssClass="inputlong" />
    </td>
    <td width="10%"></td>
    <td width="32%">
    <asp:Button ID="btnUpload" CssClass="button1" runat="server" Text="导入到列表" OnClick="btnUpload_Click"/>
    </td>
  </tr>
</table>

 </div>
 <div class="kuang5">
 <table width="95%" border="0" cellpadding="0" cellspacing="0" class="12text">
  <tr>
    <td width="10%"><div align="right">归属部门:</div></td>
    <td width="38%"><asp:DropDownList ID="selDept" CssClass="inputmid" runat="server" AutoPostBack="true"
     OnSelectedIndexChanged="selDept_SelectedIndexChanged"></asp:DropDownList></td>
    <td width="10%"><div align="right">归属员工:</div></td>
    <td width="32%"><asp:DropDownList ID="selOper" CssClass="inputmid" runat="server"></asp:DropDownList></td>
    </tr>
</table>
  </div>
  <div class="jieguo">卡号列表</div>
  <div class="kuang5">
<div class="gdtb" style="height:310px">
         <asp:GridView ID="gvResult" runat="server"
        Width = "98%"
        CssClass="tab1"
        HeaderStyle-CssClass="tabbt"
        AlternatingRowStyle-CssClass="tabjg"
        SelectedRowStyle-CssClass="tabsel"
        AllowPaging="false"
        PagerSettings-Mode="NumericFirstLast"
        PagerStyle-HorizontalAlign="left"
        PagerStyle-VerticalAlign="Top"
        AutoGenerateColumns="False">
           <Columns>
               <asp:BoundField HeaderText="起始卡号" DataField="BeginCardNo"/>
                <asp:BoundField HeaderText="终止卡号" DataField="EndCardno"/>
           </Columns>           
            <EmptyDataTemplate>
                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                  <tr class="tabbt">
                    <td>起始卡号</td>
                    <td>终止卡号<td>
                  </tr>
                  </table>
            </EmptyDataTemplate>
        </asp:GridView>
  </div>
  </div>
</div>
<div class="btns">
     <table width="200" align="right"  border="0"cellpadding="0" cellspacing="0">
  <tr>
    <td><asp:Button ID="btnClear" Enabled="false" CssClass="button1" runat="server" Text="清除列表" OnClick="btnClear_Click"/></td>
    <td><asp:Button ID="btnSubmit" Enabled="false" CssClass="button1" runat="server" Text="提交" OnClick="btnSubmit_Click"/></td>
  </tr>
</table>

</div>

            </ContentTemplate>
    <Triggers>
    <asp:PostBackTrigger ControlID="btnUpload" />
    </Triggers>            
        </asp:UpdatePanel>

    </form>
</body>
</html>

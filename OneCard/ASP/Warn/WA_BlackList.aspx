<%@ Page Language="C#" AutoEventWireup="true" CodeFile="WA_BlackList.aspx.cs" Inherits="ASP_Warn_WA_BlackList" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
     <title>黑名单</title>
    <script type="text/javascript" src="../../js/myext.js"></script>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
   <link href="../../css/card.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
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
        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
            <ContentTemplate>
        <div class="tb">
        账务监控->黑名单
        </div>

    <asp:BulletedList ID="bulMsgShow" runat="server"/>
    <script runat="server" >public override void ErrorMsgShow(){ErrorMsgHelper(bulMsgShow);}</script>

        <div class="con">
          <div class="base">查询条件</div>
          <div class="kuang5">
         <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
          <tr>
            <td align="right">卡号:</td>
            <td><asp:TextBox runat="server"  CssClass="inputmid"  ID="txtCardNo1" MaxLength="16"/></td>
            <td align="right">&nbsp;</td>
            <td>&nbsp;</td>
            <td align="right">&nbsp;</td>
            <td><asp:Button ID="Button2" CssClass="button1" runat="server" Text="查询" OnClick="btnQuery_Click"/></td>
            <td><asp:Button ID="btnDown" CssClass="button1" runat="server" Text="下载" OnClick="btnDown_Click"/></td>
          </tr>
        </table>

         </div>
          <div class="jieguo">查询结果
          </div>
  <div class="kuang5">
  <div class="gdtb" style="height:260px">

         <asp:GridView ID="gvResult" runat="server"
        Width = "98%"
        CssClass="tab1"
        AutoGenerateSelectButton="true"
        HeaderStyle-CssClass="tabbt"
        AlternatingRowStyle-CssClass="tabjg"
        SelectedRowStyle-CssClass="tabsel"
        AllowPaging="False"
        PagerSettings-Mode="NumericFirstLast"
        PagerStyle-HorizontalAlign="left"
        PagerStyle-VerticalAlign="Top"
        AutoGenerateColumns="True"
        OnSelectedIndexChanged="gvResult_SelectedIndexChanged"
        EmptyDataText="没有数据记录!">
        </asp:GridView>
        </div>
  </div>       
          <div class="kuang5">
         <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
          <tr>
            <td align="right">卡号:</td>
            <td><asp:TextBox runat="server" ID="txtCardNo" CssClass="inputmid"  MaxLength="16"/><span class="red">*</span></td>
            <asp:HiddenField runat="server" ID="hidCardNo" />
            <asp:HiddenField runat="server" ID="hidCardNoForDelAndMod" />
            
            <td align="right">告警类型:</td>
            <td><asp:DropDownList ID="selWarnType" CssClass="inputmid" runat="server"/><span class="red">*</span></td>
            <td align="right">告警级别</td>
            <td><asp:DropDownList ID="selWarnLevel" CssClass="inputmid" runat="server">
                <asp:ListItem Text="---请选择---" Value=""/>
                <asp:ListItem Text="0: 普通告警" Value="0"/>
                <asp:ListItem Text="1: 一级告警" Value="1"/>
                <asp:ListItem Text="2: 二级告警" Value="2"/>
                <asp:ListItem Text="3: 三级告警" Value="3"/>
                </asp:DropDownList><span class="red">*</span>   </td>
            <td>&nbsp;</td>
          </tr>
          <tr>
            <td align="right">生成时间:</td>
            <td><asp:Label runat="server" ID="labCreateTime"  /></td>
             <td align="right">下载时间:</td>
            <td><asp:Label runat="server" ID="labDownTime"/></td>
            <td>&nbsp;</td>
            <td>&nbsp;</td>
            <td>&nbsp;</td>
          </tr>
      <tr>
       <td align="right">备注:</td>
       <td colspan="3"><asp:TextBox runat="server" ID="txtRemark" CssClass="inputmax" MaxLength="100" /></td>
       <td colspan="2"><table width="300" border="0" align="right" cellpadding="0" cellspacing="0">
         <tr>
           
           <td><asp:Button ID="btnAdd" runat="server" Text="新增" CssClass="button1" OnClick="btnAdd_Click" /></td>
           <td><asp:Button ID="btnMod" runat="server" Text="修改" CssClass="button1" OnClick="btnMod_Click" /></td>
           <td><asp:Button ID="btnDel" runat="server" Text="删除" CssClass="button1" OnClick="btnDel_Click" /></td>
         </tr>
            </table>
         </td>
      </tr>       
       </table>
  </div>
</ContentTemplate>
      <Triggers>
        <asp:PostBackTrigger ControlID="btnDown" />
      </Triggers>

</asp:UpdatePanel>
    </form>
</body>
</html>

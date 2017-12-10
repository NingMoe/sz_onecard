<%@ Page Language="C#" AutoEventWireup="true" CodeFile="WA_WarnCustomer.aspx.cs" Inherits="ASP_Warn_WA_WarnCustomer"%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
     <title>恐怖人员维护</title>
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
        风险监控->恐怖人员维护
        </div>

    <asp:BulletedList ID="bulMsgShow" runat="server"/>
    <script runat="server" >public override void ErrorMsgShow(){ErrorMsgHelper(bulMsgShow);}</script>

        <div class="con">
          <div class="base">查询条件</div>
          <div class="kuang5">
         <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
          <tr>
            <td align="right">姓名:</td>
            <td><asp:TextBox runat="server"  CssClass="inputmid"  ID="txtSelCustName" MaxLength="25"/></td>
            <td align="right">证件类型:</td>
            <td><asp:DropDownList ID="selslPaperType" runat="server" CssClass="inputmid">
                </asp:DropDownList>
            </td>
            <td align="right">证件号码:</td>
            <td>
                <asp:TextBox runat="server" ID="txtSelPaperNo" CssClass="inputmid"/>
            </td>
            <td><asp:Button ID="Button1" CssClass="button1" runat="server" Text="查询" OnClick="btnQuery_Click"/></td>
          </tr>
        </table>

         </div>
          <div class="jieguo">查询结果
          </div>
            <asp:HiddenField ID="hidPaperType" runat="server" />
            <asp:HiddenField ID="hidPaperNo" runat="server" />
  <div class="kuang5">
  <div class="gdtb" style="height:260px">

         <asp:GridView ID="gvResult" runat="server"
        Width = "98%"
        CssClass="tab1"
        AutoGenerateSelectButton="true"
        HeaderStyle-CssClass="tabbt"
        AlternatingRowStyle-CssClass="tabjg"
        SelectedRowStyle-CssClass="tabsel"
        AllowPaging="True"
        PagerSettings-Mode="NumericFirstLast"
        PagerStyle-HorizontalAlign="left"
        PagerStyle-VerticalAlign="Top"
        AutoGenerateColumns="False"
        OnSelectedIndexChanged="gvResult_SelectedIndexChanged"
        OnRowDataBound="gvResult_RowDataBound"
        PageSize="50"
        OnPageIndexChanging="gvResult_Page"
        >
        <Columns>
               <asp:BoundField HeaderText="姓名" DataField="CUSTNAME"/>
               <asp:BoundField HeaderText="证件类型" DataField="PAPERTYPECODE"/>
               <asp:BoundField HeaderText="证件类型" DataField="PAPERTYPENAME"/>
               <asp:BoundField HeaderText="证件号码" DataField="PAPERNO"/>
               <asp:BoundField HeaderText="性别" DataField="CUSTSEX"/>
               <asp:BoundField HeaderText="出生日期" DataField="CUSTBIRTH"/>
            </Columns>   
            <EmptyDataTemplate>
                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                  <tr class="tabbt">
                  <td>姓名</td>
                    <td>证件类型</td>
                    <td>证件号码</td>
                    <td>性别</td>
                    <td>出生日期</td>
                  </tr>
                  </table>
            </EmptyDataTemplate>
        </asp:GridView>
        </div>
  </div>       
          <div class="kuang5">
         <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
          <tr>
          <asp:HiddenField runat="server" ID="hidCondCode" />
            <td align="right">证件类型:</td>
            <td>
                <asp:DropDownList ID="selInPaperType" runat="server" CssClass="inputmid">
                </asp:DropDownList><span class="red">*</span>
            </td>
            <td align="right">证件号码:</td>
            <td><asp:TextBox runat="server" ID="txtInPaperNo" CssClass="inputmid"/><span class="red">*</span></td>
            <td align="right">姓名:</td>
            <td><asp:TextBox runat="server" ID="txtInName" CssClass="inputmid"/></td>
          </tr>
          <tr>
            <td align="right">性别:</td>
            <td><asp:DropDownList ID="selCustsex" runat="server" CssClass="inputmid">
                </asp:DropDownList></td>
            <td align="right">出生日期:</td>
            <td><asp:TextBox ID="txtCustbirth" CssClass="input" runat="server" MaxLength="10" />
                <ajaxToolkit:CalendarExtender ID="FCalendar" runat="server" TargetControlID="txtCustbirth" Format="yyyyMMdd" />
            </td>
          </tr>
          <tr>
            <td align="right">&nbsp;</td>
            <td colspan="3">&nbsp;</td>
            <td align="right">&nbsp;</td>
            <td><table width="300" border="0" align="right" cellpadding="0" cellspacing="0">
            <tr>
                <asp:Button runat="server" ID="btnAdd" CssClass="button1" Text="新增" OnClick="btnAdd_Click" /></td>
                <asp:Button runat="server" ID="btnMod" CssClass="button1" Text="修改" OnClick="btnMod_Click"  />
                <asp:Button runat="server" ID="btnDel" CssClass="button1" Text="删除"  OnClick="btnDel_Click" />
            </tr>
            </table></td>
          </tr>
        </table>
  </div>
</ContentTemplate>
</asp:UpdatePanel>
    </form>
</body>
</html>

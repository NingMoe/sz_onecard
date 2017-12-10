<%@ Page Language="C#" AutoEventWireup="true" CodeFile="WA_WarnCond.aspx.cs" Inherits="ASP_Warn_WA_WarnCond"%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
     <title>监控条件</title>
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
        账务监控->监控条件
        </div>

    <asp:BulletedList ID="bulMsgShow" runat="server"/>
    <script runat="server" >public override void ErrorMsgShow(){ErrorMsgHelper(bulMsgShow);}</script>

        <div class="con">
          <div class="base">查询条件</div>
          <div class="kuang5">
         <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
          <tr>
            <td align="right">条件编码:</td>
            <td><asp:TextBox runat="server"  CssClass="inputmid"  ID="txtCondCode1" MaxLength="4"/></td>
            <td align="right">条件名称:</td>
            <td><asp:TextBox runat="server" ID="txtCondName1" CssClass="inputmid"  MaxLength="100"/></td>
            <td align="right">条件范围:</td>
            <td><asp:DropDownList ID="selCondRange1" CssClass="inputmid" runat="server">
                <asp:ListItem Text="---请选择---" Value=""/>
                <asp:ListItem Text="0: 全局范围" Value="0"/>
                <asp:ListItem Text="1: 个性范围" Value="1"/>
            </asp:DropDownList></td>
            <td>&nbsp;</td>
          </tr>
          <tr>
            <td align="right">告警级别:</td>
            <td><asp:DropDownList ID="selWarnLevel1" CssClass="inputmid" runat="server">
                <asp:ListItem Text="---请选择---" Value=""/>
                <asp:ListItem Text="0: 普通告警" Value="0"/>
                <asp:ListItem Text="1: 一级告警" Value="1"/>
                <asp:ListItem Text="2: 二级告警" Value="2"/>
                <asp:ListItem Text="3: 三级告警" Value="3"/>
                </asp:DropDownList></td>
            <td align="right">应用类别:</td>
            <td><asp:DropDownList ID="selCondCate1" CssClass="inputmid" runat="server">
                <asp:ListItem Text="---请选择---" Value=""/>
                <asp:ListItem Text="0: 电子钱包账户类" Value="0"/>
                <asp:ListItem Text="1: 消费清单类" Value="1"/>
            </asp:DropDownList></td>
            <td align="right">告警类型:</td>
            <td>
                <asp:DropDownList ID="selWarnType1" runat="server" CssClass="inputmid">
                </asp:DropDownList></td>
            <td><asp:Button ID="Button1" CssClass="button1" runat="server" Text="查询" OnClick="btnQuery_Click"/></td>
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
          <asp:HiddenField runat="server" ID="hidCondCode" />
            <td align="right">条件编码:</td>
            <td><asp:TextBox runat="server" ID="txtCondCode" CssClass="inputmid"  MaxLength="4"/><span class="red">*</span></td>
            <td align="right">条件名称:</td>
            <td><asp:TextBox runat="server" ID="txtCondName" CssClass="inputmid"  MaxLength="256"/><span class="red">*</span></td>
            <td align="right">条件范围:</td>
            <td><asp:DropDownList ID="selCondRange" CssClass="inputmid" runat="server">
                <asp:ListItem Text="---请选择---" Value=""/>
                <asp:ListItem Text="0: 全局范围" Value="0"/>
                <asp:ListItem Text="1: 个性范围" Value="1"/>
            </asp:DropDownList><span class="red">*</span></td>
          </tr>
          <tr>
            <td align="right">告警级别:</td>
            <td><asp:DropDownList ID="selWarnLevel" CssClass="inputmid" runat="server">
                <asp:ListItem Text="---请选择---" Value=""/>
                <asp:ListItem Text="0: 普通告警" Value="0"/>
                <asp:ListItem Text="1: 一级告警" Value="1"/>
                <asp:ListItem Text="2: 二级告警" Value="2"/>
                <asp:ListItem Text="3: 三级告警" Value="3"/>
                </asp:DropDownList><span class="red">*</span></td>
            <td align="right">应用类别:</td>
            <td><asp:DropDownList ID="selCondCate" CssClass="inputmid" runat="server">
                <asp:ListItem Text="---请选择---" Value=""/>
                <asp:ListItem Text="0: 电子钱包账户类" Value="0"/>
                <asp:ListItem Text="1: 消费清单类" Value="1"/>
            </asp:DropDownList><span class="red">*</span></td>
            <td align="right">告警类型:</td>
            <td><asp:DropDownList ID="selWarnType" runat="server" CssClass="inputmid"/><span class="red">*</span>
          </tr>
          <tr>
            <td align="right">条件字符串:</td>
            <td colspan="3"><asp:TextBox runat="server" CssClass="inputmax" ID="txtCondStr" MaxLength="256"/><span class="red">*</span></td>
            <td align="right">&nbsp;</td>
            <td>&nbsp;</td>
          </tr>
          <tr>
            <td align="right">备注:</td>
            <td colspan="3"><asp:TextBox runat="server" CssClass="inputmax" ID="txtRemark" MaxLength="256"/></td>
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

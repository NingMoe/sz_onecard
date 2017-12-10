<%@ Page Language="C#" AutoEventWireup="true" CodeFile="UC_CardQuery.aspx.cs" Inherits="ASP_UserCard_UC_CardQuery" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
     <title>用户卡查询</title>
    <script type="text/javascript" src="../../js/myext.js"></script>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
   <link href="../../css/card.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
        <ajaxToolkit:ToolkitScriptManager EnableScriptGlobalization="true" 
        AsyncPostBackTimeout="600" EnableScriptLocalization="true" ID="ScriptManager1" runat="server"/>
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
        卡片管理->用户卡查询
        </div>

    <asp:BulletedList ID="bulMsgShow" runat="server"/>
    <script runat="server" >public override void ErrorMsgShow(){ErrorMsgHelper(bulMsgShow);}</script>

        <div class="con">
          <div class="base">查询条件</div>
          <div class="kuang5">
         <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
         <asp:Panel id="panCond" runat="server" Visible="false">
          <tr>
            <td><div align="right">卡片状态:</div></td>
            <td><asp:DropDownList ID="selCardStat" CssClass="inputmid" runat="server"></asp:DropDownList></td>
            <td><div align="right">COS类型:</div></td>
            <td><asp:DropDownList ID="selCosType" CssClass="inputmid" runat="server"></asp:DropDownList></td>
            <td><div align="right">卡片厂商:</div></td>
            <td><asp:DropDownList ID="selProducer" CssClass="inputmid" runat="server"></asp:DropDownList></td>
            <td>&nbsp;</td>
          </tr>
          <tr>
            <td><div align="right">卡片类型:</div></td>
            <td><asp:DropDownList ID="selCardType" CssClass="inputmid" runat="server"></asp:DropDownList></td>
            <td><div align="right">卡面类型:</div></td>
            <td><asp:DropDownList ID="selFaceType" CssClass="inputmid" runat="server"></asp:DropDownList></td>
            <td><div align="right">芯片类型:</div></td>
            <td><asp:DropDownList ID="selChipType" CssClass="inputmid" runat="server"></asp:DropDownList></td>
            <td>&nbsp;</td>
          </tr>
        </asp:Panel>         

          <tr>
            <td><div align="right">所属部门:</div></td>
            <td><asp:DropDownList ID="selDepts" CssClass="inputmid" runat="server" AutoPostBack="true"
                    onselectedindexchanged="selDepts_SelectedIndexChanged"></asp:DropDownList></td>
            <td><div align="right">所属员工:</div></td>
            <td><asp:DropDownList ID="selStaffs" CssClass="inputmid" runat="server"></asp:DropDownList></td>
            <%--<td>&nbsp;</td>
            <td>&nbsp;</td>--%>
            <td><div align="right">卡片价格:</div></td>
            <td><asp:TextBox ID="txtCardPrice" runat="server" CssClass="input"></asp:TextBox>* 100 分</td>
            <td align="right">&nbsp;</td>
          </tr> 
          <tr>
            <td><div align="right">起讫卡号:</div></td>
            <td colspan="5"><asp:TextBox ID="txtFromCardNo" CssClass="inputmid" runat="server" MaxLength="16"></asp:TextBox><span class="red">*</span>
              -
              <asp:TextBox ID="txtToCardNo" CssClass="inputmid" runat="server"  MaxLength="16"></asp:TextBox>
                <div align="right"></div></td>
            <td align="right"><asp:Button ID="btnQuery" CssClass="button1" runat="server" Text="查询" OnClick="btnQuery_Click"/>
            &nbsp;<asp:Button ID="btnShowCond" CssClass="button1" runat="server" Text="更多条件>>"  OnClick="btnShowCond_Click"/>
            </td>
          </tr>
        </table>

         </div>
          <div class="jieguo">查询结果
          </div>
  <div class="kuang5">
<%--  <div class="gdtb" style="height:310px">
--%>
         <asp:GridView ID="gvResult" runat="server"
        Width = "98%"
        CssClass="tab1"
        HeaderStyle-CssClass="tabbt"
        AlternatingRowStyle-CssClass="tabjg"
        SelectedRowStyle-CssClass="tabsel"
        AllowPaging="True"
        PageSize="200"
        PagerSettings-Mode="NumericFirstLast"
        PagerStyle-HorizontalAlign="left"
        PagerStyle-VerticalAlign="Top"
        AutoGenerateColumns="False"
        AllowSorting="true" OnSorting="gvResult_Sorting"
        OnPageIndexChanging="gvResult_PageIndexChanging" 
             onrowdatabound="gvResult_RowDataBound">
           <Columns>
               <asp:BoundField HeaderText="卡号" DataField="CARDNO" SortExpression="CARDNO"/>
                 <asp:BoundField HeaderText="状态" DataField="RESSTATE"/>
                 <asp:BoundField HeaderText="开通功能" DataField="RESSTATECODE"/>
               <asp:BoundField HeaderText="所属员工" DataField="STAFFNAME"/>
                <asp:BoundField HeaderText="所属部门" DataField="DEPARTNAME"/>
                <asp:BoundField HeaderText="类型" DataField="CARDTYPENAME"/>
                <asp:BoundField HeaderText="卡片价格" DataField="CARDPRICE"/>
                <asp:BoundField HeaderText="有效期" DataField="VALIDDATE"/>
                <asp:BoundField HeaderText="卡面" DataField="CARDSURFACENAME"/>
                <asp:BoundField HeaderText="厂商" DataField="MANUNAME"/>
                <asp:BoundField HeaderText="COS" DataField="COSTYPE"/>
                <asp:BoundField HeaderText="芯片" DataField="CARDCHIPTYPENAME"/>
            </Columns>           
            <EmptyDataTemplate>
                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                  <tr class="tabbt">
                    <td>卡号</td>
                    <td>卡状态</td>
                    <td>开通功能</td>
                    <td>所属员工</td>
                    <td>所属部门</td>
                    <td>卡类型</td>
                    <td>卡片价格</td>
                    <td>有效期</td>
                    <td>卡面</td>
                    <td>厂商</td>
                    <td>COS类型</td>
                    <td>芯片类型</td>
                  </tr>
                  </table>
            </EmptyDataTemplate>
        </asp:GridView>
<%--        </div>
--%>  </div>       
  </div>
</ContentTemplate>
</asp:UpdatePanel>
    </form>
</body>
</html>

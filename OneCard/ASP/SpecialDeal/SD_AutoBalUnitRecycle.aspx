<%@ Page Language="C#" AutoEventWireup="true" CodeFile="SD_AutoBalUnitRecycle.aspx.cs" Inherits="ASP_SpecialDeal_SD_AutoBalUnitRecycle"  EnableEventValidation="false" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
     <title>自动回收结算单元配置</title>
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
        <table cellpadding="0" cellspacing="0"  style="  width:100%;">
        <tr>
        <td> 异常处理->自动回收结算单元配置</td>
        <td align="right" style=" height:13px;">&nbsp;</td>
        </tr>
        </table>
       
        </div>

    <asp:BulletedList ID="bulMsgShow" runat="server"/>
    <script runat="server" >public override void ErrorMsgShow(){ErrorMsgHelper(bulMsgShow);}</script>

        <div class="con">
          <div class="base">自动回收结算单元查看</div>
         <div class="kuang5">
   <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
     <tr>
       <td><div align="right">结算单元编码:</div></td>
       <td>
       <asp:TextBox ID="txtSBalUnitNo" CssClass="input" runat="server" MaxLength="8"></asp:TextBox>
       </td>
       <td><asp:Button ID="btnQuery" runat="server" Text="查询" CssClass="button1" 
                        OnClick="btnQuery_Click" /></td>
     </tr>
   </table>
 </div>
  <div class="kuang5">
  <div class="gdtb" style="height:300px">
  <table width="800" border="0" cellpadding="0" cellspacing="0" class="tab1" >
      
      
      <asp:GridView ID="lvwTypeList" runat="server"
         Width = "98%"
        CssClass="tab1"
        HeaderStyle-CssClass="tabbt"
        AlternatingRowStyle-CssClass="tabjg"
        SelectedRowStyle-CssClass="tabsel"
        PagerSettings-Mode=NumericFirstLast
        PagerStyle-HorizontalAlign=left
        PagerStyle-VerticalAlign=Top
        AutoGenerateColumns="false"
        OnRowCreated="lvwStaff_RowCreated" 
        OnSelectedIndexChanged="lvwStaff_SelectedIndexChanged"
        >
         <Columns>
                <asp:BoundField HeaderText="结算单元编码" DataField="BALUNITNO"/>
                <asp:BoundField HeaderText="结算单元名称" DataField="BALUNIT"/>
                <asp:BoundField HeaderText="自动回收生效日期" DataField="EFFECTIVEDATE"/>
                <asp:TemplateField HeaderText="是否转账">
                       <ItemTemplate>
                         <asp:Label ID="labDimTag" Text='<%# Eval("STATE").ToString() == "0" ? "否" : "是" %>' runat="server"></asp:Label>
                       </ItemTemplate>
                      </asp:TemplateField>
            </Columns>   
            

             <EmptyDataTemplate>
                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                  <tr class="tabbt">
                    <td>结算单元编码</td>
                    <td>结算单元名称</td>
                    <td>自动回收生效日期</td>
                    <td>是否转账</td>
                    
                  </tr>
                  </table>
            </EmptyDataTemplate>


            <PagerSettings Mode="NumericFirstLast" />
            <SelectedRowStyle CssClass="tabsel" />
            <PagerStyle HorizontalAlign="Left" VerticalAlign="Top" />
            <HeaderStyle CssClass="tabbt" />
            <AlternatingRowStyle CssClass="tabjg" />        
        </asp:GridView>
    </table>
  </div>
  </div>
  <div class="kuang5">
   <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
     <tr>
       <tr>

                  <td align="right">结算单元编码:</td>
                  <td>
                  <asp:HiddenField ID="hidInputBalUnitNo" runat="server" />
                  <asp:TextBox ID="txtInputBalUnitNo" CssClass="input" runat="server" MaxLength="8"></asp:TextBox>
                  </td>
        
     <td><div align="right">自动回收生效日期:</div></td>
       <td>
        <asp:TextBox runat="server" ID="txtEffectDate" CssClass="inputmid"  MaxLength="10"/>
        <ajaxToolkit:CalendarExtender ID="FCalendar" runat="server" TargetControlID="txtEffectDate"
            Format="yyyy-MM-dd" />
       </td>
      <td><div align="right">是否转账:</div></td>
       <td><asp:CheckBox ID="chkIsState" runat="server" /></td>
        <td><div align="right">是否有效:</div></td>
       <td><asp:CheckBox ID="chkUseTag" runat="server" Checked /></td>
     </tr>
    
     <tr>
       <td><div align="right"></div></td>
       <td>&nbsp;</td>
       <td colspan="4"><table width="300" border="0" align="right" cellpadding="0" cellspacing="0">
         <tr>
           <td><asp:Button ID="btnStaffAdd" runat="server" Text="增加" CssClass="button1" OnClick="btnAdd_Click" /></td>
           <td><asp:Button ID="btnStaffModify" runat="server" Text="修改" CssClass="button1" OnClick="btnModify_Click" /></td>
           <td><asp:Button ID="btnStaffDelete" runat="server" Text="删除" CssClass="button1" OnClick="btnDelete_Click" /></td>
         </tr>
            </table></td>
      </tr>
   </table>
 </div>



         </div>


   <div class="footall"></div>
  
<div class="btns">
     

</div>

</ContentTemplate>
</asp:UpdatePanel>

    </form>
</body>
</html>

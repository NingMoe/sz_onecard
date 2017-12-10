<%@ Page Language="C#" AutoEventWireup="true" CodeFile="SD_AutoTransferRecycle.aspx.cs" Inherits="ASP_SpecialDeal_SD_AutoTransferRecycle" EnableEventValidation="false"  %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <title>转账账单回收</title>
    <script type="text/javascript" src="../../js/myext.js"></script>
	<link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" /> 
    
        <script type="text/JavaScript">
        
        function submitConfirm(checkednum){

            if(true)
           {
                MyExtConfirm('确认',
		        '已选中'+checkednum+'行，是否确认回收？'
		        , submitConfirmCallback);
           }
           
		}
		function submitConfirmCallback(btn)
        {
             if (btn == 'yes') {
                $get('btnConfirm').click();
            }
        }
    </script>
    
</head>
<body>
    <form id="form1" runat="server">
      <div class="tb">异常处理->转账账单回收</div>
      
      <ajaxToolkit:ToolkitScriptManager runat="Server" EnableScriptGlobalization="true"
            EnableScriptLocalization="true" ID="ScriptManager2" />
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
         
        <asp:BulletedList ID="bulMsgShow" runat="server"/>
         <script runat="server" >public override void ErrorMsgShow(){ErrorMsgHelper(bulMsgShow);}</script>
         
      
      <div class="con">
      <asp:Panel runat="server" ID="panCond" >    
         <div class="kuang5">
           <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
               <tr>
               <td><div align="right">行业名称:</div></td>
               <td>
               <asp:DropDownList ID="selCalling" CssClass="inputmidder" runat="server"
                     AutoPostBack="true" OnSelectedIndexChanged="selCalling_SelectedIndexChanged"/>
                     
               </td>
               <td><div align="right">IC卡号:</div></td>
               <td><asp:TextBox ID="txtCardNo" runat="server" CssClass="input" MaxLength="16"/>
               </td>
               </tr>
               <tr>
               <td><div align="right">单位名称:</div></td>
               <td>
               <asp:DropDownList ID="selCorp" CssClass="inputmidder" runat="server" AutoPostBack="true" 
                     OnSelectedIndexChanged="selCorp_SelectedIndexChanged"/>
                     
               </td>
               <td><div align="right">结算单元编码:</div></td>
               <td><asp:TextBox runat="server" CssClass="input" ID="txtBalUnitNo" Width="80px" MaxLength="8" />
               </td>
               </tr>
               <tr>
               <td><div align="right"><asp:Label runat="server" ID="labUnitName" Text="部门名称" />:</div></td>
               <td><asp:DropDownList ID="selDepart" CssClass="inputmidder" runat="server"/>
                    
               </td>
               <td><div align="right">交易日期:</div></td>
               <td><asp:TextBox ID="txtStartDate" runat="server" CssClass="input" MaxLength="8"  
                            Width="80px" />
                   <ajaxToolkit:CalendarExtender ID="CalendarExtender2" 
                          runat="server" TargetControlID="txtStartDate" Format="yyyyMMdd"  PopupPosition="BottomLeft" />
               -&nbsp;<asp:TextBox ID="txtEndDate" runat="server" CssClass="input" MaxLength="8"  
                            Width="80px" />
                   <ajaxToolkit:CalendarExtender ID="CalendarExtender4" 
                          runat="server" TargetControlID="txtEndDate" Format="yyyyMMdd"  PopupPosition="BottomLeft" />
               
               </td>     
               </tr>
          
           </table>
         </div>
         </asp:Panel>
         
         
        <table width="100%" border="0" cellpadding="0" cellspacing="0" class="12text">
          <tr>
            <td width="30%"><div class="jieguo">转账账单信息</div></td>
            <td width="20%"><asp:Label runat="server" ID="labCount"/>
            </td>
            <td width="20%"><asp:Label runat="server" ID="labSum"/>
            </td>
            <td><asp:Button ID="btnQuery" Width="50px" runat="server" Text="查询" CssClass="button1" OnClick="btnQuery_Click" /></td>
          </tr>
        </table>
         <%-- <div class="jieguo">转账账单信息</div>--%>
          <div class="kuang5">
            <div id="gdtb" style="height:350px">
              
              <asp:GridView ID="gvResult" runat="server"
                Width = "200%"
                CssClass="tab1"
                HeaderStyle-CssClass="tabbt"
                AlternatingRowStyle-CssClass="tabjg"
                SelectedRowStyle-CssClass="tabsel"
                AllowPaging="True"
                PageSize="100"
                PagerSettings-Mode="NumericFirstLast"
                PagerStyle-HorizontalAlign="left"
                PagerStyle-VerticalAlign="Top"
                AutoGenerateColumns="False"
                OnPageIndexChanging="gvResult_Page"
                OnRowDataBound="gvResult_RowDataBound"
                >
                   <Columns>
                        <asp:BoundField DataField="ID"      HeaderText="ID"/>  

                          <asp:TemplateField>
                            <HeaderTemplate>
                              <asp:CheckBox ID="CheckBox1" runat="server"  AutoPostBack="true" OnCheckedChanged="CheckAll" />
                            </HeaderTemplate>
                            <ItemTemplate>
                              <asp:CheckBox ID="ItemCheckBox" runat="server"/>
                            </ItemTemplate>
                          </asp:TemplateField>
                          <asp:BoundField DataField="CARDNO"       HeaderText="IC卡号"/>
                          <asp:BoundField DataField="CARDTRADENO"       HeaderText="卡交易序列号"/>           
                          <asp:BoundField DataField="SAMNO"   HeaderText="PSAM编号"/>  
                          <asp:BoundField DataField="POSNO"      HeaderText="POS编号"/>  
                          <asp:BoundField DataField="TRADEDATE"      HeaderText="交易日期"/>           
                          <asp:BoundField DataField="TRADETIME"    HeaderText="交易时间"/>             
                          <asp:BoundField DataField="PREMONEY"    HeaderText="交易前￥"/>             
                          <asp:BoundField DataField="TRADEMONEY"     HeaderText="交易￥"/>                 
                          <asp:BoundField DataField="SMONEY"   HeaderText="应收￥"/> 
                          <asp:BoundField DataField="TRADECOMFEE"          HeaderText="结算佣金" />
                          <asp:BoundField DataField="BALUNITNO"          HeaderText="结算单元编码" />
                          <asp:BoundField DataField="BALUNIT"  HeaderText=" 结算单元名称"/>
                          <asp:BoundField DataField="CALLNONAME"  HeaderText="行业名称"/>
                          <asp:BoundField DataField="CORPNONAME"   HeaderText="单位名称"/>          
                          <asp:BoundField DataField="DEPARTNONAME"   HeaderText="部门名称"/>
                          <asp:BoundField DataField="ERRORREASON"   HeaderText="错误原因"/>   
                          <asp:BoundField DataField="DEALTIME"     HeaderText="处理时间"/>  
                          <asp:BoundField DataField="RENEWTYPE"     HeaderText="人工回收方式"/>   
                          <asp:BoundField DataField="BALTIME" HeaderText="结算处理时间"/>  
                          
                          
                    </Columns>           
                    <EmptyDataTemplate>
                        <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                          <tr class="tabbt">
                            <td><input type="checkbox" /></td>
                              <td>IC卡号</td>
                              <td>卡交易序列号</td>
                              <td>PSAM编号</td>
                              <td>POS编号</td>
                              <td>交易日期</td>
                              <td>交易时间</td>
                              <td>交易前￥</td>
                              <td>交易￥</td>
                              <td>应收￥</td>
                              <td>结算佣金</td>
                              <td>结算单元编码</td>
                              <td>结算单元名称</td>
                              <td>行业名称</td>
                              <td>单位名称</td>
                              <td>部门名称</td>
                              <td>错误原因</td>
                              <td>处理时间</td>
                              <td>人工回收方式</td>
                              <td>结算处理时间</td>    
                           </tr>
                          </table>
                    </EmptyDataTemplate>
                </asp:GridView>
             
            </div>
          </div>
          <table width="100%" border="0" cellpadding="0" cellspacing="0" class="12text">
          <tr>
            <td><div align="right">
              <asp:LinkButton runat="server" ID="btnConfirm" OnClick="btnRecycle_Click" />
              <asp:Button ID="btnRecycle" CssClass="button1" runat="server" Text="回收" OnClick="submitConfirm_Click" />
              <%--<asp:Button ID="btnRecycle" runat="server" Text="回收" CssClass="button1" OnClick="btnRecycle_Click" />--%>
              </div></td>
              <td> &nbsp;&nbsp; &nbsp;&nbsp;</td>
          </tr>
        </table>
          
        </div>

    
      </ContentTemplate>
     </asp:UpdatePanel>
  
    </form>
</body>
</html>

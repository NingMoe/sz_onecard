<%@ Page Language="C#" AutoEventWireup="true" CodeFile="SD_ConsumeErrorInfoRecycle.aspx.cs" Inherits="ASP_SpecialDeal_SD_ConsumeErrorInfoRecycle" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <title><%=labTitle.Text %></title>
    <script type="text/javascript" src="../../js/myext.js"></script>
	<link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
   
</head>
<body>
    <form id="form1" runat="server">
     <asp:Label runat="server" ID="labTitle" Visible="false"/>
      <div class="tb">异常处理-><%=labTitle.Text %></div>
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
 <asp:HiddenField runat="server" ID="hidGardenRec" />        
   
         <asp:BulletedList ID="bulMsgShow" runat="server"/>
         <script runat="server" >public override void ErrorMsgShow(){ErrorMsgHelper(bulMsgShow);}</script>
                 
         <div class="con">
        	
<%--         <div class="card">查询条件</div>
--%>     
         <asp:Panel runat="server" ID="panCond" >    
         <div class="kuang5">
           <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
               <tr>
                   <td> <div align="right">处理年月:</div></td>
                   <td>
                       <asp:TextBox ID="txtDealDate" runat="server" CssClass="input" Width="50px" MaxLength="7" /><span class="red">*</span>(yyyy-MM)
                       <asp:HiddenField ID="hidDealDate" runat="server" />
                       &nbsp;
                       结算单元编码:<asp:TextBox runat="server" CssClass="input" ID="txtBalUnitNo" Width="80px" MaxLength="8" />
                 &nbsp;&nbsp;
                       处理日期:<asp:TextBox ID="txtDealDateExt" runat="server" CssClass="input" MaxLength="8" Width="60px" />
                         <ajaxToolkit:CalendarExtender ID="CalendarExtender4" 
                          runat="server" TargetControlID="txtDealDateExt" Format="yyyyMMdd"  PopupPosition="BottomLeft" />
                   &nbsp;&nbsp;
                   错误原因:
                   <asp:DropDownList ID="selErrorReasonCode" CssClass="inputmid" runat="server"/>
                   </td>
               </tr>
               <tr>
               <td><div align="right">行业名称:</div></td>
               <td>
                    <asp:DropDownList ID="selCalling" CssClass="inputmidder" runat="server"
                     AutoPostBack="true" OnSelectedIndexChanged="selCalling_SelectedIndexChanged"/>
               &nbsp;&nbsp;
               交易日期:<asp:TextBox ID="txtStartDate" runat="server" CssClass="input" MaxLength="8"  Width="60px" />
                   <ajaxToolkit:CalendarExtender ID="BeginCalendar" 
                          runat="server" TargetControlID="txtStartDate" Format="yyyyMMdd"  PopupPosition="BottomLeft" />
               -&nbsp;<asp:TextBox ID="txtEndDate" runat="server" CssClass="input" MaxLength="8"  Width="60px" />
                   <ajaxToolkit:CalendarExtender ID="CalendarExtender2" 
                          runat="server" TargetControlID="txtEndDate" Format="yyyyMMdd"  PopupPosition="BottomLeft" />
               &nbsp;&nbsp;
               交易类型:
                   <asp:DropDownList ID="ddlTradeType" CssClass="input" runat="server"/>
               </td>
               </tr>
               <tr>
               <td><div align="right">单位名称:</div></td>
               <td>
                    <asp:DropDownList ID="selCorp" CssClass="inputmidder" runat="server" AutoPostBack="true" 
                            OnSelectedIndexChanged="selCorp_SelectedIndexChanged"/>
                &nbsp;&nbsp;
                PSAM:<asp:TextBox ID="txtPasmNo" runat="server" CssClass="input" MaxLength="12" Width="90px" />
                   &nbsp;&nbsp;
                   POS:
                   <asp:TextBox ID="txtPosNo" runat="server" CssClass="input" MaxLength="6" Width="45px" /> </td>
               </tr>
               <tr>
               <td><div align="right"><asp:Label runat="server" ID="labUnitName" Text="部门名称" />:</div></td>
               <td>
                    <asp:DropDownList ID="selDepart" CssClass="inputmidder" runat="server"/>
               &nbsp;&nbsp;
               IC卡号:<asp:TextBox ID="txtCardNo" runat="server" CssClass="input" MaxLength="16"/>
               &nbsp;&nbsp;
               回收状态:
               <asp:DropDownList runat="server" ID="selRecyState" CssClass="input"/></td>
               </tr>
          
           </table>
         </div>
         </asp:Panel>
         
          <table width="100%" border="0" cellpadding="0" cellspacing="0" class="12text">
          <tr>
            <td width="30%"><div class="jieguo">异常消费清单</div></td>
            <td width="20%"><asp:Label runat="server" ID="labCount"/>
            </td>
            <td width="20%"><asp:Label runat="server" ID="labSum"/>
            </td>
            <td><asp:Button ID="btnQuery" Width="50px" runat="server" Text="查询" CssClass="button1" OnClick="btnQuery_Click" /></td>
          </tr>
        </table>

          <div class="kuang5">

               <asp:GridView ID="gvResult" runat="server"
                Width = "2400"
                CssClass="tab1"
                HeaderStyle-CssClass="tabbt"
                AlternatingRowStyle-CssClass="tabjg"
                SelectedRowStyle-CssClass="tabsel"
                AllowPaging="True"
                PageSize="1000"
                PagerSettings-Mode="NumericFirstLast"
                PagerStyle-HorizontalAlign="left"
                PagerStyle-VerticalAlign="Top"
                AutoGenerateColumns="False" 
                OnPageIndexChanging="gvResult_Page"
                OnRowDataBound="gvResult_RowDataBound"
                EmptyDataText="没有数据记录!" >
                   <Columns>
                          <asp:TemplateField>
                            <HeaderTemplate>
                              <asp:CheckBox ID="CheckBox1" runat="server"  AutoPostBack="true" OnCheckedChanged="CheckAll" />
                            </HeaderTemplate>
                            <ItemTemplate>
                              <asp:CheckBox ID="ItemCheckBox" runat="server"/>
                            </ItemTemplate>
                          </asp:TemplateField>
                          <asp:BoundField DataField="ID"           HeaderText="ID"/>  
                          <asp:BoundField DataField="RECYSTATE"    HeaderText="回收状态" />
                          <asp:BoundField DataField="CARDNO"       HeaderText="IC卡号"/> 
                          <asp:BoundField DataField="ICTRADETYPECODE"       HeaderText="交易类型"/> 
                          <asp:BoundField DataField="BALUNIT"      HeaderText="结算单元"/> 
                          <asp:BoundField DataField="SAMNO"        HeaderText="PSAM"/>     
                          <asp:BoundField DataField="POSNO"        HeaderText="POS"/> 
                          <asp:BoundField DataField="DEALTIME"     HeaderText="处理时间"  HtmlEncode="false" DataFormatString="{0:yyyy-MM-dd HH:mm:ss}" />  
                          <asp:BoundField DataField="TRADEDATE"    HeaderText="交易日期"/>             
                          <asp:BoundField DataField="TRADETIME"    HeaderText="交易时间"/>             
                          <asp:BoundField DataField="PREMONEY"     HeaderText="交易前￥"  DataFormatString="{0:n}" HtmlEncode="False"/>                 
                          <asp:BoundField DataField="TRADEMONEY"   HeaderText="交易￥"  DataFormatString="{0:n}" HtmlEncode="False"/> 
                          <asp:BoundField DataField="ERRORREASON"  HeaderText="错误原因" />
                          <asp:BoundField DataField="RECYSTAFF"    HeaderText="回收员工" />
                          <asp:BoundField DataField="RENEWTIME"    HeaderText="回收时间" HtmlEncode="false" DataFormatString="{0:yyyy-MM-dd HH:mm:ss}" />                          
                          <asp:BoundField DataField="RENEWREMARK"  HeaderText="回收说明" />                          
                          <asp:BoundField DataField="CARDTRADENO"  HeaderText="卡片交易#"/>
                          <asp:BoundField DataField="CALLINGNAME"  HeaderText="行业"/>                 
                          <asp:BoundField DataField="CORPNAME"     HeaderText="单位"/>            
                          <asp:BoundField DataField="DEPARTNAME"   HeaderText="部门"/>                     
                    </Columns>           
                </asp:GridView>
          </div>
         <asp:Panel runat="server" ID="panel1" Visible="false">
          <table width="100%" border="0" cellpadding="0" cellspacing="0" class="12text">
          <tr>
            <td><div class="jieguo">回收处理</div></td>
            <td>(在"处理方式"为"手工指定结算单元"时，需要选择"结算单元"; 可在"名称查询"框中输入部分名字，然后点击"查结算单元"，就可以生成"结算单元列表"，然后从中选择即可!)</td>
          </tr>
        </table>
         <div class="kuang5">  
           <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
            <tr>
              <td align="right">回收说明:</td>
              <td>
                <asp:TextBox ID="txtRenewRemark" Enabled="false" runat="server" CssClass="inputmidder" MaxLength="150" />
              </td>
              <td align="right">名称查询:</td>
              <td>
              <asp:TextBox ID="txtBalUnit" CssClass="inputmid" runat="server" MaxLength="50"/>
             &nbsp;<asp:Button runat="server" ID="btnQryBalUnit" Text="查结算单元" CssClass="button1" OnClick="txtBalUnit_TextChanged" />
              </td>
              <td> &nbsp;
              </td>
              <td>&nbsp;</td>
            </tr>
            <tr>
              <td align="right">处理方式:</td>
              <td>
              <asp:DropDownList ID="selActionType" runat="server" CssClass="inputmid">
                <asp:ListItem Text="---请选择---" Value="" />
                <asp:ListItem Text="自动补全结算单元" Value="AutoFillBalUnit"/>
                <asp:ListItem Text="手工指定结算单元" Value="ManuFillBalUnit"/>
                <asp:ListItem Text="回收" Value="Recycle" />
                <asp:ListItem Text="作废" Value="Cancel" />
              </asp:DropDownList>
              </td>
              <td align="right">结算单元:</td>
              <td><asp:DropDownList ID="selBalUint" CssClass="inputmidder" runat="server"/></td>
              <td><asp:Button ID="btnSubmit" runat="server" Text="提交" CssClass="button1" OnClick="btnSubmit_Click" /></td>
              <td>&nbsp;</td>
            </tr>
           </table>
         </div>
        </asp:Panel>
         </div>
 
        </ContentTemplate>
       </asp:UpdatePanel>
    </form>
</body>
</html>

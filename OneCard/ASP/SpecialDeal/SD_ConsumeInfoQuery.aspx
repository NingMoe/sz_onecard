<%@ Page Language="C#" AutoEventWireup="true" CodeFile="SD_ConsumeInfoQuery.aspx.cs" Inherits="ASP_SpecialDeal_SD_ConsumeInfoQuery" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <title>正常消费清单查询</title>
    <script type="text/javascript" src="../../js/myext.js"></script>
	<link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
      <div class="tb">异常处理->正常消费清单查询</div>
      
      <ajaxToolkit:ToolkitScriptManager runat="Server"
            AsyncPostBackTimeout="600"
            EnableScriptGlobalization="true"
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
         <div class="card">查询方式</div>
         <div class="kuang5">
           <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
            <tr>
            <td><div align="right">行业名称:</div></td>
               <td>
                    <asp:DropDownList ID="selCalling" CssClass="inputmidder" runat="server" 
                    AutoPostBack="true" OnSelectedIndexChanged="selCalling_SelectedIndexChanged"/>
               </td>
               <td><div align="right">交易起始日期:</div></td>
               <td>
                   <asp:TextBox ID="txtStartDate" runat="server" CssClass="input" MaxLength="8" /><span class="red">*</span>
                   <ajaxToolkit:CalendarExtender ID="BeginCalendar" 
                          runat="server" TargetControlID="txtStartDate" Format="yyyyMMdd"  PopupPosition="BottomLeft" />
               </td>
               <td ><div align="right">交易终止日期:</div></td>
               <td >
                  <asp:TextBox ID="txtEndDate" runat="server" CssClass="input" MaxLength="8"/><span class="red">*</span>
                   <ajaxToolkit:CalendarExtender ID="CalendarExtender1" 
                          runat="server" TargetControlID="txtEndDate" Format="yyyyMMdd"  PopupPosition="BottomLeft" />
               </td>
               </tr>
               <tr>
               <td><div align="right">单位名称:</div></td>
               <td>
                    <asp:DropDownList ID="selCorp" CssClass="inputmidder" runat="server" AutoPostBack="true" 
                             OnSelectedIndexChanged="selCorp_SelectedIndexChanged"/>
                </td>
                <td><div align="right">POS编号:</div></td>
               <td><asp:TextBox ID="txtPosNo" runat="server" CssClass="input" MaxLength="6" /> </td>
               <td><div align="right">IC卡号 :</div></td>
               <td><asp:TextBox ID="txtCardNo" runat="server" CssClass="input" MaxLength="16"/></td>
               </tr>
               <tr>
               <td><div align="right">部门名称:</div></td>
               <td>
                    <asp:DropDownList ID="selDepart" CssClass="inputmidder" runat="server"/>
               </td>              
               <td><div align="right">PSAM编号:</div></td>
               <td><asp:TextBox ID="txtPasmNo" runat="server" CssClass="input" MaxLength="12"/></td>
               <td><div align="right">结算日期:</div></td>
                <td>
                  <asp:TextBox ID="txtDealDate" runat="server" CssClass="input" MaxLength="8"/>
                   <ajaxToolkit:CalendarExtender ID="CalendarExtender2" 
                          runat="server" TargetControlID="txtDealDate" Format="yyyyMMdd"  PopupPosition="BottomLeft" />
                </td>
               </tr>
           </table>
         </div>

          <table width="100%" border="0" cellpadding="0" cellspacing="0" class="12text">
          <tr>
            <td width="30%"><div class="jieguo">消费清单信息</div></td>
            <td width="10%"><div align="right">总交易笔数:</div></td>
            <td width="10%"><asp:Label runat="server" ID="labCount"/>
            </td>
            <td width="10%"><div align="right">总交易金额:</div></td>
            <td width="10%"><asp:Label runat="server" ID="labSum"/>
            </td>
            <td><asp:Button ID="btnQuery" runat="server" Text="查询" CssClass="button1" OnClick="btnQuery_Click" /></td>
            <td><asp:Button ID="btnSave" runat="server" Text="导出" CssClass="button1" OnClick="btnSave_Click" /></td>
          </tr>
        </table>
          <div class="kuang5">
        
           <asp:GridView ID="lvwConsumeInfo" runat="server"
                    CssClass="tab1"
                    Width ="150%"
                    HeaderStyle-CssClass="tabbt"
                    AlternatingRowStyle-CssClass="tabjg"
                    SelectedRowStyle-CssClass="tabsel"
                    AllowPaging="True"
                    PageSize="1000"
                    PagerSettings-Mode="NumericFirstLast"
                    PagerStyle-HorizontalAlign="Left"
                    PagerStyle-VerticalAlign="Top"
                    AutoGenerateColumns="False"
                    OnPageIndexChanging="lvwConsumeInfo_Page" >
                    <Columns>
                          <asp:BoundField DataField="CARDNO"       HeaderText="IC卡号"/>      
                          <asp:BoundField DataField="DEALTIME"     HeaderText="结算日期" DataFormatString="{0:yyyy-MM-dd HH:mm:ss}" HtmlEncode="false"/> 
                          <asp:BoundField DataField="TRADEDATE"    HeaderText="交易日期"/>             
                          <asp:BoundField DataField="TRADETIME"    HeaderText="交易时间"/>             
                          <asp:BoundField DataField="PREMONEY"     HeaderText="交易前￥"/>                 
                          <asp:BoundField DataField="TRADEMONEY"   HeaderText="交易￥"/> 
                          <asp:BoundField DataField="CARDTRADENO"  HeaderText="卡片交易#"/>
                          <asp:BoundField DataField="POSNO"        HeaderText="POS编号"/> 
                          <asp:BoundField DataField="CALLINGNAME"  HeaderText="行业"/>                 
                          <asp:BoundField DataField="CORPNAME"     HeaderText="单位"/>            
                          <asp:BoundField DataField="DEPARTNAME"   HeaderText="部门"/>  
                          <asp:BoundField DataField="SAMNO"        HeaderText="PSAM编号"/>              
                          <asp:BoundField DataField="ASN"          HeaderText="卡片ASN号" />
                          <asp:BoundField DataField="TAC"          HeaderText="TAC码"/>         
                   </Columns>   
                   
                   <EmptyDataTemplate>
                      <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                         <tr class="tabbt">
                            <td>IC卡号</td>
                            <td>结算日期</td>
                            <td>交易日期</td>
                            <td>交易时间</td>
                            <td>交易前￥</td>
                            <td>交易￥</td>
                            <td>卡片交易#</td>
                            <td>POS编号</td>
                            <td>行业</td>
                            <td>单位</td>
                            <td>部门</td>
                            <td>PSAM编号</td>
                            <td>卡片ASN号</td>
                            <td>TAC码</td>
                          </tr>
                      </table>
                   </EmptyDataTemplate>
                  </asp:GridView>
          
          </div>
         </div>
        
        </ContentTemplate>
        <Triggers>
            <asp:PostBackTrigger ControlID="btnSave" />
        </Triggers>
      </asp:UpdatePanel>       
      
    </form>
</body>
</html>

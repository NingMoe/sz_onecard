<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PS_ZEROTRADEPOS_COLLECT.aspx.cs" Inherits="ASP_PartnerShip_PS_ZEROTRADEPOS_COLLECT" EnableEventValidation="false" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>零交易POS录入</title>
	<link rel="stylesheet" type="text/css" href="../../css/frame.css" />
	<script type="text/javascript" src="../../js/print.js"></script>
     <script type="text/javascript" src="../../js/myext.js"></script>
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
       <div class="tb">合作伙伴->零交易POS录入</div>
       
        <ajaxToolkit:ToolkitScriptManager runat="Server" EnableScriptGlobalization="true"
            EnableScriptLocalization="true" ID="ScriptManager2" AsyncPostBackTimeout="600" />
            <script type="text/javascript" language="javascript">
                var swpmIntance = Sys.WebForms.PageRequestManager.getInstance();
                swpmIntance.add_initializeRequest(BeginRequestHandler);
                swpmIntance.add_pageLoading(EndRequestHandler);
                function BeginRequestHandler(sender, args) {
                    try { MyExtShow('请等待', '正在提交后台处理中...'); } catch (ex) { }
                }
                function EndRequestHandler(sender, args) {
                    try { MyExtHide(); } catch (ex) { }
                }
          </script>
        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
         <ContentTemplate>
         
         <asp:BulletedList ID="bulMsgShow" runat="server"/>
         <script runat="server" >public override void ErrorMsgShow(){ErrorMsgHelper(bulMsgShow);}</script>
         
         <div class="con">
	       <div class="card">查询</div>
           <div class="kuang5">
           <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
            <tr>
            <td><div align="right">行业名称:</div></td>
              <td>
                    <asp:DropDownList ID="selCalling" CssClass="inputmidder" runat="server" AutoPostBack="true"  OnSelectedIndexChanged="selCalling_SelectedIndexChanged" >
                    </asp:DropDownList>
              </td>
               <td><div align="right">交易日期:</div></td>
               <td><asp:TextBox ID="txtTradeDate" runat="server" CssClass="input" MaxLength="10" ></asp:TextBox>
                    <ajaxToolkit:CalendarExtender ID="CalendarExtender2" 
                          runat="server" TargetControlID="txtTradeDate" Format="yyyyMMdd"  PopupPosition="BottomLeft" />
               </td>
            </tr>
            <tr>
              <td><div align="right">单位名称:</div></td>
              <td><asp:DropDownList ID="selCorp" CssClass="inputmidder" runat="server" AutoPostBack="true" OnSelectedIndexChanged="selCorp_SelectedIndexChanged" >
                    </asp:DropDownList>
              </td>
              <td><div align="right">POS号:</div></td>
              <td><asp:TextBox ID="txtPosno" runat="server" CssClass="input"></asp:TextBox></td>
               </tr>
               <tr>
              <td><div align="right">部门名称:</div></td>
              <td>
                    <asp:DropDownList ID="selDepart" CssClass="inputmidder" runat="server">
                    </asp:DropDownList>
              </td>
              <td align="right">结算单元:</td>
                  <td><asp:DropDownList ID="selBalUint" CssClass="inputmidder" runat="server" AutoPostBack="true">
                      </asp:DropDownList>
                  </td>
              
              <td><asp:Button ID="btnQuery" runat="server" Text="查询" CssClass="button1" OnClick="btnQuery_Click" /></td>
            </tr>
           </table>
         </div>
         <asp:HiddenField ID="hiddenBALUNITNO" runat="server" />
         <asp:HiddenField ID="hiddenPOSNO" runat="server" />

           <div class="jieguo">POS信息</div>
          <div class="kuang5">
            <div id="gdtb" style=" height:200px;">        
              <asp:GridView ID="gvResult" runat="server"
                    CssClass="tab1"
                    Width ="100%"
                    HeaderStyle-CssClass="tabbt"
                    AlternatingRowStyle-CssClass="tabjg"
                    SelectedRowStyle-CssClass="tabsel"
                    AllowPaging="True"
                    PageSize="6"
                    PagerSettings-Mode="NumericFirstLast"
                    PagerStyle-HorizontalAlign="Left"
                    PagerStyle-VerticalAlign="Top"
                    AutoGenerateColumns="False"
                    OnPageIndexChanging="gvResult_Page"
                    OnSelectedIndexChanged="gvResult_SelectedIndexChanged"
                    OnRowCreated="gvResult_RowCreated">
                    <Columns>
                    
                          <asp:BoundField DataField="BALUNITNO"       HeaderText="结算单元编码"/>      
                          <asp:BoundField DataField="BALUNIT"  HeaderText="结算单元"/>                            
                          <asp:BoundField DataField="POSNO"    HeaderText="POS号"/>                           
                   </Columns>   
                   <EmptyDataTemplate>
                      <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                         <tr class="tabbt">
                              <td>结算单元编码</td>
                              <td>结算单元</td>
                              <td>POS号</td>
                           </tr>
                      </table>
                   </EmptyDataTemplate>
                  </asp:GridView>
            </div>
          </div>
          <div class="card">零交易信息</div>
          <div class="kuang5">
            <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
              <tr>
                <td width="9%" ><div align="right">结算单元编号:</div></td>
                <td>
                   <asp:Label ID="labBALUNITNO" runat="server"  ></asp:Label>
                </td>
                <td width="10%"><div align="right">结算单元:</div></td>
                <td>
                 <asp:Label ID="labBALUNIT" runat="server"   ></asp:Label>
                </td>
                <td><div align="right">POS号:</div></td>
                <td>
                  <asp:Label ID="labPOSNO" runat="server"  ></asp:Label>
                </td>
              </tr>
              <tr>
                <td><div align="right">门店名称:</div></td>
                <td>                    
                    <asp:TextBox ID="txtShop" runat="server" CssClass="input" MaxLength="16" ></asp:TextBox>
                    <span class="red">*</span>
                </td>
                <td><div align="right">协议到期时间:</div></td>
                <td><asp:TextBox ID="txtEndDate" runat="server" CssClass="input"></asp:TextBox>
                <ajaxToolkit:CalendarExtender ID="CalendarExtender1" 
                          runat="server" TargetControlID="txtEndDate" Format="yyyyMMdd"  PopupPosition="TopLeft" />
                          <span class="red">*</span></td>
                <td><div align="right">零交易原因:</div></td>
                <td> 
                    <asp:DropDownList ID="selReason" runat="server" CssClass="inputmid"></asp:DropDownList>
                    <span class="red">*</span>
                    <asp:HiddenField ID="hidTradeMoneyExt" runat="server" />
                </td>
              </tr>
            </table>
          </div>
        </div>
        <div class="btns">
          <table width="100" border="0" align="right" cellpadding="0" cellspacing="0">
            <tr>
              <td><asp:Button ID="btnInput" runat="server" Text="提交" CssClass="button1" OnClick="btnInput_Click" /></td>
            </tr>
          </table>
        </div>
       </ContentTemplate>
     </asp:UpdatePanel>
    </form>
</body>
</html>
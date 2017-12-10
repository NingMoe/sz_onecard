<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PS_BalUnitComScheme.aspx.cs" Inherits="ASP_PartnerShip_PS_BalUnitComScheme"  EnableEventValidation="false" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <title>佣金方案维护</title>
	<link rel="stylesheet" type="text/css" href="../../css/frame.css" />
   <link href="../../css/card.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
    <div class="tb">合作伙伴->结算单元对应佣金方案关系维护</div>
    
    <ajaxToolkit:ToolkitScriptManager runat="Server" EnableScriptGlobalization="true"
            EnableScriptLocalization="true" ID="ScriptManager2" />
       <asp:UpdatePanel ID="UpdatePanel1" runat="server">
           <ContentTemplate>
           <asp:BulletedList ID="bulMsgShow" runat="server"/>
         <script runat="server" >public override void ErrorMsgShow(){ErrorMsgHelper(bulMsgShow);}</script> 
           
           <div class="con">
           <div class="kuang5">
               <table width="95%" border="0" cellpadding="0" cellspacing="0" class="12text">
                 <tr>
                   <td><div align="right">行业:</div></td>
                   <td>
                    <asp:DropDownList ID="selCalling" CssClass="inputmidder" runat="server" AutoPostBack="true" 
                        OnSelectedIndexChanged="selCalling_SelectedIndexChanged" />
                   </td>
                   <td><div align="right">单位:</div></td>
                   <td>
                    <asp:DropDownList ID="selCorp" CssClass="inputmidder" runat="server" AutoPostBack="true" 
                        OnSelectedIndexChanged="selCorp_SelectedIndexChanged" />
                   </td>
                   </tr>
                   <td><div align="right">部门:</div></td>
                   <td>
                      <asp:DropDownList ID="selDepart" CssClass="inputmidder" runat="server"/>
                   </td>
                   <td><div align="right">到期:</div></td>
                   <td>
                      <asp:DropDownList ID="selExpiration" CssClass="inputmid" runat="server"/>
                   </td>
                   <td width="9%"><asp:Button ID="btnQuery" runat="server" Text="查询" CssClass="button1" OnClick="btnQuery_Click" /></td>
                  </tr>
               </table>
               
               
           </div>
           
           <div class="jieguo">结算单元-佣金方案列表</div>
           <div class="kuang5">
            <div class="gdtb" style="height:300px">
            
              <asp:GridView ID="lvwBalComSQuery" runat="server"
                    Width = "98%"
                    CssClass="tab1"
                    HeaderStyle-CssClass="tabbt"
                    AlternatingRowStyle-CssClass="tabjg"
                    SelectedRowStyle-CssClass="tabsel"
                    AllowPaging="True"
                    PageSize="10"
                    PagerSettings-Mode="NumericFirstLast"
                    PagerStyle-HorizontalAlign="left"
                    PagerStyle-VerticalAlign="Top"
                    AutoGenerateColumns="False"
                    OnPageIndexChanging="lvwBalComSQuery_Page"
                    OnSelectedIndexChanged="lvwBalComSQuery_SelectedIndexChanged"
                    OnRowCreated="lvwBalComSQuery_RowCreated">
             
                    <Columns>
                        <asp:BoundField DataField="BALUNIT"     HeaderText="结算单元"/> 
                      <%--  <asp:BoundField DataField="BALUNITTYPECODE"  Visible="false"/> --%>
                              
                        <asp:BoundField DataField="NAME"    HeaderText="佣金方案"/>  
                       <%-- <asp:BoundField DataField="SCHEMENO"      Visible="false"/> --%> 
                              
                        <asp:BoundField DataField="CALLINGNAME"   HeaderText="行业名称"/>      
                        <asp:BoundField DataField="CORPNAME"      HeaderText="单位名称"/>      
                        <asp:BoundField DataField="DEPARTNAME"    HeaderText="部门名称"/>     
                        <asp:BoundField DataField="BEGINTIME"     HeaderText="规则起始时间" DataFormatString="{0:yyyy-MM}" HtmlEncode="False"/>      
                        <asp:BoundField DataField="ENDTIME"       HeaderText="规则终止时间" DataFormatString="{0:yyyy-MM}" HtmlEncode="False"/> 
                                      
                    </Columns>           
                  
                   <EmptyDataTemplate>
                   
                   <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                     <tr class="tabbt">
                      <td>结算单元</td>
                      <td>佣金方案</td>
                      <td>行业名称</td>
                      <td>单位名称</td>
                      <td>部门名称</td>
                      <td>规则起始时间</td>
                      <td>规则终止时间</td>
                     </tr>
                   </table>
                  </EmptyDataTemplate>
                </asp:GridView>
         
            </div>
          </div>
          <div class="card">结算单元-佣金方案信息</div>
           <div class="kuang5">
           <table width="95%" border="0" cellpadding="0" cellspacing="0" class="12text">
             <tr>
               <td><div align="right">
                   结算单元:</div></td>
               <td>
                 <asp:DropDownList ID="selBalUnit" CssClass="inputmidder" runat="server" AutoPostBack="true" OnSelectedIndexChanged="selBalUnit_SelectedIndexChanged">
                 </asp:DropDownList>
               </td>
               <td><div align="right">
                   行业:</div></td>
               <td>
               <asp:Label ID="labCalling" runat="server" CssClass="inputmidder"></asp:Label>
               <asp:HiddenField  ID="hidCallingNo" runat="server"/>
               
               </td>
               </tr>
               <tr>
               <td><div align="right">
                   单位:</div></td>
               <td ><asp:Label ID="labCorp" runat="server" CssClass="inputmidder"></asp:Label></td>
               <td><div align="right">
                   部门:</div></td>
               <td><asp:Label ID="labDepart" runat="server" CssClass="inputmidder"></asp:Label></td>
             </tr>
             <tr>
               <td ><div align="right">佣金方案:</div></td>
               <td>
                 <asp:DropDownList ID="selComScheme" CssClass="inputmidder" runat="server">
                 </asp:DropDownList>
               </td>
               <td><div align="right">方案起始年月:</div></td>
               <td>
                   <asp:TextBox ID="txtBeginTime" runat="server" CssClass="input" MaxLength="7" ></asp:TextBox>
                   <ajaxToolkit:CalendarExtender ID="BeginCalendar" 
                        runat="server" TargetControlID="txtBeginTime" Format="yyyy-MM"  PopupPosition="TopLeft" />
                   终止年月:
                   <asp:TextBox ID="txtEndTime" runat="server" CssClass="input" MaxLength="7" ></asp:TextBox>
                   <ajaxToolkit:CalendarExtender ID="EndCalendar" 
                         runat="server" TargetControlID="txtEndTime" Format="yyyy-MM" PopupPosition="TopLeft"/>
                  <asp:CheckBox ID="chkEndDate" runat="server" OnCheckedChanged="chkEndDate_CheckedChanged" AutoPostBack="true"/>无限期</td>
             </tr>

             <tr>
               <td>&nbsp;</td>
               <td>&nbsp;</td>
               <td>&nbsp;</td>
               <td align="right">
                   &nbsp;<asp:Button ID="btnAdd" runat="server" Text="增加" CssClass="button1" OnClick="btnAdd_Click" />
                   &nbsp;<asp:Button ID="btnDel" runat="server" Text="删除" CssClass="button1" OnClick="btnDel_Click" />
                   &nbsp;<asp:Button ID="btnModify" runat="server" Text="修改" CssClass="button1" OnClick="btnModify_Click" />
                </td>
              </tr>
           </table>
          </div>
          </div>
           
           

        </ContentTemplate>
      </asp:UpdatePanel>   
      
   
    </form>
</body>
</html>

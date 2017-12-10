<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PS_GroupCustChange.aspx.cs" Inherits="ASP_PartnerShip_PS_GroupCustChange" EnableEventValidation="false" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">

   <title>集团客户修改</title>
	<link rel="stylesheet" type="text/css" href="../../css/frame.css" />
	
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
    <div class="tb">合作伙伴->集团客户信息修改</div>
    <ajaxToolkit:ToolkitScriptManager runat="Server" EnableScriptGlobalization="true"
            EnableScriptLocalization="true" ID="ScriptManager2" />
     <asp:UpdatePanel ID="UpdatePanel1" runat="server">
            <ContentTemplate>
            <asp:BulletedList ID="bulMsgShow" runat="server"/>
         <script runat="server" >public override void ErrorMsgShow(){ErrorMsgHelper(bulMsgShow);}</script>
            <div class="con">
             <div class="card">集团客户信息查询</div>
             <div class="kuang5">
               <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                 <tr>
                   <td width="18%"><div align="right">集团客户名称:</div></td>
                   <td width="15%">
                     <%--<asp:DropDownList ID="selGroupCust" CssClass="inputlong" runat="server">
                     </asp:DropDownList>--%>
                     <asp:TextBox ID="txtGroupName" runat="server" CssClass="inputlong" MaxLength="50" Width="200" ></asp:TextBox>
                    </td>
                   <td width="11%"><asp:Button ID="btnQuery" runat="server" Text="查询" CssClass="button1" OnClick="btnQuery_Click" /></td>
                   <td width="16%">&nbsp;</td>
                   <td width="46%">&nbsp;</td>
                 </tr>
               </table>
             </div>
              <div class="jieguo">集团客户信息</div>
              <div class="kuang5">
              <div id="gdtb" style="height:250px">
               <asp:GridView ID="lvwGroupCustQuery" runat="server"
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
                    OnPageIndexChanging="lvwGroupCustQuery_Page"
                    OnSelectedIndexChanged="lvwGroupCustQuery_SelectedIndexChanged"
                    OnRowCreated="lvwGroupCustQuery_RowCreated"
                    >
                    <Columns>
                      <asp:TemplateField HeaderText="有效标志">
                       <ItemTemplate>
                         <asp:Label ID="labUseTag" Text='<%# Eval("USETAG").ToString() == "1" ? "有效" : "无效" %>' runat="server"></asp:Label>
                       </ItemTemplate>
                      </asp:TemplateField>
                      
                      <asp:BoundField DataField="CORPCODE"       HeaderText="集团客户编码"/>
                      <asp:BoundField DataField="CORPNAME"       HeaderText="集团客户名称"/>
                      <asp:BoundField DataField="STAFFNAME"      HeaderText="客服经理"  NullDisplayText=""/>
                      <asp:BoundField DataField="LINKMAN"        HeaderText="联系人"/>
                      <asp:BoundField DataField="CORPPHONE"      HeaderText="联系电话"/>
                      <asp:BoundField DataField="CORPADD"        HeaderText="联系地址"/>
                      <asp:BoundField DataField="CORPEMAIL"      HeaderText="电子邮件"/>
                      
                        
                    </Columns>     
               
                   <EmptyDataTemplate>
                   <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                     <tr class="tabbt">
                      <td>有效标志</td>
                      <td>集团客户编码</td>
                      <td>集团客户名称</td>
                      <td>客服经理</td>
                      <td>联系人</td>
                      <td>联系电话</td>
                      <td>联系地址</td>
                      <td>电子邮件</td>
                    </tr>
                   </table>
                  </EmptyDataTemplate>
                </asp:GridView>
              </div>
              </div>
               <div class="card">选定集团客户信息</div>
               <div class="kuang5">
                <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                 <tr>
                   <td width="8%"><div align="right">客户名称:</div></td>
                   <td>
                    <asp:TextBox ID="txtGroupCust" runat="server" CssClass="inputlong" MaxLength="50" Width="200" ></asp:TextBox>
                    
                    <span class="red">*</span></td>
                   <td ><div align="right">客服经理:</div></td>
                   <td ><asp:DropDownList ID="selCustSerMgr" CssClass="inputmid" runat="server" Width="120"> </asp:DropDownList>
                   </td>
                   <td><div align="right">有效标志:</div></td>
                   <td colspan="2" ><asp:DropDownList ID="selUseTag" CssClass="input" runat="server" Width="80"> </asp:DropDownList>
                   </td>
                  </tr>
                  <tr>
                   <td><div align="right">联系人&nbsp; :</div></td>
                   <td><asp:TextBox ID="txtLinkMan" runat="server" CssClass="input" MaxLength="10" Width="200" ></asp:TextBox>
                   </td>
                   <td><div align="right">联系电话: </div></td>
                   <td><asp:TextBox ID="txtPhone" runat="server" CssClass="input" MaxLength="40"  Width="200" ></asp:TextBox>
                   </td>
                   <td>&nbsp;</td>
                   <td colspan="2">&nbsp;</td>
                 </tr>
                 <tr>
                   <td><div align="right">联系地址:</div></td>
                   <td>                    
                     <asp:TextBox ID="txtAddr" runat="server" CssClass="inputlong" MaxLength="100"  Width="200" ></asp:TextBox>
                     </td>
                   <td><div align="right">电子邮件:</div></td>
                   <td><asp:TextBox ID="txtEmail" runat="server" CssClass="input" MaxLength="30" Width="200" ></asp:TextBox>
                   </td>
                   <td><div align="right"></div></td>
                   <td colspan="2">
                     <span class="red"> </span></td>
                  </tr>
                 <tr>
                   <td><div align="right">备注&nbsp;&nbsp;&nbsp;&nbsp;:</div></td>
                   <td colspan="5"><asp:TextBox ID="txtRemark" runat="server" CssClass="inputmax" MaxLength="100" ></asp:TextBox></td>
                   <td width="9%"><asp:Button ID="btnModify" runat="server" Text="修改" CssClass="button1" OnClick="btnModify_Click" /></td>
                 </tr>
               </table>
              </div>
            </div>
           </ContentTemplate>
        </asp:UpdatePanel> 
    </form>
</body>
</html>

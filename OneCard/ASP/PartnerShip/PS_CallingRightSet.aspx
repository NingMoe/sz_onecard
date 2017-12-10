<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PS_CallingRightSet.aspx.cs" Inherits="ASP_PartnerShip_PS_CallingRightSet" EnableEventValidation="false" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">    
    <title>应用行业权值维护</title>
	<link rel="stylesheet" type="text/css" href="../../css/frame.css" />
   
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
       <div class="tb">合作伙伴->应用行业权值维护</div>
      
       <ajaxToolkit:ToolkitScriptManager runat="Server" EnableScriptGlobalization="true"
            EnableScriptLocalization="true" ID="ScriptManager2" />
       <asp:UpdatePanel ID="UpdatePanel1" runat="server">
            <ContentTemplate>
           
           <asp:BulletedList ID="bulMsgShow" runat="server"/>
         <script runat="server" >public override void ErrorMsgShow(){ErrorMsgHelper(bulMsgShow);}</script>
            
            <div class="con">
                <div class="card">查询</div>
                <div class="kuang5">
                <table width="95%" border="0" cellpadding="0" cellspacing="0" class="12text">
                 <tr>
                   <td width="12%"><div align="right">应用行业名称:</div></td>
                   <td width="15%">
                     <asp:DropDownList ID="selCalling" CssClass="inputmid" runat="server" >
                     </asp:DropDownList>
                   </td>
                   <td width="12%"><div align="right">权值应用类型:</div></td>
                   <td width="15%">
                     <asp:DropDownList ID="ddlType" CssClass="inputmid" runat="server" >
                      <asp:ListItem Text="--请选择--" Value=""></asp:ListItem>
                                    <asp:ListItem Text="1:商户" Value="1"></asp:ListItem>
                                    <asp:ListItem Text="2:客户(订单)" Value="2"></asp:ListItem>
                      </asp:DropDownList>
                     
                   </td>
                  
                   <td width="26%"><asp:Button ID="btnQuery" runat="server" Text="查询" CssClass="button1" OnClick="btnQuery_Click" /></td>
                 </tr>
                </table>
                </div>
                <div class="jieguo">查询结果</div>
                <div class="kuang5">
                <div id="gdtb" style="height:290px">

                    <asp:GridView ID="gvCallingList" CssClass="tab2" HeaderStyle-CssClass="tabbt" FooterStyle-CssClass="tabcon"
                            AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel" PagerSettings-Mode="NumericFirstLast"
                            PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top" runat="server"
                            AutoGenerateColumns="false" Width="100%" 
                            AllowPaging="true" PageSize="10" OnPageIndexChanging="gvCallingList_Page"
                           OnRowCreated="gvCallingList_RowCreated"
                    OnSelectedIndexChanged="gvCallingList_SelectedIndexChanged">
                    <Columns>
                    <%--<asp:TemplateField>
                                    
                        <ItemTemplate>
                            <asp:HiddenField ID = "hidCallingNo" runat="server" Value='<%#Eval("CALLINGNO")%>'/ />
                            <asp:HiddenField ID = "hidApplytype" runat="server"  Value='<%#Eval("APPLYTYPE")%>'/>
                        </ItemTemplate>
                     </asp:TemplateField>--%>
                      <asp:BoundField DataField="APPCALLINGCODE"   HeaderText="应用行业编码"/>
                      <asp:BoundField DataField="APPCALLING"   HeaderText="应用行业名称"/>
                      <asp:BoundField DataField="CALLINGRIGHTVALUE"   HeaderText="应用行业权值"  />
                      <asp:TemplateField HeaderText="权值应用类型">
                                <ItemTemplate>
                                    <asp:Label ID="labType" Text='<%# Eval("APPLYTYPE").ToString() == "1" ? "商户" : (Eval("APPLYTYPE").ToString() == "2"?"客户(订单)":"") %>' runat="server"></asp:Label>
                                </ItemTemplate>
                            </asp:TemplateField>

                      <asp:BoundField DataField="REMARK"  HeaderText="说明"/>
                      
                    </Columns>     
                  
                   <EmptyDataTemplate>
                   <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                     <tr class="tabbt">
                     <td>应用行业编码</td>
                      <td>应用行业名称</td>
                      <td>应用行业权值</td> 
                      <td>权值应用类型</td>
                      <td>说明</td>
                      
                    </tr>
                   </table>
                  </EmptyDataTemplate>
                </asp:GridView>
                </div>
                <%--<div id="gdtb" style="height:100px"></div>--%>
               
                </div>
                <div class="card">应用行业权值信息</div>
                <div class="kuang5">
                <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                
                 <tr>

                   <td width="8%"><div align="right">应用行业:</div></td>
                   <td width="22%">
                      <asp:DropDownList ID="selCallingExt" CssClass="inputmid" runat="server">
                      </asp:DropDownList>
                    <span class="red">*</span></td>
                    <td width="9%"><div align="right" >应用行业权值:</div></td>
                   <td width="22%">
                    <asp:TextBox runat="server" CssClass="input" MaxLength="10" ID="txtCallingRightValue"> </asp:TextBox>
                     <span class="red">*</span>  
                   </td>
                   <td width="8%"><div align="right">权值应用类型:</div></td>
                   <td width="22%">
                      <asp:DropDownList ID="selType" CssClass="inputmid" runat="server">
                       <asp:ListItem Text="--请选择--" Value=""></asp:ListItem>
                                    <asp:ListItem Text="1:商户" Value="1"></asp:ListItem>
                                    <asp:ListItem Text="2:客户(订单)" Value="2"></asp:ListItem>
                      </asp:DropDownList>
                    <span class="red">*</span></td>
                   
                 </tr>
                 <tr>
                  <td><div align="right">备注:</div></td>
                   <td><asp:TextBox ID="txtRemark" runat="server" CssClass="inputlong" MaxLength="100" 
                           Width="285px" ></asp:TextBox></td>
                  <td>
                  <asp:HiddenField ID = "hidCallingNo" runat="server" />
                  </td>
                  <td>
                  <asp:HiddenField ID = "hidType" runat="server" />
                  </td>
                 </tr>
                 

                 <tr>
                  
                   <td>&nbsp;</td>
                   <td colspan="5">
                     <table width="200" border="0" align="right" cellpadding="0" cellspacing="0">
                       <tr>
                         <td height="24"><asp:Button ID="btnAdd" runat="server" Text="增加" CssClass="button1" OnClick="btnAdd_Click" /></td>
                         <td><asp:Button ID="btnModify" runat="server" Text="修改" CssClass="button1" OnClick="btnModify_Click" /></td>
                       </tr>
                     </table>
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

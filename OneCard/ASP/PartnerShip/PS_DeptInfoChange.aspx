<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PS_DeptInfoChange.aspx.cs" Inherits="ASP_PartnerShip_PS_DeptInfoChange" EnableEventValidation="false" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <title>部门信息维护</title>
	<link rel="stylesheet" type="text/css" href="../../css/frame.css" />

    <link href="../../css/card.css" rel="stylesheet" type="text/css" /> 
</head>
<body>
    <form id="form1" runat="server">
       <div class="tb">合作伙伴->部门信息资料维护</div>
       <ajaxToolkit:ToolkitScriptManager runat="Server" EnableScriptGlobalization="true"
            EnableScriptLocalization="true" ID="ScriptManager2" />
       <asp:UpdatePanel ID="UpdatePanel1" runat="server">
            <ContentTemplate>
          
            <asp:BulletedList ID="bulMsgShow" runat="server"/>
         <script runat="server" >public override void ErrorMsgShow(){ErrorMsgHelper(bulMsgShow);}</script>
            <div class="con">
             <div class="card">查询部门信息</div>
             <div class="kuang5">
               <table width="95%" border="0" cellpadding="0" cellspacing="0" class="12text">
                 <tr>
                   <td><div align="right">行业:</div></td>
                   <td>
                    <asp:DropDownList ID="selCalling" CssClass="inputmidder" runat="server" AutoPostBack="true" OnSelectedIndexChanged="selCalling_SelectedIndexChanged">
                    </asp:DropDownList>
                   </td>
                   <td><div align="right">单位:</div></td>
                   <td>
                    <asp:DropDownList ID="selCorp" CssClass="inputmidder" runat="server" AutoPostBack="true" OnSelectedIndexChanged="selCorp_SelectedIndexChanged">
                    </asp:DropDownList>
                   </td>
                 </tr>
                 <tr>
                   <td><div align="right">部门:</div></td>
                   <td>
                      <asp:DropDownList ID="selDepart" CssClass="inputmidder" runat="server">
                      </asp:DropDownList>
                   </td>
                   <td>&nbsp;</td>
                   <td width="9%"><asp:Button ID="btnQuery" runat="server" Text="查询" CssClass="button1" OnClick="btnQuery_Click" /></td>
                  </tr>
               </table>
             </div>
              <div class="jieguo">部门信息列表</div>
              
              <div class="kuang5">
              <div id="gdtb" style="height:250px">
               <asp:GridView ID="lvwDepartQuery" runat="server"
                    Width = "150%"
                    CssClass="tab1"
                    HeaderStyle-CssClass="tabbt"
                    AlternatingRowStyle-CssClass="tabjg"
                    SelectedRowStyle-CssClass="tabsel"
                    AllowPaging="True"
                    PageSize="8"
                    PagerSettings-Mode="NumericFirstLast"
                    PagerStyle-HorizontalAlign="left"
                    PagerStyle-VerticalAlign="Top"
                    AutoGenerateColumns="False"
                    OnPageIndexChanging="lvwDepartQuery_Page"
                    OnSelectedIndexChanged="lvwDepartQuery_SelectedIndexChanged"
                    OnRowCreated="lvwDepartQuery_RowCreated">
                    <Columns>
                      <asp:TemplateField HeaderText="有效标志">
                       <ItemTemplate>
                         <asp:Label ID="labUseTag" Text='<%# Eval("USETAG").ToString() == "1" ? "有效" : "无效" %>' runat="server"></asp:Label>
                       </ItemTemplate>
                      </asp:TemplateField>
                        <asp:BoundField DataField="DEPARTNO"    HeaderText="部门编码"/>     
                        <asp:BoundField DataField="DEPART"      HeaderText="部门名称"/>       
                        <asp:BoundField DataField="CORP"        HeaderText="单位名称"/>        
                        <asp:BoundField DataField="CALLING"     HeaderText="行业名称"/>      
                        <asp:BoundField DataField="LINKMAN"     HeaderText="联系人"/>      
                        <asp:BoundField DataField="DEPARTPHONE" HeaderText="联系电话"/>  
                        <asp:BoundField DataField="DPARTMARK"   HeaderText="部门说明"/> 
                         
                    </Columns>           
                  
                   <EmptyDataTemplate>
                   
                   <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                     <tr class="tabbt">
                      <td>有效标志</td>
                      <td>部门编码</td>
                      <td>部门名称</td>
                      <td>单位名称</td>
                      <td>行业名称</td>
                      <td>联系人</td>
                      <td>联系电话</td>
                      <td>部门说明</td>
                    </tr>
                   </table>
                  </EmptyDataTemplate>
                </asp:GridView>
              </div>
              </div>
              
              <div class="card">部门信息</div>
                 <div class="kuang5">  
                  
                  <table width="95%" border="0" cellpadding="0" cellspacing="0" class="12text">
                     <tr>
                       <td><div align="right" >部门编码:</div></td>
                       <td>
				          <asp:TextBox ID="txtDepartNo" runat="server" CssClass="inputmidder" MaxLength="4"></asp:TextBox>
				          <span class="red">*</span>
    				   
				       </td>
                      
                       <td><div align="right">部门名称:</div></td>
                       <td>
                         <asp:TextBox ID="txtDepart" runat="server" CssClass="inputmidder" MaxLength="40"  ></asp:TextBox>
					     <span class="red">*</span>
				       </td>                     
                     </tr>
 				     <tr>
                       <td><div align="right">部门说明:</div></td>
                       <td> <asp:TextBox ID="txtDeptRemark" runat="server" CssClass="inputlong" MaxLength="50" ></asp:TextBox></td>
                        <td><div align="right">行业名称:</div></td>
                       <td>
				          <asp:DropDownList ID="selCallingExt" CssClass="inputmidder" runat="server" AutoPostBack="true"  
					           OnSelectedIndexChanged="selCallingExt_SelectedIndexChanged">
                          </asp:DropDownList>
                         <span class="red">*</span>
				       </td>
                    </tr>                    
                     <tr>
                       <td><div align="right">单位名称:</div></td>
                       <td>
				         <asp:DropDownList ID="selCorpExt" CssClass="inputmidder" runat="server">
                         </asp:DropDownList>
                         <span class="red">*</span>
    				    	 
				       </td>
				       <td><div align="right">联系人:</div></td>
				       <td>
                            <asp:TextBox ID="txtLinkMan" runat="server" CssClass="inputmidder" MaxLength="10"></asp:TextBox>
                            <span class="red"> *</span> 
                       </td>
				       </tr>


                     <tr>
    				   
				        <td><div align="right">联系电话:</div> </td>
					    <td>
                            <asp:TextBox ID="txtPhone" runat="server" CssClass="inputmidder" MaxLength="40"></asp:TextBox>		
                            <span class="red">*</span>      
				        </td>
                        <td><div align="right">备注:</div></td>
                        <td>
                             <asp:TextBox ID="txtRemark" runat="server" CssClass="inputmidder" MaxLength="100" ></asp:TextBox>
                        </td>
                     </tr>
                     <tr>
				       <td><div align="right">有效标志:</div></td>
                       <td>
                            <asp:DropDownList ID="selUseTag" CssClass="inputmid" runat="server"></asp:DropDownList>
                            <span class="red">* </span>
				       </td>
                        <td><div align="right">&nbsp;</div></td>
                        <td><asp:Button ID="btnAdd" runat="server" Text="增加" CssClass="button1" OnClick="btnAdd_Click" />
                            &nbsp;&nbsp;
                            <asp:Button ID="btnModify" runat="server" Text="修改" CssClass="button1" OnClick="btnModify_Click" />
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

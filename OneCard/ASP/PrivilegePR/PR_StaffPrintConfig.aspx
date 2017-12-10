<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PR_StaffPrintConfig.aspx.cs" Inherits="ASP_PrivilegePR_PR_StaffPrintConfig"  EnableEventValidation="false"%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>系统设置-员工打印设置</title>
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="../../js/myext.js"></script>
    <script type="text/javascript" src="../../js/jquery-1.5.min.js"></script>
</head>
<body>
    <form id="form1" runat="server">
       <div class="tb">系统设置-员工打印设置</div>
      
       <ajaxToolkit:ToolkitScriptManager runat="Server" EnableScriptGlobalization="true"
            EnableScriptLocalization="true" ID="ScriptManager2" />
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
                <table width="95%" border="0" cellpadding="0" cellspacing="0" class="12text">
                 <tr>
                   <td width="12%"><div align="right">部门:</div></td>
                   <td width="25%">
                     <asp:DropDownList ID="selDepart" CssClass="inputmid" runat="server" 
                        AutoPostBack="true" OnSelectedIndexChanged="selDepart_SelectedIndexChanged" >
                     </asp:DropDownList>
                   </td>
                   <td width="12%"><div align="right">员工:</div></td>
                   <td width="25%">
                     <asp:DropDownList ID="selStaff" CssClass="inputmid" runat="server" >
                      </asp:DropDownList>
                     
                   </td>
                  
                   <td width="26%" align="right"><asp:Button ID="btnQuery" runat="server" Text="查询" CssClass="button1" OnClick="btnQuery_Click" /></td>
                   <asp:HiddenField runat="server" ID="hidIsManager" />
                 </tr>
                </table>
                </div>
                <div class="jieguo">查询结果</div>
                <div class="kuang5">
                <div id="gdtb" style="height:290px">

                    <asp:GridView ID="gvList" CssClass="tab2" HeaderStyle-CssClass="tabbt" FooterStyle-CssClass="tabcon"
                            AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel" PagerSettings-Mode="NumericFirstLast"
                            PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top" runat="server"
                            AutoGenerateColumns="false" Width="100%" 
                            AllowPaging="true" PageSize="10" OnPageIndexChanging="gvList_Page"
                           OnRowCreated="gvList_RowCreated"
                    OnSelectedIndexChanged="gvList_SelectedIndexChanged">
                    <Columns>

                      <asp:BoundField DataField="DEPART"   HeaderText="部门"/>
                      <asp:BoundField DataField="STAFF"   HeaderText="员工"/>
                      <asp:BoundField DataField="PRINTMODE"   HeaderText="打印设置"  />
                      
                    </Columns>     
                  
                   <EmptyDataTemplate>
                   <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                     <tr class="tabbt">
                     <td>部门</td>
                      <td>员工</td>
                      <td>打印设置</td> 
                      
                    </tr>
                   </table>
                  </EmptyDataTemplate>
                </asp:GridView>
                </div>
               
                </div>
                <div class="card">员工打印设置信息</div>
                <div class="kuang5">
                <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                
                 <tr>

                   <td width="8%"><div align="right">部门:</div></td>
                   <td width="10%">
                      <asp:DropDownList ID="ddlDepart" CssClass="inputmid" runat="server"
                      AutoPostBack="true" OnSelectedIndexChanged="ddlDepart_SelectedIndexChanged">
                      </asp:DropDownList>
                    <span class="red">*</span></td>
                    <td width="10%">
                    </td>
                    <td width="5%"><div align="right" >员工:</div></td>
                   <td width="20%">
                    <asp:DropDownList ID="ddlStaff" CssClass="inputmid" runat="server">
                      </asp:DropDownList>
                     <span class="red">*</span>  
                   </td>   
                 </tr>
                 <tr>
                  <td><div align="right">打印设置:</div></td>
                   
                    <td >
                     <asp:RadioButton ID="zhenshiPrint" Visible="true" Checked="true" Text="针式打印" GroupName="OrderType" TextAlign="Right" runat="server" />
                    </td>
                    <td >
                        <asp:RadioButton ID="reminPrint" Visible="true" Checked="false" Text="热敏打印" GroupName="OrderType" TextAlign="Right" runat="server"  />
                    </td>
               
                 </tr> 
                 <tr>
                  
                   <td>&nbsp;</td>
                   <td colspan="4">
                     <table width="200" border="0" align="right" cellpadding="0" cellspacing="0">
                       <tr>
                         <td height="24">
                             <asp:Button ID="btnAdd" runat="server" Text="增加" CssClass="button1" OnClick="btnAdd_Click" /></td>
                         <td>
                             <asp:Button ID="btnModify" runat="server" Text="修改" CssClass="button1" OnClick="btnModify_Click" />
                          </td>
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

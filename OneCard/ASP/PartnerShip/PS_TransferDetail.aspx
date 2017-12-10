<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PS_TransferDetail.aspx.cs" Inherits="ASP_PartnerShip_PS_TransferDetail" EnableEventValidation="false" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">    
    <title>合帐结算单元信息维护</title>
	<link rel="stylesheet" type="text/css" href="../../css/frame.css" />
   <script type="text/javascript" src="../../js/myext.js"></script>
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
       <div class="tb">合作伙伴->合帐结算单元信息维护</div>
      
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
                <div class="card">合帐结算单元查询信息</div>
                <div class="kuang5">
                <table width="95%" border="0" cellpadding="0" cellspacing="0" class="12text">
                 <tr>
                   <td width="20%"><div align="right">合帐结算单元名称:</div></td>
                   <td width="50%">
                     <asp:DropDownList ID="selCalling" CssClass="inputmidder" runat="server">
                     </asp:DropDownList>
                   </td>
                   <td width="30%"><asp:Button ID="btnBalQuery" runat="server" Text="查询" CssClass="button1" OnClick="btnBalQuery_Click" /></td>
                 </tr>
                </table>
                </div>
                <div class="con">
                <div class="card">单位查询信息</div>
                <div class="kuang5">
                <table width="95%" border="0" cellpadding="0" cellspacing="0" class="12text">
                 <tr>
                   <td width="20%"><div align="right">单位名称:</div></td>
                   <td width="50%">
                     <asp:DropDownList ID="selCorp" CssClass="inputmidder" runat="server" >
                     </asp:DropDownList>
                   </td>
                   <td width="30%"><asp:Button ID="btnCorpQuery" runat="server" Text="查询" CssClass="button1" OnClick="btnCorpQuery_Click" /></td>
                 </tr>
                </table>
                </div>
                <asp:HiddenField ID="hiddenShow" runat="server" />
                <div class="jieguo">结算单元信息列表</div>
                <div class="kuang5">
                <div id="gdtb" style="height:290px">
                <asp:GridView ID="lvwCorpQuery" runat="server"
                    Width="95%"
                    CssClass="tab1"
                    HeaderStyle-CssClass="tabbt"
                    AlternatingRowStyle-CssClass="tabjg"
                    SelectedRowStyle-CssClass="tabsel"
                    AllowPaging="True"
                    PagerSettings-Mode="NumericFirstLast"
                    PagerStyle-HorizontalAlign="left"
                    PagerStyle-VerticalAlign="Top"
                    AutoGenerateColumns="False" 
                    OnRowDeleting="lvwCorpQuery_RowDeleting"
                    OnPageIndexChanging="lvwCorpQuery_Page"
                    OnRowDataBound="lvwCorpQuery_RowDataBound">
                    <Columns>
                      <asp:TemplateField>
                        <HeaderTemplate>
                          <asp:CheckBox ID="CheckBox1" runat="server"  AutoPostBack="true" OnCheckedChanged="CheckAll" />
                        </HeaderTemplate>
                        <ItemTemplate>
                          <asp:CheckBox ID="ItemCheckBox" runat="server"/>
                        </ItemTemplate>
                      </asp:TemplateField>
                          <asp:BoundField DataField="CORPNO"    HeaderText="合帐单位编码"/>
                          <asp:BoundField DataField="CORP"      HeaderText="合帐单位名称"/>
                          <asp:BoundField DataField="CALLING"   HeaderText="行业名称"/>
                          <asp:BoundField DataField="CORPNAME"   HeaderText="单位名称"/>
                          <asp:BoundField DataField="BALUNITNO"   HeaderText="结算单元编码"/>
                          <asp:BoundField DataField="BALUNIT"   HeaderText="结算单元名称"/>
                          <asp:BoundField DataField="BANKACCNO"   HeaderText="银行账号"/>
                          <asp:BoundField DataField="LINKMAN"   HeaderText="联系人"  />
                          <asp:BoundField DataField="UNITPHONE" HeaderText="联系电话"/>
                        <asp:TemplateField HeaderText="删除" ShowHeader="False">
                            <ItemTemplate>
                                <asp:LinkButton ID="btnDelete" runat="server" CausesValidation="False" 
                                    CommandName="Delete" Text="删除"></asp:LinkButton>
                            </ItemTemplate>
                        </asp:TemplateField>
                     
                    </Columns>     
                  
                   <EmptyDataTemplate>
                   <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                     <tr class="tabbt">
                     <td><input type="checkbox" /></td>
                      <td>合帐单位编码</td>
                      <td>合帐单位名称</td>
                      <td>行业名称</td>
                      <td>单位名称</td>
                      <td>结算单元编码</td>
                      <td>结算单元名称</td>
                      <td>银行账号</td>
                      <td>联系人</td>
                      <td>联系电话</td>
                    </tr>
                   </table>
                  </EmptyDataTemplate>
                    
                </asp:GridView>
                </div>
                <%--<div id="gdtb" style="height:100px"></div>--%>
                </div>
                <div class="card">增加合帐结算单元</div>
                <div class="kuang5">
                <table width="95%" border="0" cellpadding="0" cellspacing="0" class="12text">
                <td width="20%"><div align="right">合帐结算单元名称:</div></td>
                <td width="50%">
                    <asp:DropDownList runat="server" CssClass="inputmidder" ID="txtBALUNITNO"> </asp:DropDownList>
                   </td>
                   <td width="30%"><asp:Button ID="btnAdd" runat="server" Enabled="false" Text="批量增加" CssClass="button1" OnClick="btnAdd_Click" /></td>
                </table>
                </div>
                </div>
          </ContentTemplate>
        </asp:UpdatePanel>
    </form>
</body>
</html>


<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PS_GroupCustApproval.aspx.cs" Inherits="ASP_PartnerShip_PS_GroupCustApproval" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">

    <title>集团客户审批</title>
	<link rel="stylesheet" type="text/css" href="../../css/frame.css" />
     <link href="../../css/card.css" rel="stylesheet" type="text/css" />


     
     <script language="javascript">
           function SelectAll(tempControl)
           {
               //将除头模板中的其它所有的CheckBox取反 

                var theBox=tempControl;
                 xState=theBox.checked;    

                elem=theBox.form.elements;
                for(i=0;i<elem.length;i++)
                if(elem[i].type=="checkbox" && elem[i].id!=theBox.id)
                 {
                      if(elem[i].checked!=xState)
                            elem[i].click();
                }
            }  
    </script>
    
</head>
<body>
    <form id="form1" runat="server">
    <div class="tb">合作伙伴->集团客户资料审批</div>
    
    <ajaxToolkit:ToolkitScriptManager runat="Server" EnableScriptGlobalization="true"
        EnableScriptLocalization="true" ID="ScriptManager2" />
    <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
       
       <asp:BulletedList ID="bulMsgShow" runat="server"/>
         <script runat="server" >public override void ErrorMsgShow(){ErrorMsgHelper(bulMsgShow);}</script>
        <div class="con">
          <div class="jieguo">待审批的集团客户信息</div>
           <div class="kuang5">
             <div id="gdtb" style="height:400px">
             
             <asp:GridView ID="lvwGroupCustAppral" runat="server"
                CssClass="tab1"
                Width ="1100"
                HeaderStyle-CssClass="tabbt"
                AlternatingRowStyle-CssClass="tabjg"
                SelectedRowStyle-CssClass="tabsel"
                AllowPaging="True"
                PageSize="10"
                PagerSettings-Mode="NumericFirstLast"
                PagerStyle-HorizontalAlign="Left"
                PagerStyle-VerticalAlign="Top"
                AutoGenerateColumns="False"
                OnPageIndexChanging="lvwGroupCustAppral_Page"
                OnRowDataBound ="lvwGroupCustAppral_RowDataBound">

                <Columns>
                 <asp:TemplateField>
                    <HeaderTemplate>
                        <asp:CheckBox ID="chkAllCust" runat="server" onclick="javascript:SelectAll(this);" />
                    </HeaderTemplate>
                    <ItemTemplate>
                        <asp:CheckBox ID="chkGroupCust" runat="server"  />
                    </ItemTemplate>
                 </asp:TemplateField>
                 
                 <asp:BoundField DataField="TRADEID"  HeaderText="业务流水号"/>
                 <asp:BoundField DataField="BIZTYPE"  HeaderText="操作类型"/>
                 <asp:BoundField DataField="TRADETYPECODE"  HeaderText="业务类型编码"/>
                 <asp:BoundField DataField="USETAG_EXT"     HeaderText="有效标志"/>
                 
                 <asp:BoundField DataField="CORPCODE"  HeaderText="集团客户编码"/>
                 <asp:BoundField DataField="CORPNAME"  HeaderText="集团客户名称"/>
                 <asp:BoundField DataField="LINKMAN"   HeaderText="联系人"/>
                 <asp:BoundField DataField="CORPPHONE" HeaderText="联系电话"/>
                 <asp:BoundField DataField="CORPADD"   HeaderText="联系地址"/>
                 <asp:BoundField DataField="SERMGR"    HeaderText="客服经理" NullDisplayText="" />
                 <asp:BoundField DataField="SERMANAGERCODE"   HeaderText="客服经理编码"/>
                 <asp:BoundField DataField="CORPEMAIL"        HeaderText="电子邮件"  NullDisplayText=" " />
                 
                 <asp:BoundField DataField="STAFF"  HeaderText="操作员工"/>
                 <asp:BoundField DataField="OPERATESTAFFNO"  HeaderText="操作员工编码"/>
                 
                 <asp:BoundField DataField="OPERATETIME"   HeaderText="操作时间"  />
                 <asp:BoundField DataField="REMARK"        HeaderText="备注" NullDisplayText=" "/>
                            
               </Columns>   
               
               <EmptyDataTemplate>
                  <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                     <tr class="tabbt">
                      <td><input type="checkbox" /></td>
                      <td>操作类型</td>
                      <td>集团客户编码</td>
                      <td>集团客户名称</td>
                      <td>联系人</td>
                      <td>联系电话</td>
                      <td>联系地址</td>
                      <td>客服经理</td>
                      <td>电子邮件</td>
                      <td>操作员工</td>
                      <td>操作时间</td>
                      <td>备注</td>
                     </tr>
                  </table>
               </EmptyDataTemplate>
            </asp:GridView>
             
           </div>
          

          </div>
        </div>
        <div class="btns">
          <table width="200" border="0" align="right" cellpadding="0" cellspacing="0">
            <tr>
              <td><asp:Button ID="btnAppPass" runat="server" Text="通过" CssClass="button1" OnClick="btnAppPass_Click" /></td>
              <td><asp:Button ID="btnAppCancel" runat="server" Text="作废" CssClass="button1" OnClick="btnAppCancel_Click" /></td>
            </tr>
          </table>
        </div>
        
    
      </ContentTemplate>
     </asp:UpdatePanel>



    </form>
</body>
</html>

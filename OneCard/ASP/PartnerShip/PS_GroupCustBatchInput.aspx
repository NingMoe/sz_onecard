<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PS_GroupCustBatchInput.aspx.cs" Inherits="ASP_PartnerShip_PS_GroupCustBatchInput" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">

    <title>集团客户批量录入</title>
	<link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
    <div class="tb">合作伙伴->集团客户批量录入</div>
   
    <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
      <asp:UpdatePanel ID="UpdatePanel2" UpdateMode="Conditional" runat="server">
        <ContentTemplate>    
       
        <!-- #include file="../../ErrorMsg.inc" -->
     
        <div class="con">
         <div class="base">文件录入</div>
         <div class="kuang5">
         <table width="95%" border="0" cellpadding="0" cellspacing="0" class="12text">
          <tr>
            <td width="7%"><div align="right">导入文件:</div></td>
            <td width="42%"><asp:FileUpload ID="FileUpload1" runat="server" CssClass="inputlong" /></td>
            <td width="51%"><asp:Button ID="btnUpload" runat="server" Text="导入文件" CssClass="button1" OnClick="btnUpload_Click" /></td>
          </tr>
         </table>
         </div>
         <div class="jieguo">集团客户信息</div>
         <div class="kuang5">
         <div id="gdtb" style="height:350px">
         
         <asp:GridView ID="lvwGroupCustImp" runat="server"
                Width = "1000"
                CssClass="tab1"
                HeaderStyle-CssClass="tabbt"
                AlternatingRowStyle-CssClass="tabjg"
                SelectedRowStyle-CssClass="tabsel"
               
                PagerSettings-Mode="NumericFirstLast"
                PagerStyle-HorizontalAlign="left"
                PagerStyle-VerticalAlign="Top"
                AutoGenerateColumns="False" >
                <Columns>
                    <asp:BoundField DataField="CORPCODE"   HeaderText="集团客户编码"/>
                    <asp:BoundField DataField="CORPNAME"   HeaderText="集团客户名称"/>
                    <asp:BoundField DataField="LINKMAN"    HeaderText="联系人"/>
                    <asp:BoundField DataField="CORPPHONE"  HeaderText="联系电话"/>
                    <asp:BoundField DataField="CORPADD"    HeaderText="联系地址"/>
                    <asp:BoundField DataField="SERMANAGERCODE" HeaderText="客服经理" NullDisplayText=""/>

                    <asp:BoundField DataField="CORPEMAIL"  HeaderText="电子邮件"/>
                    <asp:BoundField DataField="REMARK"     HeaderText="备注" />
               </Columns>           
              <EmptyDataTemplate>
                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                  <tr class="tabbt">
                    <td>集团客户编码</td>
                    <td>集团客户名称</td>
                    <td>联系人</td>
                    <td>联系电话</td>
                    <td>联系地址</td>
                    <td>客服经理编码</td>
          
                    <td>电子邮件</td>
                    <td>备注</td>
                  </tr>
                </table>
            </EmptyDataTemplate>
         </asp:GridView>
         
        </div>
        </div>
        </div>
        <div class="btns">
            <table width="100" border="0" align="right" cellpadding="0" cellspacing="0">
              <tr>
                <td><asp:Button ID="btnSave" runat="server" Text="保存" CssClass="button1" OnClick="btnSave_Click" /></td>
              </tr>
            </table>
        </div>
             
    
       </ContentTemplate>
       <Triggers>
        <asp:PostBackTrigger ControlID="btnUpload" />
       </Triggers>            
      </asp:UpdatePanel>
   
    </form>
</body>
</html>

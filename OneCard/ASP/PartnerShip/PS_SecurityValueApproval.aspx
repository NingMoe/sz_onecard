<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PS_SecurityValueApproval.aspx.cs" Inherits="ASP_PartnerShip_PS_SecurityValueApproval" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>

    <script src="../../js/jquery-1.5.min.js" type="text/javascript"></script>

    <script type="text/javascript" src="../../js/print.js"></script>

    <script type="text/javascript" src="../../js/myext.js"></script>

    <script type="text/javascript" src="../../js/Window.js"></script>

    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
   <%-- <script type="text/javascript" src="../../js/mootools.js"></script>--%>
   <script type="text/javascript" language="javascript">
       function SelectAll(tempControl) {
           //将除头模板中的其它所有的CheckBox取反 

           var theBox = tempControl;
           xState = theBox.checked;

           elem = theBox.form.elements;
           for (i = 0; i < elem.length; i++)
               if (elem[i].type == "checkbox" && elem[i].id != theBox.id) {
                   if (elem[i].checked != xState)
                       elem[i].click();
               }
       }  
    </script>
    
</head>
<body>
    <form id="form1" runat="server">
    <div class="tb">
        合作伙伴->商户安全值审核
    </div>
    <ajaxToolkit:ToolkitScriptManager runat="Server" EnableScriptGlobalization="true"
        EnableScriptLocalization="true" ID="ToolkitScriptManager1" />

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
     <asp:UpdatePanel ID="UpdatePanel2" runat="server">
        <ContentTemplate>
         <asp:BulletedList ID="bulMsgShow" runat="server" />

            <script runat="server">public override void ErrorMsgShow() { ErrorMsgHelper(bulMsgShow); }</script>

            <div class="con">
                <div class="card">
                    查询</div>
                <div class="kuang5" id ="searchComBuyCard" style="display: block"   runat="server">
                    <div >
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                        <td width="12%">
                                <div align="right">
                                    行业名称:</div>
                            </td>
                            <td width="15%">
                                <asp:DropDownList ID="selCalling" CssClass="inputmid" runat="server" OnSelectedIndexChanged="selCalling_SelectedIndexChanged"
                                    AutoPostBack="true">
                                </asp:DropDownList>
                            </td>
                            <td width="10%">
                                <div align="right">
                                    单位名称:</div>
                            </td>
                            <td width="30%">
                                <asp:DropDownList ID="selCorp" CssClass="inputmidder" runat="server">
                                </asp:DropDownList>
                            </td>
                            
                        </tr>
                        
                        <tr>
                        <td colspan="4"  align="right">
                                <asp:Button ID="btnQuery" runat="server" Text="查询" CssClass="button1" OnClick="btnQuery_Click" />
                            </td>
                        </tr>
                    </table>
                    </div>
                    
                </div>
                <div class="kuang5"  id ="searchPerBuyCard" style="display: none"   runat="server">
                    <div id ="Div1" >
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td>
                                <div align="right" >
                                    姓名:</div>
                            </td>
                            <td>
                                <asp:TextBox ID="txtActername2" CssClass="input" MaxLength="25" runat="server"></asp:TextBox>
                            </td>
                            <td>
                                <div align="right" >
                                    证件类型:</div>
                            </td>
                            <td >
                                <asp:DropDownList ID="selActerPapertype2" CssClass="input" runat="server">
                                </asp:DropDownList>
                            </td>
                            
                            <td>
                                <div align="right" >
                                    证件号码:</div>
                            </td>
                            <td>
                                <asp:TextBox ID="txtActerPaperno2" CssClass="input" MaxLength="20" runat="server"></asp:TextBox>
                            </td>
                        </tr>
                        
                        <tr>
                        <td colspan="6"  align="right">
                                <asp:Button ID="Button1" runat="server" Text="查询" CssClass="button1" OnClick="btnQuery_Click" />
                            </td>
                        </tr>
                    </table>
                    </div>
                    
                </div>
                <div class="jieguo">
                    查询结果</div>
                <div class="kuang5">
                <div id="combuycardgv" style="height: 280px; display: block; overflow: auto"  runat="server">
                <asp:GridView ID="gvComResult" runat="server" CssClass="tab1" Width="150%" HeaderStyle-CssClass="tabbt"
                            AlternatingRowStyle-CssClass="tabjg" 
                        SelectedRowStyle-CssClass="tabsel" AllowPaging="True"
                            PageSize="20" PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="Left"
                            PagerStyle-VerticalAlign="Top" AutoGenerateColumns="False" OnPageIndexChanging="gvComResult_Page"
                             EmptyDataText="没有查询出任何记录">
                            <Columns>
                           
                                 <asp:TemplateField>
                                                    <HeaderTemplate>
                                                        <asp:CheckBox ID="chkAllCheck" runat="server" onclick="javascript:SelectAll(this);" />
                                                    </HeaderTemplate>
                                                    <ItemTemplate>
                                                        <asp:CheckBox ID="chkCheck" runat="server" />
                                                    </ItemTemplate>
                                                </asp:TemplateField>
                                 <asp:BoundField DataField="ID"   HeaderText="ID"/> 
                                <asp:BoundField DataField="CORPNO" HeaderText="单位编码" />
                                <asp:BoundField DataField="CORP" HeaderText="单位名称" />
                                <asp:BoundField DataField="CALLING" HeaderText="行业名称" />
                                <asp:BoundField DataField="APPCALLING" HeaderText="应用行业" />
                                <asp:BoundField DataField="registeredcapital" HeaderText="注册资金" />
                                <asp:BoundField DataField="securityvalue" HeaderText="安全值" />
                                <asp:TemplateField>
                                    <HeaderTemplate >
                                        <asp:Label ID="labelHeader" runat="server" Text="审核状态" />
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                        <asp:Label ID="labelText" runat="server" Text="待审核" />
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField DataField="LINKMAN" HeaderText="联系人" />
                                <asp:BoundField DataField="CORPPHONE" HeaderText="联系电话" />
                                <asp:BoundField DataField="CORPADD" HeaderText="单位地址" />
                                <asp:BoundField DataField="CORPMARK" HeaderText="单位说明" />
                                
                            </Columns>
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                    <td>ID</td>
                                    <td>
                                            单位编码
                                        </td>
                                        <td>
                                            单位名称
                                        </td>
                                        <td>
                                            行业名称
                                        </td>
                                        <td>
                                            应用行业
                                        </td>
                                        <td>
                                            注册资金
                                        </td>
                                        <td>
                                            安全值
                                        </td>
                                        <td>
                                            审核状态
                                        </td>
                                        <td>
                                            联系人
                                        </td>
                                        <td>
                                            联系电话
                                        </td>
                                        <td>
                                            联系地址
                                        </td>
                                        <td>
                                            电子邮件
                                        </td>   
                                    </tr>
                                </table>
                            </EmptyDataTemplate>
                        </asp:GridView>
                </div>
                
            </div>
                
           
          
                
  <div class="btns">        
             <table width="95%" border="0"cellpadding="0" cellspacing="0">
              <tr>
                 <td width="80%">&nbsp;</td>
                 
                 <td align="right"> <asp:Button ID="btnSubmit" Text="通 过" CssClass="button1" runat="server" OnClick="btnSubmit_Click" /></td>
                  <td align="right"> <asp:Button ID="btnCancel" Text="作废" CssClass="button1" runat="server" OnClick="btnCancel_Click" /></td>
             </tr>
      </table>

       </div>
                </div>   
             </ContentTemplate>
            
        
    </asp:UpdatePanel>
    </form>
</body>
</html>

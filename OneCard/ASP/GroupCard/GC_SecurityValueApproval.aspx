<%@ Page Language="C#" AutoEventWireup="true" CodeFile="GC_SecurityValueApproval.aspx.cs" Inherits="ASP_GroupCard_GC_SecurityValueApproval" %>

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
        function SelectComBuyCard() {
            $get('hidCardType').value = "combuycard";
            searchComBuyCard.style.display = "block";
            searchPerBuyCard.style.display = "none";
            combuycardgv.style.display = "block";
            perbuycardgv.style.display = "none";
           

            document.getElementById("txtActername2").value = "";
            document.getElementById("txtActerPaperno2").value = "";

            usecard.className = "on";
            chargecard.className = null;

            return false;
        }
        function SelectPerBuyCard() {
            $get('hidCardType').value = "perbuycard";
            searchComBuyCard.style.display = "none";
            perbuycardgv.style.display = "block";
            combuycardgv.style.display = "none";

           
            searchPerBuyCard.style.display = "block";
            document.getElementById("txtActername").value = "";
            document.getElementById("txtActerPaperno").value = "";
            usecard.className = null;
            chargecard.className = "on";

            return false;
        }
        function mout() {
            var cardname = $get('hidCardType').value;
            var object = document.getElementById(cardname);

        }

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
        订单管理->购卡客户安全值审核
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
        
            <asp:HiddenField ID="hidCardType" runat="server" />
            <div style="height: 22px">
                <table>
                    <tr>
                        <td width="10%">
                        </td>
                        <td align="center">
                            <ul class="nav_list">
                                <li runat="server" id="liSupplyStock" visible="true">
                                    <asp:LinkButton ID="usecard" Target="_top" CssClass="on" runat="server" 
                                        onmouseout="mout();" OnClientClick="return SelectComBuyCard()"><span class="signA">单位购卡安全值</span></asp:LinkButton></li>
                                <li runat="server" id="liNewCard" visible="true">
                                    <asp:LinkButton ID="chargecard" Target="_top" runat="server" 
                                        onmouseout="mout();" OnClientClick="return SelectPerBuyCard()"><span class="signB">个人购卡安全值</span></asp:LinkButton></li>
                            </ul>
                        </td>
                    </tr>
                </table>
            </div>
            <div class="con">
                <div class="card">
                    查询</div>
                <div class="kuang5" id ="searchComBuyCard" style="display: block"   runat="server">
                    <div >
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                         <td>
                                <div align="right">
                                    单位名称:</div>
                            </td>
                            <td width="36%">
                                <asp:TextBox ID="txtCompanyname" CssClass="input" MaxLength="100" runat="server"
                                    AutoPostBack="true" OnTextChanged="queryCompanyName"></asp:TextBox>
                           
                                <asp:DropDownList ID="selCompanyname" CssClass="inputmid" Width="200px" runat="server"
                                   >
                                </asp:DropDownList>
                            </td>
                            
                            <td width="12%">
                                <div align="right" >
                                    单位证件类型:</div>
                            </td>
                            <td width="12%">
                                <asp:DropDownList ID="selActerPapertype1" CssClass="input" runat="server">
                                </asp:DropDownList>
                            </td>
                           <td width="12%">
                                <div align="right">
                                    单位证件号码:</div>
                            </td>
                            <td  align="left">
                                <asp:TextBox ID="txtCompaperno" CssClass="input" MaxLength="30" runat="server"></asp:TextBox>
                            </td>
                            
                        </tr>
                        <tr >
                           <td width="12%">
                                <div align="right" >
                                    经办人姓名:</div>
                            </td>
                            <td width="24%">
                                <asp:TextBox ID="txtActername" CssClass="input" MaxLength="25" runat="server"></asp:TextBox>
                            </td>
                            <td width="12%">
                                <div align="right">
                                    经办人证件号码:</div>
                            </td>
                            <td width="12%">
                                <asp:TextBox ID="txtActerPaperno" CssClass="input" MaxLength="20" runat="server"></asp:TextBox>
                            </td>
                            
                            
                        </tr>
                        <tr>
                        <td colspan="5"  align="right">
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
                           <%-- <asp:TemplateField>
                                    <ItemTemplate>
                                        <asp:HiddenField ID="num" runat="server" Value='<%# Container.DataItemIndex%>' />
                                    </ItemTemplate>
                                </asp:TemplateField>--%>
                                 <asp:TemplateField>
                                                    <HeaderTemplate>
                                                        <asp:CheckBox ID="chkAllCheck" runat="server" onclick="javascript:SelectAll(this);" />
                                                    </HeaderTemplate>
                                                    <ItemTemplate>
                                                        <asp:CheckBox ID="chkCheck" runat="server" />
                                                    </ItemTemplate>
                                                </asp:TemplateField>
                                 <asp:BoundField DataField="ID"   HeaderText="ID"/> 
                                <asp:BoundField DataField="COMPANYNO" HeaderText="单位编码" />
                                <asp:BoundField DataField="COMPANYNAME" HeaderText="单位名称" />
                                <asp:BoundField DataField="COMPANYPAPERTYPE" HeaderText="单位证件类型" />
                                <asp:BoundField DataField="COMPANYPAPERNO" HeaderText="单位证件号码" />
                                <asp:BoundField DataField="appcalling" HeaderText="行业名称" />
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
                                <asp:BoundField DataField="NAME" HeaderText="经办人姓名" />
                                <asp:BoundField DataField="PAPERTYPE" HeaderText="经办人证件类型" />
                                <asp:BoundField DataField="PAPERNO" HeaderText="经办人证件号码" />
                                <asp:BoundField DataField="PAPERENDDATE" HeaderText="经办人证件有效期" />
                                <asp:BoundField DataField="PHONENO" HeaderText="联系电话" />
                                <asp:BoundField DataField="ADDRESS" HeaderText="联系地址" />
                                <asp:BoundField DataField="EMAIL" HeaderText="电子邮件" />
                                
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
                                            单位证件类型
                                        </td>
                                        <td>
                                            单位证件号码
                                        </td>
                                        <td>
                                            行业名称
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
                                            经办人姓名

                                        </td>
                                        
                                        <td>
                                            经办人证件类型

                                        </td>
                                        <td>
                                            经办人证件号码

                                        </td>
                                        <td>
                                            经办人证件有效期

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
                <div id="perbuycardgv" style="height: 280px; display: none; overflow: auto"  runat="server">
                <asp:GridView ID="gvPerResult" runat="server"
                    CssClass="tab1"
                    Width ="150%"
                    HeaderStyle-CssClass="tabbt"
                    AlternatingRowStyle-CssClass="tabjg"
                    SelectedRowStyle-CssClass="tabsel"
                    AllowPaging="True"
                    PageSize="20"
                    PagerSettings-Mode="NumericFirstLast"
                    PagerStyle-HorizontalAlign="Left"
                    PagerStyle-VerticalAlign="Top"
                    AutoGenerateColumns="False"
                    OnPageIndexChanging="gvPerResult_Page">
                    <Columns> 
                    <%--<asp:TemplateField>
                                    <ItemTemplate>
                                        <asp:HiddenField ID="num" runat="server" Value='<%# Container.DataItemIndex%>' />
                                    </ItemTemplate>
                                </asp:TemplateField> --%>
                    <asp:TemplateField>
                                    <HeaderTemplate>
                                        <asp:CheckBox ID="chkAllCheck" runat="server" onclick="javascript:SelectAll(this);" />
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                        <asp:CheckBox ID="chkCheck" runat="server" />
                                    </ItemTemplate>
                                </asp:TemplateField>  
                          <asp:BoundField DataField="ID"   HeaderText="ID"/>  
                          <asp:BoundField DataField="NAME"   HeaderText="姓名"/>            
                          <asp:BoundField DataField="PAPERTYPE"    HeaderText="证件类型"/>             
                          <asp:BoundField DataField="PAPERNO"    HeaderText="证件号码"/> 
                          <asp:BoundField DataField="registeredcapital" HeaderText="注册资金" />
                          <asp:BoundField DataField="securityvalue" HeaderText="安全值" />
                           <asp:TemplateField>
                                    <HeaderTemplate >
                                        <asp:Label ID="labelHeader2" runat="server" Text="审核状态" />
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                        <asp:Label ID="labelText2" runat="server" Text="待审核" />
                                    </ItemTemplate>
                                </asp:TemplateField>
                           <asp:BoundField DataField="BIRTHDAY"   HeaderText="出生日期"/> 
                           <asp:BoundField DataField="NATIONALITY"   HeaderText="国籍"/>
                           <asp:BoundField DataField="JOB"   HeaderText="职业"/>          
                          <asp:BoundField DataField="PHONENO"     HeaderText="联系电话"/>                 
                          <asp:BoundField DataField="ADDRESS"   HeaderText="联系地址"/> 
                          <asp:BoundField DataField="EMAIL"  HeaderText="电子邮件"/>
                          
                   </Columns>   
                   
                   <EmptyDataTemplate>
                      <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                         <tr class="tabbt">
                         <td>ID</td>
                              <td>姓名</td> 
                              <td>证件类型</td>
                              <td>证件号码</td>
                              <td>注册资金</td>
                              <td>安全值</td>
                              <td>审核状态 </td>
                              <td>出生日期</td>
                              <td>国籍</td>
                              <td>职业</td>
                              <td>联系电话</td>
                              <td>联系地址</td>
                              <td>电子邮件</td>
                              

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

<%@ Page Language="C#" AutoEventWireup="true" CodeFile="WA_AntiWarnQuery.aspx.cs" Inherits="ASP_Warn_WA_AntiWarnQuery" EnableEventValidation="false" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >

<head id="Head1" runat="server">
    <title>风险监控</title>
    <script type="text/javascript" src="../../js/myext.js"></script>
	<link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <script>
        function closeConfirm() {
            MyExtConfirm('确认', '是否确定关闭返销所有选中主体？', closeConfirmCb);
            return false;
        }

        function closeConfirmCb(btn) {
            if (btn == 'yes') {
                $get('hidWarning').value = 'Close';
                $get('btnConfirm').click();
            }
        }
    </script>
</head>

<body>
  <form id="form1" runat="server">
    <div class="tb">风险监控->关闭交易查询</div>
    
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
    
    <script type="text/javascript" language="javascript">
        function SelectAll(tempControl) {
            //将除头模板中的其它所有的CheckBox取反 

            var theBox = tempControl;
            xState = theBox.checked;

            //elem = theBox.form.elements;
            elem = theBox.parentNode.parentNode.parentNode.getElementsByTagName("input");
            for (i = 0; i < elem.length; i++)
                if (elem[i].type == "checkbox" && elem[i].id != theBox.id) {
                    if (elem[i].checked != xState)
                        elem[i].click();
                }
        }
    </script> 
 
    <asp:HiddenField runat="server" ID="hidWarning" />
    <asp:LinkButton  runat="server" ID="btnConfirm" OnClick="btnConfirm_Click"/>
    <asp:UpdatePanel ID="UpdatePanel1" runat="server" RenderMode="Inline">
      <ContentTemplate>
        
        <asp:BulletedList ID="bulMsgShow" runat="server"/>
        <script runat="server" >public override void ErrorMsgShow(){ErrorMsgHelper(bulMsgShow);}</script>
        
        <div class="con">
            <div class="card">查询条件</div>
             
            <div class="kuang5">
              <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                
                   <tr>
                    <td><div align="right">监控条件:</div></td>
                    <td><asp:DropDownList ID="selCond" CssClass="inputlong" runat="server" 
                            AutoPostBack="true" onselectedindexchanged="selCond_SelectedIndexChanged" />
                      
                    </td>
                    <td> <div align="right">监控开始日期:</div></td><td> <asp:TextBox ID="txtBeginTime" runat="server" CssClass="input" />
                    <ajaxToolkit:CalendarExtender ID="CalendarExtender1" runat="server" TargetControlID="txtBeginTime" Format="yyyyMMdd" />
                    </td>
                    <td> <div align="right">监控结束日期:</div></td><td> <asp:TextBox ID="txtEndTime" runat="server" CssClass="input" />
                    <ajaxToolkit:CalendarExtender ID="FCalendar1" runat="server" TargetControlID="txtEndTime" Format="yyyyMMdd" />
                    </td>
                  </tr>
                  <tr>  
                    <td> <div align="right">风险等级:</div></td>
                    <td>
                      <asp:DropDownList ID="selRiskGrade" CssClass="input" runat="server" AutoPostBack="false" />
                    </td>
                    <td><div align="right">主体类型:</div></td>
                    <td>
                      <asp:DropDownList ID="selSubjectType" CssClass="input" runat="server" AutoPostBack="false" />
                    </td>
                    <td><div align="right">额度分类:</div></td>
                    <td>
                      <asp:DropDownList ID="selLimitType" CssClass="input" runat="server" AutoPostBack="false" />
                    </td>
                  </tr>
              </table>
            </div>
     
            <table width="100%" border="0" cellpadding="0" cellspacing="0" class="12text">
              <tr>
                <td width="30%"><div class="jieguo">可疑主体列表</div></td>
                <td>可疑主体数量:<asp:Label runat="server" ID="labCnt" Text="0" /></td>
                <td>
                  <asp:Button ID="btnClear" Width="50px" runat="server" Text="重置" CssClass="button1" OnClick="btnClear_Click" />
                  <asp:Button ID="btnQuery" Width="50px" runat="server" Text="查询" CssClass="button1" OnClick="btnQuery_Click" />
                </td>
                 <td>
                  <asp:Button ID="btnClose"  runat="server" Text="关闭返销" CssClass="button1" OnClientClick="return closeConfirm()"/>
                  
                </td>
                <td>
                   <asp:Button ID="btnExportXML" CssClass="button1fix" runat="server" Text="导出正常报文"
                                OnClick="btnExportXML_Click" /><span class="red">仅选中的可导出</span>
                </td>
              </tr>
            </table>
            
          <asp:HiddenField ID="hidSubjectType" runat="server" />
                    
            <div class="kuang5">
<%--              <div class="gdtb" style="height:240px">
--%>

              <asp:GridView ID="gvResult" runat="server"
                    Width = "100%"
                    CssClass="tab1"
                    HeaderStyle-CssClass="tabbt"
                   AlternatingRowStyle-CssClass="tabjg"
                    SelectedRowStyle-CssClass="tabsel"
                    PagerSettings-Mode="NumericFirstLast"
                    PagerStyle-HorizontalAlign="left"
                    PagerStyle-VerticalAlign="Top"
                    AutoGenerateColumns="False" >
                <Columns>
                  <asp:TemplateField>
                   <HeaderTemplate>
                      <asp:CheckBox ID="chkAllSubject" runat="server"  AutoPostBack="true" OnCheckedChanged="chkAllSubject_CheckedChanged" />
                    </HeaderTemplate>
                   <%-- <HeaderTemplate>
                        <asp:CheckBox ID="chkAllSubject" runat="server" onclick="javascript:SelectAll(this);" />
                    </HeaderTemplate>--%>
                    <ItemTemplate>
                        <asp:CheckBox ID="chkSubject" runat="server"   AutoPostBack="true" OnCheckedChanged="chkAllSubject_CheckedChanged"/>
                    </ItemTemplate>
                 </asp:TemplateField>
                  <asp:TemplateField>
                <HeaderTemplate>#</HeaderTemplate>
                    <ItemTemplate>
                      <%#Container.DataItemIndex + 1%>
                    </ItemTemplate>
                  </asp:TemplateField>
                  <asp:BoundField DataField="ID"       HeaderText="主体ID"/>
                  <asp:BoundField DataField="SUBJECTCODE"       HeaderText="主体编号"/> 
                  <asp:BoundField DataField="NAME"       HeaderText="主体名称"/> 
                  <asp:BoundField DataField="PAPERTYPE"     HeaderText="证件类型"/>  
                  <asp:BoundField DataField="PAPERNAME"  HeaderText="证件号码" />   
                  <asp:BoundField DataField="TRADENUM"  HeaderText="主体交易数量" />        
                  <asp:BoundField DataField="ADDR"     HeaderText="地址" />             
                  <asp:BoundField DataField="PHONE"      HeaderText="电话"/>                 
                  <asp:BoundField DataField="EMAIL"     HeaderText="邮件"/> 
                  <asp:BoundField DataField="CALLINGNO"    HeaderText="行业" />
                  <asp:BoundField DataField="BACKTIME"    HeaderText="关闭时间" />
                  <asp:BoundField DataField="CLOSEREASON"    HeaderText="关闭原因"/>
                </Columns>     
                      
                <EmptyDataTemplate>
                  <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                    <tr class="tabbt">
                    <td><input type="checkbox" /></td>
                               <td>#</td>
                               <td>主体ID</td>
                               <td>主体编号</td>
                       <td>主体名称</td>
                        <td>证件类型</td>
                        <td>证件号码</td>
                        <td>地址</td>
                        <td>电话</td>
                        <td>邮件</td>
                        <td>行业</td>
                        <td>关闭时间</td>
                         <td>关闭原因</td>
                    </tr>
                  </table>
                </EmptyDataTemplate>
              </asp:GridView>
<%--              </div>
--%>            </div>
             <table width="100%" border="0" cellpadding="0" cellspacing="0" class="12text">
              <tr>
                <td width="30%"><div class="jieguo">主体交易列表</div></td>
                <td>主体交易数量:<asp:Label runat="server" ID="labDetailCnt" Text="0" /></td>
                <td>&nbsp;
                </td>
              </tr>
            </table>
           <div class="kuang5">
              <asp:GridView ID="gridDetail" runat="server"
                    Width = "100%"
                    CssClass="tab1"
                    HeaderStyle-CssClass="tabbt"
                    AlternatingRowStyle-CssClass="tabjg"
                    SelectedRowStyle-CssClass="tabsel"
                    AllowPaging="False"
                    AutoGenerateColumns="False" >
                <Columns>
                 <asp:TemplateField>
                    <HeaderTemplate>
                        <asp:CheckBox ID="chkAllDetail" runat="server" Checked onclick="javascript:SelectAll(this);" />
                    </HeaderTemplate>
                    <ItemTemplate>
                        <asp:CheckBox ID="chkDetail" runat="server"  Checked/>
                    </ItemTemplate>
                 </asp:TemplateField>
                  <asp:TemplateField>
                    <HeaderTemplate>#</HeaderTemplate>
                    <ItemTemplate><%#Container.DataItemIndex + 1%></ItemTemplate>
                  </asp:TemplateField>
                  <asp:BoundField DataField="ID"           HeaderText="主体交易ID"/>
                  <asp:BoundField DataField="NAME"           HeaderText="主体名称"/>
                  <asp:BoundField DataField="PAPERTYPE"     HeaderText="证件类型"/>
                  <asp:BoundField DataField="PAPERNAME"     HeaderText="证件号码"  />             
                  <asp:BoundField DataField="PAYMODE"     HeaderText="付款方式"/> 

                  <%--<asp:BoundField DataField="TRADEMONEY"    HeaderText="交易金额" />--%>
                   <asp:TemplateField>
                    <HeaderTemplate>交易金额</HeaderTemplate>
                    <ItemTemplate><%#(Convert.ToInt32(Eval("TRADEMONEY")) / 100.0).ToString("0.00")%></ItemTemplate>
                  </asp:TemplateField>
                  <asp:BoundField DataField="TRADETIME"      HeaderText="交易时间" />
                  <asp:BoundField DataField="SPNAME"     HeaderText="商品名称" />
                  <asp:BoundField DataField="CARDNO"   HeaderText="卡号" />
                  <asp:BoundField DataField="TRADEID"   HeaderText="交易流水号" />
                  <asp:BoundField DataField="BANKNAME"       HeaderText="开户银行"/>
                  <asp:BoundField DataField="BANKACCOUNT"       HeaderText="银行账号"/>
                  <asp:BoundField DataField="PARTNERNO"      HeaderText="商户编码" />
                  <asp:BoundField DataField="PARTNERNAME"     HeaderText="商户名称"/>
                  <asp:BoundField DataField="PAYMENTTAG"     HeaderText="收付标志"/>
                  <asp:BoundField DataField="SUBJECTID"     HeaderText="主体ID"/>
                </Columns>  
                         
                <EmptyDataTemplate>
                  <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                    <tr class="tabbt">
                    <td><input type="checkbox" /></td>
                        <td>#</td>
                        <td>主体交易ID</td>
                        <td>主体名称</td>
                        <td>证件类型</td>
                        <td>证件号码</td>
                        <td>付款方式</td>
                        <td>交易金额</td>
                        <td>交易时间</td>
                        <td>商品名称</td>
                        <td>卡号</td>
                        <td>交易流水</td>
                        <td>开户银行</td>
                        <td>银行账号</td>
                        <td>商户编码</td>
                        <td>商户名称</td>
                        <td>收付标志</td>
                        <td>主体ID</td>
                    </tr>   
                  </table>
                </EmptyDataTemplate>
                
              </asp:GridView>
            </div>       
          </div>

        </ContentTemplate>

        <Triggers>
            <asp:PostBackTrigger ControlID="btnExportXML" />
        </Triggers>
       </asp:UpdatePanel>
  </form>
</body>
</html>

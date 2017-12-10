<%@ Page Language="C#" AutoEventWireup="true" CodeFile="WA_WarnManage.aspx.cs" Inherits="ASP_Warn_WA_WarnManage" EnableEventValidation="false" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >

<head id="Head1" runat="server">
    <title>帐务告警管理</title>
    <script type="text/javascript" src="../../js/myext.js"></script>
	<link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
</head>

<body>
  <form id="form1" runat="server">
    <div class="tb">帐务监控->帐务告警管理</div>
    
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
		function closeConfirm(){
		    MyExtConfirm('确认','是否确定关闭所有选中告警？', closeConfirmCb);
            return false;
		}
		
		function closeConfirmCb(btn)
        {
            if (btn == 'yes' )
            {
                $get('hidWarning').value = 'Close';
                $get('btnConfirm').click();
            }
        }
        
        function blackConfirm(){
		    MyExtConfirm('确认',
		    '是否确定将选中告警对应的账户导入黑名单？<br>' + 
		    '如果该账户已在黑名单中，则黑名单信息被覆盖为最新；<br>' + 
		    '如果该账户目前在监控名单中，则从监控名单删除'
		    , blackConfirmCb);
            return false;
		}
		function blackConfirmCb(btn)
        {
            if (btn == 'yes' )
            {
                $get('hidWarning').value = 'Black';
                $get('btnConfirm').click();
            }
        }
        
        function monSubmitConfirm(){
		    MyExtConfirm('确认',
		    '是否确定针对选中告警生成监控名单？<br>' + 
		    '如果账户已在黑名单中，则对应黑名单信息将被删除'
		    , monSubmitConfirmCb);
            return false;
		}
		function monSubmitConfirmCb(btn)
        {
            if (btn == 'yes' )
            {
                $get('hidWarning').value = 'MonitorSubmit';
                $get('btnConfirm').click();
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
            <%--<div class="card">查询条件</div>--%>
             
            <div class="kuang5">
              <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                  <tr>
                    <td><div align="right">监控条件:</div></td>
                    <td colspan="3"><asp:DropDownList ID="selCond" CssClass="inputmidder" runat="server" AutoPostBack="false" />
                      
                    </td>
                    <td>&nbsp;</td><td>&nbsp;</td>
                  </tr>
                 
                  <tr>  
                    <td> <div align="right">卡号:</div></td>
                    <td>
                      <asp:TextBox ID="txtCardNO" runat="server" CssClass="input" MaxLength="16" />
                    </td>
                    <td><div align="right">最近告警类型:</div></td>
                    <td>
                      <asp:DropDownList ID="selType" CssClass="inputmid" runat="server" AutoPostBack="false" />
                    </td>
                    <td><div align="right">最近告警形成:</div></td>
                    <td>
                      <asp:DropDownList ID="selSrc" CssClass="input" runat="server" AutoPostBack="false" />
                    </td>
                  </tr>
              
                  <tr>
                    <td><div align="right">最近级别高于:</div></td>
                    <td>
                      <asp:TextBox ID="txtLevel" runat="server" CssClass="input" MaxLength="1" />
                    </td>
                    <td><div align="right">详单数量超过:</div></td>
                    <td>
                      <asp:TextBox ID="txtDetails" runat="server" CssClass="input" MaxLength="8" />
                    </td>
                    <td><div align="right">告警时长超过:</div></td>
                    <td>
                      <asp:TextBox ID="txtTimespan" runat="server" CssClass="input" MaxLength="8" />小时
                    </td>
                  </tr>
              </table>
            </div>
     
            <table width="100%" border="0" cellpadding="0" cellspacing="0" class="12text">
              <tr>
                <td width="30%"><div class="jieguo">告警列表</div></td>
                <td>主告警单数量:<asp:Label runat="server" ID="labCnt" Text="0" /></td>
                <td>
                  <asp:Button ID="btnClear" Width="50px" runat="server" Text="重置" CssClass="button1" OnClick="btnClear_Click" />
                  <asp:Button ID="btnQuery" Width="50px" runat="server" Text="查询" CssClass="button1" OnClick="btnQuery_Click" />
                </td>
              </tr>
            </table>
                    
            <div class="kuang5">
<%--              <div class="gdtb" style="height:240px">
--%>
              <asp:GridView ID="gvResult" runat="server"
                    Width = "1500"
                    CssClass="tab1"
        AllowSorting="true" OnSorting="gvResult_Sorting"
                    HeaderStyle-CssClass="tabbt"
                    AutoGenerateSelectButton="true"
                   AlternatingRowStyle-CssClass="tabjg"
                    SelectedRowStyle-CssClass="tabsel"
                    AllowPaging="True"
                    PageSize="200"
                    PagerSettings-Mode="NumericFirstLast"
                    PagerStyle-HorizontalAlign="left"
                    PagerStyle-VerticalAlign="Top"
                    AutoGenerateColumns="False" 
                    OnPageIndexChanging="gvResult_Page"
                    OnSelectedIndexChanged="gvResult_SelectedIndexChanged"
                    OnRowDataBound="gvResult_RowDataBound">
                <Columns>
                  <asp:TemplateField>
                   <HeaderTemplate>
                      <asp:CheckBox ID="checkAll" runat="server"  AutoPostBack="true" OnCheckedChanged="checkAll_CheckedChanged" />
                    </HeaderTemplate>
                    <ItemTemplate>
                      <asp:CheckBox ID="checkItem" runat="server"/>
                    </ItemTemplate>
                     </asp:TemplateField>
                  <asp:TemplateField>
                <HeaderTemplate>#</HeaderTemplate>
                    <ItemTemplate>
                      <%#Container.DataItemIndex + 1%>
                    </ItemTemplate>
                  </asp:TemplateField>
                  
                  <asp:BoundField DataField="CARDNO"       HeaderText="IC卡号" SortExpression="CARDNO"/> 
                  <asp:BoundField DataField="CONDNAME"     HeaderText="最近监控条件" SortExpression="CONDNAME"/>  
                  <asp:BoundField DataField="INITIALTIME"  HeaderText="首次告警时间" SortExpression="INITIALTIME"  HtmlEncode="false" DataFormatString="{0:yyyy-MM-dd HH:mm}" />             
                  <asp:BoundField DataField="LASTTIME"     HeaderText="最近告警时间" SortExpression="LASTTIME"  HtmlEncode="false" DataFormatString="{0:yyyy-MM-dd HH:mm}" />             
                  <asp:BoundField DataField="DETAILS"      HeaderText="次数" SortExpression="DETAILS"/>                 
                  <asp:BoundField DataField="WARNTYPE"     HeaderText="最近类型" SortExpression="WARNTYPE"/> 
                  <asp:BoundField DataField="WARNLEVEL"    HeaderText="最近级别" SortExpression="WARNLEVEL" />
                  <asp:BoundField DataField="WARNSRC"      HeaderText="最近告警形成" SortExpression="WARNSRC" />
                  <asp:BoundField DataField="PREMONEY"     HeaderText="最近消费前余额" SortExpression="PREMONEY" DataFormatString="{0:n}" HtmlEncode="False"/>
                  <asp:BoundField DataField="TRADEMONEY"   HeaderText="最近消费金额" SortExpression="TRADEMONEY" DataFormatString="{0:n}" HtmlEncode="False"/>                          
                  <asp:BoundField DataField="ACCBALANCE"   HeaderText="最近账户余额" SortExpression="ACCBALANCE" DataFormatString="{0:n}" HtmlEncode="False"/>                          
                  <asp:BoundField DataField="REMARK"       HeaderText="备注"/>
                </Columns>     
                      
                <EmptyDataTemplate>
                  <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                    <tr class="tabbt">
                        <td><input type="checkbox" /></td>
                               <td>#</td>
                       <td>IC卡号</td>
                        <td>最近监控条件</td>
                        <td>首次告警时间</td>
                        <td>最近告警时间</td>
                        <td>次数</td>
                        <td>最近告警类型</td>
                        <td>最近告警级别</td>
                        <td>最近告警形成</td>
                        <td>最近消费前余额</td>
                        <td>最近消费金额</td>
                        <td>最近账户余额</td>
                        <td>备注</td>
                    </tr>
                  </table>
                </EmptyDataTemplate>
              </asp:GridView>
<%--              </div>
--%>            </div>
            
            <table width="100%" border="0" cellpadding="0" cellspacing="0" class="12text">
              <tr>
                <td width="80%"></td>
                <td>
                  <asp:Button ID="btnClose"   Width="50px"  runat="server" Text="关闭"     CssClass="button1" OnClientClick="return closeConfirm()"/>
                  <asp:Button ID="btnMonitor" Width="50px"  runat="server" Text="监控. . ."     CssClass="button1" OnClick="btnMonitor_Click"/>
                  <asp:Button ID="btnBalck"   Width="80px"  runat="server" Text="入黑名单" CssClass="button1" OnClientClick="return blackConfirm()" />
                </td>
              </tr>
            </table>
            
            <asp:Panel id="area1" runat="server" Visible="true">
             <table width="100%" border="0" cellpadding="0" cellspacing="0" class="12text">
              <tr>
                <td width="30%"><div class="jieguo">告警详单列表</div></td>
                <td>告警详单数量:<asp:Label runat="server" ID="labDetailCnt" Text="0" /></td>
                <td>&nbsp;
                </td>
              </tr>
            </table>
           <div class="kuang5">
              <asp:GridView ID="gridDetail" runat="server"
                    Width = "1500"
                    CssClass="tab1"
                    HeaderStyle-CssClass="tabbt"
                    AlternatingRowStyle-CssClass="tabjg"
                    SelectedRowStyle-CssClass="tabsel"
                    AllowPaging="False"
                    AutoGenerateColumns="False" >
                <Columns>
                  <asp:TemplateField>
                    <HeaderTemplate>#</HeaderTemplate>
                    <ItemTemplate><%#Container.DataItemIndex + 1%></ItemTemplate>
                  </asp:TemplateField>
                  <asp:BoundField DataField="ID"           HeaderText="消费清单ID"/>
                  <asp:BoundField DataField="CONDNAME"     HeaderText="监控条件"/>
                  <asp:BoundField DataField="LASTTIME"     HeaderText="告警时间"  HtmlEncode="false" DataFormatString="{0:yyyy-MM-dd HH:mm:ss}" />             
                  <asp:BoundField DataField="WARNTYPE"     HeaderText="告警类型"/> 
                  <asp:BoundField DataField="WARNLEVEL"    HeaderText="告警级别" />
                  <asp:BoundField DataField="WARNSRC"      HeaderText="告警形成" />
                  <asp:BoundField DataField="PREMONEY"     HeaderText="消费前余额" DataFormatString="{0:n}" HtmlEncode="False"/>
                  <asp:BoundField DataField="TRADEMONEY"   HeaderText="消费金额" DataFormatString="{0:n}" HtmlEncode="False"/>
                  <asp:BoundField DataField="ACCBALANCE"   HeaderText="账户余额" DataFormatString="{0:n}" HtmlEncode="False"/>
                  <asp:BoundField DataField="REMARK"       HeaderText="备注"/>
                </Columns>  
                         
                <EmptyDataTemplate>
                  <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                    <tr class="tabbt">
                        <td>#</td>
                        <td>消费清单ID</td>
                        <td>告警条件</td>
                        <td>告警时间</td>
                        <td>告警类型</td>
                        <td>告警级别</td>
                        <td>告警形成</td>
                        <td>消费前余额</td>
                        <td>消费金额</td>
                        <td>账户余额</td>
                        <td>备注</td>
                    </tr>
                  </table>
                </EmptyDataTemplate>
                
              </asp:GridView>
            </div>       
            </asp:Panel>
            
            <asp:Panel id="area2" runat="server" Visible="false">
              <div class="card">填写监控定制条件</div>
              <div class="kuang5">
                <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                  <tr>
                    <td><div align="right">监控条件:</div></td>
                    <td>
                      <asp:DropDownList ID="selMonCond" CssClass="inputmidder" runat="server" AutoPostBack="false" />
                    </td>
<%--                    <td><div align="right">告警类型:</div></td>
                    <td>
                      <asp:DropDownList ID="selMonType" CssClass="inputmid" runat="server" AutoPostBack="false" />
                    </td>
--%>                    <td><div align="right">告警级别:</div></td>
                    <td>
                      <asp:TextBox ID="txtMonLevel" runat="server" CssClass="input" MaxLength="1" />
                    </td>
                  </tr>
                  </table>
              </div>
              <table width="100%" border="0" cellpadding="0" cellspacing="0" class="12text">
              <tr>
                <td width="80%"></td>
                <td>
                  <asp:Button ID="btnMonCancel" Width="50px"  runat="server" Text="取消" CssClass="button1" OnClick="btnMonCancel_Click" />
                  <asp:Button ID="btnMonSubmit" Width="50px"  runat="server" Text="提交" CssClass="button1" OnClientClick="return monSubmitConfirm()" />
                </td>
              </tr>
              </table>
            </asp:Panel>
            
          </div>

        </ContentTemplate>
       </asp:UpdatePanel>
  </form>
</body>
</html>

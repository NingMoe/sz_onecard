<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PS_TransferDiscountApproval.aspx.cs" Inherits="ASP_PartnerShip_PS_TransferDiscountApproval" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
   <title>结算单元优惠审核</title>
	<link rel="stylesheet" type="text/css" href="../../css/frame.css" />
   <link href="../../css/card.css" rel="stylesheet" type="text/css" />
   
</head>
<body>
    <form id="form1" runat="server">
      <div class="tb">合作伙伴->结算单元优惠审核</div>
      <ajaxToolkit:ToolkitScriptManager runat="Server" EnableScriptGlobalization="true"
            EnableScriptLocalization="true" ID="ScriptManager2" />
        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
            <ContentTemplate>
           
            <asp:BulletedList ID="bulMsgShow" runat="server"/>
         <script runat="server" >public override void ErrorMsgShow(){ErrorMsgHelper(bulMsgShow);}</script>
      
           <div class="con">
              <div class="jieguo">待审核结算单元优惠信息</div>
              <div class="kuang5">
                <div class="gdtb" style="height:380px">
                 
                   <asp:GridView ID="lvwBalUnitsFiAppral" runat="server"
                    CssClass="tab1"
                    Width ="120%"
                    HeaderStyle-CssClass="tabbt"
                    AlternatingRowStyle-CssClass="tabjg"
                    SelectedRowStyle-CssClass="tabsel"
                    AllowPaging="True"
                    PageSize="100"
                    PagerSettings-Mode="NumericFirstLast"
                    PagerStyle-HorizontalAlign="Left"
                    PagerStyle-VerticalAlign="Top"
                    AutoGenerateColumns="False"
                    OnPageIndexChanging="lvwBalUnitsFiAppral_Page"
                    OnSelectedIndexChanged="lvwBalUnitsFiAppral_SelectedIndexChanged"
                    OnRowCreated="lvwBalUnitsFiAppral_RowCreated"
                    >
                    <Columns>
                        <asp:BoundField DataField="BIZTYPE"        HeaderText="操作类型"/>
                        <asp:BoundField DataField="RATE"           HeaderText="优惠折扣"/>
                        <asp:BoundField DataField="preferentialupper" HeaderText="优惠上线" />
                        <asp:BoundField DataField="special" HeaderText="是否支持补助消费" />
                        <asp:BoundField DataField="begindate" HeaderText="优惠开始时间" />
                        <asp:BoundField DataField="enddate" HeaderText="优惠结束时间" />
                        <asp:BoundField DataField="balunittypename" HeaderText="商户类别" />
                        <asp:BoundField DataField="NAME" HeaderText="佣金方案" />
                        <asp:BoundField DataField="BALUNITNO"      HeaderText="结算单元编码"/> 
                        <asp:BoundField DataField="BALUNIT"        HeaderText="结算单元名称"/>             
                        <asp:BoundField DataField="BALUNITTYPE"    HeaderText="单元类型"/>                 
                      <%--  <asp:BoundField DataField="SOURCETYPE"     HeaderText="来源识别类型"/>   --%>          
                        <asp:BoundField DataField="CREATETIME"     HeaderText="合作时间" DataFormatString="{0:yyyy-MM-dd}" HtmlEncode="False"/>                 
                        <asp:BoundField DataField="CALLINGNAME"    HeaderText="行业"/>                     
                        <asp:BoundField DataField="CORPNAME"       HeaderText="单位"/>                    
                        <asp:BoundField DataField="DEPARTNAME"     HeaderText="部门"/>                      
                        <%--<asp:BoundField DataField="BANKNAME"       HeaderText="开户银行"/>                  
                        <asp:BoundField DataField="BANKACCNO"      HeaderText="银行帐号"/>  --%>                                                        
                     <%--   <asp:BoundField DataField="SERMANAGER"      HeaderText="商户经理"/> --%>     
                        
                        <asp:BoundField DataField="STAFFNAME"      HeaderText="申请员工"/>  
                        <asp:BoundField DataField="applydate"      HeaderText="申请时间"/>     
                       

                   </Columns>   
                   
                   <EmptyDataTemplate>
                      <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                         <tr class="tabbt">
                          <td>操作类型</td>
                          <td>优惠折扣</td>
                          <td>优惠上线</td>
                          <td>是否支持补助消费</td>
                          <td>优惠开始时间</td>
                          <td>优惠结束时间</td>
                          <td>商户类别</td>
                          <td>佣金方案</td>
                          <td>结算单元编码</td>
                          <td>结算单元名称</td>
                          <td>单元类型</td>
                          <%--<td>来源识别类型</td>--%>
                          <td>合作时间</td>
                          <td>行业</td>
                          <td>单位</td>
                          <td>部门</td>
            <%--              <td>开户银行</td>
                          <td>银行帐号</td>
                          <td>商户经理</td>--%>
                          <td>申请员工</td>
                          <td>申请时间</td>
                         
                         </tr>
                      </table>
                   </EmptyDataTemplate>
                 </asp:GridView>
                    
                  
                  
                  
                </div>
              </div>
             </div>             
             
             <div class="footall"></div>
            <div class="btns">
              <table width="200" border="0" align="right" cellpadding="0" cellspacing="0">
                <tr>
                  <td><asp:Button ID="btnPass" runat="server" Text="通过" CssClass="button1" OnClick="btnPass_Click" /></td>
                  <td><asp:Button ID="btnCancel" runat="server" Text="作废" CssClass="button1" OnClick="btnCancel_Click" /></td>
                </tr>
              </table>
            </div>
      
     
          </ContentTemplate>
       </asp:UpdatePanel>

    </form>
</body>
</html>

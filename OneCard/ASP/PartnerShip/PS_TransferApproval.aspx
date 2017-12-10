<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PS_TransferApproval.aspx.cs" Inherits="ASP_PartnerShip_PS_TransferApproval" EnableEventValidation="false" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <title>结算单元审批</title>
	<link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />

</head>
<body>
    <form id="form1" runat="server">
      <div class="tb">合作伙伴->结算单元审批</div>
    
      <ajaxToolkit:ToolkitScriptManager runat="Server" EnableScriptGlobalization="true"
            EnableScriptLocalization="true" ID="ScriptManager2" />
       <asp:UpdatePanel ID="UpdatePanel1" runat="server">
            <ContentTemplate>
           
            <asp:BulletedList ID="bulMsgShow" runat="server"/>
         <script runat="server" >public override void ErrorMsgShow(){ErrorMsgHelper(bulMsgShow);}</script> 
            
            <div class="con">
              <div class="jieguo">待审批结算单元信息</div>
              <div class="kuang5">
                <div class="gdtb" style="height:180px">
                
                  <asp:GridView ID="lvwBalUnitsAppral" runat="server"
                    CssClass="tab1"
                    Width ="2800"
                    HeaderStyle-CssClass="tabbt"
                    AlternatingRowStyle-CssClass="tabjg"
                    SelectedRowStyle-CssClass="tabsel"
                    AllowPaging="True"
                    PageSize="100"
                    PagerSettings-Mode="NumericFirstLast"
                    PagerStyle-HorizontalAlign="Left"
                    PagerStyle-VerticalAlign="Top"
                    AutoGenerateColumns="False"
                    OnPageIndexChanging="lvwBalUnitsAppral_Page"
                    OnSelectedIndexChanged="lvwBalUnitsAppral_SelectedIndexChanged"
                    OnRowCreated="lvwBalUnitsAppral_RowCreated">
                    <Columns>
                        <asp:BoundField DataField="BIZTYPE"        HeaderText="操作类型"/>
                        <asp:BoundField DataField="BALUNITNO"      HeaderText="结算单元编码"/> 
                        <asp:BoundField DataField="BALUNIT"        HeaderText="结算单元名称"/>             
                        <asp:BoundField DataField="BALUNITTYPE"    HeaderText="单元类型"/>                 
                        <asp:BoundField DataField="SOURCETYPE"     HeaderText="来源识别类型"/>             
                        <asp:BoundField DataField="CREATETIME"     HeaderText="合作时间" DataFormatString="{0:yyyy-MM-dd}" HtmlEncode="False"/>                 
                        <asp:BoundField DataField="CALLINGNAME"    HeaderText="行业"/>                     
                        <asp:BoundField DataField="CORPNAME"       HeaderText="单位"/>                    
                        <asp:BoundField DataField="DEPARTNAME"     HeaderText="部门"/>                      
                        <asp:BoundField DataField="BANKNAME"       HeaderText="开户银行"/>                  
                        <asp:BoundField DataField="BANKACCNO"      HeaderText="银行帐号"/>                  
                                        
                        <asp:BoundField DataField="SERMANAGER"     HeaderText="商户经理"/>      
                        <asp:BoundField DataField="BALLEVEL"       HeaderText="结算级别"/>                 
                        <asp:BoundField DataField="BALCYCLETYPE"   HeaderText="结算周期类型"/>            
                        <asp:BoundField DataField="BALINTERVAL"    HeaderText="结算周期跨度"/>             
                        <asp:BoundField DataField="FINCYCLETYPE"   HeaderText="划账周期类型"/>             
                        <asp:BoundField DataField="FININTERVAL"    HeaderText="划账周期跨度"/>             
                        <asp:BoundField DataField="FINTYPE"        HeaderText="转账类型"/>                 
                        <asp:BoundField DataField="COMFEETAKE"     HeaderText="佣金扣减方式"/> 
                        <asp:BoundField DataField="FINBANK"        HeaderText="转出银行"/>              
                        <asp:BoundField DataField="LINKMAN"        HeaderText="联系人"/>                                     
                        <asp:BoundField DataField="UNITPHONE"      HeaderText="联系电话"/>                
                        <asp:BoundField DataField="UNITADD"        HeaderText="联系地址"/> 
                        <asp:BoundField DataField="UNITEMAIL"      HeaderText="电子邮件"/>        
                        <asp:BoundField DataField="OPERATESTAFF"   HeaderText="操作员工"/>
                        <asp:BoundField DataField="OPERATETIME"    HeaderText="操作时间"/>
                        <asp:BoundField DataField="PURPOSE"        HeaderText="收款人账户类型"/>    
                        <asp:BoundField DataField="BankChannel"    HeaderText="银行渠道"/>
                        <asp:BoundField DataField="REGIONNAME"     HeaderText="地区名称" />
                        <asp:BoundField DataField="DELIVERYMODE"   HeaderText="POS投放模式" />   
                        <asp:BoundField DataField="APPCALLING"     HeaderText="应用行业" />      
                   </Columns>   
                   
                   <EmptyDataTemplate>
                      <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                         <tr class="tabbt">
                          <td>操作类型</td> 
                          <td>结算单元编码</td>
                          <td>结算单元名称</td>
                          <td>单元类型</td>
                          <td>来源识别类型</td>
                          <td>合作时间</td>
                          <td>行业</td>
                          <td>单位</td>
                          <td>部门</td>
                          <td>开户银行</td>
                          <td>银行帐号</td>
                          <td>商户经理</td>
                          <td>结算级别</td>
                          <td>结算周期类型</td>
                          <td>结算周期跨度</td>
                          <td>划账周期类型</td>
                          <td>划账周期跨度</td>
                          <td>转账类型</td>
                          <td>佣金扣减方式</td>
                          <td>转出银行</td>
                          <td>联系人</td>
                          <td>联系电话</td>
                          <td>联系地址</td>
                          <td>电子邮件</td>
                          <td>操作员工</td>
                          <td>操作时间</td>
                          <td>收款人账户类型</td>
                          <td>银行渠道</td>
                          <td>地区名称</td>
                          <td>POS投放模式</td>
                          <td>应用行业</td>
                         </tr>
                      </table>
                   </EmptyDataTemplate>
                </asp:GridView>
                    
                  
               </div>
              </div>
            </div>
             <div class="basicinfoz3">
             <div class="base">结算单元信息</div>
             <div class="kuang5">
               <table width="760" border="0" cellpadding="0" cellspacing="0" class="text25">
                 <tr>
                   <td align="right">单元编码:</td>
                   <td width="110"><asp:Label ID="labBalUnitNO" runat="server" /></td>
                   <td align="right">单元名称:</td>
                   <td width="110"><asp:Label ID="labBalUnit" runat="server" /></td>
                   <td align="right">单元类型:</td>
                   <td width="110"><asp:Label ID="labBalType" runat="server" /></td>
                   <td align="right">来源类型:</td>
                   <td width="110"><asp:Label ID="labSourceType" runat="server"/></td>
                 </tr>
                 <tr>
                   <td align="right">合作时间:</td>
                   <td><asp:Label ID="labCreateTime" runat="server"/></td>
                   <td align="right">操作员工:</td>
                   <td><asp:Label ID="labOpeStuff" runat="server"/></td>
                   <td align="right">行业:</td>
                   <td><asp:Label ID="labCalling" runat="server"/></td>
                   <td align="right">单位:</td>
                   <td><asp:Label ID="labCorp" runat="server"/></td>
                 </tr>
                 <tr>
                   <td align="right">部门:</td>
                   <td><asp:Label ID="labDepart" runat="server"/></td>
                   <td align="right">地区:</td>
                   <td><asp:Label ID="labRegion" runat="server" /></td>
                   <td align="right">POS投放模式:</td>
                   <td><asp:Label ID="labDeliveryMode" runat="server" /></td>
                   <td align="right">应用行业:</td>
                   <td><asp:Label ID="labAppCalling" runat="server" /></td>
                 </tr>
                 <tr>
                   <td align="right">开户银行:</td>
                   <td><asp:Label ID="labBank" runat="server"/></td>
                    <td align="right">银行帐号:</td>
                  <td><asp:Label ID="labBankAccNo" runat="server"/></td>
                   <td align="right">通道名称:</td>
                   <td><asp:DropDownList CssClass="input" runat="server" ID="selChannel"/></td>
                   <td>&nbsp;</td>
                   <td>&nbsp;</td>                   
                  </tr>
               </table>
               <div class="linex"></div>
               <table width="760" border="0" cellpadding="0" cellspacing="0" class="text25">
                 <tr>
                   <td align="right">结算级别:</td>
                   <td width="110"><asp:Label ID="labBalLevel" runat="server"/></td>
                   <td align="right">结算周期类型:</td>
                   <td width="110"><asp:Label ID="labBalCyclType" runat="server"/></td>
                   <td align="right">结算周期跨度:</td>
                   <td width="110"><asp:Label ID="labBalInterval" runat="server"/></td>
                   <td align="right">划账周期类型:</td>
                   <td width="110"><asp:Label ID="labFinCyclType" runat="server"/></td>
                 </tr>
                 <tr>
                   <td align="right">划账周期跨度:</td>
                   <td><asp:Label ID="labFinCyclInterval" runat="server"/></td>
                   <td align="right">转账类型:</td>
                   <td><asp:Label ID="labFinType" runat="server"/></td>
                   <td align="right">佣金减扣方式:</td>
                   <td><asp:Label ID="labComFeeTake" runat="server"/></td>
                   <td align="right">商户经理:</td>
                   <td><asp:Label ID="labSerMgr" runat="server"/></td>
                 </tr>
                 <tr>
                   <td align="right">转出银行:</td>
                   <td><asp:Label ID="labFinBank" runat="server"/></td>
                   <td align="right">收款人账户类型:</td>
                   <td><asp:Label ID="labPurPose" runat="server"/></td>
                   <td align="right">银行渠道：</td>
                   <td><asp:Label ID="labBankChannel" runat="server" /></td>
                   <td>&nbsp;</td>
                   <td>&nbsp;</td>
                 </tr>
                 <tr>
                    <td colspan="8">&nbsp;</td>
                  </tr>
               </table>
               <div class="linex"></div>
               <table width="760" border="0" cellpadding="0" cellspacing="0" class="text25">
                 <tr>
                   <td align="right">联系人:</td>
                   <td width="110"><asp:Label ID="labLinkMan" runat="server"/></td>
                   <td align="right">联系地址:</td>
                   <td width="110"><asp:Label ID="labAddress" runat="server"/></td>
                   <td align="right">联系电话:</td>
                   <td width="110"><asp:Label ID="labPhone" runat="server"/></td>
                   <td align="right">电子邮件:</td>
                   <td width="110"><asp:Label ID="labEmail" runat="server"/></td>
                 </tr>
                 <tr>
                   <td align="right">备注:</td>
                   <td colspan="3"><asp:Label ID="labReMark" runat="server"/></td>
                   <td colspan="4">&nbsp;</td>
                 </tr>
               </table>
             </div>
             </div>
             <div class="pipinfoz3">
             <div class="info">佣金方案[当前处理]</div>
             <div class="kuang5">
              <div class="gdtb2" style="height:90px;">
            
                <asp:GridView ID="lvwBalComScheme" runat="server"
                    Width = "300"
                    CssClass="tab1"
                    HeaderStyle-CssClass="tabbt"
                    AlternatingRowStyle-CssClass="tabjg"
                    SelectedRowStyle-CssClass="tabsel"
                    AllowPaging="True"
                    PageSize="10"
                    PagerSettings-Mode="NumericFirstLast"
                    PagerStyle-HorizontalAlign="left"
                    PagerStyle-VerticalAlign="Top"
                    AutoGenerateColumns="False"
                    >
                    <Columns>
                        <asp:BoundField DataField="NAME"     HeaderText="方案名称"/>     
                        <asp:BoundField DataField="BEGINTIME"      HeaderText="起始月" DataFormatString="{0:yyyy-MM}" HtmlEncode="False"/>       
                        <asp:BoundField DataField="ENDTIME"        HeaderText="终止月" DataFormatString="{0:yyyy-MM}" HtmlEncode="False"/>  
                        <asp:BoundField DataField="REMARK"         HeaderText="方案描述"/>       
                    </Columns>      
                   <EmptyDataTemplate>
                   <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                     <tr class="tabbt">
                       <td>方案名称</td>
                       <td>起始月</td>
                       <td>终止月</td>
                       <td>方案描述</td>
                    </tr>
                   </table>
                  </EmptyDataTemplate>
                </asp:GridView>
                
              </div>
             </div>
             </div>
             
             <div class="pipinfoz3">
             <div class="info">佣金方案[已有方案]</div>
             <div class="kuang5">
               <div class="gdtb2" style="height:120px;">
            
                <asp:GridView ID="lvwExistedComScheme" runat="server"
                    Width = "300"
                    CssClass="tab1"
                    HeaderStyle-CssClass="tabbt"
                    AlternatingRowStyle-CssClass="tabjg"
                    SelectedRowStyle-CssClass="tabsel"
                    AllowPaging="True"
                    PageSize="10"
                    PagerSettings-Mode="NumericFirstLast"
                    PagerStyle-HorizontalAlign="left"
                    PagerStyle-VerticalAlign="Top"
                    AutoGenerateColumns="False"
                    >
                    <Columns>
                        <asp:BoundField DataField="NAME"     HeaderText="方案名称"/>     
                        <asp:BoundField DataField="BEGINTIME"      HeaderText="起始月" DataFormatString="{0:yyyy-MM}" HtmlEncode="False"/>       
                        <asp:BoundField DataField="ENDTIME"        HeaderText="终止月" DataFormatString="{0:yyyy-MM}" HtmlEncode="False"/>  
                        <asp:BoundField DataField="REMARK"         HeaderText="方案描述"/>       
                    </Columns>      
                   <EmptyDataTemplate>
                   <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                     <tr class="tabbt">
                       <td>方案名称</td>
                       <td>起始月</td>
                       <td>终止月</td>
                       <td>方案描述</td>
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

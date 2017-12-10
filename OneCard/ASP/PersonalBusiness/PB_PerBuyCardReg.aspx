<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PB_PerBuyCardReg.aspx.cs" Inherits="ASP_PersonalBusiness_PB_PerBuyCardReg" EnableEventValidation="false"%>
<%@ Register Src="../../CardReader.ascx" TagName="CardReader" TagPrefix="cr" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
<title>个人购卡登记</title>
        <%--<link rel="stylesheet" type="text/css" href="../../css/frame.css" />--%>
         <script type="text/javascript" src="../../js/print.js"></script>
         <link href="../../css/card.css" rel="stylesheet" type="text/css" />

     </head>
<body>
	<cr:CardReader id="cardReader" Runat="server"/>    

    <form id="form1" runat="server">
<div class="tb">
个人业务->个人购卡登记
</div>
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

<asp:BulletedList ID="bulMsgShow" runat="server">
</asp:BulletedList>
<script runat="server" >public override void ErrorMsgShow(){ErrorMsgHelper(bulMsgShow);}</script>  
  <div class="con">
  <div class="card">查询</div>
  <div class="kuang5">
  <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
  <tr>
    <td><div align="right">姓名:</div></td>
    <td><asp:TextBox ID="txtActername" CssClass="input" maxlength="25" runat="server"></asp:TextBox></td>
    <td><div align="right">证件类型:</div></td>
    <td><asp:DropDownList ID="selActerPapertype" CssClass="input" runat="server"></asp:DropDownList></td>
    <td><div align="right">证件号码:</div></td>
    <td><asp:TextBox ID="txtActerPaperno" CssClass="input" maxlength="20" runat="server"></asp:TextBox></td>
    <td><asp:Button ID="Button1" runat="server" Text="查询" CssClass="button1" OnClick="btnQuery_Click" /></td>
    <td></td>
  </tr>
  </table>
  </div>
  <div class="jieguo">登记信息</div>
          <div class="kuang5">
            <div id="gdtb" style=" height:200px;">
            
            
              <asp:GridView ID="gvResult" runat="server"
                    CssClass="tab1"
                    Width ="200%"
                    HeaderStyle-CssClass="tabbt"
                    AlternatingRowStyle-CssClass="tabjg"
                    SelectedRowStyle-CssClass="tabsel"
                    AllowPaging="True"
                    PageSize="20"
                    PagerSettings-Mode="NumericFirstLast"
                    PagerStyle-HorizontalAlign="Left"
                    PagerStyle-VerticalAlign="Top"
                    AutoGenerateColumns="False"
                    OnPageIndexChanging="gvResult_Page"
                    OnRowDataBound="gvResult_RowDataBound"
                    OnSelectedIndexChanged="gvResult_SelectedIndexChanged"
                    OnRowCreated="gvResult_RowCreated">
                    <Columns>
                          <asp:BoundField DataField="ID"      HeaderText="ID"/>        
                          <asp:BoundField DataField="NAME"   HeaderText="姓名"/>
                          <asp:BoundField DataField="BIRTHDAY"   HeaderText="出生日期"/>             
                          <asp:BoundField DataField="PAPERTYPE"    HeaderText="证件类型"/>             
                          <asp:BoundField DataField="PAPERNO"    HeaderText="证件号码"/> 
                          <asp:BoundField DataField="SEX"    HeaderText="性别"/>            
                          <asp:BoundField DataField="PHONENO"     HeaderText="联系电话"/>                 
                          <asp:BoundField DataField="ADDRESS"   HeaderText="联系地址"/> 
                          <asp:BoundField DataField="EMAIL"  HeaderText="电子邮件"/>
                          <asp:BoundField DataField="STARTCARDNO"           HeaderText="起始卡号"/>
                          <asp:BoundField DataField="ENDCARDNO"           HeaderText="结束卡号"/>
                          <asp:BoundField DataField="BUYCARDDATE"           HeaderText="购卡日期"/>
                          <asp:BoundField DataField="BUYCARDNUM"           HeaderText="购卡数量"/>
                          <asp:BoundField DataField="BUYCARDMONEY"           HeaderText="购卡金额"/>
                          <asp:BoundField DataField="CHARGEMONEY"           HeaderText="充值金额"/>
                          <asp:BoundField DataField="REMARK"           HeaderText="备注"/>
                   </Columns>   
                   
                   <EmptyDataTemplate>
                      <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                         <tr class="tabbt">
                              <td>姓名</td>
                              <td>出生日期</td>
                              <td>证件类型</td>
                              <td>证件号码</td>
                              <td>性别</td>
                              <td>联系电话</td>
                              <td>联系地址</td>
                              <td>电子邮件</td>
                              <td>起始卡号</td>
                              <td>结束卡号</td>
                              <td>购卡日期</td>
                              <td>购卡数量</td>
                              <td>购卡金额</td>
                              <td>充值金额</td>
                              <td>备注</td>
                           </tr>
                      </table>
                   </EmptyDataTemplate>
                  </asp:GridView>
            
            </div>
          </div>
  <div class="pip">个人购卡登记</div>
  <div class="kuang5">
 <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
  <tr>
    <asp:HiddenField runat="server" ID="hiddenID" />
    <td><div align="right">姓 名:</div></td>
    <td><asp:TextBox ID="txtCusname" CssClass="input" maxlength="25" runat="server"></asp:TextBox></td>
    <td><div align="right">出生日期:</div></td>
    <td><asp:TextBox ID="txtCustbirth" CssClass="input" runat="server" maxlength="8"/>
    <ajaxToolkit:CalendarExtender ID="FCalendar" runat="server" TargetControlID="txtCustbirth" Format="yyyy-MM-dd" /></td>
    <td ><div align="right">证件类型:</div></td>
    <td><asp:DropDownList ID="selPapertype" CssClass="input" runat="server"></asp:DropDownList></td>
    <td><div align="right">证件号码:</div></td>
    <td><asp:TextBox ID="txtCustpaperno" CssClass="input" maxlength="20" runat="server" AutoPostBack="true" OnTextChanged="queryCustinfo"></asp:TextBox></td>
    <asp:HiddenField runat="server" ID="hiddenPapertype" />
    <asp:HiddenField runat="server" ID="hiddenpaperno" />
    </tr>
  <tr>
    <td><div align="right">性 别:</div></td>
    <td><asp:DropDownList ID="selCustsex" CssClass="input" runat="server"></asp:DropDownList></td>
    <td><div align="right">联系电话:</div></td>
    <td><asp:TextBox ID="txtCustphone" CssClass="input" maxlength="20" runat="server"></asp:TextBox></td>
    <td><div align="right">联系地址:</div></td>
    <td colspan="3"><asp:TextBox ID="txtCustaddr" CssClass="inputlong" maxlength="100" runat="server"></asp:TextBox></td>
    </tr>
  
  
  <tr>
    <td><div align="right">电子邮件:</div></td>
    <td><asp:TextBox ID="txtEmail" CssClass="input" maxlength="40" runat="server"></asp:TextBox></td>
    <td><div align="right">购卡日期:</div></td>
    <td><asp:TextBox ID="txtBuyCardDate" CssClass="input" runat="server" maxlength="8"/>
    <ajaxToolkit:CalendarExtender ID="BuyCalendar" runat="server" TargetControlID="txtBuyCardDate" Format="yyyy-MM-dd" /></td>
    <td><div align="right">起始卡号:</div></td>
    <td><asp:TextBox ID="txtStartCardNo" CssClass="input" MaxLength="16" runat="server"></asp:TextBox></td>
    <td><div align="right">结束卡号:</div></td>
    <td><asp:TextBox ID="txtEndCardNo" CssClass="input" MaxLength="16" runat="server"></asp:TextBox></td>
  </tr>
  <tr>
    <td><div align="right">购卡数量:</div></td>
    <td><asp:TextBox ID="txtBuyCardNum" CssClass="input" maxlength="7" runat="server"></asp:TextBox></td>
    <td><div align="right">购卡金额:</div></td>
    <td><asp:TextBox ID="txtBuyCardMoney" CssClass="input" maxlength="7" runat="server"></asp:TextBox></td>
    <td><div align="right">充值金额:</div></td>
    <td><asp:TextBox ID="txtChargeMoney" CssClass="input" maxlength="7" runat="server"></asp:TextBox></td>
    <td><div align="right">充值来源:</div></td>
    <td>
     <asp:DropDownList ID="selChargeSource" runat="server">
                                <asp:ListItem Value="">--请选择--</asp:ListItem>
                                <asp:ListItem Value="利金卡">利金卡</asp:ListItem>
                                <asp:ListItem Value="充值卡">充值卡</asp:ListItem>
                                <asp:ListItem Value="企服卡">企服卡</asp:ListItem>
                                <asp:ListItem Value="其他">其他</asp:ListItem>
                                </asp:DropDownList>
    </td>
    </tr>
    <tr>
    <td></td>
    <td colspan="3"></td>
    <td></td>
    <td><asp:Button ID="txtReadPaper" Text="读二代证" CssClass="button1"  runat="server" 
    OnClientClick="readIDCardEx('txtCusname', 'selCustsex', 'txtCustbirth', 'selPapertype', 'txtCustpaperno', 'txtCustaddr')" /></td>
    <td colspan="2">
    <asp:Button ID="btnComBuyCardReg"  Text="购卡登记" CssClass="button1" runat="server" OnClick="btnBuyCardReg_Click" />
    <asp:Button ID="btnRegModify"  Text="修 改" CssClass="button1" runat="server" Enabled=false OnClick="btnRegModify_Click" />
    <asp:Button ID="btnRegDelete"  Text="删 除" CssClass="button1" runat="server" Enabled=false OnClick="btnRegDelete_Click" />
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

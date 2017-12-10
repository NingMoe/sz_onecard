<%@ Page Language="C#" AutoEventWireup="true" CodeFile="CC_ActivateDirectSale.aspx.cs" EnableEventValidation="false" Inherits="ASP_ChargeCard_CC_ActivateDirectSale" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
    <title>激活-直销</title>

    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    
    <script type="text/javascript" src="../../js/printorder.js"></script>
    <script type="text/javascript" src="../../js/myext.js"></script>
    
    <script type="text/javascript" src="../../js/jquery-1.5.min.js"></script>
    <script type="text/javascript" src="../../js/Window.js"></script>

</head>
<body>
    <form id="form1" runat="server">
<div class="tb">
激活-直销
</div>
        <ajaxToolkit:ToolkitScriptManager EnableScriptGlobalization="true" EnableScriptLocalization="true" ID="ScriptManager1" runat="server"/>
        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
            <ContentTemplate>

    <asp:BulletedList ID="bulMsgShow" runat="server"/>
    <script runat="server" >public override void ErrorMsgShow(){ErrorMsgHelper(bulMsgShow);}</script>
<div class="con">
  <div class="base">订单中未激活直销的充值卡列表</div>
  <div class="kuang5">
      <div  style="height: 200px; overflow: auto; display: block">
      <asp:GridView ID="gvOrderList" 
                 CssClass="tab1"
                 HeaderStyle-CssClass="tabbt" 
                 FooterStyle-CssClass="tabcon"
                 AlternatingRowStyle-CssClass="tabjg"
                 SelectedRowStyle-CssClass="tabsel"
                 PagerSettings-Mode="NumericFirstLast"
                 PagerStyle-HorizontalAlign="left"
                 PagerStyle-VerticalAlign="Top"
                 runat="server" 
                 AutoGenerateColumns="false"
                 Width="100%" OnDataBound="gvOrderList_DataBound">
                 <Columns>
                 <asp:TemplateField>
                                    <HeaderTemplate>
                                        <asp:CheckBox ID="CheckBox1" runat="server" AutoPostBack="true" OnCheckedChanged="CheckAll" />
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                        <asp:CheckBox ID="ItemCheckBox" runat="server" />
                                    </ItemTemplate>
                                </asp:TemplateField>
                        <asp:BoundField DataField="ValidResult" HeaderText="校验" />       
                        <asp:BoundField DataField="ORDERNO" HeaderText="订单号" />
                        <asp:BoundField DataField="FROMCARDNO" HeaderText="起始卡号" />
                        <asp:BoundField DataField="TOCARDNO" HeaderText="结束卡号" />
                        <asp:BoundField DataField="VALUE" HeaderText="面额" />
                        <asp:BoundField DataField="COUNT" HeaderText="购卡数量" />
                        <asp:BoundField DataField="SUM" HeaderText="总金额" />
                        <asp:BoundField DataField="groupname" HeaderText="客户名称" />
                        <asp:BoundField DataField="TRANSACTOR" HeaderText="经办人" />
                        <asp:BoundField DataField="INPUTTIME" HeaderText="录入时间" />
                 </Columns>
                 <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                        <td>
                                            <input type="checkbox" />
                                        </td>
                                        <td>
                                            订单号
                                        </td>
                                        <td>
                                            起始卡号
                                        </td>
                                        <td>
                                            结束卡号
                                        </td>
                                        <td>
                                            面额
                                        </td>
                                        <td>
                                            购卡数量
                                        </td>
                                        <td>
                                            总金额
                                        </td>
                                        <td>
                                            客户名称
                                        </td>
                                        <td>
                                            经办人
                                        </td>
                                        <td>
                                            录入时间
                                        </td>
                                    </tr>
                                </table>
                            </EmptyDataTemplate>
       </asp:GridView>
 </div>
 </div>
</div>
<div class="con">
  <div class="base">直销</div>
  <div class="kuang5">
    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
      <tr>
        <td width="10%" align="right">付款方式:</td>
        <td width="20%">
                <asp:DropDownList CssClass="input" AutoPostBack="true" runat="server" ID="selPayMode" OnSelectedIndexChanged="selPayMode_SelectedIndexChanged">
                    <asp:ListItem Value="" Text="---请选择---"></asp:ListItem>
                    <asp:ListItem Value="1" Text="1:现金方式"></asp:ListItem>
                    <asp:ListItem Value="0" Text="0:转账方式"></asp:ListItem>
                    <asp:ListItem Value="2" Text="2:报销方式"></asp:ListItem>
                </asp:DropDownList>
                    
                <span class="red">*</span>

        </td>
        <td width="10%" align="right">到帐标记:</td>
        <td width="20%">
                <asp:DropDownList CssClass="input" Enabled="false" AutoPostBack="true" runat="server" ID="selRecvTag" OnSelectedIndexChanged="selPayMode_SelectedIndexChanged">
                    <asp:ListItem Value="" Text="---请选择---"></asp:ListItem>
                    <asp:ListItem Value="1" Text="1:已到帐"></asp:ListItem>
                    <asp:ListItem Value="0" Text="0:未到帐"></asp:ListItem>
                </asp:DropDownList>
                <span class="red">*</span>

        </td>
        </td>
      </tr>
      <tr>
        <td width="10%" align="right">到帐日期:</td>
        <td colspan="3"><asp:TextBox Enabled="false" runat="server" ID="txtAccRecvDate" CssClass="input"></asp:TextBox>
     <span class="red">*</span>(“转账或报销方式，已到帐”时必需)
      <ajaxToolkit:CalendarExtender ID="FCalendar" runat="server" TargetControlID="txtAccRecvDate"
            Format="yyyyMMdd" />
      </tr>
      <tr>
        <td width="10%" align="right">备注:</td>
        <td colspan="4"><asp:TextBox runat="server" ID="txtRemark" CssClass="inputmax" MaxLength="200"></asp:TextBox></td>
      </tr>

    </table>
  </div>
  </div>
  <div class="btns">
    &nbsp;<table width="95%" border="0"cellpadding="0" cellspacing="0">
  <tr>
    <td width="70%">&nbsp;<br />
&nbsp;&nbsp;&nbsp; &nbsp;</td>
    <td align="right">&nbsp;</td>
    <td align="right">&nbsp;</td>
    <td align="right"><asp:Button ID="btnSubmit" Enabled="true" CssClass="button1" runat="server" Text="激活-直销" OnClick="btnSubmit_OnClick"/></td>
  </tr>
</table>

</div>
            </ContentTemplate>         
        </asp:UpdatePanel>

    </form>
</body>
</html>

<%@ Page Language="C#" AutoEventWireup="true" CodeFile="GC_Open.aspx.cs" Inherits="ASP_GroupCard_GC_Open" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
    <title>企服卡批量开卡</title>

    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />   
</head>
<body>
    <form id="form1" runat="server">
<div class="tb">
企服卡->批量开卡
</div>
        <ajaxToolkit:ToolkitScriptManager EnableScriptGlobalization="true" EnableScriptLocalization="true" ID="ScriptManager1" runat="server"/>
        <asp:UpdatePanel ID="UpdatePanel1" UpdateMode="Conditional" runat="server">
            <ContentTemplate>

    <asp:BulletedList ID="bulMsgShow" runat="server"/>
    <script runat="server" >public override void ErrorMsgShow(){ErrorMsgHelper(bulMsgShow);}</script>
<div class="con">
  <div class="base">批量开卡</div>
  <div class="kuang5">
 <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
  <tr>
    <td><div align="right">导入文件:</div></td>
    <td>
    <asp:FileUpload ID="FileUpload1" runat="server" CssClass="inputlong" />
    <asp:Button ID="btnUpload" CssClass="button1" runat="server" Text="导入" OnClick="btnUpload_Click"/>
    </td>
    <td><div align="right">集团客户:</div></td>
    <td><asp:DropDownList ID="selCorp" CssClass="inputmidder" runat="server">
                                    </asp:DropDownList>
    </td>
    <td>
        <asp:CheckBox ID="chkOldFlag" runat="server"  Text="旧卡开卡" />
    
    </td>
  </tr>
</table>

 </div>
  <div class="jieguo">客户信息</div>
  <div class="kuang5">
  <asp:HiddenField ID="hiddenSMKCount" runat="server" />
<div class="gdtb" style="height:310px">
         <asp:GridView ID="gvResult" runat="server"
        Width = "98%"
        CssClass="tab1"
        HeaderStyle-CssClass="tabbt"
        AlternatingRowStyle-CssClass="tabjg"
        SelectedRowStyle-CssClass="tabsel"
        AllowPaging="false"
        PagerSettings-Mode="NumericFirstLast"
        PagerStyle-HorizontalAlign=left
        PagerStyle-VerticalAlign=Top
        AutoGenerateColumns="False"
        OnRowDataBound="gvResult_RowDataBound">
           <Columns>
                <asp:BoundField HeaderText="校验结果" DataField="ValidRet"/>
               <asp:BoundField HeaderText="卡号" DataField="CardNo"/>
                <asp:BoundField HeaderText="姓名" DataField="CustName"/>
                <asp:BoundField HeaderText="性别" DataField="CustSex"/>
                <asp:BoundField HeaderText="出生日期" DataField="CustBirth"/>
                <asp:BoundField HeaderText="证件类型" DataField="PaperType"/>
                <asp:BoundField HeaderText="证件号码" DataField="PaperNo"/>
                <asp:BoundField HeaderText="联系地址" DataField="CustAddr"/>
                <asp:BoundField HeaderText="邮政编码" DataField="CustPost"/>
                <asp:BoundField HeaderText="电话号码" DataField="CustPhone"/>
                <asp:BoundField HeaderText="电子邮件" DataField="CustEmail"/>
           </Columns>           
            <EmptyDataTemplate>
                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                  <tr class="tabbt">
                    <td>校验结果</td>
                    <td>卡号</td>
                    <td>姓名</td>
                    <td>性别</td>
                    <td>出生日期</td>
                    <td>证件类型</td>
                    <td>证件号码</td>
                    <td>联系地址</td>
                    <td>邮政编码</td>
                    <td>电话号码</td>
                    <td>电子邮件</td>
                  </tr>
                  </table>
            </EmptyDataTemplate>
        </asp:GridView>
  </div>
  </div>
</div>
<div class="btns">
     <table width="95%" border="0"cellpadding="0" cellspacing="0">
  <tr>
    <td width="70%">&nbsp;</td>
    <td align="right"><asp:Button ID="btnSubmit" Enabled="false" CssClass="button1" runat="server" Text="提交" OnClick="btnSubmit_Click"/></td>
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

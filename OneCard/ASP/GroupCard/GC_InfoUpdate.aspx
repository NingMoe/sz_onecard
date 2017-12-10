<%@ Page Language="C#" AutoEventWireup="true" CodeFile="GC_InfoUpdate.aspx.cs" Inherits="ASP_GroupCard_GC_InfoUpdate" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
    <title>企服卡资料更新</title>

    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    
    <script language="javascript">
        
    </script>
    
</head>
<body>
    <form id="form1" runat="server">
<div class="tb">
企服卡->资料更新
</div>
        <ajaxToolkit:ToolkitScriptManager EnableScriptGlobalization="true" EnableScriptLocalization="true" ID="ScriptManager1" runat="server"/>
        <asp:UpdatePanel ID="UpdatePanel1" UpdateMode="Conditional" runat="server">
            <ContentTemplate>

    <asp:BulletedList ID="bulMsgShow" runat="server"/>
    <script runat="server" >public override void ErrorMsgShow(){ErrorMsgHelper(bulMsgShow);}</script>

<div class="con">
  <div class="base">资料更新</div>
  <div class="kuang5">
 <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
  <tr>
    <td width="10%" ><div align="right">导入文件:</div></td>
    <td width="50%">
    <asp:FileUpload ID="FileUpload1" runat="server" CssClass="inputlong" />
    <asp:Button ID="btnUpload" CssClass="button1" runat="server" Text="导入" OnClick="btnUpload_Click"/>
    </td>
    <td width="10%"><div align="right">&nbsp;</div></td>
    <td >&nbsp;
    </td>
    <td width="17%" >
        &nbsp;
    
    </td>
  </tr>
</table>

 </div>
  <div class="jieguo">更新信息</div>
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
        PagerSettings-Mode=NumericFirstLast
        PagerStyle-HorizontalAlign=left
        PagerStyle-VerticalAlign=Top
        AutoGenerateColumns="False"
        OnRowDataBound="gvResult_RowDataBound">
           <Columns>
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

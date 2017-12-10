<%@ Page Language="C#" AutoEventWireup="true" CodeFile="IT_Volumn.aspx.cs" Inherits="ASP_InvoiceTrade_IT_Volumn" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
	<link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
        <title>发票代码</title>
</head>
<body>
    <form id="form1" runat="server">
    
        <div class="tb">发票 -> 发票代码</div>

        <ajaxToolkit:ToolkitScriptManager runat="Server" EnableScriptGlobalization="true"
            EnableScriptLocalization="true" ID="ScriptManager2" />
        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
            <ContentTemplate>
    <asp:BulletedList  ID="bulMsgShow" runat="server"/>
    <script runat="server" >public override void ErrorMsgShow(){ErrorMsgHelper(bulMsgShow);}</script>
           
            <div class="con">
                <div class="pip">发票代码</div>
                <div class="kuang5">
                   <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                     <tr>
                       <td width="12%"><div align="right">部门名称:</div></td>
                       <td width="61%">
                            <asp:Label ID="labDept" runat="server"></asp:Label>
                       </td>
                      </tr>
                      <tr>
                       <td><div align="right">发票代码:</div></td>
                       <td>
                            <asp:TextBox ID="txtVolumn" CssClass="inputmid" MaxLength="12" runat="server"></asp:TextBox>
                        </td>
                      </tr>
                      <tr>
                       <td><div align="right">更新员工:</div></td>
                       <td>
                            <asp:Label ID="labUpdateStaff" runat="server"></asp:Label>
                        </td>
                      </tr>                      <tr>
                       <td><div align="right">更新时间:</div></td>
                       <td>
                            <asp:Label ID="labUpdateTime" runat="server"></asp:Label>
                        </td>
                      </tr>
                   </table>
                </div>
            </div>
            
            <div class="btns">
              <table width="100" border="0" align="right" cellpadding="0" cellspacing="0">
                <tr>
                  <td>
                    <asp:Button ID="btnSubmit" CssClass="button1" runat="server" Text="提交" 
                          onclick="btnSubmit_Click"/>
                  </td>

                </tr>
              </table>
              <label></label>
              <label></label>
            </div>
            
            
            </ContentTemplate>
        </asp:UpdatePanel>
        
    </form>
</body>
</html>

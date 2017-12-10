<%@ Page Language="C#" AutoEventWireup="true" CodeFile="TS_ChangeCardInfo.aspx.cs" Inherits="ASP_TaxiService_TS_ChangeCardInfo" %>
<%@ Register Src="../../CardReader.ascx" TagName="CardReader" TagPrefix="cr" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <title>卡片信息修改</title>
	<link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
 
</head>
<body>
	<cr:CardReader id="cardReader" Runat="server"/>    

    <form id="form1" runat="server">
     <div class="tb">司机卡->卡片信息修改</div>
     
      <ajaxToolkit:ToolkitScriptManager runat="Server" EnableScriptGlobalization="true"
            EnableScriptLocalization="true" ID="ScriptManager2" />
       <asp:UpdatePanel ID="UpdatePanel1" runat="server">
         <ContentTemplate>
         <asp:BulletedList ID="bulMsgShow" runat="server"/>
         <script runat="server" >public override void ErrorMsgShow(){ErrorMsgHelper(bulMsgShow);}</script> 
     
         <div class="con">
          <div class="card">卡片信息修改</div>
          <div class="kuang5">
            <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
              <tr>
                <td colspan="8" class="red">请在相应栏中填入司机信息，点击写卡保存。注意卡内信息正确性！</td>
              </tr>
              <tr>
                <td><div align="right">司机工号:</div></td>
                <td>
                    <asp:TextBox ID="txtTaxiDriverNo" runat="server" CssClass="input" MaxLength="6" >
                    </asp:TextBox>
                </td>
                <td><div align="right">卡号:</div></td>
                <td> 
                    
                    <asp:TextBox ID="txtCardNo" CssClass="labeltext" runat="server" MaxLength="16" ></asp:TextBox>
                    
                </td>
                <td><div align="right">车号:</div></td>
                <td>
                   <asp:TextBox ID="txtCarNo" runat="server" CssClass="input" MaxLength="5" >
                   </asp:TextBox>
                   
                </td>
                <td><div align="right">初始状态:</div></td>
                <td>
                   <asp:DropDownList runat="server" CssClass="input" ID="selInitState">
                   </asp:DropDownList>
                </td>
              </tr>
            </table>
            
            <div class="btns">
              <table width="200" border="0" align="right" cellpadding="0" cellspacing="0">
               <tr>
                <td>
                   <asp:Button ID="btnReadCard" runat="server" Text="读卡" CssClass="button1"  
                    OnClientClick="return readDriverInfo('txtTaxiDriverNo', 'txtCardNo', 'txtCarNo', 'selInitState')"/>
                
                   <asp:HiddenField ID="hidCardNo" runat="server" /> 
                   <asp:HiddenField ID="hidStaffNo" runat="server" />
                   <asp:HiddenField ID="hidState" runat="server" />
                   <asp:HiddenField ID="hidCarNo" runat="server" />
                   <asp:HiddenField runat="server" ID="hidCardReaderToken" /> 
                   
                </td>
               
                <td><asp:Button ID="btnWriteCard" runat="server" Text="写卡" CssClass="button1" 
                    OnClick="btnWriteCard_Click" />
                    <asp:HiddenField runat="server" ID="hidWarning" />
                     <asp:LinkButton runat="server" ID="btnConfirm" OnClick="btnConfirm_Click"/>
                       </td>
               </tr>
             </table>
           </div>
          </div>
        </div>
   
        <div class="con">
          <div class="card">卡片销毁与重启用</div>
          <div class="kuang5">
            <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
              <tr>
                <td width = "9%"><div align="right">司机工号:</div></td>
                <td  width = "18%" >
                    <asp:TextBox ID="txtTaxiDriverNoExt" runat="server" CssClass="labeltext" MaxLength="6" >
                    </asp:TextBox>
                </td>
                <td><div align="right">卡号:</div></td>
                <td width = "15%" > 
                    <asp:TextBox ID="txtCardNoExt" CssClass="labeltext" runat="server" MaxLength="16" ></asp:TextBox> 
                </td>
               
                <td><div align="right">启用状态:</div></td>
                <td width = "43%">
                   <asp:DropDownList runat="server" CssClass="input" ID="selUseState">
                   </asp:DropDownList>
                </td>

              </tr>
            </table>
            
            <div class="btns">
              <table width="200" border="0" align="right" cellpadding="0" cellspacing="0">
               <tr>
                <td>
                   <asp:Button ID="Button1" runat="server" Text="读卡" CssClass="button1"  
                    OnClientClick="return readDriverInfo('txtTaxiDriverNoExt', 'txtCardNoExt', 'hidCarNoExt', null, 'selUseState')"/>
                
                   <asp:HiddenField ID="hidCarNoExt" runat="server" /> 
                   <asp:HiddenField ID="hidStaffNoExt" runat="server" />
                   <asp:HiddenField ID="hidUseStateExt" runat="server" />
                </td>
               
                <td><asp:Button ID="Button2" runat="server" Text="写卡" CssClass="button1" OnClick="btnWriteCardExt_Click" />
                      
                </td>
               </tr>
             </table>
           </div>
          </div>
        </div>
        
    
         </ContentTemplate>
      </asp:UpdatePanel>
    
    </form>
</body>
</html>

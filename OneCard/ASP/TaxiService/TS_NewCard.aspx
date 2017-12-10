<%@ Page Language="C#" AutoEventWireup="true" CodeFile="TS_NewCard.aspx.cs" Inherits="ASP_TaxiService_TS_NewCard" %>
<%@ Register Src="../../CardReader.ascx" TagName="CardReader" TagPrefix="cr" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
    <title>开卡</title>

     
	<link rel="stylesheet" type="text/css" href="../../css/frame.css" />     
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    
</head>
<body>
	<cr:CardReader id="cardReader" Runat="server"/>    

    <form id="form1" runat="server">

    <div class="tb">司机卡->开卡</div>
   <ajaxToolkit:ToolkitScriptManager runat="Server" EnableScriptGlobalization="true"
            EnableScriptLocalization="true" ID="ScriptManager2" />
        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
         <ContentTemplate>
         <asp:BulletedList ID="bulMsgShow" runat="server"/>
         <script runat="server" >public override void ErrorMsgShow(){ErrorMsgHelper(bulMsgShow);}</script>  
         
         <div class="con">
          <div class="card">卡片信息</div>
          <div class="kuang5">
         <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text20">
          <tr>
            <td width="8%"><div align="right">卡号:</div></td>
            <td width="20%">
             <asp:TextBox ID="txtCardNo" CssClass="labeltext" runat="server" MaxLength="16" ></asp:TextBox>
            </td>
            <td>
               <asp:Button ID="btnReadCard" runat="server" CssClass="button1" Text="读卡"
                OnClientClick="return readDriverInfoEx('inStaffno', 'txtCardNo', 'inTaxiNo', 'selInState', 'selUseState')" 
                 OnClick="btnReadCard_Click"/>
            </td>

            <td colspan = "5">
                <asp:HiddenField runat="server" ID="hidCardReaderToken" />  
            
              <asp:HiddenField runat="server" ID="hidForPaperNo" />
              <asp:HiddenField runat="server" ID="hidForPhone" />
              <asp:HiddenField runat="server" ID="hidForAddr" />
            </td>
            
            </tr>
             <tr>
              
              <td width="8%"><div align="right">工号:</div></td>
              <td width="8%"><asp:TextBox ID="inStaffno" CssClass="labeltext" runat="server"></asp:TextBox></td>
              <td width="8%"><div align="right">车号:</div></td>
              <td width="8%"><asp:TextBox ID="inTaxiNo" CssClass="labeltext" runat="server"></asp:TextBox></td>
              <td width="10%"><div align="left">初始状态:</div></td>
              <td width="20%"><asp:DropDownList runat="server" CssClass="input" ID="selInState" Enabled="false"/>
              </td>
              <td width="10%"><div align="left">启用标志:</div></td>
              <td width="30%">
              <asp:DropDownList runat="server" CssClass="input" ID="selUseState" Enabled="false"/>             
              </td>
             
            </tr>
        </table>
        
         </div>

           <div class="pip">司机卡信息</div>
         <div class="kuang5">
         <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
          <tr>
            <td><div align="right">司机工号:</div></td>
            <td>
                <asp:TextBox runat="server" CssClass="inputmid" MaxLength="6" ID="txtDriverStaffNo"></asp:TextBox>
                <span class="red"> * </span>
                <asp:HiddenField ID="hidStaffNo" runat="server" /></td>
            <td><div align="right">司机工号确认:</div></td>
            <td><asp:TextBox runat="server" CssClass="inputmid" MaxLength="6" ID="txtDriverStaffNoConfirm"></asp:TextBox>
              <span class="red"> * </span></td>
            <td><div align="right">车号:</div></td>
            <td><asp:TextBox runat="server" CssClass="inputmid" MaxLength="5" ID="txtCarNo"></asp:TextBox>
              <span class="red"> * </span>
              <asp:HiddenField ID="hidCarNo" runat="server" />
            </td>
          </tr>
          <tr>
            <td><div align="right">开户银行:</div></td>
            <td>
            <asp:TextBox ID="txtBank" CssClass="inputmid" runat="server" AutoPostBack="true"
                                    OnTextChanged="txtBank_Changed"></asp:TextBox>
            <asp:DropDownList runat="server" CssClass="inputmidder" ID="selHouseBank"></asp:DropDownList>
              <span class="red"> * </span></td>
            <td><div align="right">银行帐号:</div></td>
            <td><asp:TextBox runat="server" CssClass="inputmid" MaxLength="30" ID="txtBankAccount"></asp:TextBox>
              <span class="red"> * </span></td>
            <td><div align="right">银行帐号确认:</div></td>
            <td><asp:TextBox runat="server" CssClass="inputmid" MaxLength="30" ID="txtBankAccountConfirm"></asp:TextBox>
              <span class="red"> * </span></td>
          </tr>
          <tr>
            <td><div align="right">司机姓名:</div></td>
            <td><asp:TextBox runat="server" CssClass="inputmid" MaxLength="20" ID="txtStaffName"></asp:TextBox>
              <span class="red"> * </span></td>
            <td><div align="right">司机性别:</div></td>
            <td><asp:DropDownList runat="server" CssClass="inputmid" ID="selStaffSex"></asp:DropDownList>
            </td>
            <td><div align="right">联系电话:</div></td>
            <td><asp:TextBox runat="server" CssClass="inputmid" MaxLength="20" ID="txtContactPhone"></asp:TextBox>
              <span class="red"> * </span></td>
          </tr>
          <tr>
            <td><div align="right">车载电话:</div></td>
            <td><asp:TextBox runat="server" CssClass="inputmid" MaxLength="15" ID="txtCarPhone"></asp:TextBox>
              <span class="red"> * </span></td>
            <td><div align="right">证件类型:</div></td>
            <td><asp:DropDownList runat="server" CssClass="inputmid" ID="selPaperType"></asp:DropDownList>
              <span class="red"> * </span></td>
            <td><div align="right">证件号码:</div></td>
            <td><asp:TextBox runat="server" CssClass="inputmid" MaxLength="20" ID="txtPaperNo"></asp:TextBox>
              <span class="red"> * </span></td>
          </tr>
          <tr>
            <td><div align="right">单位名称:</div></td>
            <td><asp:DropDownList runat="server" CssClass="inputmider" ID="selUnitName"
                    AutoPostBack="true" OnSelectedIndexChanged="selUnitName_SelectedIndexChanged"></asp:DropDownList>
              <span class="red">* </span></td>
            <td><div align="right">部门名称:</div></td>
            <td><asp:DropDownList runat="server" CssClass="inputmid" ID="selDeptName"></asp:DropDownList>
            </td>
            <td><div align="right">POS编号:</div></td>
            <td><asp:TextBox runat="server" CssClass="inputmid" MaxLength="6" ID="txtPosID"></asp:TextBox>
            </td>
          </tr>
          
          <tr>
            <td><div align="right">邮政编码:</div></td>
            <td><asp:TextBox runat="server" CssClass="inputmid" MaxLength="6" ID="txtPostCode"></asp:TextBox>
            <td><div align="right">电子邮件:</div></td>
            <td><asp:TextBox runat="server" CssClass="inputmid" MaxLength="30" ID="txtEmailAddr"></asp:TextBox>
            <td><div align="right">联系地址:</div></td>
            <td><asp:TextBox runat="server" CssClass="inputmid" MaxLength="50" ID="txtContactAddr"></asp:TextBox>
            </td>
          </tr>
          
          <tr>
            <td><div align="right">采集卡号:</div></td>
            <td><asp:TextBox runat="server" CssClass="labeltext" MaxLength="16" ID="txtCollectCardNo"></asp:TextBox>
            </td>
            <td><div align="right">商户经理:</div></td>
            <td>
             <asp:DropDownList runat="server" CssClass="inputmid" ID="selServerMgr"></asp:DropDownList>
             <span class="red"> * </span>
            </td>
            <td><div align="right">初始状态:</div></td>
            <td>
               <asp:DropDownList runat="server" CssClass="inputmid" ID="selState"></asp:DropDownList>
               <asp:HiddenField ID="hidState" runat="server" />
            </td>
          </tr>
          <tr>
            <td><div align="right">收款人账户类型:</div></td>
            <td><asp:DropDownList runat="server" CssClass="inputmid" ID="selPurPoseType"></asp:DropDownList>
              <span class="red"> * </span></td>
            </td>
            <td><div align="right"></div></td>
            <td>&nbsp;
            </td>
            <td><div align="right"></div></td>
            <td>&nbsp;
            </td>
          </tr>
        </table>

         </div>
        </div>
        <div>
          <div class="footall"></div>
        </div>

        <div class="btns">
         <table width="100" border="0" align="right" cellpadding="0" cellspacing="0">
          <tr>
            <td><asp:Button runat="server" ID="btnSubmit" CssClass="button1" Text="提交" OnClick="btnSubmit_Click"/>
            <asp:HiddenField runat="server" ID="hidWarning" />
              <asp:LinkButton runat="server" ID="btnConfirm" OnClick="btnConfirm_Click"/>

            </td>
          </tr>
         </table>

        注:加<span class="red">*</span>为必填项</div>
                    </ContentTemplate>
                </asp:UpdatePanel>
        </form>
     </body>
</html>

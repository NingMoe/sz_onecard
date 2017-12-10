<%@ Page Language="C#" AutoEventWireup="true" CodeFile="TS_ChangeInfo.aspx.cs" Inherits="ASP_TaxiService_TS_ChangeInfo" %>
<%@ Register Src="../../CardReader.ascx" TagName="CardReader" TagPrefix="cr" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <title>信息变更</title>

	<link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />

  
</head>
<body>
    	<cr:CardReader id="cardReader" Runat="server"/>    

    <form id="form1" runat="server">
      <div class="tb">司机卡->信息变更</div>
      
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
            <td width="9%"><div align="right">司机工号:</div></td>
            <td width="10%"><span class="red">
            
              <asp:TextBox ID="txtDriverStaffNo" runat="server" CssClass="input" MaxLength="6" Width = "100px" ></asp:TextBox>
              <asp:HiddenField ID="hidStaffNo" runat="server" /> 
               <asp:HiddenField runat="server" ID="hidCardReaderToken" /> 
            </span></td>
            <td width="12%">
              <asp:Button ID="btnQuery" runat="server" Text="查询" CssClass="button1" OnClick="btnQuery_Click" />
              
              <asp:HiddenField ID="hidQueryFlag" runat="server"  Value="false"/> 
            </td>
            <td>
             
              <asp:Button ID="btnReadCard" runat="server" Text="读卡" CssClass="button1" 
                OnClientClick="return readDriverInfo('txtDriverStaffNo', 'hidCardNo', 'inTaxiNo', 'selInState', 'selUseState')" OnClick="btnReadCard_Click" />

              <asp:HiddenField ID="hidCardNo" runat="server" /> 
              <asp:HiddenField ID="hidCarNo" runat="server" /> 
              
              <asp:HiddenField ID="hidReadCardFlag" runat="server" Value="false"/> 
              
            </td>
          </tr>
          <tr style="height:30px;">
              <td width="8%"><div align="right">车号:</div></td>
              <td><asp:TextBox ID="inTaxiNo" CssClass="labeltext" runat="server"></asp:TextBox></td>
              <td><div align="right">初始状态:</div></td>
              <td><asp:DropDownList runat="server" CssClass="input" ID="selInState" Enabled="false"/>
              </td>
              <td><div align="right">启用标志:</div></td>
              <td><asp:DropDownList runat="server" CssClass="input" ID="selUseState" Enabled="false"/>  
              </td>
              <td></td>
              <td></td>
          </tr>
          
        </table>

         </div>

           <div class="pip">司机卡信息</div>
         <div class="kuang5">
         <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">

          <tr>
            <td><div align="right">IC卡号:</div></td>
            <td>
              <asp:TextBox ID="txtCardNo" runat="server"  CssClass="labeltext" MaxLength="16" ></asp:TextBox>
              <span class="red">*</span>
            </td>
          
            <td> <div align="right">
               <asp:Button ID="btnReadNewCardNo" runat="server" Text="读新卡号" CssClass="button1"
                 OnClientClick="return readCardNo()"  OnClick="btnReadNewCard_Click"/>
               <asp:HiddenField ID="hidReadNewCardNoFlag" runat="server" Value="false" /> 
               <asp:HiddenField ID="hidReadNewCardNo" runat="server" /> 
              </div>
            </td>
            <td>
              <div align="center">
               补办中:<asp:CheckBox ID="chkPatchState" runat="server"  AutoPostBack="true"
                                  OnCheckedChanged="chkPatchState_CheckedChanged"  />  
               </div>
            </td>   
              
            <td><div align="right">车号:</div></td>
            <td><asp:TextBox runat="server" CssClass="inputmid" MaxLength="5" ID="txtCarNo"></asp:TextBox>
                <span class="red"> * </span>
            </td>
          </tr>

          <tr>
            <td><div align="right">开户银行:</div></td>
            <td>
            <asp:TextBox ID="txtBank" CssClass="inputmid" runat="server" AutoPostBack="true"
                                    OnTextChanged="txtBank_Changed"></asp:TextBox>
                <asp:DropDownList runat="server" CssClass="inputmidder" ID="selHouseBank"></asp:DropDownList>    
                <span class="red"> *        </span></td>
            <td><div align="right">银行帐号:</div></td>
            <td>
                <asp:TextBox runat="server" CssClass="inputmid" MaxLength="30" ID="txtBankAccount"></asp:TextBox>
                <span class="red"> * </span></td>
            <td><div align="right">银行帐号确认:</div></td>
            <td>
                <asp:TextBox runat="server" CssClass="inputmid" MaxLength="30" ID="txtBankAccountConfirm"></asp:TextBox>
                <span class="red"> * </span></td>
          </tr>
          <tr>
            <td><div align="right">司机姓名:</div></td>
            <td>
               <asp:TextBox runat="server" CssClass="input" MaxLength="20" ID="txtStaffName"></asp:TextBox>
                <span class="red"> * </span></td>
            <td><div align="right">司机性别:</div></td>
            <td>
                <asp:DropDownList runat="server" CssClass="inputmid" ID="selStaffSex" Width = "153px"></asp:DropDownList>
            </td>
            <td><div align="right">联系电话:</div></td>
            <td>
                <asp:TextBox runat="server" CssClass="inputmid" MaxLength="20" ID="txtContactPhone"></asp:TextBox>
                <span class="red"> * </span></td>
          </tr>
          <tr>
            <td><div align="right">车载电话:</div></td>
            <td>
                <asp:TextBox runat="server" CssClass="input" MaxLength="15" ID="txtCarPhone"></asp:TextBox>
                
                <span class="red"> * </span></td>
            <td><div align="right">证件类型:</div></td>
            <td>
               <asp:DropDownList runat="server" CssClass="inputmid" ID="selPaperType" Width = "153px"></asp:DropDownList>
            
              
                <span class="red"> * </span></td>
            <td><div align="right">证件号码:</div></td>
            <td><asp:TextBox runat="server" CssClass="inputmid" MaxLength="20" ID="txtPaperNo"></asp:TextBox>
                <span class="red"> * </span>
            </td>
          </tr>
          <tr>
            <td><div align="right">单位名称:</div></td>
            <td>
              <asp:DropDownList runat="server" CssClass="inputmider" ID="selUnitName" AutoPostBack="true" 
                       OnSelectedIndexChanged="selUnitName_SelectedIndexChanged"></asp:DropDownList>
                <span class="red">* </span></td>
            <td><div align="right">部门名称:</div></td>
            <td>
              <asp:DropDownList runat="server" CssClass="inputmid" ID="selDeptName" Width = "153px"></asp:DropDownList>
            </td>
            <td><div align="right">POS编号:</div></td>
            <td>
               <asp:TextBox runat="server" CssClass="inputmid" MaxLength="8" ID="txtPosID"></asp:TextBox>
            
            </td>
          </tr>
          <tr>
            <td><div align="right">离职标志:</div></td>
            <td><asp:DropDownList runat="server" CssClass="input" ID="selDimissionTag" Width = "118px"></asp:DropDownList>
            </td>
            <td><div align="right">电子邮件:</div></td>
            <td><asp:TextBox runat="server" CssClass="inputmid" MaxLength="30" ID="txtEmailAddr"></asp:TextBox></td>
            <td><div align="right">联系地址:</div></td>
            <td><asp:TextBox runat="server" CssClass="inputmid" MaxLength="50" ID="txtContactAddr"></asp:TextBox></td>
          </tr>
          <tr>
            <td><div align="right">邮政编码:</div></td>
            <td>
              <asp:TextBox runat="server" CssClass="input" MaxLength="6" ID="txtPostCode"></asp:TextBox>
            </td>
            <td><div align="right">商户经理:</div></td>
            <td>
              <asp:DropDownList runat="server" CssClass="inputmid" ID="selServerMgr" Width = "153px"></asp:DropDownList>
              <span class="red"> * </span>
            
            </td>
            
            <td><div align="right">采集卡号:</div></td>
            <td><asp:TextBox runat="server" CssClass="labeltext" 
                MaxLength="16" ID="txtCollectCardNo"></asp:TextBox></td>
           
          </tr>
          
          <tr>
             <td><div align="right">初始状态:</div></td>
            <td>
              <asp:DropDownList runat="server" CssClass="input" ID="selState" Width = "118px"></asp:DropDownList>
                <asp:HiddenField ID="hidState" runat="server" />
                
             
            </td>
         
            <td><div align="right">更新员工:</div></td>
            <td><asp:TextBox ID="txtUpdStaff" runat="server" ReadOnly="true" CssClass="labeltext" ></asp:TextBox> </td>
            <td><div align="right">更新时间:</div></td>
            <td><asp:TextBox ID="txtUpdTime" runat="server" ReadOnly="true" CssClass="labeltext"></asp:TextBox></td>
          </tr>
          <tr>
             <td><div align="right">收款人账户类型:</div></td>
            <td>
              <asp:DropDownList runat="server" CssClass="input" ID="selPurPoseType" Width = "118px"></asp:DropDownList>
            </td>
         
            <td><div align="right"></div></td>
            <td></td>
            <td><div align="right"></div></td>
            <td></td>
          </tr>
          
        </table>

         </div>
        </div>
        <div>
          <div class="footall"></div>
        </div>

        <div class="btns">
          <table border="0" cellpadding="0" cellspacing="0" align="right">
          <tr>
            <td >
              <asp:Button ID="btnUpdate" runat="server"  Text="更新" CssClass="button1" OnClick="btnUpdate_Click" />
            
            </td>
            <td >
                &nbsp; &nbsp;
                <asp:Button ID="btnSubmit" runat="server" Text="更新&写卡" CssClass="button1" OnClick="btnSubmit_Click" />&nbsp;
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

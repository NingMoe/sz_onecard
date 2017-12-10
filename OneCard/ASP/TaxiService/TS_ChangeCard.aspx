<%@ Page Language="C#" AutoEventWireup="true" CodeFile="TS_ChangeCard.aspx.cs" Inherits="ASP_TaxiService_TS_ChangeCard" %>
<%@ Register Src="../../CardReader.ascx" TagName="CardReader" TagPrefix="cr" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <title>补换卡</title>
	<link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
</head>
<body>
    	<cr:CardReader id="cardReader" Runat="server"/>    

    <form id="form1" runat="server">
     <div class="tb">司机卡->补换卡</div>
    
     <ajaxToolkit:ToolkitScriptManager runat="Server" EnableScriptGlobalization="true"
            EnableScriptLocalization="true" ID="ScriptManager2" />
       <asp:UpdatePanel ID="UpdatePanel1" runat="server">
            <ContentTemplate>
           
            <asp:BulletedList ID="bulMsgShow" runat="server"/>
         <script runat="server" >public override void ErrorMsgShow(){ErrorMsgHelper(bulMsgShow);}</script>
            
            <div class="con">
              <div class="info">司机信息查询</div>
              <div class="kuang5">
              
             <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text20">
              <tr>
                <td width="8%"><div align="right">司机工号:</div></td>
                <td width="22%">
                
                  <asp:TextBox ID="txtDriverStaffNo" runat="server" CssClass="input" MaxLength="6" ></asp:TextBox>
                  <asp:HiddenField ID="hidStaffNo" runat="server" /> 
                </td>
                <td width="12%"><div align="right">
                  <asp:Button ID="btnQueryByStuffNo" runat="server" Text="查询" CssClass="button1" OnClick="btnQueryByStuffNo_Click" />
    
                </div></td>
                <td width="25%"><asp:HiddenField runat="server" ID="hidCardReaderToken" />  </td>
                <td width="11%">&nbsp;</td>
                <td width="18%">&nbsp;</td>
              </tr>
            </table>

             </div>

               <div class="card">旧卡信息</div>
             <div class="kuang5"> 
             <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
              <tr>
                <td width="8%"><div align="right">IC卡号　:</div></td>
                <td width="20%"> <asp:Label ID="labCardNo" runat="server" Text=""></asp:Label></td>
                <td width="8%"><div align="right">车号　　:</div></td>
                <td width="13%"><asp:Label ID="labCarNo" runat="server"></asp:Label>
                 <asp:HiddenField ID="hidCarNo" runat="server" /> 
                </td>
                <td width="12%">&nbsp;</td>
                <td width="29%">&nbsp;</td>
              </tr>
              <tr>
                <td><div align="right">开户银行:</div></td>
                <td>
                   <asp:Label ID="labHouseBank" runat="server"></asp:Label>
                   <asp:HiddenField ID="hidBankCode" runat="server" /> 
                
                </td>
                <td><div align="right">银行账号:</div></td>
                <td><asp:Label ID="labBankAccount" runat="server"></asp:Label>   </td>
                <td><div align="right"></div></td>
                <td>&nbsp;</td>
              </tr>
              <tr>
                <td><div align="right">司机姓名:</div></td>
                <td><asp:Label ID="labStaffName" runat="server"></asp:Label>  </td>
                <td><div align="right">司机性别:</div></td>
                <td><asp:Label ID="labStaffSex" runat="server"></asp:Label></td>
                <td><div align="right">联系电话:</div></td>
                <td><asp:Label ID="labContactPhone" runat="server"></asp:Label></td>
              </tr>
              <tr>
                <td><div align="right">车载电话:</div></td>
                <td><asp:Label ID="labCarPhone" runat="server"></asp:Label>    </td>
                <td><div align="right">证件类型:</div></td>
                <td>
                    <asp:Label ID="labPaperType" runat="server"></asp:Label> 
                    <asp:HiddenField ID="hidPaperTypeNo" runat="server" />  
                </td>
                <td><div align="right">证件号码:</div></td>
                <td><asp:Label ID="labPaperNo" runat="server"></asp:Label>  </td>
              </tr>
              <tr>
                <td><div align="right">单位名称:</div></td>
                <td>
                   <asp:Label ID="labUnitName" runat="server"></asp:Label> 
                   <asp:HiddenField ID="hidCorpNo" runat="server" /> 
                </td>
                <td><div align="right">部门名称:</div></td>
                <td>
                   <asp:Label ID="labDeptName" runat="server"></asp:Label>
                   <asp:HiddenField ID="hidDepartNo" runat="server" /> 
                </td>
                <td><div align="right">POS编号:</div></td>
                <td><asp:Label ID="labPosID" runat="server"></asp:Label> </td>
              </tr>
              <tr>
                <td><div align="right">邮政编码:</div></td>
                <td><asp:Label ID="labPostCode" runat="server"></asp:Label>  </td>
                <td><div align="right">电子邮件:</div></td>
                <td><asp:Label ID="labEmailAddr" runat="server"></asp:Label> </td>
                <td><div align="right">联系地址:</div></td>
                <td><asp:Label ID="labContactAddr" runat="server"></asp:Label>  </td>
              </tr>

              <tr>
                <td><div align="right">采集卡号:</div></td>
                <td><asp:Label ID="labCollectCardNo" runat="server"></asp:Label> </td>
                <td><div align="right">采集卡密码:</div></td>
                <td><asp:Label ID="labCollectCardPass" runat="server"></asp:Label></td>
                <td><div align="right">离职标志:</div></td>
                <td><asp:Label ID="labDimssionTag" runat="server"></asp:Label>  </td>
              </tr>
            </table>
 
            

             </div>
               <div class="card">新卡信息</div>
              <div class="kuang5">
              
             <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text20">
              <tr>
                <td width="8%"><div align="right">IC卡号　:</div></td>
                <td width="18%">
                  <asp:TextBox ID="txtCardNo" CssClass="labeltext" runat="server" MaxLength="16" ></asp:TextBox>
                </td>
                <td width="9%"><div align="left">
                  <asp:Button ID="btnReadCard" runat="server" Text="读卡" CssClass="button1"
                   OnClientClick="return readDriverInfoEx('inStaffno', 'txtCardNo', 'inTaxiNo', 'selInitState', 'selUseState')" 
                   OnClick="btnReadCard_Click" />
                </div></td>
                <td width="20%" >&nbsp;</td>
                <td>&nbsp;</td>
                <td>&nbsp;</td>
              </tr>
              <tr>
                <td width="8%"><div align="right">开户银行:</div></td>
                <td width="10%">
            <asp:TextBox ID="txtBank" CssClass="inputmid" runat="server" AutoPostBack="true"
                                    OnTextChanged="txtBank_Changed"></asp:TextBox>
                  <asp:DropDownList runat="server" CssClass="inputmidder" ID="selHouseBank"></asp:DropDownList><span class="red">*</span>
                </td>
                <td colspan="2" width="20%">银行帐号:
                 <asp:TextBox runat="server" CssClass="inputmid" MaxLength="30" ID="txtBankAccount"></asp:TextBox>
                 <span class="red">*</span>
                </td>
                <td colspan="2" width="30%">银行账号确认:
                 <asp:TextBox runat="server" CssClass="inputmid" MaxLength="30" ID="txtBankAccountConfirm"></asp:TextBox>
                 <span class="red">*</span>
                </td>
              </tr>
              <tr>
                <td><div align="right">初始状态:</div></td>
                <td>
                   <asp:DropDownList runat="server" CssClass="input" ID="selInitState"></asp:DropDownList>
                   <span class="red">*</span>
                   <asp:HiddenField ID="hidState" runat="server" />
                </td>
                <td colspan="5">备注　　:
                 <asp:TextBox ID="txtRemark" runat="server" CssClass="inputlong" MaxLength="100" ></asp:TextBox>
                </td>
              </tr>
              <tr>
                <td><div align="right">司机工号:</div></td>
                <td>
                  <asp:TextBox ID="inStaffno" CssClass="labeltext" runat="server"></asp:TextBox>
                </td>
                <td colspan="2">车号　　:
                  <asp:TextBox ID="inTaxiNo" CssClass="labeltext" runat="server" ></asp:TextBox>
                </td>
                
                <td colspan="2">启用标志:
                <asp:DropDownList runat="server" CssClass="input" ID="selUseState" Enabled="false"/>  
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
                <td><asp:Button ID="btnChangeCard" runat="server" Text="确定" CssClass="button1" OnClick="btnChangeCard_Click" />
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

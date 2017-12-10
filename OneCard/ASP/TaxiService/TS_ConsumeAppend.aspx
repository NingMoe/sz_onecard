<%@ Page Language="C#" AutoEventWireup="true" CodeFile="TS_ConsumeAppend.aspx.cs" Inherits="ASP_TaxiService_TS_ConsumeAppend" %>
<%@ Register Src="../../CardReader.ascx" TagName="CardReader" TagPrefix="cr" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <title>消费补录</title>

	<link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />

</head>
<body>
	<cr:CardReader id="cardReader" Runat="server"/>    

    <form id="form1" runat="server">
     <div class="tb">司机卡->消费补录</div>
   
     <ajaxToolkit:ToolkitScriptManager runat="Server" EnableScriptGlobalization="true"
            EnableScriptLocalization="true" ID="ScriptManager2" />
        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
         <ContentTemplate>
         <asp:BulletedList ID="bulMsgShow" runat="server"/>
         <script runat="server" >public override void ErrorMsgShow(){ErrorMsgHelper(bulMsgShow);}</script>  
         
         <div class="con">
          <div class="pip">员工信息</div>
          <div class="kuang5">
            <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
              <tr>
                <td width="5%"><div align="right">司机工号:</div></td>
                <td width="9%">
               
                <asp:TextBox ID="txtDriverStaffNo" runat="server" CssClass="input" MaxLength="6" ></asp:TextBox>
                <asp:HiddenField ID="hidDriverStafffNo" runat="server" />   
                
                </td>
                <td width="13%"> <div align="right">
                    <asp:Button ID="btnQuery" runat="server" Text="查询" CssClass="button1" OnClick="btnQuery_Click" />
                    &nbsp;
                    <asp:Button ID="btnReadCard" runat="server" Text="读卡" CssClass="button1" 
                        OnClick="btnReadCard_Click" OnClientClick="return readDriverInfo('txtDriverStaffNo')" />
                    <asp:HiddenField ID="hidBalUnitNo" runat="server" />
                   
                   </div>
               
               
                </td>
                <td width="8%">&nbsp;</td>
                <td width="10%">&nbsp;</td>
                <td width="10%">&nbsp;</td>
              </tr>
              <tr>
                <td><div align="right">IC卡号　:</div></td>
                <td>
                    <asp:Label ID="labCardNo" runat="server"></asp:Label>
                </td>
                <td>&nbsp;</td>
                <td>&nbsp;</td>
                <td>&nbsp;</td>
                <td>&nbsp;</td>
              </tr>
              <tr>
                <td><div align="right">车号　　:</div></td>
                <td><asp:Label ID="labCarNo" runat="server"></asp:Label></td>
                <td><div align="right">开户银行:</div></td>
                <td>
                   <asp:Label ID="labHouseBank" runat="server"></asp:Label>
                    <asp:HiddenField ID="hidBankCode" runat="server" /> 
                </td>
                <td><div align="right">银行账号:</div></td>
                <td><asp:Label ID="labBankAccount" runat="server"></asp:Label> </td>
              </tr>
              <tr>
                <td><div align="right">员工姓名:</div></td>
                <td><asp:Label ID="labStaffName" runat="server"></asp:Label></td>
                <td><div align="right">员工性别:</div></td>
               <td>
                  <asp:Label ID="labStaffSex" runat="server"></asp:Label>
                  
               </td>    
                <td><div align="right">联系电话:</div></td>
                <td><asp:Label ID="labContactPhone" runat="server"></asp:Label></td>
              </tr>
              <tr>
                <td><div align="right">车载电话:</div></td>
                <td><asp:Label ID="labCarPhone" runat="server"></asp:Label> </td>
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
                 <td><asp:Label ID="labPostCode" runat="server"></asp:Label> </td>
                <td><div align="right">电子邮件:</div></td>
                <td><asp:Label ID="labEmailAddr" runat="server"></asp:Label></td>
                <td><div align="right">联系地址:</div></td>
                <td colspan="3"><asp:Label ID="labContactAddr" runat="server"></asp:Label></td>
              </tr>
              <tr>
                <td><div align="right">采集卡号:</div></td>
                <td><asp:Label ID="labCollectCardNo" runat="server"></asp:Label>   </td>
                <td><div align="right">采集卡密码:</div></td>
                <td><asp:Label ID="labCollectCardPass" runat="server"></asp:Label> </td>
                <td><div align="right">离职标志:</div></td>
                <td><asp:Label ID="labDimssionTag" runat="server"></asp:Label>      </td>
              </tr>
            </table>
          </div>
        </div>
        <div class="pipinfo2">
        <div class="base">交易信息</div>
         <div class="kuang5" style=" height:150px;">
          <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
          <tr>
            <td width="14%"><div align="right">卡片ASN号 :</div></td>
            <td width="21%"><asp:Label ID="labAsnNo" runat="server"></asp:Label></td>
            <td width="18%"><div align="right">交易日期　:</div></td>
            <td width="16%"><asp:Label ID="labTradeDate" runat="server"></asp:Label></td>
            
            <td><div align="right">交易前金额:</div></td>
            <td><asp:Label ID="labPreMoney" runat="server"></asp:Label></td>
           
          </tr>
          <tr>
             <td><div align="right">交易后金额:</div></td>
            <td><asp:Label ID="labResMoney" runat="server"></asp:Label></td>
            
             <td><div align="right">交易金额　:</div></td>
            <td><asp:Label ID="labTradeMoney" runat="server"></asp:Label></td>
            
            <td width="18%"><div align="right">终端交易号:</div></td>
            <td width="13%"><asp:Label ID="labTradePos" runat="server"></asp:Label></td>
          </tr>
          <tr>
            <td><div align="right">卡片交易号:</div></td>
            <td><asp:Label ID="labCardTradeNo" runat="server"></asp:Label></td>
            <td><div align="right">终端编号　:</div></td>
            <td><asp:Label ID="labPsam" runat="server"></asp:Label></td>
            <td><div align="right">TAC码　　 :</div></td>
            <td><asp:Label ID="labTac" runat="server"></asp:Label></td>
          </tr>
          <tr>
            <td><div align="right">员工编码　:</div></td>
            <td><asp:Label ID="labStaffNo" runat="server"></asp:Label></td>
            <td>&nbsp;</td>
            <td>&nbsp;</td>
            <td>&nbsp;</td>
            <td>&nbsp;</td>
          </tr>
          <tr>
            <td>&nbsp;</td>
            <td>&nbsp;</td>
            <td>&nbsp;</td>
            <td>&nbsp;</td>
            <td>&nbsp;</td>
            <td><asp:HiddenField ID="hiddTradeDate" runat="server" />
                 <asp:HiddenField ID="hiddPreMoney" runat="server" />
                 <asp:HiddenField ID="hiddTradeMoney" runat="server" /></td>
          </tr>

        </table>
         </div> 
        </div>
        <div class="basicinfo2">
          <div class="jieguo">输入票据信息</div>
           <div class="kuang5">
             <table width="169" border="0" cellpadding="0" cellspacing="0" class="text25">
               <tr>
                 <td colspan="2">
                 <asp:TextBox ID="txtAppend01" runat="server"    
                        CssClass="inputmid" MaxLength="16" ></asp:TextBox>
                       
                 </td>
               </tr>
               <tr>
                 <td colspan="2">
                 <asp:TextBox ID="txtAppend02" runat="server"
                        CssClass="inputmid" MaxLength="16"></asp:TextBox>
                            
                 </td>
               </tr>
               <tr>
                 <td colspan="2">
                 <asp:TextBox ID="txtAppend03" runat="server" 
                        CssClass="inputmid" MaxLength="16" ></asp:TextBox>
                 <asp:HiddenField ID="hidPosTradeNo" runat="server" />
                        
                 </td>
               </tr>
               <tr>
                 <td colspan="2">
                 <asp:TextBox ID="txtAppend04" runat="server" 
                        CssClass="inputmid" MaxLength="16" ></asp:TextBox>
                      
                 </td>
               </tr>
               <tr>
                 <td width="80">
                 <asp:TextBox ID="txtAppend05" runat="server" 
                        CssClass="inputshort" MaxLength="8" ></asp:TextBox>
                        
                 </td>
                 <td width="89">
                 <asp:TextBox ID="txtAppend06" runat="server" 
                        CssClass="inputshort" MaxLength="6" ></asp:TextBox>
                    
                 </td>
               </tr>
               <tr>
                 <td>支付方式:</td>
                <td>
                   <asp:DropDownList runat="server" ID="selPayMoney" OnSelectedIndexChanged="MoneyPay_Select" AutoPostBack="true"></asp:DropDownList>       
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
            <td><asp:Button ID="btnConsumeAppend" runat="server" Text="补录" CssClass="button1" OnClick="btnConsumeAppend_Click" /></td>
            </tr>
        </table>

        </div>
         
              <asp:HiddenField ID="hidAppend01Ext" runat ="server" />  
              <asp:HiddenField ID="hidAppend02Ext" runat ="server" />   
              <asp:HiddenField ID="hidAppend03Ext" runat ="server" />  
              <asp:HiddenField ID="hidAppend04Ext" runat ="server" />   
              <asp:HiddenField ID="hidAppend05Ext" runat ="server" />  
              <asp:HiddenField ID="hidAppend06Ext" runat ="server" /> 
              
           </ContentTemplate>
         </asp:UpdatePanel>
    
    </form>
</body>
</html>

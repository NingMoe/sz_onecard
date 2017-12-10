<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Bus_ChangeInfo.aspx.cs" Inherits="ASP_TaxiService_Bus_ChangeInfo" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
    <title>公交司机信息变更</title>
	<link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
      <div class="tb">司机卡->信息变更</div>
      
       <ajaxToolkit:ToolkitScriptManager runat="Server" EnableScriptGlobalization="true"
            EnableScriptLocalization="true" ID="ScriptManager2" />
       <asp:UpdatePanel ID="UpdatePanel1" runat="server">
         <ContentTemplate>
         
         <asp:BulletedList ID="bulMsgShow" runat="server"/>
         <script runat="server" >public override void ErrorMsgShow(){ErrorMsgHelper(bulMsgShow);}</script>
            
      <div class="con">
          <div class="card">信息查询</div>
          <div class="kuang5">
         <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text20">
          <tr>
            <td width="9%"><div align="right">司机工号:</div></td>
            <td width="22%"><span class="red">
            
              <asp:TextBox ID="txtDriverStaffNo" runat="server" CssClass="input" MaxLength="6" ></asp:TextBox>
              <asp:HiddenField ID="hidDriverStafffNo" runat="server" /> 
            
            </span></td>
            <td width="14%">
              <asp:Button ID="btnQuery" runat="server" Text="查询" CssClass="button1" OnClick="btnQuery_Click" />
              
              <asp:HiddenField ID="hidQueryFlag" runat="server"  Value="false"/> 
            </td>
            <td width="64%">
             
            </td>
          </tr>
        </table>

         </div>

         <div class="pip">公交司机信息</div>
         <div class="kuang5">
         <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">

         <tr>
            <td><div align="right">司机姓名:</div></td>
            <td>
               <asp:TextBox runat="server" CssClass="input" MaxLength="20" ID="txtStaffName"></asp:TextBox>
            </td>
            <td><div align="right">司机性别:</div></td>
            <td>
                <asp:DropDownList runat="server" CssClass="input" ID="selStaffSex" Width = "118px"></asp:DropDownList>
            </td>
            <td><div align="right">IC卡号:</div></td>
            <td>
              <asp:TextBox ID="txtCardNo" runat="server"  CssClass="inputmid" MaxLength="16" ></asp:TextBox>
            </td>
          </tr>
          
          <tr>    
            <td><div align="right">车号:</div></td>
            <td><asp:TextBox runat="server" CssClass="input" MaxLength="5" ID="txtCarNo"></asp:TextBox>
            </td>
            <td><div align="right">联系电话:</div></td>
            <td>
                <asp:TextBox runat="server" CssClass="inputmid" MaxLength="20" ID="txtContactPhone"></asp:TextBox>
            </td> 
            <td><div align="right">车载电话:</div></td>
            <td>
                <asp:TextBox runat="server" CssClass="inputmid" MaxLength="15" ID="txtCarPhone"></asp:TextBox>
                
            </td>   
          </tr>

          <tr>
            <td><div align="right">证件类型:</div></td>
            <td>
               <asp:DropDownList runat="server" CssClass="input" ID="selPaperType" Width = "118px"></asp:DropDownList>
            
             </td>
            <td><div align="right">证件号码:</div></td>
            <td><asp:TextBox runat="server" CssClass="inputmid" MaxLength="20" ID="txtPaperNo"></asp:TextBox>
            </td>
             <td><div align="right">POS编号:</div></td>
            <td>
               <asp:TextBox runat="server" CssClass="inputmid" MaxLength="6" ID="txtPosID"></asp:TextBox>
            
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
             <td><div align="right">更新员工:</div></td>
            <td><asp:TextBox ID="txtUpdStaff" CssClass="labeltext" runat="server" ReadOnly="true"  Width="115px"></asp:TextBox> </td>
            <td><div align="right">更新时间:</div></td>
            <td><asp:TextBox ID="txtUpdTime" CssClass="labeltext" runat="server" ReadOnly="true" ></asp:TextBox></td>
    
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
              <asp:Button ID="btnUpdate" runat="server"  Text="更新" CssClass="button1" OnClick="Update_Click"   />
            </td>
            <td >
               &nbsp;
            </td>
               
          </tr>
        </table>

      </div>
  
      </ContentTemplate>
    </asp:UpdatePanel>

    
    </form>
</body>

</html>

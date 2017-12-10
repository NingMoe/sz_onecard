<%@ Page Language="C#" AutoEventWireup="true" CodeFile="TS_DriverInfoQuery.aspx.cs" Inherits="ASP_TaxiService_TS_DriverInfoQuery" %>
<%@ Register Src="../../CardReader.ascx" TagName="CardReader" TagPrefix="cr" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <title>司机信息查询</title>
	<link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    
    
</head>
<body>
    	<cr:CardReader id="cardReader" Runat="server"/>    

    <form id="form1" runat="server">
     <div class="tb">司机卡->司机信息查询</div>
     <ajaxToolkit:ToolkitScriptManager runat="Server" EnableScriptGlobalization="true"
            EnableScriptLocalization="true" ID="ScriptManager2" />
        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
         <ContentTemplate>
         <asp:BulletedList ID="bulMsgShow" runat="server"/>
         <script runat="server" >public override void ErrorMsgShow(){ErrorMsgHelper(bulMsgShow);}</script>  
    
        <div class="con">
          <div class="base">查询</div>
          <div class="kuang5">
            <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
          <tr>
            <td><div align="right">采集卡号:</div></td>
            <td><asp:TextBox ID="txtCardNo" runat="server" CssClass="inputmid" MaxLength="16" Width = "130px" ></asp:TextBox></td>
            <td><div align="right"><asp:Button ID="btnReadCard" runat="server" Text="读卡" CssClass="button1" 
                   OnClientClick="return readCardNo()" OnClick="btnQuery_Click"  /> 
                </div></td>
            <td>&nbsp;</td>
            <td><div align="right">司机工号:</div></td>
            <td><asp:TextBox ID="txtDriverStaffNo" runat="server" CssClass="input" MaxLength="6" ></asp:TextBox>
                <asp:HiddenField ID="hidStaffNo" runat="server" /></td>
   
            <td>&nbsp;</td>
          </tr>
          <tr>
            <td><div align="right">单位名称:</div></td>
            <td>
               <asp:DropDownList runat="server" CssClass="inputmid" ID="selUnitName"
                 AutoPostBack="true" OnSelectedIndexChanged="selUnitName_SelectedIndexChanged">
               </asp:DropDownList>
            </td>
            <td><div align="right">部门名称:</div></td>
            <td>
               <asp:DropDownList runat="server" CssClass="inputmid" ID="selDeptName" >
               </asp:DropDownList>
            </td>
            <td><div align="right">司机姓名:</div></td>
            <td><asp:TextBox runat="server" ID="txtDriverName" CssClass="input"  MaxLength = "20" ></asp:TextBox></td>
            <td>&nbsp;</td>
          </tr>
          <tr>
            <td width="9%"><div align="right">联系电话:</div></td>
            <td width="15%">
               <asp:TextBox runat="server" ID="txtDriverPhone" CssClass="inputmid" MaxLength = "20"  Width = "130px"></asp:TextBox>
            </td>
                       
            <td width="10%"><div align="right">证件号码:</div></td>
            <td width="19%">
               <asp:TextBox runat="server" CssClass="inputmid" MaxLength="20" ID="txtPaperNo" ></asp:TextBox>
            </td>
            <td width="9%"><div align="right">车号:</div></td>
            <td width="24%">
               <asp:TextBox ID="txtCarNo" runat="server" CssClass="input" MaxLength="5" ></asp:TextBox>
            </td>
            <td width="14%">
                <asp:Button ID="btnQuery" runat="server" Text="查询" CssClass="button1" OnClick="btnQuery_Click" />
            </td>
          </tr>
        </table>
         </div>
          <div class="jieguo">司机信息

          </div>
          <div class="kuang5">
           <div class="gdtb" style="height:300px">
         
             <asp:GridView ID="lvwTaxiDriverInfo" runat="server"
                    CssClass="tab1"
                    Width ="2300"
                    HeaderStyle-CssClass="tabbt"
                    AlternatingRowStyle-CssClass="tabjg"
                    SelectedRowStyle-CssClass="tabsel"
                    PagerSettings-Mode="NumericFirstLast"
                    PagerStyle-HorizontalAlign="Left"
                    PagerStyle-VerticalAlign="Top"
                    AutoGenerateColumns="False"
                    OnPageIndexChanging="lvwTaxiDriverInfo_Page"
                    OnRowDataBound="gvResult_RowDataBound"
                    
                    >
                    <Columns>
                          <asp:BoundField DataField="STAFFNO"            HeaderText="工号"/> 
                          <asp:BoundField DataField="COLLECTCARDNO"      HeaderText="采集卡号"/>    
                          <asp:BoundField DataField="STAFFNAME"          HeaderText="姓名"/>   
                          <asp:BoundField DataField="STAFFSEX"           HeaderText="性别"/>               
                          <asp:BoundField DataField="STAFFPHONE"         HeaderText="联系电话"/>       
                          <asp:BoundField DataField="PAPERTYPENAME"      HeaderText="证件类型"/>      
                          <asp:BoundField DataField="STAFFPAPERNO"       HeaderText="证件号码"/>         
                          <asp:BoundField DataField="CORPNAME"           HeaderText="单位名称"/>       
                          <asp:BoundField DataField="DEPARTNAME"         HeaderText="部门名称"/>       
                          <asp:BoundField DataField="CARNO"              HeaderText="车号"/>           
                          <asp:BoundField DataField="STAFFMOBILE"        HeaderText="车载电话"/>     
                          <asp:BoundField DataField="DIMISSIONTAG"       HeaderText="离职标志"/>    
                          <asp:BoundField DataField="POSID"              HeaderText="PSAM卡号"/>       
                          <asp:BoundField DataField="STAFFPOST"          HeaderText="邮编"/>           
                          <asp:BoundField DataField="STAFFEMAIL"         HeaderText="电子邮件"/>  
                          <asp:BoundField DataField="STAFFADDR"          HeaderText="联系地址"/>           
                         <%-- <asp:BoundField DataField="OPERCARDNO"       HeaderText="司机卡号"/>  --%>  
                         <%-- <asp:BoundField DataField="COLLECTCARDPWD"   HeaderText="采集卡密码"/>  --%>
                                     
                   </Columns>   
                   
                   <EmptyDataTemplate>
                      <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                         <tr class="tabbt">
                          <td>工号</td>
                          <td>采集卡号</td>
                          <td>姓名</td>
                          <td>性别</td>
                          <td>联系电话</td>
                          <td>证件类型</td>
                          <td>证件号</td>
                          <td>单位名称</td>
                          <td>部门名称</td>
                          <td>车号</td>
                          <td>车载电话</td>
                          <td>离职标志</td>
                          <td>PSAM卡号</td>
                          <td>邮编</td>
                          <td>电子邮件</td>
                          <td>联系地址</td>
                       
                          <td>司机卡号</td>
                          <td>采集卡密码</td>
                         </tr>
                      </table>
                   </EmptyDataTemplate>
                  </asp:GridView>
                 
              
            </div>
          </div>
        </div>
       
     
        </ContentTemplate>
       </asp:UpdatePanel>
       <div class="btns">
         <table width="100" border="0" align="right" cellpadding="0" cellspacing="0">
          <tr>
            <td>
               <asp:Button ID="btnSave" runat="server" Text="导出" CssClass="button1" OnClick="btnSave_Click" />
            </td>
          </tr>
         </table>
        </div>
    
    </form>
</body>
</html>

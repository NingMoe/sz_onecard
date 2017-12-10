<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PB_TransitBalance_Loss.aspx.cs" Inherits="ASP_PersonalBusiness_PB_TransitBalance_Loss" %>
<%@ Register Src="../../CardReader.ascx" TagName="CardReader" TagPrefix="cr" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
<title>תֵ</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />

    <script type="text/javascript" src="../../js/print.js"></script>
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
</head>
<body>
	<cr:CardReader id="cardReader" Runat="server" />    
    <form id="form1" runat="server">
<div class="tb">
����ҵ��->��ʧ��תֵ

</div>
<ajaxToolkit:ToolkitScriptManager runat="Server" EnableScriptGlobalization="true"
            EnableScriptLocalization="true" ID="ScriptManager2" />
          <script type="text/javascript" language="javascript">
                var swpmIntance = Sys.WebForms.PageRequestManager.getInstance();
                swpmIntance.add_initializeRequest(BeginRequestHandler);
                swpmIntance.add_pageLoading(EndRequestHandler);
								function BeginRequestHandler(sender, args){
    							try {MyExtShow('��ȴ�', '�����ύ��̨������...'); } catch(ex){}
								}
								function EndRequestHandler(sender, args) {
    							try {MyExtHide(); } catch(ex){}
								}
          </script>
        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
            <ContentTemplate>
            <aspControls:PrintPingZheng ID="ptnPingZheng" runat="server" PrintArea="ptnPingZheng1" />
<asp:BulletedList ID="bulMsgShow" runat="server">
</asp:BulletedList>
<script runat="server" >public override void ErrorMsgShow(){ErrorMsgHelper(bulMsgShow);}</script>  
  <div class="con">
  <div class="card">�¿���Ϣ</div>
  <div class="kuang5">
    <table width="98%" border="0" cellpadding="0" cellspacing="0" class="text20">
   <tr>
     <td width="9%" align="right"><div align="right">�¿�����:</div></td>
     <td width="13%"><asp:TextBox ID="txtCardno" CssClass="labeltext" runat="server"></asp:TextBox></td>
     <td width="9%" align="right"><div align="right">��Ƭ����:</div></td>
     <td width="13%"><asp:TextBox ID="LabCardtype" CssClass="labeltext" runat="server"></asp:TextBox></td>
     <td width="9%"align="right"><div align="right">��������:</div></td>
     <td width="13%"><asp:TextBox ID="sDate" CssClass="labeltext" runat="server" Text=""></asp:TextBox></td>
     <td width="9%"align="right"><div align="right">�������:</div></td>
     <td width="13%"><asp:TextBox ID="cMoney" CssClass="labeltext" runat="server" Text=""></asp:TextBox>
                <asp:TextBox ID="LabAsn" CssClass="labeltext" runat="server" Visible="false"></asp:TextBox></td>
     <td width="11%"  align="right"><asp:Button ID="btnReadCard" CssClass="button1" runat="server" Text="���¿�"  OnClientClick="return ReadCardInfo()" OnClick="btnReadCard_Click" /></td>
   </tr>
 </table>
   <asp:HiddenField ID="newCardNo" runat="server" />
   <asp:HiddenField ID="hiddenread" runat="server" />
   <asp:HiddenField ID="hiddenAsn" runat="server" />
   <asp:HiddenField ID="hiddenLabCardtype" runat="server" />
   <asp:HiddenField ID="hiddensDate" runat="server" />
   <asp:HiddenField ID="hiddeneDate" runat="server" />
   <asp:HiddenField ID="hiddencMoney" runat="server" />
   <asp:HiddenField ID="hiddentradeno" runat="server" />
   <asp:HiddenField ID="hidWarning" runat="server" />
   <asp:HiddenField ID="hidSupplyMoney" runat="server" />
   <asp:HiddenField ID="hidCustname" runat="server" />
   <asp:HiddenField ID="hidPaperno" runat="server" />
   <asp:HiddenField ID="hidPapertype" runat="server" />
   <asp:LinkButton  ID="btnConfirm" runat="server" OnClick="btnConfirm_Click"/>
   <asp:HiddenField ID="ChangeRecord" runat="server" />
   <asp:HiddenField ID="hidCardReaderToken" runat="server"/>
   <asp:HiddenField ID="HiddenLossCardMoney" runat="server"/>
   <asp:HiddenField ID="HiddenTransitMoney" runat="server" />
   <asp:HiddenField runat="server" ID="hidoutTradeid" />
 </div>
 
 <div class="pip">�û���Ϣ</div>
  <div class="kuang5">
 <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text20">
  <tr>
    <td width="10%"><div align="right">�û�����:</div></td>
    <td width="13%"><asp:Label ID="CustName" runat="server" Text=""></asp:Label></td>
    <td width="9%"><div align="right">��������:</div></td>
    <td width="13%"><asp:Label ID="CustBirthday" runat="server" Text=""></asp:Label></td>
    <td width="9%"><div align="right">֤������:</div></td>
    <td width="13%"><asp:Label ID="Papertype" runat="server" Text=""></asp:Label></td>
    <td width="9%"><div align="right">֤������:</div></td>
    <td width="24%" colspan="3"><asp:Label ID="Paperno" runat="server" Text=""></asp:Label></td>
    </tr>
  <tr>
    <td><div align="right">�û��Ա�:</div></td>
    <td><asp:Label ID="Custsex" runat="server" Text=""></asp:Label></td>
    <td><div align="right">��ϵ�绰:</div></td>
    <td><asp:Label ID="Custphone" runat="server" Text=""></asp:Label></td>
    <td><div align="right">��������:</div></td>
    <td><asp:Label ID="Custpost" runat="server" Text=""></asp:Label></td>
    <td><div align="right">��ϵ��ַ:</div></td>
    <td colspan="3"><asp:Label ID="Custaddr" runat="server" Text=""></asp:Label></td>
    </tr>
  
  
  <tr>
    <td><div align="right">�����ʼ�:</td>
    <td><asp:Label ID="txtEmail" runat="server" Text=""></asp:Label></td> 
    <td valign="top"><div align="right">��ע����:</div></td>
    <td colspan="5"><asp:Label ID="Remark" runat="server" Text=""></asp:Label></td>
    </tr>
</table>
 </div>
 
 
 <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
     <tr>
        <td width="100" align="center"><div class="card">��ʧ����Ϣ</div></td>
        <td width="*" align="right">&nbsp;</td>
        <td width="60"><div align="right">��ѯ����:</div></td>
        <td width="460" align="right">
            <asp:DropDownList runat="server" ID="selQueryType">
                <asp:ListItem Selected="True" Text="01:����" Value="01"></asp:ListItem>
                <asp:ListItem Text="02:֤��" Value="02"></asp:ListItem>
            </asp:DropDownList>
            <asp:TextBox ID="txtCondition" CssClass="inputlong" runat="server" MaxLength="20" Text=""/>
            <asp:Button ID="btnQuery" Text="��ѯ" CssClass="button1" runat="server" OnClick="btnQuery_Click"/>
        </td>
    </tr>
   </table>
       
   
   
 <div class="kuang5">
   <div class="tab1" style="height:80px;overflow-y: scroll;" >
   <asp:GridView ID="gvLossOldCardInfo" runat="server"
        Width = "98%"
        CssClass="tab1"
        HeaderStyle-CssClass="tabbt"
        AlternatingRowStyle-CssClass="tabjg"
        SelectedRowStyle-CssClass="tabsel"
        AutoGenerateColumns="false"
        AutoGenerateSelectButton="True" 
        OnSelectedIndexChanged="gvLossOldCardInfo_SelectedIndexChanged" 
       >
           <Columns>
               <asp:BoundField ItemStyle-Width="15%" HeaderText="����" DataField="CARDNO"/>
               <asp:BoundField ItemStyle-Width="10%" HeaderText="��ʧʱ��" DataField="LOSSDATE"/>
               <asp:BoundField ItemStyle-Width="15%" HeaderText="�����" DataField="CARDACCMONEY"/>
               <asp:BoundField ItemStyle-Width="15%" HeaderText="������" DataField="CARDTYPENAME"/>
               <asp:BoundField ItemStyle-Width="10%" HeaderText="����" DataField="CUSTNAME"/>
               <asp:BoundField ItemStyle-Width="20%" HeaderText="֤������" DataField="PAPERNO"/>
               <asp:BoundField ItemStyle-Width="10%" HeaderText="��ϵ�绰" DataField="CUSTPHONE"/>
            </Columns>   
            
            <EmptyDataTemplate>
                <table width="90%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                  <tr class="tabbt">
                  <td  width="10%">����</td>
                  <td width="10%">��ʧ����</td>
                    <td width="10%">�����</td>
                    <td width="10%">������</td>
                    <td width="10%">����</td>
                    <td width="10%">֤������</td>
                    <td width="10%">��ϵ�绰</td>
                    </tr>
                  </table>
            </EmptyDataTemplate>
            
               
    </asp:GridView>
    
    
   
    
    </div>
 </div>
 


  <div class="pip">δתֵ��Ϣ</div>
  <div class="kuang5">
  <div style="height:60px;overflow-y: scroll;" >
  <asp:GridView ID="lvwTransitQuery" runat="server"
            Width = "95%"
            CssClass="tab1"
            HeaderStyle-CssClass="tabbt"
            AlternatingRowStyle-CssClass="tabjg"
            SelectedRowStyle-CssClass="tabsel"
            AllowPaging="True"
            PageSize="5"
            PagerSettings-Mode="NumericFirstLast"
            PagerStyle-HorizontalAlign="left"
            PagerStyle-VerticalAlign="Top"
            OnPageIndexChanging="lvwTransitQuery_Page"
            AutoGenerateColumns="False"
            OnRowDataBound = "lvwTransitQuery_RowDataBound"
            >
            <Columns>
              <asp:BoundField DataField="OLDCARDNO"       HeaderText="�ɿ�����"/>
              <asp:BoundField DataField="CARDNO"       HeaderText="�¿�����"/>  
              <asp:BoundField  DataFormatString="{0:yyyy-MM-dd}" DataField="OPERATETIME" HeaderText="����ʱ��" />
              <asp:BoundField DataField="CARDACCMONEY"      HeaderText="δתֵ���" NullDisplayText="0" DataFormatString="{0:n}" HtmlEncode="false" />
              <asp:BoundField DataField="TFLAG"       HeaderText="��־λ"/>
              <asp:BoundField DataField="TRADEID"       HeaderText="TRADEID" />
      
            </Columns>     
       
           <EmptyDataTemplate>
           <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
             <tr class="tabbt">
                <td>�ɿ�����</td>
                <td>�¿�����</td>
                <td>����ʱ��</td>
                <td>δתֵ���</td>
            </tr>
           </table>
          </EmptyDataTemplate>
    </asp:GridView>
  </div>
</div>
</div>

 <div class="basicinfo">
 <div class="money">������Ϣ</div>
 <div class="kuang5">
     <table width="170" border="0" cellpadding="0" cellspacing="0" class="tab1">
  <tr class="tabbt">
    <td width="66">������Ŀ</td>
    <td width="94">���ý��(Ԫ)</td>
    </tr>
  <tr>
    <td>������</td>
    <td><asp:Label ID="ProcedureFee" runat="server" Text=""></asp:Label></td>
    </tr>
  <tr class="tabjg">
    <td>��������</td>
    <td><asp:Label ID="OtherFee" runat="server" Text=""></asp:Label></td>
    </tr>
  <tr class="tabjg">
    <td>�ϼ�Ӧ��(��)</td>
    <td><asp:Label ID="Total" runat="server" Text=""></asp:Label></td>
  </tr>
</table>
 </div>
 </div>
 
 
 <div class="pipinfo">
 <div class="info">תֵ��Ϣ</div>
 <div class="kuang5">
 <div style="height:83px">
 <div class="left">
 <img src="../../Images/show.JPG" width="170" height="83" alt="" /></div>
  <div class="big">
  <table width="200" border="0" cellspacing="0" cellpadding="0">    
     <tr>
       <td width="320" colspan="2" class="red"><div align="center">��ǰת���¿������Ϊ</div></td>
      </tr>
     <tr>
       <td colspan="2"><div align="center"><asp:Label ID="TransitBalance" runat="server" Text=""></asp:Label></div></td>
      </tr>
   </table>
  </div>
  </div>
 </div>
</div>

 <div class="footall"></div>
  <div class="footall"></div>
<div class="btns">
     <table width="200" border="0" align="right" cellpadding="0" cellspacing="0">
  <tr>
    <td style="height: 21px"><asp:Button ID="btnPrintPZ" runat="server" Text="��ӡƾ֤" CssClass="button1" Enabled="false"  OnClientClick="printdiv('ptnPingZheng1')" /></td>
    <td style="height: 21px"><asp:Button ID="Transit" CssClass="button1" runat="server" Text="תֵ" OnClick="Transit_Click" /></td>
  </tr>
</table>
<td><asp:CheckBox ID="chkPingzheng" runat="server" Checked="true" />�Զ���ӡƾ֤</td>
</div>
        </ContentTemplate>          
        </asp:UpdatePanel>
    </form>
</body>
</html>

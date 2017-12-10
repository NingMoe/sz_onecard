<%@ Page Language="C#" AutoEventWireup="true" CodeFile="CG_CashGiftBatchSale.aspx.cs" Inherits="ASP_CashGift_CG_CashGiftBatchSale" %>
<%@ Register Src="../../CardReader.ascx" TagName="CardReader" TagPrefix="cr" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <title>利金卡批量售卡</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
     <script type="text/javascript" src="../../js/print.js"></script>
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript">
    
    var readCardTimes = 0;
    
    function readGiftFunc()
    {
        if ($get('txtCardNo').value != "")
        {
            printShouJu();
        }

        MyExtConfirm('利金卡售卡', 
            '请放置好准备出售的卡片。<br><br>按确认继续。', 
            readGiftFuncDelay);     
    }
    
    function readGiftFuncDelay(btn)
    {
        if (btn == 'yes' )
        {
            if (cardReader.testingMode )
            {
                if (readCardTimes == 0) $get('txtCardNo').value = '2150050100000071';
                else if (readCardTimes == 1) $get('txtCardNo').value = '2150050100000072';
                else if (readCardTimes == 2) $get('txtCardNo').value = '2150050100000073';
                readCardTimes++;
            }
        
            var readRet = ReadCashGiftInfo(assignGiftFunc);
            if (readRet) {
                $get('hidWarning').value = 'ReadSuccess';
                $get('btnConfirm').click();
            }
        }
   }
    
   function assignGiftFunc(cardNoId, cardInfo)
   {
        assignValue('txtCardNo', cardInfo.cardNo);
        assignValue('hidAsn', cardInfo.appSn);
        assignValue('txtStartDate', cardInfo.appStartDate);
        assignValue('txtEndDate', cardInfo.appEndDate);
        assignValue('txtCardBalance', cardInfo.balance);
        assignValue('txtWallet2', cardInfo.wallet2);
        assignValue('hidTradeNo', cardInfo.tradeNo);	    
   }
       
    </script>
</head>
<body>
	<cr:CardReader id="cardReader" runat="server"/>    
	   
    <form id="form1" runat="server">
       <div class="tb">利金卡->批量售卡</div>
        <ajaxToolkit:ToolkitScriptManager EnableScriptGlobalization="true" 
            EnableScriptLocalization="true" ID="ScriptManager1" runat="server"/>
           <script type="text/javascript" language="javascript">
                var swpmIntance = Sys.WebForms.PageRequestManager.getInstance();
                swpmIntance.add_initializeRequest(BeginRequestHandler);
                swpmIntance.add_pageLoading(EndRequestHandler);
				function BeginRequestHandler(sender, args){
				    try {MyExtShow('请等待', '正在提交后台处理中...'); } catch(ex){}
				}
				function EndRequestHandler(sender, args) {
				    try {MyExtHide(); } catch(ex){}
				}
          </script> 
          <asp:UpdatePanel ID="UpdatePanel1" runat="server" RenderMode="Inline" >
            <ContentTemplate>
            
    <aspControls:PrintShouJu ID="ptnShouJu" runat="server" PrintArea="ptnShouJu1" />


    <asp:BulletedList ID="bulMsgShow" runat="server">
    </asp:BulletedList>
    <script runat="server" >public override void ErrorMsgShow(){ErrorMsgHelper(bulMsgShow);}</script>          

<asp:HiddenField runat="server" ID="txtCardNo" />
<asp:HiddenField runat="server" ID="hidAsn" />
<asp:HiddenField runat="server" ID="txtStartDate" />
<asp:HiddenField runat="server" ID="txtEndDate" />
<asp:HiddenField runat="server" ID="txtCardBalance" />
<asp:HiddenField runat="server" ID="txtWallet2" />
<asp:HiddenField runat="server" ID="hidTradeNo" />

<asp:HiddenField runat="server" ID="hidWarning" />
<asp:HiddenField runat="server" ID="hidSeqNo" /> 
<asp:HiddenField runat="server" ID="hidWriteCardFailInfo" /> 

<asp:HiddenField runat="server" ID="hidSaleSeq" Value="0" />

<asp:LinkButton runat="server" ID="btnConfirm" OnClick="btnConfirm_Click"/></tr>

<div class="con">
  <div class="jieguo"></div>
  <div class="kuang5">
  <div id="gdtb" style="height:450px">
         <asp:GridView ID="gvResult" runat="server"
        Width = "98%"
        CssClass="tab1"
        HeaderStyle-CssClass="tabbt"
        AlternatingRowStyle-CssClass="tabjg"
        SelectedRowStyle-CssClass="tabsel"
        PagerSettings-Mode="NumericFirstLast"
        PagerStyle-HorizontalAlign="left"
        PagerStyle-VerticalAlign="Top"
        AutoGenerateColumns="False">
           <Columns>
              <asp:BoundField HeaderText="#" ItemStyle-Width="5%" DataField="seq" />
             <asp:BoundField HeaderText="卡号" ItemStyle-Width="15%" DataField="cardno" />
              <asp:BoundField HeaderText="售卡金额" ItemStyle-Width="10%" DataField="salemoney" />
              <asp:BoundField HeaderText="读卡信息" ItemStyle-Width="20%" DataField="readcardinfo" />
              <asp:BoundField HeaderText="写库信息" ItemStyle-Width="20%" DataField="writedbinfo" />
              <asp:BoundField HeaderText="写卡信息" ItemStyle-Width="20%" DataField="writecardinfo" />
            </Columns>           
            <EmptyDataTemplate>
                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                  <tr class="tabbt">
                    <td width="5%">#</td>
                    <td width="15%">卡号</td>
                    <td width="10%">售卡金额</td>

                    <td width="20%">读卡信息</td>
                    <td width="20%">写库信息</td>
                   <td width="20%">写卡信息</td>
                  </tr>
                  </table>
            </EmptyDataTemplate>
        </asp:GridView>
  </div>
  </div>
</div>


 <div class="footall"></div>
<div class="btns">
     <table width="600" align="right" border="0"cellpadding="0" cellspacing="0">
  <tr>
    <td align="right">每张售卡金额:</td>
    <td><asp:TextBox ID="txtSaleMoney" CssClass="input" runat="server" MaxLength="6" Width="50px" />元<span class="red">*</span></td>
<%--    <td align="right">每张有效期:</td>
    <td><asp:DropDownList runat="server" ID="selValidMonths" CssClass="input" /><span class="red">*</span></td>
--%>    <td align="middle"><asp:Button ID="btnSubmit" CssClass="button1" runat="server" Text="开始售卡" OnClick="btnSubmit_Click"/></td>
  </tr>
</table>
<asp:CheckBox ID="chkShouju" runat="server" Text="自动打印收据"  Checked="true"/>

</div>  
    
                </ContentTemplate>
        </asp:UpdatePanel>
    </form>
</body>
</html>

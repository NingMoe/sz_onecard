<%@ Page Language="C#" AutoEventWireup="true" CodeFile="TL_AwardHistory.aspx.cs" Inherits="ASP_TransferLottery_TL_AwardHistory" %>

<%@ Register Src="../../CardReader.ascx" TagName="CardReader" TagPrefix="cr" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>领奖历史查询</title>

     <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="../../js/myext.js"></script>
    <script type="text/javascript" src="../../js/print.js"></script>
</head>
<body>
    <cr:CardReader ID="cardReader" runat="server" />
    <form id="form1" runat="server">
   <div class="tb">
		    换乘奖励->领奖历史查询
	    </div>
	
	    <ajaxToolkit:ToolkitScriptManager runat="Server" EnableScriptGlobalization="true"
            EnableScriptLocalization="true" ID="ToolkitScriptManager1" />
	    <script type="text/javascript" language="javascript">
	        var swpmIntance = Sys.WebForms.PageRequestManager.getInstance();
	        swpmIntance.add_initializeRequest(BeginRequestHandler);
	        swpmIntance.add_pageLoading(EndRequestHandler);
	        function BeginRequestHandler(sender, args) {
	            try { MyExtShow('请等待', '正在提交后台处理中...'); } catch (ex) { }
	        }
	        function EndRequestHandler(sender, args) {
	            try { MyExtHide(); } catch (ex) { }
	        }
          </script>
          <asp:UpdatePanel ID="UpdatePanel2" runat="server">  
            <ContentTemplate>
             <asp:BulletedList ID="bulMsgShow" runat="server" />
                <script runat="server">public override void ErrorMsgShow() { ErrorMsgHelper(bulMsgShow); }</script>
            <div class="con">

	           <div class="card">查询</div>
               <div class="kuang5">
               <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                   <tr>
                        <td width="15%">
                            <div align="right">
                                卡号:
                            </div>
                        </td>
                        <td width="15%">
                            <asp:TextBox runat="server" ID="txtCardno" CssClass="input" MaxLength="16"></asp:TextBox>
                        </td>
                        <td width="15%"></td>
                        <td align="right">
                            <asp:Button ID="btnQuery" CssClass="button1" runat="server" Text="读卡" OnClientClick="return ReadCardInfo()"
                               OnClick="btnReadCard_Click"/>
                                <asp:Button ID="btnQueryDB" CssClass="button1" runat="server" Text="查询" OnClick="btnReadCard_Click" />
                        </td>
                       
                   </tr>
                   
               </table>
               
             </div>
              <div class="jieguo">
                        查询结果
                    </div>
                    <div class="kuang5">
                        <div id="divResult" style="height: 280px; overflow: auto; display: block">
                            <asp:GridView ID="gvResult" runat="server" Width="150%" CssClass="tab1"
                                HeaderStyle-CssClass="tabbt" FooterStyle-CssClass="tabcon" AlternatingRowStyle-CssClass="tabjg"
                                SelectedRowStyle-CssClass="tabsel"  AutoGenerateColumns="false" >
                                <Columns> 
                                <asp:BoundField DataField="CARDNO" HeaderText="中奖卡号" />
                                <asp:BoundField DataField="AWARDCARDNO" HeaderText="领奖卡号" />
                                <asp:BoundField DataField="LOTTERYPERIOD" HeaderText="奖期" />
                                <asp:BoundField DataField="AWARDSNAME" HeaderText="中奖奖项" />
                                <asp:BoundField DataField="MONEY" HeaderText="中奖金额" />
                                <asp:BoundField DataField="OPERATETIME" HeaderText="领奖时间" />
                                <asp:BoundField DataField="OPERATEDEPART" HeaderText="领奖网点" />
                                <asp:BoundField DataField="NAME" HeaderText="领奖人姓名" />
                                <asp:BoundField DataField="PAPERTYPE" HeaderText="领奖人证件类型" /> 
                                <asp:BoundField DataField="PAPERNO" HeaderText="领奖人证件号码" /> 
                                <asp:BoundField DataField="TEL" HeaderText="领奖人电话" />
                                <asp:BoundField DataField="TAX" HeaderText="扣税" /> 
                            </Columns>
                                <EmptyDataTemplate>
                                    <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                        <tr class="tabbt">
                                            <td>中奖卡号 
                                            </td>
                                            <td>领奖卡号 
                                            </td>
                                            <td>奖期
                                            </td>
                                            <td>中奖奖项 
                                            </td>
                                            <td>中奖金额
                                            </td>
                                            <td>领奖时间
                                            </td>
                                            <td>领奖网点
                                            </td>
                                            <td>领奖人姓名
                                            </td>
                                            <td>领奖人证件类型
                                            </td>
                                            <td>领奖人证件号码
                                            </td>
                                            <td>领奖人电话
                                            </td>
                                            <td>扣税
                                            </td>
                                        </tr>
                                    </table>
                                </EmptyDataTemplate>
                            </asp:GridView>
                        </div>
                    </div>
               </div>
            </ContentTemplate>
            </asp:UpdatePanel>
    </form>
</body>
</html>

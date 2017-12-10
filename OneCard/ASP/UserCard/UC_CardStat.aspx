<%@ Page Language="C#" AutoEventWireup="true" CodeFile="UC_CardStat.aspx.cs" Inherits="ASP_UserCard_UC_CardStat" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <title>用户卡统计</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <script language="javascript">

    </script>
</head>
<body>
    <form id="form1" runat="server">
        <ajaxToolkit:ToolkitScriptManager EnableScriptGlobalization="true" EnableScriptLocalization="true" ID="ScriptManager1" runat="server"/>

        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
            <ContentTemplate>
        <div class="tb">
        卡片管理->用户卡统计
        </div>
    <asp:BulletedList ID="bulMsgShow" runat="server">
    </asp:BulletedList>
    <script runat="server" >public override void ErrorMsgShow(){ErrorMsgHelper(bulMsgShow);}</script>


        <div class="con">
          <div class="jieguo">统计结果
          </div>
  <div id="printarea" class="kuang5">
         <asp:GridView ID="gvResult" runat="server"
        Width = "100%"
        CssClass="tab2"
        HeaderStyle-CssClass="tabbt"
        AlternatingRowStyle-CssClass="tabjg"
        SelectedRowStyle-CssClass="tabsel"

        PagerSettings-Mode=NumericFirstLast
        PagerStyle-HorizontalAlign=left
        PagerStyle-VerticalAlign=Top
        AutoGenerateColumns="False"
        OnDataBound="gvResult_DataBound"
        OnPreRender="gvResult_PreRender"
        ShowFooter="true" OnRowDataBound="gvResult_RowDataBound"
        >
           <Columns>
                <asp:BoundField HeaderText="卡类型" DataField="CARDTYPENAME"/>
                <asp:BoundField HeaderText="卡面" DataField="CARDSURFACENAME"/>
                <asp:BoundField HeaderText="芯片类型" DataField="CARDCHIPTYPENAME"/>
                <asp:BoundField HeaderText="卡状态" DataField="RESSTATE"/>
                <asp:BoundField HeaderText="卡数量" DataField="AMOUNT"/>
           </Columns>           
            <EmptyDataTemplate>
                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                  <tr class="tabbt">
                    <td>卡类型</td>
                    <td>卡面</td>
                    <td>芯片类型</td>
                    <td>卡状态</td>
                    <td>卡数量</td>
                  </tr>
                  </table>
            </EmptyDataTemplate>
        </asp:GridView>
  </div>       
  </div>
  </ContentTemplate>
</asp:UpdatePanel>
      <div class="btns">
    <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>   
     <td align="right">
    <asp:Button ID="btnExport" CssClass="button1" runat="server" Text="导出" OnClick="btnExport_Click"/>
    <asp:Button ID="btnPrint" CssClass="button1" runat="server" Text="打印" OnClientClick="onprint();"/>
    </td>
    </tr>
    </table>
    </div>


    </form>
	<script type="text/javascript">
	window.onbeforeprint = beforePrint;
	window.onafterprint = afterPrint;
	var bdhtml = null;
	var borderstyle = null;
	function beforePrint(){
		bdhtml= window.document.body.innerHTML; 
		window.document.body.innerHTML = $get('printarea').innerHTML;

        borderstyle = window.document.body.style.border;
		window.document.body.style.border = '';
	}
	function afterPrint(){
		window.document.body.innerHTML  = bdhtml;
		window.document.body.style.border = borderstyle;
	}
	function onprint(){
	    parent.content.focus();
	    parent.content.print();
	}
	</script>
    
</body>
</html>

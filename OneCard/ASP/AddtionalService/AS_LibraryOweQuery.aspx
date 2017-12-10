<%@ Page Language="C#" AutoEventWireup="true" CodeFile="AS_LibraryOweQuery.aspx.cs" Inherits="ASP_AddtionalService_AS_LibraryOweQuery" %>
<%@ Register Src="../../CardReader.ascx" TagName="CardReader" TagPrefix="cr" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>图书馆欠款欠书查询</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <script type="text/javascript" src="../../js/print.js"></script>
    <script type="text/javascript" src="../../js/myext.js"></script>
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
</head>
<body>
<cr:CardReader id="cardReader" Runat="server"/>    
    <form id="form1" runat="server">
    <div class="tb">
         附加业务->图书馆欠款欠书查询
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
            <!-- #include file="../../ErrorMsg.inc" -->
            <div class="con">
                <div class="card">
                    查询</div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text20">
                        <tr>
                            <td width="10%">
                                <div align="right">
                                    用户卡号:</div>
                            </td>
                            <td width="13%">
                                <asp:TextBox ID="txtCardno" CssClass="input" maxlength="16" runat="server"></asp:TextBox>
                            </td>
                            <td width="9%">
                                <div align="right">
                                    卡片类型:</div>
                            </td>
                            <td width="13%">
                                <asp:Label ID="labCardType" CssClass="labeltext" runat="server" />
                            </td>
                            <td width="9%">
                                <div align="right">
                                    卡内余额:</div>
                            </td>
                            <td width="13%">
                                <asp:TextBox ID="txtCardBalance" CssClass="labeltext" runat="server" />
                            </td>
       
                            <td width="24%">
                             <div align="right">
                                <asp:Button ID="btnReadCard" Text="读卡" CssClass="button1" runat="server" OnClientClick="return ReadParkCardInfo()"
                                    OnClick="btnReadCard_Click" />
                                    </div>
                            </td>
                           
                        </tr>
                        <tr>
                            <td width="10%">
                                <div align="right">
                                    启用日期:</div>
                            </td>
                            <td width="13%">
                                <asp:TextBox ID="txtStartDate" CssClass="labeltext" runat="server" />
                            </td>
                            <td width="9%">
                                <div align="right">
                                    结束日期:</div>
                            </td>
                            <td width="13%">
                                <asp:TextBox ID="txtEndDate" CssClass="labeltext" runat="server" />
                            </td>
                            <td width="9%">
                                <div align="right">
                                    卡片状态:</div>
                            </td>
                            <td width="13%">
                                <asp:TextBox ID="txtCardState" CssClass="labeltext" runat="server" />
                            </td>
                             <td width="24%">
                              <div align="right">
                             <asp:Button ID="btnDBread" CssClass="button1" runat="server" Text="读数据库" OnClick="btnDBread_Click"  /></td>
                           </div>
                        </tr>
                    </table>
                </div>
                <table border="0" width="95%">
                    <tr>
                        <td align="left">
                            <div class="jieguo">
                                查询结果</div>
                        </td>
                        <td align="right">
                           <asp:Button ID="btnQuery" CssClass="button1" runat="server" Text="查询" OnClick="btnQuery_Click" />
                        </td>
                    </tr>
                </table>
                <div id="printarea" class="kuang5">
                    <div style="height: 150px;overflow:auto;">
                        <asp:GridView ID="gvMoney" runat="server" Width="95%" CssClass="tab1" HeaderStyle-CssClass="tabbt"
                            FooterStyle-CssClass="tabcon" AlternatingRowStyle-CssClass="tabjg" 
                            SelectedRowStyle-CssClass="tabsel" PagerSettings-Mode="NumericFirstLast" 
                            PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top"
                            AutoGenerateColumns="false" ShowFooter="true" AllowPaging="True"
                            PageSize="20" OnPageIndexChanging="gvMoney_PageIndexChanging" >
                            <Columns>
                                <asp:BoundField HeaderText="欠款类型" DataField="OWETYPE"  />
                                <asp:BoundField HeaderText="欠款金额" DataField="OWEMONEY" />
                                <asp:BoundField HeaderText="欠款时间" DataField="OWEMONEYTIME" />
 
                            </Columns>
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                    
                                         <td width="5%">
                                            欠款类型
                                        </td>
                                         <td width="5%">
                                            欠款金额
                                        </td>
                                        <td width="5%">
                                            欠款时间
                                        </td>
                                      
                                    </tr>
                                </table>
                            </EmptyDataTemplate>
                        </asp:GridView>
                    </div>
                </div>
                <div id="Div1" class="kuang5">
                    <div style="height: 280px;overflow:auto;">
                        <asp:GridView ID="gvBook" runat="server" Width="95%" CssClass="tab1" HeaderStyle-CssClass="tabbt"
                            FooterStyle-CssClass="tabcon" AlternatingRowStyle-CssClass="tabjg" 
                            SelectedRowStyle-CssClass="tabsel" PagerSettings-Mode="NumericFirstLast" 
                            PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top"
                            AutoGenerateColumns="false" ShowFooter="true" AllowPaging="True"
                            PageSize="20" OnPageIndexChanging="gvBook_PageIndexChanging">
                            <Columns>
                                <asp:BoundField HeaderText="书名" DataField="TITLE"  />
                                <asp:BoundField HeaderText="作者" DataField="AUTHOR" />
                                <asp:BoundField HeaderText="ISBN" DataField="ISBN" />
                                <asp:BoundField HeaderText="索书号" DataField="INDEX"  />
                                <asp:BoundField HeaderText="出版社" DataField="PRESS" />
                                <asp:BoundField HeaderText="出版时间" DataField="PUBLISHDATE" />
                                <asp:BoundField HeaderText="借阅时间" DataField="BORROWTIME" />
                            </Columns>
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                    
                                         <td width="5%">
                                            书名
                                        </td>
                                         <td width="5%">
                                            作者
                                        </td>
                                        <td width="5%">
                                            ISBN
                                        </td>
                                        <td width="8%">
                                            索书号
                                        </td>
                                          <td width="8%">
                                            出版社
                                        </td>
                                        <td width="8%">
                                            出版时间
                                        </td>
                                        <td width="8%">
                                            借阅时间
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

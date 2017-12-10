<%@ Page Language="C#" AutoEventWireup="true" CodeFile="AS_LibrarySyncQuery.aspx.cs" Inherits="ASP_AddtionalService_AS_LibrarySyncQuery" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>图书馆同步信息查询</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <script type="text/javascript" src="../../js/print.js"></script>
    <script type="text/javascript" src="../../js/myext.js"></script>
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
    <div class="tb">
         附加业务->图书馆同步信息查询
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
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                          <td width="10%">
                                <div align="right">
                                    用户卡号:</div>
                            </td>
                            <td width="13%">
                                <asp:TextBox ID="txtCardno" CssClass="input" maxlength="16" runat="server"></asp:TextBox>
                            </td>
                            <td>
                                <div align="right">
                                    同步类型:</div>
                            </td>
                            <td>
                                <asp:DropDownList ID="selSyncType" CssClass="inputmid" runat="server">
                                </asp:DropDownList>
                            </td>
                            <td>
                                <div align="right">
                                    同步状态:</div>
                            </td>
                            <td>
                                <asp:DropDownList ID="selSyncStates" CssClass="inputmid" runat="server">
                                </asp:DropDownList>
                            </td>
                          
                        </tr>
                         <tr>
                           <td>
                                <div align="right">
                                    同步发起方:</div>
                            </td>
                            <td>
                                <asp:DropDownList ID="selSyncHomes" CssClass="inputmid" runat="server">
                                </asp:DropDownList>
                            </td>
                            <td>
                                <div align="right">
                                    业务处理结果:</div>
                            </td>
                            <td>
                                <asp:DropDownList ID="selTradeStates" CssClass="inputmid" runat="server">
                                </asp:DropDownList>
                            </td>
                            <td width="12%">
                                <div align="right">
                                    开始日期:</div>
                            </td>
                            <td width="12%">
                                <asp:TextBox runat="server" ID="txtFromDate" MaxLength="8" CssClass="inputmid"></asp:TextBox>
                                <ajaxToolkit:CalendarExtender ID="FromDateCalendar" runat="server" TargetControlID="txtFromDate"
                                    Format="yyyyMMdd" />
                            </td>
                           
                        </tr>
                          <tr>
                            <td width="12%">
                                <div align="right">
                                    结束日期:</div>
                            </td>
                            <td width="12%">
                                <asp:TextBox runat="server" ID="txtToDate" MaxLength="8" CssClass="inputmid"></asp:TextBox>
                                <ajaxToolkit:CalendarExtender ID="CalendarExtender2" runat="server" TargetControlID="txtToDate"
                                    Format="yyyyMMdd" />
                            </td>
                            <td colspan="4" align="right">
                                <asp:Button ID="btnQuery" CssClass="button1" runat="server" Text="查询" OnClick="btnQuery_Click"/>
                            </td>
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

                        </td>
                    </tr>
                </table>
                <div id="printarea" class="kuang5">
                    <div style="height: 380px;overflow:auto;">
                        <asp:GridView ID="gvResult" runat="server" Width="195%" CssClass="tab1" HeaderStyle-CssClass="tabbt"
                            FooterStyle-CssClass="tabcon" AlternatingRowStyle-CssClass="tabjg" 
                            SelectedRowStyle-CssClass="tabsel" PagerSettings-Mode="NumericFirstLast" 
                            PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top"
                            AutoGenerateColumns="false" ShowFooter="true" AllowPaging="True"
                            PageSize="20" OnPageIndexChanging="gvResult_PageIndexChanging" >
                            <Columns>
                                <asp:BoundField HeaderText="同步类型" DataField="SYNCTYPECODE" />
                                <asp:BoundField HeaderText="同步状态" DataField="SYNCCODE" />
                                <asp:BoundField HeaderText="同步业务类型" DataField="TRADETYPECODE" />
                                <asp:BoundField HeaderText="业务处理结果" DataField="PROCEDURESYNCCODE" />
                                <asp:BoundField HeaderText="同步发起方" DataField="SYNCHOME" />
                                <asp:BoundField HeaderText="同步接收方" DataField="SYNCCLIENT"  />
                                <asp:BoundField HeaderText="卡号" DataField="CARDNO" />
                                <asp:BoundField HeaderText="社保号" DataField="SOCLSECNO" />
                                <asp:BoundField HeaderText="姓名" DataField="NAME"  />
                                <asp:BoundField HeaderText="证件类型" DataField="PAPERTYPECODE" />
                                <asp:BoundField HeaderText="证件号码" DataField="PAPERNO" />
                                <asp:BoundField HeaderText="出生日期" DataField="BIRTH"  />
                                <asp:BoundField HeaderText="性别" DataField="SEX" />
                                <asp:BoundField HeaderText="电话" DataField="PHONE" />
                                <asp:BoundField HeaderText="邮政编码" DataField="CUSTPOST" />
                                <asp:BoundField HeaderText="联系地址" DataField="ADDR" />
                                <asp:BoundField HeaderText="邮箱" DataField="EMAIL"  />
                                <asp:BoundField HeaderText="同步时间" DataField="LASTSYNCTIME" />
                            </Columns>
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                        <td width="5%">
                                            同步类型
                                        </td>
                                        <td width="5%">
                                            同步状态
                                        </td>
                                          <td width="5%">
                                            同步业务类型
                                        </td>
                                         <td width="5%">
                                            业务处理结果
                                        </td>
                                        <td width="8%">
                                            同步发起方
                                        </td>
                                         <td width="5%">
                                            同步接收方
                                        </td>
                                        <td width="5%">
                                            卡号
                                        </td>
                                        <td width="8%">
                                            社保号
                                        </td>
                                         <td width="5%">
                                            姓名
                                        </td>
                                         <td width="5%">
                                            证件类型
                                        </td>
                                        <td width="5%">
                                            证件号码
                                        </td>
                                        <td width="5%">
                                            出生日期
                                        </td>
                                          <td width="5%">
                                            性别
                                        </td>
                                        <td width="5%">
                                            电话
                                        </td>
                                        <td width="5%">
                                            邮政编码
                                        </td>

                                         <td width="5%">
                                            联系地址
                                        </td>
                                          <td width="5%">
                                            邮箱
                                        </td>
                                        <td width="5%">
                                            同步时间
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

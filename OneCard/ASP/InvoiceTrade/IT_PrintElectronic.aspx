<%@ Page Language="C#" AutoEventWireup="true" CodeFile="IT_PrintElectronic.aspx.cs" Inherits="ASP_InvoiceTrade_IT_PrintElectronic" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>电子开票提取</title>
    <script type="text/javascript" src="../../js/print.js"></script>
    <script type="text/javascript" src="../../js/myext.js"></script>
    <script type="text/javascript" src="../../js/currency.js"></script>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <link href="../../css/invoice.css" rel="stylesheet" type="text/css" />
    <script language="javascript" type="text/javascript">
        function SelectAll(tempControl) {
            //将除头模板中的其它所有的CheckBox取反 

            var theBox = tempControl;
            xState = theBox.checked;

            elem = theBox.form.elements;
            for (i = 0; i < elem.length; i++)
                if (elem[i].type == "checkbox" && elem[i].id != theBox.id) {
                    if (elem[i].checked != xState)
                        elem[i].click();
                }
        }
        function printFaPiao() {
            printdiv('printfapiao');
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
    <div class="tb">
        发票 -> 电子开票提取</div>
    <ajaxToolkit:ToolkitScriptManager runat="Server" EnableScriptGlobalization="true"
        EnableScriptLocalization="true" ID="ScriptManager2" />
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
 
 
    <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
            <!-- #include file="../../ErrorMsg.inc" -->
             <%--<aspControls:PrintHMXXPingZheng ID="ptnPingZheng" runat="server" PrintArea="ptnPingZheng1" />--%>
             <aspControls:PrintElectronicFaPiao ID="ptnFaPiao" runat="server" PrintArea="printfapiao" />
            <asp:HiddenField ID="hidPrinted" Value="false" runat="server" />
            <div class="con">
                <div class="card">
                    查询条件</div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td width="7%">
                                <div align="right">
                                   起始卡号：</div>
                            </td>
                            <td width="15%">
                                <asp:TextBox ID="txtBeginCardNo" CssClass="input" runat="server" MaxLength="19"></asp:TextBox>
                            </td>
                            <td width="7%">
                                <div align="right">
                                    终止卡号：
                                </div>
                            </td>
                            <td width="15%">
                                <asp:TextBox ID="txtEndCardNo" CssClass="input" runat="server" MaxLength="19"></asp:TextBox>
                            </td>
                            <td width="7%">
                                <div align="right">
                                    部门:</div>
                            </td>
                            <td width="15%">
                                <asp:DropDownList ID="selDept" CssClass="input" runat="server" AutoPostBack="true"
                                 OnSelectedIndexChanged="selDept_Changed" >
                                </asp:DropDownList>
                            </td>
                            <td width="7%">
                                <div align="right">
                                    员工:</div>
                            </td>
                            <td width="15%">
                                <asp:DropDownList ID="selStaff" CssClass="input" runat="server">
                                </asp:DropDownList>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    业务类型：
                                </div>
                            </td>
                            <td>
                                <asp:DropDownList ID="selTradeType"  CssClass="inputmid" runat="server">
                                    <asp:ListItem Text="普通充值" Value="1"></asp:ListItem>
                                    <asp:ListItem Text="充值卡售出" Value="2"></asp:ListItem>
                                    <asp:ListItem Text="礼金卡售出" Value="3"></asp:ListItem>
                                    <asp:ListItem Text="代理充值" Value="4"></asp:ListItem>
<%--                                    <asp:ListItem Text="省卡充值" Value="5"></asp:ListItem>--%>
                                    <asp:ListItem Text="手Q充值" Value="5"></asp:ListItem>
                                    <asp:ListItem Text="充值补登" Value="6"></asp:ListItem>
                                    <asp:ListItem Text="读卡器售出" Value="7"></asp:ListItem>
                                    <asp:ListItem Text="售卡" Value="8"></asp:ListItem>
                                    <asp:ListItem Text="休闲开卡" Value="9"></asp:ListItem>
                                    <asp:ListItem Text="省卡充值" Value="10"></asp:ListItem>
                                    <asp:ListItem Text="省卡售卡" Value="11"></asp:ListItem>
                                </asp:DropDownList>
                            </td>
                            <td>
                                <div align="right">
                                    开始日期：</div>
                            </td>
                            <td>
                                <asp:TextBox ID="txtBeginDate" CssClass="input" runat="server" MaxLength="10"></asp:TextBox>
                                <ajaxToolkit:CalendarExtender ID="BeginCalendar" runat="server" TargetControlID="txtBeginDate"
                                    Format="yyyyMMdd" />
                            </td>
                            <td>
                                <div align="right">
                                    结束日期：</div>
                            </td>
                            <td>
                                <asp:TextBox ID="txtEndDate" CssClass="input" runat="server" MaxLength="10"></asp:TextBox>
                                <ajaxToolkit:CalendarExtender ID="EndCalendar" runat="server" TargetControlID="txtEndDate"
                                    Format="yyyyMMdd" />
                            </td>
                            <td align="right">
                            </td>
                            <td align="center">
                                <asp:Button ID="btnQuery" CssClass="button1" OnClick="btnQuery_Click" Text="查询" runat="server" />
                            </td>
                        </tr>
                    </table>
                </div>
                <div class="card">
                    查询结果
                </div>
                <div class="kuang5">
                    <div class="gdtb" style="height: 220px; padding: 5px 0 0 0;">
                        <asp:GridView ID="lvwInvoice" runat="server" Width="100%"  CssClass="tab1" HeaderStyle-CssClass="tabbt"
                            AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel" AllowPaging="True"
                            PageSize="200" OnPageIndexChanging="lvwInvoice_Page" PagerSettings-Mode="NumericFirstLast"
                            PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top" AutoGenerateColumns="False"
                            OnSelectedIndexChanged="lvwInvoice_SelectedIndexChanged" OnRowCreated="lvwInvoice_RowCreated">
                            <Columns>
                            <asp:TemplateField>
                                <HeaderTemplate>
                                    <asp:CheckBox ID="CheckBox1" runat="server"  runat="server" onclick="javascript:SelectAll(this);"  />
                                </HeaderTemplate>
                                <ItemTemplate>
                                    <asp:CheckBox ID="ItemCheckBox" runat="server" />
                                </ItemTemplate>
                             </asp:TemplateField>
                                <asp:BoundField DataField="TRADEID" HeaderText="交易流水号" />
                                <asp:BoundField DataField="CARDNO"  HeaderText="卡号(段)" />
                                <asp:BoundField DataField="TRADETYPE" HeaderText="业务类型" />
                                <asp:BoundField DataField="CURRENTMONEY" HeaderText="交易金额" />
                                <asp:BoundField DataField="OPERATESTAFFNO" HeaderText="操作员工" />
                                <asp:BoundField DataField="DEPARTNO" HeaderText="操作部门" />
                                <asp:BoundField DataField="OPERATETIME" HeaderText="操作时间" />
                                <asp:BoundField DataField="VOLUMENO" HeaderText="发票代码" />
                                <asp:BoundField DataField="INVOICENO" HeaderText="发票号码" />

                            </Columns>
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                        <td>
                                            交易流水号
                                        </td>
                                        <td>
                                            卡号(段)
                                        </td>
                                        <td>
                                            业务类型
                                        </td>
                                        <td>
                                            交易金额
                                        </td>
                                        <td>
                                            操作员工
                                        </td>
                                        <td>
                                            操作部门
                                        </td>
                                        <td>
                                            操作时间
                                        </td>
                                        <td>
                                            发票代码
                                        </td>
                                        <td>
                                            发票号码
                                        </td>
                                        <td>
                                        </td>
                                    </tr>
                                </table>
                            </EmptyDataTemplate>
                        </asp:GridView>
                    </div>
                </div>
                <div class="card">
                    开票项目名称</div>
                <div class="kuang5">
                    <table>
                        <tr>
                            <td width="10%">
                                <div align="left">
                                    项目名称：</div>
                            </td>
                            <td width="30%" align="left" >
                                 <asp:DropDownList ID="ddlProjName" CssClass="inputlong" runat="server"  Enabled="false"/>
                                
                            </td>
                            <td width="10%">
                                <div align="left">
                                    项目内容：</div>
                            </td>
                            <td width="30%" align="left" >
                                <div align="left">
                                <asp:DropDownList ID="selProj1" CssClass="inputmid" runat="server">
                                <asp:ListItem Text="---请选择---" Value=""></asp:ListItem>
                                     <asp:ListItem Text="1:充值" Value="充值"></asp:ListItem>
                                     <asp:ListItem Text="2:交通费" Value="交通费"></asp:ListItem>
                                     <asp:ListItem Text="3:福利费" Value="福利费"></asp:ListItem>
                                     <asp:ListItem Text="4:通讯费" Value="通讯费"></asp:ListItem>
                                     <asp:ListItem Text="5:宣传费" Value="宣传费"></asp:ListItem>
                                </asp:DropDownList>
                            </div>
                            </td>
                            
                        </tr>
                    </table>
                    
                </div>
                 <div class="card">
                    附注：</div>
                <div class="kuang5">
                    <table>
                        <tr>
                            <td width="10%">
                                <div align="left">
                                    附注：</div>
                            </td>
                            <td width="80%" align="left" colspan="8">
                                <asp:TextBox ID="txtRemark" CssClass="inputlong" runat="server" MaxLength="50"></asp:TextBox>
                               <%-- <span class="red" runat="server" id="spnGroup">*</span> --%>
                            </td>
                            
                        </tr>
                    </table>
                </div>
                 <div class="btns">
                 <asp:LinkButton runat="server" ID="linkQRbtn" OnClick="btnQR_Click" />
                <table width="100%" border="0" align="right" cellpadding="0" cellspacing="0">
                    <tr>
                   <td>业务为充值类年卡类的属于不征税，项目名称为*预付卡销售*；如：普通充值、充值卡、礼金卡、各类代理充值，所有年卡类也归于此类。</td>

                 
                  
                        <td rowspan="2">
                            <asp:Button ID="btnPrintFaPiao" runat="server" Text="打印发票提取码" CssClass="button1" OnClick="btnQR_Click" Width="100px" />
                        </td>
                        
                    </tr>
                   <tr>
						<td>业务为售卡类的按17%增值税收取，项目名称为*软件*苏州市民卡卡片业务系统软件V1.0。如各类售卡、读卡器出售等。</td>
					  </tr>

               
                </table>

                
            </div>
            
            <asp:HiddenField runat="server" ID="hidStaffno" />
            <asp:HiddenField runat="server" ID="hidMessage" />
            
            
            <div id="PrintArea"  style="display: none">
                    <p>电子发票二维码</p>
                        <div id="divImg" class="juedui">
                            <img  src="" alt="" runat="server" id="imgPrint" width="150" height="150"/>
                            
                        </div>
                
                    </div>
                
           
            
            </div>
        </ContentTemplate>
       
    </asp:UpdatePanel>
    </form>
</body>
</html>

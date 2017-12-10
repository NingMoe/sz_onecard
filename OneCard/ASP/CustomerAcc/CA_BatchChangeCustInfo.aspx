<%@ Page Language="C#" AutoEventWireup="true" CodeFile="CA_BatchChangeCustInfo.aspx.cs" Inherits="ASP_CustomerAcc_CA_BatchChangeCustInfo" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
     <title>批量修改账户资料</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <link  href="../../css/Cust_AS.css" rel="stylesheet" type="text/css" />
</head>
<body>
  <form id="form1" runat="server">
        <table border="0" cellpadding="0" cellspacing="0" width="100%">
             <td class="cust_left"></td>
             <td class="cust_mid">专有账户>批量修改账户资料</td>
             <td class="cust_right"></td>
        </table>
        <ajaxToolkit:ToolkitScriptManager EnableScriptGlobalization="true" EnableScriptLocalization="true"
            ID="ScriptManager1" runat="server" />
        <asp:UpdatePanel ID="UpdatePanel1" UpdateMode="Conditional" runat="server">
            <ContentTemplate>
                <asp:BulletedList ID="bulMsgShow" runat="server" />

                <script runat="server">public override void ErrorMsgShow() { ErrorMsgHelper(bulMsgShow); }</script>
                <div class="cust_tabbox">
	                <table border="0" cellpadding="0" cellspacing="0" width="100%">
    	                <td class="cust_top1_l"><div class="cust_p7"></div></td>
                        <td class="cust_top1_m"><span style="line-height:22px; margin-left:5px; color:#333;">批量修改账户资料</span></td>
                        <td class="cust_top1_r"></td>
                    </table>
                    <div class="cust_line1"></div>
                    <div class="cust_line2"></div>
                    <table width="100%" border="0" cellpadding="0" cellspacing="0" class="cust_form">
                            <tr>
                                <th style="width:10%">
                                        导入文件：
                                </th>
                                <td style="width:90%">
                                    <asp:FileUpload ID="FileUpload1" style="float:left;" runat="server" CssClass="inputlong" Width="250px" />
                                    <div class="cust_bton2 cust_btonSpec"><asp:LinkButton ID="btnUpload"  runat="server" Text="导入" OnClick="btnUpload_Click" /></div>
                                </td>
                            </tr>
                    </table>
                </div>
                <div class="cust_tabbox">
    	            <table border="0" cellpadding="0" cellspacing="0" width="100%">
    	            <td class="cust_top1_l"><div class="cust_p3"></div></td>
                    <td class="cust_top1_m"><span style="line-height:22px; margin-left:5px; color:#333;">客户信息</span></td>
                    <td class="cust_top1_r"></td>
                    </table>
                    <div class="cust_line1"></div>
                    <div class="cust_line2"></div>
                    <table width="100%" border="0" cellpadding="0" cellspacing="0">
                            <tr>
                                <td>
                                    <div class="gdtb" style="height: 310px">
                                        <asp:GridView ID="gvResult" runat="server" Width="100%" CssClass="tab1" HeaderStyle-CssClass="tabbt"
                                            AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel" AllowPaging="false"
                                            PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top"
                                            AutoGenerateColumns="False" OnRowDataBound="gvResult_RowDataBound" DataKeyNames="RESULT1">
                                            <Columns>
                                                <asp:BoundField HeaderText="校验结果" ItemStyle-Width="200px" DataField="ValidRet" />
                                                <asp:BoundField HeaderText="卡号" DataField="CardNo" />
                                                <asp:BoundField HeaderText="姓名" DataField="CustName" />
                                                <asp:BoundField HeaderText="性别" DataField="CustSex" />
                                                <asp:BoundField HeaderText="出生日期" DataField="CustBirth" />
                                                <asp:BoundField HeaderText="证件类型" DataField="PaperType" />
                                                <asp:BoundField HeaderText="证件号码" DataField="PaperNo" />
                                                <asp:BoundField HeaderText="联系地址" DataField="CustAddr" />
                                                <asp:BoundField HeaderText="邮政编码" DataField="CustPost" />
                                                 <asp:BoundField HeaderText="手机" DataField="CUSTPHONE" />
                                                <asp:BoundField HeaderText="固话" DataField="CUSTTEL" />
                                                <asp:BoundField HeaderText="电子邮件" DataField="CustEmail" />
                                            </Columns>
                                            <EmptyDataTemplate>
                                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                                    <tr class="tabbt">
                                                        <td>
                                                            校验结果</td>
                                                        <td>
                                                            卡号</td>
                                                        <td>
                                                            姓名</td>
                                                        <td>
                                                            性别</td>
                                                        <td>
                                                            出生日期</td>
                                                        <td>
                                                            证件类型</td>
                                                        <td>
                                                            证件号码</td>
                                                        <td>
                                                            联系地址</td>
                                                        <td>
                                                            邮政编码</td>
                                                         <td>
                                                            手机
                                                        </td><td>
                                                            固话
                                                        </td>
                                                        <td>
                                                            电子邮件</td>
                                                    </tr>
                                                </table>
                                            </EmptyDataTemplate>
                                        </asp:GridView>
                                    </div>
                                </td>
                            </tr>
                    </table>
                </div>
                <div class="cust_tabbox">
                    <div class="cust_bottom_bton">
                        <asp:LinkButton ID="btnSubmit" Enabled="false" runat="server" Text="提交"
                               OnClientClick="return confirm('确认提交?');"     OnClick="btnSubmit_Click" />
                    </div>
                </div>
            </ContentTemplate>
            <Triggers>
                <asp:PostBackTrigger ControlID="btnUpload" />
            </Triggers>
        </asp:UpdatePanel>
    </form>
</body>
</html>
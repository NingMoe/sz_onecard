<%@ Page Language="C#" EnableEventValidation="false" AutoEventWireup="true" CodeFile="GC_SubmissionRollBack.aspx.cs" Inherits="ASP_GroupCard_GC_SubmissionRollBack" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>确认领卡返销</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="../../js/printorder.js"></script>
    <script type="text/javascript" src="../../js/myext.js"></script>
    <script type="text/javascript" src="../../js/jquery-1.5.min.js"></script>
    <script type="text/javascript" src="../../js/Window.js"></script>
    <script type="text/javascript">

    </script>
    <style type="text/css">
        table.data
        {
            font-size: 90%;
            border-collapse: collapse;
            border: 0px solid black;
        }
        table.data th
        {
            background: #bddeff;
            width: 25em;
            text-align: left;
            padding-right: 8px;
            font-weight: normal;
            border: 1px solid black;
        }
        table.data td
        {
            background: #ffffff;
            vertical-align: middle;
            padding: 0px 2px 0px 2px;
            border: 1px solid black;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
    <div class="tb">
        确认领卡返销
    </div>
    <ajaxToolkit:ToolkitScriptManager EnableScriptGlobalization="true" EnableScriptLocalization="true"
        ID="ScriptManager1" runat="server" />
    <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
            <asp:BulletedList ID="bulMsgShow" runat="server" />
            <script runat="server">public override void ErrorMsgShow() { ErrorMsgHelper(bulMsgShow); }</script>
            <div class="con">
                <div class="base">
                    确认领卡返销</div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td width="10%">
                                <div align="right">
                                    单位名称:</div>
                            </td>
                            <td width="8%">
                                <asp:TextBox ID="txtCompany" CssClass="inputmid" runat="server" AutoPostBack="true"
                                    OnTextChanged="queryCompany"></asp:TextBox>
                            </td>
                            <td  colspan="2">
                                <asp:DropDownList ID="selCompany" CssClass="inputmid" Width="206" runat="server">
                                </asp:DropDownList>
                            </td>
                            <td width="10%">
                                <div align="right">
                                    联系人:</div>
                            </td>
                            <td width="8%">
                                <asp:TextBox ID="txtName" CssClass="input" runat="server"></asp:TextBox>
                            </td>
                            <td width="10%">
                                <div align="right">
                                   部门:</div>
                            </td>
                            <td width="8%">
                               <asp:DropDownList ID="selDept" CssClass="inputmid" runat="server">
                                </asp:DropDownList>
                            </td>

                        </tr>
                        <tr>
                           <td width="8%">
                                <div align="right">
                                   经办人:</div>
                            </td>
                            <td style="width: 150px;">
                               <asp:DropDownList ID="selStaff" CssClass="inputmid" runat="server">
                                </asp:DropDownList>
                            </td>
                            <td width="8%">
                                <div align="right">
                                    金额:</div>
                            </td>
                            <td width="5%">
                               
                                <asp:TextBox ID="txtTotalMoney" CssClass="input" runat="server"></asp:TextBox>
                            </td>
                            <td width="8%">
                                <div align="right">
                                    开始日期:</div>
                            </td>
                            <td width="8%">
                    
                                <asp:TextBox runat="server" ID="txtFromDate" MaxLength="8" CssClass="input"></asp:TextBox>
                                <ajaxToolkit:CalendarExtender ID="CalendarExtender1" runat="server" TargetControlID="txtFromDate"
                                    Format="yyyyMMdd" />
                            </td>
                            <td width="8%">
                                <div align="right">
                                    结束日期:</div>
                            </td>
                            <td width="8%">
                                 <asp:TextBox runat="server" ID="txtToDate" MaxLength="8" CssClass="input"></asp:TextBox>
                                <ajaxToolkit:CalendarExtender ID="CalendarExtender2" runat="server" TargetControlID="txtToDate"
                                    Format="yyyyMMdd" />
                            </td>
                            
                        </tr>
                        <tr>
                        <td colspan="7"></td>
                        <td width="2%">
                                <asp:Button runat="server" CssClass="button1" ID="Button1" Text="查询" onclick="btnQuery_Click" />
                            </td>
                        </tr>
                        
                        
                    </table>
                </div>
                <table border="0" width="95%">
                    <tr>
                        <td align="left">
                            <div class="jieguo">
                                订单列表</div>
                        </td>
                        
                    </tr>
                </table>
                <div class="kuang5">
                    <asp:GridView ID="gvOrderList" CssClass="tab2" HeaderStyle-CssClass="tabbt" FooterStyle-CssClass="tabcon"
                        AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel" PagerSettings-Mode="NumericFirstLast"
                        PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top" runat="server"
                        AutoGenerateColumns="false" Width="100%"
                        OnRowCreated="gvOrderList_RowCreated" 
                        OnSelectedIndexChanged="gvOrderList_SelectedIndexChanged">
                        <Columns>
                            <asp:BoundField DataField="orderno" HeaderText="订单号" />
                            <asp:BoundField DataField="groupname" HeaderText="单位名称" />
                            <asp:BoundField DataField="name" HeaderText="联系人" />
                            <asp:BoundField DataField="idcardno" HeaderText="身份证号码" />
                            <asp:BoundField DataField="phone" HeaderText="联系电话" />
                            <asp:BoundField DataField="totalmoney" HeaderText="购卡总金额(元)" />
                            <asp:BoundField DataField="transactor" HeaderText="经办人" />
                            <asp:BoundField DataField="inputtime" HeaderText="录入时间" />
                            <asp:BoundField DataField="ORDERSTATE" HeaderText="订单状态" />
                        </Columns>
                    </asp:GridView>
                </div>
                </div>
                <div class="con">
                <div class="jieguo">
                    详细信息</div>
                <div class="kuang5" runat="server" id="divInfo">
                </div>
            </div>
         <div class="btns">        
          <table width="95%" border="0"cellpadding="0" cellspacing="0">
            <tr>
               <td width="80%">&nbsp;</td>
               <td align="right"><asp:Button ID="btnRollBack"  CssClass="button1" Text="返销" runat="server" onclick="btnRollBack_Click" /></td>
            </tr>
          </table>
         </div>
     </ContentTemplate>
    </asp:UpdatePanel>
    </form>
</body>
</html>

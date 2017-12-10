<%@ Page Language="C#" AutoEventWireup="true" CodeFile="GC_GetCardRelation.aspx.cs" Inherits="ASP_GroupCard_GC_GetCardRelation" 
EnableEventValidation="false"%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>领卡补关联</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="../../js/printorder.js"></script>
    <script type="text/javascript" src="../../js/myext.js"></script>
    <script type="text/javascript" src="../../js/mootools.js"></script>
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
            border: 0px solid black;
        }
    </style>
    <script type="text/javascript">
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
           
            function SumNum() {
                var table = document.getElementById('gvSZTCard');
                var tr = table.getElementsByTagName("tr");
                var total = 0;
                for (i = 1; i < tr.length; i++) {
                    var FromCardno = tr[i].getElementsByTagName("td")[0].getElementsByTagName("input")[0].value;
                    var EndCardno = tr[i].getElementsByTagName("td")[0].getElementsByTagName("input")[1].value;
                    var sFCard = FromCardno.substr(8, 8);
                    var sECard = EndCardno.substr(8, 8);
                    var lCardSum = 0;

                    if (sFCard != '' && sECard != '') {
                        var lFCard = sFCard.toInt();
                        var lECard = sECard.toInt();
                        if (lECard - lFCard >= 0)
                            lCardSum = lECard - lFCard + 1;
                    }

                    tr[i].getElementsByTagName("td")[1].getElementsByTagName("input")[0].value = lCardSum;
                }
            }
            function SumCashNum() {
                var table = document.getElementById('gvCashGiftCard2');
                var tr = table.getElementsByTagName("tr");
                var total = 0;
                for (i = 1; i < tr.length; i++) {
                    var FromCardno = tr[i].getElementsByTagName("td")[0].getElementsByTagName("input")[0].value;
                    var EndCardno = tr[i].getElementsByTagName("td")[0].getElementsByTagName("input")[1].value;
                    var sFCard = FromCardno.substr(8, 8);
                    var sECard = EndCardno.substr(8, 8);
                    var lCardSum = 0;

                    if (sFCard != '' && sECard != '') {
                        var lFCard = sFCard.toInt();
                        var lECard = sECard.toInt();
                        if (lECard - lFCard >= 0)
                            lCardSum = lECard - lFCard + 1;
                    }

                    tr[i].getElementsByTagName("td")[1].getElementsByTagName("input")[0].value = lCardSum;
                }
            }
       </script>
</head>
<body>
    <form id="form1" runat="server">
    <div class="tb">
        领卡补关联
    </div>
    <ajaxToolkit:ToolkitScriptManager EnableScriptGlobalization="true" EnableScriptLocalization="true"
        ID="ScriptManager1" runat="server" />
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
            <asp:BulletedList ID="bulMsgShow" runat="server" />
            <script runat="server">public override void ErrorMsgShow() { ErrorMsgHelper(bulMsgShow); }</script>
            <asp:HiddenField ID="showCashGiftCard" runat="server" />
            <asp:HiddenField ID="hidCashValue" runat="server" />
            <asp:HiddenField ID="hidCashLeftNum" runat="server" />
            <asp:HiddenField ID="showSZTCard" runat="server" />
            <asp:HiddenField ID="hidSZTCardType" runat="server" />
            <asp:HiddenField ID="hidSZTValue" runat="server" />
            <asp:HiddenField ID="hidSZTLeftNum" runat="server" />
            <asp:HiddenField ID="hidIsCompleted" runat="server" />
            <div class="con">
                <div class="base">
                    订单查询</div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td width="8%">
                                <div align="right">
                                    订单号:</div>
                            </td>
                            <td width="10%" >
                                <asp:TextBox ID="txtOrderNo" CssClass="inputmid" runat="server"></asp:TextBox>
                            </td>
                            <td width="8%">
                                <div align="right">
                                    单位名称:</div>
                            </td>
                            <td width="10%" >
                                <asp:TextBox ID="txtGroupName" CssClass ="inputmid" MaxLength="100" runat="server" ></asp:TextBox>
                                
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
                            
                            <td width="8%">
                                <div align="right">
                                    制卡部门:</div>
                            </td>
                            <td width="8%">
                                <asp:DropDownList ID="selMakeDept" CssClass="inputmid" runat="server" AutoPostBack="true"
                                    OnSelectedIndexChanged="selMakeDept_Changed" >
                                </asp:DropDownList>
                            </td>
                            <td width="8%">
                                <div align="right">
                                    制卡员工:</div>
                            </td>
                            <td width="8%">
                                <asp:DropDownList ID="selMakeOperator" CssClass="inputmid" runat="server"  >
                                </asp:DropDownList>
                            </td>                            
                        </tr>
                        
                        <tr>
                            <td colspan="8" align="right">
                                <asp:Button runat="server" CssClass="button1" ID="btnQuery" Text="查询" OnClick="btnQuery_Click" />
                            </td>
                        </tr>
                    </table>
                </div>
                <table border="0" width="95%"   >
                    <tr>
                        <td align="left" >
                            <div class="jieguo">
                                订单列表</div>
                        </td>
                        
                    </tr>
                </table>
                <div class="kuang5">
                    <div class="gvUseCard" style="height: 170px; overflow: auto; display: block">
                        <asp:GridView ID="gvOrderList" CssClass="tab2" HeaderStyle-CssClass="tabbt" FooterStyle-CssClass="tabcon"
                            AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel" PagerSettings-Mode="NumericFirstLast"
                            PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top" runat="server"
                            AutoGenerateColumns="false" Width="150%" OnRowCreated="gvOrderList_RowCreated"
                            AllowPaging="true" PageSize="5" OnPageIndexChanging="gvOrderList_Page" OnSelectedIndexChanged="gvOrderList_SelectedIndexChanged" >
                            <Columns>
                               
                                <asp:BoundField DataField="ORDERNO" HeaderText="订单号" />
                                <asp:BoundField DataField="GROUPNAME" HeaderText="单位名称" />
                                <asp:BoundField DataField="NAME" HeaderText="联系人" />
                                <asp:BoundField DataField="IDCARDNO" HeaderText="身份证号码" />
                                <asp:BoundField DataField="PHONE" HeaderText="联系电话" />
                                <asp:BoundField DataField="totalmoney" HeaderText="购卡总金额(元)" />
                                <asp:BoundField DataField="transactor" HeaderText="经办人" />
                                <asp:BoundField DataField="inputtime" HeaderText="录入时间" />
                                <asp:BoundField DataField="orderstate" HeaderText="订单状态" />
   
                            </Columns>
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                        <td>
                                            订单号
                                        </td>
                                        <td>
                                            单位名称
                                        </td>
                                        <td>
                                            联系人
                                        </td>
                                        <td>
                                            身份证号码
                                        </td>
                                        <td>
                                            联系电话
                                        </td>
                                        <td>
                                            购卡总金额(元)
                                        </td>
                                        <td>
                                            经办人
                                        </td>
                                        <td>
                                            录入时间
                                        </td>
                                        <td>
                                            订单状态
                                        </td>
                                                                             
                                    </tr>
                                </table>
                            </EmptyDataTemplate>
                        </asp:GridView>
                    </div>
                    <div id="RoleWindow" style="width: 910px; position: absolute; display: none; z-index: 999;">
                    </div>
                </div>
                <div class="jieguo" id="divDetail" runat="server" >
                    详情</div>
                 <div class="kuang5" runat="server" id="divInfo" >
                 
                </div>
                <div id="makeCashGiftCard"  runat = "server">
                    <div>
                        <table border="0" width="95%">
                            <tr>
                                <td align="left" width="100px">
                                    <div class="card">
                                        利金卡</div>
                                </td>
                              
                        </table>
                    </div>
                    <div class="kuang5">
                        <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                        <td width="8%">
                                <div align="right">
                                    售卡部门:</div>
                            </td>
                            <td width="8%">
                                <asp:DropDownList ID="ddlSaleDept" CssClass="inputmid" runat="server" AutoPostBack="true"
                                    OnSelectedIndexChanged="ddlSaleDept_Changed" >
                                </asp:DropDownList>
                            </td>
                            <td width="8%">
                                <div align="right">
                                    售卡员工:</div>
                            </td>
                            <td width="8%">
                                <asp:DropDownList ID="ddlSaleStaff" CssClass="inputmid" runat="server"  >
                                </asp:DropDownList>
                            </td>               
                            
                            
                            <td width="8%">
                                <div align="right">
                                    开始日期:</div>
                            </td>
                            <td width="8%">
                                <asp:TextBox runat="server" ID="txtSaleFromDate" MaxLength="8" CssClass="input"></asp:TextBox>
                                <ajaxToolkit:CalendarExtender ID="CalendarExtender3" runat="server" TargetControlID="txtSaleFromDate"
                                    Format="yyyyMMdd" />
                            </td>
                            <td width="8%">
                                <div align="right">
                                    结束日期:</div>
                            </td>
                            <td width="8%">
                                <asp:TextBox runat="server" ID="txtSaleToDate" MaxLength="8" CssClass="input"></asp:TextBox>
                                <ajaxToolkit:CalendarExtender ID="CalendarExtender4" runat="server" TargetControlID="txtSaleToDate"
                                    Format="yyyyMMdd" />
                            </td>
                        </tr>
                        <tr>
                            <td width="8%">
                                <div align="right">
                                    利金卡面值:</div>
                            </td>
                            <td width="10%" >
                                <asp:TextBox ID="txtCashGiftCardType" CssClass="inputmid" runat="server"></asp:TextBox>
                            </td>
                           
                                         
                        </tr>
                        
                        <tr>
                            <td colspan="8" align="right">
                                <asp:Button runat="server" CssClass="button1" ID="Button1" Text="查询" OnClick="btnCashGiftCardQuery_Click" />
                            </td>
                        </tr>
                    </table>
                                            
                </div>
                <div class="kuang5">
                    <div class="divCashGiftCard" style="height: 350px; overflow: auto; display: block">
                        <asp:GridView ID="gvCashGiftCard" CssClass="tab2" HeaderStyle-CssClass="tabbt" FooterStyle-CssClass="tabcon"
                            AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel" PagerSettings-Mode="NumericFirstLast"
                            PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top" runat="server"
                            AutoGenerateColumns="false" Width="100%"   AllowPaging="true" PageSize="50" OnPageIndexChanging="gvCashGiftCard_Page" >
                            <Columns>
                               <asp:TemplateField>
                                <HeaderTemplate>
                                        <asp:CheckBox ID="CheckBox1" runat="server" onclick="javascript:SelectAll(this);" />
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                        <asp:CheckBox ID="ItemCheckBox" runat="server" />
                                    </ItemTemplate>
                            </asp:TemplateField>
                                <asp:BoundField DataField="cardno" HeaderText="卡号" />
                                <asp:BoundField DataField="salemoney" HeaderText="利金卡面额" />
                                <asp:BoundField DataField="CARDDEPOSITFEE" HeaderText="卡押金" />
                                <asp:BoundField DataField="SUPPLYMONEY" HeaderText="充值金额" />
                                <asp:BoundField DataField="updatestaffno" HeaderText="售卡员工" />
                                <asp:BoundField DataField="selltime" HeaderText="售卡时间" />
   
                            </Columns>
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                        <td>
                                            卡号
                                        </td>
                                        <td>
                                            利金卡面额
                                        </td>
                                        <td>
                                            卡押金
                                        </td>
                                        <td>
                                            充值金额
                                        </td>
                                        
                                        <td>
                                            售卡员工
                                        </td>
                                        <td>
                                            售卡时间
                                        </td>                              
                                    </tr>
                                </table>
                            </EmptyDataTemplate>
                        </asp:GridView>
                    </div>
                    
                  <div class="btns">
                    <div>
                    <table width="100%" border="0" align="right" cellpadding="0" cellspacing="0">
                    <tr>
                        <td width="50%" align="right">
                            <asp:Button ID="btnCashGiftCardMake" CssClass="button1"  runat="server"
                                Text="关联" OnClick="btnCashGiftCardMake_Click" Width="88px" />
                               
                        </td>
                       
                    </tr>
                   </table>
                    </div>
                    </div>  
                </div>
                 <div>
                        <table border="0" width="95%">
                            <tr>
                                <td align="left" width="100px">
                                    <div class="card">
                                        利金卡</div>
                                </td>
<%--                                <td width="50px" style="font-weight: bolder">
                            总计:
                             </td>
                             <td width="300px">
                            <asp:Label ID="Label1" runat="server" Text="0"></asp:Label>
                             </td>--%>
                             <td width="300px"></td>
                                <td>
                                    <asp:Button ID="Button3" CssClass="button1" runat="server" Text="新增" OnClick="btnCashCardAdd_Click" />
                                </td>
                            </tr>
                        </table>
                    </div>
                <div class="kuang5">
                        <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                            <tr>
                                <td width="90%">
                                    <asp:GridView ID="gvCashGiftCard2" CssClass="tab2" HeaderStyle-CssClass="tabbt" FooterStyle-CssClass="tabcon"
                                        AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel" PagerSettings-Mode="NumericFirstLast"
                                        PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top" runat="server"
                                        AutoGenerateColumns="False" OnRowDeleting="gvCashGiftCard2_RowDeleting" OnRowCommand="gvCashGiftCard2_RowCommand">
                                        <Columns>
                                            <asp:TemplateField HeaderText="卡号段">
                                                <ItemTemplate>
                                                    <asp:TextBox ID="txtCashFromCardNo" Style="text-align: center" runat="server" MaxLength="16"
                                                        Text='<%# Bind("CashFromCardNo") %>' onblur='SumCashNum()' ></asp:TextBox>&nbsp;-&nbsp;
                                                    <asp:TextBox ID="txtCashToCardNo" Style="text-align: center" runat="server" MaxLength="16"
                                                        Text='<%# Bind("CashToCardNo") %>' onblur='SumCashNum()'></asp:TextBox>
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                           
                                            <asp:TemplateField HeaderText="购卡数量">
                                                <ItemTemplate>
                                                    <asp:TextBox ID="txtCashCardNum" Style="text-align: center" CssClass="labeltext"
                                                        runat="server" Text='<%# Bind("CashCardNum") %>' ></asp:TextBox>
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                            <asp:TemplateField>
                                                <ItemTemplate>
                                                    <asp:Button ID="btnCashCardDelete" CssClass="button1" runat="server" CommandName="delete"
                                                        CommandArgument="<%#Container.DataItemIndex%>" Text='删除' CausesValidation="False" />
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                        </Columns>
                                    </asp:GridView>
                                </td>
                                <td width="10%" align="center">
                                    <asp:Button ID="Button2" runat="server" CssClass="button1" Text="关 联" OnClick="btnCashCardMake_Click" />
                                </td>
                            </tr>
                        </table>
                    </div>
                
                </div>
                <div id="makeSZTCard"  runat = "server">
                    <div>
                        <table border="0" width="95%">
                            <tr>
                                <td align="left" width="100px">
                                    <div class="card">
                                        市民卡B卡</div>
                                </td>
<%--                                <td width="50px" style="font-weight: bolder">
                            总计:
                             </td>
                             <td width="300px">
                            <asp:Label ID="Label1" runat="server" Text="0"></asp:Label>
                             </td>--%>
                             <td width="300px"></td>
                                <td>
                                    <asp:Button ID="btnSZTCard" CssClass="button1" runat="server" Text="新增" OnClick="btnSZTCardAdd_Click" />
                                </td>
                            </tr>
                        </table>
                    </div>
                    <div class="kuang5">
                        <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                            <tr>
                                <td width="90%">
                                    <asp:GridView ID="gvSZTCard" CssClass="tab2" HeaderStyle-CssClass="tabbt" FooterStyle-CssClass="tabcon"
                                        AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel" PagerSettings-Mode="NumericFirstLast"
                                        PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top" runat="server"
                                        AutoGenerateColumns="False" OnRowDeleting="gvSZTCard_RowDeleting" OnRowCommand="gvSZTCard_RowCommand">
                                        <Columns>
                                            <asp:TemplateField HeaderText="卡号段">
                                                <ItemTemplate>
                                                    <asp:TextBox ID="txtSZTFromCardNo" Style="text-align: center" runat="server" MaxLength="16"
                                                        Text='<%# Bind("FromCardNo") %>' onblur='SumNum()'></asp:TextBox>&nbsp;-&nbsp;
                                                    <asp:TextBox ID="txtSZTToCardNo" Style="text-align: center" runat="server" MaxLength="16"
                                                        Text='<%# Bind("ToCardNo") %>' onblur='SumNum()'></asp:TextBox>
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                            <%--<asp:BoundField DataField="ChargeCardValue" HeaderText="面额" />--%>
                                           <%-- <asp:TemplateField HeaderText="面额">
                                                <ItemTemplate>
                                                    <asp:TextBox ID="txtSZTCardValue" Style="text-align: center" CssClass="labeltext"
                                                        runat="server" Text='<%# Bind("SZTCardValue") %>' ></asp:TextBox>
                                                </ItemTemplate>
                                            </asp:TemplateField>--%>
                                            <%--<asp:BoundField DataField="ChargeCardNum" HeaderText="数量" />--%>
                                            <asp:TemplateField HeaderText="购卡数量">
                                                <ItemTemplate>
                                                    <asp:TextBox ID="txtSZTCardNum" Style="text-align: center" CssClass="labeltext"
                                                        runat="server" Text='<%# Bind("SZTCardNum") %>' ></asp:TextBox>
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                            <asp:TemplateField>
                                                <ItemTemplate>
                                                    <asp:Button ID="btnSZTCardDelete" CssClass="button1" runat="server" CommandName="delete"
                                                        CommandArgument="<%#Container.DataItemIndex%>" Text='删除' CausesValidation="False" />
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                        </Columns>
                                    </asp:GridView>
                                </td>
                                <td width="10%" align="center">
                                    <asp:Button ID="btnSZTCardMake" runat="server" CssClass="button1" Text="关 联" OnClick="btnSZTCardMake_Click" />
                                </td>
                            </tr>
                        </table>
                    </div>
                </div>
                
                
              
            
            
            
         <div class="btns">
                <table width="100%" border="0" align="right" cellpadding="0" cellspacing="0">
                    <tr>
                        <td width="80%" align="right">
                            <%--<asp:Button ID="btnComfirmRelation" CssClass="button1"  runat="server"
                                Text="确认关联" OnClick="btnComfirmRelation_Click" Width="88px" />--%>
                                <asp:Button ID="btnComfirmNotRelation" CssClass="button1"  runat="server"
                                Text="取消补关联" OnClick="btnComfirmNotRelation_Click" Width="88px" />
                        </td>
                       
                    </tr>
                </table>
            </div>   
        </ContentTemplate>
        
    </asp:UpdatePanel>
    </form>
</body>
</html>

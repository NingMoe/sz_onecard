<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PS_TransferDiscount.aspx.cs" Inherits="ASP_PartnerShip_PS_TransferDiscount" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>结算单元优惠维护</title>
    <script type="text/javascript" src="../../js/myext.js"></script>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <script language="javascript" type="text/javascript">
        function stopbackspace() {
            var c = event.keyCode;
            if (c == 8)
                event.returnValue = false;
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
    <div class="tb">
        合作伙伴->结算单元优惠维护</div>
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
    <asp:UpdatePanel ID="UpdatePanel1" runat="server" >
        <ContentTemplate>
            <asp:BulletedList ID="bulMsgShow" runat="server" />
            <script runat="server">public override void ErrorMsgShow() { ErrorMsgHelper(bulMsgShow); }</script>
    
    <div class="con">
        <div class="jieguo">
            查询结算单元信息</div>
        <div class="kuang5">
            <table width="98%" border="0" cellpadding="0" cellspacing="0" class="text25">
                <tr>
                    <td align="right">
                        行业名称:
                    </td>
                    <td>
                        <asp:DropDownList ID="selCalling" CssClass="inputmidder" runat="server" AutoPostBack="true"
                            OnSelectedIndexChanged="selCalling_SelectedIndexChanged">
                        </asp:DropDownList>
                    </td>
                    <td align="right">
                        单位名称:
                    </td>
                    <td>
                        <asp:DropDownList ID="selCorp" CssClass="inputmidder" runat="server" AutoPostBack="true"
                            OnSelectedIndexChanged="selCorp_SelectedIndexChanged">
                        </asp:DropDownList>
                    </td>
                </tr>
                <tr>
                    <td align="right">
                        部门名称:
                    </td>
                    <td>
                        <asp:DropDownList ID="selDepart" CssClass="inputmidder" runat="server" AutoPostBack="true"
                            OnSelectedIndexChanged="selDepart_SelectedIndexChanged">
                        </asp:DropDownList>
                    </td>
                    <td align="right">
                        结算单元:
                    </td>
                    <td>
                        <asp:DropDownList ID="selBalUint" CssClass="inputmidder" runat="server">
                        </asp:DropDownList>
                    </td>
                </tr>
                <tr>
                    <%--<td align="right">
                        审批状态:
                    </td>
                    <td>
                        <asp:DropDownList ID="selAprvState" CssClass="input" runat="server">
                            <asp:ListItem Text="0: 财审通过" Value="0"></asp:ListItem>
                            <asp:ListItem Text="1: 财审作废" Value="1"></asp:ListItem>
                            <asp:ListItem Text="2: 审批通过" Value="2"></asp:ListItem>
                            <asp:ListItem Text="3: 审批作废" Value="3"></asp:ListItem>
                            <asp:ListItem Text="4: 等待审批" Value="4"></asp:ListItem>
                        </asp:DropDownList>
                    </td>--%>
                    <%--<td>
                        <div align="right">
                            商户经理:</div>
                    </td>--%>
                    <td><div align="right">优惠开始日期:</div></td>
                        <td>
                            <asp:TextBox runat="server" ID="txtBeginDate" MaxLength="8" CssClass="input"></asp:TextBox>
                            <ajaxToolkit:CalendarExtender ID="FCalendar1" runat="server" TargetControlID="txtBeginDate" Format="yyyyMMdd" />
                        </td>
                        <td><div align="right">优惠结束日期:</div></td>
                        <td>
                            <asp:TextBox runat="server" ID="txtEndDate" MaxLength="8" CssClass="input"></asp:TextBox>
                            <ajaxToolkit:CalendarExtender ID="FCalendar2" runat="server" TargetControlID="txtEndDate" Format="yyyyMMdd" />
                        </td>
                    <td>
                        <%--<asp:DropDownList ID="selMsgQry" CssClass="input" runat="server" />--%>
                        <%--<asp:UpdatePanel ID="UpdatePanel4" runat="server" RenderMode="Inline">--%>
                            <%--<ContentTemplate>--%>
                                <asp:HiddenField runat="server" ID="hidAprvState" Value="0" />
                                <asp:HiddenField runat="server" ID="hidSeqNo" />
                                <asp:Button ID="btnQuery" runat="server" Text="查询" CssClass="button1" OnClick="btnQuery_Click" />
                           <%-- </ContentTemplate>--%>
                       <%-- </asp:UpdatePanel>--%>
                    </td>
                </tr>
                <tr>
                  <td align="right">
                        优惠方案:
                    </td>
                    <td>
                    <asp:UpdatePanel ID="UpdatePanel4" runat="server" >
                        <ContentTemplate>
                        <asp:DropDownList ID="selHasDiscount" CssClass="inputmidder" runat="server">
                            <asp:ListItem Text="0: 未创建优惠方案" Value="0"></asp:ListItem>
                            <asp:ListItem Text="1: 已创建优惠方案" Value="1"></asp:ListItem>
                            
                        </asp:DropDownList>
                        </ContentTemplate>
                            </asp:UpdatePanel>
                    </td>
                </tr>
            </table>
            <div class="gdtb" style="height: 160px">
                        <asp:GridView ID="lvwBalUnits" runat="server" CssClass="tab1" Width="120%" HeaderStyle-CssClass="tabbt"
                            AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel" AllowPaging="True"
                            PageSize="1000" PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="Left"
                            PagerStyle-VerticalAlign="Top" AutoGenerateColumns="False" OnPageIndexChanging="lvwBalUnits_Page"
                            OnSelectedIndexChanged="lvwBalUnits_SelectedIndexChanged" OnRowCreated="lvwBalUnits_RowCreated"
                            EmptyDataText="没有数据记录!">
                            <Columns>
                                <asp:BoundField DataField="ROWNUM" HeaderText="#" />
                                <asp:TemplateField HeaderText="有效标志">
                                    <ItemTemplate>
                                        <asp:Label ID="labUseTag" Text='<%# Eval("USETAG").ToString() == "1" ? "有效" : Eval("USETAG").ToString() == "0" ? "无效" : Eval("USETAG").ToString()%>'
                                            runat="server"></asp:Label>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField DataField="DISCOUNT" HeaderText="优惠折扣" />
                                <asp:BoundField DataField="preferentialupper" HeaderText="优惠上限" />
                                <asp:BoundField DataField="special" HeaderText="是否支持补助消费" />
                                <asp:BoundField DataField="begindate" HeaderText="优惠开始时间" />
                                <asp:BoundField DataField="enddate" HeaderText="优惠结束时间" />
                                <asp:BoundField DataField="balunittypename" HeaderText="商户类别" />
                                <asp:BoundField DataField="NAME" HeaderText="佣金方案" />
                                <asp:BoundField DataField="BALUNITNO" HeaderText="结算单元编码" />
                                <asp:BoundField DataField="BALUNIT" HeaderText="结算单元名称" />
                                <asp:BoundField DataField="BALUNITTYPE" HeaderText="单元类型" />
                                <asp:BoundField DataField="CHANNELNAME" HeaderText="结算通道" />
                                <asp:BoundField DataField="CREATETIME" HeaderText="合作时间" DataFormatString="{0:yyyy-MM-dd}"
                                    HtmlEncode="false" />
                                <asp:BoundField DataField="CALLINGNAME" HeaderText="行业" />
                                <asp:BoundField DataField="CORPNAME" HeaderText="单位" />
                                <asp:BoundField DataField="DEPARTNAME" HeaderText="部门" />
                                <%--<asp:BoundField DataField="BANKNAME" HeaderText="开户银行" />
                                <asp:BoundField DataField="BANKACCNO" HeaderText="银行帐号" />--%>
                               <%-- <asp:BoundField DataField="SERMANAGER" HeaderText="商户经理" />--%>

                            </Columns>
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                        <td>
                                            #
                                        </td>
                                        <td>
                                            有效标志
                                        </td>
                                        <td>
                                            优惠折扣
                                        </td>
                                        <td>
                                            优惠上限
                                        </td>
                                        <td>
                                            是否支持补助消费
                                        </td>
                                        <td>
                                            优惠开始时间
                                        </td>
                                        <td>
                                            优惠结束时间
                                        </td>
                                        <td>商户类别</td>
                                        <td>佣金方案</td>
                                        <td>
                                            结算单元编码
                                        </td>
                                        <td>
                                            结算单元名称
                                        </td>
                                        <td>
                                            单元类型
                                        </td>
                                        <td>
                                            结算通道
                                        </td>
                                        <td>
                                            来源识别类型
                                        </td>
                                        <td>
                                            合作时间
                                        </td>
                                        <td>
                                            行业
                                        </td>
                                        <td>
                                            单位
                                        </td>
                                        <td>
                                            部门
                                        </td>
                                        <%--<td>
                                            开户银行
                                        </td>
                                        <td>
                                            银行帐号
                                        </td>--%>
                                        <%--<td>
                                            商户经理
                                        </td>--%>
                                        
                                    </tr>
                                </table>
                            </EmptyDataTemplate>
                        </asp:GridView>
            </div>
        </div>
        <div class="jieguo">
            结算单元优惠信息</div>
            <div class="con">

                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td width="10%">
                                <div align="right">
                                    优惠编码:</div>
                            </td>
                            <td width="20%">
                                <asp:DropDownList ID="selDiscount" CssClass="inputmidder" runat="server" >
                                </asp:DropDownList>
                            </td> 
                            <td width="10%">
                                <div align="right">
                                    优惠上限:</div>
                            </td> 
                            <td width="20%">
                                <asp:TextBox ID="txtMax" CssClass="inputmid" MaxLength="20" runat="server"></asp:TextBox>元
                            </td> 
                            <td width="10%">
                                <div align="right">
                                    佣金方案:</div>
                            </td>
                            <td width="20%">
                                <asp:DropDownList ID="selComScheme" CssClass="inputmidder" runat="server">
                                </asp:DropDownList>
                            </td> 
                                                  
                        </tr>
                        <tr>
                        <td >
                                <div align="right">
                                    优惠开始日期:</div>
                            </td>
                            <td >
                                <asp:TextBox runat="server" ID="txtFromDate" MaxLength="8" CssClass="input"></asp:TextBox>
                                <ajaxToolkit:CalendarExtender ID="CalendarExtender1" runat="server" TargetControlID="txtFromDate"
                                    Format="yyyyMMdd" />
                            </td>
                            <td >
                                <div align="right">
                                    优惠结束日期:</div>
                            </td>
                            <td >
                                <asp:TextBox runat="server" ID="txtToDate" MaxLength="8" CssClass="input"></asp:TextBox>
                                <ajaxToolkit:CalendarExtender ID="CalendarExtender2" runat="server" TargetControlID="txtToDate"
                                    Format="yyyyMMdd" />
                            </td>
                            <td>
                            </td>
                            <td> 
                               <asp:CheckBox ID="isSpecial" runat="server" />支持补助消费
                            </td> 
                            </tr>
                            <tr>
                            <td >
                                <div align="right">
                                    商户等级:</div>
                            </td>
                            <td colspan="5">
                            <asp:CheckBoxList ID="cblType" runat="server" RepeatDirection="Horizontal" RepeatColumns="8"  CellSpacing="15">
                            </asp:CheckBoxList>
                            </td>
                             
                            </tr>
                            
                            
                                               
                    </table>
                    
                    
            </div>
            </div>
            
            <%-- <div class="footall"></div>--%>
            <div class="btns">
                <table width="95%" border="0" align="right" cellpadding="0" cellspacing="0" >
                    <tr>
                    <td width="80%">&nbsp;</td>
                        <td align="right">
                            <asp:Button ID="btnAdd" runat="server" Text="增加" CssClass="button1" OnClick="btnAdd_Click" />
                        </td>
                        <td align="right">
                            <asp:Button ID="btnModify" runat="server" Text="修改" Enabled="false" CssClass="button1"
                                OnClick="btnModify_Click" />
                        </td>
                        <td align="right">
                           <asp:Button ID="btnDelete" runat="server" Text="删除" CssClass="button1" OnClick="btnDelete_Click" />
                        </td>
                    </tr>
                </table>
            </div>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
    
    
    </form>
</body>
</html>

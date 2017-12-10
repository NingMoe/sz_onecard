<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PS_UnitInfoChange.aspx.cs"
    Inherits="ASP_PartnerShip_PS_UnitInfoChange" EnableEventValidation="false" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>商户资料维护</title>
   <%-- <link rel="stylesheet" type="text/css" href="../../css/frame.css" />--%>
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <script language="javascript" type="text/javascript">
            function stopbackspace() {
                var c = event.keyCode;
                if (c == 8)
                    event.returnValue = false;
            }
    </script>
    <style type="text/css">
        .style1
        {
            height: 25px;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
    <div class="tb">
        合作伙伴->商户资料维护</div>
    <ajaxToolkit:ToolkitScriptManager runat="Server" EnableScriptGlobalization="true"
        EnableScriptLocalization="true" ID="ScriptManager2" />
    <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
            <asp:BulletedList ID="bulMsgShow" runat="server" />
            <script runat="server">public override void ErrorMsgShow() { ErrorMsgHelper(bulMsgShow); }</script>
            <div class="con">
                <div class="card">
                    查询商户信息</div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="12text">
                        <tr>
                            <td width="12%">
                                <div align="right">
                                    行业名称:</div>
                            </td>
                            <td width="8%">
                                <asp:DropDownList ID="selCalling" CssClass="inputmid" runat="server" OnSelectedIndexChanged="selCalling_SelectedIndexChanged"
                                    AutoPostBack="true">
                                </asp:DropDownList>
                            </td>
                            <td width="12%">
                                <div align="right">
                                    单位名称:</div>
                            </td>
                            <td width="8%">
                                <asp:DropDownList ID="selCorp" CssClass="inputmidder" runat="server">
                                </asp:DropDownList>
                            </td>
                             <td width="12%">
                                <div align="right">
                                    证件有效期:</div>
                            </td>
                            <td width="8%">
                                <asp:DropDownList ID="selEndTime" CssClass="inputmidder" runat="server">
                                    <asp:ListItem Text="--请选择--" Value="" Selected="True"></asp:ListItem>
                                    <asp:ListItem Text="1: 未登记有效期" Value="1" ></asp:ListItem>
                                    <asp:ListItem Text="2: 已过期" Value="2"></asp:ListItem>
                                    <asp:ListItem Text="3: 在1个月内即将过期" Value="3" ></asp:ListItem>
                                    <asp:ListItem Text="4: 在2个月内即将过期" Value="4"></asp:ListItem>
                                    <asp:ListItem Text="5: 在3个月内即将过期" Value="5" ></asp:ListItem>
                                    <asp:ListItem Text="6: 在6个月内即将过期" Value="6"></asp:ListItem>
                                    <asp:ListItem Text="7: 在1年内即将过期" Value="7"></asp:ListItem>
                                    <asp:ListItem Text="8: 超过1年有效期" Value="8"></asp:ListItem>
                                </asp:DropDownList>
                            </td>
                            <td width="10%">
                                  <div align="right">
                                <asp:Button ID="btnQuery" runat="server" Text="查询" CssClass="button1" OnClick="btnQuery_Click" /></div>
                            </td>
                        </tr>
                    </table>
                </div>
                <div class="jieguo">
                    商户信息列表</div>
                <div class="kuang5">
                    <div id="gdtb" style="height: 290px">
                        <asp:GridView ID="lvwCorpQuery" runat="server" Width="1000" CssClass="tab1" HeaderStyle-CssClass="tabbt"
                            AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel" AllowPaging="True"
                            PageSize="10" PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left"
                            PagerStyle-VerticalAlign="Top" AutoGenerateColumns="False" OnPageIndexChanging="lvwCorpQuery_Page"
                            OnSelectedIndexChanged="lvwCorpQuery_SelectedIndexChanged" OnRowCreated="lvwCorpQuery_RowCreated">
                            <Columns>
                                <asp:TemplateField HeaderText="有效标志">
                                    <ItemTemplate>
                                        <asp:Label ID="labUseTag" Text='<%# Eval("USETAG").ToString() == "1" ? "有效" : "无效" %>'
                                            runat="server"></asp:Label>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField DataField="CORPNO" HeaderText="单位编码" />
                                <asp:BoundField DataField="CORP" HeaderText="单位名称" />
                                <asp:BoundField DataField="CALLING" HeaderText="行业名称" />
                                <asp:BoundField DataField="REGIONCODE" HeaderText="地区编码" />
                                <asp:BoundField DataField="REGIONNAME" HeaderText="地区名称" />
                                <asp:BoundField DataField="LINKMAN" HeaderText="联系人" />
                                <asp:BoundField DataField="CORPPHONE" HeaderText="联系电话" />
                                <asp:BoundField DataField="CORPADD" HeaderText="单位地址" />
                                <asp:BoundField DataField="CORPMARK" HeaderText="单位说明" />
                                 <asp:BoundField DataField="COMPANYENDTIME" HeaderText="证件有效期" />
                            </Columns>
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                        <td>
                                            有效标志
                                        </td>
                                        <td>
                                            单位编码
                                        </td>
                                        <td>
                                            单位名称
                                        </td>
                                        <td>
                                            行业名称
                                        </td>
                                        <td>
                                            地区编码
                                        </td>
                                        <td>
                                            地区名称
                                        </td>
                                        <td>
                                            联系人
                                        </td>
                                        <td>
                                            联系电话
                                        </td>
                                        <td>
                                            单位地址
                                        </td>
                                        <td>
                                            单位说明
                                        </td>
                                          <td>
                                            证件有效期
                                        </td>
                                    </tr>
                                </table>
                            </EmptyDataTemplate>
                        </asp:GridView>
                    </div>
                    <%--<div id="gdtb" style="height:100px"></div>--%>
                </div>
                <div class="card">
                    商户信息</div>
                <div class="kuang5">
                    <table width="99%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td width="12%">
                                <div align="right">
                                    行业名称:</div>
                            </td>
                            <td width="12%" style="white-space: nowrap">
                                <asp:DropDownList ID="selCallingExt" AutoPostBack="true" CssClass="inputmid" runat="server" OnSelectedIndexChanged="selCallingExt_SelectedIndexChanged">
                                </asp:DropDownList>
                                <span class="red">*</span>
                            </td>
                            <td width="12%">
                                <div align="right">
                                    地区名称:</div>
                            </td>
                            <td width="12%" style="white-space: nowrap">
                                <asp:DropDownList ID="selRegionExt" CssClass="inputmid" runat="server" AutoPostBack="true" OnSelectedIndexChanged="selRegionExt_SelectedIndexChanged">
                                </asp:DropDownList>
                                <span class="red">*</span>
                            </td>
                            <td width="12%">
                                <div align="right">
                                    单位编码:</div>
                            </td>
                            <td width="12%" style="white-space: nowrap">
                                <asp:TextBox runat="server" CssClass="input" onkeydown="stopbackspace(this.value)" ReadOnly="true" MaxLength="4" ID="txtCorpNo"> </asp:TextBox>
                                <span class="red">*</span>
                            </td>
                             <td width="12%">
                                <div align="right">
                                    单位名称:</div>
                            </td>
                            <td width="12%" style="white-space: nowrap">
                                <asp:TextBox ID="txtCorp" runat="server" CssClass="inputmid" MaxLength="100"></asp:TextBox>
                                <span class="red">*</span>
                            </td>
                        </tr>
                        <tr>
                           <td width="12%">
                                <div align="right">
                                    商户证件类型:</div>
                            </td>
                             <td width="12%" >
                                <asp:DropDownList ID="selComPapertype" CssClass="input" runat="server">
                                </asp:DropDownList>
                                <span class="red" runat="server" id="spnlComPapertype">*</span>
                            </td>
                           <td width="12%">
                                <div align="right" >
                                    商户证件号码:</div>
                            </td>
                             <td width="12%" style="white-space: nowrap">
                                <asp:TextBox ID="txtComPaperNo" CssClass="input" MaxLength="30" runat="server"></asp:TextBox>
                                 <span class="red" runat="server" id="spnComPaperNo">*</span>
                            </td>
                             <td width="12%">
                                <div align="right">
                                    商户证件有效期:</div>
                            </td>
                            <td width="12%" style="white-space: nowrap">
                                <asp:TextBox ID="txtEndDate" CssClass="input" runat="server" MaxLength="20"></asp:TextBox>
                                <ajaxToolkit:CalendarExtender ID="CalendarExtender1" runat="server" TargetControlID="txtEndDate"
                                    Format="yyyyMMdd" />
                                    <span class="red" runat="server" id="spnComEndDate">*</span>
                            </td>
                            <td width="12%">
                                <div align="right">
                                    联系电话:</div>
                            </td>
                            <td width="12%">
                                <asp:TextBox ID="txtPhone" runat="server" CssClass="input" MaxLength="40"></asp:TextBox>
                                <span class="red">*</span>
                            </td>
                        </tr>
                         <tr>
                            <td width="8%">
                                <div align="right">
                                    授权办理人:</div>
                            </td>
                            <td>
                                <asp:TextBox ID="txtLinkMan" runat="server" CssClass="input" MaxLength="10"></asp:TextBox>
                                <span class="red">*</span>
                            </td>
                            <td width="12%">
                                <div align="right" >
                                    授权办理人证件类型:</div>
                            </td>
                            <td width="12%" style="white-space: nowrap">
                                <asp:DropDownList ID="selPapertype" CssClass="input" runat="server" Width="117">
                                </asp:DropDownList>
                                 <span class="red" runat="server" id="spnPapertype">*</span>
                            </td>
                            <td width="12%">
                                <div align="right" >
                                    授权办理人证件号码:</div>
                            </td>
                            <td style="white-space: nowrap">
                                <asp:TextBox ID="txtCustpaperno" CssClass="input" MaxLength="20" runat="server"></asp:TextBox>
                                <span class="red" runat="server" id="spnCustpaperno">*</span>
                            </td>
                            <td style="white-space: nowrap">
                                <div align="right" >
                                    授权办理人证件有效期:</div>
                            </td>
                            <td>
                                <asp:TextBox ID="txtAccEndDate" CssClass="input" MaxLength="8" runat="server"></asp:TextBox>
                                <ajaxToolkit:CalendarExtender ID="CalendarExtender3" runat="server" TargetControlID="txtAccEndDate"
                                    Format="yyyyMMdd" />
                            </td>
                            </tr>
                        <tr>
                            <td width="12%">
                                <div align="right">
                                    单位说明:</div>
                            </td>
                            <td width="12%">
                                <asp:TextBox ID="txtCpRemrk" runat="server" CssClass="input" MaxLength="50"></asp:TextBox>
                            </td>
                           <td width="12%">
                                <div align="right">
                                    有效标志:</div>
                            </td>
                            <td>
                                <asp:DropDownList ID="selUseTag" CssClass="input" runat="server">
                                </asp:DropDownList>
                                <span class="red">*</span>
                            </td>
                            <td width="12%">
                                <div align="right">
                                    法人证件类型:</div>
                            </td>
                            <td style="white-space: nowrap">
                                <asp:DropDownList ID="selHoldPaperType" CssClass="input" runat="server" Width="117">
                                </asp:DropDownList>
                                <span class="red">*</span>
                            </td>
                            <td width="12%">
                                <div align="right">
                                    法人证件号码:</div>
                            </td>
                            <td style="white-space: nowrap">
                                <asp:TextBox ID="txtHoldNo" CssClass="inputmid" runat="server" MaxLength="30"></asp:TextBox>
                                <span class="red">*</span>
                            </td>
                           
                        </tr>
                        <tr>
                           
                            

                           
                            <td width="12%">
                                <div align="right">
                                    应用行业:</div>
                            </td>
                            <td width="12%" style="white-space: nowrap">
                                <asp:DropDownList ID="selAppCalling"  CssClass="inputmid" runat="server" AutoPostBack="true" OnSelectedIndexChanged="selAppCalling_SelectedIndexChanged">
                                 </asp:DropDownList>
                                <span class="red">*</span>
                            </td>
                            <td width="12%">
                                <div align="right">
                                    经营范围:</div>
                            </td>
                            <td style="white-space: nowrap">
                                <asp:TextBox ID="txtArea" CssClass="inputmid" runat="server" MaxLength="50"></asp:TextBox>
                                <span class="red">*</span>
                            </td>
                            <td width="12%">
                                <div align="right">
                                    注册资金:</div>
                            </td>
                            <td style="white-space: nowrap">
                                <asp:TextBox ID="txtMoney" runat="server" CssClass="input" AutoPostBack="true"
                                    ontextchanged="txtMoney_TextChanged" ></asp:TextBox>(万元)
                                <span class="red">*</span>
                            </td>
                             <td width="12%">
                                <div align="right">
                                    安全值:</div>
                            </td>
                            <td>
                                <asp:TextBox ID="txtSecurityValue" runat="server" CssClass="input" ></asp:TextBox>
                                
                            </td>

                        </tr>
                        <tr>
                           
                            

                           
                            <td width="12%">
                                <div align="right">
                                    法人姓名:</div>
                            </td>
                            <td width="12%" style="white-space: nowrap">
                                <asp:TextBox ID="txtCorporation" runat="server" CssClass="input" ></asp:TextBox>
                                <span class="red">*</span>
                            </td>
                            <td width="12%">
                                <div align="right">
                                    </div>
                            </td>
                            <td style="white-space: nowrap">
                            </td>
                            <td width="12%">
                                <div align="right">
                                    </div>
                            </td>
                            <td style="white-space: nowrap">
                            </td>
                             <td width="12%">
                                <div align="right">
                                    </div>
                            </td>
                            <td>
                            </td>

                        </tr>

                            <tr>
                             <td width="12%" class="style1">
                                <div align="right">
                                    单位地址:</div>
                            </td>
                            <td colspan="3" class="style1">
                                <asp:TextBox ID="txtAddr" runat="server" CssClass="input" MaxLength="50" 
                                    Width="250px"></asp:TextBox>
                                <span class="red">*</span>
                                </td>
                            <td width="12%" class="style1">
                                <div align="right">
                                    备注:</div>
                            </td>
                            <td colspan="3"width="12%" >
                                <asp:TextBox ID="txtRemark" runat="server" CssClass="inputlong" MaxLength="100" 
                                    Width="250px"></asp:TextBox>
                            </td>
                            <td>
                            <asp:HiddenField ID ="hidSecurityValue" runat="server" />
                            </td>
                            </tr>
                        <tr>
                         <td colspan="8">
                                <table width="200" border="0" align="right" cellpadding="0" cellspacing="0">
                                    <tr>
                                        <td height="24">
                                            <asp:Button ID="btnAdd" runat="server" Text="增加" CssClass="button1" OnClick="btnAdd_Click" />
                                        </td>
                                        <td>
                                            <asp:Button ID="btnModify" runat="server" Text="修改" CssClass="button1" OnClick="btnModify_Click" />
                                        </td>
                                    </tr>
                                </table>
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

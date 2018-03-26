<%@ Page Language="C#" AutoEventWireup="true" CodeFile="EM_CardSurface.aspx.cs" Inherits="ASP_EquipmentManagement_EM_CardSurface"  EnableEventValidation="false"%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>卡面编码维护</title>
    <link rel="stylesheet" type="text/css" href="../../css/frame.css" />
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
    <div class="tb">
        设备管理->卡面编码维护
    </div>
    <ajaxToolkit:ToolkitScriptManager EnableScriptGlobalization="true" EnableScriptLocalization="true"
        ID="ScriptManager1" runat="server" />
    <asp:UpdatePanel ID="UpdatePanel1" UpdateMode="Conditional" runat="server">
        <ContentTemplate>
            <asp:BulletedList ID="bulMsgShow" runat="server" />
            <script runat="server">public override void ErrorMsgShow() { ErrorMsgHelper(bulMsgShow); }</script>
            <div class="con">
                <div class="card">
                    查询</div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <td width="12%">
                            <div align="right">
                                卡片类型:</div>
                        </td>
                        <td width="12%">
                            <asp:DropDownList ID="selCardType" CssClass="input" runat="server">
                            </asp:DropDownList>
                        </td>
                        <td width="12%">
                            <div align="right">
                                卡面类型:</div>
                        </td>
                        <td width="12%">
                            <asp:DropDownList ID="selCardFaceType" CssClass="input" runat="server">
                            </asp:DropDownList>
                        </td>
                        </td>
                        <td width="12%">
                            <div align="right">
                                是否已有卡样:</div>
                        </td>
                        <td width="12%">
                            <asp:DropDownList ID="selCardPle" CssClass="input" runat="server">
                                <asp:ListItem Text="--请选择--" Value="0"></asp:ListItem>
                                <asp:ListItem Text="1: 已有" Value="1"></asp:ListItem>
                                <asp:ListItem Text="2: 没有" Value="2"></asp:ListItem>
                            </asp:DropDownList>
                        </td>
                        <td width="12%" align="right">
                            <asp:Button ID="btnQuery" CssClass="button1" runat="server" Text="查询" OnClick="btnQuery_Click" />
                        </td>
                        <td width="12%">
                        </td>
                        </tr>
                    </table>
                </div>
                <div class="jieguo">
                    需求单详细信息</div>
                <div class="kuang5">
                    <div id="Div1" style="height: 220px">
                        <asp:GridView ID="gvResult" runat="server" Width="100%" CssClass="tab1" HeaderStyle-CssClass="tabbt"
                            FooterStyle-CssClass="tabcon" AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel"
                            PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="left" PagerStyle-VerticalAlign="Top"
                            AutoGenerateColumns="true" OnRowDataBound="gvResult_RowDataBound" OnSelectedIndexChanged="gvResult_SelectedIndexChanged"
                            AllowPaging="true" PageSize="8" OnPageIndexChanging="gvResult_Page" OnRowCreated="gvResult_RowCreated"
                            >
                            
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                        <td>
                                            卡片类型
                                        </td>
                                        <td>
                                            卡面类型
                                        </td>
                                        <td>
                                            卡面类型说明
                                        </td>
                                        <td>
                                            卡样编码
                                        </td>
                                        <td>
                                            有效标志
                                        </td>
                                        <td>
                                            更新员工
                                        </td>
                                        <td>
                                            更新时间
                                        </td>
                                        <td>
                                            税率
                                        </td>
                                        <td>
                                            商品编码
                                        </td>

                                    </tr>
                                </table>
                            </EmptyDataTemplate>
                        </asp:GridView>
                    </div>
                </div>
                <div class="base">
                    文件上传</div>
                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                    <tr>
				            <td width="15%"><div align="right">卡面类型编码:</div></td>
				            <td width="30%">
				                <asp:TextBox ID="txtCode" CssClass="input" MaxLength="4" runat="server"></asp:TextBox><span class="red">*</span>
				            </td>
                            <td><div align="right">卡面类型名称:</div></td>
				            <td>
				                <asp:TextBox ID="txtName" CssClass="inputlong" MaxLength="40" runat="server"></asp:TextBox><span class="red">*</span>
				            </td>
				        </tr>
				        <tr>
				            <td><div align="right">卡面类型说明:</div></td>
				            <td>
				                <asp:TextBox ID="txtNote" CssClass="inputlong" MaxLength="150" runat="server"></asp:TextBox>
				            </td>
                            <td>
                                <div align="right">
                                    上传卡样文件:</div>
                            </td>
                            <td>
                                <asp:FileUpload ID="FileUpload1" runat="server" CssClass="inputlong" />
                            </td>
				        </tr>
				        <tr>
				            <td><div align="right">有效标志:</div></td>
				            <td>
						        <asp:DropDownList ID="selUseTag" CssClass="input" runat="server">
						        <asp:ListItem Text="0:无效" Value="0"></asp:ListItem>
                                <asp:ListItem Text="1:有效" Value="1"></asp:ListItem>
						        </asp:DropDownList>
					        </td>
                            <td><div align="right">税率:</div></td>
				            <td>
						         <asp:DropDownList ID="ddlTax" CssClass="input" runat="server">
                            </asp:DropDownList>
					        </td>
				        </tr>
                        <tr>
				            <td><div align="right">商品编码:</div></td>
				            <td>
				                <asp:TextBox ID="txtGoods" CssClass="inputlong" MaxLength="19" runat="server"></asp:TextBox>
				            </td>
                            </tr>
                    </table>
                </div>
                <div class="jieguo" >
                    查看卡面</div>
                <div class="kuang5" style="height: 160px;">
                    <div class="left">
                        <img src="../../Images/cardface.jpg" alt="卡正面"  id="Img" runat="server" height="150" style="cursor:hand" /></div>
                </div>
            </div>
            <div class="btns">
                <table width="95%" border="0" cellpadding="0" cellspacing="0">
                    <tr>
                        <td width="70%">
                            &nbsp;
                        </td>
                        <td align="right">
                            <asp:Button ID="btnSubmit" CssClass="button1" runat="server" Text="增加"
                                OnClick="btnSubmit_Click" />
                                <asp:Button ID="btnModify" CssClass="button1" runat="server" Text="修改"
                                OnClick="btnModify_Click" />
                            <asp:Button ID="btnCancel" CssClass="button1" runat="server" Text="删除卡样"
                                OnClick="btnCancel_Click" />
                        </td>
                    </tr>
                </table>
            </div>
        </ContentTemplate>
        <Triggers>
            <asp:PostBackTrigger ControlID="btnSubmit" />
            <asp:PostBackTrigger ControlID="btnModify" />
            <asp:PostBackTrigger ControlID="btnCancel" />
        </Triggers>
    </asp:UpdatePanel>
    </form>
</body>
</html>

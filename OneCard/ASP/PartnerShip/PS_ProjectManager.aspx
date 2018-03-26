<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PS_ProjectManager.aspx.cs" Inherits="ASP_PartnerShip_PS_ProjectManager" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>优惠活动维护</title>
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
        合作伙伴->优惠活动维护</div>
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
            查询活动信息</div>
        <div class="kuang5">
            <table width="98%" border="0" cellpadding="0" cellspacing="0" class="text25">
                <tr>
                    <td width="10%"><div align="right">活动名称:</div></td>
                    <td width="20%">
                        <asp:DropDownList ID="selProject" CssClass="inputmidder" runat="server">
                        </asp:DropDownList>
                    </td>
                    <td width="20%">
                      <asp:Button ID="Button1" runat="server" Text="查询" CssClass="button1" OnClick="btnQuery_Click" />
                    </td>
                    <td width="20%" align="right">
                     
                    </td>
                    <td width="20%">
                      
                    </td>
                    
                </tr>
                       
            </table>
            <div class="gdtb" style="height: 160px">
                        <asp:GridView ID="lvwBalUnits" runat="server" CssClass="tab1" Width="100%" HeaderStyle-CssClass="tabbt"
                            AlternatingRowStyle-CssClass="tabjg" SelectedRowStyle-CssClass="tabsel" AllowPaging="false"
                            PagerSettings-Mode="NumericFirstLast" PagerStyle-HorizontalAlign="Left"
                            PagerStyle-VerticalAlign="Top" AutoGenerateColumns="False"
                            OnSelectedIndexChanged="lvwBalUnits_SelectedIndexChanged" OnRowCreated="lvwBalUnits_RowCreated"
                            EmptyDataText="没有数据记录!">
                            <Columns> 
                                <asp:BoundField DataField="TAGNAME" HeaderText="是否当前活动" />                              
                                <asp:BoundField DataField="PROJECTNO" HeaderText="活动编码" />
                                <asp:BoundField DataField="PROJECTNAME" HeaderText="活动名称" />
                                <asp:BoundField DataField="DISCOUNTLIMITLINE" HeaderText="总优惠金额" />
                                <asp:BoundField DataField="DISCOUNTWARNLINE" HeaderText="优惠阀值" />
                                <asp:BoundField DataField="DISCOUNTMONEY" HeaderText="已优惠金额" />
                                
                            </Columns>
                            <EmptyDataTemplate>
                                <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tab1">
                                    <tr class="tabbt">
                                        <td>
                                            是否当前活动
                                        </td>
                                        <td>
                                            活动编码
                                        </td>
                                        <td>
                                            活动名称
                                        </td>
                                        <td>
                                            总优惠金额
                                        </td>
                                        <td>
                                            优惠阀值
                                        </td>
                                         <td>
                                            已优惠金额
                                        </td>
                                        
                                    </tr>
                                </table>
                            </EmptyDataTemplate>
                        </asp:GridView>
            </div>
        </div>
        <div class="jieguo">
            活动信息</div>
            <div class="con">

                <div class="kuang5">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td width="10%">
                                <div align="right">
                                    活动名称:</div>
                            </td>
                            <td width="20%">
                               <asp:TextBox ID="txtName" CssClass="inputmid" MaxLength="20" runat="server"></asp:TextBox>
                            </td> 
                            <td width="10%">
                                <div align="right">
                                    总优惠金额:</div>
                            </td> 
                            <td width="20%">
                                <asp:TextBox ID="txtTotal" CssClass="inputmid" MaxLength="15" runat="server"></asp:TextBox>元
                            </td> 
                            <td width="10%">
                               <div align="right">
                                    优惠阀值:</div>
                            </td> 
                            <td width="20%"> 
                                <asp:TextBox ID="txtWarm" CssClass="inputmid" MaxLength="15" runat="server"></asp:TextBox>元
                            </td>                       
                        </tr>
                        <tr>
                        <td width="10%">
                               <div align="right">
                                    已优惠金额:</div>
                            </td> 
                            <td width="20%"> 
                                <asp:TextBox ID="txtDiscount" CssClass="inputmid" MaxLength="15" runat="server" Text="0"></asp:TextBox>元(初始为0)
                            </td> 
                        </tr>
                                    
                    </table>
                    
                    
            </div>
            </div>

            <div class="btns">
                <table width="95%" border="0" align="right" cellpadding="0" cellspacing="0" >
                    <tr>
                    <td width="80%">&nbsp;</td>
                        <td align="right">
                            <asp:Button ID="btnAdd" runat="server" Text="增加" CssClass="button1" OnClick="btnAdd_Click" />
                        </td>
                        <td align="right">
                            <asp:Button ID="btnModify" runat="server" Text="修改"  CssClass="button1"
                                OnClick="btnModify_Click" />
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

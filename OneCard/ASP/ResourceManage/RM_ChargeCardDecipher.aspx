<%@ Page Language="C#" AutoEventWireup="true" CodeFile="RM_ChargeCardDecipher.aspx.cs" Inherits="ASP_ResourceManage_RM_ChargeCardDecipher" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <%--<link rel="stylesheet" type="text/css" href="../../css/frame.css" />--%>
    <link href="../../css/card.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="../../js/myext.js"></script>
    <script type="text/javascript" src="../../js/RMHelper.js"></script>
    <script type="text/javascript" src="../../js/printorder.js"></script>
    <script src="../../js/jquery-1.5.min.js" type="text/javascript"></script>
    <script type="text/javascript" src="../../js/Window.js"></script>
    <title>充值卡密码解密</title>
    
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
        卡片管理->充值卡密码解密
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
    <asp:UpdatePanel ID="UpdatePanel1" UpdateMode="Conditional" runat="server">
        <ContentTemplate>
            <asp:BulletedList ID="bulMsgShow" runat="server" />
            <script runat="server">public override void ErrorMsgShow() { ErrorMsgHelper(bulMsgShow); }</script>
                     
            <div class="con">
                <div class="card">
                    查询
                </div>
                <div class="kuang5" style="text-align: left">
                    <table width="95%" border="0" cellpadding="0" cellspacing="0" class="text25">
                        <tr>
                            <td width="12%">
                            </td>
                            <td width="12%">
                            </td>
                            <td width="12%">
                            </td>
                            <td width="12%">
                            </td>
                            <td width="12%">
                            </td>
                            <td width="12%">
                            </td>
                            <td width="12%">
                            </td>
                            <td width="12%">
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <div align="right">
                                    充值卡卡号:</div>
                            </td>
                            
                            <td>
                                <asp:TextBox ID="txtCardNo" CssClass="inputmid" maxlength="14" runat="server"></asp:TextBox>
                            </td>
                            <td>
                                <div align="right">
                                    私钥:</div>
                            </td>
                            
                           <td colspan='2'>
                               
                                <asp:FileUpload ID="FileUpload1" runat="server" CssClass="inputlong" />
                                <%--<asp:Button ID="btnUpload" CssClass="button1" runat="server" Text="导入" OnClick="btnUpload_Click" />--%>
                            </td>
                            <td>
                                <asp:Label ID="Label1" runat="server" Text=""></asp:Label>
                            </td>
                           
                             
                            
                        </tr> 
                        
                        <tr>
                        <td>
                         <div align="right">
                                    充值卡密码:</div>
                        </td>
                        <td>
                                <asp:TextBox ID="TextBox1" CssClass="inputmid"  maxlength="16" runat="server"></asp:TextBox>
                            </td>
                        <td width="50%" colspan='8' align="right">
                                <asp:Button ID="btnQuery" CssClass="button1" runat="server" Text="查询" OnClick="btnQuery_Click" />
                                 
                            </td>
                        </tr>
                    </table>
                </div>
               
                
            </div>
   
            
            
        </ContentTemplate>
       <Triggers>
            <asp:PostBackTrigger ControlID="btnQuery" /> 
   
        </Triggers>
    </asp:UpdatePanel>
    </form>
</body>
</html>

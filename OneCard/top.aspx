<%@ Page Language="C#" AutoEventWireup="true" CodeFile="top.aspx.cs" Inherits="top" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=gb2312">
    <link href="css/top.css" rel="stylesheet" type="text/css" />

    <script type="text/javascript">
        function refreshNewMsgNum() {
            setTimeout("$get('btnConfirm').click();", 60000);
        }

        function mover() {
            //ȥ�����ڽڵ���ʽ
            var object_nav = arguments[0].parentElement.parentElement;
            for (var i = 0; i < object_nav.children.length; ++i) {
                var object_cld = object_nav.children[i].children[0];
                    object_cld.children[0].style.color = "#000";
                    object_cld.className = null;

            }

            //��ǰ�ڵ������ʽ
            arguments[0].className = "on";
            arguments[0].children[0].style.color = "#fff";
            arguments[0].children[0].style.cursor = "pointer";
        }
        function mout() {
            var object = document.getElementById("linkOneCard");
            //mover(object);
        }     
        
    </script>

</head>
<body>
    <form id="form1" runat="server">
    <ajaxToolkit:ToolkitScriptManager EnableScriptGlobalization="true" EnableScriptLocalization="true"
        ID="ScriptManager1" runat="server" />
    <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
            <asp:LinkButton runat="server" ID="btnConfirm" OnClick="btnConfirm_Click" />
            <div class="iHeader">
                <div class="header">
                    <div class="logo">
                    </div>
                    <div class="header_right">
                        <div class="detail_info">
                            <p>
                                �������ƣ�<asp:Label ID="labDepartName" runat="server" Text="Label"></asp:Label>
                                Ա���ţ�<asp:Label ID="labUserID" runat="server" Text="Label"></asp:Label>
                                ������<asp:Label ID="labUserName" runat="server" Text="Label"></asp:Label>
                                ���ţ�<asp:Label ID="LabCardNo" runat="server" Text="Label"></asp:Label>
                            </p>
                            <div class="option">
                                <a class="new" href="ASP/PrivilegePR/PR_Msg.aspx" target="content">����Ϣ��<asp:Label
                                    ID="labNewMsgNum" runat="server" Text="1"></asp:Label>��</a> <a class="help" href="#"
                                        >����</a>
                                <asp:HyperLink ID="linkLogout" CssClass="quit" OnClientClick="return confirm('�����Ҫ�˳���');"
                                    Target="_top" runat="server">�˳�</asp:HyperLink>
                            </div>
                        </div>
                        
                        <div class="c">
                        </div>
                        <asp:Label ID="labSMKCheck" runat="server" Text=""></asp:Label>
                        <ul class="nav_list">
                            <li runat="server" id="liSMK" visible="false">
                                <asp:HyperLink ID="linkSMK" Target="_top" runat="server" ><span class="signA">������ϵͳ</span></asp:HyperLink></li>
                            <li runat="server" id="liNewCard" visible="false">
                                <asp:HyperLink ID="linkNewCard" Target="_top" runat="server" ><span class="signA">��ͨһ��ͨ</span></asp:HyperLink></li>
                            <li runat="server" id="liOneCard" visible="false">
                                <asp:LinkButton ID="linkOneCard" CssClass="on" runat="server"    OnClick="linkOneCard_Click">
                                    <span class="signB">����Ǯ��ϵͳ</span></asp:LinkButton></li>
                            <li runat="server" id="liGroupCard" visible="false">
                                <asp:LinkButton ID="linkGroupCard"  runat="server"  OnClick="linkGroupCard_Click">
                                    <span class="signB">ר���˻�ϵͳ</span></asp:LinkButton></li>
                            <li runat="server" id="liResource" visible="false">
                                <asp:LinkButton ID="linkResource" runat="server"    OnClick="linkResource_Click"> 
                                <span class="signC">��Դ����ϵͳ</span></asp:LinkButton></li>
                        </ul>
                    </div>
                    <div style="display: none">
                    </div>
                </div>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
    </form>
</body>
</html>

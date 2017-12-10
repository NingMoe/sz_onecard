<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PR_TestGj.aspx.cs" Inherits="TestGj" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>轨交 Test</title>
    <script type="text/javascript" src="../../js/myext.js"></script>
    <script type="text/javascript">
   var OperateCardNo = "<%= ((Hashtable)Session["LogonInfo"])["CardID"] %>";
   var currCardNo = null;
   var cardBalance = 0;
   
      function ReadGj() {

           try {
             var i = SX_CARDOCX1.ReadGjTrade(OperateCardNo); 
        if (i != 0) {
            MyExtMsg('提示', "获取卡片信息失败:" + SX_CARDOCX1.ErrInfo + "<br>返回值：" + i);
            return false;
        }
        MyExtMsg ('提示', "标识:" + SX_CARDOCX1.TradeNumber);
        return true;
        }
        catch (e) {
            MyExtMsg ('提示', "轨交控件未安装成功");
            return true;
        }
    }


    </script>
</head>
<body>
    <object id="SX_CARDOCX1" classid="clsid:0362744E-0794-4020-B5B0-355ED58A736D" width="0"
        height="0">
    </object>
    <form id="form1" runat="server">
    <ajaxToolkit:ToolkitScriptManager EnableScriptGlobalization="true" EnableScriptLocalization="true"
        ID="ScriptManager1" runat="server" />
    <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
            <asp:HiddenField runat="server" ID="hidCardReaderToken" />
            <asp:HiddenField runat="server" ID="hidHelp" />
            <br />
            <br />
            <br />
            <br />
            <br />
            <br />
            <br />
            <br />
            <div align="center">
                <asp:Button runat="server" ID="Button10" Text="读取轨交次数" OnClientClick="return ReadGj()" />
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
    </form>
</body>
</html>

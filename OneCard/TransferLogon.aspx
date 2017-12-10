<%@ Page Language="C#" AutoEventWireup="true" CodeFile="TransferLogon.aspx.cs" Inherits="TransferLogon" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <script>
        window.onload = function () {
            top.location.href = "<%=loginURL%>";
        } 
    </script> 
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
    
    </div>
    </form>
</body>
</html>

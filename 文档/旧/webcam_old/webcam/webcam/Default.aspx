<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="webcam._Default" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
   <script type="text/javascript" src="http://libs.baidu.com/jquery/1.9.1/jquery.min.js"></script> 
    <script type="text/javascript" src="Scripts/jquery.webcam.min.js"></script>
    <script type="text/javascript" src="Scripts/index.js"></script>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
</head>
<body>
    <form id="form1" runat="server">
        <div id="webcam"></div>
        <a href="javascript:webcam.capture();void(0);">拍摄</a> 
        <div id="message"></div>
        <img id="webcamPic" src="" />
    </form>
</body>
</html>

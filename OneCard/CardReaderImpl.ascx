<%@ Control Language="C#" AutoEventWireup="true" CodeFile="CardReaderImpl.ascx.cs" Inherits="CardReaderImpl" %>

<script type="text/javascript" src="js/cardreaderimpl.js"></script>
<script type="text/javascript">

cardReader.OperateCardNo = "<%= ((Hashtable)Session["LogonInfo"])["CardID"] %>";
cardReader.Debugging = "True" == "<%= ((Hashtable)Session["LogonInfo"])["Debugging"] %>";
cardReader.testingMode = cardReader.Debugging;




</script>
		
		

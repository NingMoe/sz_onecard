<%@Import namespace="System.Globalization"%>
<%@Import namespace="System.Resources"%>
<%@Import namespace="System.Threading"%>
<%@Import namespace="System.IO"%>
<%@Import namespace="System.Diagnostics"%>
<%@Import namespace="System.Resources"%>
<%@Import namespace="Common"%>

<script runat="server" language="C#">
    
protected void Application_Start(object sender, EventArgs e)
{
    Log.Init();
}
    
protected void Application_Error(object sender, EventArgs e)
{
    //Server.ClearError();
    //Server.Transfer("/Onecard/TransferError.html");
}

protected void Application_End(object sender, EventArgs e)
{

}

</script>

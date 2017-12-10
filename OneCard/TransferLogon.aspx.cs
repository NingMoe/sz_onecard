using System;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class TransferLogon : System.Web.UI.Page
{
    public string loginURL = System.Configuration.ConfigurationManager.AppSettings["LoginServer"] + "/Logon.aspx";
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Request.QueryString["type"] == "admin")
        {
            loginURL = System.Configuration.ConfigurationManager.AppSettings["LoginServer"] + "/LogonAdmin.aspx";
        }
    }
}
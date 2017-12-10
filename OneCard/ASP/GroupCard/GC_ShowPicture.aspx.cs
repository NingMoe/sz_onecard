using System;
using System.Collections;
using System.Configuration;
using System.Data;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;

public partial class ASP_GroupCard_GC_ShowPicture : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            //DateTime d = new DateTime();
            Img.Src = "GC_ShowGetPicture.aspx?orderDetailId=" + Request.QueryString["orderDetailId"] + "&photoType=" + Request.QueryString["photoType"];
        }
    }
}

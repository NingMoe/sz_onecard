using System;
using System.Text;
using System.IO;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class picture : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            //string path = Server.MapPath("~/pic.txt");
            //StreamReader sr = new StreamReader(path, Encoding.GetEncoding("GBK"));
            byte[] pic = null;
            if (Request.QueryString["picType"] != null && Request.QueryString["picType"].ToString() == "1")
            {
                pic = (byte[])Session["PicDataOther"];
            }
            else
            {
                pic = (byte[])Session["PicData"];
            }

            this.Response.ClearContent();
            this.Response.ContentType = "image/Jpeg";
            this.Response.BinaryWrite(pic);
        }
    }

 
}
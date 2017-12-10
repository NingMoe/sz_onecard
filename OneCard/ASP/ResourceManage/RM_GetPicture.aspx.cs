using System;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.IO;
using System.Text;

public partial class ASP_ResidentCard_RM_GetPicture : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        String PaperNo = "";
        if (Request.QueryString["CardSampleCode"] != null && Request.QueryString["CardSampleCode"].ToString() != "")
        {
            PaperNo = Request.QueryString["CardSampleCode"].ToString();
        }

        byte[] buffer = ResourceManageHelper.ReadPicture(context, PaperNo);

        if (buffer == null)
        {
            String path = System.Web.HttpContext.Current.Request.PhysicalApplicationPath + "/Images/cardface.jpg";
            Stream stream = new FileStream(path, System.IO.FileMode.Open, System.IO.FileAccess.Read, FileShare.ReadWrite);
            StreamReader reader = new StreamReader(stream, Encoding.GetEncoding("gb2312"));
            byte[] file = new byte[stream.Length];

            using (MemoryStream memstream = new MemoryStream())
            {
                buffer = new byte[stream.Length];
                int bytesRead = default(int);
                while ((bytesRead = reader.BaseStream.Read(buffer, 0, buffer.Length)) > 0)
                    memstream.Write(buffer, 0, bytesRead);
                file = memstream.ToArray();
                ResourceManageHelper.RespondPicture(file, Response);
                stream.Close();
                Response.End();
            }
        }
        else
        {
            ResourceManageHelper.RespondPicture(buffer, Response);
            Response.End();
        }

    }
}

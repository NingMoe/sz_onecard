using System;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.IO;
using System.Text;
using System.Data;

public partial class ASP_GroupCard_GC_ShowGetPicture : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {

        byte[] buffer = null;
        if (Request.QueryString["orderDetailId"] != null && Request.QueryString["photoType"].ToString() != ""
       && Request.QueryString["orderDetailId"] != null && Request.QueryString["photoType"].ToString() != "")
        {
            buffer = ReadImage(Request.QueryString["orderDetailId"].ToString(), Request.QueryString["photoType"].ToString());
        }

        if (buffer == null)
        {
            String path = System.Web.HttpContext.Current.Request.PhysicalApplicationPath + "/Images/nom.jpg";
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
            RespondPicture(buffer, Response);
            Response.End();
        }

    }

    /// <summary>
    /// 读取照片
    /// </summary>
    /// <param name="orderdetailid">子订单ID</param>
    /// <param name="phototype">照片类型</param>
    /// <returns>字节流</returns>
    private byte[] ReadImage(string orderdetailid, string phototype)
    {
        string selectSql = "Select " + phototype + " From TF_F_XXOL_ORDERDETAIL Where ORDERDETAILID=:ORDERDETAILID";
        context.DBOpen("Select");
        context.AddField(":ORDERDETAILID").Value = orderdetailid;
        DataTable dt = context.ExecuteReader(selectSql);
        context.DBCommit();
        if (dt != null && dt.Rows.Count > 0 && dt.DefaultView[0][phototype].ToString() != "")
        {
            return (byte[])dt.Rows[0].ItemArray[0];
        }

        return null;
    }

    /// <summary>
    /// 输出图片
    /// </summary>
    /// <param name="pic"></param>
    /// <param name="res"></param>
    public static void RespondPicture(byte[] pic, HttpResponse res)
    {
        if (pic != null)
        {
            res.ContentType = "application/octet-stream";
            res.AddHeader("Content-Disposition", "attachment;FileName= picture.JPG");
            res.BinaryWrite(pic);
        }
    }
}

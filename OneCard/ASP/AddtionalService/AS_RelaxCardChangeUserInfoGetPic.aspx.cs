using System;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using System.IO;
using System.Text;

/// <summary>
/// 读取照片
/// </summary>
public partial class ASP_AddtionalService_AS_RelaxCardChangeUserInfoGetPic : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
       
        byte[] buffer = null;
        if (Request.QueryString["Cardno"] != null && Request.QueryString["Cardno"].ToString() != ""
           && Request.QueryString["ChangeCode"] != null && Request.QueryString["ChangeCode"].ToString() != "")
        {
            buffer = ReadPicture(Request.QueryString["Cardno"].ToString(), Request.QueryString["ChangeCode"].ToString());
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
                RespondPicture(file, Response);
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
    /// 读取图片
    /// </summary>
    /// <param name="cardno"></param>
    /// <returns></returns>
    public byte[] ReadPicture(string cardno, string changeCode)
    {
        string selectSql = "";
        if (changeCode == "0" || changeCode == "1")
        {
            selectSql = "Select PICTURE From TF_F_CARDPARKPHOTO_SZ Where cardno=:cardno";
        }
        else
        {
            selectSql = "Select PICTURE From TF_F_CARDPARKPHOTOCHANGE_SZ Where cardno=:cardno";
        }
        context.DBOpen("Select");
        context.AddField(":cardno").Value = cardno;
        DataTable dt = context.ExecuteReader(selectSql);
        context.DBCommit();
        if (dt != null && dt.Rows.Count > 0 && dt.DefaultView[0]["PICTURE"].ToString() != "")
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
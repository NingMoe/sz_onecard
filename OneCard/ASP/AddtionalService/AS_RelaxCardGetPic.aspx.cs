using System;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using System.IO;
using System.Text;
using System.Drawing;
using System.Drawing.Imaging;
using System.Drawing.Drawing2D;
/// <summary>
/// 读取照片
/// </summary>
public partial class ASP_AddtionalService_AS_RelaxCardGetPic : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
       
        byte[] buffer = null;
        if (Request.QueryString["Cardno"] != null && Request.QueryString["Cardno"].ToString() != "")
        {
            buffer = ReadPicture(Request.QueryString["Cardno"].ToString());
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
            if (Request.QueryString["print"] != null && Request.QueryString["print"] == "1")
            {
                Bitmap bmp = new Bitmap(BytesToStream(buffer)); 
                MemoryStream ms = new MemoryStream();
                bmp = KiRotate90(bmp);
                bmp.Save(ms, System.Drawing.Imaging.ImageFormat.Jpeg);
                buffer = ms.GetBuffer(); 
            }
            RespondPicture(buffer, Response);
            Response.End();
        }

    }

    /// <summary>
    /// 读取图片
    /// </summary>
    /// <param name="cardno"></param>
    /// <returns></returns>
    public byte[] ReadPicture(string cardno)
    {
        string selectSql = "Select PICTURE From TF_F_CARDPARKPHOTO_SZ Where cardno=:cardno";
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

    /// <summary>
    /// 旋转
    /// </summary>
    /// <param name="bmp">原始图Bitmap</param> 
    /// <returns>输出Bitmap</returns>
    public static Bitmap KiRotate90(Bitmap img)
    {
        try
        {
            img.RotateFlip(RotateFlipType.Rotate90FlipNone);
            return img;
        }
        catch
        {
            return null;
        }
    }

    /// <summary>
    /// Stream 转 二进制
    /// </summary>
    /// <param name="stream"></param>
    /// <returns></returns>
    public byte[] StreamToBytes(Stream stream)
    {
        byte[] bytes = new byte[stream.Length];
        stream.Read(bytes, 0, bytes.Length);
        // 设置当前流的位置为流的开始
        stream.Seek(0, SeekOrigin.Begin);
        return bytes;
    }

    /// <summary>
    /// 将 byte[] 转成 Stream
    /// </summary>
    /// <param name="bytes"></param>
    /// <returns></returns>
    public Stream BytesToStream(byte[] bytes)
    {
        Stream stream = new MemoryStream(bytes);
        return stream;
    }
}
<%@ WebHandler Language="C#" Class="AS_RelaxcardWebCam" %>

using System;
using System.IO; 
using System.Web;
using System.Web.SessionState; 
using System.Drawing;
using System.Drawing.Imaging;
using System.Drawing.Drawing2D;

// 保存摄像头拍照图片
// 同时保存两张（横、竖）
// dongx 20150504
public class AS_RelaxcardWebCam : IHttpHandler, IRequiresSessionState
{
    
    public void ProcessRequest (HttpContext context) {
        string path = System.Web.HttpContext.Current.Server.MapPath("../../tmp/"); 
        Stream stream = context.Request.InputStream;
        string dump = string.Empty;
        using (StreamReader reader = new StreamReader(stream))
            dump = reader.ReadToEnd(); 
        //竖
        /*
        Bitmap bmp = new Bitmap(new MemoryStream(String_To_Bytes2(dump)));
        MemoryStream ms = new MemoryStream();
        bmp = KiRotate90(bmp);
        bmp.Save(ms, System.Drawing.Imaging.ImageFormat.Jpeg);
        System.IO.File.WriteAllBytes(path + "printImgH" + context.Session["staff"].ToString() + ".jpg", ms.GetBuffer());
         * */
        //横 
        System.IO.File.WriteAllBytes(path + "printImg" + context.Session["staff"].ToString() + ".jpg", String_To_Bytes2(dump));
       
    }
 
    public bool IsReusable {
        get {
            return false;
        }
    }


    private byte[] String_To_Bytes2(string strInput)
    {
        int numBytes = (strInput.Length) / 2;
        byte[] bytes = new byte[numBytes];

        for (int x = 0; x < numBytes; ++x)
        {
            bytes[x] = Convert.ToByte(strInput.Substring(x * 2, 2), 16);
        }
        
        return bytes;
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

}
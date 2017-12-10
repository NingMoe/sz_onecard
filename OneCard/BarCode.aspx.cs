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
using System.Drawing;

public partial class BarCode : System.Web.UI.Page
{

    private void Page_Load(object sender, System.EventArgs e)
    {
        Context.Response.Cache.SetCacheability(HttpCacheability.NoCache);
        // 在此处放置用户代码以初始化页面	
        this.CreateBarCodeImage(Request["validatecode"].ToString());
    }
    
    private void CreateBarCodeImage(string checkCode)
    {
        if (checkCode == null || checkCode.Trim() == String.Empty)
            return;
        //根据验证码生成一维条码
        BarCodeHelper bc = new BarCodeHelper();
         Font font = new System.Drawing.Font("宋体", 10);
         bc.ValueFont = font;
         System.Drawing.Bitmap image = bc.GetCodeImage(checkCode, BarCodeHelper.Encode.Code128C); 
        
        Graphics g = Graphics.FromImage(image);
        try
        {
            System.IO.MemoryStream ms = new System.IO.MemoryStream();
            image.Save(ms, System.Drawing.Imaging.ImageFormat.Bmp);
            Response.ClearContent();
            Response.ContentType = "image/bmp";
            Response.BinaryWrite(ms.ToArray());
        }
        finally
        {
            g.Dispose();
            image.Dispose();
        }
    }
}

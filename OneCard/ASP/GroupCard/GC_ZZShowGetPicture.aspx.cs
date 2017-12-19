using System;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.IO;
using System.Text;
using System.Data;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

public partial class ASP_GroupCard_GC_ZZShowGetPicture : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {

        byte[] buffer = null;
        if (Request.QueryString["orderDetailId"] != null)
        {
            buffer = ReadImage(Request.QueryString["orderDetailId"].ToString());
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
    private byte[] ReadImage(string orderdetailid)
    {
        Dictionary<string, string> postData = new Dictionary<string, string>();
        postData.Add("channelCode", "ONECARD");
        postData.Add("detailNo", orderdetailid);
        postData.Add("remark", "");
        string jsonResponse = HttpHelper.ZZPostRequest(HttpHelper.TradeType.ZZGetPhoto, postData);
        string code = "";
        string message = "";
        string bytePhoto = "";
        JObject deserObject = (JObject)JsonConvert.DeserializeObject(jsonResponse);
        foreach (JProperty itemProperty in deserObject.Properties())
        {
            string propertyName = itemProperty.Name;
            if (propertyName == "respCode")
            {
                code = itemProperty.Value.ToString();
            }
            else if (propertyName == "respDesc")
            {
                message = itemProperty.Value.ToString();
            }
            else if (propertyName == "photo")
            {
                bytePhoto = itemProperty.Value.ToString();
            }
        }
        if (code == "0000") //表示成功
        {
            return Convert.FromBase64String(bytePhoto);
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
        if (pic != null && pic.Length != 0)
        {
            res.ContentType = "application/octet-stream";
            res.AddHeader("Content-Disposition", "attachment;FileName= picture.JPG");
            res.BinaryWrite(pic);
        }
    }
}

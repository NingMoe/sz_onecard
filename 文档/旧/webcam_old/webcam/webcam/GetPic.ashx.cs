using System;
using System.IO; 
using System.Web;

namespace webcam
{
    /// <summary>
    /// GetPic 的摘要说明
    /// </summary>
    public class GetPic : IHttpHandler
    {

        public void ProcessRequest(HttpContext context)
        {
            Stream stream = context.Request.InputStream;
            string dump = string.Empty;

            using (StreamReader reader = new StreamReader(stream))
                dump = reader.ReadToEnd();

            string path = System.Web.HttpContext.Current.Server.MapPath("/tmp/test.jpg");
            System.IO.File.WriteAllBytes(path, String_To_Bytes2(dump));
            context.Response.ContentType = "text/plain";  
            context.Response.Write("OK");
            context.Response.End();

        }

        public bool IsReusable
        {
            get
            {
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

    }
}
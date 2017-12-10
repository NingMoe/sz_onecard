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

            throw new Exception("fuck"); 

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
<%@ WebHandler Language="C#" Class="Handler" %>

using System;
using System.IO; 
using System.Web;


public class Handler : IHttpHandler {
    
    public void ProcessRequest (HttpContext context) {
        Stream stream = context.Request.InputStream;
        string dump = string.Empty;

        using (StreamReader reader = new StreamReader(stream))
            dump = reader.ReadToEnd();

        string path = System.Web.HttpContext.Current.Server.MapPath("tmp/test.jpg");
        System.IO.File.WriteAllBytes(path, String_To_Bytes2(dump));
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

}
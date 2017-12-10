using System;
using System.Collections.Generic;
using System.IO;
using System.Net;
using System.Text;
using System.Web;

 
    /// <summary>
    /// Http请求
    /// </summary>
    public class HttpRequestUtility
    {
        /// <summary>
        ///通用HttpWebRequest
        /// </summary>
        /// <param name="method">请求方式（POST/GET）</param>
        /// <param name="url">请求地址</param>
        /// <param name="param">请求参数</param> 
        /// <returns>请求返回的结果</returns>
        public static string Request(string method, string url, string param)
        {
            if (string.IsNullOrEmpty(url))
                throw new ArgumentNullException("URL");

            switch (method.ToUpper())
            {
                case "POST":
                    return Post(url, param);
                case "GET":
                    return Get(url, param);
                default:
                    throw new EntryPointNotFoundException("method:" + method);
            }
        }

        /// <summary>
        /// Post请求
        /// </summary>
        /// <param name="url">请求地址</param>
        /// <param name="param">参数</param>
        /// <returns>请求返回的结果</returns>
        public static string Post(string url, string param)
        {
            UrlCheck(ref url);

            byte[] bufferBytes = Encoding.UTF8.GetBytes(param);

            HttpWebRequest request = WebRequest.Create(url) as HttpWebRequest; 
            request.Method = "POST";
            request.ContentLength = bufferBytes.Length;
            request.ContentType = "application/json";
            request.Accept = "application/json"; 
            try
            {
                using (Stream requestStream = request.GetRequestStream())
                {
                    requestStream.Write(bufferBytes, 0, bufferBytes.Length);
                }
            }
            catch (WebException ex)
            {

                return ex.Message;
            }

            return HttpRequest(request);
        }

        /// <summary>
        /// GET请求
        /// </summary>
        /// <param name="url">请求地址</param>
        /// <param name="param">参数</param>
        /// <returns>请求返回结果</returns>
        public static string Get(string url, string param)
        {
            UrlCheck(ref url);

            if (!string.IsNullOrEmpty(param))
                if (!param.StartsWith("?"))
                    param += "?" + param;
                else
                    param += param;

            HttpWebRequest request = WebRequest.Create(url) as HttpWebRequest;
            request.Method = "GET";
            request.ContentType = "application/x-www-form-urlencoded";

            return HttpRequest(request);
        }

        /// <summary>
        /// 请求的主体部分（由此完成请求并返回请求结果）
        /// </summary>
        /// <param name="request">请求的对象</param>
        /// <returns>请求返回结果</returns>
        private static string HttpRequest(HttpWebRequest request)
        {
            HttpWebResponse response = null;

            try
            {
                response = request.GetResponse() as HttpWebResponse;
            }
            catch (WebException ex)
            {
                response = ex.Response as HttpWebResponse;
            }

            if (response == null)
            { 
                return null;
            }

            string result = string.Empty;
            using (StreamReader reader = new StreamReader(response.GetResponseStream()))
            {
                result = reader.ReadToEnd();
            }
             
            return result;

        }

        /// <summary>
        /// URL拼写完整性检查
        /// </summary>
        /// <param name="url">待检查的URL</param>
        private static void UrlCheck(ref string url)
        {
            if (!url.StartsWith("http://") && !url.StartsWith("https://"))
                url = "http://" + url;
        }
    }
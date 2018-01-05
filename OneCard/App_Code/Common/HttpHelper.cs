using System;
using System.Collections.Generic;
using System.Configuration;
using System.IO;
using System.Net;
using System.Net.Security;
using System.Security.Cryptography;
using System.Text;
using System.Web;

/// <summary>
/// HttpHelper 的摘要说明
/// </summary>
public class HttpHelper
{
    private static readonly string _defaultUserAgent = "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.2; SV1; .NET CLR 1.1.4322; .NET CLR 2.0.50727)";
    private static readonly string _queryUrl = ConfigurationManager.AppSettings["QueryUrl"];
    private static readonly string _payUrl = ConfigurationManager.AppSettings["PayUrl"];
    private static readonly string _zzOrderChangeUrl = ConfigurationManager.AppSettings["ZZOrderChangeUrl"];
    private static readonly string _zzOrderCardQueryUrl = ConfigurationManager.AppSettings["ZZOrderCardQueryUrl"];
    private static readonly string _zzOrderCardCountUrl = ConfigurationManager.AppSettings["ZZOrderCardCountUrl"];
    private static readonly string _zzOrderDistrabutionUrl = ConfigurationManager.AppSettings["ZZOrderDistrabutionUrl"];
    private static readonly string _zzOrderListDistrabutionUrl = ConfigurationManager.AppSettings["ZZOrderListDistrabutionUrl"];
    private static readonly string _zzGetPhotoUrl = ConfigurationManager.AppSettings["ZZGetPhotoUrl"];
    private static readonly string _zzActivationCardUrl = ConfigurationManager.AppSettings["ZZActivationCardUrl"];
    private static readonly string _zzReceiveCardQueryUrl = ConfigurationManager.AppSettings["ZZReceiveCardQueryUrl"];
    private static readonly string _zzPayCanalDataQueryUrl = ConfigurationManager.AppSettings["ZZPayCanalDataQueryUrl"];
    private static readonly string _zzParkConSumerQueryUrl = ConfigurationManager.AppSettings["ZZParkConSumerQueryUrl"];
    private static readonly string _zzCardConSumerQueryUrl = ConfigurationManager.AppSettings["ZZCardConSumerQueryUrl"];
    private static readonly string _zzTradeQueryUrl = ConfigurationManager.AppSettings["ZZTradeQueryUrl"];
    private static readonly string _tokenKey = ConfigurationManager.AppSettings["TokenKey"];
    private static readonly string _zzTokenKey = ConfigurationManager.AppSettings["ZZTokenKey"];

    public static string PostRequest(TradeType tradeType, Dictionary<string, string> postData)
    {
        string url = "";
        if (tradeType == TradeType.Query)
        {
            url = _queryUrl;
        }
        else if (tradeType == TradeType.Pay)
        {
            url = _payUrl;
        }
        //构造请求参数
        postData = SortDictionary(postData);//排序后的集合
        string token = _tokenKey;
        string postStr = getAppentStr(postData, token);
        string md5Token = get32ByteMd5(postStr);//生成Token
        postStr += "&TOKEN=" + md5Token;
        //发送请求
        HttpWebResponse postResponse = CreatePostHttpResponse(url, postStr, "", false, Encoding.UTF8);
        Stream stream = postResponse.GetResponseStream();   //获取响应的字符串流  
        StreamReader sr = new StreamReader(stream); //创建一个stream读取流  
        string html = sr.ReadToEnd();   //从头读到尾，放到字符串html
        return html;
    }

    public static string ZZPostRequest(TradeType tradeType, Dictionary<string, string> postData, TokenType tokenType)
    {
        string url = "";
        if (tradeType == TradeType.ZZOrderChange)
        {
            url = _zzOrderChangeUrl;
        }
        else if (tradeType == TradeType.ZZOrderCardQuery)
        {
            url = _zzOrderCardQueryUrl;
        }
        else if (tradeType == TradeType.ZZOrderCardCount)
        {
            url = _zzOrderCardCountUrl;
        }
        else if (tradeType == TradeType.ZZOrderDistrabution)
        {
            url = _zzOrderDistrabutionUrl;
        }
        else if (tradeType == TradeType.ZZOrderListDistrabution)
        {
            url = _zzOrderListDistrabutionUrl;
        }
        else if (tradeType == TradeType.ZZGetPhoto)
        {
            url = _zzGetPhotoUrl;
        }
        else if (tradeType == TradeType.ZZActivationCard)
        {
            url = _zzActivationCardUrl;
        }
        else if (tradeType == TradeType.ZZReceiveCardQuery)
        {
            url = _zzReceiveCardQueryUrl;
        }
        else if (tradeType == TradeType.ZZPayCanalDataQuery)
        {
            url = _zzPayCanalDataQueryUrl;
        }
        else if (tradeType == TradeType.ZZParkConSumerQuery)
        {
            url = _zzParkConSumerQueryUrl;
        }
        else if (tradeType == TradeType.ZZCardConSumerQuery)
        {
            url = _zzCardConSumerQueryUrl;
        }
        else if (tradeType == TradeType.ZZTradeQuery)
        {
            url = _zzTradeQueryUrl;
        }
        //构造请求参数
        Dictionary<string, string> realPostData = postData;
        postData = SortDictionary(postData);//排序后的集合

        string token = _zzTokenKey;
        string postStr = getAppentStr(postData, token);
        string md5Token = get32ByteMd5(postStr);//生成Token
        postStr = geRequestStr(realPostData, md5Token);
        //发送请求
        HttpWebResponse postResponse = ZZCreatePostHttpResponse(url, postStr, "", false, Encoding.UTF8);
        Stream stream = postResponse.GetResponseStream();   //获取响应的字符串流  
        StreamReader sr = new StreamReader(stream); //创建一个stream读取流  
        string html = sr.ReadToEnd();   //从头读到尾，放到字符串html
        return html;
    }
    public static string ZZPostRequest(TradeType tradeType, Dictionary<string, string> postData)
    {
        return ZZPostRequest(tradeType, postData, TokenType.ZZToken);
    }

    public enum TradeType
    {
        Query,
        Pay,
        ZZOrderChange,
        ZZGetPhoto,
        ZZOrderCardQuery,
        ZZOrderCardCount,
        ZZOrderDistrabution,
        ZZOrderListDistrabution,
        ZZActivationCard,
        ZZReceiveCardQuery,
        ZZPayCanalDataQuery,
        ZZParkConSumerQuery,
        ZZCardConSumerQuery,
        ZZTradeQuery
    }
    public enum TokenType
    {
        JFToken,
        ZZToken
    }

    public static Dictionary<string, string> SortDictionary(Dictionary<string, string> dataDictionary)
    {
        Dictionary<string, string> returnDictionary = new Dictionary<string, string>();
        if (dataDictionary != null && dataDictionary.Count > 0)
        {
            List<KeyValuePair<string, string>> lst = new List<KeyValuePair<string, string>>(dataDictionary);
            lst.Sort(delegate (KeyValuePair<string, string> s1, KeyValuePair<string, string> s2)
            {
                return s1.Key.ToUpper().CompareTo(s2.Key.ToUpper());
            });
            foreach (KeyValuePair<string, string> item in lst)
            {
                returnDictionary.Add(item.Key.ToUpper(), item.Value);
            }
        }

        return returnDictionary;
    }

    private static string getAppentStr(Dictionary<string, string> dataDictionary, string key)
    {
        return getAppentStr(dataDictionary, key, true);
    }
    private static string getAppentStr(Dictionary<string, string> dataDictionary, string key, bool hasChannelKey)
    {
        if (hasChannelKey) dataDictionary.Add("CHANNELKEY", key);
        //拼接字符串
        string sign = "";
        foreach (KeyValuePair<string, string> item in dataDictionary)
        {
            //如果值是空，或者Name是TOKEN，去除
            if (string.IsNullOrEmpty(item.Value) || item.Key.ToUpper() == "TOKEN")
            {
                continue;
            }
            sign += item.Key + "=" + item.Value + "&";
        }
        if (sign.Length > 0)
        {
            sign = sign.Substring(0, sign.Length - 1);
            sign = sign.ToUpper();
        }
        return sign;
    }

    private static string geRequestStr(Dictionary<string, string> dataDictionary,string m5Token)
    {
        dataDictionary.Remove("CHANNELKEY");
        dataDictionary.Add("token", m5Token.ToUpper());
        //拼接字符串
        string sign = "{";
        foreach (KeyValuePair<string, string> item in dataDictionary)
        {
            sign += "\""+item.Key + "\":\"" + item.Value + "\",";
        }
        if (sign.Length > 0)
        {
            sign = sign.Substring(0, sign.Length - 1);
            sign = sign + "}";
        }
        return sign;
    }

    public static string get32ByteMd5(String s)
    {
        MD5 md5 = new MD5CryptoServiceProvider();
        byte[] bytes = System.Text.Encoding.UTF8.GetBytes(s);
        bytes = md5.ComputeHash(bytes);
        md5.Clear();

        string ret = "";
        for (int i = 0; i < bytes.Length; i++)
        {
            ret += Convert.ToString(bytes[i], 16).PadLeft(2, '0');
        }

        return ret.PadLeft(32, '0');
    }

    private static HttpWebResponse CreatePostHttpResponse(string url, string postData, string postDataKey, bool isHttps, Encoding charset)
    {
        HttpWebRequest request = null;
        if (isHttps)
        {
            //HTTPSQ请求  
            ServicePointManager.ServerCertificateValidationCallback = new RemoteCertificateValidationCallback(delegate
            {
                return true;
            });
            request = WebRequest.Create(url) as HttpWebRequest;
            request.ProtocolVersion = HttpVersion.Version10;
        }
        else
        {
            request = WebRequest.Create(url) as HttpWebRequest;
        }

        request.Method = "POST";
        //request.ContentType = "application/x-www-form-urlencoded";
        request.ContentType = "application/json";
        request.UserAgent = _defaultUserAgent;
        request.Proxy = null;
        byte[] data;
        if (postDataKey.Length > 0)
        {
            data = charset.GetBytes(string.Format("{0}={1}", postDataKey, postData));
        }
        else
        {
            data = charset.GetBytes(postData);
        }

        using (Stream stream = request.GetRequestStream())
        {
            stream.Write(data, 0, data.Length);
        }

        return request.GetResponse() as HttpWebResponse;
    }

    private static HttpWebResponse ZZCreatePostHttpResponse(string url, string postData, string postDataKey, bool isHttps, Encoding charset)
    {
        HttpWebRequest request = null;
        if (isHttps)
        {
            //HTTPSQ请求  
            ServicePointManager.ServerCertificateValidationCallback = new RemoteCertificateValidationCallback(delegate
            {
                return true;
            });
            request = WebRequest.Create(url) as HttpWebRequest;
            request.ProtocolVersion = HttpVersion.Version10;
        }
        else
        {
            request = WebRequest.Create(url) as HttpWebRequest;
        }

        request.Method = "POST";
        //request.ContentType = "application/x-www-form-urlencoded";
        request.ContentType = "application/json";
        request.UserAgent = _defaultUserAgent;
        request.Proxy = null;

        using (StreamWriter stream =new StreamWriter(request.GetRequestStream()))
        {
            stream.Write(postData);
            stream.Close();
        }

        return request.GetResponse() as HttpWebResponse;
    }
}
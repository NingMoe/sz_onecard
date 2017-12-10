using System;
using System.Web;
using System.Xml;
using System.Collections;
using System.Net;
using System.Text;
using System.IO;
using System.Xml.Serialization;

/// <summary>
/// Summary description for WebSvcCaller
/// </summary>
public class WebSvcCallerPost
{
    //<webServices>
    //  <protocols>
    //    <add name="HttpGet"/>
    //    <add name="HttpPost"/>
    //  </protocols>
    //</webServices>
    private static Hashtable _xmlNamespaces = new Hashtable();//缓存xmlNamespace，避免重复调用GetNamespace

    public static XmlDocument QuerySoapWebService(String URL, String MethodName, string strXML)
    {
        if (_xmlNamespaces.ContainsKey(URL))
        {
            return QuerySoapWebService(URL, MethodName, strXML, _xmlNamespaces[URL].ToString());
        }
        else
        {
            return QuerySoapWebService(URL, MethodName, strXML, GetNamespace(URL));
        }
    }

    private static XmlDocument QuerySoapWebService(String URL, String MethodName, string strXML, string XmlNs)
    {
        _xmlNamespaces[URL] = XmlNs;//加入缓存，提高效率
        HttpWebRequest request = (HttpWebRequest)HttpWebRequest.Create(URL);
        request.Method = "POST";
        SetWebRequest(request);
        string strSoap = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\"><soapenv:Header/><soapenv:Body><ser:invoke xmlns:ser=\"http://service.hzyl.nh.founder.com/\">" + strXML + "</ser:invoke></soapenv:Body></soapenv:Envelope>";
        byte[] data = Encoding.UTF8.GetBytes(strSoap);
        WriteRequestData(request, data);
        XmlDocument doc = new XmlDocument(), doc2 = new XmlDocument();
        doc = ReadXmlResponse(request.GetResponse());

        //XmlNamespaceManager mgr = new XmlNamespaceManager(doc.NameTable);
        //mgr.AddNamespace("soap", "http://schemas.xmlsoap.org/soap/envelope/");
        //String RetXml = doc.SelectSingleNode("//soap:Body/*/*", mgr).InnerXml;
        //doc2.LoadXml("<root>" + RetXml + "</root>");

        XmlNamespaceManager mgr = new XmlNamespaceManager(doc.NameTable);
        mgr.AddNamespace("soapenv", doc.DocumentElement.NamespaceURI);
        String RetXml = doc.SelectSingleNode("/soapenv:Envelope/soapenv:Body", mgr).LastChild.InnerXml;
        doc2.LoadXml(RetXml);
        AddDelaration(doc2);
        return doc2;
    }

    private static string GetNamespace(String URL)
    {
        HttpWebRequest request = (HttpWebRequest)WebRequest.Create(URL + "?wsdl");
        SetWebRequest(request);
        WebResponse response = request.GetResponse();
        StreamReader sr = new StreamReader(response.GetResponseStream(), Encoding.UTF8);
        XmlDocument doc = new XmlDocument();
        doc.LoadXml(sr.ReadToEnd());
        sr.Close();
        return doc.SelectSingleNode("//@targetNamespace").Value;
    }

    private static void SetWebRequest(HttpWebRequest request)
    {
        request.Credentials = CredentialCache.DefaultCredentials;
        request.Timeout = 10000;
    }

    private static void WriteRequestData(HttpWebRequest request, byte[] data)
    {
        request.ContentLength = data.Length;
        Stream writer = request.GetRequestStream();
        writer.Write(data, 0, data.Length);
        writer.Close();
    }

    private static XmlDocument ReadXmlResponse(WebResponse response)
    {
        StreamReader sr = new StreamReader(response.GetResponseStream(), Encoding.UTF8);
        String retXml = sr.ReadToEnd();
        sr.Close();
        XmlDocument doc = new XmlDocument();
        doc.LoadXml(retXml);
        return doc;
    }

    private static void AddDelaration(XmlDocument doc)
    {
        XmlDeclaration decl = doc.CreateXmlDeclaration("1.0", "utf-8", null);
        doc.InsertBefore(decl, doc.DocumentElement);
    }

    /**/
    /// <summary>
    /// 需要WebService支持Post调用
    /// </summary>
    public static XmlDocument QueryPostWebService(String URL, String MethodName, Hashtable Pars)
    {
        HttpWebRequest request = (HttpWebRequest)HttpWebRequest.Create(URL + "/" + MethodName);
        request.Method = "POST";
        request.ContentType = "application/x-www-form-urlencoded";
        SetWebRequest(request);
        byte[] data = EncodePars(Pars);
        WriteRequestData(request, data);
        return ReadXmlResponse(request.GetResponse());
    }

    /**/
    /// <summary>
    /// 需要WebService支持Get调用
    /// </summary>
    //public static XmlDocument QueryGetWebService(String URL, String MethodName, Hashtable Pars)
    //{
    //    HttpWebRequest request = (HttpWebRequest)HttpWebRequest.Create(URL + "/" + MethodName + "?" + ParsToString(Pars));
    //    request.Method = "GET";
    //    request.ContentType = "application/x-www-form-urlencoded";
    //    SetWebRequest(request);
    //    return ReadXmlResponse(request.GetResponse());
    //}

    private static byte[] EncodePars(Hashtable Pars)
    {
        return Encoding.UTF8.GetBytes(ParsToString(Pars));
    }

    private static String ParsToString(Hashtable Pars)
    {
        StringBuilder sb = new StringBuilder();
        foreach (string k in Pars.Keys)
        {
            if (sb.Length > 0)
            {
                sb.Append("&");
            }
            sb.Append(HttpUtility.UrlEncode(k) + "=" + HttpUtility.UrlEncode(Pars[k].ToString()));
        }
        return sb.ToString();
    }
}
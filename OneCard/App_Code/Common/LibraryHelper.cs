using System;
using System.Collections.Generic;
using System.Web;
using System.Text;
using System.Xml;
using System.Data;


/**********************************
 * 图书馆业务帮助类
 * 2015-1-15
 * gl
 * 初次编写
 * ********************************/
public class LibraryHelper
{
    /// <summary>
    /// 获取注销验证结果
    /// </summary>
    /// <param name="cardNo">用户卡号</param>
    /// <returns>注销结果以及原因</returns>
    public static string cancelCardCheck(string cardNo)
    {
        //调用接口
        WebReference.SzlibServiceHandlerService libService = new WebReference.SzlibServiceHandlerService();
        libService.Url = System.Web.Configuration.WebConfigurationManager.AppSettings["LibraryURI"];
        libService.Timeout = 120000;
        string retMsg = "";
        string rsp = string.Empty;
        try
        {
            rsp = libService.RequestHandle(SetupXML(cardNo,"0004"));
            retMsg = AnalyticCardCheckXML(rsp.Replace("\r","").Replace("\n",""));
        }
        catch (Exception ex)
        {
            retMsg = "Exception: " + ex.Message;
        }
       
       return retMsg;
    }
    /// <summary>
    /// 解析图书馆返回报文
    /// </summary>
    /// <param name="xml">图书馆返回报文</param>
    /// <returns>返回退卡信息</returns>
    private static string AnalyticCardCheckXML(string xml)
    {
        string homeDomain = "";
        string tradeId = "";
        string respCode = "";
        string respDesc = "";
        XmlDocument dom = new XmlDocument();
        dom.LoadXml(xml);
        XmlNodeList xnList = dom.SelectNodes(@"//SVCCONT");
        if (xnList.Count == 1)
        {
            xnList = dom.SelectNodes(@"//PICKUPRSP");

            foreach (XmlNode node in xnList)
            {
                XmlNodeList rsp = node.ChildNodes;
                foreach (XmlNode n in rsp)
                {
                    if (n.Name == "HOMEDOMAIN")
                    {
                        homeDomain = n.InnerText;
                    }
                    else if (n.Name == "TRANSIDH")
                    {
                        tradeId = n.InnerText;
                    }
                    else if (n.Name == "RESPCODE")
                    {
                        respCode = n.InnerText;
                    }
                    else if (n.Name == "RESPDESC")
                    {
                        respDesc = n.InnerText;
                    }
                }

            }
        }

        if (respCode == "0000")
            return "0000";
        else
            return respDesc;
    }

    /// <summary>
    /// 获取欠款欠书信息
    /// </summary>
    /// <param name="cardNo">用户卡号</param>
    /// <param name="oweBookTable">欠书DataTable</param>
    /// <param name="oweMoneyTable">欠款DataTable</param>
    /// <returns>欠书情况</returns>
    public static void getOweTable(string cardNo,out DataTable oweBookTable, out DataTable oweMoneyTable,out string errorInfo)
    {
        //调用接口
        WebReference.SzlibServiceHandlerService libService = new WebReference.SzlibServiceHandlerService();
        libService.Url = System.Web.Configuration.WebConfigurationManager.AppSettings["LibraryURI"];
        libService.Timeout = 120000;
        string rsp = string.Empty;
  
        oweBookTable = new DataTable();
        oweMoneyTable =new DataTable();
        errorInfo = "";
        try
        {
            rsp = libService.RequestHandle(SetupXML(cardNo, "0005"));
            AnalyticOweXML(rsp.Replace("\r", "").Replace("\n", ""), out oweBookTable, out oweMoneyTable, out errorInfo);

        }
        catch (Exception ex)
        {
            errorInfo = "Exception: "+ex.Message;
        }

        
    }


    /// <summary>
    /// 解析图书馆返回报文
    /// </summary>
    /// <param name="xml">图书馆返回报文</param>
    /// <returns>返回欠款欠书信息</returns>
    private static void AnalyticOweXML(string xml, out DataTable oweBookTable, out DataTable oweMoneyTable, out string errorInfo)
    {
        string homeDomain = "";
        string tradeId = "";
        string respCode = "";
        string respDesc = "";
        oweBookTable = new DataTable();
        oweMoneyTable = new DataTable();
        errorInfo = "";

        XmlDocument dom = new XmlDocument();
        dom.LoadXml(xml);
        XmlNodeList xnList = dom.SelectNodes(@"//SVCCONT");
        if (xnList.Count == 1)
        {
            xnList = dom.SelectNodes(@"//PICKUPRSP");

            foreach (XmlNode node in xnList)
            {
                XmlNodeList rsp = node.ChildNodes;
                foreach (XmlNode n in rsp)
                {
                    if (n.Name == "HOMEDOMAIN")
                    {
                        homeDomain = n.InnerText;
                    }
                    else if (n.Name == "TRANSIDH")
                    {
                        tradeId = n.InnerText;
                    }
                    else if (n.Name == "RESPCODE")
                    {
                        respCode = n.InnerText;
                    }
                    else if (n.Name == "RESPDESC")
                    {
                        respDesc = n.InnerText;
                    }
                }

                //解析欠款情况
                XmlNodeList xnMoneyList = dom.SelectNodes(@"//OWEMONEYRSP");

                if (xnMoneyList.Count > 0)
                {
                    oweMoneyTable = AnalyticOweMoneyXML(xnMoneyList);
                }

                //解析欠书情况
                XmlNodeList xnBookList = dom.SelectNodes(@"//OWEBOOKRSP");
                if (xnBookList.Count > 0)
                {
                    oweBookTable = AnalyticOweBookXML(xnBookList);
                }
            }
        }
        if (respCode == "9999")
            errorInfo = respDesc;
    }

     /// <summary>
    /// 初始化欠书明细的DataTable
    /// </summary>
    private static DataTable InitializationOweBookTable()
    {
        DataTable dt = new DataTable();
        dt.Columns.Add("TITLE");
        dt.Columns.Add("AUTHOR");
        dt.Columns.Add("ISBN");
        dt.Columns.Add("INDEX");
        dt.Columns.Add("PRESS");
        dt.Columns.Add("PUBLISHDATE");
        dt.Columns.Add("BORROWTIME");
        return dt;
    }

    /// <summary>
    /// 初始化欠款明细的DataTable
    /// </summary>
    private static DataTable InitializationOweMoneyTable()
    {
        DataTable dt = new DataTable();
        dt.Columns.Add("OWETYPE");
        dt.Columns.Add("OWEMONEY");
        dt.Columns.Add("OWEMONEYTIME");
        return dt;
    }
    
    /// <summary>
    /// 解析xml欠款信息
    /// </summary>
    /// <param name="xnMoneyList">欠款信息xml</param>
    /// <returns>欠款情况</returns>
    private static DataTable AnalyticOweMoneyXML(XmlNodeList xnMoneyList)
    {
        DataTable dt = InitializationOweMoneyTable();
        foreach (XmlNode node in xnMoneyList)
        {
            XmlNodeList rspMoney = node.ChildNodes;
            DataRow dr = dt.NewRow();
            foreach (XmlNode n in rspMoney)
            {
                if (n.Name == "OWETYPE")
                {
                    dr["OWETYPE"] = n.InnerText;
                }
                else if (n.Name == "OWEMONEY")
                {
                    dr["OWEMONEY"] = n.InnerText;
                }
                else if (n.Name == "OWEMONEYTIME")
                {
                    if (!string.IsNullOrEmpty(n.InnerText))
                    {
                        dr["OWEMONEYTIME"] = DateTime.ParseExact(n.InnerText, "yyyyMMddhhmmss", System.Globalization.CultureInfo.CurrentCulture);
                    }

                }
            }
            dt.Rows.Add(dr);
        }
        return dt;
    }


     /// <summary>
    /// 解析xml欠书信息
    /// </summary>
    /// <param name="xnMoneyList">欠书信息xml</param>
    /// <returns>欠书情况</returns>
    private static DataTable AnalyticOweBookXML(XmlNodeList xnBookList)
    {
        DataTable dt = InitializationOweBookTable();
        foreach (XmlNode node in xnBookList)
        {
            XmlNodeList rspbook = node.ChildNodes;
            DataRow dr = dt.NewRow();
            foreach (XmlNode n in rspbook)
            {
                if (n.Name == "TITLE")
                {
                    dr["TITLE"] = n.InnerText;
                }
                else if (n.Name == "AUTHOR")
                {
                    dr["AUTHOR"] = n.InnerText;
                }
                else if (n.Name == "ISBN")
                {
                    dr["ISBN"] = n.InnerText;
                }
                else if (n.Name == "INDEX")
                {
                    dr["INDEX"] = n.InnerText;
                }
                else if (n.Name == "PRESS")
                {
                    dr["PRESS"] = n.InnerText;
                }
                else if (n.Name == "PUBLISHDATE")
                {
                    dr["PUBLISHDATE"] = n.InnerText;
                }
                else if (n.Name == "BORROWTIME")
                {
                    if (!string.IsNullOrEmpty(n.InnerText))
                    {
                        dr["BORROWTIME"] = DateTime.ParseExact(n.InnerText, "yyyyMMddhhmmss", System.Globalization.CultureInfo.CurrentCulture);
                    }
                }

            }
            dt.Rows.Add(dr);
        }
        return dt;
    }

    /// <summary>
    /// 构造请求XML
    /// </summary>
    /// <param name="cardNo">cardNo</param>
    /// <param name="bipCode">bipCode</param>
    /// <returns>请求的XML</returns>
    private static string SetupXML(string cardNo,string bipCode)
    {
        StringBuilder xml = new StringBuilder();
        xml.AppendLine("<SVC>");
        xml.AppendLine("<SVCHEAD>");
        xml.AppendLine("<ORIGDOMAIN>01</ORIGDOMAIN>");
        xml.AppendLine("<HOMEDOMAIN>L1</HOMEDOMAIN>");
        xml.AppendLine("<BIPCODE>");
        xml.Append(bipCode);
        xml.AppendLine("</BIPCODE>");
        xml.AppendLine("<ACTIONCODE>0</ACTIONCODE>");
        xml.AppendLine("<TRANSIDO>");
        xml.Append(Guid.NewGuid());
        xml.AppendLine("</TRANSIDO>");
        xml.AppendLine("<PROCESSTIME>");
        xml.Append(DateTime.Now.ToString("yyyyMMddHHmmss"));
        xml.AppendLine("</PROCESSTIME>");
        xml.AppendLine("</SVCHEAD>");
        xml.AppendLine("<SVCCONT>");
        xml.AppendLine("<PICKUPREQ>");
        xml.AppendLine("<CARDNO>");
        xml.Append(cardNo);
        xml.AppendLine("</CARDNO>");
        xml.AppendLine("</PICKUPREQ>");
        xml.AppendLine("</SVCCONT>");
        xml.AppendLine("</SVC>");
        XmlDocument dom = new XmlDocument();
        dom.LoadXml(xml.ToString());
        byte[] utf8Buf = Encoding.UTF8.GetBytes(xml.ToString());
        byte[] gbkBuf = Encoding.Convert(Encoding.UTF8, Encoding.GetEncoding("gb2312"), utf8Buf);
        string strGB2312 = Encoding.GetEncoding("gb2312").GetString(gbkBuf);
        return strGB2312;
    }
}
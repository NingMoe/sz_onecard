using System;
using System.Collections.Generic;
using System.Web;
using System.Text;
using System.Xml;
using System.Data;


/**********************************
 * 休闲订单接口同步
 * 2015-5-05
 * jbb
 * 初次编写
 * ********************************/
public class RelaxWebServiceHelper
{

    /// <summary>
    /// 休闲订单状态变更通知
    /// </summary>
    /// <param name="orderid">订单号</param>
    /// <param name="detailid">子订单号</param>
    /// <param name="cardNo">电子钱包卡号</param>
    /// <param name="orderstate">订单类型</param>
    /// <param name="trackingcopname">物流公司</param>
    /// <param name="trackingno">物流号</param>
    /// <param name="remark">备注</param>
    /// <param name="errorInfo">返回消息</param>
    public static string RelaxOrderTypeInfo(DataTable dt)
    {
        if (dt == null || dt.Rows.Count < 1)
        {
            return "待请求数据为空";
        }

        //调用接口
        RelaxWebService.SMKWebServiceService smkWebService= new RelaxWebService.SMKWebServiceService();
        //WebReference.SzlibServiceHandlerService libService = new WebReference.SzlibServiceHandlerService();
        //libService.Url = System.Web.Configuration.WebConfigurationManager.AppSettings["RelaxServiceURL"];
        smkWebService.Url= System.Web.Configuration.WebConfigurationManager.AppSettings["RelaxServiceURL"];
        smkWebService.Timeout = 120000;
        string rsp = string.Empty;
        try
        {
            rsp = smkWebService.notifyYChg(SetupXML(dt));
            return AnalyticCardCheckXML(rsp.Replace("\r", "").Replace("\n", ""));
        }
        catch (Exception ex)
        {
            return "Exception: " + ex.Message;
        }
    }

    /// <summary>
    /// 组装请求报文
    /// </summary>
    /// <param name="orderid">订单号</param>
    /// <param name="detailid">子订单号</param>
    /// <param name="cardNo">电子钱包卡号</param>
    /// <param name="orderstate">订单类型</param>
    /// <param name="trackingcopname">物流公司</param>
    /// <param name="trackingno">物流号</param>
    /// <param name="remark">备注</param>
    /// <returns></returns>
    private static string SetupXML(DataTable dt)
    {
        StringBuilder xml = new StringBuilder();
        //报文头
        xml.AppendLine("<SVC>");
        xml.AppendLine("<SVCHEAD>");
        xml.AppendLine("<ORIGDOMAIN>SMK</ORIGDOMAIN>");
        xml.AppendLine("<HOMEDOMAIN>APP</HOMEDOMAIN>");
        xml.AppendLine("<BIPCODE>1044</BIPCODE>");
        xml.AppendLine("<ACTIONCODE>0</ACTIONCODE>");
        xml.AppendLine(string.Format("<TRANSIDO>{0}</TRANSIDO>", Guid.NewGuid()));
        xml.AppendLine(string.Format("<PROCID>{0}</PROCID>", Guid.NewGuid()));
        xml.AppendLine(string.Format("<PROCESSTIME>{0}</PROCESSTIME>", DateTime.Now.ToString("yyyyMMddHHmmss")));
        xml.AppendLine("</SVCHEAD>");
        xml.AppendLine("<SVCCONT>");

        //组装报文体
        foreach (DataRow item in dt.Rows)
        {
            string orderid = item["ORDERNO"].ToString();                //订单号
            string detailid = item["DETAILID"].ToString();              //子订单号
            string cardNo = item["CARDNO"].ToString();                  //卡号
            string orderstate = item["ORDERSTATE"].ToString();          //订单状态
            string trackingcopname = item["LOGISTICSCOMPANY"].ToString();//物流公司名称
            string trackingno = item["TRACKINGNO"].ToString();          //物流号
            string remark = item["REMARK"].ToString();                  //备注

            xml.AppendLine("<ORDERREQ>");
            xml.AppendLine(string.Format("<ORDERID>{0}</ORDERID>", orderid));
            xml.AppendLine(string.Format("<DETAILID>{0}</DETAILID>", detailid));
            xml.AppendLine(string.Format("<CARDNO>{0}</CARDNO>", cardNo));
            xml.AppendLine(string.Format("<ORDERSTATE>{0}</ORDERSTATE>", orderstate));
            xml.AppendLine(string.Format("<LOGISTICSCOMPANY>{0}</LOGISTICSCOMPANY>", trackingcopname));
            xml.AppendLine(string.Format("<TRACKINGNO>{0}</TRACKINGNO>", trackingno));
            xml.AppendLine(string.Format("<REMARK>{0}</REMARK>", remark));
            xml.AppendLine("</ORDERREQ>");
        }

        xml.AppendLine("</SVCCONT>");
        xml.AppendLine("</SVC>");
        XmlDocument dom = new XmlDocument();
        dom.LoadXml(xml.ToString());
        byte[] utf8Buf = Encoding.UTF8.GetBytes(xml.ToString());
        byte[] gbkBuf = Encoding.Convert(Encoding.UTF8, Encoding.GetEncoding("gb2312"), utf8Buf);
        string strGB2312 = Encoding.GetEncoding("gb2312").GetString(gbkBuf);
        return strGB2312;
    }

    /// <summary>
    /// 解析手机端返回报文
    /// </summary>
    /// <param name="xml">手机端返回报文</param>
    /// <returns>返回校验信息</returns>
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
            return respCode + respDesc;
    }
}

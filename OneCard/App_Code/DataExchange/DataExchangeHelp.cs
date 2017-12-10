//-----------------------------------------------------------------------
// <copyright file="DataExchangeHelp.cs" company="linkage">
//   * 功能名: 同步帮助类

// </copyright>
// <author>hzl</author>
//   * 更改日期      姓名           摘要 
//   * ----------    -----------    --------------------------------
//   * 2013/08/21    hzl          初次开发   

//-----------------------------------------------------------------------

namespace DataExchange
{
    using System;
    using System.Collections.Generic;
    using System.Configuration;
    using System.Data;
    using System.Text;
    using System.Threading;
    using System.Xml;
    using System.Collections;

    /// <summary>
    /// 同步帮助类  
    /// </summary>
    public static class DataExchangeHelp
    {
        /// <summary>
        /// 同步请求
        /// </summary>
        /// <param name="syncRequest">同步请求集合 </param>
        /// <param name="syncResponse">同步响应集合 </param>
        /// <returns>同步是否成功 </returns>
        public static bool Sync(SyncRequest syncRequest, out SyncRequest syncResponse, out string msg)
        {
            // 调用接口
            string rsp = string.Empty;
            try
            {
                if (syncRequest.TransCode == "9506" || syncRequest.TransCode == "9501" || syncRequest.TransCode == "9505" || syncRequest.TransCode == "9507" || syncRequest.TransCode == "9508" || syncRequest.TransCode == "9510" || syncRequest.TransCode == "9511")
                {
                    //方式一
                    //Hashtable pars = new Hashtable();
                    //pars["message"] = SetupXML(syncRequest);
                    //XmlDocument doc = WebServiceInvoke.QueryPostWebService(ConfigurationManager.AppSettings.Get("Electric.CenterProcess"), "HandleInfoChange", pars);
                    //rsp = doc.OuterXml;

                    //方式二
                    //Hashtable pars = new Hashtable();
                    //pars["message"] = SetupXML(syncRequest);
                    //rsp = WebServiceInvoke.QuerySoapWebService(ConfigurationManager.AppSettings.Get("Electric.CenterProcess"), "HandleInfoChange", pars);
                  
                    //方式三
                    XmlDocument doc = WebSvcCallerPost.QuerySoapWebService(ConfigurationManager.AppSettings.Get("WebSvcCallerURL"), "invoke", SetupXML(syncRequest));
                    rsp = doc.SelectSingleNode("/root").InnerXml;
                    //rsp = (string)WebServiceInvokeHelper.InvokeWebService(ConfigurationManager.AppSettings.Get("Electric.CenterProcess"), "HandleData", "HandleInfoChange", SetupXML(syncRequest).Split(';')); 
                    //rsp = (string)WebServiceInvokeHelper.InvokeWebService(ConfigurationManager.AppSettings.Get("Electric.CenterProcess"), "FrameInvokeService", "invoke", SetupXML(syncRequest).Split(';')); 
                }
            }
            catch (Exception ex)
            {
                rsp = "Exception: " + ex.Message;
            }
            // 分析及处理返回XML
            syncResponse = AnalyticXML(false, rsp, syncRequest);
            //syncResponse = AnalyticXMLTest(false, rsp, syncRequest);
            bool result = syncResponse.Code == "2000" ? true : false;
            msg = syncResponse.Message;
            UpdateSyncState(syncResponse.TradeID, syncResponse.CitizenCardNo, syncResponse.SyncCode, syncResponse.Message);
            return result;
        }


        public static bool Sync(SyncRequest syncRequest, out SyncRequest syncResponse)
        {
            // 调用接口
            string rsp = string.Empty;
            try
            {
                if (syncRequest.TransCode == "9506" || syncRequest.TransCode == "9501" || syncRequest.TransCode == "9505" || syncRequest.TransCode == "9507" || syncRequest.TransCode == "9508" || syncRequest.TransCode == "9510" || syncRequest.TransCode == "9511")
                {
                    //方式一
                    //Hashtable pars = new Hashtable();
                    //pars["message"] = SetupXML(syncRequest);
                    //XmlDocument doc = WebServiceInvoke.QueryPostWebService(ConfigurationManager.AppSettings.Get("Electric.CenterProcess"), "HandleInfoChange", pars);
                    //rsp = doc.OuterXml;

                    //方式二
                    //Hashtable pars = new Hashtable();
                    //pars["message"] = SetupXML(syncRequest);
                    //rsp = WebServiceInvoke.QuerySoapWebService(ConfigurationManager.AppSettings.Get("Electric.CenterProcess"), "HandleInfoChange", pars);

                    //方式三
                    XmlDocument doc = WebSvcCallerPost.QuerySoapWebService(ConfigurationManager.AppSettings.Get("WebSvcCallerURL"), "invoke", SetupXML(syncRequest));
                    rsp = doc.SelectSingleNode("/root").InnerXml;
                    //rsp = (string)WebServiceInvokeHelper.InvokeWebService(ConfigurationManager.AppSettings.Get("Electric.CenterProcess"), "HandleData", "HandleInfoChange", SetupXML(syncRequest).Split(';')); 
                    //rsp = (string)WebServiceInvokeHelper.InvokeWebService(ConfigurationManager.AppSettings.Get("Electric.CenterProcess"), "FrameInvokeService", "invoke", SetupXML(syncRequest).Split(';')); 
                }
            }
            catch (Exception ex)
            {
                rsp = "Exception: " + ex.Message;
            }
            // 分析及处理返回XML
            syncResponse = AnalyticXML(false, rsp, syncRequest);
            //syncResponse = AnalyticXMLTest(false, rsp, syncRequest);
            bool result = syncResponse.Code == "2000" ? true : false;
         
            UpdateSyncState(syncResponse.TradeID, syncResponse.CitizenCardNo, syncResponse.SyncCode, syncResponse.Message);
            return result;
        }

        /// <summary>
        /// DataTable转换
        /// </summary>
        /// <param name="dt">The DataTable.</param>
        /// <param name="batchID">任务编号</param>
        /// <param name="syncRequest">同步请求集合</param>
        /// <returns>是否转换成功</returns>
        public static bool ParseFormDataTable(DataTable dt, string tradeID, out SyncRequest syncRequest)
        {
            bool result = true;
            syncRequest = null;
            if (dt.Rows.Count == 1)
            {
                try
                {
                    if (dt.Rows[0]["TRANS_CODE"].ToString() == "9506")//修改资料
                    {
                        syncRequest = new UserInfoChangeSync();
                        syncRequest.ParseFormDataRow(dt.Rows[0]);
                        syncRequest.TradeID = tradeID;
                    }
                    else if (dt.Rows[0]["TRANS_CODE"].ToString() == "9501")//售卡
                    {
                        syncRequest = new CardSaleInfoSync();
                        syncRequest.ParseFormDataRow(dt.Rows[0]);
                        syncRequest.TradeID = tradeID;
                    }
                    else if (dt.Rows[0]["TRANS_CODE"].ToString() == "9505")//换卡
                    {
                        syncRequest = new CardChangeInfoSync();
                        syncRequest.ParseFormDataRow(dt.Rows[0]);
                        syncRequest.TradeID = tradeID;
                    }
                    else if (dt.Rows[0]["TRANS_CODE"].ToString() == "9507")//退卡,注销
                    {
                        syncRequest = new CardReturnInfoSync();
                        syncRequest.ParseFormDataRow(dt.Rows[0]);
                        syncRequest.TradeID = tradeID;
                    }
                    else if (dt.Rows[0]["TRANS_CODE"].ToString() == "9508")//售卡返销
                    {
                        syncRequest = new CardSaleRollbackInfoSync();
                        syncRequest.ParseFormDataRow(dt.Rows[0]);
                        syncRequest.TradeID = tradeID;
                    }
                    else if (dt.Rows[0]["TRANS_CODE"].ToString() == "9510")//换卡返销
                    {
                        syncRequest = new CardChangeRollbackInfoSync();
                        syncRequest.ParseFormDataRow(dt.Rows[0]);
                        syncRequest.TradeID = tradeID;
                    }
                    else if (dt.Rows[0]["TRANS_CODE"].ToString() == "9511")//退卡返销
                    {
                        syncRequest = new CardReturnRollbackInfoSync();
                        syncRequest.ParseFormDataRow(dt.Rows[0]);
                        syncRequest.TradeID = tradeID;
                    }
                }
                catch (ArgumentException ex)
                {
                    Common.Log.Error("调用接口转换错误", ex, "AppLog");
                    result = false;
                }
                catch (Exception ex)
                {
                    result = false;
                    throw ex;
                }
            }
            else
            {
                result = false;
            }
            return result;
        }

        /// <summary>
        /// 构造请求XML
        /// </summary>
        /// <param name="listSync">The list sync.</param>
        /// <returns>请求的XML</returns>
        private static string SetupXML(SyncRequest listSync)
        {
            StringBuilder xml = new StringBuilder();
            xml.AppendLine("<root>");
            //xml.AppendLine("<DATA_CARRIER>");
            xml.AppendLine(string.Format("<TRANS_CODE>{0}</TRANS_CODE>", listSync.TransCode));
            xml.AppendLine(string.Format("<CITIZEN_CARD_NO>{0}</CITIZEN_CARD_NO>", listSync.CitizenCardNo));
            xml.Append(listSync.SetupXML());
            //xml.AppendLine("</DATA_CARRIER>");
            //xml.AppendLine("<DATA_PKG_TYPE>");
            //xml.AppendLine("</DATA_PKG_TYPE>");
            //xml.AppendLine("<DATA_PKG_SUB_TYPE>");
            //xml.AppendLine("</DATA_PKG_SUB_TYPE>");
            //xml.AppendLine("<DATA_PKG_VERSION>");
            //xml.AppendLine("</DATA_PKG_VERSION>");
            //xml.AppendLine("<TERM_SEND_TIME>");
            //xml.AppendLine("</TERM_SEND_TIME>");
            //xml.AppendLine("<TXN_TP>");
            //xml.AppendLine("</TXN_TP>");
            //xml.AppendLine("<REQ_RSP_FLAG>");
            //xml.AppendLine("</REQ_RSP_FLAG>");
            //xml.AppendLine("<MSG_MAC>");
            //xml.AppendLine("</MSG_MAC>");
            //xml.AppendLine("<TERM_RSP_CODE>");
            //xml.AppendLine("</TERM_RSP_CODE>");
            xml.AppendLine("</root>");
            XmlDocument dom = new XmlDocument();
            dom.LoadXml(xml.ToString());
            byte[] utf8Buf = Encoding.UTF8.GetBytes(xml.ToString());
            byte[] gbkBuf = Encoding.Convert(Encoding.UTF8, Encoding.GetEncoding("gb2312"), utf8Buf);
            string strGB2312 = Encoding.GetEncoding("gb2312").GetString(gbkBuf);
            return strGB2312;
        }

        /// <summary>
        /// 分析结果XML
        /// </summary>
        /// <param name="isAsync">是否为异步请求.</param>
        /// <param name="xml">响应XML.</param>
        /// <param name="cardno">卡号.</param>
        /// <param name="tradeID">流水号.</param>
        /// <param name="requestList">同步请求集合.</param>
        /// <returns>响应结果集合结果</returns>
        private static SyncRequest AnalyticXML(bool isAsync, string xml, SyncRequest request)
        {
            List<SyncRequest> result = new List<SyncRequest>();
            string code, message;
            try
            {
                XmlDocument dom = new XmlDocument();
                if (!xml.Contains("<root>"))
                {
                    xml = "<root>" + xml + "</root>";
                }

                dom.LoadXml(xml);
                XmlNodeList xnList = dom.SelectNodes(@"//root");
                if (xnList.Count == 1)
                {
                    foreach (XmlNode node in xnList)
                    {
                        code = "";
                        message = "";
                        XmlNodeList rsp = node.ChildNodes;
                        foreach (XmlNode n in rsp)
                        {
                            if (n.Name == "CODE")
                            {
                                code = n.InnerText;
                            }
                            else if (n.Name == "MESSAGE")
                            {
                                message = n.InnerText;
                            }
                        }
                        if (request != null)
                        {
                            if (code == "2000")
                            {
                                request.Code = "2000";
                                request.SyncCode = "1";
                                request.Message = message;
                                request.SyncTime = DateTime.Now;
                            }
                            else
                            {
                                request.Code = "2001";
                                request.SyncCode = "0";
                                request.Message = message;
                                request.SyncTime = DateTime.Now;
                            }
                        }
                    }
                }
                else
                {
                    // 请求报文格式错误
                    message = xnList[0].ChildNodes.Item(2).InnerText;
                    request.SyncCode = "0";
                    request.Message = message;
                    request.SyncTime = DateTime.Now;
                }
            }
            // 未知异常捕获
            catch (Exception ex)
            {
                // 异常信息
                string exceptionMsg = string.Empty;
                if (xml.StartsWith("Exception:"))
                {
                    exceptionMsg = xml;
                }
                else
                {
                    exceptionMsg = ex.Message;
                }
                request.SyncCode = "0";
                request.Message = exceptionMsg;
                request.SyncTime = DateTime.Now;
            }
            return request;
        }

        private static SyncRequest AnalyticXMLTest(bool isAsync, string xml, SyncRequest request)
        {
            List<SyncRequest> result = new List<SyncRequest>();
            string code, message;
            try
            {
                XmlDocument dom = new XmlDocument();
                if (!xml.Contains("<root>"))
                {
                    xml = "<root>" + xml + "</root>";
                }

                dom.LoadXml(xml);
                XmlNodeList xnList = dom.SelectNodes(@"//DATA_CARRIER");
                if (xnList.Count == 1)
                {
                    foreach (XmlNode node in xnList)
                    {
                        code = "";
                        message = "";
                        XmlNodeList rsp = node.ChildNodes;
                        foreach (XmlNode n in rsp)
                        {
                            if (n.Name == "CODE")
                            {
                                code = n.InnerText;
                            }
                            else if (n.Name == "MESSAGE")
                            {
                                message = n.InnerText;
                            }
                        }
                        if (request != null)
                        {
                            if (code == "2000")
                            {
                                request.Code = "2000";
                                request.SyncCode = "1";
                                request.Message = message;
                                request.SyncTime = DateTime.Now;
                            }
                            else
                            {
                                request.Code = "2001";
                                request.SyncCode = "0";
                                request.Message = message;
                                request.SyncTime = DateTime.Now;
                            }
                        }
                    }
                }
                else
                {
                    // 请求报文格式错误
                    message = xnList[0].ChildNodes.Item(2).InnerText;
                    request.SyncCode = "0";
                    request.Message = message;
                    request.SyncTime = DateTime.Now;
                }
            }
            // 未知异常捕获
            catch (Exception ex)
            {
                // 异常信息
                string exceptionMsg = string.Empty;
                if (xml.StartsWith("Exception:"))
                {
                    exceptionMsg = xml;
                }
                else
                {
                    exceptionMsg = ex.Message;
                }
                request.SyncCode = "0";
                request.Message = exceptionMsg;
                request.SyncTime = DateTime.Now;
            }
            return request;
        }

        /// <summary>
        /// 更新同步台帐子表  数据量大的情况下，考虑改为批量同步
        /// </summary>
        /// <param name="tableType">操作表类型.</param>
        /// <param name="tradeID">流水号.</param>
        /// <param name="cardNo">卡号</param>
        /// <param name="syncSysCode">同步系统编码.</param>
        /// <param name="state">同步状态.</param>
        /// <param name="errorDesc">同步异常信息.</param>
        /// <param name="syncSysTradeID">响应流水号</param>
        /// <returns>更新是否成功</returns>
        private static bool UpdateSyncState(string tradeID, string cardNo, string state, string errorDesc)
        {
            Master.DBConnection dBConnection = new Master.DBConnection();
            dBConnection.Open("StorePro");
            dBConnection.AddDBParameter("String", "P_TRADEID", tradeID, "16", "input");
            dBConnection.AddDBParameter("String", "P_CARDNO", cardNo, "16", "input");
            dBConnection.AddDBParameter("String", "P_STATE", state, "1", "input");
            dBConnection.AddDBParameter("String", "P_ERROR", errorDesc, "512", "input");
            dBConnection.AddDBParameter("String", "p_retCode", "", "10", "output");
            dBConnection.AddDBParameter("String", "p_retMsg", "", "127", "output");
            dBConnection.ExecuteReader("SP_PB_CHANGEUSERINFOSYNCUPDATE");
            string retCode = dBConnection.GetParameterValue("p_retCode").ToString();
            string error = dBConnection.GetParameterValue("p_retMsg").ToString();
            dBConnection.Commit();
            dBConnection.Close();

            if (retCode != "0000000000")
            {
                Common.Log.Error(retCode + ":" + error + " P_TRADEID: " + tradeID + " P_CARDNO:" + cardNo, null, "AppLog");
                return false;
            }
            return true;
        }
    }
}
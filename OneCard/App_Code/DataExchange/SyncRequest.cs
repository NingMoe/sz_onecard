//-----------------------------------------------------------------------
// <copyright file="SyncRequest.cs" company="linkage">
//   * 功能名: 同步请求类

// </copyright>
// <author>hzl</author>
//   * 更改日期      姓名           摘要 
//   * ----------    -----------    --------------------------------
//   * 2013/08/21    huangzl           初次开发   

//-----------------------------------------------------------------------
namespace DataExchange
{
    using System;
    using System.Data;
    using System.Xml;

    /// <summary>
    /// 同步请求类

    /// </summary>
    public abstract class SyncRequest
    {
        /// <summary>
        /// 处理码
        /// </summary>
        protected string transCode;
        public string TransCode
        {
            get { return this.transCode; }
        }

        /// <summary>
        /// 市民卡号
        /// </summary>
        private string citizenCardNo;
        public string CitizenCardNo
        {
            get { return this.citizenCardNo; }
            set { this.citizenCardNo = value; }
        }

        /// <summary>
        /// 返回码
        /// </summary>
        private string code;
        public string Code
        {
            get { return this.code; }
            set { this.code = value; }
        }

        /// <summary>
        /// 返回信息
        /// </summary>
        private string message;
        public string Message
        {
            get { return this.message; }
            set { this.message = value; }
        }

        /// <summary>
        /// 业务流水号
        /// </summary>
        private string tradeID;
        public string TradeID
        {
            get { return this.tradeID; }
            set { this.tradeID = value; }
        }
        
        /// <summary>
        /// 业务类型
        /// </summary>
        private string syncSyscCode;
        public string SyncSyscCode
        {
            get { return this.syncSyscCode; }
            set { this.syncSyscCode = value; }
        }

        /// <summary>
        /// 同步状态
        /// </summary>
        private string syncCode;
        public string SyncCode
        {
            get { return this.syncCode; }
            set { this.syncCode = value; }
        }

        /// <summary>
        /// 同步完成时间
        /// </summary>
        private DateTime syncTime;
        public DateTime SyncTime
        {
            get { return this.syncTime; }
            set { this.syncTime = value; }
        }

        /// <summary>
        /// 构造请求XML
        /// </summary>
        /// <returns>请求XML</returns>
        public abstract string SetupXML();

        /// <summary>
        /// DataRow转换.
        /// </summary>
        /// <param name="dr">DataRow</param>
        public abstract void ParseFormDataRow(DataRow dr);

        /// <summary>
        /// 获取返回参数.
        /// </summary>
        /// <param name="rsp">XML</param>
        public virtual void GetSyncResponse(XmlNodeList rsp)
        {
        }
    }
}
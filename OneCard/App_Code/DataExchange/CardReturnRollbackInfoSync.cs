//-----------------------------------------------------------------------
// <copyright file="CardReturnRollbackInfoSyncTest.cs" company="linkage">
//   * 功能名: 退卡返销信息同步。
// </copyright>
// <author>huangzl</author>
//   * 更改日期      姓名           摘要 
//   * ----------    -----------    --------------------------------
//   * 2013/09/05    huangzl         初次开发   
//-----------------------------------------------------------------------

namespace DataExchange
{
    using System;
    using System.Data;
    using System.Text;

    public class CardReturnRollbackInfoSync : SyncRequest
    {
        /// <summary>
        /// 构造函数
        /// </summary>
        public CardReturnRollbackInfoSync()
        {
            this.transCode = "9511";//退卡返销
        }

        //姓名
        private string name;
        public string NAME
        {
            get { return name; }
            set { name = value; }
        }

        //证件类型
        private string paper_type;
        public string PAPER_TYPE
        {
            get { return paper_type; }
            set { paper_type = value; }
        }

        //证件号码
        private string paper_no;
        public string PAPER_NO
        {
            get { return paper_no; }
            set { paper_no = value; }
        }

        //卡类型
        private string card_type;
        public string CARD_TYPE
        {
            get { return card_type; }
            set { card_type = value; }
        }

        /// <summary>
        /// 构造请求XML
        /// </summary>
        /// <returns>
        /// 请求XML
        /// </returns>
        public override string SetupXML()
        {
            StringBuilder xml = new StringBuilder();
            xml.AppendLine("<PICKUPREQ>");
            xml.AppendLine(string.Format("<NAME>{0}</NAME>", this.NAME.Trim()));
            xml.AppendLine(string.Format("<PAPER_TYPE>{0}</PAPER_TYPE>", this.PAPER_TYPE));
            xml.AppendLine(string.Format("<PAPER_NO>{0}</PAPER_NO>", this.PAPER_NO));
            xml.AppendLine(string.Format("<CARD_TYPE>{0}</CARD_TYPE>", this.CARD_TYPE));
            xml.AppendLine("</PICKUPREQ>");
            return xml.ToString();
        }

        /// <summary>
        /// DataRow转换
        /// </summary>
        /// <param name="row">DataRow</param>
        public override void ParseFormDataRow(DataRow row)
        {
            this.TradeID = row["TRADEID"].ToString();
            this.CitizenCardNo = row["CITIZEN_CARD_NO"].ToString();
            this.NAME = row["NAME"].ToString();
            this.PAPER_TYPE = row["PAPER_TYPE"].ToString();
            this.PAPER_NO = row["PAPER_NO"].ToString();
            this.CARD_TYPE = row["CARD_TYPE"].ToString();
        }
    }
}
//-----------------------------------------------------------------------
// <copyright file="UserInfoChangeSync.cs" company="linkage">
//   * 功能名: 信息变更同步。
// </copyright>
// <author>huangzl</author>
//   * 更改日期      姓名           摘要 
//   * ----------    -----------    --------------------------------
//   * 2013/08/13    huangzl         初次开发   
//-----------------------------------------------------------------------

namespace DataExchange
{
    using System;
    using System.Data;
    using System.Text;

    public class UserInfoChangeSync:SyncRequest
    {
        /// <summary>
        /// 构造函数
        /// </summary>
        public UserInfoChangeSync()
        {
            this.transCode = "9506";//信息变更
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

        //原姓名
        private string old_name;
        public string OLD_NAME
        {
            get { return old_name; }
            set { old_name = value; }
        }

        //原证件类型
        private string old_paper_type;
        public string OLD_PAPER_TYPE
        {
            get { return old_paper_type; }
            set { old_paper_type = value; }
        }

        //原证件号码
        private string old_paper_no;
        public string OLD_PAPER_NO
        {
            get { return old_paper_no; }
            set { old_paper_no = value; }
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
            xml.AppendLine(string.Format("<NAME>{0}</NAME>", this.NAME.Trim()));
            xml.AppendLine(string.Format("<PAPER_TYPE>{0}</PAPER_TYPE>", this.PAPER_TYPE));
            xml.AppendLine(string.Format("<PAPER_NO>{0}</PAPER_NO>", this.PAPER_NO));
            xml.AppendLine(string.Format("<OLD_NAME>{0}</OLD_NAME>", this.OLD_NAME.Trim()));
            xml.AppendLine(string.Format("<OLD_PAPER_TYPE>{0}</OLD_PAPER_TYPE>", this.OLD_PAPER_TYPE));
            xml.AppendLine(string.Format("<OLD_PAPER_NO>{0}</OLD_PAPER_NO>", this.OLD_PAPER_NO));
            xml.AppendLine(string.Format("<CARD_TYPE>{0}</CARD_TYPE>", this.CARD_TYPE));
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
            this.OLD_NAME = row["OLD_NAME"].ToString();
            this.OLD_PAPER_TYPE = row["OLD_PAPER_TYPE"].ToString();
            this.OLD_PAPER_NO = row["OLD_PAPER_NO"].ToString();
            this.CARD_TYPE = row["CARD_TYPE"].ToString();
        }
    }
}
﻿//-----------------------------------------------------------------------
// <copyright file="CardChangeInfoSync.cs" company="linkage">
//   * 功能名: 换卡信息同步。
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

    public class CardChangeInfoSync : SyncRequest
    {
        /// <summary>
        /// 构造函数
        /// </summary>
        public CardChangeInfoSync()
        {
            this.transCode = "9505";//换卡
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


        //旧市民卡号
        private string old_card_no;
        public string OLD_CARD_NO
        {
            get { return old_card_no; }
            set { old_card_no = value; }
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
            xml.AppendLine(string.Format("<OLD_CARD_NO>{0}</OLD_CARD_NO>", this.OLD_CARD_NO));
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
            this.OLD_CARD_NO = row["OLD_CARD_NO"].ToString();
        }
    }
}
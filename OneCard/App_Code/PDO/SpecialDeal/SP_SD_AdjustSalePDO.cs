using System;
using System.Collections.Generic;
using System.Web;
using Master;

namespace PDO.PersonalBusiness
{
    public class SP_SD_AdjustSalePDO : PDOBase
    {
        public SP_SD_AdjustSalePDO()
        {
        }

        protected override void Init()
        {
            InitBegin("SP_SD_AdjustSale", 22);

            AddField("@ID", "string", "18", "input");
            AddField("@CARDNO", "string", "16", "input");
            AddField("@DEPOSIT", "Int32", "", "input");
            AddField("@ADJUSTMONEY", "Int32", "", "input");
            AddField("@OTHERFEE", "Int32", "", "input");
            AddField("@CARDTRADENO", "string", "4", "input");
            AddField("@CARDTYPECODE", "string", "2", "input");
            AddField("@CARDMONEY", "Int32", "", "input");
            AddField("@SELLCHANNELCODE", "string", "2", "input");
            AddField("@SERSTAKETAG", "string", "1", "input");
            AddField("@TRADETYPECODE", "string", "2", "input");
            AddField("@OLDCARDNO", "string", "16", "input");
            AddField("@VALIDENDDATE", "string", "8", "input");
            AddField("@TERMNO", "string", "12", "input");
            AddField("@OPERCARDNO", "string", "16", "input");
            AddField("@CURRENTTIME", "DateTime", "", "output");
            AddField("@TRADEID", "string", "16", "output");

            InitEnd();
        }

        // 记录流水号
        public string ID
        {
            get { return Getstring("ID"); }
            set { Setstring("ID", value); }
        }

        // 卡号
        public string CARDNO
        {
            get { return Getstring("CARDNO"); }
            set { Setstring("CARDNO", value); }
        }

        // 卡押金
        public Int32 DEPOSIT
        {
            get { return GetInt32("DEPOSIT"); }
            set { SetInt32("DEPOSIT", value); }
        }

        // 卡费
        public Int32 ADJUSTMONEY
        {
            get { return GetInt32("ADJUSTMONEY"); }
            set { SetInt32("ADJUSTMONEY", value); }
        }

        // 其他费用
        public Int32 OTHERFEE
        {
            get { return GetInt32("OTHERFEE"); }
            set { SetInt32("OTHERFEE", value); }
        }

        // 联机交易序号
        public string CARDTRADENO
        {
            get { return Getstring("CARDTRADENO"); }
            set { Setstring("CARDTRADENO", value); }
        }

        // 卡类型
        public string CARDTYPECODE
        {
            get { return Getstring("CARDTYPECODE"); }
            set { Setstring("CARDTYPECODE", value); }
        }

        // 卡内余额
        public Int32 CARDMONEY
        {
            get { return GetInt32("CARDMONEY"); }
            set { SetInt32("CARDMONEY", value); }
        }

        // 售卡渠道编码
        public string SELLCHANNELCODE
        {
            get { return Getstring("SELLCHANNELCODE"); }
            set { Setstring("SELLCHANNELCODE", value); }
        }

        // 服务费收取标志
        public string SERSTAKETAG
        {
            get { return Getstring("SERSTAKETAG"); }
            set { Setstring("SERSTAKETAG", value); }
        }

        // 交易类型编码
        public string TRADETYPECODE
        {
            get { return Getstring("TRADETYPECODE"); }
            set { Setstring("TRADETYPECODE", value); }
        }

        // 旧卡卡号
        public string OLDCARDNO
        {
            get { return Getstring("OLDCARDNO"); }
            set { Setstring("OLDCARDNO", value); }
        }

        // 有效期
        public string VALIDENDDATE
        {
            get { return Getstring("VALIDENDDATE"); }
            set { Setstring("VALIDENDDATE", value); }
        }

        // 终端号
        public string TERMNO
        {
            get { return Getstring("TERMNO"); }
            set { Setstring("TERMNO", value); }
        }

        // 操作员卡号
        public string OPERCARDNO
        {
            get { return Getstring("OPERCARDNO"); }
            set { Setstring("OPERCARDNO", value); }
        }

        // 返回系统时间
        public DateTime CURRENTTIME
        {
            get { return GetDateTime("CURRENTTIME"); }
            set { SetDateTime("CURRENTTIME", value); }
        }

        // 返回交易序列号
        public string TRADEID
        {
            get { return Getstring("TRADEID"); }
            set { Setstring("TRADEID", value); }
        }

    }
}



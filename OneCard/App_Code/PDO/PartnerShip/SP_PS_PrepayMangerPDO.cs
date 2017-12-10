using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.PartnerShip
{
    public class SP_PS_PrepayMangerPDO : PDOBase
    {
        public SP_PS_PrepayMangerPDO()
        {
        }
        protected override void Init()
        {
            InitBegin("SP_PS_PrepayManger", 9);

            AddField("@FUNCCODE", "string", "4", "input");
            AddField("@MONEY", "Int32", "", "input");
            AddField("@CHMONEY", "String", "50", "input");
            AddField("@REMARK", "String", "10", "input");
            AddField("@DBALUNITNO", "String", "40", "input");

            InitEnd();
        }
        // 功能编码
        public string FUNCCODE
        {
            get { return Getstring("FUNCCODE"); }
            set { Setstring("FUNCCODE", value); }
        }
        //操作金额
        public Int32 MONEY
        {
            get { return GetInt32("MONEY"); }
            set { SetInt32("MONEY", value); }
        }
        //大写金额
        public string CHMONEY
        {
            get { return Getstring("CHMONEY"); }
            set { Setstring("CHMONEY", value); }
        }
        // 备注
        public string REMARK
        {
            get { return Getstring("REMARK"); }
            set { Setstring("REMARK", value); }
        }
        //网点结算单元编码
        public string DBALUNITNO
        {
            get { return Getstring("DBALUNITNO"); }
            set { Setstring("DBALUNITNO", value); }
        }
    }
}
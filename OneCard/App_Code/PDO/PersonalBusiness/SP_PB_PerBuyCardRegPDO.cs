using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.PersonalBusiness
{
    public class SP_PB_PerBuyCardRegPDO : PDOBase
    {
        public SP_PB_PerBuyCardRegPDO()
        {

        }
        protected override void Init()
        {
            InitBegin("SP_PB_PerBuyCardReg", 24);

            AddField("@FUNCCODE", "string", "6", "input");
            AddField("@ID", "string", "16", "input");
            AddField("@NAME", "string", "50", "input");
            AddField("@BIRTHDAY", "string", "8", "input");
            AddField("@PAPERTYPE", "string", "2", "input");
            AddField("@PAPERNO", "string", "20", "input");
            AddField("@SEX", "string", "1", "input");
            AddField("@PHONENO", "string", "20", "input");
            AddField("@ADDRESS", "string", "200", "input");
            AddField("@EMAIL", "string", "40", "input");
            AddField("@STARTCARDNO", "string", "16", "input");
            AddField("@ENDCARDNO", "string", "16", "input");
            AddField("@BUYCARDDATE", "string", "8", "input");
            AddField("@BUYCARDNUM", "Int32", "", "input");
            AddField("@BUYCARDMONEY", "Int32", "", "input");
            AddField("@CHARGEMONEY", "Int32", "", "input");
            AddField("@REMARK", "string", "200", "input");

            InitEnd();
        }

        // 功能编码
        public string FUNCCODE
        {
            get { return Getstring("FUNCCODE"); }
            set { Setstring("FUNCCODE", value); }
        }
        // 记录流水号
        public string ID
        {
            get { return Getstring("ID"); }
            set { Setstring("ID", value); }
        }
        // 姓名
        public string NAME
        {
            get { return Getstring("NAME"); }
            set { Setstring("NAME", value); }
        }
        // 出生日期
        public string BIRTHDAY
        {
            get { return Getstring("BIRTHDAY"); }
            set { Setstring("BIRTHDAY", value); }
        }
        // 证件类型
        public string PAPERTYPE
        {
            get { return Getstring("PAPERTYPE"); }
            set { Setstring("PAPERTYPE", value); }
        }
        // 证件号码
        public string PAPERNO
        {
            get { return Getstring("PAPERNO"); }
            set { Setstring("PAPERNO", value); }
        }
        // 性别
        public string SEX
        {
            get { return Getstring("SEX"); }
            set { Setstring("SEX", value); }
        }
        // 联系电话
        public string PHONENO
        {
            get { return Getstring("PHONENO"); }
            set { Setstring("PHONENO", value); }
        }
        // 联系地址
        public string ADDRESS
        {
            get { return Getstring("ADDRESS"); }
            set { Setstring("ADDRESS", value); }
        }
        // 电子邮件
        public string EMAIL
        {
            get { return Getstring("EMAIL"); }
            set { Setstring("EMAIL", value); }
        }
        // 起始卡号
        public string STARTCARDNO
        {
            get { return Getstring("STARTCARDNO"); }
            set { Setstring("STARTCARDNO", value); }
        }
        // 结束卡号
        public string ENDCARDNO
        {
            get { return Getstring("ENDCARDNO"); }
            set { Setstring("ENDCARDNO", value); }
        }
        // 购卡日期
        public string BUYCARDDATE
        {
            get { return Getstring("BUYCARDDATE"); }
            set { Setstring("BUYCARDDATE", value); }
        }
        // 购卡数量
        public Int32 BUYCARDNUM
        {
            get { return GetInt32("BUYCARDNUM"); }
            set { SetInt32("BUYCARDNUM", value); }
        }
        // 购卡金额
        public Int32 BUYCARDMONEY
        {
            get { return GetInt32("BUYCARDMONEY"); }
            set { SetInt32("BUYCARDMONEY", value); }
        }
        // 充值金额
        public Int32 CHARGEMONEY
        {
            get { return GetInt32("CHARGEMONEY"); }
            set { SetInt32("CHARGEMONEY", value); }
        }
        // 备注
        public string REMARK
        {
            get { return Getstring("REMARK"); }
            set { Setstring("REMARK", value); }
        }
    }
}
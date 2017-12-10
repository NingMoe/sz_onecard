using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace PDO.TaxiService
{
    // 出租车开卡
    public class SP_TS_NewCardPDO : PDOBase
    {
        public SP_TS_NewCardPDO()
        {
        }

        protected override void Init()
        {
            InitBegin("SP_TS_NewCard", 27);

            AddField("@CALLINGSTAFFNO", "string", "6", "input");
            AddField("@CARDNO", "String", "16", "input");
            AddField("@CARNO", "string", "10", "input");
            AddField("@strState", "string", "2", "input");
            AddField("@BANKCODE", "string", "4", "input");
            AddField("@BANKACCNO", "String", "20", "input");
            AddField("@STAFFNAME", "String", "20", "input");
            AddField("@STAFFSEX", "string", "1", "input");
            AddField("@STAFFPHONE", "String", "20", "input");
            AddField("@STAFFMOBILE", "String", "15", "input");
            AddField("@STAFFPAPERTYPECODE", "string", "2", "input");
            AddField("@STAFFPAPERNO", "String", "20", "input");
            AddField("@STAFFPOST", "String", "6", "input");
            AddField("@STAFFADDR", "String", "50", "input");
            AddField("@STAFFEMAIL", "String", "30", "input");
            AddField("@CORPNO", "string", "4", "input");
            AddField("@DEPARTNO", "string", "4", "input");
            AddField("@POSID", "string", "8", "input");
            AddField("@COLLECTCARDNO", "String", "16", "input");
            AddField("@COLLECTCARDPWD", "String", "8", "input");
            AddField("@operCardNo", "String", "16", "input");
            AddField("@SERMANAGERCODE", "string", "6", "input");

            //add by jiangbb 2012-07-03 收款人或藏虎类型
            AddField("@PURPOSETYPE", "String", "1", "input");
            InitEnd();
        }

        //收款人账户类型
        public string PURPOSETYPE
        {
            get { return Getstring("PURPOSETYPE"); }
            set { Setstring("PURPOSETYPE", value); }
        }

        // 行业员工编码
        public string CALLINGSTAFFNO
        {
            get { return Getstring("CALLINGSTAFFNO"); }
            set { Setstring("CALLINGSTAFFNO", value); }
        }

        // 员工卡号
        public String CARDNO
        {
            get { return GetString("CARDNO"); }
            set { SetString("CARDNO", value); }
        }

        // 车号
        public string CARNO
        {
            get { return Getstring("CARNO"); }
            set { Setstring("CARNO", value); }
        }

        // 司机卡初始状态
        public string strState
        {
            get { return Getstring("strState"); }
            set { Setstring("strState", value); }
        }

        // 开户银行编码
        public string BANKCODE
        {
            get { return Getstring("BANKCODE"); }
            set { Setstring("BANKCODE", value); }
        }

        // 银行账号
        public String BANKACCNO
        {
            get { return GetString("BANKACCNO"); }
            set { SetString("BANKACCNO", value); }
        }

        // 员工姓名
        public String STAFFNAME
        {
            get { return GetString("STAFFNAME"); }
            set { SetString("STAFFNAME", value); }
        }

        // 员工性别
        public string STAFFSEX
        {
            get { return Getstring("STAFFSEX"); }
            set { Setstring("STAFFSEX", value); }
        }

        // 员工联系电话
        public String STAFFPHONE
        {
            get { return GetString("STAFFPHONE"); }
            set { SetString("STAFFPHONE", value); }
        }

        // 员工移动电话
        public String STAFFMOBILE
        {
            get { return GetString("STAFFMOBILE"); }
            set { SetString("STAFFMOBILE", value); }
        }

        // 员工证件类型
        public string STAFFPAPERTYPECODE
        {
            get { return Getstring("STAFFPAPERTYPECODE"); }
            set { Setstring("STAFFPAPERTYPECODE", value); }
        }

        // 员工证件号码
        public String STAFFPAPERNO
        {
            get { return GetString("STAFFPAPERNO"); }
            set { SetString("STAFFPAPERNO", value); }
        }

        // 邮编地址
        public String STAFFPOST
        {
            get { return GetString("STAFFPOST"); }
            set { SetString("STAFFPOST", value); }
        }

        // 员工联系地址
        public String STAFFADDR
        {
            get { return GetString("STAFFADDR"); }
            set { SetString("STAFFADDR", value); }
        }

        // EMAIL地址
        public String STAFFEMAIL
        {
            get { return GetString("STAFFEMAIL"); }
            set { SetString("STAFFEMAIL", value); }
        }

        // 单位编码
        public string CORPNO
        {
            get { return Getstring("CORPNO"); }
            set { Setstring("CORPNO", value); }
        }

        // 部门编码
        public string DEPARTNO
        {
            get { return Getstring("DEPARTNO"); }
            set { Setstring("DEPARTNO", value); }
        }

        // POSID
        public string POSID
        {
            get { return Getstring("POSID"); }
            set { Setstring("POSID", value); }
        }

        // 采集卡号
        public String COLLECTCARDNO
        {
            get { return GetString("COLLECTCARDNO"); }
            set { SetString("COLLECTCARDNO", value); }
        }

        // 采集卡密码
        public String COLLECTCARDPWD
        {
            get { return GetString("COLLECTCARDPWD"); }
            set { SetString("COLLECTCARDPWD", value); }
        }

        // 操作员卡号
        public String operCardNo
        {
            get { return GetString("operCardNo"); }
            set { SetString("operCardNo", value); }
        }

        // 商户经理
        public string SERMANAGERCODE
        {
            get { return Getstring("SERMANAGERCODE"); }
            set { Setstring("SERMANAGERCODE", value); }
        }

    }
}



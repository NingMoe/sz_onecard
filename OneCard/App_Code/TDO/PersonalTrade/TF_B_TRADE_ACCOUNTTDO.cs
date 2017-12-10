using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.PersonalTrade
{
    // 业务台帐主表
    public class TF_B_TRADE_ACCOUNTTDO : DDOBase
    {
        public TF_B_TRADE_ACCOUNTTDO()
        {
        }

        protected override void Init()
        {
            tableName = "TF_B_TRADE_ACCOUNT";

            columns = new String[29][];
            columns[0] = new String[] { "TRADEID", "string" };
            columns[1] = new String[] { "ACCTID", "Int32" };
            columns[2] = new String[] { "CARDNO", "string" };
            columns[3] = new String[] { "ID", "string" };
            columns[4] = new String[] { "TRADETYPECODE", "string" };
            columns[5] = new String[] { "ASN", "string" };
            columns[6] = new String[] { "CARDTYPECODE", "string" };
            columns[7] = new String[] { "CARDTRADENO", "string" };
            columns[8] = new String[] { "REASONCODE", "string" };
            columns[9] = new String[] { "OLDCARDNO", "string" };
            columns[10] = new String[] { "DEPOSIT", "Int32" };
            columns[11] = new String[] { "OLDCARDMONEY", "Int32" };
            columns[12] = new String[] { "CURRENTMONEY", "Int32" };
            columns[13] = new String[] { "PREMONEY", "Int32" };
            columns[14] = new String[] { "NEXTMONEY", "Int32" };
            columns[15] = new String[] { "CORPNO", "string" };
            columns[16] = new String[] { "OPERATESTAFFNO", "string" };
            columns[17] = new String[] { "OPERATEDEPARTID", "string" };
            columns[18] = new String[] { "OPERATETIME", "DateTime" };
            columns[19] = new String[] { "CHECKSTAFFNO", "string" };
            columns[20] = new String[] { "CHECKDEPARTNO", "string" };
            columns[21] = new String[] { "CHECKTIME", "DateTime" };
            columns[22] = new String[] { "STATECODE", "string" };
            columns[23] = new String[] { "CANCELTAG", "string" };
            columns[24] = new String[] { "CANCELTRADEID", "string" };
            columns[25] = new String[] { "CARDSTATE", "string" };
            columns[26] = new String[] { "SERSTAKETAG", "string" };
            columns[27] = new String[] { "RSRV1", "String" };
            columns[28] = new String[] { "RSRV2", "String" };
            
            columnKeys = new String[]{
                   "TRADEID",
                   "ACCTID",
               };

            array = new String[29];
            hash.Add("TRADEID", 0);
            hash.Add("ACCTID", 1);
            hash.Add("CARDNO", 2);
            hash.Add("ID", 3);
            hash.Add("TRADETYPECODE", 4);
            hash.Add("ASN", 5);
            hash.Add("CARDTYPECODE", 6);
            hash.Add("CARDTRADENO", 7);
            hash.Add("REASONCODE", 8);
            hash.Add("OLDCARDNO", 9);
            hash.Add("DEPOSIT", 10);
            hash.Add("OLDCARDMONEY", 11);
            hash.Add("CURRENTMONEY", 12);
            hash.Add("PREMONEY", 13);
            hash.Add("NEXTMONEY", 14);
            hash.Add("CORPNO", 15);
            hash.Add("OPERATESTAFFNO", 16);
            hash.Add("OPERATEDEPARTID", 17);
            hash.Add("OPERATETIME", 18);
            hash.Add("CHECKSTAFFNO", 19);
            hash.Add("CHECKDEPARTNO", 20);
            hash.Add("CHECKTIME", 21);
            hash.Add("STATECODE", 22);
            hash.Add("CANCELTAG", 23);
            hash.Add("CANCELTRADEID", 24);
            hash.Add("CARDSTATE", 25);
            hash.Add("SERSTAKETAG", 26);
            hash.Add("RSRV1", 27);
            hash.Add("RSRV2", 28);
            
        }

        // 业务流水号
        public string TRADEID
        {
            get { return Getstring("TRADEID"); }
            set { Setstring("TRADEID", value); }
        }

        // 业务流水号
        public string ACCTID
        {
            get { return Getstring("ACCTID"); }
            set { Setstring("ACCTID", value); }
        }

        // IC卡号
        public string CARDNO
        {
            get { return Getstring("CARDNO"); }
            set { Setstring("CARDNO", value); }
        }

        // 记录流水号
        public string ID
        {
            get { return Getstring("ID"); }
            set { Setstring("ID", value); }
        }

        // 业务类型编码
        public string TRADETYPECODE
        {
            get { return Getstring("TRADETYPECODE"); }
            set { Setstring("TRADETYPECODE", value); }
        }

        // 应用序列号
        public string ASN
        {
            get { return Getstring("ASN"); }
            set { Setstring("ASN", value); }
        }

        // 卡类型
        public string CARDTYPECODE
        {
            get { return Getstring("CARDTYPECODE"); }
            set { Setstring("CARDTYPECODE", value); }
        }

        // 联机交易序号
        public string CARDTRADENO
        {
            get { return Getstring("CARDTRADENO"); }
            set { Setstring("CARDTRADENO", value); }
        }

        // 业务操作原因编码
        public string REASONCODE
        {
            get { return Getstring("REASONCODE"); }
            set { Setstring("REASONCODE", value); }
        }

        // 旧卡卡号
        public string OLDCARDNO
        {
            get { return Getstring("OLDCARDNO"); }
            set { Setstring("OLDCARDNO", value); }
        }

        // 旧卡剩余押金
        public Int32 DEPOSIT
        {
            get { return GetInt32("DEPOSIT"); }
            set { SetInt32("DEPOSIT", value); }
        }

        // 旧卡余额
        public Int32 OLDCARDMONEY
        {
            get { return GetInt32("OLDCARDMONEY"); }
            set { SetInt32("OLDCARDMONEY", value); }
        }

        // 发生金额
        public Int32 CURRENTMONEY
        {
            get { return GetInt32("CURRENTMONEY"); }
            set { SetInt32("CURRENTMONEY", value); }
        }

        // 发生前余额
        public Int32 PREMONEY
        {
            get { return GetInt32("PREMONEY"); }
            set { SetInt32("PREMONEY", value); }
        }

        // 发生后余额
        public Int32 NEXTMONEY
        {
            get { return GetInt32("NEXTMONEY"); }
            set { SetInt32("NEXTMONEY", value); }
        }

        // 集团客户编码
        public string CORPNO
        {
            get { return Getstring("CORPNO"); }
            set { Setstring("CORPNO", value); }
        }

        // 操作员工编码
        public string OPERATESTAFFNO
        {
            get { return Getstring("OPERATESTAFFNO"); }
            set { Setstring("OPERATESTAFFNO", value); }
        }

        // 部门编码
        public string OPERATEDEPARTID
        {
            get { return Getstring("OPERATEDEPARTID"); }
            set { Setstring("OPERATEDEPARTID", value); }
        }

        // 操作时间
        public DateTime OPERATETIME
        {
            get { return GetDateTime("OPERATETIME"); }
            set { SetDateTime("OPERATETIME", value); }
        }

        // 审批操作员
        public string CHECKSTAFFNO
        {
            get { return Getstring("CHECKSTAFFNO"); }
            set { Setstring("CHECKSTAFFNO", value); }
        }

        // 审批部门编码
        public string CHECKDEPARTNO
        {
            get { return Getstring("CHECKDEPARTNO"); }
            set { Setstring("CHECKDEPARTNO", value); }
        }

        // 审批时间
        public DateTime CHECKTIME
        {
            get { return GetDateTime("CHECKTIME"); }
            set { SetDateTime("CHECKTIME", value); }
        }

        // 状态编码
        public string STATECODE
        {
            get { return Getstring("STATECODE"); }
            set { Setstring("STATECODE", value); }
        }

        // 回退标志
        public string CANCELTAG
        {
            get { return Getstring("CANCELTAG"); }
            set { Setstring("CANCELTAG", value); }
        }

        // 回退业务流水号
        public string CANCELTRADEID
        {
            get { return Getstring("CANCELTRADEID"); }
            set { Setstring("CANCELTRADEID", value); }
        }

        // 卡状态
        public string CARDSTATE
        {
            get { return Getstring("CARDSTATE"); }
            set { Setstring("CARDSTATE", value); }
        }

        // 服务费收取标志
        public string SERSTAKETAG
        {
            get { return Getstring("SERSTAKETAG"); }
            set { Setstring("SERSTAKETAG", value); }
        }

        // 备用1
        public String RSRV1
        {
            get { return GetString("RSRV1"); }
            set { SetString("RSRV1", value); }
        }

        // 备用2
        public String RSRV2
        {
            get { return GetString("RSRV2"); }
            set { SetString("RSRV2", value); }
        }

    }
}



using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.CustomerAcc
{
    // �ͻ��ʻ�
    public class TF_F_CUST_ACCTTDO : DDOBase
    {
        public TF_F_CUST_ACCTTDO()
        {
        }

        protected override void Init()
        {
            tableName = "TF_F_CUST_ACCT";

            columns = new String[22][];
            columns[0] = new String[] { "ACCT_ID", "String" };
            columns[1] = new String[] { "CUST_ID", "String" };
            columns[2] = new String[] { "ACCT_NAME", "String" };
            columns[3] = new String[] { "STATE", "string" };
            columns[4] = new String[] { "STATE_DATE", "DateTime" };
            columns[5] = new String[] { "CREATE_DATE", "DateTime" };
            columns[6] = new String[] { "EFF_DATE", "DateTime" };
            columns[7] = new String[] { "ACCT_PAYMENT_TYPE", "string" };
            columns[8] = new String[] { "ICCARD_NO", "String" };
            columns[9] = new String[] { "ACCT_BALANCE", "Int32" };
            columns[10] = new String[] { "REL_BALANCE", "Int32" };
            columns[11] = new String[] { "CUST_PASSWORD", "string" };
            columns[12] = new String[] { "TOTAL_CONSUME_TIMES", "Int32" };
            columns[13] = new String[] { "TOTAL_SUPPLY_TIMES", "Int32" };
            columns[14] = new String[] { "TOTAL_CONSUME_MONEY", "Int32" };
            columns[15] = new String[] { "TOTAL_SUPPLY_MONEY", "Int32" };
            columns[16] = new String[] { "LAST_CONSUME_TIME", "DateTime" };
            columns[17] = new String[] { "LAST_SUPPLY_TIME", "DateTime" };
            columns[18] = new String[] { "LIMIT_DAYAMOUNT", "Int32" };
            columns[19] = new String[] { "AMOUNT_TODAY", "Int32" };
            columns[20] = new String[] { "LIMIT_EACHTIME", "Int32" };
            columns[21] = new String[] { "CODEERRORTIMES", "Int32" };
            columnKeys = new String[]{
                   "ACCT_ID",
               };


            array = new String[22];
            hash.Add("ACCT_ID", 0);
            hash.Add("CUST_ID", 1);
            hash.Add("ACCT_NAME", 2);
            hash.Add("STATE", 3);
            hash.Add("STATE_DATE", 4);
            hash.Add("CREATE_DATE", 5);
            hash.Add("EFF_DATE", 6);
            hash.Add("ACCT_PAYMENT_TYPE", 7);
            hash.Add("ICCARD_NO", 8);
            hash.Add("ACCT_BALANCE", 9);
            hash.Add("REL_BALANCE", 10);
            hash.Add("CUST_PASSWORD", 11);
            hash.Add("TOTAL_CONSUME_TIMES", 12);
            hash.Add("TOTAL_SUPPLY_TIMES", 13);
            hash.Add("TOTAL_CONSUME_MONEY", 14);
            hash.Add("TOTAL_SUPPLY_MONEY", 15);
            hash.Add("LAST_CONSUME_TIME", 16);
            hash.Add("LAST_SUPPLY_TIME", 17);
            hash.Add("LIMIT_DAYAMOUNT", 18);
            hash.Add("AMOUNT_TODAY", 19);
            hash.Add("LIMIT_EACHTIME", 20);
            hash.Add("CODEERRORTIMES", 21);
        }

        // �ʻ���ʶ
        public String ACCT_ID
        {
            get { return GetString("ACCT_ID"); }
            set { SetString("ACCT_ID", value); }
        }

        // �ͻ���ʶ
        public String CUST_ID
        {
            get { return GetString("CUST_ID"); }
            set { SetString("CUST_ID", value); }
        }

        // �ʻ�����
        public String ACCT_NAME
        {
            get { return GetString("ACCT_NAME"); }
            set { SetString("ACCT_NAME", value); }
        }

        // ״̬
        public string STATE
        {
            get { return Getstring("STATE"); }
            set { Setstring("STATE", value); }
        }

        // ״̬ʱ��
        public DateTime STATE_DATE
        {
            get { return GetDateTime("STATE_DATE"); }
            set { SetDateTime("STATE_DATE", value); }
        }

        // ����ʱ��
        public DateTime CREATE_DATE
        {
            get { return GetDateTime("CREATE_DATE"); }
            set { SetDateTime("CREATE_DATE", value); }
        }

        // ��Чʱ��
        public DateTime EFF_DATE
        {
            get { return GetDateTime("EFF_DATE"); }
            set { SetDateTime("EFF_DATE", value); }
        }

        // �ʻ�֧������
        public string ACCT_PAYMENT_TYPE
        {
            get { return Getstring("ACCT_PAYMENT_TYPE"); }
            set { Setstring("ACCT_PAYMENT_TYPE", value); }
        }

        // �󶨴���IC����
        public String ICCARD_NO
        {
            get { return GetString("ICCARD_NO"); }
            set { SetString("ICCARD_NO", value); }
        }

        // �ʱ����
        public Int32 ACCT_BALANCE
        {
            get { return GetInt32("ACCT_BALANCE"); }
            set { SetInt32("ACCT_BALANCE", value); }
        }

        // ʵʱ���
        public Int32 REL_BALANCE
        {
            get { return GetInt32("REL_BALANCE"); }
            set { SetInt32("REL_BALANCE", value); }
        }

        // ����
        public string CUST_PASSWARD
        {
            get { return Getstring("CUST_PASSWORD"); }
            set { Setstring("CUST_PASSWORD", value); }
        }

        // �����Ѵ���
        public Int32 TOTAL_CONSUME_TIMES
        {
            get { return GetInt32("TOTAL_CONSUME_TIMES"); }
            set { SetInt32("TOTAL_CONSUME_TIMES", value); }
        }

        // �ܳ�ֵ����
        public Int32 TOTAL_SUPPLY_TIMES
        {
            get { return GetInt32("TOTAL_SUPPLY_TIMES"); }
            set { SetInt32("TOTAL_SUPPLY_TIMES", value); }
        }

        // �����ѽ��
        public Int32 TOTAL_CONSUME_MONEY
        {
            get { return GetInt32("TOTAL_CONSUME_MONEY"); }
            set { SetInt32("TOTAL_CONSUME_MONEY", value); }
        }

        // �ܳ�ֵ���
        public Int32 TOTAL_SUPPLY_MONEY
        {
            get { return GetInt32("TOTAL_SUPPLY_MONEY"); }
            set { SetInt32("TOTAL_SUPPLY_MONEY", value); }
        }

        // �������ʱ��
        public DateTime LAST_CONSUME_TIME
        {
            get { return GetDateTime("LAST_CONSUME_TIME"); }
            set { SetDateTime("LAST_CONSUME_TIME", value); }
        }

        // �����ֵʱ��
        public DateTime LAST_SUPPLY_TIME
        {
            get { return GetDateTime("LAST_SUPPLY_TIME"); }
            set { SetDateTime("LAST_SUPPLY_TIME", value); }
        }
        // ���������
        public int CODEERRORTIMES
        {
            get { return GetInt32("CODEERRORTIMES"); }
            set { SetInt32("CODEERRORTIMES", value); }
        }

        // ���������޶�
        public int LIMIT_DAYAMOUNT
        {
            get { return GetInt32("LIMIT_DAYAMOUNT"); }
            set { SetInt32("LIMIT_DAYAMOUNT", value); }
        }

        // ���������ѽ��
        public int AMOUNT_TODAY
        {
            get { return GetInt32("AMOUNT_TODAY"); }
            set { SetInt32("AMOUNT_TODAY", value); }
        }

        // ÿ�������޶�
        public int LIMIT_EACHTIME
        {
            get { return GetInt32("LIMIT_EACHTIME"); }
            set { SetInt32("LIMIT_EACHTIME", value); }
        }

    }
}



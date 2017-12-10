using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.CustomerAcc
{
    // 客户资料表
    public class TF_F_CUSTTDO : DDOBase
    {
        public TF_F_CUSTTDO()
        {
        }

        protected override void Init()
        {
            tableName = "TF_F_CUST";

            columns = new String[21][];
            columns[0] = new String[] { "CUST_ID", "String" };
            columns[1] = new String[] { "PAPER_TYPE_CODE", "String" };
            columns[2] = new String[] { "PAPER_NO", "String" };
            columns[3] = new String[] { "CUST_NAME", "String" };
            columns[4] = new String[] { "CUST_SEX", "String" };
            columns[5] = new String[] { "CUST_BIRTH", "DateTime" };
            columns[6] = new String[] { "CUST_ADDR", "String" };
            columns[7] = new String[] { "CUST_POST", "String" };
            columns[8] = new String[] { "CUST_PHONE", "String" };
            columns[9] = new String[] { "CUST_TELPHONE", "String" };
            columns[10] = new String[] { "CUST_EMAIL", "String" };
            columns[11] = new String[] { "CUST_TYPE_ID", "string" };
            columns[12] = new String[] { "CUST_SERVICE_SCOPE", "string" };
            columns[13] = new String[] { "ICCARD_NO", "String" };
            columns[14] = new String[] { "IS_VIP", "string" };
            columns[15] = new String[] { "PARENT_ID", "String" };
            columns[16] = new String[] { "STATE", "string" };
            columns[17] = new String[] { "STAFF_ID", "String" };
            columns[18] = new String[] { "CREATE_DATE", "DateTime" };
            columns[19] = new String[] { "EFF_DATE", "DateTime" };
            columns[20] = new String[] { "EXP_DATE", "DateTime" };

            columnKeys = new String[]{
                   "CUST_ID",
               };


            array = new String[21];
            hash.Add("CUST_ID", 0);
            hash.Add("PAPER_TYPE_CODE", 1);
            hash.Add("PAPER_NO", 2);
            hash.Add("CUST_NAME", 3);
            hash.Add("CUST_SEX", 4);
            hash.Add("CUST_BIRTH", 5);
            hash.Add("CUST_ADDR", 6);
            hash.Add("CUST_POST", 7);
            hash.Add("CUST_PHONE", 8);
            hash.Add("CUST_TELPHONE", 9);
            hash.Add("CUST_EMAIL", 10);
            hash.Add("CUST_TYPE_ID", 11);
            hash.Add("CUST_SERVICE_SCOPE", 12);
            hash.Add("ICCARD_NO", 13);
            hash.Add("IS_VIP", 14);
            hash.Add("PARENT_ID", 15);
            hash.Add("STATE", 16);
            hash.Add("STAFF_ID", 17);
            hash.Add("CREATE_DATE", 18);
            hash.Add("EFF_DATE", 19);
            hash.Add("EXP_DATE", 20);
        }

        // 客户标识
        public String CUST_ID
        {
            get { return GetString("CUST_ID"); }
            set { SetString("CUST_ID", value); }
        }

        // 证件类型
        public String PAPER_TYPE_CODE
        {
            get { return GetString("PAPER_TYPE_CODE"); }
            set { SetString("PAPER_TYPE_CODE", value); }
        }

        // 证件号码
        public String PAPER_NO
        {
            get { return GetString("PAPER_NO"); }
            set { SetString("PAPER_NO", value); }
        }

        // 客户名称
        public String CUST_NAME
        {
            get { return GetString("CUST_NAME"); }
            set { SetString("CUST_NAME", value); }
        }

        // 客户性别
        public String CUST_SEX
        {
            get { return GetString("CUST_SEX"); }
            set { SetString("CUST_SEX", value); }
        }

        // 出生日期
        public String CUST_BIRTH
        {
            get { return GetString("CUST_BIRTH"); }
            set { SetString("CUST_BIRTH", value); }
        }

        // 联系地址
        public String CUST_ADDR
        {
            get { return GetString("CUST_ADDR"); }
            set { SetString("CUST_ADDR", value); }
        }

        // 邮政编码
        public String CUST_POST
        {
            get { return GetString("CUST_POST"); }
            set { SetString("CUST_POST", value); }
        }

        // 手机号码
        public String CUST_PHONE
        {
            get { return GetString("CUST_PHONE"); }
            set { SetString("CUST_PHONE", value); }
        }

        // 固定电话
        public String CUST_TELPHONE
        {
            get { return GetString("CUST_TELPHONE"); }
            set { SetString("CUST_TELPHONE", value); }
        }

        // 邮件地址
        public String CUST_EMAIL
        {
            get { return GetString("CUST_EMAIL"); }
            set { SetString("CUST_EMAIL", value); }
        }

        // 客户类型
        public string CUST_TYPE_ID
        {
            get { return Getstring("CUST_TYPE_ID"); }
            set { Setstring("CUST_TYPE_ID", value); }
        }

        // 服务范围
        public string CUST_SERVICE_SCOPE
        {
            get { return Getstring("CUST_SERVICE_SCOPE"); }
            set { Setstring("CUST_SERVICE_SCOPE", value); }
        }

        // 绑定代表IC卡号
        public String ICCARD_NO
        {
            get { return GetString("ICCARD_NO"); }
            set { SetString("ICCARD_NO", value); }
        }

        // 重点客户标志
        public string IS_VIP
        {
            get { return Getstring("IS_VIP"); }
            set { Setstring("IS_VIP", value); }
        }

        // 上级客户标识
        public String PARENT_ID
        {
            get { return GetString("PARENT_ID"); }
            set { SetString("PARENT_ID", value); }
        }

        // 状态
        public string STATE
        {
            get { return Getstring("STATE"); }
            set { Setstring("STATE", value); }
        }

        // 工号
        public String STAFF_ID
        {
            get { return GetString("STAFF_ID"); }
            set { SetString("STAFF_ID", value); }
        }

        // 创建时间
        public DateTime CREATE_DATE
        {
            get { return GetDateTime("CREATE_DATE"); }
            set { SetDateTime("CREATE_DATE", value); } 
        }

        // 生效时间
        public DateTime EFF_DATE
        {
            get { return GetDateTime("EFF_DATE"); }
            set { SetDateTime("EFF_DATE", value); }
        }

        // 失效时间
        public DateTime EXP_DATE
        {
            get { return GetDateTime("EXP_DATE"); }
            set { SetDateTime("EXP_DATE", value); }
        }

    }
}



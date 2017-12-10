using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.CustomerAcc
{
     // 余额帐本
     public class TF_F_ACCT_BALANCETDO : DDOBase
     {
          public TF_F_ACCT_BALANCETDO()
          {
          }

          protected override void Init()
          {
               tableName = "TF_F_ACCT_BALANCE";

               columns = new String[10][];
               columns[0] = new String[]{"ACCT_BALANCE_ID", "String"};
               columns[1] = new String[]{"ACCT_ID", "String"};
               columns[2] = new String[]{"ICCARD_NO", "String"};
               columns[3] = new String[]{"ACCT_TYPE_NO", "String" };
               columns[4] = new String[]{"BALANCE", "Int32"};
               columns[5] = new String[]{"BANK_ACCT_NO", "String"};
               columns[6] = new String[]{"EFF_DATE", "DateTime"};
               columns[7] = new String[]{"EXP_DATE", "DateTime"};
               columns[8] = new String[]{"STATE", "string"};
               columns[9] = new String[]{"STATE_DATE", "DateTime"};

               columnKeys = new String[]{
                   "ACCT_BALANCE_ID",
               };


               array = new String[10];
               hash.Add("ACCT_BALANCE_ID", 0);
               hash.Add("ACCT_ID", 1);
               hash.Add("ICCARD_NO", 2);
               hash.Add("ACCT_TYPE_NO", 3);
               hash.Add("BALANCE", 4);
               hash.Add("BANK_ACCT_NO", 5);
               hash.Add("EFF_DATE", 6);
               hash.Add("EXP_DATE", 7);
               hash.Add("STATE", 8);
               hash.Add("STATE_DATE", 9);
          }

          // 余额帐本标识
          public String ACCT_BALANCE_ID
          {
              get { return  GetString("ACCT_BALANCE_ID"); }
              set { SetString("ACCT_BALANCE_ID",value); }
          }

          // 账户类型标识
          public String ACCT_TYPE_NO
          {
              get { return GetString("ACCT_TYPE_NO"); }
              set { SetString("ACCT_TYPE_NO", value); }
          }

          // 帐户标识
          public String ACCT_ID
          {
              get { return  GetString("ACCT_ID"); }
              set { SetString("ACCT_ID",value); }
          }

          // 绑定代表IC卡号
          public String ICCARD_NO
          {
              get { return  GetString("ICCARD_NO"); }
              set { SetString("ICCARD_NO",value); }
          }

          // 余额
          public Int32 BALANCE
          {
              get { return  GetInt32("BALANCE"); }
              set { SetInt32("BALANCE",value); }
          }

          // 银行帐号
          public String BANK_ACCT_NO
          {
              get { return  GetString("BANK_ACCT_NO"); }
              set { SetString("BANK_ACCT_NO",value); }
          }

          // 生效时间
          public DateTime EFF_DATE
          {
              get { return  GetDateTime("EFF_DATE"); }
              set { SetDateTime("EFF_DATE",value); }
          }

          // 失效时间
          public DateTime EXP_DATE
          {
              get { return  GetDateTime("EXP_DATE"); }
              set { SetDateTime("EXP_DATE",value); }
          }

          // 状态
          public string STATE
          {
              get { return  Getstring("STATE"); }
              set { Setstring("STATE",value); }
          }

          // 状态时间
          public DateTime STATE_DATE
          {
              get { return  GetDateTime("STATE_DATE"); }
              set { SetDateTime("STATE_DATE",value); }
          }

     }
}



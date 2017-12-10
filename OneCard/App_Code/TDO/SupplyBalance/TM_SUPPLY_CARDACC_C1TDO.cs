using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.SupplyBalance
{
     // 卡账户非实时充值合账临时表
     public class TM_SUPPLY_CARDACC_C1TDO : DDOBase
     {
          public TM_SUPPLY_CARDACC_C1TDO()
          {
          }

          protected override void Init()
          {
               tableName = "TM_SUPPLY_CARDACC_C1";

               columns = new String[10][];
               columns[0] = new String[]{"CARDNO", "string"};
               columns[1] = new String[]{"REALCARDNO", "string"};
               columns[2] = new String[]{"TOTALSUPPLYTIMES", "Int32"};
               columns[3] = new String[]{"TOTALSUPPLYMONEY", "Int32"};
               columns[4] = new String[]{"DEALTIME", "DateTime"};
               columns[5] = new String[]{"LASTSUPPLYTIME", "DateTime"};
               columns[6] = new String[]{"CARDREALMONEY", "Int32"};
               columns[7] = new String[]{"ONLINECARDTRADENO", "string"};
               columns[8] = new String[]{"BATCHNO", "string"};
               columns[9] = new String[]{"REMARK", "String"};

               columnKeys = new String[]{
                   "CARDNO",
               };


               array = new String[10];
               hash.Add("CARDNO", 0);
               hash.Add("REALCARDNO", 1);
               hash.Add("TOTALSUPPLYTIMES", 2);
               hash.Add("TOTALSUPPLYMONEY", 3);
               hash.Add("DEALTIME", 4);
               hash.Add("LASTSUPPLYTIME", 5);
               hash.Add("CARDREALMONEY", 6);
               hash.Add("ONLINECARDTRADENO", 7);
               hash.Add("BATCHNO", 8);
               hash.Add("REMARK", 9);
          }

          // IC卡号
          public string CARDNO
          {
              get { return  Getstring("CARDNO"); }
              set { Setstring("CARDNO",value); }
          }

          // 实际增减卡号
          public string REALCARDNO
          {
              get { return  Getstring("REALCARDNO"); }
              set { Setstring("REALCARDNO",value); }
          }

          // 充值笔数
          public Int32 TOTALSUPPLYTIMES
          {
              get { return  GetInt32("TOTALSUPPLYTIMES"); }
              set { SetInt32("TOTALSUPPLYTIMES",value); }
          }

          // 充值金额
          public Int32 TOTALSUPPLYMONEY
          {
              get { return  GetInt32("TOTALSUPPLYMONEY"); }
              set { SetInt32("TOTALSUPPLYMONEY",value); }
          }

          // 处理时间
          public DateTime DEALTIME
          {
              get { return  GetDateTime("DEALTIME"); }
              set { SetDateTime("DEALTIME",value); }
          }

          // 最近充值时间
          public DateTime LASTSUPPLYTIME
          {
              get { return  GetDateTime("LASTSUPPLYTIME"); }
              set { SetDateTime("LASTSUPPLYTIME",value); }
          }

          // 最近卡实际余额
          public Int32 CARDREALMONEY
          {
              get { return  GetInt32("CARDREALMONEY"); }
              set { SetInt32("CARDREALMONEY",value); }
          }

          // 最近联机交易序号
          public string ONLINECARDTRADENO
          {
              get { return  Getstring("ONLINECARDTRADENO"); }
              set { Setstring("ONLINECARDTRADENO",value); }
          }

          // 批次号
          public string BATCHNO
          {
              get { return  Getstring("BATCHNO"); }
              set { Setstring("BATCHNO",value); }
          }

          // 备注
          public String REMARK
          {
              get { return  GetString("REMARK"); }
              set { SetString("REMARK",value); }
          }

     }
}



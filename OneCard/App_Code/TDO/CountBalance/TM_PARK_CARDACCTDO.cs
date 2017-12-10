using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.CountBalance
{
     // 园林年卡卡账户合账临时表
     public class TM_PARK_CARDACCTDO : DDOBase
     {
          public TM_PARK_CARDACCTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TM_PARK_CARDACC";

               columns = new String[6][];
               columns[0] = new String[]{"CARDNO", "string"};
               columns[1] = new String[]{"TOTALTIMES", "Int32"};
               columns[2] = new String[]{"MINSPARETIMES", "Int32"};
               columns[3] = new String[]{"DEALTIME", "DateTime"};
               columns[4] = new String[]{"BATCHNO", "string"};
               columns[5] = new String[]{"REMARK", "String"};

               columnKeys = new String[]{
                   "CARDNO",
               };


               array = new String[6];
               hash.Add("CARDNO", 0);
               hash.Add("TOTALTIMES", 1);
               hash.Add("MINSPARETIMES", 2);
               hash.Add("DEALTIME", 3);
               hash.Add("BATCHNO", 4);
               hash.Add("REMARK", 5);
          }

          // IC卡号
          public string CARDNO
          {
              get { return  Getstring("CARDNO"); }
              set { Setstring("CARDNO",value); }
          }

          // 消费次数
          public Int32 TOTALTIMES
          {
              get { return  GetInt32("TOTALTIMES"); }
              set { SetInt32("TOTALTIMES",value); }
          }

          // 最小剩余次数
          public Int32 MINSPARETIMES
          {
              get { return  GetInt32("MINSPARETIMES"); }
              set { SetInt32("MINSPARETIMES",value); }
          }

          // 处理时间
          public DateTime DEALTIME
          {
              get { return  GetDateTime("DEALTIME"); }
              set { SetDateTime("DEALTIME",value); }
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



using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.SupplyBalance
{
     // 非实时充值排重过滤表
     public class TF_SUPPLY_EXCLUDETDO : DDOBase
     {
          public TF_SUPPLY_EXCLUDETDO()
          {
          }

          protected override void Init()
          {
               tableName = "TF_SUPPLY_EXCLUDE";

               columns = new String[2][];
               columns[0] = new String[]{"IDENTIFYNO", "string"};
               columns[1] = new String[]{"BATCHNO", "string"};

               columnKeys = new String[]{
                   "IDENTIFYNO",
               };


               array = new String[2];
               hash.Add("IDENTIFYNO", 0);
               hash.Add("BATCHNO", 1);
          }

          // 排重序号
          public string IDENTIFYNO
          {
              get { return  Getstring("IDENTIFYNO"); }
              set { Setstring("IDENTIFYNO",value); }
          }

          // 批次号
          public string BATCHNO
          {
              get { return  Getstring("BATCHNO"); }
              set { Setstring("BATCHNO",value); }
          }

     }
}



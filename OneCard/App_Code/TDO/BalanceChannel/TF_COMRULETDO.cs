using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.BalanceChannel
{
     // 佣金计算规则编码表
     public class TF_COMRULETDO : DDOBase
     {
          public TF_COMRULETDO()
          {
          }

          protected override void Init()
          {
               tableName = "TF_COMRULE";

               columns = new String[8][];
               columns[0] = new String[]{"COMRULENO", "string"};
               columns[1] = new String[]{"SLOPE", "String"};
               columns[2] = new String[]{"OFFSET", "String"};
               columns[3] = new String[]{"LOWERBOUND", "Int32"};
               columns[4] = new String[]{"UPPERBOUND", "Int32"};
               columns[5] = new String[]{"UPDATESTAFFNO", "string"};
               columns[6] = new String[]{"UPDATETIME", "DateTime"};
               columns[7] = new String[]{"REMARK", "String"};

               columnKeys = new String[]{
                   "COMRULENO",
               };


               array = new String[8];
               hash.Add("COMRULENO", 0);
               hash.Add("SLOPE", 1);
               hash.Add("OFFSET", 2);
               hash.Add("LOWERBOUND", 3);
               hash.Add("UPPERBOUND", 4);
               hash.Add("UPDATESTAFFNO", 5);
               hash.Add("UPDATETIME", 6);
               hash.Add("REMARK", 7);
          }

          // 规则编码
          public string COMRULENO
          {
              get { return  Getstring("COMRULENO"); }
              set { Setstring("COMRULENO",value); }
          }

          // 佣金比例
          public String SLOPE
          {
              get { return  GetString("SLOPE"); }
              set { SetString("SLOPE",value); }
          }

          // 佣金固定值
          public String OFFSET
          {
              get { return  GetString("OFFSET"); }
              set { SetString("OFFSET",value); }
          }

          // 交易区间下限
          public Int32 LOWERBOUND
          {
              get { return  GetInt32("LOWERBOUND"); }
              set { SetInt32("LOWERBOUND",value); }
          }

          // 交易区间上限
          public Int32 UPPERBOUND
          {
              get { return  GetInt32("UPPERBOUND"); }
              set { SetInt32("UPPERBOUND",value); }
          }

          // 更新员工
          public string UPDATESTAFFNO
          {
              get { return  Getstring("UPDATESTAFFNO"); }
              set { Setstring("UPDATESTAFFNO",value); }
          }

          // 更新时间
          public DateTime UPDATETIME
          {
              get { return  GetDateTime("UPDATETIME"); }
              set { SetDateTime("UPDATETIME",value); }
          }

          // 备注
          public String REMARK
          {
              get { return  GetString("REMARK"); }
              set { SetString("REMARK",value); }
          }

     }
}



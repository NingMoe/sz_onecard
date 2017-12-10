using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.BalanceParameter
{
     // 结算处理时间状态表
     public class TP_DEALTIMETDO : DDOBase
     {
          public TP_DEALTIMETDO()
          {
          }

          protected override void Init()
          {
               tableName = "TP_DEALTIME";

               columns = new String[5][];
               columns[0] = new String[]{"DEALDATE", "DateTime"};
               columns[1] = new String[]{"DEALHOUR", "Int32"};
               columns[2] = new String[]{"USETAG", "string"};
               columns[3] = new String[]{"UPDATETIME", "DateTime"};
               columns[4] = new String[]{"REMARK", "String"};

               columnKeys = new String[]{
               };


               array = new String[5];
               hash.Add("DEALDATE", 0);
               hash.Add("DEALHOUR", 1);
               hash.Add("USETAG", 2);
               hash.Add("UPDATETIME", 3);
               hash.Add("REMARK", 4);
          }

          // 处理日期
          public DateTime DEALDATE
          {
              get { return  GetDateTime("DEALDATE"); }
              set { SetDateTime("DEALDATE",value); }
          }

          // 处理时间
          public Int32 DEALHOUR
          {
              get { return  GetInt32("DEALHOUR"); }
              set { SetInt32("DEALHOUR",value); }
          }

          // 有效标志
          public string USETAG
          {
              get { return  Getstring("USETAG"); }
              set { Setstring("USETAG",value); }
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



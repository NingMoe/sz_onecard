using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.BalanceParameter
{
     // 通道工作信号表
     public class TD_M_CHANNELSIGNALTDO : DDOBase
     {
          public TD_M_CHANNELSIGNALTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TD_M_CHANNELSIGNAL";

               columns = new String[6][];
               columns[0] = new String[]{"CHANNELNO", "string"};
               columns[1] = new String[]{"BATCHNO", "string"};
               columns[2] = new String[]{"FINISHEDSTEP", "Int32"};
               columns[3] = new String[]{"DEALTIME", "DateTime"};
               columns[4] = new String[]{"UPDATETIME", "DateTime"};
               columns[5] = new String[]{"REMARK", "String"};

               columnKeys = new String[]{
                   "CHANNELNO",
                   "BATCHNO",
               };


               array = new String[6];
               hash.Add("CHANNELNO", 0);
               hash.Add("BATCHNO", 1);
               hash.Add("FINISHEDSTEP", 2);
               hash.Add("DEALTIME", 3);
               hash.Add("UPDATETIME", 4);
               hash.Add("REMARK", 5);
          }

          // 通道编码
          public string CHANNELNO
          {
              get { return  Getstring("CHANNELNO"); }
              set { Setstring("CHANNELNO",value); }
          }

          // 批次号
          public string BATCHNO
          {
              get { return  Getstring("BATCHNO"); }
              set { Setstring("BATCHNO",value); }
          }

          // 完成任务
          public Int32 FINISHEDSTEP
          {
              get { return  GetInt32("FINISHEDSTEP"); }
              set { SetInt32("FINISHEDSTEP",value); }
          }

          // 处理时间
          public DateTime DEALTIME
          {
              get { return  GetDateTime("DEALTIME"); }
              set { SetDateTime("DEALTIME",value); }
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



using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.BalanceParameter
{
     // 通道编码表
     public class TD_M_CHANNELTDO : DDOBase
     {
          public TD_M_CHANNELTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TD_M_CHANNEL";

               columns = new String[6][];
               columns[0] = new String[]{"CHANNELNO", "string"};
               columns[1] = new String[]{"CHANNELNAME", "String"};
               columns[2] = new String[]{"CHANNELTYPE", "string"};
               columns[3] = new String[]{"TABLESUFFIX", "string"};
               columns[4] = new String[]{"USETAG", "string"};
               columns[5] = new String[]{"REMARK", "String"};

               columnKeys = new String[]{
                   "CHANNELNO",
               };


               array = new String[6];
               hash.Add("CHANNELNO", 0);
               hash.Add("CHANNELNAME", 1);
               hash.Add("CHANNELTYPE", 2);
               hash.Add("TABLESUFFIX", 3);
               hash.Add("USETAG", 4);
               hash.Add("REMARK", 5);
          }

          // 通道编码
          public string CHANNELNO
          {
              get { return  Getstring("CHANNELNO"); }
              set { Setstring("CHANNELNO",value); }
          }

          // 通道名
          public String CHANNELNAME
          {
              get { return  GetString("CHANNELNAME"); }
              set { SetString("CHANNELNAME",value); }
          }

          // 通道类型
          public string CHANNELTYPE
          {
              get { return  Getstring("CHANNELTYPE"); }
              set { Setstring("CHANNELTYPE",value); }
          }

          // 套表表名后缀
          public string TABLESUFFIX
          {
              get { return  Getstring("TABLESUFFIX"); }
              set { Setstring("TABLESUFFIX",value); }
          }

          // 启用标志
          public string USETAG
          {
              get { return  Getstring("USETAG"); }
              set { Setstring("USETAG",value); }
          }

          // 备注
          public String REMARK
          {
              get { return  GetString("REMARK"); }
              set { SetString("REMARK",value); }
          }

     }
}



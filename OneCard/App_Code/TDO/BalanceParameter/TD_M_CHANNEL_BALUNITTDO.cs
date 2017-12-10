using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.BalanceParameter
{
     // 通道与结算单元对应关系表
     public class TD_M_CHANNEL_BALUNITTDO : DDOBase
     {
          public TD_M_CHANNEL_BALUNITTDO()
          {
          }

          protected override void Init()
          {
               tableName = "TD_M_CHANNEL_BALUNIT";

               columns = new String[5][];
               columns[0] = new String[]{"CHANNELNO", "string"};
               columns[1] = new String[]{"BALUNITNO", "string"};
               columns[2] = new String[]{"CHANNELTYPE", "string"};
               columns[3] = new String[]{"USETAG", "string"};
               columns[4] = new String[]{"REMARK", "String"};

               columnKeys = new String[]{
                   "CHANNELNO",
                   "BALUNITNO",
               };


               array = new String[5];
               hash.Add("CHANNELNO", 0);
               hash.Add("BALUNITNO", 1);
               hash.Add("CHANNELTYPE", 2);
               hash.Add("USETAG", 3);
               hash.Add("REMARK", 4);
          }

          // 通道编码
          public string CHANNELNO
          {
              get { return  Getstring("CHANNELNO"); }
              set { Setstring("CHANNELNO",value); }
          }

          // 结算单元编码
          public string BALUNITNO
          {
              get { return  Getstring("BALUNITNO"); }
              set { Setstring("BALUNITNO",value); }
          }

          // 通道类型
          public string CHANNELTYPE
          {
              get { return  Getstring("CHANNELTYPE"); }
              set { Setstring("CHANNELTYPE",value); }
          }

          // 有效标志
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



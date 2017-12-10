using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.ChargeCard
{
     // 充值卡卡状态参数表
     public class TP_XFC_CARDSTATETDO : DDOBase
     {
          public TP_XFC_CARDSTATETDO()
          {
          }

          protected override void Init()
          {
               tableName = "TP_XFC_CARDSTATE";

               columns = new String[5][];
               columns[0] = new String[]{"CARDSTATECODE", "string"};
               columns[1] = new String[]{"CARDSTATE", "String"};
               columns[2] = new String[]{"UPDATETIME", "DateTime"};
               columns[3] = new String[]{"UPDATESTAFFNO", "string"};
               columns[4] = new String[]{"REMARK", "String"};

               columnKeys = new String[]{
                   "CARDSTATECODE",
               };


               array = new String[5];
               hash.Add("CARDSTATECODE", 0);
               hash.Add("CARDSTATE", 1);
               hash.Add("UPDATETIME", 2);
               hash.Add("UPDATESTAFFNO", 3);
               hash.Add("REMARK", 4);
          }

          // 卡状态码
          public string CARDSTATECODE
          {
              get { return  Getstring("CARDSTATECODE"); }
              set { Setstring("CARDSTATECODE",value); }
          }

          // 状态
          public String CARDSTATE
          {
              get { return  GetString("CARDSTATE"); }
              set { SetString("CARDSTATE",value); }
          }

          // 更新时间
          public DateTime UPDATETIME
          {
              get { return  GetDateTime("UPDATETIME"); }
              set { SetDateTime("UPDATETIME",value); }
          }

          // 更新员工
          public string UPDATESTAFFNO
          {
              get { return  Getstring("UPDATESTAFFNO"); }
              set { Setstring("UPDATESTAFFNO",value); }
          }

          // 备注
          public String REMARK
          {
              get { return  GetString("REMARK"); }
              set { SetString("REMARK",value); }
          }

     }
}



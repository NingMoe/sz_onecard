using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.BalanceChannel
{
     // 消费结算单元-佣金方案对应关系表
     public class TD_TBALUNIT_COMSCHEMETDO : DDOBase
     {
          public TD_TBALUNIT_COMSCHEMETDO()
          {
          }

          protected override void Init()
          {
               tableName = "TD_TBALUNIT_COMSCHEME";

               columns = new String[9][];
               columns[0] = new String[]{"ID", "string"};
               columns[1] = new String[]{"BALUNITNO", "string"};
               columns[2] = new String[]{"COMSCHEMENO", "string"};
               columns[3] = new String[]{"BEGINTIME", "DateTime"};
               columns[4] = new String[]{"ENDTIME", "DateTime"};
               columns[5] = new String[]{"USETAG", "string"};
               columns[6] = new String[]{"UPDATESTAFFNO", "string"};
               columns[7] = new String[]{"UPDATETIME", "DateTime"};
               columns[8] = new String[]{"REMARK", "String"};

               columnKeys = new String[]{
                   "ID",
               };


               array = new String[9];
               hash.Add("ID", 0);
               hash.Add("BALUNITNO", 1);
               hash.Add("COMSCHEMENO", 2);
               hash.Add("BEGINTIME", 3);
               hash.Add("ENDTIME", 4);
               hash.Add("USETAG", 5);
               hash.Add("UPDATESTAFFNO", 6);
               hash.Add("UPDATETIME", 7);
               hash.Add("REMARK", 8);
          }

          // 关系编码
          public string ID
          {
              get { return  Getstring("ID"); }
              set { Setstring("ID",value); }
          }

          // 结算单元编码
          public string BALUNITNO
          {
              get { return  Getstring("BALUNITNO"); }
              set { Setstring("BALUNITNO",value); }
          }

          // 佣金方案编码
          public string COMSCHEMENO
          {
              get { return  Getstring("COMSCHEMENO"); }
              set { Setstring("COMSCHEMENO",value); }
          }

          // 起始时间
          public DateTime BEGINTIME
          {
              get { return  GetDateTime("BEGINTIME"); }
              set { SetDateTime("BEGINTIME",value); }
          }

          // 终止时间
          public DateTime ENDTIME
          {
              get { return  GetDateTime("ENDTIME"); }
              set { SetDateTime("ENDTIME",value); }
          }

          // 有效标志
          public string USETAG
          {
              get { return  Getstring("USETAG"); }
              set { Setstring("USETAG",value); }
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



using System;
using System.Data;
using System.Configuration;
using System.Collections;
using Master;

namespace TDO.BalanceChannel
{
     // 售充佣金方案-佣金规则对应关系表
     public class TD_SSCOMSCHEME_COMRULETDO : DDOBase
     {
          public TD_SSCOMSCHEME_COMRULETDO()
          {
          }

          protected override void Init()
          {
               tableName = "TD_SSCOMSCHEME_COMRULE";

               columns = new String[6][];
               columns[0] = new String[]{"COMSCHEMENO", "string"};
               columns[1] = new String[]{"COMRULENO", "string"};
               columns[2] = new String[]{"USETAG", "string"};
               columns[3] = new String[]{"UPDATESTAFFNO", "string"};
               columns[4] = new String[]{"UPDATETIME", "DateTime"};
               columns[5] = new String[]{"REMARK", "String"};

               columnKeys = new String[]{
                   "COMSCHEMENO",
                   "COMRULENO",
               };


               array = new String[6];
               hash.Add("COMSCHEMENO", 0);
               hash.Add("COMRULENO", 1);
               hash.Add("USETAG", 2);
               hash.Add("UPDATESTAFFNO", 3);
               hash.Add("UPDATETIME", 4);
               hash.Add("REMARK", 5);
          }

          // 佣金方案编码
          public string COMSCHEMENO
          {
              get { return  Getstring("COMSCHEMENO"); }
              set { Setstring("COMSCHEMENO",value); }
          }

          // 佣金规则编码
          public string COMRULENO
          {
              get { return  Getstring("COMRULENO"); }
              set { Setstring("COMRULENO",value); }
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


